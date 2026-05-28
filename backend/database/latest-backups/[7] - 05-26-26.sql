-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: db
-- Generation Time: May 26, 2026 at 06:14 AM
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
-- Table structure for table `admin_bypass_log`
--

CREATE TABLE `admin_bypass_log` (
  `id` int(11) NOT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `bypassed_user_email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bypass_key` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `approval_queue`
--

CREATE TABLE `approval_queue` (
  `id` int(11) NOT NULL,
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
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
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
(1, 'view_entries', 'INVENTORY', 'View inventory entries', 2, 1, '2026-04-22 00:32:32'),
(2, 'create_entries', 'INVENTORY', 'Create new inventory entries', 2, 1, '2026-04-22 00:32:32'),
(3, 'edit_entries', 'INVENTORY', 'Edit existing inventory entries', 2, 1, '2026-04-22 00:32:32'),
(4, 'delete_entries', 'INVENTORY', 'Delete inventory entries', 2, 1, '2026-04-22 00:32:32'),
(5, 'create_employee', 'ADMIN', 'Create new employee account', 2, 1, '2026-04-22 00:32:32'),
(6, 'edit_employee_caps', 'ADMIN', 'Edit employee capabilities', 2, 1, '2026-04-22 00:32:32'),
(7, 'view_employees', 'ADMIN', 'View employee list', 2, 1, '2026-04-22 00:32:32'),
(8, 'create_admin', 'ADMIN', 'Create new admin account', 1, 1, '2026-04-22 00:32:32'),
(9, 'edit_admin_caps', 'ADMIN', 'Edit admin capabilities', 1, 1, '2026-04-22 00:32:32'),
(10, 'delete_admin', 'ADMIN', 'Delete admin account', 1, 1, '2026-04-22 00:32:32'),
(11, 'view_admin_list', 'ADMIN', 'View all admins', 1, 1, '2026-04-22 00:32:32'),
(12, 'view_audit_logs', 'SYSTEM', 'View all system audit logs', 1, 1, '2026-04-22 00:32:32'),
(13, 'manage_roles', 'SYSTEM', 'Create or modify roles', 1, 1, '2026-04-22 00:32:32'),
(14, 'system_settings', 'SYSTEM', 'Access system configuration', 1, 1, '2026-04-22 00:32:32'),
(15, 'view_own_entries', 'USER', 'View own inventory entries', 3, 1, '2026-04-22 00:32:32'),
(16, 'view_own_capabilities', 'USER', 'View own assigned capabilities', 3, 1, '2026-04-22 00:32:32'),
(17, 'view_own_audit_history', 'USER', 'View own action history', 3, 1, '2026-04-22 00:32:32');

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

--
-- Dumping data for table `capability_audit_log`
--

INSERT INTO `capability_audit_log` (`id`, `actor_id`, `target_id`, `action`, `capability_id`, `reason`, `ip_address`, `created_at`) VALUES
(1, 1, 2, 'GRANT', 2, NULL, '172.20.0.1', '2026-04-22 00:33:45'),
(2, 1, 2, 'GRANT', 4, NULL, '172.20.0.1', '2026-04-22 00:33:46'),
(3, 1, 2, 'GRANT', 3, NULL, '172.20.0.1', '2026-04-22 00:33:47'),
(4, 1, 2, 'GRANT', 1, NULL, '172.20.0.1', '2026-04-22 00:33:49'),
(5, 1, 2, 'GRANT', 5, NULL, '172.20.0.1', '2026-04-22 00:33:50'),
(6, 1, 2, 'GRANT', 6, NULL, '172.20.0.1', '2026-04-22 00:33:51'),
(7, 1, 2, 'GRANT', 17, NULL, '172.20.0.1', '2026-04-22 00:33:52'),
(8, 1, 2, 'GRANT', 7, NULL, '172.20.0.1', '2026-04-22 00:33:54'),
(9, 1, 2, 'GRANT', 16, NULL, '172.20.0.1', '2026-04-22 00:33:55'),
(10, 1, 2, 'GRANT', 15, NULL, '172.20.0.1', '2026-04-22 00:33:57'),
(11, 1, 3, 'GRANT', 17, NULL, '172.20.0.1', '2026-04-22 01:04:16'),
(12, 1, 3, 'GRANT', 16, NULL, '172.20.0.1', '2026-04-22 01:04:17'),
(13, 1, 3, 'GRANT', 15, NULL, '172.20.0.1', '2026-04-22 01:04:18'),
(14, 1, 4, 'GRANT', 2, NULL, '172.20.0.1', '2026-04-22 05:52:22'),
(15, 1, 4, 'GRANT', 4, NULL, '172.20.0.1', '2026-04-22 05:52:23'),
(16, 1, 4, 'GRANT', 3, NULL, '172.20.0.1', '2026-04-22 05:52:24'),
(17, 1, 4, 'GRANT', 1, NULL, '172.20.0.1', '2026-04-22 05:52:25'),
(18, 1, 4, 'GRANT', 17, NULL, '172.20.0.1', '2026-04-22 05:52:26'),
(19, 1, 4, 'GRANT', 7, NULL, '172.20.0.1', '2026-04-22 05:52:27'),
(20, 1, 4, 'GRANT', 6, NULL, '172.20.0.1', '2026-04-22 05:52:28'),
(21, 1, 4, 'GRANT', 15, NULL, '172.20.0.1', '2026-04-22 05:52:30'),
(22, 1, 4, 'GRANT', 5, NULL, '172.20.0.1', '2026-04-22 05:52:30'),
(23, 1, 4, 'GRANT', 16, NULL, '172.20.0.1', '2026-04-22 05:52:31');

-- --------------------------------------------------------

--
-- Table structure for table `documents`
--

CREATE TABLE `documents` (
  `id` int(11) NOT NULL,
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
  `verified_at` timestamp NULL DEFAULT NULL
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
  `Description` longtext,
  `Item` varchar(100) DEFAULT NULL,
  `SerialNo` varchar(100) DEFAULT NULL,
  `DateAcquired` date DEFAULT NULL,
  `Location` varchar(100) DEFAULT NULL,
  `InventoryItemNo` varchar(50) DEFAULT NULL,
  `EstimatedUsefulLife` varchar(50) DEFAULT NULL,
  `ApprovalStatus` varchar(50) DEFAULT NULL,
  `ApprovedBy` int(11) DEFAULT NULL,
  `ApprovedDate` datetime DEFAULT NULL,
  `DeliveryNotes` text,
  `DeliveryDate` date DEFAULT NULL,
  `DeliveryStatus` varchar(50) DEFAULT NULL,
  `InspectionNotes` text,
  `InspectionDate` datetime DEFAULT NULL,
  `InspectionStatus` varchar(50) DEFAULT NULL,
  `InspectedBy` int(11) DEFAULT NULL,
  `FormType` varchar(50) DEFAULT NULL,
  `FormData` json DEFAULT NULL,
  `FormSubmitDate` datetime DEFAULT NULL,
  `FormStatus` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `entries`
--

INSERT INTO `entries` (`order_id`, `Quantity`, `Unit`, `Amount`, `UnitCost`, `TotalCost`, `Description`, `Item`, `SerialNo`, `DateAcquired`, `Location`, `InventoryItemNo`, `EstimatedUsefulLife`, `ApprovalStatus`, `ApprovedBy`, `ApprovedDate`, `DeliveryNotes`, `DeliveryDate`, `DeliveryStatus`, `InspectionNotes`, `InspectionDate`, `InspectionStatus`, `InspectedBy`, `FormType`, `FormData`, `FormSubmitDate`, `FormStatus`) VALUES
(4, 1, 'items', NULL, 65321.00, 65321.00, 'TEST', 'TEST', NULL, NULL, 'MARINA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(5, 1, 'items', NULL, 51932.00, 51932.00, 'TEST 2', 'TEST 2', NULL, NULL, 'MARINA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(6, 1, 'items', NULL, 54321.00, 54321.00, 'TEST 3', 'TEST 3', NULL, NULL, 'MARINA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(7, 1, 'items', NULL, 54321.00, 54321.00, 'TEST 3', 'TEST 3', NULL, NULL, 'MARINA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(8, 1, 'items', NULL, 54321.00, 54321.00, 'TEST 4', 'TEST 4', NULL, NULL, 'MARINA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `inspection_assignments`
--

CREATE TABLE `inspection_assignments` (
  `id` int(11) NOT NULL,
  `pr_id` int(11) NOT NULL,
  `assigned_to` int(11) NOT NULL,
  `status` enum('pending','in_progress','completed','rejected') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `inspection_notes` text COLLATE utf8mb4_unicode_ci,
  `condition_report` text COLLATE utf8mb4_unicode_ci,
  `findings` json DEFAULT NULL,
  `assigned_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `due_date` date DEFAULT NULL,
  `completed_date` timestamp NULL DEFAULT NULL,
  `attachment_count` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inspection_assignments`
--

INSERT INTO `inspection_assignments` (`id`, `pr_id`, `assigned_to`, `status`, `inspection_notes`, `condition_report`, `findings`, `assigned_date`, `due_date`, `completed_date`, `attachment_count`) VALUES
(1, 24, 2, 'completed', 'TEST', 'TEST', NULL, '2026-05-26 03:27:22', NULL, '2026-05-26 03:27:22', 0),
(2, 27, 4, 'completed', 'TEST 2', 'TEST 2', NULL, '2026-05-26 04:11:32', NULL, '2026-05-26 04:11:32', 0),
(3, 38, 2, 'completed', 'TEST 3', 'TEST 3', NULL, '2026-05-26 05:46:15', NULL, '2026-05-26 05:46:15', 0),
(4, 39, 2, 'completed', 'TEST 4 ', 'TEST 4 ', NULL, '2026-05-26 06:08:03', NULL, '2026-05-26 06:08:03', 0);

-- --------------------------------------------------------

--
-- Table structure for table `login_audit`
--

CREATE TABLE `login_audit` (
  `id` int(11) NOT NULL,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `login_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `mode` enum('online','offline') COLLATE utf8mb4_unicode_ci DEFAULT 'online',
  `success` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `offline_emails`
--

CREATE TABLE `offline_emails` (
  `id` int(11) NOT NULL,
  `recipient_email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` longtext COLLATE utf8mb4_unicode_ci,
  `status` enum('pending','sent','failed') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `attempts` int(11) DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sent_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `otp_codes`
--

CREATE TABLE `otp_codes` (
  `otp_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
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
-- Table structure for table `otp_settings`
--

CREATE TABLE `otp_settings` (
  `id` int(11) NOT NULL DEFAULT '1',
  `enabled` tinyint(1) DEFAULT '1',
  `expiry_minutes` int(11) DEFAULT '5',
  `max_attempts` int(11) DEFAULT '5',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `otp_settings`
--

INSERT INTO `otp_settings` (`id`, `enabled`, `expiry_minutes`, `max_attempts`, `updated_at`) VALUES
(1, 1, 5, 5, '2026-04-22 00:32:32');

-- --------------------------------------------------------

--
-- Table structure for table `property_inventory`
--

CREATE TABLE `property_inventory` (
  `id` int(11) NOT NULL,
  `pr_id` int(11) DEFAULT NULL,
  `pr_no` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `property_number` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
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
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `property_inventory`
--

INSERT INTO `property_inventory` (`id`, `pr_id`, `pr_no`, `property_number`, `model_number`, `description`, `serial_number`, `unit_of_measure`, `acquisition_date`, `supplier`, `estimated_cost`, `location`, `status`, `deprecated_value`, `depreciation_percentage`, `last_maintenance_date`, `assigned_to`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 4, '2026-01-007', '2026-01-007-EQU-20260422', 'Test', 'test', 'Test', 'set', '2026-05-06', '0', 224.00, '0', 'serviceable', NULL, NULL, NULL, NULL, 3, '2026-04-22 03:14:08', '2026-04-22 03:14:08'),
(2, 20, '2026-01-014', '2026-01-014-TOO-20260422', 'TEST13', 'TEST13', 'TEST13', 'set', '2026-04-30', '0', 783225.00, '0', 'serviceable', NULL, NULL, NULL, NULL, 2, '2026-04-22 06:36:56', '2026-04-22 06:36:56'),
(3, 26, 'E2E-20260526033815', 'E2E-20260526033815-PPE-001', 'MDL-001', 'Test Equipment', 'SN-001', '0', NULL, NULL, 55000.00, 'Main Office', 'serviceable', NULL, NULL, NULL, NULL, 1, '2026-05-26 03:38:15', '2026-05-26 03:38:15');

-- --------------------------------------------------------

--
-- Table structure for table `property_inventory_tags`
--

CREATE TABLE `property_inventory_tags` (
  `id` int(11) NOT NULL,
  `pr_id` int(11) DEFAULT NULL,
  `pr_no` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `property_number` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model_number` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `serial_number` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `unit_of_measure` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `acquisition_date` date NOT NULL,
  `supplier` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `estimated_cost` decimal(15,2) NOT NULL DEFAULT '0.00',
  `location` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `status` enum('serviceable','unserviceable','disposed','missing','for_repair') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'serviceable',
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `property_inventory_tags`
--

INSERT INTO `property_inventory_tags` (`id`, `pr_id`, `pr_no`, `property_number`, `model_number`, `description`, `serial_number`, `unit_of_measure`, `acquisition_date`, `supplier`, `estimated_cost`, `location`, `status`, `created_by`, `created_at`, `updated_at`) VALUES
(1, NULL, 'undefined', '2026-40503-0001-06', 'TEST 2', 'TEST 2', 'TEST 2', '', '2026-06-16', '', 51932.00, 'Shipping and Franchising Division', 'serviceable', 4, '2026-05-26 04:12:22', '2026-05-26 04:12:22'),
(2, NULL, 'undefined', '2026-40503-0002-06', 'TEST 3', 'TEST 3', 'TEST 3', '', '2026-06-09', '', 54321.00, 'Management, Financial and Administrative Service', 'serviceable', 2, '2026-05-26 05:47:48', '2026-05-26 05:47:48');

-- --------------------------------------------------------

--
-- Table structure for table `purchase_requests`
--

CREATE TABLE `purchase_requests` (
  `id` int(11) NOT NULL,
  `pr_no` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext COLLATE utf8mb4_unicode_ci,
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
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `purchase_requests`
--

INSERT INTO `purchase_requests` (`id`, `pr_no`, `description`, `item_name`, `office`, `division_section`, `quantity`, `unit`, `unit_cost`, `total_amount`, `status`, `approval_date`, `approved_by`, `approval_notes`, `rejected_by`, `rejection_reason`, `delivery_notes`, `expected_delivery_date`, `actual_delivery_date`, `inspection_notes`, `inspection_date`, `inspected_by`, `form_type`, `created_by`, `created_at`, `updated_at`) VALUES
(1, '2026-01-001', '0', '1', 'General Supply Division', 'test', 225, 'set', 225.00, 50625.00, 'approved', '2026-05-26 03:27:17', 1, 'Testing approval workflow', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-04-22 00:39:16', '2026-05-26 03:27:17'),
(2, '2026-01-002', '0', '1', 'General Supply Division', 'test2', 226, 'set', 225.00, 50850.00, 'approved', '2026-04-22 00:53:29', 2, 'Approved', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-04-22 00:53:26', '2026-04-22 00:53:29'),
(3, '2026-01-006', '0', '1', 'General Supply Division', 'test3', 227, 'set', 226.00, 51302.00, 'in_delivery', '2026-04-22 01:11:33', 3, 'Approved', NULL, NULL, 'TEST3', NULL, NULL, NULL, NULL, NULL, 'ppe', 3, '2026-04-22 01:11:30', '2026-04-22 01:11:40'),
(4, '2026-01-007', '0', '1', 'General Supply Division', 'TEST4', 226, 'set', 226.00, 51076.00, 'inspected', '2026-04-22 01:14:17', 3, 'Approved', NULL, NULL, 'test', NULL, NULL, 'test\n', '2026-04-22 03:12:37', 3, 'ppe', 3, '2026-04-22 01:14:14', '2026-04-22 03:12:37'),
(5, '2026-01-008', '0', '1', 'General Supply Division', 'test6', 226, 'set', 225.00, 50850.00, 'approved', '2026-04-22 04:45:31', 2, 'Approved', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-04-22 04:45:28', '2026-04-22 04:45:31'),
(6, '2026-01-009', '0', '1', 'General Supply Division', 'testing7', 359, 'set', 359.00, 128881.00, 'approved', '2026-04-22 04:46:55', 2, 'Approved', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-04-22 04:46:51', '2026-04-22 04:46:55'),
(7, 'PR-TEST-20260422125924', '0', 'Test Item', 'Test Office', 'Testing', 2, 'units', 20000.00, 40000.00, 'in_delivery', '2026-04-22 04:59:24', 3, 'Test approval', NULL, NULL, 'Items received', NULL, '2026-04-22', NULL, NULL, NULL, 'ics', 3, '2026-04-22 04:59:24', '2026-04-22 04:59:24'),
(8, 'PR-LOW-20260422125924', '0', 'Low Value', 'Branch', 'Operations', 1, 'units', 5000.00, 5000.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 3, '2026-04-22 04:59:25', '2026-04-22 04:59:25'),
(9, 'PR-HIGH-20260422125925', '0', 'High Value', 'HQ', 'Infrastructure', 3, 'units', 25000.00, 75000.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 3, '2026-04-22 04:59:25', '2026-04-22 04:59:25'),
(10, 'PR-TEST-20260422130031', '0', 'Test Item', 'Test Office', 'Testing', 2, 'units', 20000.00, 40000.00, 'in_delivery', '2026-04-22 05:00:31', 3, 'Test approval', NULL, NULL, 'Items received', NULL, '2026-04-22', NULL, NULL, NULL, 'ics', 3, '2026-04-22 05:00:31', '2026-04-22 05:00:31'),
(11, 'PR-LOW-20260422130031', '0', 'Low Value', 'Branch', 'Operations', 1, 'units', 5000.00, 5000.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 3, '2026-04-22 05:00:32', '2026-04-22 05:00:32'),
(12, 'PR-HIGH-20260422130032', '0', 'High Value', 'HQ', 'Infrastructure', 3, 'units', 25000.00, 75000.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 3, '2026-04-22 05:00:32', '2026-04-22 05:00:32'),
(13, '2026-01-010', '0', '1', 'Planning and Policy Service', 'TESTING', 226, 'set', 226.00, 51076.00, 'approved', '2026-04-22 05:04:18', 2, 'Approved', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-04-22 05:04:15', '2026-04-22 05:04:18'),
(14, '2026-01-011', '0', '1', 'Manpower Development Service', 'TESTING9', 229, 'set', 299.00, 68471.00, 'approved', '2026-04-22 05:07:10', 2, 'Approved', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-04-22 05:07:06', '2026-04-22 05:07:10'),
(15, 'PR-TEST-20260422133317', '0', 'Test Item', 'Test Office', 'Testing', 2, 'units', 20000.00, 40000.00, 'in_delivery', '2026-04-22 05:33:17', 3, 'Test approval', NULL, NULL, 'Items received', NULL, '2026-04-22', NULL, NULL, NULL, 'ics', 3, '2026-04-22 05:33:17', '2026-04-22 05:33:17'),
(16, 'PR-LOW-20260422133317', '0', 'Low Value', 'Branch', 'Operations', 1, 'units', 5000.00, 5000.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 3, '2026-04-22 05:33:17', '2026-04-22 05:33:17'),
(17, 'PR-HIGH-20260422133317', '0', 'High Value', 'HQ', 'Infrastructure', 3, 'units', 25000.00, 75000.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 3, '2026-04-22 05:33:17', '2026-04-22 05:33:17'),
(18, '2026-01-012', '0', '1', 'General Supply Division', 'test', 832, 'set', 831.00, 691392.00, 'approved', '2026-04-22 05:46:41', 2, 'Approved', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-04-22 05:46:37', '2026-04-22 05:46:41'),
(19, '2026-01-013', '0', '1', 'General Supply Division', 'TESTING11', 225, 'set', 225.00, 50625.00, 'approved', '2026-04-22 06:25:15', 4, 'Approved', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 4, '2026-04-22 06:25:12', '2026-04-22 06:25:15'),
(20, '2026-01-014', '0', '1', 'General Supply Division', 'test12', 755, 'set', 755.00, 570025.00, 'inspected', '2026-04-22 06:31:44', 2, 'Approved', NULL, NULL, 'TEST13', NULL, NULL, 'TEST13\n', '2026-04-22 06:35:54', 2, 'ppe', 2, '2026-04-22 06:31:42', '2026-04-22 06:35:54'),
(21, '2026-05-001', 'TEST', '[{\"id\":1779765034595,\"particular\":\"TEST\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":64231,\"amount\":64231}]', 'MARINA', 'Shipping and Franchising Division', 1, 'items', 64231.00, 64231.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-05-26 03:10:58', '2026-05-26 03:10:58'),
(22, '2026-05-001-01', 'TEST', '[{\"id\":1779765207980,\"particular\":\"TEST\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":62302,\"amount\":62302}]', 'MARINA', 'Shipping and Franchising Division', 1, 'items', 62302.00, 62302.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-05-26 03:13:48', '2026-05-26 03:13:48'),
(23, '2026-05-001-02', 'TEST', '[{\"id\":1779765621022,\"particular\":\"TEST\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":56432,\"amount\":56432}]', 'MARINA', 'Shipping and Franchising Division', 1, 'items', 56432.00, 56432.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-05-26 03:20:40', '2026-05-26 03:20:40'),
(24, '2026-05-001-03', 'TEST', '[{\"id\":1779765966386,\"particular\":\"TEST\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":65321,\"amount\":65321}]', 'MARINA', 'Management, Financial and Administrative Service', 1, 'items', 65321.00, 65321.00, 'inspected', '2026-05-26 03:26:33', 2, 'Approved by system', NULL, NULL, 'No delivery notes provided', NULL, '2026-06-09', 'TEST', '2026-05-26 03:27:22', 2, 'ppe', 2, '2026-05-26 03:26:27', '2026-05-26 03:27:22'),
(25, 'TEST-20260526033740', 'Test PPE Item >= 50000', NULL, NULL, NULL, NULL, NULL, NULL, 75000.00, 'approved', '2026-05-26 03:37:40', 1, 'Auto-approved for testing', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-05-26 03:37:40', '2026-05-26 03:37:40'),
(26, 'E2E-20260526033815', 'E2E Test - PPE Item', NULL, NULL, NULL, NULL, NULL, NULL, 55000.00, 'approved', '2026-05-26 03:38:15', 1, 'E2E Test Approval', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-05-26 03:38:15', '2026-05-26 03:38:15'),
(27, '2026-05-004', 'TEST 2', '[{\"id\":1779768632340,\"particular\":\"TEST 2\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":51932,\"amount\":51932}]', 'MARINA', 'Shipping and Franchising Division', 1, 'items', 51932.00, 51932.00, 'inspected', '2026-05-26 04:10:58', 4, 'Approved by system', NULL, NULL, 'No delivery notes provided', NULL, '2026-06-09', 'TEST 2', '2026-05-26 04:11:32', 4, 'ppe', 4, '2026-05-26 04:10:35', '2026-05-26 04:11:32'),
(28, 'CHAIN-TEST-20260526041404', 'Chain Test Item - PPE', NULL, NULL, NULL, NULL, NULL, NULL, 60000.00, 'completed', '2026-05-26 04:14:04', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-05-26 04:14:04', '2026-05-26 04:14:04'),
(29, '2026-05-005', 'Test 3', '[{\"id\":1779773384574,\"particular\":\"Test 3\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":54321,\"amount\":54321}]', 'MARINA', 'Shipping and Franchising Division', 1, 'items', 54321.00, 54321.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-05-26 05:30:09', '2026-05-26 05:30:09'),
(30, '2026-05-005-01', 'Test 3', '[{\"id\":1779773384574,\"particular\":\"Test 3\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":54321,\"amount\":54321}]', 'MARINA', 'Shipping and Franchising Division', 1, 'items', 54321.00, 54321.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-05-26 05:30:19', '2026-05-26 05:30:19'),
(31, '2026-05-002', 'TEST 3', '[{\"id\":1779773587066,\"particular\":\"TEST 3\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":54321,\"amount\":54321}]', 'MARINA', 'Shipping and Franchising Division', 1, 'items', 54321.00, 54321.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-05-26 05:33:11', '2026-05-26 05:33:11'),
(32, '2026-05-002-01', 'TEST 3', '[{\"id\":1779773735186,\"particular\":\"TEST 3\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":54321,\"amount\":54321}]', 'MARINA', 'Management, Financial and Administrative Service', 1, 'items', 54321.00, 54321.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-05-26 05:35:43', '2026-05-26 05:35:43'),
(33, '2026-05-002-02', 'TEST 3', '[{\"id\":1779773844384,\"particular\":\"TEST 3\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":54321,\"amount\":54321}]', 'MARINA', 'Overseas Shipping Service', 1, 'items', 54321.00, 54321.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-05-26 05:37:42', '2026-05-26 05:37:42'),
(34, '2026-05-002-03', 'TEST 3', '[{\"id\":1779773844384,\"particular\":\"TEST 3\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":54321,\"amount\":54321}]', 'MARINA', 'Overseas Shipping Service', 1, 'items', 54321.00, 54321.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-05-26 05:38:03', '2026-05-26 05:38:03'),
(35, '2026-05-002-04', 'TEST 3', '[{\"id\":1779773844384,\"particular\":\"TEST 3\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":54321,\"amount\":54321}]', 'MARINA', 'Overseas Shipping Service', 1, 'items', 54321.00, 54321.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-05-26 05:38:19', '2026-05-26 05:38:19'),
(36, '2026-005-TEST', 'Test Laptop Computer', '[{\"id\":1779773946035,\"particular\":\"Test Laptop Computer\",\"unit\":\"pcs\",\"quantity\":2,\"unitCost\":25000,\"amount\":50000}]', 'MARINA', 'General Supply Division', 2, 'items', 25000.00, 50000.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-05-26 05:39:19', '2026-05-26 05:39:19'),
(37, '2026-05-002-05', 'TEST 3', '[{\"id\":1779774043553,\"particular\":\"TEST 3\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":54321,\"amount\":54321}]', 'MARINA', 'Shipping and Franchising Division', 1, 'items', 54321.00, 54321.00, 'approved', '2026-05-26 05:41:30', 2, 'Approved by system', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-05-26 05:40:51', '2026-05-26 05:41:30'),
(38, '2026-05-002-06', 'TEST 3', '[{\"id\":1779774316207,\"particular\":\"TEST 3\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":54321,\"amount\":54321}]', 'MARINA', 'Management, Financial and Administrative Service', 1, 'items', 54321.00, 54321.00, 'inspected', '2026-05-26 05:45:43', 2, 'Approved by system', NULL, NULL, 'No delivery notes provided', NULL, '2026-06-09', 'TEST 3', '2026-05-26 05:46:15', 2, 'ppe', 2, '2026-05-26 05:45:21', '2026-05-26 05:46:15'),
(39, '2026-05-002-07', 'TEST 4', '[{\"id\":1779775647934,\"particular\":\"TEST 4\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":54321,\"amount\":54321}]', 'MARINA', 'Management, Financial and Administrative Service', 1, 'items', 54321.00, 54321.00, 'inspected', '2026-05-26 06:07:40', 2, 'Approved by system', NULL, NULL, 'No delivery notes provided', NULL, '2026-06-09', 'TEST 4 ', '2026-05-26 06:08:03', 2, 'ppe', 2, '2026-05-26 06:07:30', '2026-05-26 06:08:03');

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
(1, 'superadmin', 'superadmin@ics.local', '$2y$10$JuzdwISa4W1yBM9gkP2fTe0lACKEm/q4YI.dAE.3v8uMYphygFw4S', 1, 'active', 1, NULL, 0, NULL, '2026-04-22 00:32:32', '2026-04-22 00:32:32'),
(2, 'kuzano', 'kuzano@gmail.com', '$2y$10$eH9ZykvL1jBkjem9SCiSluy3t9rilE9VXtBI.Yl65gQGuWOxFoZBK', 2, 'active', 0, NULL, 0, NULL, '2026-04-22 00:33:35', '2026-04-22 00:33:35'),
(3, 'employee', 'employee_0001@gmail.com', '$2y$10$QNGOV3091lJqlDHAusdESucgWSXqqyyOKwixTB/vG/Lpo1yPhF8mW', 3, 'active', 0, NULL, 0, NULL, '2026-04-22 01:04:10', '2026-04-22 01:04:10'),
(4, 'admin01', 'admin01@gmail.com', '$2y$10$Lx1GVLQ0RzrKkmdhVabgAOHATCMUtDXuHJgV.vUMuElET.5JNhd0W', 2, 'active', 0, NULL, 0, NULL, '2026-04-22 05:52:09', '2026-04-22 05:52:09');

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
(1, 1, 1, NULL, '2026-04-22 00:32:32', NULL),
(2, 1, 2, NULL, '2026-04-22 00:32:32', NULL),
(3, 1, 3, NULL, '2026-04-22 00:32:32', NULL),
(4, 1, 4, NULL, '2026-04-22 00:32:32', NULL),
(5, 1, 5, NULL, '2026-04-22 00:32:32', NULL),
(6, 1, 6, NULL, '2026-04-22 00:32:32', NULL),
(7, 1, 7, NULL, '2026-04-22 00:32:32', NULL),
(8, 1, 8, NULL, '2026-04-22 00:32:32', NULL),
(9, 1, 9, NULL, '2026-04-22 00:32:32', NULL),
(10, 1, 10, NULL, '2026-04-22 00:32:32', NULL),
(11, 1, 11, NULL, '2026-04-22 00:32:32', NULL),
(12, 1, 12, NULL, '2026-04-22 00:32:32', NULL),
(13, 1, 13, NULL, '2026-04-22 00:32:32', NULL),
(14, 1, 14, NULL, '2026-04-22 00:32:32', NULL),
(15, 1, 15, NULL, '2026-04-22 00:32:32', NULL),
(16, 1, 16, NULL, '2026-04-22 00:32:32', NULL),
(17, 1, 17, NULL, '2026-04-22 00:32:32', NULL),
(18, 2, 2, 1, '2026-04-22 00:33:45', NULL),
(19, 2, 4, 1, '2026-04-22 00:33:46', NULL),
(20, 2, 3, 1, '2026-04-22 00:33:47', NULL),
(21, 2, 1, 1, '2026-04-22 00:33:49', NULL),
(22, 2, 5, 1, '2026-04-22 00:33:50', NULL),
(23, 2, 6, 1, '2026-04-22 00:33:51', NULL),
(24, 2, 17, 1, '2026-04-22 00:33:52', NULL),
(25, 2, 7, 1, '2026-04-22 00:33:54', NULL),
(26, 2, 16, 1, '2026-04-22 00:33:55', NULL),
(27, 2, 15, 1, '2026-04-22 00:33:57', NULL),
(28, 3, 17, 1, '2026-04-22 01:04:16', NULL),
(29, 3, 16, 1, '2026-04-22 01:04:17', NULL),
(30, 3, 15, 1, '2026-04-22 01:04:18', NULL),
(31, 4, 2, 1, '2026-04-22 05:52:22', NULL),
(32, 4, 4, 1, '2026-04-22 05:52:23', NULL),
(33, 4, 3, 1, '2026-04-22 05:52:24', NULL),
(34, 4, 1, 1, '2026-04-22 05:52:25', NULL),
(35, 4, 17, 1, '2026-04-22 05:52:26', NULL),
(36, 4, 7, 1, '2026-04-22 05:52:27', NULL),
(37, 4, 6, 1, '2026-04-22 05:52:28', NULL),
(38, 4, 15, 1, '2026-04-22 05:52:30', NULL),
(39, 4, 5, 1, '2026-04-22 05:52:30', NULL),
(40, 4, 16, 1, '2026-04-22 05:52:31', NULL);

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
(1, 'SuperAdmin', 'Super Administrator - Full system access including admin creation', '[\"create_admins\", \"edit_admins\", \"delete_admins\", \"view_all_users\", \"system_settings\", \"view_audit_logs\", \"manage_roles\"]', 1, '2026-04-22 00:32:32', '2026-04-22 00:32:32'),
(2, 'Admin', 'Administrator - Can manage inventory and entries', '[\"view_entries\", \"create_entries\", \"edit_entries\", \"delete_entries\", \"view_users\", \"change_inventory\"]', 1, '2026-04-22 00:32:32', '2026-04-22 00:32:32'),
(3, 'Employee', 'Employee - Can view and create inventory entries', '[\"view_entries\", \"create_entries\", \"edit_own_entries\"]', 1, '2026-04-22 00:32:32', '2026-04-22 00:32:32');

-- --------------------------------------------------------

--
-- Table structure for table `workflow_history`
--

CREATE TABLE `workflow_history` (
  `id` int(11) NOT NULL,
  `pr_id` int(11) NOT NULL,
  `status_from` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status_to` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_by` int(11) DEFAULT NULL,
  `action_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `workflow_history`
--

INSERT INTO `workflow_history` (`id`, `pr_id`, `status_from`, `status_to`, `action_by`, `action_type`, `notes`, `ip_address`, `action_date`) VALUES
(1, 1, NULL, 'draft', 2, 'created', 'Purchase Request created', NULL, '2026-04-22 00:39:16'),
(2, 1, 'draft', 'approved', 2, '0', 'Approved', NULL, '2026-04-22 00:39:18'),
(3, 2, NULL, 'draft', 2, 'created', 'Purchase Request created', NULL, '2026-04-22 00:53:26'),
(4, 2, 'draft', 'approved', 2, '0', 'Approved', NULL, '2026-04-22 00:53:29'),
(5, 3, NULL, 'draft', 3, 'created', 'Purchase Request created', NULL, '2026-04-22 01:11:30'),
(6, 3, 'draft', 'approved', 3, '0', 'Approved', NULL, '2026-04-22 01:11:33'),
(7, 3, 'approved', 'in_delivery', 3, 'delivery_noted', 'TEST3', NULL, '2026-04-22 01:11:40'),
(8, 4, NULL, 'draft', 3, 'created', 'Purchase Request created', NULL, '2026-04-22 01:14:14'),
(9, 4, 'draft', 'approved', 3, '0', 'Approved', NULL, '2026-04-22 01:14:17'),
(10, 4, 'approved', 'in_delivery', 3, 'delivery_noted', 'test', NULL, '2026-04-22 03:12:30'),
(11, 4, 'in_delivery', 'inspected', 3, 'inspection_completed', 'test\n', NULL, '2026-04-22 03:12:37'),
(12, 5, NULL, 'draft', 2, 'created', 'Purchase Request created', NULL, '2026-04-22 04:45:28'),
(13, 5, 'draft', 'approved', 2, '0', 'Approved', NULL, '2026-04-22 04:45:31'),
(14, 6, NULL, 'draft', 2, 'created', 'Purchase Request created', NULL, '2026-04-22 04:46:51'),
(15, 6, 'draft', 'approved', 2, '0', 'Approved', NULL, '2026-04-22 04:46:55'),
(16, 7, NULL, 'draft', 3, 'created', 'Purchase Request created', NULL, '2026-04-22 04:59:24'),
(17, 7, 'draft', 'approved', 3, '0', 'Test approval', NULL, '2026-04-22 04:59:24'),
(18, 7, 'approved', 'in_delivery', 3, 'delivery_noted', 'Items received', NULL, '2026-04-22 04:59:24'),
(19, 8, NULL, 'draft', 3, 'created', 'Purchase Request created', NULL, '2026-04-22 04:59:25'),
(20, 9, NULL, 'draft', 3, 'created', 'Purchase Request created', NULL, '2026-04-22 04:59:25'),
(21, 10, NULL, 'draft', 3, 'created', 'Purchase Request created', NULL, '2026-04-22 05:00:31'),
(22, 10, 'draft', 'approved', 3, '0', 'Test approval', NULL, '2026-04-22 05:00:31'),
(23, 10, 'approved', 'in_delivery', 3, 'delivery_noted', 'Items received', NULL, '2026-04-22 05:00:31'),
(24, 11, NULL, 'draft', 3, 'created', 'Purchase Request created', NULL, '2026-04-22 05:00:32'),
(25, 12, NULL, 'draft', 3, 'created', 'Purchase Request created', NULL, '2026-04-22 05:00:32'),
(26, 13, NULL, 'draft', 2, 'created', 'Purchase Request created', NULL, '2026-04-22 05:04:15'),
(27, 13, 'draft', 'approved', 2, '0', 'Approved', NULL, '2026-04-22 05:04:18'),
(28, 14, NULL, 'draft', 2, 'created', 'Purchase Request created', NULL, '2026-04-22 05:07:06'),
(29, 14, 'draft', 'approved', 2, '0', 'Approved', NULL, '2026-04-22 05:07:10'),
(30, 15, NULL, 'draft', 3, 'created', 'Purchase Request created', NULL, '2026-04-22 05:33:17'),
(31, 15, 'draft', 'approved', 3, '0', 'Test approval', NULL, '2026-04-22 05:33:17'),
(32, 15, 'approved', 'in_delivery', 3, 'delivery_noted', 'Items received', NULL, '2026-04-22 05:33:17'),
(33, 16, NULL, 'draft', 3, 'created', 'Purchase Request created', NULL, '2026-04-22 05:33:17'),
(34, 17, NULL, 'draft', 3, 'created', 'Purchase Request created', NULL, '2026-04-22 05:33:17'),
(35, 18, NULL, 'draft', 2, 'created', 'Purchase Request created', NULL, '2026-04-22 05:46:37'),
(36, 18, 'draft', 'approved', 2, '0', 'Approved', NULL, '2026-04-22 05:46:41'),
(37, 19, NULL, 'draft', 4, 'created', 'Purchase Request created', NULL, '2026-04-22 06:25:12'),
(38, 19, 'draft', 'approved', 4, '0', 'Approved', NULL, '2026-04-22 06:25:15'),
(39, 20, NULL, 'draft', 2, 'created', 'Purchase Request created', NULL, '2026-04-22 06:31:42'),
(40, 20, 'draft', 'approved', 2, '0', 'Approved', NULL, '2026-04-22 06:31:44'),
(41, 20, 'approved', 'in_delivery', 2, 'delivery_noted', 'TEST13', NULL, '2026-04-22 06:34:40'),
(42, 20, 'in_delivery', 'inspected', 2, 'inspection_completed', 'TEST13\n', NULL, '2026-04-22 06:35:54'),
(43, 22, NULL, 'draft', 2, 'created', 'Purchase Request created', NULL, '2026-05-26 03:13:48'),
(44, 23, NULL, 'draft', 2, 'created', 'Purchase Request created', NULL, '2026-05-26 03:20:40'),
(45, 1, 'approved', 'approved', 1, 'approved', 'Testing approval workflow', NULL, '2026-05-26 03:26:09'),
(46, 24, NULL, 'draft', 2, 'created', 'Purchase Request created', NULL, '2026-05-26 03:26:27'),
(47, 24, 'draft', 'approved', 2, 'approved', 'Approved by system', NULL, '2026-05-26 03:26:33'),
(48, 24, 'approved', 'in_delivery', 2, 'delivery_noted', 'No delivery notes provided', NULL, '2026-05-26 03:26:47'),
(49, 24, 'in_delivery', 'in_delivery', 2, 'delivery_noted', 'No delivery notes provided', NULL, '2026-05-26 03:26:59'),
(50, 1, 'approved', 'approved', 1, 'approved', 'Testing approval workflow', NULL, '2026-05-26 03:27:17'),
(51, 24, 'in_delivery', 'inspected', 2, 'inspection_completed', 'TEST', NULL, '2026-05-26 03:27:22'),
(52, 25, 'draft', 'approved', 1, 'approved', 'Auto-test approval', NULL, '2026-05-26 03:37:40'),
(53, 26, 'draft', 'approved', 1, 'approved', 'E2E Test Approval', NULL, '2026-05-26 03:38:15'),
(54, 27, NULL, 'draft', 4, 'created', 'Purchase Request created', NULL, '2026-05-26 04:10:35'),
(55, 27, 'draft', 'approved', 4, 'approved', 'Approved by system', NULL, '2026-05-26 04:10:58'),
(56, 27, 'approved', 'in_delivery', 4, 'delivery_noted', 'No delivery notes provided', NULL, '2026-05-26 04:11:14'),
(57, 27, 'in_delivery', 'inspected', 4, 'inspection_completed', 'TEST 2', NULL, '2026-05-26 04:11:32'),
(58, 37, NULL, 'draft', 2, 'created', 'Purchase Request created', NULL, '2026-05-26 05:40:51'),
(59, 37, 'draft', 'approved', 2, 'approved', 'Approved by system', NULL, '2026-05-26 05:41:30'),
(60, 38, NULL, 'draft', 2, 'created', 'Purchase Request created', NULL, '2026-05-26 05:45:21'),
(61, 38, 'draft', 'approved', 2, 'approved', 'Approved by system', NULL, '2026-05-26 05:45:43'),
(62, 38, 'approved', 'in_delivery', 2, 'delivery_noted', 'No delivery notes provided', NULL, '2026-05-26 05:46:00'),
(63, 38, 'in_delivery', 'inspected', 2, 'inspection_completed', 'TEST 3', NULL, '2026-05-26 05:46:15'),
(64, 39, NULL, 'draft', 2, 'created', 'Purchase Request created', NULL, '2026-05-26 06:07:30'),
(65, 39, 'draft', 'approved', 2, 'approved', 'Approved by system', NULL, '2026-05-26 06:07:40'),
(66, 39, 'approved', 'in_delivery', 2, 'delivery_noted', 'No delivery notes provided', NULL, '2026-05-26 06:07:54'),
(67, 39, 'in_delivery', 'inspected', 2, 'inspection_completed', 'TEST 4 ', NULL, '2026-05-26 06:08:03');

-- --------------------------------------------------------

--
-- Table structure for table `workflow_status`
--

CREATE TABLE `workflow_status` (
  `id` int(11) NOT NULL,
  `entry_id` int(11) NOT NULL,
  `pr_no` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pr_id` int(11) DEFAULT NULL,
  `step_1_completed` tinyint(1) DEFAULT '0',
  `step_2_completed` tinyint(1) DEFAULT '0',
  `step_3_completed` tinyint(1) DEFAULT '0',
  `step_4_completed` tinyint(1) DEFAULT '0',
  `step_5_completed` tinyint(1) DEFAULT '0',
  `current_step` int(11) DEFAULT '1',
  `step_1_data` json DEFAULT NULL,
  `step_2_data` json DEFAULT NULL,
  `step_3_data` json DEFAULT NULL,
  `step_4_data` json DEFAULT NULL,
  `step_5_data` json DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `workflow_status`
--

INSERT INTO `workflow_status` (`id`, `entry_id`, `pr_no`, `pr_id`, `step_1_completed`, `step_2_completed`, `step_3_completed`, `step_4_completed`, `step_5_completed`, `current_step`, `step_1_data`, `step_2_data`, `step_3_data`, `step_4_data`, `step_5_data`, `created_by`, `created_at`, `updated_at`) VALUES
(2, 4, '2026-05-001-03', 24, 0, 0, 0, 0, 0, 1, NULL, NULL, NULL, NULL, NULL, 2, '2026-05-26 03:26:27', '2026-05-26 03:26:27'),
(3, 5, '2026-05-004', 27, 1, 0, 0, 0, 0, 2, NULL, NULL, NULL, NULL, NULL, 4, '2026-05-26 04:10:35', '2026-05-26 04:10:58'),
(4, 6, '2026-05-002-05', 37, 1, 0, 0, 0, 0, 2, NULL, NULL, NULL, NULL, NULL, 2, '2026-05-26 05:40:51', '2026-05-26 05:41:30'),
(5, 7, '2026-05-002-06', 38, 1, 0, 0, 0, 0, 2, NULL, NULL, NULL, NULL, NULL, 2, '2026-05-26 05:45:21', '2026-05-26 05:45:43'),
(6, 8, '2026-05-002-07', 39, 1, 0, 0, 0, 0, 2, NULL, NULL, NULL, NULL, NULL, 2, '2026-05-26 06:07:30', '2026-05-26 06:07:40');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin_accounts`
--
ALTER TABLE `admin_accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `admin_user_id` (`admin_user_id`),
  ADD KEY `idx_is_active` (`is_active`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `created_by_superadmin_id` (`created_by_superadmin_id`);

--
-- Indexes for table `admin_bypass_log`
--
ALTER TABLE `admin_bypass_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_admin_id` (`admin_id`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `approval_queue`
--
ALTER TABLE `approval_queue`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pr_id` (`pr_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_assigned_to` (`assigned_to`),
  ADD KEY `required_role_id` (`required_role_id`),
  ADD KEY `approved_by` (`approved_by`);

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
-- Indexes for table `documents`
--
ALTER TABLE `documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pr_id` (`pr_id`),
  ADD KEY `idx_document_type` (`document_type`),
  ADD KEY `idx_upload_date` (`upload_date`),
  ADD KEY `uploaded_by` (`uploaded_by`),
  ADD KEY `verified_by` (`verified_by`);

--
-- Indexes for table `entries`
--
ALTER TABLE `entries`
  ADD PRIMARY KEY (`order_id`),
  ADD UNIQUE KEY `unique_serial` (`SerialNo`),
  ADD UNIQUE KEY `unique_inventory` (`InventoryItemNo`),
  ADD KEY `idx_approval_status` (`ApprovalStatus`),
  ADD KEY `idx_delivery_status` (`DeliveryStatus`),
  ADD KEY `idx_inspection_status` (`InspectionStatus`),
  ADD KEY `idx_form_status` (`FormStatus`);

--
-- Indexes for table `inspection_assignments`
--
ALTER TABLE `inspection_assignments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pr_id` (`pr_id`),
  ADD KEY `idx_assigned_to` (`assigned_to`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `login_audit`
--
ALTER TABLE `login_audit`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_username` (`username`),
  ADD KEY `idx_login_time` (`login_time`);

--
-- Indexes for table `offline_emails`
--
ALTER TABLE `offline_emails`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_recipient` (`recipient_email`);

--
-- Indexes for table `otp_codes`
--
ALTER TABLE `otp_codes`
  ADD PRIMARY KEY (`otp_id`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_expires_at` (`expires_at`);

--
-- Indexes for table `otp_settings`
--
ALTER TABLE `otp_settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `property_inventory`
--
ALTER TABLE `property_inventory`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `property_number` (`property_number`),
  ADD KEY `idx_property_number` (`property_number`),
  ADD KEY `idx_pr_no` (`pr_no`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_location` (`location`),
  ADD KEY `pr_id` (`pr_id`),
  ADD KEY `assigned_to` (`assigned_to`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `property_inventory_tags`
--
ALTER TABLE `property_inventory_tags`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_property_number` (`property_number`),
  ADD KEY `idx_pr_id` (`pr_id`),
  ADD KEY `idx_pr_no` (`pr_no`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_acquisition_date` (`acquisition_date`),
  ADD KEY `idx_created_by` (`created_by`);

--
-- Indexes for table `purchase_requests`
--
ALTER TABLE `purchase_requests`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pr_no` (`pr_no`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_pr_no` (`pr_no`),
  ADD KEY `idx_office` (`office`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_approved_by` (`approved_by`),
  ADD KEY `rejected_by` (`rejected_by`),
  ADD KEY `inspected_by` (`inspected_by`),
  ADD KEY `created_by` (`created_by`);

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
-- Indexes for table `workflow_history`
--
ALTER TABLE `workflow_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pr_id` (`pr_id`),
  ADD KEY `idx_status_to` (`status_to`),
  ADD KEY `idx_action_date` (`action_date`),
  ADD KEY `action_by` (`action_by`);

--
-- Indexes for table `workflow_status`
--
ALTER TABLE `workflow_status`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_entry_id` (`entry_id`),
  ADD KEY `idx_pr_id` (`pr_id`),
  ADD KEY `idx_pr_no` (`pr_no`),
  ADD KEY `idx_current_step` (`current_step`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin_accounts`
--
ALTER TABLE `admin_accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `admin_bypass_log`
--
ALTER TABLE `admin_bypass_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `approval_queue`
--
ALTER TABLE `approval_queue`
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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `documents`
--
ALTER TABLE `documents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `entries`
--
ALTER TABLE `entries`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `inspection_assignments`
--
ALTER TABLE `inspection_assignments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `login_audit`
--
ALTER TABLE `login_audit`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `offline_emails`
--
ALTER TABLE `offline_emails`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `property_inventory`
--
ALTER TABLE `property_inventory`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `property_inventory_tags`
--
ALTER TABLE `property_inventory_tags`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `purchase_requests`
--
ALTER TABLE `purchase_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT for table `role_audit_logs`
--
ALTER TABLE `role_audit_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `user_capabilities`
--
ALTER TABLE `user_capabilities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `user_roles`
--
ALTER TABLE `user_roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `workflow_history`
--
ALTER TABLE `workflow_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=68;

--
-- AUTO_INCREMENT for table `workflow_status`
--
ALTER TABLE `workflow_status`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `workflow_status`
--
ALTER TABLE `workflow_status`
  ADD CONSTRAINT `fk_entry_workflow_entries` FOREIGN KEY (`entry_id`) REFERENCES `entries` (`order_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_entry_workflow_pr` FOREIGN KEY (`pr_id`) REFERENCES `purchase_requests` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
