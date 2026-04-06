<?php
/**
 * Create User Endpoint
 * 
 * Only SuperAdmin can create new users (Admin or Employee roles)
 * POST /create_user.php
 * 
 * Request:
 * {
 *   "actor_id": 1 (SuperAdmin),
 *   "username": "newuser",
 *   "email": "user@example.com",
 *   "password": "securepass123",
 *   "role_id": 2 or 3 (Admin or Employee)
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
    $username = trim($input['username'] ?? '');
    $email = trim($input['email'] ?? '');
    $password = $input['password'] ?? '';
    $roleId = intval($input['role_id'] ?? 0);
    
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
        exit(json_encode(['status' => 'error', 'message' => 'Only SuperAdmin can create users']));
    }
    
    // Validate inputs
    if (empty($username) || empty($email) || empty($password)) {
        http_response_code(400);
        exit(json_encode(['status' => 'error', 'message' => 'Missing required fields']));
    }
    
    if (!in_array($roleId, [2, 3])) {
        http_response_code(400);
        exit(json_encode(['status' => 'error', 'message' => 'Invalid role_id (must be 2 or 3)']));
    }
    
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        http_response_code(400);
        exit(json_encode(['status' => 'error', 'message' => 'Invalid email format']));
    }
    
    if (strlen($password) < 6) {
        http_response_code(400);
        exit(json_encode(['status' => 'error', 'message' => 'Password must be at least 6 characters']));
    }
    
    // Check if username exists
    $checkUsernameStmt = $conn->prepare("SELECT id FROM users WHERE username = ?");
    $checkUsernameStmt->bind_param('s', $username);
    $checkUsernameStmt->execute();
    if ($checkUsernameStmt->get_result()->num_rows > 0) {
        http_response_code(400);
        exit(json_encode(['status' => 'error', 'message' => 'Username already exists']));
    }
    $checkUsernameStmt->close();
    
    // Check if email exists
    $checkEmailStmt = $conn->prepare("SELECT id FROM users WHERE email = ?");
    $checkEmailStmt->bind_param('s', $email);
    $checkEmailStmt->execute();
    if ($checkEmailStmt->get_result()->num_rows > 0) {
        http_response_code(400);
        exit(json_encode(['status' => 'error', 'message' => 'Email already exists']));
    }
    $checkEmailStmt->close();
    
    // Hash password
    $passwordHash = password_hash($password, PASSWORD_BCRYPT);
    
    // Start transaction
    $conn->begin_transaction();
    
    try {
        // Insert user
        $insertStmt = $conn->prepare(
            "INSERT INTO users (username, email, password_hash, role_id, created_at) 
             VALUES (?, ?, ?, ?, NOW())"
        );
        $insertStmt->bind_param('sssi', $username, $email, $passwordHash, $roleId);
        
        if (!$insertStmt->execute()) {
            throw new Exception('Failed to create user: ' . $insertStmt->error);
        }
        
        $newUserId = $conn->insert_id;
        $insertStmt->close();
        
        // Get role name
        $roleStmt = $conn->prepare("SELECT role_name FROM user_roles WHERE id = ?");
        $roleStmt->bind_param('i', $roleId);
        $roleStmt->execute();
        $roleResult = $roleStmt->get_result();
        $roleRow = $roleResult->fetch_assoc();
        $roleName = $roleRow['role_name'];
        $roleStmt->close();
        
        // Log to audit trail
        $action = 'CREATE';
        $ipAddress = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $auditStmt = $conn->prepare(
            "INSERT INTO capability_audit_log 
             (actor_id, target_id, action, ip_address) 
             VALUES (?, ?, ?, ?)"
        );
        $auditStmt->bind_param('iiss', $actorId, $newUserId, $action, $ipAddress);
        
        if (!$auditStmt->execute()) {
            error_log('Audit log insert failed: ' . $auditStmt->error);
        }
        $auditStmt->close();
        
        $conn->commit();
        
        http_response_code(201);
        echo json_encode([
            'status' => 'success',
            'message' => 'User created successfully',
            'user' => [
                'id' => $newUserId,
                'username' => $username,
                'email' => $email,
                'role_id' => $roleId,
                'role_name' => $roleName,
                'created_at' => date('Y-m-d H:i:s')
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
