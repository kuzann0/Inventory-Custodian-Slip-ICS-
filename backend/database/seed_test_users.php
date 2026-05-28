<?php
/**
 * Seed Test Users Script
 * 
 * Creates test users for each role:
 * - role_id = 1: SuperAdmin (superadmin / SuperAdmin@2026)
 * - role_id = 2: Admin (admin / Admin@2026)
 * - role_id = 3: Employee (employee / Employee@2026)
 * 
 * Run this via: curl http://localhost:8080/database/seed_test_users.php
 */

header('Content-Type: application/json');

try {
    // Database connection
    $servername = getenv('MYSQL_HOST') ?? 'db';
    $dbuser = getenv('MYSQL_USER') ?? 'root';
    $dbpass = getenv('MYSQL_PASSWORD') ?? 'rootpassword';
    $dbname = getenv('MYSQL_DATABASE') ?? 'my_app_db';

    $conn = new mysqli($servername, $dbuser, $dbpass, $dbname);

    if ($conn->connect_error) {
        throw new Exception('Database connection failed: ' . $conn->connect_error);
    }

    $results = [];

    // =====================================
    // Get Role IDs
    // =====================================
    $roleQuery = "SELECT id, role_name FROM user_roles ORDER BY role_name";
    $roleResult = $conn->query($roleQuery);
    
    if (!$roleResult) {
        throw new Exception('Failed to fetch roles: ' . $conn->error);
    }

    $roles = [];
    while ($row = $roleResult->fetch_assoc()) {
        $roles[$row['role_name']] = $row['id'];
    }

    // Verify all roles exist
    if (count($roles) < 3) {
        throw new Exception('Not all roles exist. Run create_user_management_tables.php first');
    }

    $results['roles'] = [
        'SuperAdmin' => $roles['SuperAdmin'],
        'Admin' => $roles['Admin'],
        'Employee' => $roles['Employee']
    ];

    // =====================================
    // Test Users Data
    // =====================================
    $testUsers = [
        [
            'username' => 'superadmin',
            'email' => 'superadmin@ics.local',
            'password' => 'SuperAdmin@2026',
            'role_id' => $roles['SuperAdmin'],
            'is_superadmin' => 1,
            'description' => 'Super Administrator - Full system access'
        ],
        [
            'username' => 'admin',
            'email' => 'admin@ics.local',
            'password' => 'Admin@2026',
            'role_id' => $roles['Admin'],
            'is_superadmin' => 0,
            'description' => 'Administrator - Inventory management'
        ],
        [
            'username' => 'employee',
            'email' => 'employee@ics.local',
            'password' => 'Employee@2026',
            'role_id' => $roles['Employee'],
            'is_superadmin' => 0,
            'description' => 'Employee - Can view and create entries'
        ]
    ];

    // =====================================
    // Seed Test Users
    // =====================================
    $createdUsers = [];

    foreach ($testUsers as $testUser) {
        // Check if user already exists
        $checkStmt = $conn->prepare("SELECT id FROM users WHERE username = ?");
        $checkStmt->bind_param('s', $testUser['username']);
        $checkStmt->execute();
        $checkResult = $checkStmt->get_result();

        if ($checkResult->num_rows > 0) {
            $createdUsers[] = [
                'username' => $testUser['username'],
                'status' => 'exists',
                'message' => 'User already exists'
            ];
            $checkStmt->close();
            continue;
        }
        $checkStmt->close();

        // Hash password
        $passwordHash = password_hash($testUser['password'], PASSWORD_BCRYPT);

        // Insert user
        $insertStmt = $conn->prepare(
            "INSERT INTO users (username, email, password_hash, role_id, is_superadmin, account_status) 
             VALUES (?, ?, ?, ?, ?, 'active')"
        );

        if (!$insertStmt) {
            throw new Exception('Prepare failed: ' . $conn->error);
        }

        $insertStmt->bind_param(
            'sssii',
            $testUser['username'],
            $testUser['email'],
            $passwordHash,
            $testUser['role_id'],
            $testUser['is_superadmin']
        );

        if ($insertStmt->execute()) {
            $createdUsers[] = [
                'username' => $testUser['username'],
                'email' => $testUser['email'],
                'role_id' => $testUser['role_id'],
                'password' => $testUser['password'],
                'status' => 'created',
                'message' => '✓ ' . $testUser['description']
            ];
        } else {
            $createdUsers[] = [
                'username' => $testUser['username'],
                'status' => 'error',
                'message' => 'Failed to create: ' . $insertStmt->error
            ];
        }
        $insertStmt->close();
    }

    $conn->close();

    // Return results
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Test users seeded successfully',
        'roles' => $results['roles'],
        'users_created' => $createdUsers
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);

} catch (Exception $e) {
    error_log('Seed error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
