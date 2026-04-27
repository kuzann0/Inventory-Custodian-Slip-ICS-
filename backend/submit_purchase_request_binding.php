<?php
/**
 * DYNAMIC DATA BINDING - Updated Purchase Request Submission
 * 
 * This endpoint now uses the centralized DynamicDataBinding class
 * to manage all workflow data through the entries table.
 * 
 * Backward compatible with existing purchase_requests table.
 */

require_once 'config/cors.php';
require_once 'DynamicDataBinding.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

session_start();

try {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('Invalid request method', 400);
    }

    // Database connection
    $conn = new mysqli(
        getenv('MYSQL_HOST') ?: 'db',
        getenv('MYSQL_USER') ?: 'root',
        getenv('MYSQL_PASSWORD') ?: 'rootpassword',
        getenv('MYSQL_DATABASE') ?: 'my_app_db'
    );
    
    if ($conn->connect_error) {
        throw new Exception('Database connection failed', 500);
    }

    // Parse request data
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    if (!$data) {
        throw new Exception('Invalid JSON input', 400);
    }

    // Get user ID
    $user_id = $data['user_id'] ?? $_SESSION['user_id'] ?? $_SERVER['HTTP_X_USER_ID'] ?? 1;

    // Validate required fields
    $required_fields = ['pr_no', 'item_name', 'quantity', 'unit', 'unit_cost', 'office', 'division_section'];
    foreach ($required_fields as $field) {
        if (empty($data[$field])) {
            throw new Exception("Missing required field: $field", 400);
        }
    }

    // Initialize Dynamic Data Binding
    $binding = new DynamicDataBinding($conn);

    // Create workflow entry using centralized binding
    $result = $binding->createWorkflowEntry($data, (int)$user_id);

    // Log successful creation
    $log_sql = "INSERT INTO audit_logs (admin_id, action, action_details, created_at) VALUES (?, 'pr_created_via_binding', ?, NOW())";
    $stmt = $conn->prepare($log_sql);
    $details = json_encode(['pr_no' => $data['pr_no'], 'entry_id' => $result['entry_id'], 'pr_id' => $result['pr_id']]);
    $stmt->bind_param('is', $user_id, $details);
    $stmt->execute();
    $stmt->close();

    $conn->close();

    http_response_code(201);
    echo json_encode($result);
    exit;

} catch (Exception $e) {
    http_response_code($e->getCode() ?: 500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
    exit;
}
?>
