<?php
// Suppress all warnings and notices
error_reporting(0);
ini_set('display_errors', '0');

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

    // Validate required fields (make location_building optional with default)
    $required_fields = ['property_description', 'category', 'unit_of_measure', 'quantity', 'unit_cost', 'total_cost', 'estimated_useful_life', 'condition'];
    foreach ($required_fields as $field) {
        if (empty($data[$field])) {
            throw new Exception("Missing required field: {$field}", 400);
        }
    }
    
    // location_building is optional - use default if not provided
    $location_building = $data['location_building'] ?? 'Main Office';

    // Get PR info
    $pr_id = isset($data['pr_id']) ? (int)$data['pr_id'] : null;
    $pr_no = isset($data['pr_no']) ? $data['pr_no'] : null;

    // Insert into property_inventory table (mapped to existing schema)
    $stmt = $conn->prepare("
        INSERT INTO property_inventory (
            pr_id,
            pr_no,
            property_number,
            description,
            model_number,
            serial_number,
            unit_of_measure,
            acquisition_date,
            supplier,
            estimated_cost,
            location,
            status,
            created_by,
            created_at
        ) VALUES (
            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'serviceable', ?, NOW()
        )
    ");

    if (!$stmt) {
        throw new Exception('Prepare failed: ' . $conn->error, 500);
    }

    // Create a property number from PR number and category
    $property_number = $pr_no . '-' . strtoupper(substr($data['category'], 0, 3)) . '-' . date('Ymd');
    
    // Handle optional date fields
    $acquisition_date = !empty($data['acquisition_date']) ? $data['acquisition_date'] : date('Y-m-d');
    
    // Bind parameters (12 parameters total)
    $stmt->bind_param(
        'isssssssdsii',
        $pr_id,
        $pr_no,
        $property_number,
        $data['property_description'],
        $data['model_number'],
        $data['serial_number'],
        $data['unit_of_measure'],
        $acquisition_date,
        $data['supplier_name'],
        $data['total_cost'],
        $location_building,
        $user_id
    );

    if (!$stmt->execute()) {
        throw new Exception('Execute failed: ' . $stmt->error, 500);
    }

    $property_id = $conn->insert_id;

    // Update purchase request status to 'ppe_form_completed'
    if ($pr_id) {
        $update_stmt = $conn->prepare("
            UPDATE purchase_requests 
            SET status = 'ppe_form_completed', updated_at = NOW()
            WHERE id = ?
        ");
        
        if ($update_stmt) {
            $update_stmt->bind_param('i', $pr_id);
            $update_stmt->execute();
            $update_stmt->close();
        }
    }
        // ------------------------------------------------------------
    // Update entries table with PPE data
    // ------------------------------------------------------------
    if ($pr_id) {
        $find_entry = $conn->prepare("SELECT entry_id FROM workflow_status WHERE pr_id = ? LIMIT 1");
        if ($find_entry) {
            $find_entry->bind_param('i', $pr_id);
            $find_entry->execute();
            $res_entry = $find_entry->get_result();
            if ($entry_row = $res_entry->fetch_assoc()) { 
                $entry_id = $entry_row['entry_id'];
                
                $update_entry = $conn->prepare("
                    UPDATE entries 
                    SET SerialNo = ?, 
                        EstimatedUsefulLife = ?, 
                        FormType = 'PPE'
                    WHERE order_id = ?
                ");
                if ($update_entry) {
                    $serial = $data['serial_number'] ?? '';
                    $est_life = $data['estimated_useful_life'] ?? '';
                    $update_entry->bind_param('ssi', $serial, $est_life, $entry_id);
                    $update_entry->execute();
                    $update_entry->close();
                }
            }
            $find_entry->close();
        }
    }

    $stmt->close();
    $conn->close();

    // Return success response
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'PPE Form submitted successfully',
        'property_id' => $property_id,
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
