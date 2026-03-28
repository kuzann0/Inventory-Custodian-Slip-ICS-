<?php
/**
 * Create Admin Account Endpoint
 * 
 * Only SuperAdmin can create new admin accounts
 * POST /create_admin.php
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

try {
    // Get input
    $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;

    // Validate SuperAdmin authorization
    $authHeader = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
    if (empty($authHeader)) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Missing authorization header']);
        exit;
    }

    // Database connection
    $servername = getenv('MYSQL_HOST') ?? 'db';
    $dbuser = getenv('MYSQL_USER') ?? 'root';
    $dbpass = getenv('MYSQL_PASSWORD') ?? 'rootpassword';
    $dbname = getenv('MYSQL_DATABASE') ?? 'my_app_db';

    $conn = new mysqli($servername, $dbuser, $dbpass, $dbname);

    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    // Verify SuperAdmin
    $superAdminCheck = "SELECT id FROM users WHERE is_superadmin = TRUE AND account_status = 'active' LIMIT 1";
    $result = $conn->query($superAdminCheck);

    if ($result->num_rows === 0) {
        http_response_code(403);
        echo json_encode(['success' => false, 'message' => 'No active SuperAdmin found']);
        $conn->close();
        exit;
    }

    $superAdmin = $result->fetch_assoc();
    $superAdminId = $superAdmin['id'];

    // Validate input
    $username = $input['username'] ?? '';
    $email = $input['email'] ?? '';
    $password = $input['password'] ?? '';
    $confirmPassword = $input['confirmPassword'] ?? '';
    $permissions = $input['permissions'] ?? [];
    $notes = $input['notes'] ?? '';

    if (empty($username) || empty($email) || empty($password)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Missing required fields']);
        $conn->close();
        exit;
    }

    // Validate password
    if ($password !== $confirmPassword) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Passwords do not match']);
        $conn->close();
        exit;
    }

    if (strlen($password) < 8) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Password must be at least 8 characters']);
        $conn->close();
        exit;
    }

    // Check if username exists
    $checkUsername = $conn->prepare("SELECT id FROM users WHERE username = ?");
    $checkUsername->bind_param("s", $username);
    $checkUsername->execute();
    if ($checkUsername->get_result()->num_rows > 0) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Username already exists']);
        $conn->close();
        exit;
    }

    // Check if email exists
    $checkEmail = $conn->prepare("SELECT id FROM users WHERE email = ?");
    $checkEmail->bind_param("s", $email);
    $checkEmail->execute();
    if ($checkEmail->get_result()->num_rows > 0) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Email already exists']);
        $conn->close();
        exit;
    }

    // Get Admin role ID
    $roleResult = $conn->query("SELECT id FROM user_roles WHERE role_name = 'Admin' AND is_active = TRUE");
    $roleRow = $roleResult->fetch_assoc();
    $adminRoleId = $roleRow['id'];

    // Hash password
    $passwordHash = password_hash($password, PASSWORD_BCRYPT);

    // Start transaction
    $conn->begin_transaction();

    try {
        // Insert user
        $insertUser = $conn->prepare("
            INSERT INTO users (username, email, password_hash, role_id, account_status) 
            VALUES (?, ?, ?, ?, 'active')
        ");
        $insertUser->bind_param("sssi", $username, $email, $passwordHash, $adminRoleId);
        $insertUser->execute();
        $userId = $conn->insert_id;

        // Insert admin account record
        $permissionsJSON = json_encode($permissions);
        $insertAdmin = $conn->prepare("
            INSERT INTO admin_accounts (admin_user_id, created_by_superadmin_id, username, email, permissions, is_active, notes) 
            VALUES (?, ?, ?, ?, ?, TRUE, ?)
        ");
        $insertAdmin->bind_param("iissss", $userId, $superAdminId, $username, $email, $permissionsJSON, $notes);
        $insertAdmin->execute();

        // Log action
        $action = 'CREATE_ADMIN';
        $actionDetails = json_encode([
            'admin_username' => $username,
            'admin_email' => $email,
            'permissions' => $permissions
        ]);
        $ipAddress = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'unknown';

        $logAudit = $conn->prepare("
            INSERT INTO audit_logs (admin_id, action, action_details, ip_address, user_agent) 
            VALUES (?, ?, ?, ?, ?)
        ");
        $logAudit->bind_param("issss", $superAdminId, $action, $actionDetails, $ipAddress, $userAgent);
        $logAudit->execute();

        $conn->commit();

        http_response_code(201);
        echo json_encode([
            'success' => true,
            'message' => 'Admin account created successfully',
            'admin' => [
                'id' => $userId,
                'username' => $username,
                'email' => $email,
                'role' => 'Admin',
                'created_at' => date('Y-m-d H:i:s')
            ]
        ]);

    } catch (Exception $e) {
        $conn->rollback();
        throw $e;
    }

    $conn->close();

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}
?>
