<?php
/**
 * Grant/Revoke User Capability Endpoint
 * 
 * SuperAdmin: Can grant/revoke any capability to any user
 * Admin: Can grant managed capabilities to Employees only
 * Employee: Cannot grant anything
 * 
 * File: backend/grant_capability.php
 */

header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(json_encode(['ok' => true]));
}

// Load database and utilities
$servername = getenv('MYSQL_HOST') ?? 'db';
$dbuser = getenv('MYSQL_USER') ?? 'root';
$dbpass = getenv('MYSQL_PASSWORD') ?? 'rootpassword';
$dbname = getenv('MYSQL_DATABASE') ?? 'my_app_db';

$conn = new mysqli($servername, $dbuser, $dbpass, $dbname);

if ($conn->connect_error) {
    http_response_code(500);
    exit(json_encode(['success' => false, 'error' => 'Database connection failed']));
}

// Load PermissionValidator class
require_once __DIR__ . '/lib/PermissionValidator.php';

// Parse request
$input = json_decode(file_get_contents('php://input'), true) ?? [];

$actorId = intval($input['actor_id'] ?? 0);
$targetId = intval($input['target_id'] ?? 0);
$capabilityId = intval($input['capability_id'] ?? 0);
$action = strtoupper($input['action'] ?? '');  // GRANT or REVOKE

try {
    // ═════════════════════════════════════════════════════════════
    // VALIDATION CHAIN
    // ═════════════════════════════════════════════════════════════
    
    // 1. Validate inputs
    if (!$actorId || !$targetId || !$capabilityId || !in_array($action, ['GRANT', 'REVOKE'])) {
        throw new Exception('Missing or invalid parameters');
    }
    
    // 2. Initialize validator as actor
    $validator = new PermissionValidator($conn, $actorId);
    
    // 3. Actor must have edit_admin_caps or edit_employee_caps
    $hasAdminEdit = $validator->hasCapability('edit_admin_caps');
    $hasEmployeeEdit = $validator->hasCapability('edit_employee_caps');
    
    if (!$hasAdminEdit && !$hasEmployeeEdit) {
        throw new Exception('You lack capability management permissions');
    }
    
    // 4. Validate target user (will check hierarchy)
    $target = $validator->validateTarget($targetId, $action);
    
    // 5. Get capability info and validate it can be granted to target
    $validator->validateCapabilityGrant($capabilityId, $target['role_id']);
    
    // ═════════════════════════════════════════════════════════════
    // EXECUTE OPERATION
    // ═════════════════════════════════════════════════════════════
    
    $conn->begin_transaction();
    
    try {
        if ($action === 'GRANT') {
            // Check if already granted
            $checkStmt = $conn->prepare(
                "SELECT id FROM user_capabilities 
                 WHERE user_id = ? AND capability_id = ?"
            );
            $checkStmt->bind_param('ii', $targetId, $capabilityId);
            $checkStmt->execute();
            
            if ($checkStmt->get_result()->num_rows > 0) {
                throw new Exception('Target already has this capability');
            }
            $checkStmt->close();
            
            // Grant capability
            $grantStmt = $conn->prepare(
                "INSERT INTO user_capabilities 
                 (user_id, capability_id, granted_by_id) 
                 VALUES (?, ?, ?)"
            );
            $grantStmt->bind_param('iii', $targetId, $capabilityId, $actorId);
            
            if (!$grantStmt->execute()) {
                throw new Exception('Failed to grant capability: ' . $grantStmt->error);
            }
            $grantStmt->close();
            
        } else {  // REVOKE
            // Check if exists
            $checkStmt = $conn->prepare(
                "SELECT id FROM user_capabilities 
                 WHERE user_id = ? AND capability_id = ?"
            );
            $checkStmt->bind_param('ii', $targetId, $capabilityId);
            $checkStmt->execute();
            
            if ($checkStmt->get_result()->num_rows === 0) {
                throw new Exception('Target does not have this capability');
            }
            $checkStmt->close();
            
            // Revoke capability
            $revokeStmt = $conn->prepare(
                "DELETE FROM user_capabilities 
                 WHERE user_id = ? AND capability_id = ?"
            );
            $revokeStmt->bind_param('ii', $targetId, $capabilityId);
            
            if (!$revokeStmt->execute()) {
                throw new Exception('Failed to revoke capability: ' . $revokeStmt->error);
            }
            $revokeStmt->close();
        }
        
        // ═════════════════════════════════════════════════════════════
        // LOG AUDIT TRAIL
        // ═════════════════════════════════════════════════════════════
        
        $ipAddress = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $auditStmt = $conn->prepare(
            "INSERT INTO capability_audit_log 
             (actor_id, target_id, action, capability_id, ip_address) 
             VALUES (?, ?, ?, ?, ?)"
        );
        $auditStmt->bind_param('iisss', $actorId, $targetId, $action, $capabilityId, $ipAddress);
        
        if (!$auditStmt->execute()) {
            error_log('Audit log insert failed: ' . $auditStmt->error);
            // Don't fail the operation, just log error
        }
        $auditStmt->close();
        
        // Commit transaction
        $conn->commit();
        
        // ═════════════════════════════════════════════════════════════
        // SUCCESS RESPONSE
        // ═════════════════════════════════════════════════════════════
        
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'action' => $action,
            'target_id' => $targetId,
            'target_username' => $target['username'],
            'capability_id' => $capabilityId,
            'message' => ($action === 'GRANT' 
                ? 'Capability granted successfully'
                : 'Capability revoked successfully'),
            'timestamp' => date('Y-m-d H:i:s')
        ]);
        
    } catch (Exception $e) {
        $conn->rollback();
        throw $e;
    }
    
} catch (Exception $e) {
    http_response_code(403);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ]);
}

$conn->close();
?>
