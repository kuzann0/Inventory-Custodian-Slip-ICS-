<?php
// Suppress all warnings and notices
error_reporting(0);
ini_set('display_errors', '0');

/**
 * Submit property inventory tag - Link to purchase_requests
 * Creates fixed asset records for items with amount >= 50,000 (ABOVE PAR)
 */

// CORS Configuration
require_once 'config/cors.php';

header('Content-Type: application/json; charset=UTF-8');
session_start();

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

try {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!$data) {
        throw new Exception('Invalid JSON data');
    }
    
    $conn = new mysqli(
        getenv('MYSQL_HOST') ?: 'db',
        getenv('MYSQL_USER') ?: 'root',
        getenv('MYSQL_PASSWORD') ?: 'rootpassword',
        getenv('MYSQL_DATABASE') ?: 'my_app_db'
    );
    
    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    $pr_id = $data['pr_id'] ?? null;
    $pr_no = $data['pr_no'] ?? '';
    $property_number = $data['property_number'] ?? '';
    $model_number = $data['model_number'] ?? '';
    $description = $data['description'] ?? '';
    $serial_number = $data['serial_number'] ?? '';
    $unit_of_measure = $data['unit_of_measure'] ?? '';
    $acquisition_date = !empty($data['acquisition_date']) ? $data['acquisition_date'] : date('Y-m-d');
    $supplier = $data['supplier'] ?? '';
    $estimated_cost = !empty($data['estimated_cost']) ? (float)$data['estimated_cost'] : 0;
    $location = $data['location'] ?? '';
    $status = $data['status'] ?? 'serviceable';
    $created_by = isset($_SESSION['user_id']) ? $_SESSION['user_id'] : ($_SERVER['HTTP_X_USER_ID'] ?? 1);


    if (!$property_number || !$description) {
        throw new Exception('Property number and description are required');
    }


    // Check if property_number already exists
    $check_stmt = $conn->prepare("SELECT id FROM property_inventory_tags WHERE property_number = ?");
    if (!$check_stmt) {
        throw new Exception('Prepare failed: ' . $conn->error);
    }
    
    $check_stmt->bind_param('s', $property_number);
    $check_stmt->execute();
    $result = $check_stmt->get_result();
    
    if ($result->num_rows > 0) {
        throw new Exception('Property number already exists');
    }
    $check_stmt->close();

    // If pr_id provided, check if PR exists and get details
    if ($pr_id) {
        $pr_check = $conn->prepare("SELECT pr_no, total_amount FROM purchase_requests WHERE id = ?");
        if (!$pr_check) {
            throw new Exception('Prepare failed: ' . $conn->error);
        }
        
        $pr_check->bind_param('i', $pr_id);
        $pr_check->execute();
        $pr_result = $pr_check->get_result();
        
        if ($pr_result->num_rows > 0) {
            $pr_row = $pr_result->fetch_assoc();
            $pr_no = $pr_row['pr_no'];
            $total_amount = $pr_row['total_amount'];
            
            // ABOVE PAR threshold check (>= 50,000)
            if ($total_amount < 50000) {
                throw new Exception('Purchase amount must be >= 50,000 to register as fixed asset');
            }
        }
        
        $pr_check->close();
    }

    // Insert into property_inventory_tags table
    $stmt = $conn->prepare("
        INSERT INTO property_inventory_tags 
        (pr_id, pr_no, property_number, model_number, description, serial_number, unit_of_measure, acquisition_date, supplier, estimated_cost, location, status, created_by)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    if (!$stmt) {
        throw new Exception('Prepare failed: ' . $conn->error);
    }

    $stmt->bind_param(
        'issssssssdssi',
        $pr_id,
        $pr_no,
        $property_number,
        $model_number,
        $description,
        $serial_number,
        $unit_of_measure,
        $acquisition_date,
        $supplier,
        $estimated_cost,
        $location,
        $status,
        $created_by
    );

    if (!$stmt->execute()) {
        if (strpos($stmt->error, 'Duplicate') !== false) {
            throw new Exception('Property number already exists');
        }
        throw new Exception('Failed to insert property tag: ' . $stmt->error);
    }

    $property_id = $stmt->insert_id;
    $stmt->close();

    // Log to audit_logs if table exists
    $audit_stmt = $conn->prepare("
        INSERT INTO audit_logs (action, entity_type, entity_id, user_id, details)
        VALUES (?, ?, ?, ?, ?)
    ");

    if ($audit_stmt) {
        $action = 'created';
        $entity_type = 'property_inventory_tag';
        $details = json_encode(['property_number' => $property_number, 'pr_id' => $pr_id]);
        
        $audit_stmt->bind_param('ssiss', $action, $entity_type, $property_id, $created_by, $details);
        $audit_stmt->execute();
        $audit_stmt->close();
    }
    
        // ------------------------------------------------------------
    // Update entries table with final property number and serial
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
                        InventoryItemNo = ?, 
                        FormType = 'PPE'
                    WHERE order_id = ?
                ");
                if ($update_entry) {
                    $serial = $data['serial_number'] ?? '';
                    $inventory_no = $data['property_number'] ?? '';
                    $update_entry->bind_param('ssi', $serial, $inventory_no, $entry_id);
                    $update_entry->execute();
                    $update_entry->close();
                }
            }
            $find_entry->close();
        }
    }

    http_response_code(201);
    echo json_encode([
        'success' => true,
        'message' => 'Property inventory tag created successfully',
        'property_number' => $property_number,
        'property_id' => $property_id,
        'status' => 'registered_as_fixed_asset',
        'threshold' => 'ABOVE PAR (>= 50,000)'
    ]);

    $conn->close();

} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
