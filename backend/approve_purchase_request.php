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

    $user_id = isset($_SESSION['user_id']) ? $_SESSION['user_id'] : null;
    if (!$user_id) {
        throw new Exception('User not authenticated', 401);
    }

    $data = json_decode(file_get_contents('php://input'), true);

    if (empty($data['pr_id']) || empty($data['action'])) {
        throw new Exception('Missing pr_id or action');
    }

    $action = $data['action']; // 'approve' or 'reject'
    $notes = $data['notes'] ?? '';

    // Get current PR
    $sql = "SELECT pr_no, status FROM purchase_requests WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param('i', $data['pr_id']);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows === 0) {
        throw new Exception('Purchase Request not found');
    }

    $pr = $result->fetch_assoc();
    $stmt->close();

    // Update status and approval info
    if ($action === 'approve') {
        $new_status = 'approved';
        $update_sql = "
            UPDATE purchase_requests 
            SET status = 'approved', 
                approved_by = ?, 
                approval_date = NOW(), 
                approval_notes = ? 
            WHERE id = ?
        ";
    } elseif ($action === 'reject') {
        $new_status = 'rejected';
        $update_sql = "
            UPDATE purchase_requests 
            SET status = 'rejected', 
                rejected_by = ?, 
                rejection_reason = ? 
            WHERE id = ?
        ";
    } else {
        throw new Exception('Invalid action');
    }

    $stmt = $conn->prepare($update_sql);
    $stmt->bind_param('isi', $user_id, $notes, $data['pr_id']);

    if (!$stmt->execute()) {
        throw new Exception('Failed to update PR: ' . $stmt->error);
    }
    $stmt->close();

    // Log to workflow_history
    $history_sql = "
        INSERT INTO workflow_history (
            pr_id, 
            status_from, 
            status_to, 
            action_by, 
            action_type, 
            notes
        ) VALUES (?, ?, ?, ?, ?, ?)
    ";

    $stmt = $conn->prepare($history_sql);
    $status_from = $pr['status'];
    $action_type = $action === 'approve' ? 'approved' : 'rejected';
    $stmt->bind_param('issiiss', $data['pr_id'], $status_from, $new_status, $user_id, $action_type, $notes);
    $stmt->execute();
    $stmt->close();

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Purchase Request ' . ucfirst($action) . 'd successfully',
        'pr_no' => $pr['pr_no'],
        'new_status' => $new_status
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
