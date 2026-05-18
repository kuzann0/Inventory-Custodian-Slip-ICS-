<?php
// TEST ENDPOINT - Remove auth for testing
require_once 'config/cors.php';
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

try {
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    $conn = new mysqli(
        getenv('MYSQL_HOST') ?: 'db',
        getenv('MYSQL_USER') ?: 'root',
        getenv('MYSQL_PASSWORD') ?: 'rootpassword',
        getenv('MYSQL_DATABASE') ?: 'my_app_db'
    );
    
    if ($conn->connect_error) {
        throw new Exception('DB error: ' . $conn->connect_error);
    }

    // Accept any user_id or default to 1
    $user_id = (int)($data['user_id'] ?? 1);
    
    // Validate required fields
    $required_fields = ['pr_no', 'item_name', 'quantity', 'unit', 'unit_cost', 'office'];
    foreach ($required_fields as $field) {
        if (empty($data[$field])) {
            throw new Exception("Missing required field: $field");
        }
    }

    $total_amount = (float)$data['quantity'] * (float)$data['unit_cost'];
    $form_type = $total_amount >= 50000 ? 'ppe' : 'ics';

    // Check if PR already exists
    $check_sql = "SELECT id FROM purchase_requests WHERE pr_no = ?";
    $stmt = $conn->prepare($check_sql);
    $stmt->bind_param('s', $data['pr_no']);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        throw new Exception('PR Number already exists');
    }
    $stmt->close();

    // Insert into purchase_requests table
    $insert_sql = "
        INSERT INTO purchase_requests (
            pr_no, item_name, description, quantity, unit, unit_cost, 
            total_amount, office, division_section, status, form_type, created_by
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'draft', ?, ?)
    ";

    $stmt = $conn->prepare($insert_sql);
    if (!$stmt) {
        throw new Exception('Prepare failed: ' . $conn->error);
    }

    $description = $data['description'] ?? '';
    $division_section = $data['division_section'] ?? '';
    
    $stmt->bind_param(
        'sssidsdssi',
        $data['pr_no'],
        $data['item_name'],
        $description,
        $data['quantity'],
        $data['unit_cost'],
        $total_amount,
        $data['office'],
        $division_section,
        $form_type,
        $user_id
    );

    if (!$stmt->execute()) {
        throw new Exception('Failed to create PR: ' . $stmt->error);
    }

    $pr_id = $stmt->insert_id;
    $stmt->close();

    // Log to workflow_history
    $history_sql = "
        INSERT INTO workflow_history (pr_id, status_to, action_by, action_type, notes)
        VALUES (?, 'draft', ?, 'created', 'Purchase Request created')
    ";

    $stmt = $conn->prepare($history_sql);
    $stmt->bind_param('ii', $pr_id, $user_id);
    $stmt->execute();
    $stmt->close();

    http_response_code(201);
    echo json_encode([
        'success' => true,
        'message' => 'Purchase Request submitted successfully',
        'pr_id' => $pr_id,
        'pr_no' => $data['pr_no'],
        'total_amount' => $total_amount,
        'form_type' => $form_type,
        'status' => 'draft'
    ]);

    $conn->close();

} catch (Exception $e) {
    http_response_code($e->getCode() ?: 500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
