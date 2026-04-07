<?php
/**
 * Direct Login Endpoint - No Dependencies
 * Simple, fast, reliable
 */

// Configure session cookies BEFORE starting session
session_set_cookie_params([
    'lifetime' => 3600,
    'path' => '/',
    'domain' => '',
    'secure' => false,  // Allow HTTP for development
    'httponly' => true, // No JavaScript access
    'samesite' => 'Lax'
]);

// Start session AFTER cookie params set
session_start();

// Require CORS configuration
require_once 'config/cors.php';

header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(json_encode(['ok' => true]));
}

$input = json_decode(file_get_contents('php://input'), true) ?? [];
$username = trim($input['username'] ?? '');
$password = trim($input['password'] ?? '');

// Debug logging
error_log("LOGIN ATTEMPT: username='$username', password_length=" . strlen($password));

if (empty($username) || empty($password)) {
    http_response_code(400);
    exit(json_encode(['status' => 'error', 'message' => 'Username and password required']));
}

try {
    $conn = @new mysqli(
        getenv('MYSQL_HOST') ?: 'db',
        getenv('MYSQL_USER') ?: 'root',
        getenv('MYSQL_PASSWORD') ?: 'rootpassword',
        getenv('MYSQL_DATABASE') ?: 'my_app_db'
    );

    if ($conn->connect_error) {
        throw new Exception('DB connection failed');
    }

    // Query user with role details
    $stmt = $conn->prepare("
        SELECT u.id, u.username, u.email, u.password_hash, u.role_id, u.account_status, ur.role_name, ur.permissions
        FROM users u
        LEFT JOIN user_roles ur ON u.role_id = ur.id
        WHERE u.username = ? AND u.account_status = 'active'
    ");
    if (!$stmt) {
        throw new Exception('Query failed: ' . $conn->error);
    }

    $stmt->bind_param('s', $username);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows === 0) {
        error_log("LOGIN FAILED: User '$username' not found or inactive");
        http_response_code(401);
        exit(json_encode(['status' => 'error', 'message' => 'Invalid credentials']));
    }

    $user = $result->fetch_assoc();
    $stmt->close();

    if (!password_verify($password, $user['password_hash'])) {
        error_log("LOGIN FAILED: Wrong password for user '$username'");
        http_response_code(401);
        exit(json_encode(['status' => 'error', 'message' => 'Invalid credentials']));
    }

    error_log("LOGIN SUCCESS: User '$username' (ID: {$user['id']}, Role: {$user['role_name']}");

    $token = bin2hex(random_bytes(32));
    $roleId = (int)$user['role_id'];
    $roleName = $user['role_name'] ?? 'User'; // Fallback if role not found
    $permissions = json_decode($user['permissions'] ?? '[]', true);
    
    // SET SESSION VARIABLES
    $_SESSION['user_id'] = (int)$user['id'];
    $_SESSION['username'] = $user['username'];
    $_SESSION['email'] = $user['email'];
    $_SESSION['role_id'] = $roleId;
    $_SESSION['role_name'] = $roleName;
    $_SESSION['permissions'] = $permissions;

    http_response_code(200);
    echo json_encode([
        'status' => 'success',
        'token' => $token,
        'user' => [
            'id' => (int)$user['id'],
            'username' => $user['username'],
            'email' => $user['email'],
            'role_id' => $roleId,
            'role_name' => $roleName,
            'permissions' => $permissions
        ]
    ]);

    $conn->close();

} catch (Exception $e) {
    error_log('Login error: ' . $e->getMessage());
    http_response_code(500);
    exit(json_encode(['status' => 'error', 'message' => 'Server error']));
}
