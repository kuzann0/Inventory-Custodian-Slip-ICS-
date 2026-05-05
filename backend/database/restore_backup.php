<?php
/**
 * Restore proper database schema from backup
 */

header('Content-Type: application/json');

try {
    $servername = getenv('MYSQL_HOST') ?? 'db';
    $dbuser = getenv('MYSQL_USER') ?? 'root';
    $dbpass = getenv('MYSQL_PASSWORD') ?? 'rootpassword';
    $dbname = getenv('MYSQL_DATABASE') ?? 'my_app_db';

    $conn = new mysqli($servername, $dbuser, $dbpass, $dbname);

    if ($conn->connect_error) {
        throw new Exception('Database connection failed: ' . $conn->connect_error);
    }

    // Drop existing tables to get clean restore
    $dropTables = [
        'user_capabilities',
        'capability_audit_log',
        'role_audit_logs',
        'admin_accounts',
        'audit_logs',
        'capabilities',
        'otp_codes',
        'entries',
        'users',
        'user_roles'
    ];

    foreach ($dropTables as $table) {
        $conn->query("DROP TABLE IF EXISTS `$table`");
    }
    echo "✓ Dropped existing tables\n";

    // Recreate user_roles
    $createRolesSQL = "
    CREATE TABLE `user_roles` (
        `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
        `role_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE,
        `role_description` text COLLATE utf8mb4_unicode_ci,
        `permissions` json DEFAULT NULL,
        `is_active` tinyint(1) DEFAULT '1',
        `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
        `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    $conn->query($createRolesSQL);
    echo "✓ Created user_roles table\n";

    // Insert roles
    $rolesData = [
        [1, 'SuperAdmin', 'Super Administrator - Full system access including admin creation', '["create_admins", "edit_admins", "delete_admins", "view_all_users", "system_settings", "view_audit_logs", "manage_roles"]'],
        [2, 'Admin', 'Administrator - Can manage inventory and entries', '["view_entries", "create_entries", "edit_entries", "delete_entries", "view_users", "change_inventory"]'],
        [3, 'Employee', 'Employee - Can view and create inventory entries', '["view_entries", "create_entries", "edit_own_entries"]']
    ];

    foreach ($rolesData as $role) {
        $stmt = $conn->prepare("INSERT INTO user_roles (id, role_name, role_description, permissions) VALUES (?, ?, ?, ?)");
        $stmt->bind_param('isss', ...$role);
        $stmt->execute();
    }
    echo "✓ Inserted roles\n";

    // Recreate users table
    $createUsersSQL = "
    CREATE TABLE `users` (
        `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
        `username` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE,
        `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE,
        `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
        `role_id` int(11) NOT NULL DEFAULT '2',
        `account_status` enum('active','inactive','suspended') COLLATE utf8mb4_unicode_ci DEFAULT 'active',
        `is_superadmin` tinyint(1) DEFAULT '0',
        `last_login` timestamp NULL DEFAULT NULL,
        `failed_attempts` int(11) DEFAULT '0',
        `locked_until` timestamp NULL DEFAULT NULL,
        `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
        `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (role_id) REFERENCES user_roles(id),
        KEY idx_username (username),
        KEY idx_email (email),
        KEY idx_role_id (role_id),
        KEY idx_account_status (account_status)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    $conn->query($createUsersSQL);
    echo "✓ Created users table\n";

    // Insert users from backup
    $usersData = [
        [1, 'superadmin', 'superadmin@ics.local', '$2y$10$JuzdwISa4W1yBM9gkP2fTe0lACKEm/q4YI.dAE.3v8uMYphygFw4S', 1, 'active', 1],
        [2, 'admin', 'admin@ics.local', '$2y$10$wPpm2WkaQ92iJ28lf6c2nuTXWUd3BN3KgxPa2kACwhqE0GvzOnE1O', 2, 'active', 0],
        [3, 'employee', 'employee@ics.local', '$2y$10$nDQ67/3wPXYkeiEs1J7e9uODqJEfMnZKQZY20BnNV1J.Rl/FKjBli', 3, 'active', 0],
        [4, 'testemployee', 'testemployee@test.com', '$2y$10$WasdJWDGmdxcmPQnloSAbOVLf.Cni6cqwq9F7.b1VmSLx095fWtoK', 3, 'active', 0],
        [6, 'testuser', 'test@example.com', '$2y$10$dIWqGw0MdtN5104LVx8rD.wwm95yd7S2oPl9p3oLNmRlIzw7kPo2i', 3, 'active', 0],
        [7, 'kuzano', 'kuzano.1001@gmail.com', '$2y$10$ASZqbZczrJGeBe9S8zoHYO0BqISIi.fxzM.s34yIfeow3H0HSFe1u', 3, 'active', 0]
    ];

    foreach ($usersData as $user) {
        list($id, $username, $email, $hash, $role_id, $status, $is_superadmin) = $user;
        $stmt = $conn->prepare("INSERT INTO users (id, username, email, password_hash, role_id, account_status, is_superadmin) VALUES (?, ?, ?, ?, ?, ?, ?)");
        if (!$stmt) {
            throw new Exception("Prepare failed: " . $conn->error);
        }
        $stmt->bind_param('isssisi', $id, $username, $email, $hash, $role_id, $status, $is_superadmin);
        if (!$stmt->execute()) {
            throw new Exception("Insert failed for user $username: " . $stmt->error);
        }
        $stmt->close();
    }
    echo "✓ Inserted users\n";

    // Recreate capabilities table
    $createCapabilitiesSQL = "
    CREATE TABLE `capabilities` (
        `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
        `capability_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE,
        `category` enum('INVENTORY','ADMIN','SYSTEM','USER') COLLATE utf8mb4_unicode_ci NOT NULL,
        `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
        `required_role_id` int(11) DEFAULT NULL,
        `is_active` tinyint(1) DEFAULT '1',
        `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
        KEY idx_capability_key (capability_key),
        KEY idx_category (category),
        KEY idx_required_role (required_role_id),
        FOREIGN KEY (required_role_id) REFERENCES user_roles(id) ON DELETE SET NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    $conn->query($createCapabilitiesSQL);
    echo "✓ Created capabilities table\n";

    // Insert capabilities
    $capabilitiesData = [
        [1, 'view_entries', 'INVENTORY', 'View inventory entries', 2, 1],
        [2, 'create_entries', 'INVENTORY', 'Create new inventory entries', 2, 1],
        [3, 'edit_entries', 'INVENTORY', 'Edit existing inventory entries', 2, 1],
        [4, 'delete_entries', 'INVENTORY', 'Delete inventory entries', 2, 1],
        [5, 'create_employee', 'ADMIN', 'Create new employee account', 2, 1],
        [6, 'edit_employee_caps', 'ADMIN', 'Edit employee capabilities', 2, 1],
        [7, 'view_employees', 'ADMIN', 'View employee list', 2, 1],
        [8, 'create_admin', 'ADMIN', 'Create new admin account', 1, 1],
        [9, 'edit_admin_caps', 'ADMIN', 'Edit admin capabilities', 1, 1],
        [10, 'delete_admin', 'ADMIN', 'Delete admin account', 1, 1],
        [11, 'view_admin_list', 'ADMIN', 'View all admins', 1, 1],
        [12, 'view_audit_logs', 'SYSTEM', 'View all system audit logs', 1, 1],
        [13, 'manage_roles', 'SYSTEM', 'Create or modify roles', 1, 1],
        [14, 'system_settings', 'SYSTEM', 'Access system configuration', 1, 1],
        [15, 'view_own_entries', 'USER', 'View own inventory entries', 3, 1],
        [16, 'view_own_capabilities', 'USER', 'View own assigned capabilities', 3, 1],
        [17, 'view_own_audit_history', 'USER', 'View own action history', 3, 1]
    ];

    foreach ($capabilitiesData as $cap) {
        $stmt = $conn->prepare("INSERT INTO capabilities (id, capability_key, category, description, required_role_id, is_active) VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->bind_param('isssii', ...$cap);
        $stmt->execute();
    }
    echo "✓ Inserted 17 capabilities\n";

    // Recreate user_capabilities
    $createUserCapSQL = "
    CREATE TABLE `user_capabilities` (
        `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
        `user_id` int(11) NOT NULL,
        `capability_id` int(11) NOT NULL,
        `granted_by_id` int(11) DEFAULT NULL,
        `granted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
        `expires_at` timestamp NULL DEFAULT NULL,
        UNIQUE KEY unique_user_cap (user_id, capability_id),
        KEY idx_user_id (user_id),
        KEY idx_capability_id (capability_id),
        KEY idx_granted_by (granted_by_id),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (capability_id) REFERENCES capabilities(id) ON DELETE CASCADE,
        FOREIGN KEY (granted_by_id) REFERENCES users(id) ON DELETE SET NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    $conn->query($createUserCapSQL);
    echo "✓ Created user_capabilities table\n";

    // Insert user capabilities (simplified - give superadmin all, admin most, employee basic)
    $userCaps = [
        // SuperAdmin gets all 17
        [1, 1, NULL], [1, 2, NULL], [1, 3, NULL], [1, 4, NULL], [1, 5, NULL], [1, 6, NULL], [1, 7, NULL],
        [1, 8, NULL], [1, 9, NULL], [1, 10, NULL], [1, 11, NULL], [1, 12, NULL], [1, 13, NULL], [1, 14, NULL],
        [1, 15, NULL], [1, 16, NULL], [1, 17, NULL],
        // Admin gets INVENTORY + some ADMIN
        [2, 1, NULL], [2, 2, NULL], [2, 3, NULL], [2, 4, NULL], [2, 5, NULL], [2, 6, NULL], [2, 7, NULL],
        [2, 15, NULL], [2, 16, NULL], [2, 17, NULL],
        // Employee gets basic
        [3, 15, NULL], [3, 2, NULL], [3, 16, NULL], [3, 17, NULL],
    ];

    foreach ($userCaps as [$uid, $cid, $gid]) {
        $stmt = $conn->prepare("INSERT INTO user_capabilities (user_id, capability_id, granted_by_id) VALUES (?, ?, ?)");
        $stmt->bind_param('iii', $uid, $cid, $gid);
        $stmt->execute();
    }
    echo "✓ Inserted user capabilities\n";

    // Recreate other tables
    $createAdminAccountsSQL = "
    CREATE TABLE `admin_accounts` (
        `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
        `admin_user_id` int(11) NOT NULL UNIQUE,
        `created_by_superadmin_id` int(11) NOT NULL,
        `username` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
        `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
        `permissions` json DEFAULT NULL,
        `is_active` tinyint(1) DEFAULT '1',
        `last_login` timestamp NULL DEFAULT NULL,
        `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
        `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        `notes` text COLLATE utf8mb4_unicode_ci,
        KEY created_by_superadmin_id (created_by_superadmin_id),
        KEY idx_is_active (is_active),
        KEY idx_created_at (created_at),
        FOREIGN KEY (admin_user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (created_by_superadmin_id) REFERENCES users(id) ON DELETE RESTRICT
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    $conn->query($createAdminAccountsSQL);

    $createAuditLogsSQL = "
    CREATE TABLE `audit_logs` (
        `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
        `admin_id` int(11) DEFAULT NULL,
        `action` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
        `action_details` json DEFAULT NULL,
        `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
        `user_agent` text COLLATE utf8mb4_unicode_ci,
        `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
        KEY idx_admin_id (admin_id),
        KEY idx_action (action),
        KEY idx_created_at (created_at),
        FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE SET NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    $conn->query($createAuditLogsSQL);

    $createCapabilityAuditSQL = "
    CREATE TABLE `capability_audit_log` (
        `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
        `actor_id` int(11) NOT NULL,
        `target_id` int(11) NOT NULL,
        `action` enum('GRANT','REVOKE','EXPIRE') COLLATE utf8mb4_unicode_ci NOT NULL,
        `capability_id` int(11) NOT NULL,
        `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
        `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
        `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
        KEY capability_id (capability_id),
        KEY idx_actor_id (actor_id),
        KEY idx_target_id (target_id),
        KEY idx_action (action),
        KEY idx_created_at (created_at),
        FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (target_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (capability_id) REFERENCES capabilities(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    $conn->query($createCapabilityAuditSQL);

    $createRoleAuditLogsSQL = "
    CREATE TABLE `role_audit_logs` (
        `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
        `action` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
        `admin_id` int(11) DEFAULT NULL,
        `target_admin_id` int(11) DEFAULT NULL,
        `details` json DEFAULT NULL,
        `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
        `user_agent` text COLLATE utf8mb4_unicode_ci,
        `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
        KEY idx_admin_id (admin_id),
        KEY idx_target_admin_id (target_admin_id),
        KEY idx_action (action),
        KEY idx_timestamp (timestamp),
        FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE SET NULL,
        FOREIGN KEY (target_admin_id) REFERENCES users(id) ON DELETE SET NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    $conn->query($createRoleAuditLogsSQL);

    $createEntriesSQL = "
    CREATE TABLE `entries` (
        `order_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
        `Quantity` int(11) DEFAULT NULL,
        `Unit` varchar(50) DEFAULT NULL,
        `Amount` decimal(10,2) DEFAULT NULL,
        `UnitCost` decimal(10,2) DEFAULT NULL,
        `TotalCost` decimal(10,2) DEFAULT NULL,
        `Description` varchar(255) DEFAULT NULL,
        `Item` varchar(100) DEFAULT NULL,
        `SerialNo` varchar(100) DEFAULT NULL UNIQUE,
        `DateAcquired` date DEFAULT NULL,
        `Location` varchar(100) DEFAULT NULL,
        `InventoryItemNo` varchar(50) DEFAULT NULL UNIQUE,
        `EstimatedUsefulLife` varchar(50) DEFAULT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
    ";
    $conn->query($createEntriesSQL);

    // Insert entries data
    $entriesData = [
        [1, 10, 'set', 5000.00, 5000.00, 10000.00, 'TESTING', 'Waste Basket', 'S9583SC', '2026-03-23', '10th Floor', 'IIN9432SCG', '5'],
        [2, 10, 'set', 5000.00, 5000.00, 10000.00, 'TESTING', 'Standard, Staper', 'S9684SC', '2026-03-23', '10th Floor', 'IIN9533SCG', '5'],
        [3, 20, 'set', 200.00, 1999.96, 39999.20, '', 'Testing', '2c13123c123', '2026-03-23', '', 'c1c23c12312c', ''],
        [10, 0, '', 10.00, 5000.00, 150.00, '1V234', 'TESTING 100', '24V56N', '2026-03-23', '10th Floor', 'ASV124V24', '5']
    ];

    foreach ($entriesData as $entry) {
        $stmt = $conn->prepare("INSERT INTO entries (order_id, Quantity, Unit, Amount, UnitCost, TotalCost, Description, Item, SerialNo, DateAcquired, Location, InventoryItemNo, EstimatedUsefulLife) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param('sissddssssss', ...$entry);
        $stmt->execute();
    }
    echo "✓ Inserted entries data\n";

    $createOtpSQL = "
    CREATE TABLE `otp_codes` (
        `otp_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL PRIMARY KEY,
        `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
        `otp_code` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL,
        `status` enum('pending','verified','expired','used') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
        `attempts` int(11) DEFAULT '0',
        `max_attempts` int(11) DEFAULT '5',
        `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
        `expires_at` timestamp NULL DEFAULT NULL,
        `verified_at` timestamp NULL DEFAULT NULL,
        `used_at` timestamp NULL DEFAULT NULL,
        KEY idx_email (email),
        KEY idx_status (status),
        KEY idx_expires_at (expires_at),
        FOREIGN KEY (email) REFERENCES users(email) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";
    $conn->query($createOtpSQL);
    echo "✓ Created all supporting tables\n";

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Database restored from backup successfully',
        'tables_restored' => [
            'user_roles',
            'users',
            'capabilities',
            'user_capabilities',
            'admin_accounts',
            'audit_logs',
            'capability_audit_log',
            'role_audit_logs',
            'entries',
            'otp_codes'
        ],
        'sample_credentials' => [
            'superadmin' => 'superadmin@ics.local / SuperAdmin@2026',
            'admin' => 'admin@ics.local / Admin password (from backup)',
            'employee' => 'employee@ics.local / Employee password (from backup)'
        ]
    ]);
    $conn->close();

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>

