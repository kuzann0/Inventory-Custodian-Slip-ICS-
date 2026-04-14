<?php
/**
 * Database Migration Script
 * 
 * Creates users table and initializes default users
 * Run this after initial Docker setup
 */

// Database Connection
$servername = getenv('MYSQL_HOST') ?? 'db';
$username   = getenv('MYSQL_USER') ?? 'root';
$password   = getenv('MYSQL_PASSWORD') ?? 'rootpassword';
$dbname     = getenv('MYSQL_DATABASE') ?? 'my_app_db';

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(['success' => false, 'error' => 'Connection failed: ' . $conn->connect_error]));
}

header('Content-Type: application/json');

try {
    // ========================================================================
    // CREATE USERS TABLE
    // ========================================================================
    
    $createTableSQL = "
    CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        role ENUM('admin', 'user', 'moderator') DEFAULT 'user',
        status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
        last_login TIMESTAMP NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_username (username),
        INDEX idx_email (email),
        INDEX idx_role (role)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if ($conn->query($createTableSQL)) {
        $response[] = ['success' => true, 'message' => 'Users table created successfully'];
    } else {
        $response[] = ['success' => false, 'error' => 'Failed to create users table: ' . $conn->error];
    }

    // ========================================================================
    // CREATE LOGIN AUDIT TABLE
    // ========================================================================

    $auditTableSQL = "
    CREATE TABLE IF NOT EXISTS login_audit (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(50) NOT NULL,
        login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        ip_address VARCHAR(45),
        user_agent TEXT,
        mode ENUM('online', 'offline') DEFAULT 'online',
        success BOOLEAN DEFAULT false,
        INDEX idx_username (username),
        INDEX idx_login_time (login_time)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if ($conn->query($auditTableSQL)) {
        $response[] = ['success' => true, 'message' => 'Login audit table created successfully'];
    } else {
        $response[] = ['success' => false, 'error' => 'Failed to create login audit table: ' . $conn->error];
    }

    // ========================================================================
    // CREATE OFFLINE EMAILS TABLE (for backup)
    // ========================================================================

    $emailTableSQL = "
    CREATE TABLE IF NOT EXISTS offline_emails (
        id INT AUTO_INCREMENT PRIMARY KEY,
        recipient_email VARCHAR(100) NOT NULL,
        subject VARCHAR(255) NOT NULL,
        body LONGTEXT,
        status ENUM('pending', 'sent', 'failed') DEFAULT 'pending',
        attempts INT DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        sent_at TIMESTAMP NULL,
        INDEX idx_status (status),
        INDEX idx_recipient (recipient_email)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if ($conn->query($emailTableSQL)) {
        $response[] = ['success' => true, 'message' => 'Offline emails table created successfully'];
    } else {
        $response[] = ['success' => false, 'error' => 'Failed to create offline emails table: ' . $conn->error];
    }

    // ========================================================================
    // INSERT DEFAULT ADMIN USER
    // ========================================================================

    $adminUsername = 'admin';
    $adminEmail = 'admin@ics-system.local';
    $adminPassword = 'password123'; // Change this in production!
    $adminPasswordHash = password_hash($adminPassword, PASSWORD_BCRYPT);

    // Check if admin user already exists
    $checkAdmin = $conn->query("SELECT id FROM users WHERE username = 'admin'");
    
    if ($checkAdmin->num_rows === 0) {
        $insertAdminSQL = "INSERT INTO users (username, email, password_hash, role, status) VALUES (?, ?, ?, 'admin', 'active')";
        $stmt = $conn->prepare($insertAdminSQL);
        $stmt->bind_param("sss", $adminUsername, $adminEmail, $adminPasswordHash);
        
        if ($stmt->execute()) {
            $response[] = [
                'success' => true, 
                'message' => 'Default admin user created',
                'credentials' => [
                    'username' => 'admin',
                    'password' => 'password123',
                    'note' => 'CHANGE THIS PASSWORD IN PRODUCTION'
                ]
            ];
        } else {
            $response[] = ['success' => false, 'error' => 'Failed to create admin user: ' . $conn->error];
        }
        $stmt->close();
    } else {
        $response[] = ['success' => true, 'message' => 'Admin user already exists'];
    }

    // ========================================================================
    // INSERT DEMO USER
    // ========================================================================

    $demoUsername = 'demo';
    $demoEmail = 'demo@ics-system.local';
    $demoPassword = 'demo123';
    $demoPasswordHash = password_hash($demoPassword, PASSWORD_BCRYPT);

    $checkDemo = $conn->query("SELECT id FROM users WHERE username = 'demo'");
    
    if ($checkDemo->num_rows === 0) {
        $insertDemoSQL = "INSERT INTO users (username, email, password_hash, role, status) VALUES (?, ?, ?, 'user', 'active')";
        $stmt = $conn->prepare($insertDemoSQL);
        $stmt->bind_param("sss", $demoUsername, $demoEmail, $demoPasswordHash);
        
        if ($stmt->execute()) {
            $response[] = [
                'success' => true, 
                'message' => 'Demo user created',
                'credentials' => [
                    'username' => 'demo',
                    'password' => 'demo123'
                ]
            ];
        } else {
            $response[] = ['success' => false, 'error' => 'Failed to create demo user: ' . $conn->error];
        }
        $stmt->close();
    } else {
        $response[] = ['success' => true, 'message' => 'Demo user already exists'];
    }

    $conn->close();

    echo json_encode($response, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => 'Migration error: ' . $e->getMessage()
    ]);
}
?>
