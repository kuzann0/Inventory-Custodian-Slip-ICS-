<?php
/**
 * DYNAMIC DATA BINDING - Get All Workflow Entries
 * 
 * This endpoint retrieves all workflow entries with dynamic binding,
 * supporting filters for status and form type.
 * 
 * Usage: 
 * - GET /get_all_workflow_entries_binding.php
 * - GET /get_all_workflow_entries_binding.php?status=approved
 * - GET /get_all_workflow_entries_binding.php?form_type=ics
 * - GET /get_all_workflow_entries_binding.php?status=completed&form_type=ppe
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

    // Parse filters
    $filters = [];
    
    if (isset($_GET['status']) && !empty($_GET['status'])) {
        $filters['status'] = $_GET['status'];
    }
    
    if (isset($_GET['form_type']) && !empty($_GET['form_type'])) {
        $filters['form_type'] = $_GET['form_type'];
    }

    // Initialize Dynamic Data Binding
    $binding = new DynamicDataBinding($conn);

    // Get all entries with optional filters
    $entries = $binding->getAllWorkflowEntries($filters);

    $conn->close();

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'count' => count($entries),
        'filters' => $filters,
        'data' => $entries
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
