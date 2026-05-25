<?php
/**
 * Logout Endpoint
 * 
 * Clears session and revokes authentication tokens
 */

require_once 'config/cors.php';
header('Content-Type: application/json');

session_start();

try {
    // Get user ID from session
    $user_id = $_SESSION['user_id'] ?? null;
    
    if (!$user_id) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'error' => 'Not authenticated'
        ]);
        exit();
    }
    
    // Log the logout action
    require_once 'config/db.php';
    
    $stmt = $conn->prepare("
        INSERT INTO audit_logs (admin_id, action, action_details, ip_address, user_agent)
        VALUES (?, 'LOGOUT', JSON_OBJECT('session_id', ?), ?, ?)
    ");
    
    if ($stmt) {
        $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $user_agent = $_SERVER['HTTP_USER_AGENT'] ?? 'unknown';
        $session_id = session_id();
        
        $stmt->bind_param('isss', $user_id, $session_id, $ip, $user_agent);
        $stmt->execute();
        $stmt->close();
    }
    
    // Destroy session
    session_destroy();
    
    // Clear authentication cookie
    setcookie('auth_token', '', time() - 3600, '/', '', true, true); // HttpOnly, Secure
    
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Logout successful'
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Logout failed',
        'details' => $e->getMessage()
    ]);
}
?>
