<?php
/**
 * Complete workflow process - Mark PR as completed
 */

session_start();

$origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
header('Access-Control-Allow-Origin: ' . $origin);
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, X-Requested-With');
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json; charset=UTF-8');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(0);
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

try {
    $data = json_decode(file_get_contents('php://input'), true);
    $user_id = isset($_SESSION['user_id']) ? $_SESSION['user_id'] : null;
    
    $conn = new mysqli('db', 'root', 'rootpassword', 'my_app_db');
    
    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    $pr_id = $data['pr_id'] ?? 0;

    if (!$pr_id) {
        throw new Exception('Missing pr_id');
    }

    // Get current PR details
    $stmt = $conn->prepare("SELECT pr_no, status, form_type, total_amount FROM purchase_requests WHERE id = ?");
    $stmt->bind_param('i', $pr_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        throw new Exception('PR not found');
    }
    
    $pr = $result->fetch_assoc();
    $current_status = $pr['status'];
    $stmt->close();

    // Update purchase_requests status to completed
    $stmt = $conn->prepare("UPDATE purchase_requests SET status = 'completed', updated_at = NOW() WHERE id = ?");
    $stmt->bind_param('i', $pr_id);
    
    if (!$stmt->execute()) {
        throw new Exception('Failed to complete PR: ' . $stmt->error);
    }
    $stmt->close();

    // Log to workflow_history
    if ($user_id) {
        $notes = 'Purchase request workflow completed';
        $stmt = $conn->prepare("INSERT INTO workflow_history (pr_id, status_from, status_to, action_by, action_type, notes) VALUES (?, ?, 'completed', ?, 'process_completed', ?)");
        $stmt->bind_param('isIs', $pr_id, $current_status, $user_id, $notes);
        $stmt->execute();
        $stmt->close();
    }

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Workflow process completed successfully',
        'pr' => [
            'id' => $pr_id,
            'pr_no' => $pr['pr_no'],
            'total_amount' => $pr['total_amount'],
            'form_type' => $pr['form_type'],
            'status' => 'completed'
        ]
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
