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
    $required_fields = ['item_description', 'item_category', 'unit_of_measure', 'quantity', 'unit_cost', 'total_cost', 'inventory_location'];
    foreach ($required_fields as $field) {
        if (empty($data[$field])) {
            throw new Exception("Missing required field: {$field}", 400);
        }
    }

    // Get PR info
    $pr_id = isset($data['pr_id']) ? (int)$data['pr_id'] : null;
    $pr_no = isset($data['pr_no']) ? $data['pr_no'] : null;

    // Create inventory entry or record in a logs/completion table
    // For now, we'll insert into audit_logs to record the ICS form completion
    $ics_data = json_encode($data);
    
    $stmt = $conn->prepare("
        INSERT INTO audit_logs (
            entity_type,
            entity_id,
            action,
            description,
            details,
            performed_by,
            created_at
        ) VALUES (
            'purchase_request',
            ?,
            'ics_form_submitted',
            ?,
            ?,
            ?,
            NOW()
        )
    ");

    if (!$stmt) {
        throw new Exception('Prepare failed: ' . $conn->error, 500);
    }

    $action_desc = "ICS Form submitted for PR: " . ($pr_no ? $pr_no : 'Unknown');
    
    // Bind parameters
    $stmt->bind_param(
        'issi',
        $pr_id,
        $action_desc,
        $ics_data,
        $user_id
    );

    if (!$stmt->execute()) {
        throw new Exception('Execute failed: ' . $stmt->error, 500);
    }

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

    $stmt->close();
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
