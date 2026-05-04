<?php
/**
 * DYNAMIC DATA BINDING - Unified Workflow Step Handler
 * 
 * This endpoint handles all workflow steps (2-5) using the
 * centralized DynamicDataBinding class. 
 * 
 * Single endpoint for all workflow progression:
 * - Step 2: Approval
 * - Step 3: Notice of Delivery
 * - Step 4: Inspection & Acceptance Report
 * - Step 5: Conditional Form (ICS/PPE)
 * 
 * Request format:
 * {
 *   "pr_id": 123,
 *   "step": 2,
 *   "data": { ...step-specific data... }
 * }
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

    // Parse request
    $input = file_get_contents('php://input');
    $request = json_decode($input, true);
    
    if (!$request) {
        throw new Exception('Invalid JSON input', 400);
    }

    // Get user ID
    $user_id = $request['user_id'] ?? $_SESSION['user_id'] ?? $_SERVER['HTTP_X_USER_ID'] ?? 1;

    // Validate required fields
    if (empty($request['pr_id'])) {
        throw new Exception('Missing pr_id', 400);
    }
    if (empty($request['step'])) {
        throw new Exception('Missing step number', 400);
    }
    if (!isset($request['data']) || !is_array($request['data'])) {
        throw new Exception('Missing or invalid data object', 400);
    }

    $pr_id = (int)$request['pr_id'];
    $step = (int)$request['step'];
    $data = $request['data'];

    // Initialize Dynamic Data Binding
    $binding = new DynamicDataBinding($conn);

    // Process workflow step
    $result = $binding->updateWorkflowStep($pr_id, $step, $data, (int)$user_id);

    // Log the step completion
    $log_sql = "INSERT INTO audit_logs (admin_id, action, action_details, created_at) VALUES (?, 'workflow_step_completed', ?, NOW())";
    $stmt = $conn->prepare($log_sql);
    $details = json_encode(['pr_id' => $pr_id, 'step' => $step]);
    $stmt->bind_param('is', $user_id, $details);
    $stmt->execute();
    $stmt->close();

    // Get updated workflow state
    $workflow = $binding->getWorkflowEntry($pr_id);

    $conn->close();

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => "Step $step completed successfully",
        'pr_id' => $pr_id,
        'step' => $step,
        'workflow' => $workflow
    ]);
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
