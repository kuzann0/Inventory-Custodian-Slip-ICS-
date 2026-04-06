<?php
// Enable CORS - Allow from any origin with credentials
$origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
header('Access-Control-Allow-Origin: ' . $origin);
header('Access-Control-Allow-Methods: POST, GET, OPTIONS, DELETE, PUT');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

session_start();

try {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('Invalid request method');
    }

    $conn = new mysqli('db', 'root', 'rootpassword', 'my_app_db');
    
    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    // Get user ID from session
    $user_id = isset($_SESSION['user_id']) ? $_SESSION['user_id'] : null;
    if (!$user_id) {
        throw new Exception('User not authenticated', 401);
    }

    // Get POST data
    $data = json_decode(file_get_contents('php://input'), true);

    // Validate required fields
    $required_fields = ['pr_no', 'item_name', 'quantity', 'unit', 'unit_cost', 'office', 'division_section'];
    foreach ($required_fields as $field) {
        if (empty($data[$field])) {
            throw new Exception("Missing required field: $field");
        }
    }

    // Calculate total amount
    $total_amount = (float)$data['quantity'] * (float)$data['unit_cost'];

    // Determine form type based on amount threshold (50,000)
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
            pr_no, 
            item_name, 
            description, 
            quantity, 
            unit, 
            unit_cost, 
            total_amount, 
            office, 
            division_section, 
            status, 
            form_type, 
            created_by
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'draft', ?, ?)
    ";

    $stmt = $conn->prepare($insert_sql);
    if (!$stmt) {
        throw new Exception('Prepare failed: ' . $conn->error);
    }

    $description = $data['description'] ?? '';
    $stmt->bind_param(
        'sssidsdssi',
        $data['pr_no'],
        $data['item_name'],
        $description,
        $data['quantity'],
        $data['unit_cost'],
        $total_amount,
        $data['office'],
        $data['division_section'],
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
        INSERT INTO workflow_history (
            pr_id, 
            status_to, 
            action_by, 
            action_type, 
            notes
        ) VALUES (?, 'draft', ?, 'created', 'Purchase Request created')
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
