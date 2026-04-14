<?php
/**
 * Delete User Endpoint
 * 
 * Only SuperAdmin can delete users
 * - Revokes all capability grants before deletion
 * - Logs deletion action
 * - Prevents self-deletion
 * - Prevents deletion of SuperAdmin accounts
 * 
 * POST /delete_user.php
 * 
 * Request:
 * {
 *   "actor_id": 1 (SuperAdmin),
 *   "target_id": 5 (User to delete)
 * }
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

try {
    // Parse input
    $input = json_decode(file_get_contents('php://input'), true) ?? [];
    
    // Get parameters
    $actorId = intval($input['actor_id'] ?? 0);
    $targetId = intval($input['target_id'] ?? 0);
    
    // Database connection
    $servername = getenv('MYSQL_HOST') ?? 'db';
    $dbuser = getenv('MYSQL_USER') ?? 'root';
    $dbpass = getenv('MYSQL_PASSWORD') ?? 'rootpassword';
    $dbname = getenv('MYSQL_DATABASE') ?? 'my_app_db';
    
    $conn = new mysqli($servername, $dbuser, $dbpass, $dbname);
    
    if ($conn->connect_error) {
        http_response_code(500);
        exit(json_encode(['status' => 'error', 'message' => 'Database connection failed']));
    }
    
    // Validate actor is SuperAdmin
    $actorStmt = $conn->prepare("SELECT role_id FROM users WHERE id = ?");
    $actorStmt->bind_param('i', $actorId);
    $actorStmt->execute();
    $actorResult = $actorStmt->get_result();
    
    if ($actorResult->num_rows === 0) {
        http_response_code(403);
        exit(json_encode(['status' => 'error', 'message' => 'Actor not found']));
    }
    
    $actor = $actorResult->fetch_assoc();
    $actorStmt->close();
    
    if ($actor['role_id'] !== 1) {
        http_response_code(403);
        exit(json_encode(['status' => 'error', 'message' => 'Only SuperAdmin can delete users']));
    }
    
    // Prevent self-deletion
    if ($actorId === $targetId) {
        http_response_code(403);
        exit(json_encode(['status' => 'error', 'message' => 'Cannot delete your own account']));
    }
    
    // Validate target exists and get details
    $targetStmt = $conn->prepare("SELECT id, role_id, username FROM users WHERE id = ?");
    $targetStmt->bind_param('i', $targetId);
    $targetStmt->execute();
    $targetResult = $targetStmt->get_result();
    
    if ($targetResult->num_rows === 0) {
        http_response_code(404);
        exit(json_encode(['status' => 'error', 'message' => 'Target user not found']));
    }
    
    $target = $targetResult->fetch_assoc();
    $targetStmt->close();
    
    // Protect SuperAdmin accounts
    if ($target['role_id'] === 1) {
        http_response_code(403);
        exit(json_encode(['status' => 'error', 'message' => 'Cannot delete SuperAdmin accounts']));
    }
    
    // Start transaction
    $conn->begin_transaction();
    
    try {
        // Step 1: Revoke all capabilities for this user
        $revokeStmt = $conn->prepare(
            "DELETE FROM user_capabilities WHERE user_id = ?"
        );
        $revokeStmt->bind_param('i', $targetId);
        
        if (!$revokeStmt->execute()) {
            throw new Exception('Failed to revoke capabilities: ' . $revokeStmt->error);
        }
        $revokeStmt->close();
        
        // Step 2: Delete user
        $deleteStmt = $conn->prepare("DELETE FROM users WHERE id = ?");
        $deleteStmt->bind_param('i', $targetId);
        
        if (!$deleteStmt->execute()) {
            throw new Exception('Failed to delete user: ' . $deleteStmt->error);
        }
        $deleteStmt->close();
        
        // Step 3: Log deletion to audit trail
        $action = 'DELETE';
        $ipAddress = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $auditStmt = $conn->prepare(
            "INSERT INTO capability_audit_log 
             (actor_id, target_id, action, ip_address) 
             VALUES (?, ?, ?, ?)"
        );
        $auditStmt->bind_param('iiss', $actorId, $targetId, $action, $ipAddress);
        
        if (!$auditStmt->execute()) {
            error_log('Audit log insert failed: ' . $auditStmt->error);
        }
        $auditStmt->close();
        
        $conn->commit();
        
        http_response_code(200);
        echo json_encode([
            'status' => 'success',
            'message' => 'User deleted successfully',
            'deleted_user' => [
                'id' => $targetId,
                'username' => $target['username']
            ]
        ]);
        
    } catch (Exception $e) {
        $conn->rollback();
        http_response_code(500);
        exit(json_encode(['status' => 'error', 'message' => $e->getMessage()]));
    }
    
    $conn->close();
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Server error: ' . $e->getMessage()]);
}
?>
