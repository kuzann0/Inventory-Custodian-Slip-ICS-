-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: db
-- Generation Time: Mar 29, 2026 at 07:15 PM
-- Server version: 5.7.44
-- PHP Version: 8.3.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `my_app_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin_accounts`
--

CREATE TABLE `admin_accounts` (
  `id` int(11) NOT NULL,
  `admin_user_id` int(11) NOT NULL,
  `created_by_superadmin_id` int(11) NOT NULL,
  `username` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `permissions` json DEFAULT NULL COMMENT 'JSON array of admin permissions',
  `is_active` tinyint(1) DEFAULT '1',
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `notes` text COLLATE utf8mb4_unicode_ci COMMENT 'Notes about this admin account'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` int(11) NOT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `action` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_details` json DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `capabilities`
--

CREATE TABLE `capabilities` (
  `id` int(11) NOT NULL,
  `capability_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Identifier: edit_admin_caps',
  `category` enum('INVENTORY','ADMIN','SYSTEM','USER') COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `required_role_id` int(11) DEFAULT NULL COMMENT 'Minimum role_id that can have this: 1=SuperAdmin, 2=Admin, 3=Employee',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `capabilities`
--

INSERT INTO `capabilities` (`id`, `capability_key`, `category`, `description`, `required_role_id`, `is_active`, `created_at`) VALUES
(1, 'view_entries', 'INVENTORY', 'View inventory entries', 2, 1, '2026-03-28 10:27:11'),
(2, 'create_entries', 'INVENTORY', 'Create new inventory entries', 2, 1, '2026-03-28 10:27:11'),
(3, 'edit_entries', 'INVENTORY', 'Edit existing inventory entries', 2, 1, '2026-03-28 10:27:11'),
(4, 'delete_entries', 'INVENTORY', 'Delete inventory entries', 2, 1, '2026-03-28 10:27:11'),
(5, 'create_employee', 'ADMIN', 'Create new employee account', 2, 1, '2026-03-28 10:27:11'),
(6, 'edit_employee_caps', 'ADMIN', 'Edit employee capabilities', 2, 1, '2026-03-28 10:27:11'),
(7, 'view_employees', 'ADMIN', 'View employee list', 2, 1, '2026-03-28 10:27:11'),
(8, 'create_admin', 'ADMIN', 'Create new admin account', 1, 1, '2026-03-28 10:27:11'),
(9, 'edit_admin_caps', 'ADMIN', 'Edit admin capabilities', 1, 1, '2026-03-28 10:27:11'),
(10, 'delete_admin', 'ADMIN', 'Delete admin account', 1, 1, '2026-03-28 10:27:11'),
(11, 'view_admin_list', 'ADMIN', 'View all admins', 1, 1, '2026-03-28 10:27:11'),
(12, 'view_audit_logs', 'SYSTEM', 'View all system audit logs', 1, 1, '2026-03-28 10:27:11'),
(13, 'manage_roles', 'SYSTEM', 'Create or modify roles', 1, 1, '2026-03-28 10:27:11'),
(14, 'system_settings', 'SYSTEM', 'Access system configuration', 1, 1, '2026-03-28 10:27:11'),
(15, 'view_own_entries', 'USER', 'View own inventory entries', 3, 1, '2026-03-28 10:27:11'),
(16, 'view_own_capabilities', 'USER', 'View own assigned capabilities', 3, 1, '2026-03-28 10:27:11'),
(17, 'view_own_audit_history', 'USER', 'View own action history', 3, 1, '2026-03-28 10:27:11');

-- --------------------------------------------------------

--
-- Table structure for table `capability_audit_log`
--

CREATE TABLE `capability_audit_log` (
  `id` int(11) NOT NULL,
  `actor_id` int(11) NOT NULL COMMENT 'Who made the change',
  `target_id` int(11) NOT NULL COMMENT 'Who was the target',
  `action` enum('GRANT','REVOKE','EXPIRE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `capability_id` int(11) NOT NULL,
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `entries`
--

CREATE TABLE `entries` (
  `order_id` int(11) NOT NULL,
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
  `EstimatedUsefulLife` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `entries`
--

INSERT INTO `entries` (`order_id`, `Quantity`, `Unit`, `Amount`, `UnitCost`, `TotalCost`, `Description`, `Item`, `SerialNo`, `DateAcquired`, `Location`, `InventoryItemNo`, `EstimatedUsefulLife`) VALUES
(1, 10, 'set', 5000.00, 5000.00, 10000.00, 'TESTING', 'Waste Basket', 'S9583SC', '2026-03-23', '10th Floor', 'IIN9432SCG', '5'),
(2, 10, 'set', 5000.00, 5000.00, 10000.00, 'TESTING', 'Standard, Staper', 'S9684SC', '2026-03-23', '10th Floor', 'IIN9533SCG', '5'),
(3, 20, 'set', 200.00, 1999.96, 39999.20, '', 'Testing', '2c13123c123', '2026-03-23', '', 'c1c23c12312c', ''),
(10, 0, '', 10.00, 5000.00, 150.00, '1V234', 'TESTING 100', '24V56N', '2026-03-23', '10th Floor', 'ASV124V24', '5');

-- --------------------------------------------------------

--
-- Table structure for table `otp_codes`
--

CREATE TABLE `otp_codes` (
  `otp_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Unique OTP session ID',
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'User email address',
  `otp_code` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '6-digit OTP code',
  `status` enum('pending','verified','expired','used') COLLATE utf8mb4_unicode_ci DEFAULT 'pending' COMMENT 'OTP status',
  `attempts` int(11) DEFAULT '0' COMMENT 'Number of verification attempts',
  `max_attempts` int(11) DEFAULT '5' COMMENT 'Maximum allowed attempts',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'When OTP was created',
  `expires_at` timestamp NULL DEFAULT NULL COMMENT 'When OTP expires (5 minutes default)',
  `verified_at` timestamp NULL DEFAULT NULL COMMENT 'When OTP was verified',
  `used_at` timestamp NULL DEFAULT NULL COMMENT 'When OTP was used'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `role_audit_logs`
--

CREATE TABLE `role_audit_logs` (
  `id` int(11) NOT NULL,
  `action` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'create, update, delete',
  `admin_id` int(11) DEFAULT NULL,
  `target_admin_id` int(11) DEFAULT NULL,
  `details` json DEFAULT NULL COMMENT 'Additional details about the action',
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_id` int(11) NOT NULL DEFAULT '2',
  `account_status` enum('active','inactive','suspended') COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `is_superadmin` tinyint(1) DEFAULT '0' COMMENT 'True if this is THE SuperAdmin',
  `last_login` timestamp NULL DEFAULT NULL,
  `failed_attempts` int(11) DEFAULT '0',
  `locked_until` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password_hash`, `role_id`, `account_status`, `is_superadmin`, `last_login`, `failed_attempts`, `locked_until`, `created_at`, `updated_at`) VALUES
(1, 'superadmin', 'superadmin@ics.local', '$2y$10$JuzdwISa4W1yBM9gkP2fTe0lACKEm/q4YI.dAE.3v8uMYphygFw4S', 1, 'active', 1, NULL, 0, NULL, '2026-03-28 04:31:54', '2026-03-28 04:31:54'),
(2, 'admin', 'admin@ics.local', '$2y$10$wPpm2WkaQ92iJ28lf6c2nuTXWUd3BN3KgxPa2kACwhqE0GvzOnE1O', 2, 'active', 0, NULL, 0, NULL, '2026-03-28 10:23:12', '2026-03-28 10:23:12'),
(3, 'employee', 'employee@ics.local', '$2y$10$nDQ67/3wPXYkeiEs1J7e9uODqJEfMnZKQZY20BnNV1J.Rl/FKjBli', 3, 'active', 0, NULL, 0, NULL, '2026-03-28 10:23:12', '2026-03-28 10:23:12'),
(4, 'testemployee', 'testemployee@test.com', '$2y$10$WasdJWDGmdxcmPQnloSAbOVLf.Cni6cqwq9F7.b1VmSLx095fWtoK', 3, 'active', 0, NULL, 0, NULL, '2026-03-28 11:05:03', '2026-03-28 11:05:03'),
(6, 'testuser', 'test@example.com', '$2y$10$dIWqGw0MdtN5104LVx8rD.wwm95yd7S2oPl9p3oLNmRlIzw7kPo2i', 3, 'active', 0, NULL, 0, NULL, '2026-03-28 11:16:22', '2026-03-28 11:16:22'),
(7, 'kuzano', 'kuzano.1001@gmail.com', '$2y$10$ASZqbZczrJGeBe9S8zoHYO0BqISIi.fxzM.s34yIfeow3H0HSFe1u', 3, 'active', 0, NULL, 0, NULL, '2026-03-28 13:04:40', '2026-03-28 13:04:40');

-- --------------------------------------------------------

--
-- Table structure for table `user_capabilities`
--

CREATE TABLE `user_capabilities` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `capability_id` int(11) NOT NULL,
  `granted_by_id` int(11) DEFAULT NULL COMMENT 'Which admin granted this, NULL=system',
  `granted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NULL DEFAULT NULL COMMENT 'NULL = permanent'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_capabilities`
--

INSERT INTO `user_capabilities` (`id`, `user_id`, `capability_id`, `granted_by_id`, `granted_at`, `expires_at`) VALUES
(1, 1, 1, NULL, '2026-03-28 10:27:11', NULL),
(2, 1, 2, NULL, '2026-03-28 10:27:11', NULL),
(3, 1, 3, NULL, '2026-03-28 10:27:11', NULL),
(4, 1, 4, NULL, '2026-03-28 10:27:11', NULL),
(5, 1, 5, NULL, '2026-03-28 10:27:11', NULL),
(6, 1, 6, NULL, '2026-03-28 10:27:11', NULL),
(7, 1, 7, NULL, '2026-03-28 10:27:11', NULL),
(8, 1, 8, NULL, '2026-03-28 10:27:11', NULL),
(9, 1, 9, NULL, '2026-03-28 10:27:11', NULL),
(10, 1, 10, NULL, '2026-03-28 10:27:11', NULL),
(11, 1, 11, NULL, '2026-03-28 10:27:11', NULL),
(12, 1, 12, NULL, '2026-03-28 10:27:11', NULL),
(13, 1, 13, NULL, '2026-03-28 10:27:11', NULL),
(14, 1, 14, NULL, '2026-03-28 10:27:11', NULL),
(15, 1, 15, NULL, '2026-03-28 10:27:11', NULL),
(16, 1, 16, NULL, '2026-03-28 10:27:11', NULL),
(17, 1, 17, NULL, '2026-03-28 10:27:11', NULL),
(18, 2, 1, NULL, '2026-03-28 10:27:11', NULL),
(19, 2, 2, NULL, '2026-03-28 10:27:11', NULL),
(20, 2, 3, NULL, '2026-03-28 10:27:11', NULL),
(21, 2, 4, NULL, '2026-03-28 10:27:11', NULL),
(22, 2, 5, NULL, '2026-03-28 10:27:11', NULL),
(23, 2, 6, NULL, '2026-03-28 10:27:11', NULL),
(24, 2, 7, NULL, '2026-03-28 10:27:11', NULL),
(25, 2, 15, NULL, '2026-03-28 10:27:11', NULL),
(26, 2, 16, NULL, '2026-03-28 10:27:11', NULL),
(27, 2, 17, NULL, '2026-03-28 10:27:11', NULL),
(28, 3, 15, NULL, '2026-03-28 10:27:11', NULL),
(29, 3, 2, NULL, '2026-03-28 10:27:11', NULL),
(30, 3, 16, NULL, '2026-03-28 10:27:11', NULL),
(31, 3, 17, NULL, '2026-03-28 10:27:11', NULL),
(32, 4, 15, NULL, '2026-03-28 11:15:02', NULL),
(33, 4, 2, NULL, '2026-03-28 11:15:02', NULL),
(34, 4, 16, NULL, '2026-03-28 11:15:02', NULL),
(35, 4, 17, NULL, '2026-03-28 11:15:02', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_roles`
--

CREATE TABLE `user_roles` (
  `id` int(11) NOT NULL,
  `role_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'SuperAdmin or Admin',
  `role_description` text COLLATE utf8mb4_unicode_ci,
  `permissions` json DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_roles`
--

INSERT INTO `user_roles` (`id`, `role_name`, `role_description`, `permissions`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'SuperAdmin', 'Super Administrator - Full system access including admin creation', '[\"create_admins\", \"edit_admins\", \"delete_admins\", \"view_all_users\", \"system_settings\", \"view_audit_logs\", \"manage_roles\"]', 1, '2026-03-28 04:31:54', '2026-03-28 04:31:54'),
(2, 'Admin', 'Administrator - Can manage inventory and entries', '[\"view_entries\", \"create_entries\", \"edit_entries\", \"delete_entries\", \"view_users\", \"change_inventory\"]', 1, '2026-03-28 04:31:54', '2026-03-28 04:31:54'),
(3, 'Employee', 'Employee - Can view and create inventory entries', '[\"view_entries\", \"create_entries\", \"edit_own_entries\"]', 1, '2026-03-28 10:21:13', '2026-03-28 10:21:13');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin_accounts`
--
ALTER TABLE `admin_accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `admin_user_id` (`admin_user_id`),
  ADD KEY `created_by_superadmin_id` (`created_by_superadmin_id`),
  ADD KEY `idx_is_active` (`is_active`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_admin_id` (`admin_id`),
  ADD KEY `idx_action` (`action`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `capabilities`
--
ALTER TABLE `capabilities`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `capability_key` (`capability_key`),
  ADD KEY `idx_capability_key` (`capability_key`),
  ADD KEY `idx_category` (`category`),
  ADD KEY `idx_required_role` (`required_role_id`);

--
-- Indexes for table `capability_audit_log`
--
ALTER TABLE `capability_audit_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `capability_id` (`capability_id`),
  ADD KEY `idx_actor_id` (`actor_id`),
  ADD KEY `idx_target_id` (`target_id`),
  ADD KEY `idx_action` (`action`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `entries`
--
ALTER TABLE `entries`
  ADD PRIMARY KEY (`order_id`),
  ADD UNIQUE KEY `unique_serial` (`SerialNo`),
  ADD UNIQUE KEY `unique_inventory` (`InventoryItemNo`);

--
-- Indexes for table `otp_codes`
--
ALTER TABLE `otp_codes`
  ADD PRIMARY KEY (`otp_id`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_expires_at` (`expires_at`);

--
-- Indexes for table `role_audit_logs`
--
ALTER TABLE `role_audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_admin_id` (`admin_id`),
  ADD KEY `idx_target_admin_id` (`target_admin_id`),
  ADD KEY `idx_action` (`action`),
  ADD KEY `idx_timestamp` (`timestamp`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_username` (`username`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_role_id` (`role_id`),
  ADD KEY `idx_account_status` (`account_status`);

--
-- Indexes for table `user_capabilities`
--
ALTER TABLE `user_capabilities`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_cap` (`user_id`,`capability_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_capability_id` (`capability_id`),
  ADD KEY `idx_granted_by` (`granted_by_id`);

--
-- Indexes for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `role_name` (`role_name`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin_accounts`
--
ALTER TABLE `admin_accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `capabilities`
--
ALTER TABLE `capabilities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `capability_audit_log`
--
ALTER TABLE `capability_audit_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `entries`
--
ALTER TABLE `entries`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `role_audit_logs`
--
ALTER TABLE `role_audit_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `user_capabilities`
--
ALTER TABLE `user_capabilities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT for table `user_roles`
--
ALTER TABLE `user_roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admin_accounts`
--
ALTER TABLE `admin_accounts`
  ADD CONSTRAINT `admin_accounts_ibfk_1` FOREIGN KEY (`admin_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `admin_accounts_ibfk_2` FOREIGN KEY (`created_by_superadmin_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `capabilities`
--
ALTER TABLE `capabilities`
  ADD CONSTRAINT `capabilities_ibfk_1` FOREIGN KEY (`required_role_id`) REFERENCES `user_roles` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `capability_audit_log`
--
ALTER TABLE `capability_audit_log`
  ADD CONSTRAINT `capability_audit_log_ibfk_1` FOREIGN KEY (`actor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `capability_audit_log_ibfk_2` FOREIGN KEY (`target_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `capability_audit_log_ibfk_3` FOREIGN KEY (`capability_id`) REFERENCES `capabilities` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `otp_codes`
--
ALTER TABLE `otp_codes`
  ADD CONSTRAINT `otp_codes_ibfk_1` FOREIGN KEY (`email`) REFERENCES `users` (`email`) ON DELETE CASCADE;

--
-- Constraints for table `role_audit_logs`
--
ALTER TABLE `role_audit_logs`
  ADD CONSTRAINT `role_audit_logs_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `role_audit_logs_ibfk_2` FOREIGN KEY (`target_admin_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `user_roles` (`id`);

--
-- Constraints for table `user_capabilities`
--
ALTER TABLE `user_capabilities`
  ADD CONSTRAINT `user_capabilities_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_capabilities_ibfk_2` FOREIGN KEY (`capability_id`) REFERENCES `capabilities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_capabilities_ibfk_3` FOREIGN KEY (`granted_by_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
