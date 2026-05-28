<?php
// CORS Configuration
require_once 'config/cors.php';

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

    $conn = new mysqli(
        getenv('MYSQL_HOST') ?: 'db',
        getenv('MYSQL_USER') ?: 'root',
        getenv('MYSQL_PASSWORD') ?: 'rootpassword',
        getenv('MYSQL_DATABASE') ?: 'my_app_db'
    );
    
    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    // Get POST data first
    $json_input = file_get_contents('php://input');
    $data = json_decode($json_input, true);
    
    if (!$data || !is_array($data)) {
        throw new Exception('Invalid JSON data provided');
    }
    
    // Get user ID from multiple sources
    $user_id = null;
    
    // Priority 1: Request body
    if (isset($data['user_id']) && !empty($data['user_id'])) {
        $user_id = (int)$data['user_id'];
    }
    
    // Priority 2: Session
    if (!$user_id && isset($_SESSION['user_id'])) {
        $user_id = (int)$_SESSION['user_id'];
    }
    
    // Priority 3: Request header
    if (!$user_id && isset($_SERVER['HTTP_X_USER_ID'])) {
        $user_id = (int)$_SERVER['HTTP_X_USER_ID'];
    }
    
    // Priority 4: Default to user 1 for testing (REMOVE IN PRODUCTION)
    if (!$user_id || $user_id <= 0) {
        $user_id = 1; // Default test user
    }

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
        
        $stmt = $conn->prepare($update_sql);
        if (!$stmt) {
            throw new Exception('Prepare error: ' . $conn->error);
        }
        $stmt->bind_param('isi', $user_id, $notes, $data['pr_id']);
        
    } elseif ($action === 'reject') {
        $new_status = 'rejected';
        $update_sql = "
            UPDATE purchase_requests 
            SET status = 'rejected', 
                rejected_by = ?, 
                rejection_reason = ?
            WHERE id = ?
        ";
        
        $stmt = $conn->prepare($update_sql);
        if (!$stmt) {
            throw new Exception('Prepare error: ' . $conn->error);
        }
        $stmt->bind_param('isi', $user_id, $notes, $data['pr_id']);
        
    } else {
        throw new Exception('Invalid action');
    }

    if (!$stmt->execute()) {
        $stmt->close();
        throw new Exception('Update failed: ' . $stmt->error);
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
    if (!$stmt) {
        throw new Exception('History prepare error: ' . $conn->error);
    }
    $status_from = (string)$pr['status'];
    $action_type = $action === 'approve' ? 'approved' : 'rejected';
    $pr_id_int = (int)$data['pr_id'];
    $stmt->bind_param('ississ', $pr_id_int, $status_from, $new_status, $user_id, $action_type, $notes);
    if (!$stmt->execute()) {
        $stmt->close();
        throw new Exception('History insert failed: ' . $stmt->error);
    }
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
