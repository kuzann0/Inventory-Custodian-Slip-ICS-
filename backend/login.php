<?php
/**
 * Direct Login Endpoint - No Dependencies
 * Simple, fast, reliable
 */

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(json_encode(['ok' => true]));
}

$input = json_decode(file_get_contents('php://input'), true) ?? [];
$username = $input['username'] ?? '';
$password = $input['password'] ?? '';

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
        SELECT u.id, u.username, u.email, u.password_hash, u.role_id, ur.role_name, ur.permissions
        FROM users u
        LEFT JOIN user_roles ur ON u.role_id = ur.id
        WHERE u.username = ?
    ");
    if (!$stmt) {
        throw new Exception('Query failed: ' . $conn->error);
    }

    $stmt->bind_param('s', $username);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows === 0) {
        http_response_code(401);
        exit(json_encode(['status' => 'error', 'message' => 'Invalid credentials']));
    }

    $user = $result->fetch_assoc();
    $stmt->close();

    if (!password_verify($password, $user['password_hash'])) {
        http_response_code(401);
        exit(json_encode(['status' => 'error', 'message' => 'Invalid credentials']));
    }

    $token = bin2hex(random_bytes(32));
    $roleId = (int)$user['role_id'];
    $roleName = $user['role_name'] ?? 'User'; // Fallback if role not found
    $permissions = json_decode($user['permissions'] ?? '[]', true);

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
