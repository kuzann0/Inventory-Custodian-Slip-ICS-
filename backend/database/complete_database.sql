-- ============================================================
-- COMPLETE DATABASE SCHEMA FOR V8 ICS SYSTEM
-- Database: my_app_db
-- ============================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;


-- ============================================================
-- TABLE: users
-- ============================================================
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `username` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_id` int(11) NOT NULL DEFAULT '2',
  `account_status` enum('active','inactive','suspended') COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `is_superadmin` tinyint(1) DEFAULT '0' COMMENT 'True if this is THE SuperAdmin',
  `last_login` timestamp NULL DEFAULT NULL,
  `failed_attempts` int(11) DEFAULT '0',
  `locked_until` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `idx_username` (`username`),
  KEY `idx_email` (`email`),
  KEY `idx_role_id` (`role_id`),
  KEY `idx_account_status` (`account_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: capabilities
-- ============================================================
CREATE TABLE IF NOT EXISTS `capabilities` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `capability_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE COMMENT 'Identifier: edit_admin_caps',
  `category` enum('INVENTORY','ADMIN','SYSTEM','USER') COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `required_role_id` int(11) DEFAULT NULL COMMENT 'Minimum role_id that can have this: 1=SuperAdmin, 2=Admin, 3=Employee',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_capability_key` (`capability_key`),
  KEY `idx_category` (`category`),
  KEY `idx_required_role` (`required_role_id`),
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

 
-- ============================================================
-- TABLE: user_roles
-- ============================================================
CREATE TABLE `user_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `role_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE COMMENT 'SuperAdmin or Admin',
  `role_description` text COLLATE utf8mb4_unicode_ci,
  `permissions` json DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: purchase_requests
-- ============================================================
CREATE TABLE IF NOT EXISTS `purchase_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `pr_no` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `office` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `division_section` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `unit` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unit_cost` decimal(10,2) DEFAULT NULL,
  `total_amount` decimal(10,2) DEFAULT NULL,
  `status` enum('draft','pending_approval','approved','rejected','in_delivery','delivered','inspected','completed') COLLATE utf8mb4_unicode_ci DEFAULT 'draft',
  `approval_date` timestamp NULL DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approval_notes` text COLLATE utf8mb4_unicode_ci,
  `rejected_by` int(11) DEFAULT NULL,
  `rejection_reason` text COLLATE utf8mb4_unicode_ci,
  `delivery_notes` text COLLATE utf8mb4_unicode_ci,
  `expected_delivery_date` date DEFAULT NULL,
  `actual_delivery_date` date DEFAULT NULL,
  `inspection_notes` text COLLATE utf8mb4_unicode_ci,
  `inspection_date` timestamp NULL DEFAULT NULL,
  `inspected_by` int(11) DEFAULT NULL,
  `form_type` enum('ics','ppe','none') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `idx_status` (`status`),
  KEY `idx_pr_no` (`pr_no`),
  KEY `idx_office` (`office`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_approved_by` (`approved_by`),
  FOREIGN KEY (`approved_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`rejected_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`inspected_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: admin_accounts
-- ============================================================
CREATE TABLE IF NOT EXISTS `admin_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `admin_user_id` int(11) NOT NULL UNIQUE,
  `created_by_superadmin_id` int(11) NOT NULL,
  `username` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `permissions` json DEFAULT NULL COMMENT 'JSON array of admin permissions',
  `is_active` tinyint(1) DEFAULT '1',
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `notes` text COLLATE utf8mb4_unicode_ci COMMENT 'Notes about this admin account',
  KEY `idx_is_active` (`is_active`),
  KEY `idx_created_at` (`created_at`),
  KEY `created_by_superadmin_id` (`created_by_superadmin_id`),
  FOREIGN KEY (`admin_user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`created_by_superadmin_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: audit_logs
-- ============================================================
CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `admin_id` int(11) DEFAULT NULL,
  `action` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_details` json DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_admin_id` (`admin_id`),
  KEY `idx_action` (`action`),
  KEY `idx_created_at` (`created_at`),
  FOREIGN KEY (`admin_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: role_audit_logs
-- ============================================================
CREATE TABLE IF NOT EXISTS `role_audit_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `action` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'create, update, delete',
  `admin_id` int(11) DEFAULT NULL,
  `target_admin_id` int(11) DEFAULT NULL,
  `details` json DEFAULT NULL COMMENT 'Additional details about the action',
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_admin_id` (`admin_id`),
  KEY `idx_target_admin_id` (`target_admin_id`),
  KEY `idx_action` (`action`),
  KEY `idx_timestamp` (`timestamp`),
  FOREIGN KEY (`admin_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`target_admin_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- ============================================================
-- TABLE: user_capabilities
-- ============================================================
CREATE TABLE IF NOT EXISTS `user_capabilities` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` int(11) NOT NULL,
  `capability_id` int(11) NOT NULL,
  `granted_by_id` int(11) DEFAULT NULL COMMENT 'Which admin granted this, NULL=system',
  `granted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NULL DEFAULT NULL COMMENT 'NULL = permanent',
  UNIQUE KEY `unique_user_cap` (`user_id`,`capability_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_capability_id` (`capability_id`),
  KEY `idx_granted_by` (`granted_by_id`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`capability_id`) REFERENCES `capabilities`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`granted_by_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: capability_audit_log
-- ============================================================
CREATE TABLE IF NOT EXISTS `capability_audit_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `actor_id` int(11) NOT NULL COMMENT 'Who made the change',
  `target_id` int(11) NOT NULL COMMENT 'Who was the target',
  `action` enum('GRANT','REVOKE','EXPIRE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `capability_id` int(11) NOT NULL,
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `capability_id` (`capability_id`),
  KEY `idx_actor_id` (`actor_id`),
  KEY `idx_target_id` (`target_id`),
  KEY `idx_action` (`action`),
  KEY `idx_created_at` (`created_at`),
  FOREIGN KEY (`actor_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`target_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`capability_id`) REFERENCES `capabilities`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `approval_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pr_id` int(11) NOT NULL,
  `approval_level` int(11) DEFAULT NULL,
  `required_role_id` int(11) DEFAULT NULL,
  `assigned_to` int(11) DEFAULT NULL,
  `is_required` tinyint(1) DEFAULT '1',
  `status` enum('pending','approved','rejected','expired') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `approved_by` int(11) DEFAULT NULL,
  `approval_date` timestamp NULL DEFAULT NULL,
  `rejection_reason` text COLLATE utf8mb4_unicode_ci,
  `due_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pr_id` (`pr_id`),
  KEY `idx_status` (`status`),
  KEY `idx_assigned_to` (`assigned_to`),
  KEY `required_role_id` (`required_role_id`),
  KEY `approved_by` (`approved_by`),
  CONSTRAINT `approval_queue_ibfk_1` FOREIGN KEY (`pr_id`) REFERENCES `purchase_requests` (`id`) ON DELETE CASCADE,
  CONSTRAINT `approval_queue_ibfk_2` FOREIGN KEY (`required_role_id`) REFERENCES `user_roles` (`id`) ON DELETE SET NULL,
  CONSTRAINT `approval_queue_ibfk_3` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `approval_queue_ibfk_4` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;






-- ============================================================
-- TABLE: otp_codes
-- ============================================================
CREATE TABLE IF NOT EXISTS `otp_codes` (
  `otp_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL PRIMARY KEY,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'User email address',
  `otp_code` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '6-digit OTP code',
  `status` enum('pending','verified','expired','used') COLLATE utf8mb4_unicode_ci DEFAULT 'pending' COMMENT 'OTP status',
  `attempts` int(11) DEFAULT '0' COMMENT 'Number of verification attempts',
  `max_attempts` int(11) DEFAULT '5' COMMENT 'Maximum allowed attempts',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'When OTP was created',
  `expires_at` timestamp NULL DEFAULT NULL COMMENT 'When OTP expires (5 minutes default)',
  `verified_at` timestamp NULL DEFAULT NULL COMMENT 'When OTP was verified',
  `used_at` timestamp NULL DEFAULT NULL COMMENT 'When OTP was used',
  KEY `idx_email` (`email`),
  KEY `idx_status` (`status`),
  KEY `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- ============================================================
-- TABLE: otp_settings
-- ============================================================
CREATE TABLE IF NOT EXISTS `otp_settings` (
  `id` int(11) NOT NULL PRIMARY KEY DEFAULT 1,
  `enabled` tinyint(1) DEFAULT '1',
  `expiry_minutes` int(11) DEFAULT '5',
  `max_attempts` int(11) DEFAULT '5',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: offline_emails
-- ============================================================
CREATE TABLE IF NOT EXISTS `offline_emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `recipient_email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` longtext COLLATE utf8mb4_unicode_ci,
  `status` enum('pending','sent','failed') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `attempts` int(11) DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sent_at` timestamp NULL DEFAULT NULL,
  KEY `idx_status` (`status`),
  KEY `idx_recipient` (`recipient_email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;








-- ============================================================
-- TABLE: approval_queue
-- ============================================================
CREATE TABLE IF NOT EXISTS `approval_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `pr_id` int(11) NOT NULL,
  `approval_level` int(11) DEFAULT NULL,
  `required_role_id` int(11) DEFAULT NULL,
  `assigned_to` int(11) DEFAULT NULL,
  `is_required` tinyint(1) DEFAULT '1',
  `status` enum('pending','approved','rejected','expired') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `approved_by` int(11) DEFAULT NULL,
  `approval_date` timestamp NULL DEFAULT NULL,
  `rejection_reason` text COLLATE utf8mb4_unicode_ci,
  `due_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `idx_pr_id` (`pr_id`),
  KEY `idx_status` (`status`),
  KEY `idx_assigned_to` (`assigned_to`),
  FOREIGN KEY (`pr_id`) REFERENCES `purchase_requests`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`required_role_id`) REFERENCES `user_roles`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`assigned_to`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`approved_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: workflow_history
-- ============================================================
CREATE TABLE IF NOT EXISTS `workflow_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `pr_id` int(11) NOT NULL,
  `status_from` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status_to` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_by` int(11) DEFAULT NULL,
  `action_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_pr_id` (`pr_id`),
  KEY `idx_status_to` (`status_to`),
  KEY `idx_action_date` (`action_date`),
  FOREIGN KEY (`pr_id`) REFERENCES `purchase_requests`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`action_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: documents
-- ============================================================
CREATE TABLE IF NOT EXISTS `documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `pr_id` int(11) NOT NULL,
  `pr_no` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `document_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `filename` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_size` int(11) DEFAULT NULL,
  `uploaded_by` int(11) DEFAULT NULL,
  `upload_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `verified` tinyint(1) DEFAULT '0',
  `verified_by` int(11) DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  KEY `idx_pr_id` (`pr_id`),
  KEY `idx_document_type` (`document_type`),
  KEY `idx_upload_date` (`upload_date`),
  FOREIGN KEY (`pr_id`) REFERENCES `purchase_requests`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`uploaded_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`verified_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- ============================================================
-- TABLE: inspection_assignments
-- ============================================================
CREATE TABLE IF NOT EXISTS `inspection_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `pr_id` int(11) NOT NULL,
  `assigned_to` int(11) NOT NULL,
  `status` enum('pending','in_progress','completed','rejected') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `inspection_notes` text COLLATE utf8mb4_unicode_ci,
  `condition_report` text COLLATE utf8mb4_unicode_ci,
  `findings` json DEFAULT NULL,
  `assigned_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `due_date` date DEFAULT NULL,
  `completed_date` timestamp NULL DEFAULT NULL,
  `attachment_count` int(11) DEFAULT '0',
  KEY `idx_pr_id` (`pr_id`),
  KEY `idx_assigned_to` (`assigned_to`),
  KEY `idx_status` (`status`),
  FOREIGN KEY (`pr_id`) REFERENCES `purchase_requests`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`assigned_to`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: entries
-- ============================================================
CREATE TABLE IF NOT EXISTS `entries` (
  `order_id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `Quantity` int(11) DEFAULT NULL,
  `Unit` varchar(50) DEFAULT NULL,
  `Amount` decimal(10,2) DEFAULT NULL,
  `UnitCost` decimal(10,2) DEFAULT NULL,
  `TotalCost` decimal(10,2) DEFAULT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `Item` varchar(100) DEFAULT NULL,
  `SerialNo` varchar(100) DEFAULT NULL,
  `DateAcquired` date DEFAULT NULL,
  `Location` varchar(100) DEFAULT NULL,
  `InventoryItemNo` varchar(50) DEFAULT NULL,
  `EstimatedUsefulLife` varchar(50) DEFAULT NULL,
  UNIQUE KEY `unique_serial` (`SerialNo`),
  UNIQUE KEY `unique_inventory` (`InventoryItemNo`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ============================================================
-- TABLE: property_inventory
-- ============================================================
CREATE TABLE IF NOT EXISTS `property_inventory` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `pr_id` int(11) DEFAULT NULL,
  `pr_no` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `property_number` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL UNIQUE,
  `model_number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `serial_number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unit_of_measure` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `acquisition_date` date DEFAULT NULL,
  `supplier` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estimated_cost` decimal(10,2) DEFAULT NULL,
  `location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('serviceable','under_repair','obsolete','for_disposal') COLLATE utf8mb4_unicode_ci DEFAULT 'serviceable',
  `deprecated_value` decimal(10,2) DEFAULT NULL,
  `depreciation_percentage` decimal(5,2) DEFAULT NULL,
  `last_maintenance_date` date DEFAULT NULL,
  `assigned_to` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `idx_property_number` (`property_number`),
  KEY `idx_pr_no` (`pr_no`),
  KEY `idx_status` (`status`),
  KEY `idx_location` (`location`),
  FOREIGN KEY (`pr_id`) REFERENCES `purchase_requests`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`assigned_to`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: login_audit
-- ============================================================
CREATE TABLE IF NOT EXISTS `login_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `login_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `mode` enum('online','offline') COLLATE utf8mb4_unicode_ci DEFAULT 'online',
  `success` tinyint(1) DEFAULT '0',
  KEY `idx_username` (`username`),
  KEY `idx_login_time` (`login_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLE: admin_bypass_log
-- ============================================================
CREATE TABLE IF NOT EXISTS `admin_bypass_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `admin_id` int(11) DEFAULT NULL,
  `bypassed_user_email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bypass_key` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_admin_id` (`admin_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- ============================================================
-- INSERT DEFAULT ROLES
-- ============================================================
INSERT IGNORE INTO `user_roles` (`id`, `role_name`, `role_description`, `permissions`, `is_active`) VALUES
(1, 'SuperAdmin', 'Super Administrator - Full system access including admin creation', '[\"create_admins\", \"edit_admins\", \"delete_admins\", \"view_all_users\", \"system_settings\", \"view_audit_logs\", \"manage_roles\"]', 1),
(2, 'Admin', 'Administrator - Can manage inventory and entries', '[\"view_entries\", \"create_entries\", \"edit_entries\", \"delete_entries\", \"view_users\", \"change_inventory\"]', 1),
(3, 'Employee', 'Employee - Can view and create inventory entries', '[\"view_entries\", \"create_entries\", \"edit_own_entries\"]', 1);

-- ============================================================
-- INSERT DEFAULT CAPABILITIES
-- ============================================================
INSERT IGNORE INTO `capabilities` (`id`, `capability_key`, `category`, `description`, `required_role_id`, `is_active`) VALUES
(1, 'view_entries', 'INVENTORY', 'View inventory entries', 2, 1),
(2, 'create_entries', 'INVENTORY', 'Create new inventory entries', 2, 1),
(3, 'edit_entries', 'INVENTORY', 'Edit existing inventory entries', 2, 1),
(4, 'delete_entries', 'INVENTORY', 'Delete inventory entries', 2, 1),
(5, 'create_employee', 'ADMIN', 'Create new employee account', 2, 1),
(6, 'edit_employee_caps', 'ADMIN', 'Edit employee capabilities', 2, 1),
(7, 'view_employees', 'ADMIN', 'View employee list', 2, 1),
(8, 'create_admin', 'ADMIN', 'Create new admin account', 1, 1),
(9, 'edit_admin_caps', 'ADMIN', 'Edit admin capabilities', 1, 1),
(10, 'delete_admin', 'ADMIN', 'Delete admin account', 1, 1),
(11, 'view_admin_list', 'ADMIN', 'View all admins', 1, 1),
(12, 'view_audit_logs', 'SYSTEM', 'View all system audit logs', 1, 1),
(13, 'manage_roles', 'SYSTEM', 'Create or modify roles', 1, 1),
(14, 'system_settings', 'SYSTEM', 'Access system configuration', 1, 1),
(15, 'view_own_entries', 'USER', 'View own inventory entries', 3, 1),
(16, 'view_own_capabilities', 'USER', 'View own assigned capabilities', 3, 1),
(17, 'view_own_audit_history', 'USER', 'View own action history', 3, 1);

-- ============================================================
-- INSERT DEFAULT SUPERADMIN USER
-- ============================================================
INSERT IGNORE INTO `users` (`id`, `username`, `email`, `password_hash`, `role_id`, `is_superadmin`, `account_status`) VALUES
(1, 'superadmin', 'superadmin@ics.local', '$2y$10$JuzdwISa4W1yBM9gkP2fTe0lACKEm/q4YI.dAE.3v8uMYphygFw4S', 1, 1, 'active');

-- ============================================================
-- GRANT ALL CAPABILITIES TO SUPERADMIN
-- ============================================================
INSERT IGNORE INTO `user_capabilities` (`user_id`, `capability_id`, `granted_by_id`) VALUES
(1, 1, NULL),
(1, 2, NULL),
(1, 3, NULL),
(1, 4, NULL),
(1, 5, NULL),
(1, 6, NULL),
(1, 7, NULL),
(1, 8, NULL),
(1, 9, NULL),
(1, 10, NULL),
(1, 11, NULL),
(1, 12, NULL),
(1, 13, NULL),
(1, 14, NULL),
(1, 15, NULL),
(1, 16, NULL),
(1, 17, NULL);

-- ============================================================
-- INSERT DEFAULT OTP SETTINGS
-- ============================================================
INSERT IGNORE INTO `otp_settings` (`id`, `enabled`, `expiry_minutes`, `max_attempts`) VALUES
(1, 1, 5, 5);

-- ============================================================
-- COMMIT TRANSACTION
-- ============================================================
COMMIT;

