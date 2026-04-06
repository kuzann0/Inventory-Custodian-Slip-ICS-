<?php
/**
 * Set test user passwords for development
 * This is for testing only - in production use proper password management
 */

header('Content-Type: application/json');

try {
    $conn = new mysqli('db', 'root', 'rootpassword', 'my_app_db');
    
    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    // Define test passwords for known users
    $testUsers = [
        'superadmin' => 'SuperAdmin@2026',
        'admin' => 'Admin@2026',
        'employee' => 'Employee@2026',
        'kuzano' => 'Kuzano@2026'
    ];

    $updated = [];

    // Update each user with proper password hash
    foreach ($testUsers as $username => $password) {
        $passwordHash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 10]);
        
        $stmt = $conn->prepare("UPDATE users SET password_hash = ? WHERE username = ?");
        $stmt->bind_param('ss', $passwordHash, $username);
        
        if ($stmt->execute()) {
            if ($stmt->affected_rows > 0) {
                $updated[] = [
                    'username' => $username,
                    'password' => $password,
                    'status' => 'updated'
                ];
            } else {
                $updated[] = [
                    'username' => $username,
                    'status' => 'user_not_found'
                ];
            }
        } else {
            $updated[] = [
                'username' => $username,
                'status' => 'error',
                'error' => $stmt->error
            ];
        }
        $stmt->close();
    }

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Test passwords configured successfully',
        'updated' => $updated,
        'test_credentials' => [
            'superadmin@ics.local / SuperAdmin@2026',
            'admin@ics.local / Admin@2026',
            'employee@ics.local / Employee@2026',
            'kuzano.1001@gmail.com / Kuzano@2026'
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
