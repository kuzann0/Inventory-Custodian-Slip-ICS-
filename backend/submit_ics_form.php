<?php
// CORS Configuration
require_once 'config/cors.php';

header('Content-Type: application/json');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

session_start();

try {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('Invalid request method', 400);
    }

    $conn = new mysqli(
        getenv('MYSQL_HOST') ?: 'db',
        getenv('MYSQL_USER') ?: 'root',
        getenv('MYSQL_PASSWORD') ?: 'rootpassword',
        getenv('MYSQL_DATABASE') ?: 'my_app_db'
    );
    
    if ($conn->connect_error) {
        throw new Exception('Database connection failed: ' . $conn->connect_error, 500);
    }

    // Get POST data
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    if (!$data) {
        throw new Exception('Invalid JSON input', 400);
    }

    // Get user ID from multiple sources
    $user_id = null;
    if (isset($data['user_id']) && !empty($data['user_id'])) {
        $user_id = (int)$data['user_id'];
    } elseif (isset($_SESSION['user_id'])) {
        $user_id = (int)$_SESSION['user_id'];
    } elseif (isset($_SERVER['HTTP_X_USER_ID'])) {
        $user_id = (int)$_SERVER['HTTP_X_USER_ID'];
    } else {
        $user_id = 1;
    }

    // Validate required fields
    $required_fields = ['item_description', 'quantity', 'unit_cost'];

    // Optional: Set defaults for missing fields
    $item_category = $data['item_category'] ?? ($data['itemCategory'] ?? 'office_supplies');
    $unit_of_measure = $data['unit_of_measure'] ?? ($data['unit'] ?? 'piece');
    $total_cost = $data['total_cost'] ?? ($data['total_amount'] ?? 0);
    $inventory_location = $data['inventory_location'] ?? ($data['location_code'] ?? 'storage');

    // Validate only critical fields
    foreach ($required_fields as $field) {
        if (empty($data[$field])) {
            throw new Exception("Missing required field: {$field}", 400);
        }
    }

    // Get PR info
    $pr_id = isset($data['pr_id']) ? (int)$data['pr_id'] : null;
    $pr_no = isset($data['pr_no']) ? $data['pr_no'] : null;

    // Create inventory entry or record in audit_logs to record the ICS form completion
    $ics_data = json_encode($data);
    
    $stmt = $conn->prepare("
        INSERT INTO audit_logs (
            admin_id,
            action,
            action_details,
            created_at
        ) VALUES (?, 'ics_form_completed', ?, NOW())
    ");

    if (!$stmt) {
        throw new Exception('Prepare failed for audit_logs: ' . $conn->error, 500);
    }
    
    $stmt->bind_param('is', $user_id, $ics_data);
    if (!$stmt->execute()) {
        throw new Exception('Execute failed for audit_logs: ' . $stmt->error, 500);
    }
    $stmt->close();

    // ✅ INSERT INTO ICS_FORMS TABLE
    // First ensure the table exists (optional – run this once in phpMyAdmin)
    $conn->query("
        CREATE TABLE IF NOT EXISTS `ics_forms` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `pr_id` int(11) DEFAULT NULL,
            `pr_no` varchar(100) DEFAULT NULL,
            `ics_entry_no` varchar(50) NOT NULL,
            `sp_value` enum('SPLV','SPHV') NOT NULL,
            `location_code` varchar(10) DEFAULT NULL,
            `items` json DEFAULT NULL,
            `total_amount` decimal(15,2) DEFAULT NULL,
            `received_from` varchar(255) DEFAULT NULL,
            `received_by` varchar(255) DEFAULT NULL,
            `position` varchar(100) DEFAULT NULL,
            `approved_by_position` varchar(100) DEFAULT NULL,
            `property_no` varchar(100) DEFAULT NULL,
            `estimated_useful_life` varchar(50) DEFAULT NULL,
            `remarks` text,
            `created_by` int(11) DEFAULT NULL,
            `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ");

    $ics_stmt = $conn->prepare("
        INSERT INTO ics_forms (
            pr_id, pr_no, ics_entry_no, sp_value, location_code,
            items, total_amount, received_from, received_by,
            position, approved_by_position, property_no,
            estimated_useful_life, remarks, created_by
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");
    
    if (!$ics_stmt) {
        throw new Exception('Prepare failed for ics_forms: ' . $conn->error, 500);
    }

    // Prepare values with fallbacks
    $ics_entry_no = $data['ics_entry_no'] ?? '';
    $sp_value = $data['sp_value'] ?? 'SPLV';
    $location_code = $data['location_code'] ?? '';
    $items_json = json_encode($data['items'] ?? []);
    $total_amount = $data['total_amount'] ?? 0;
    $received_from = $data['received_from'] ?? '';
    $received_by = $data['received_by'] ?? '';
    $position = $data['position'] ?? '';
    $approved_by_position = $data['approved_by_position'] ?? '';
    $property_no = $data['property_no'] ?? '';
    $estimated_useful_life = $data['estimated_useful_life'] ?? '';
    $remarks = $data['remarks'] ?? '';

    $ics_stmt->bind_param(
        'isssssdsssssssi',
        $pr_id,
        $pr_no,
        $ics_entry_no,
        $sp_value,
        $location_code,
        $items_json,
        $total_amount,
        $received_from,
        $received_by,
        $position,
        $approved_by_position,
        $property_no,
        $estimated_useful_life,
        $remarks,
        $user_id
    );

    if (!$ics_stmt->execute()) {
        throw new Exception('ICS insert failed: ' . $ics_stmt->error, 500);
    }
    $ics_stmt->close();

    // Update purchase request status to 'ics_form_completed'
    if ($pr_id) {
        $update_stmt = $conn->prepare("
            UPDATE purchase_requests 
            SET status = 'ics_form_completed', updated_at = NOW()
            WHERE id = ?
        ");
        
        if ($update_stmt) {
            $update_stmt->bind_param('i', $pr_id);
            $update_stmt->execute();
            $update_stmt->close();
        }
    }

    $conn->close();

    // Return success response
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'ICS Form submitted successfully',
        'pr_id' => $pr_id,
        'pr_no' => $pr_no
    ]);
    exit;

} catch (Exception $e) {
    http_response_code($e->getCode() ?: 500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
    exit;
}
?>