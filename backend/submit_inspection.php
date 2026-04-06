<?php
/**
 * Submit inspection notes - Updated for workflow_history tracking
 */

// Enable CORS - Allow from any origin with credentials
$origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
header('Access-Control-Allow-Origin: ' . $origin);
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json; charset=UTF-8');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

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

    $user_id = isset($_SESSION['user_id']) ? $_SESSION['user_id'] : null;
    $assignment_id = $data['assignment_id'] ?? 0;
    $pr_id = $data['pr_id'] ?? 0;
    $inspection_notes = $data['inspection_notes'] ?? '';
    $condition_report = $data['condition_report'] ?? '';

    if (!$assignment_id || !$pr_id || !$inspection_notes) {
        throw new Exception('Missing required fields');
    }

    // Update inspection_assignments table
    $stmt = $conn->prepare("UPDATE inspection_assignments SET status = 'completed', inspection_notes = ?, condition_report = ?, completed_date = NOW() WHERE id = ?");
    $stmt->bind_param('ssi', $inspection_notes, $condition_report, $assignment_id);

    if (!$stmt->execute()) {
        throw new Exception('Failed to update assignment: ' . $stmt->error);
    }
    $stmt->close();

    // Update purchase_requests table
    $stmt = $conn->prepare("UPDATE purchase_requests SET status = 'inspected', inspection_notes = ?, inspection_date = NOW(), inspected_by = ? WHERE id = ?");
    $stmt->bind_param('sii', $inspection_notes, $user_id, $pr_id);
    $stmt->execute();
    $stmt->close();

    // Log to workflow_history
    if ($user_id) {
        $stmt = $conn->prepare("INSERT INTO workflow_history (pr_id, status_from, status_to, action_by, action_type, notes) VALUES (?, 'in_delivery', 'inspected', ?, 'inspection_completed', ?)");
        $stmt->bind_param('iis', $pr_id, $user_id, $inspection_notes);
        $stmt->execute();
        $stmt->close();
    }

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Inspection submitted successfully'
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
