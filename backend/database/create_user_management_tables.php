<?php
/**
 * User Management Database Migration
 * 
 * Creates tables for:
 * - user_roles: Role definitions (SuperAdmin, Admin)
 * - users: User accounts with role assignment
 * - admin_accounts: Track admins created by SuperAdmin
 * 
 * Run this via: curl http://localhost:8080/database/create_user_management_tables.php
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

    $errors = [];

    // =====================================
    // 1. Create user_roles table
    // =====================================
    $createRolesSQL = "
    CREATE TABLE IF NOT EXISTS `user_roles` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `role_name` VARCHAR(50) UNIQUE NOT NULL COMMENT 'SuperAdmin or Admin',
        `role_description` TEXT,
        `permissions` JSON,
        `is_active` BOOLEAN DEFAULT TRUE,
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if (!$conn->query($createRolesSQL)) {
        $errors[] = 'Failed to create user_roles table: ' . $conn->error;
    } else {
        echo "✓ user_roles table created/verified\n";
    }

    // =====================================
    // 2. Create users table
    // =====================================
    $createUsersSQL = "
    CREATE TABLE IF NOT EXISTS `users` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `username` VARCHAR(100) UNIQUE NOT NULL,
        `email` VARCHAR(255) UNIQUE NOT NULL,
        `password_hash` VARCHAR(255) NOT NULL,
        `role_id` INT NOT NULL DEFAULT 2,
        `account_status` ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
        `is_superadmin` BOOLEAN DEFAULT FALSE COMMENT 'True if this is THE SuperAdmin',
        `last_login` TIMESTAMP NULL,
        `failed_attempts` INT DEFAULT 0,
        `locked_until` TIMESTAMP NULL,
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (role_id) REFERENCES user_roles(id) ON DELETE RESTRICT,
        INDEX idx_username (username),
        INDEX idx_email (email),
        INDEX idx_role_id (role_id),
        INDEX idx_account_status (account_status)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if (!$conn->query($createUsersSQL)) {
        $errors[] = 'Failed to create users table: ' . $conn->error;
    } else {
        echo "✓ users table created/verified\n";
    }

    // =====================================
    // 3. Create admin_accounts table
    // =====================================
    $createAdminAccountsSQL = "
    CREATE TABLE IF NOT EXISTS `admin_accounts` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `admin_user_id` INT NOT NULL UNIQUE,
        `created_by_superadmin_id` INT NOT NULL,
        `username` VARCHAR(100) NOT NULL,
        `email` VARCHAR(255) NOT NULL,
        `permissions` JSON COMMENT 'JSON array of admin permissions',
        `is_active` BOOLEAN DEFAULT TRUE,
        `last_login` TIMESTAMP NULL,
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        `notes` TEXT COMMENT 'Notes about this admin account',
        FOREIGN KEY (admin_user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (created_by_superadmin_id) REFERENCES users(id) ON DELETE RESTRICT,
        INDEX idx_is_active (is_active),
        INDEX idx_created_at (created_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if (!$conn->query($createAdminAccountsSQL)) {
        $errors[] = 'Failed to create admin_accounts table: ' . $conn->error;
    } else {
        echo "✓ admin_accounts table created/verified\n";
    }

    // =====================================
    // 4. Insert default roles if not exists
    // =====================================
    $superAdminPerms = json_encode([
        'create_admins',
        'edit_admins',
        'delete_admins',
        'view_all_users',
        'system_settings',
        'view_audit_logs',
        'manage_roles'
    ]);

    $adminPerms = json_encode([
        'view_entries',
        'create_entries',
        'edit_entries',
        'delete_entries',
        'view_users',
        'change_inventory'
    ]);

    $employeePerms = json_encode([
        'view_entries',
        'create_entries',
        'edit_own_entries'
    ]);

    $checkSuperAdminRole = "SELECT id FROM user_roles WHERE role_name = 'SuperAdmin'";
    $result = $conn->query($checkSuperAdminRole);

    if ($result->num_rows === 0) {
        $insertSuperAdminRole = "
        INSERT INTO user_roles (role_name, role_description, permissions, is_active) 
        VALUES (
            'SuperAdmin',
            'Super Administrator - Full system access including admin creation',
            '$superAdminPerms',
            TRUE
        )
        ";
        if ($conn->query($insertSuperAdminRole)) {
            echo "✓ SuperAdmin role created\n";
        } else {
            $errors[] = 'Failed to insert SuperAdmin role: ' . $conn->error;
        }
    }

    $checkAdminRole = "SELECT id FROM user_roles WHERE role_name = 'Admin'";
    $result = $conn->query($checkAdminRole);

    if ($result->num_rows === 0) {
        $insertAdminRole = "
        INSERT INTO user_roles (role_name, role_description, permissions, is_active) 
        VALUES (
            'Admin',
            'Administrator - Can manage inventory and entries',
            '$adminPerms',
            TRUE
        )
        ";
        if ($conn->query($insertAdminRole)) {
            echo "✓ Admin role created\n";
        } else {
            $errors[] = 'Failed to insert Admin role: ' . $conn->error;
        }
    }

    // =====================================
    // Employee Role
    // =====================================
    $checkEmployeeRole = "SELECT id FROM user_roles WHERE role_name = 'Employee'";
    $result = $conn->query($checkEmployeeRole);

    if ($result->num_rows === 0) {
        $insertEmployeeRole = "
        INSERT INTO user_roles (role_name, role_description, permissions, is_active) 
        VALUES (
            'Employee',
            'Employee - Can view and create inventory entries',
            '$employeePerms',
            TRUE
        )
        ";
        if ($conn->query($insertEmployeeRole)) {
            echo "✓ Employee role created\n";
        } else {
            $errors[] = 'Failed to insert Employee role: ' . $conn->error;
        }
    }

    // =====================================
    // 5. Create default SuperAdmin account
    // =====================================
    $checkSuperAdminExists = "SELECT id FROM users WHERE is_superadmin = TRUE";
    $result = $conn->query($checkSuperAdminExists);

    if ($result->num_rows === 0) {
        // Get SuperAdmin role ID
        $roleResult = $conn->query("SELECT id FROM user_roles WHERE role_name = 'SuperAdmin'");
        $roleRow = $roleResult->fetch_assoc();
        $superAdminRoleId = $roleRow['id'];

        // Create default SuperAdmin (password: SuperAdmin@2026)
        $superAdminPassword = password_hash('SuperAdmin@2026', PASSWORD_BCRYPT);
        $insertSuperAdmin = "
        INSERT INTO users (username, email, password_hash, role_id, is_superadmin, account_status) 
        VALUES (
            'superadmin',
            'superadmin@ics.local',
            '$superAdminPassword',
            $superAdminRoleId,
            TRUE,
            'active'
        )
        ";
        if ($conn->query($insertSuperAdmin)) {
            $superAdminId = $conn->insert_id;
            echo "✓ Default SuperAdmin account created\n";
            echo "  Username: superadmin\n";
            echo "  Email: superadmin@ics.local\n";
            echo "  Password: SuperAdmin@2026\n";
            echo "  ⚠️  IMPORTANT: Change this password after first login!\n";
        } else {
            $errors[] = 'Failed to create default SuperAdmin: ' . $conn->error;
        }
    }

    // =====================================
    // 6. Create audit_logs table (for tracking admin actions)
    // =====================================
    $createAuditSQL = "
    CREATE TABLE IF NOT EXISTS `audit_logs` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `admin_id` INT,
        `action` VARCHAR(255) NOT NULL,
        `action_details` JSON,
        `ip_address` VARCHAR(45),
        `user_agent` TEXT,
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE SET NULL,
        INDEX idx_admin_id (admin_id),
        INDEX idx_action (action),
        INDEX idx_created_at (created_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if (!$conn->query($createAuditSQL)) {
        $errors[] = 'Failed to create audit_logs table: ' . $conn->error;
    } else {
        echo "✓ audit_logs table created/verified\n";
    }

    // =====================================
    // 7. Create capabilities table
    // =====================================
    $createCapabilitiesSQL = "
    CREATE TABLE IF NOT EXISTS `capabilities` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `capability_key` VARCHAR(100) UNIQUE NOT NULL,
        `category` VARCHAR(50),
        `description` TEXT,
        `required_role_id` INT,
        `is_active` BOOLEAN DEFAULT TRUE,
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if (!$conn->query($createCapabilitiesSQL)) {
        $errors[] = 'Failed to create capabilities table: ' . $conn->error;
    } else {
        echo "✓ capabilities table created/verified\n";
    }

    // Insert default capabilities
    $defaultCapabilities = [
        ['view_dashboard', 'Dashboard', 'Access to dashboard', 1],
        ['manage_users', 'Users', 'Create and manage users', 1],
        ['manage_roles', 'Roles', 'Manage user roles', 1],
        ['view_entries', 'Entries', 'View all entries', 2],
        ['create_entry', 'Entries', 'Create new entry', 2],
        ['edit_entry', 'Entries', 'Edit entries', 2],
    ];

    foreach ($defaultCapabilities as $cap) {
        $stmt = $conn->prepare('INSERT IGNORE INTO capabilities (capability_key, category, description, required_role_id, is_active) VALUES (?, ?, ?, ?, TRUE)');
        $stmt->bind_param('sssi', $cap[0], $cap[1], $cap[2], $cap[3]);
        if (!$stmt->execute()) {
            $errors[] = 'Failed to insert capability ' . $cap[0] . ': ' . $stmt->error;
        }
    }
    echo "✓ Default capabilities inserted\n";

    $conn->close();

    // Return response
    if (count($errors) > 0) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Migration completed with errors',
            'errors' => $errors
        ]);
    } else {
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => 'User management tables created successfully!',
            'tables_created' => [
                'user_roles',
                'users',
                'admin_accounts',
                'audit_logs',
                'capabilities'
            ],
            'default_superadmin' => [
                'username' => 'superadmin',
                'password' => 'SuperAdmin@2026',
                'note' => 'Change immediately after first login'
            ]
        ]);
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Error: ' . $e->getMessage()
    ]);
}
?>
