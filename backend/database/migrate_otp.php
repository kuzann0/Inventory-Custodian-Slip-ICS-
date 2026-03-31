<?php
/**
 * OTP Database Migration
 * 
 * Creates otp_codes table for storing OTP sessions
 * Run on first deployment
 */

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
    // CREATE OTP CODES TABLE
    // ========================================================================
    
    $createOTPTableSQL = "
    CREATE TABLE IF NOT EXISTS otp_codes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        otp_id VARCHAR(255) UNIQUE NOT NULL,
        email VARCHAR(100) NOT NULL,
        otp_code VARCHAR(6) NOT NULL,
        status ENUM('pending', 'verified', 'expired', 'used') DEFAULT 'pending',
        attempts INT DEFAULT 0,
        created_at INT NOT NULL,
        expires_at INT NOT NULL,
        verified_at INT NULL,
        used_at INT NULL,
        INDEX idx_otp_id (otp_id),
        INDEX idx_email (email),
        INDEX idx_status (status),
        INDEX idx_expires_at (expires_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if ($conn->query($createOTPTableSQL)) {
        $response[] = ['success' => true, 'message' => 'OTP codes table created successfully'];
    } else {
        $response[] = ['success' => false, 'error' => 'Failed to create OTP table: ' . $conn->error];
    }

    // ========================================================================
    // CREATE ADMIN BYPASS LOG TABLE
    // ========================================================================

    $createBypassLogTableSQL = "
    CREATE TABLE IF NOT EXISTS admin_bypass_log (
        id INT AUTO_INCREMENT PRIMARY KEY,
        admin_id INT,
        bypassed_user_email VARCHAR(100),
        bypass_key VARCHAR(255),
        ip_address VARCHAR(45),
        user_agent TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_admin_id (admin_id),
        INDEX idx_created_at (created_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if ($conn->query($createBypassLogTableSQL)) {
        $response[] = ['success' => true, 'message' => 'Admin bypass log table created successfully'];
    } else {
        $response[] = ['success' => false, 'error' => 'Failed to create bypass log table: ' . $conn->error];
    }

    // ========================================================================
    // CREATE OTP SETTINGS TABLE
    // ========================================================================

    $createSettingsTableSQL = "
    CREATE TABLE IF NOT EXISTS otp_settings (
        id INT PRIMARY KEY DEFAULT 1,
        enabled BOOLEAN DEFAULT true,
        expiry_minutes INT DEFAULT 5,
        max_attempts INT DEFAULT 5,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if ($conn->query($createSettingsTableSQL)) {
        $response[] = ['success' => true, 'message' => 'OTP settings table created successfully'];
    } else {
        $response[] = ['success' => false, 'error' => 'Failed to create settings table: ' . $conn->error];
    }

    // Insert default settings if not exists
    $checkSettings = $conn->query("SELECT COUNT(*) as count FROM otp_settings");
    $settingsCount = $checkSettings->fetch_assoc()['count'];

    if ($settingsCount === 0) {
        $insertSettings = "INSERT INTO otp_settings (id, enabled, expiry_minutes, max_attempts) VALUES (1, true, 5, 5)";
        if ($conn->query($insertSettings)) {
            $response[] = ['success' => true, 'message' => 'OTP settings initialized'];
        }
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
