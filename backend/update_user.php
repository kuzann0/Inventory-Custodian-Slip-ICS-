<?php
/**
 * Update User Endpoint
 * 
 * Only SuperAdmin can update user details
 * SuperAdmin cannot update their own account (prevents self-modification)
 * POST /update_user.php
 * 
 * Request:
 * {
 *   "actor_id": 1 (SuperAdmin),
 *   "target_id": 5 (User to update),
 *   "username": "updatedname",
 *   "email": "updated@example.com",
 *   "role_id": 2 or 3 (optional)
 * }
 */

header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(json_encode(['ok' => true]));
}

try {
    // Parse input
    $input = json_decode(file_get_contents('php://input'), true) ?? [];
    
    // Get parameters
    $actorId = intval($input['actor_id'] ?? 0);
    $targetId = intval($input['target_id'] ?? 0);
    $username = !empty($input['username']) ? trim($input['username']) : null;
    $email = !empty($input['email']) ? trim($input['email']) : null;
    $roleId = !empty($input['role_id']) ? intval($input['role_id']) : null;
    
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
        exit(json_encode(['status' => 'error', 'message' => 'Only SuperAdmin can update users']));
    }
    
    // Prevent self-modification
    if ($actorId === $targetId) {
        http_response_code(403);
        exit(json_encode(['status' => 'error', 'message' => 'Cannot modify your own account']));
    }
    
    // Validate target exists
    $targetStmt = $conn->prepare("SELECT id, username, email, role_id FROM users WHERE id = ?");
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
        exit(json_encode(['status' => 'error', 'message' => 'Cannot modify SuperAdmin accounts']));
    }
    
    // Check if new username already exists (if changed)
    if (!is_null($username) && $username !== $target['username']) {
        $checkUsernameStmt = $conn->prepare("SELECT id FROM users WHERE username = ? AND id != ?");
        $checkUsernameStmt->bind_param('si', $username, $targetId);
        $checkUsernameStmt->execute();
        if ($checkUsernameStmt->get_result()->num_rows > 0) {
            http_response_code(400);
            exit(json_encode(['status' => 'error', 'message' => 'Username already exists']));
        }
        $checkUsernameStmt->close();
    }
    
    // Check if new email already exists (if changed)
    if (!is_null($email) && $email !== $target['email']) {
        $checkEmailStmt = $conn->prepare("SELECT id FROM users WHERE email = ? AND id != ?");
        $checkEmailStmt->bind_param('si', $email, $targetId);
        $checkEmailStmt->execute();
        if ($checkEmailStmt->get_result()->num_rows > 0) {
            http_response_code(400);
            exit(json_encode(['status' => 'error', 'message' => 'Email already exists']));
        }
        $checkEmailStmt->close();
    }
    
    // Validate new role if provided
    if (!is_null($roleId) && !in_array($roleId, [2, 3])) {
        http_response_code(400);
        exit(json_encode(['status' => 'error', 'message' => 'Invalid role_id (must be 2 or 3)']));
    }
    
    // Validate email format
    if (!is_null($email) && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        http_response_code(400);
        exit(json_encode(['status' => 'error', 'message' => 'Invalid email format']));
    }
    
    // Build update query
    $updates = [];
    $types = '';
    $values = [];
    
    if (!is_null($username)) {
        $updates[] = "username = ?";
        $types .= 's';
        $values[] = $username;
    }
    
    if (!is_null($email)) {
        $updates[] = "email = ?";
        $types .= 's';
        $values[] = $email;
    }
    
    if (!is_null($roleId)) {
        $updates[] = "role_id = ?";
        $types .= 'i';
        $values[] = $roleId;
    }
    
    if (empty($updates)) {
        http_response_code(400);
        exit(json_encode(['status' => 'error', 'message' => 'No fields to update']));
    }
    
    // Add updated_at timestamp
    $updates[] = "updated_at = NOW()";
    
    // Add target ID to bind params
    $types .= 'i';
    $values[] = $targetId;
    
    // Execute update
    $updateQuery = "UPDATE users SET " . implode(", ", $updates) . " WHERE id = ?";
    $updateStmt = $conn->prepare($updateQuery);
    
    if (!$updateStmt) {
        http_response_code(500);
        exit(json_encode(['status' => 'error', 'message' => 'Query preparation failed: ' . $conn->error]));
    }
    
    call_user_func_array([$updateStmt, 'bind_param'], 
        array_merge([$types], array_map(function(&$val) { return $val; }, $values)));
    
    if (!$updateStmt->execute()) {
        http_response_code(500);
        exit(json_encode(['status' => 'error', 'message' => 'Update failed: ' . $updateStmt->error]));
    }
    
    $updateStmt->close();
    
    // Log to audit trail
    $action = 'UPDATE';
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
    
    // Get updated user
    $selectStmt = $conn->prepare("
        SELECT u.id, u.username, u.email, u.role_id, ur.role_name 
        FROM users u
        LEFT JOIN user_roles ur ON u.role_id = ur.id
        WHERE u.id = ?"
    );
    $selectStmt->bind_param('i', $targetId);
    $selectStmt->execute();
    $updatedUser = $selectStmt->get_result()->fetch_assoc();
    $selectStmt->close();
    
    http_response_code(200);
    echo json_encode([
        'status' => 'success',
        'message' => 'User updated successfully',
        'user' => $updatedUser
    ]);
    
    $conn->close();
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Server error: ' . $e->getMessage()]);
}
?>
