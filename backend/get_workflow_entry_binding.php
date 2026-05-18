<?php
/**
 * DYNAMIC DATA BINDING - Get Workflow Entry Data
 * 
 * This endpoint retrieves complete workflow entry data with
 * all binding information for a specific purchase request.
 * 
 * Returns unified data from:
 * - entries table (single source of truth)
 * - entry_workflow_status (workflow progress)
 * - purchase_requests (metadata)
 * 
 * Usage: GET /get_workflow_entry_binding.php?pr_id=123
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
    if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
        throw new Exception('Invalid request method', 400);
    }

    // Get PR ID
    $pr_id = $_GET['pr_id'] ?? null;
    if (!$pr_id) {
        throw new Exception('Missing pr_id parameter', 400);
    }

    $pr_id = (int)$pr_id;

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

    // Initialize Dynamic Data Binding
    $binding = new DynamicDataBinding($conn);

    // Get workflow entry
    $entry = $binding->getWorkflowEntry($pr_id);

    $conn->close();

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'data' => $entry
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
