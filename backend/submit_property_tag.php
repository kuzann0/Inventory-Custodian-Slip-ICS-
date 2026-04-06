<?php
/**
 * Submit property inventory tag - Link to purchase_requests
 */

header('Content-Type: application/json; charset=UTF-8');
session_start();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

try {
    $data = json_decode(file_get_contents('php://input'), true);
    
    $conn = new mysqli('db', 'root', 'rootpassword', 'my_app_db');
    
    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    $pr_id = $data['pr_id'] ?? 0;
    $pr_no = $data['pr_no'] ?? '';
    $property_number = $data['property_number'] ?? '';
    $model_number = $data['model_number'] ?? '';
    $description = $data['description'] ?? '';
    $serial_number = $data['serial_number'] ?? '';
    $unit_of_measure = $data['unit_of_measure'] ?? '';
    $acquisition_date = $data['acquisition_date'] ?? date('Y-m-d');
    $supplier = $data['supplier'] ?? '';
    $estimated_cost = $data['estimated_cost'] ?? 0;
    $location = $data['location'] ?? '';
    $status = $data['status'] ?? 'serviceable';
    $created_by = isset($_SESSION['user_id']) ? $_SESSION['user_id'] : null;

    if (!$property_number || !$description) {
        throw new Exception('Property number and description are required');
    }

    if (!$pr_id && !$pr_no) {
        throw new Exception('PR ID or PR Number is required');
    }

    // Insert property tag into property_inventory table
    $stmt = $conn->prepare("
        INSERT INTO property_inventory 
        (pr_id, pr_no, property_number, model_number, description, serial_number, unit_of_measure, acquisition_date, supplier, estimated_cost, location, status, created_by)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");

    $stmt->bind_param(
        'isssssssdssi',
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

    // Log to workflow_history if pr_id exists
    if ($pr_id) {
        $stmt = $conn->prepare("INSERT INTO workflow_history (pr_id, status_to, action_by, action_type, notes) VALUES (?, 'completed', ?, 'property_tagged', ?)");
        $notes = 'Property tagged as: ' . $property_number;
        $stmt->bind_param('iis', $pr_id, $created_by, $notes);
        $stmt->execute();
        $stmt->close();
    }

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Property inventory tag created successfully',
        'property_number' => $property_number,
        'property_id' => $property_id
    ]);

    $conn->close();

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
