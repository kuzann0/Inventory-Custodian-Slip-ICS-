<?php
/**
 * Capability Management System - Database Migration
 * 
 * Creates tables for:
 * - capabilities: Master list of all possible capabilities
 * - user_capabilities: Which user has which capabilities (overrides role defaults)
 * - capability_audit_log: Track all capability changes for audit
 * 
 * Run this via: curl http://localhost:8080/database/setup_capability_system.php
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

    $errors = [];

    // ═════════════════════════════════════════════════════════════
    // 1. Create capabilities table
    // ═════════════════════════════════════════════════════════════
    $createCapabilitiesSQL = "
    CREATE TABLE IF NOT EXISTS `capabilities` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `capability_key` VARCHAR(100) UNIQUE NOT NULL COMMENT 'Identifier: edit_admin_caps',
        `category` ENUM('INVENTORY', 'ADMIN', 'SYSTEM', 'USER') NOT NULL,
        `description` VARCHAR(255),
        `required_role_id` INT COMMENT 'Minimum role_id that can have this: 1=SuperAdmin, 2=Admin, 3=Employee',
        `is_active` BOOLEAN DEFAULT TRUE,
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_capability_key (capability_key),
        INDEX idx_category (category),
        INDEX idx_required_role (required_role_id),
        FOREIGN KEY (required_role_id) REFERENCES user_roles(id) ON DELETE SET NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if (!$conn->query($createCapabilitiesSQL)) {
        $errors[] = 'Failed to create capabilities table: ' . $conn->error;
    } else {
        echo "✓ capabilities table created/verified\n";
    }

    // ═════════════════════════════════════════════════════════════
    // 2. Create user_capabilities table
    // ═════════════════════════════════════════════════════════════
    $createUserCapSQL = "
    CREATE TABLE IF NOT EXISTS `user_capabilities` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `user_id` INT NOT NULL,
        `capability_id` INT NOT NULL,
        `granted_by_id` INT COMMENT 'Which admin granted this, NULL=system',
        `granted_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        `expires_at` TIMESTAMP NULL COMMENT 'NULL = permanent',
        UNIQUE KEY unique_user_cap (user_id, capability_id),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (capability_id) REFERENCES capabilities(id) ON DELETE CASCADE,
        FOREIGN KEY (granted_by_id) REFERENCES users(id) ON DELETE SET NULL,
        INDEX idx_user_id (user_id),
        INDEX idx_capability_id (capability_id),
        INDEX idx_granted_by (granted_by_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if (!$conn->query($createUserCapSQL)) {
        $errors[] = 'Failed to create user_capabilities table: ' . $conn->error;
    } else {
        echo "✓ user_capabilities table created/verified\n";
    }

    // ═════════════════════════════════════════════════════════════
    // 3. Create capability_audit_log table
    // ═════════════════════════════════════════════════════════════
    $createAuditSQL = "
    CREATE TABLE IF NOT EXISTS `capability_audit_log` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `actor_id` INT NOT NULL COMMENT 'Who made the change',
        `target_id` INT NOT NULL COMMENT 'Who was the target',
        `action` ENUM('GRANT', 'REVOKE', 'EXPIRE') NOT NULL,
        `capability_id` INT NOT NULL,
        `reason` VARCHAR(255),
        `ip_address` VARCHAR(45),
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (target_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (capability_id) REFERENCES capabilities(id) ON DELETE CASCADE,
        INDEX idx_actor_id (actor_id),
        INDEX idx_target_id (target_id),
        INDEX idx_action (action),
        INDEX idx_created_at (created_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if (!$conn->query($createAuditSQL)) {
        $errors[] = 'Failed to create capability_audit_log table: ' . $conn->error;
    } else {
        echo "✓ capability_audit_log table created/verified\n";
    }

    // ═════════════════════════════════════════════════════════════
    // 4. Insert capability definitions
    // ═════════════════════════════════════════════════════════════
    
    // Get role IDs
    $roleQuery = "SELECT id, role_name FROM user_roles";
    $roleResult = $conn->query($roleQuery);
    $roles = [];
    while ($row = $roleResult->fetch_assoc()) {
        $roles[$row['role_name']] = $row['id'];
    }

    $capabilities = [
        // INVENTORY capabilities (require Admin level: role_id >= 2)
        ['view_entries', 'INVENTORY', 'View inventory entries', 2],
        ['create_entries', 'INVENTORY', 'Create new inventory entries', 2],
        ['edit_entries', 'INVENTORY', 'Edit existing inventory entries', 2],
        ['delete_entries', 'INVENTORY', 'Delete inventory entries', 2],
        
        // ADMIN capabilities - Manage Employees (require Admin: role_id >= 2)
        ['create_employee', 'ADMIN', 'Create new employee account', 2],
        ['edit_employee_caps', 'ADMIN', 'Edit employee capabilities', 2],
        ['view_employees', 'ADMIN', 'View employee list', 2],
        
        // ADMIN capabilities - Manage Admins (require SuperAdmin: role_id = 1)
        ['create_admin', 'ADMIN', 'Create new admin account', 1],
        ['edit_admin_caps', 'ADMIN', 'Edit admin capabilities', 1],
        ['delete_admin', 'ADMIN', 'Delete admin account', 1],
        ['view_admin_list', 'ADMIN', 'View all admins', 1],
        
        // SYSTEM capabilities (require SuperAdmin: role_id = 1)
        ['view_audit_logs', 'SYSTEM', 'View all system audit logs', 1],
        ['manage_roles', 'SYSTEM', 'Create or modify roles', 1],
        ['system_settings', 'SYSTEM', 'Access system configuration', 1],
        
        // USER capabilities (available to all: role_id >= 3)
        ['view_own_entries', 'USER', 'View own inventory entries', 3],
        ['view_own_capabilities', 'USER', 'View own assigned capabilities', 3],
        ['view_own_audit_history', 'USER', 'View own action history', 3],
    ];

    $capCount = 0;
    foreach ($capabilities as $cap) {
        $checkStmt = $conn->prepare(
            "SELECT id FROM capabilities WHERE capability_key = ?"
        );
        $checkStmt->bind_param('s', $cap[0]);
        $checkStmt->execute();
        
        if ($checkStmt->get_result()->num_rows == 0) {
            $insertStmt = $conn->prepare(
                "INSERT INTO capabilities (capability_key, category, description, required_role_id) 
                 VALUES (?, ?, ?, ?)"
            );
            $insertStmt->bind_param('sssi', $cap[0], $cap[1], $cap[2], $cap[3]);
            
            if ($insertStmt->execute()) {
                $capCount++;
            } else {
                $errors[] = "Failed to insert capability {$cap[0]}: " . $insertStmt->error;
            }
            $insertStmt->close();
        }
        $checkStmt->close();
    }
    echo "✓ Inserted $capCount capabilities\n";

    // ═════════════════════════════════════════════════════════════
    // 5. Grant default capabilities to each role
    // ═════════════════════════════════════════════════════════════

    // SuperAdmin capabilities (gets all)
    $superAdminCaps = [
        'view_entries', 'create_entries', 'edit_entries', 'delete_entries',
        'create_employee', 'edit_employee_caps', 'view_employees',
        'create_admin', 'edit_admin_caps', 'delete_admin', 'view_admin_list',
        'view_audit_logs', 'manage_roles', 'system_settings',
        'view_own_entries', 'view_own_capabilities', 'view_own_audit_history'
    ];

    // Admin capabilities (inventory + employee management only)
    $adminCaps = [
        'view_entries', 'create_entries', 'edit_entries', 'delete_entries',
        'create_employee', 'edit_employee_caps', 'view_employees',
        'view_own_entries', 'view_own_capabilities', 'view_own_audit_history'
    ];

    // Employee capabilities (limited)
    $employeeCaps = [
        'view_own_entries', 'create_entries',
        'view_own_capabilities', 'view_own_audit_history'
    ];

    $roleCapabilities = [
        1 => $superAdminCaps,  // SuperAdmin
        2 => $adminCaps,       // Admin
        3 => $employeeCaps     // Employee
    ];

    // Get current users and grant default capabilities
    $userQuery = "SELECT id, role_id FROM users";
    $userResult = $conn->query($userQuery);

    $grantCount = 0;
    while ($user = $userResult->fetch_assoc()) {
        $userId = $user['id'];
        $roleId = $user['role_id'];
        
        $capsForRole = $roleCapabilities[$roleId] ?? [];

        foreach ($capsForRole as $capKey) {
            // Get capability ID
            $capStmt = $conn->prepare(
                "SELECT id FROM capabilities WHERE capability_key = ?"
            );
            $capStmt->bind_param('s', $capKey);
            $capStmt->execute();
            $capResult = $capStmt->get_result();
            
            if ($capResult->num_rows > 0) {
                $capId = $capResult->fetch_assoc()['id'];
                
                // Check if already granted
                $checkStmt = $conn->prepare(
                    "SELECT id FROM user_capabilities WHERE user_id = ? AND capability_id = ?"
                );
                $checkStmt->bind_param('ii', $userId, $capId);
                $checkStmt->execute();
                
                if ($checkStmt->get_result()->num_rows == 0) {
                    // Grant capability
                    $grantStmt = $conn->prepare(
                        "INSERT INTO user_capabilities (user_id, capability_id, granted_by_id) 
                         VALUES (?, ?, NULL)"
                    );
                    $grantStmt->bind_param('ii', $userId, $capId);
                    
                    if ($grantStmt->execute()) {
                        $grantCount++;
                    }
                    $grantStmt->close();
                }
                $checkStmt->close();
            }
            $capStmt->close();
        }
    }
    echo "✓ Granted $grantCount default capabilities to users\n";

    $conn->close();

    // Return success response
    if (count($errors) > 0) {
        http_response_code(207);  // Multi-Status
        echo json_encode([
            'success' => false,
            'message' => 'Setup completed with warnings',
            'errors' => $errors
        ], JSON_PRETTY_PRINT);
    } else {
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => 'Capability system initialized successfully',
            'tables' => [
                'capabilities',
                'user_capabilities',
                'capability_audit_log'
            ],
            'capabilities_created' => count($capabilities),
            'default_grants' => $grantCount
        ], JSON_PRETTY_PRINT);
    }

} catch (Exception $e) {
    error_log('Setup error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
