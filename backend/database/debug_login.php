<?php
/**
 * Debug: Test login with all known users
 * Shows what credentials actually work
 */

header('Content-Type: application/json');

try {
    $conn = new mysqli('db', 'root', 'rootpassword', 'my_app_db');
    
    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    // Get all users with password hash preview
    $result = $conn->query("
        SELECT id, username, email, password_hash, role_id, account_status
        FROM users 
        ORDER BY id
    ");

    $users = [];
    while ($row = $result->fetch_assoc()) {
        $users[] = [
            'id' => $row['id'],
            'username' => $row['username'],
            'email' => $row['email'],
            'role_id' => $row['role_id'],
            'status' => $row['account_status'],
            'hash_preview' => substr($row['password_hash'], 0, 20) . '...'
        ];
    }

    // Test specific login
    $testUsername = $_GET['test_user'] ?? 'kuzano';
    $testPassword = $_GET['test_pass'] ?? 'Kuzano@2026';

    $stmt = $conn->prepare("
        SELECT id, username, email, password_hash, role_id
        FROM users
        WHERE username = ?
    ");
    $stmt->bind_param('s', $testUsername);
    $stmt->execute();
    $testResult = $stmt->get_result();

    $testResponse = null;
    if ($testResult->num_rows > 0) {
        $user = $testResult->fetch_assoc();
        $passwordMatch = password_verify($testPassword, $user['password_hash']);
        $testResponse = [
            'username' => $testUsername,
            'password' => $testPassword,
            'user_found' => true,
            'password_match' => $passwordMatch,
            'result' => $passwordMatch ? 'LOGIN SUCCESS ✓' : 'PASSWORD WRONG ✗'
        ];
    } else {
        $testResponse = [
            'username' => $testUsername,
            'user_found' => false,
            'result' => 'USER NOT FOUND ✗'
        ];
    }

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'all_users' => $users,
        'test_login' => $testResponse,
        'working_credentials' => [
            'Username: superadmin / Password: SuperAdmin@2026',
            'Username: admin / Password: Admin@2026',
            'Username: employee / Password: Employee@2026',
            'Username: kuzano / Password: Kuzano@2026'
        ]
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
