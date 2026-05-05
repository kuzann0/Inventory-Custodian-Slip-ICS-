<?php
/**
 * Submit delivery notes and mark as delivered
 */

// CORS Configuration
require_once 'config/cors.php';

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
    
    $conn = new mysqli(
        getenv('MYSQL_HOST') ?: 'db',
        getenv('MYSQL_USER') ?: 'root',
        getenv('MYSQL_PASSWORD') ?: 'rootpassword',
        getenv('MYSQL_DATABASE') ?: 'my_app_db'
    );
    
    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    $pr_id = $data['pr_id'] ?? 0;
    $delivery_notes = $data['delivery_notes'] ?? '';
    $actual_delivery_date = $data['actual_delivery_date'] ?? null;

    if (!$pr_id || !$delivery_notes) {
        throw new Exception('Missing required fields');
    }

    // Get current status
    $stmt = $conn->prepare("SELECT status FROM purchase_requests WHERE id = ?");
    $stmt->bind_param('i', $pr_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        throw new Exception('PR not found');
    }
    
    $pr = $result->fetch_assoc();
    $current_status = $pr['status'];
    $stmt->close();

    // Update purchase_requests
    $stmt = $conn->prepare("UPDATE purchase_requests SET status = 'in_delivery', delivery_notes = ?, actual_delivery_date = ? WHERE id = ?");
    $stmt->bind_param('ssi', $delivery_notes, $actual_delivery_date, $pr_id);
    
    if (!$stmt->execute()) {
        throw new Exception('Failed to update delivery info: ' . $stmt->error);
    }
    $stmt->close();

    // Log to workflow_history
    if ($user_id) {
        $stmt = $conn->prepare("INSERT INTO workflow_history (pr_id, status_from, status_to, action_by, action_type, notes) VALUES (?, ?, 'in_delivery', ?, 'delivery_noted', ?)");
        $stmt->bind_param('isis', $pr_id, $current_status, $user_id, $delivery_notes);
        $stmt->execute();
        $stmt->close();
    }

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Delivery notes submitted successfully'
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
