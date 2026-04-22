CREATE TABLE IF NOT EXISTS user_roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    role_description TEXT,
    permissions JSON,
    is_active TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE,
    password_hash VARCHAR(255),
    role_id INT NOT NULL,
    account_status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES user_roles(id),
    INDEX (username),
    INDEX (role_id)
);

INSERT IGNORE INTO user_roles VALUES
(1, 'SuperAdmin', 'System Administrator', '["admin", "manage_users", "audit_logs", "capabilities"]', 1, NOW(), NOW()),
(2, 'Admin', 'Administrator', '["manage_users", "view_entries", "audit_logs"]', 1, NOW(), NOW()),
(3, 'User', 'Employee User', '["view_entries", "submit_entries"]', 1, NOW(), NOW());

INSERT IGNORE INTO users VALUES
(1, 'superadmin', 'superadmin@test.com', '$2y$10$8Jv1EeqJ8YI8J7YI8J7YI8J7YI8J7YI8J7YI8J7Y', 1, 'active', NOW(), NOW()),
(2, 'admin', 'admin@test.com', '$2y$10$8Jv1EeqJ8YI8J7YI8J7YI8J7YI8J7YI8J7YI8J7Y', 2, 'active', NOW(), NOW()),
(3, 'yusho', 'yusho@test.com', '$2y$10$lNwhFc5Wt5I.z.3lDc3bJ.WdY3h7YPcUMfDdH3WMj.tRE7bTQhPm2', 3, 'active', NOW(), NOW());
