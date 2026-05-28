-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: db
-- Generation Time: May 25, 2026 at 03:24 AM
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

--
-- Dumping data for table `audit_logs`
--

INSERT INTO `audit_logs` (`id`, `admin_id`, `action`, `action_details`, `ip_address`, `user_agent`, `created_at`) VALUES
(1, 5, 'ics_form_completed', '{\"unit\": \"pc\", \"items\": [{\"id\": 1779668164909, \"unit\": \"pc\", \"amount\": 43932, \"quantity\": 1, \"unitCost\": 43932, \"particular\": \"Low Value Item #1\"}], \"pr_id\": \"25\", \"pr_no\": \"2026-05-004\", \"office\": \"Shipyards Regulation Service\", \"remarks\": \"Test\", \"user_id\": \"5\", \"iac_date\": \"2026-06-08\", \"position\": \"admin_officer\", \"quantity\": 1, \"sp_value\": \"SPHV\", \"supplier\": \"SAVE MONEY TRADING\", \"unit_cost\": 43932, \"iac_iar_no\": \"2026-06-08\", \"total_cost\": 43932, \"property_no\": \"Test\", \"received_by\": \"Yusho\", \"ics_entry_no\": \"SPHV-26ICS-05\", \"total_amount\": 43932, \"date_acquired\": \"2026-06-08\", \"item_category\": \"office_supplies\", \"location_code\": \"05\", \"received_from\": \"Kuzano\", \"unit_of_measure\": \"pc\", \"division_section\": \"Shipping and Franchising Division\", \"inspection_notes\": \"Test\", \"item_description\": \"Low Value Item #1\", \"inventory_location\": \"05\", \"approved_by_position\": \"director\", \"estimated_useful_life\": \"5 yrs\"}', NULL, NULL, '2026-05-25 00:18:27'),
(2, 2, 'ics_form_completed', '{\"unit\": \"pc\", \"items\": [{\"id\": 1779668892541, \"unit\": \"pc\", \"amount\": 420, \"quantity\": 1, \"unitCost\": 420, \"particular\": \"SP Low Value Item #1\"}], \"pr_id\": \"29\", \"pr_no\": \"2026-05-002-01\", \"office\": \"Shipyards Regulation Service\", \"remarks\": \"No Remarks needed\", \"user_id\": \"2\", \"iac_date\": \"2026-06-08\", \"position\": \"budget_officer\", \"quantity\": 1, \"sp_value\": \"SPLV\", \"supplier\": \"Save  Money Trading\", \"unit_cost\": 420, \"iac_iar_no\": \"2026-05-002\", \"total_cost\": 420, \"property_no\": \"Test\", \"received_by\": \"\", \"ics_entry_no\": \"SPLV-26ICS-05\", \"total_amount\": 420, \"item_category\": \"office_supplies\", \"location_code\": \"11\", \"received_from\": \"Positions dropdown values change if needed (same goes here)\", \"unit_of_measure\": \"pc\", \"division_section\": \"Shipping and Franchising Division\", \"inspection_notes\": \"test\", \"item_description\": \"SP Low Value Item #1\", \"inventory_location\": \"11\", \"approved_by_position\": \"director\", \"estimated_useful_life\": \"\"}', NULL, NULL, '2026-05-25 00:35:11'),
(3, 2, 'ics_form_completed', '{\"unit\": \"pc\", \"items\": [{\"id\": 1779670063644, \"unit\": \"pc\", \"amount\": 455, \"quantity\": 1, \"unitCost\": 455, \"particular\": \"Form Type Test\"}], \"pr_id\": \"30\", \"pr_no\": \"2026-05-002-02\", \"office\": \"Shipyards Regulation Service\", \"remarks\": \"Remove\", \"user_id\": \"2\", \"iac_date\": \"2026-06-01\", \"position\": \"supply_officer\", \"quantity\": 1, \"sp_value\": \"SPLV\", \"supplier\": \"Sova Corp.\", \"unit_cost\": 455, \"iac_iar_no\": \"2026-01-004\", \"total_cost\": 455, \"property_no\": \"Form Type Test\", \"received_by\": \"Form Type Test\", \"ics_entry_no\": \"SPLV-26ICS-05\", \"total_amount\": 455, \"date_acquired\": \"2026-06-08\", \"item_category\": \"office_supplies\", \"location_code\": \"06\", \"received_from\": \"Form Type Test\", \"unit_of_measure\": \"pc\", \"division_section\": \"Shipping and Franchising Division\", \"inspection_notes\": \"Requisitioning office not necessary\", \"item_description\": \"Form Type Test\", \"inventory_location\": \"06\", \"approved_by_position\": \"assistant_director\", \"estimated_useful_life\": \"5 yrs.\"}', NULL, NULL, '2026-05-25 00:50:57'),
(4, 2, 'ics_form_completed', '{\"unit\": \"pc\", \"items\": [{\"id\": 1779670548281, \"unit\": \"pc\", \"amount\": 250, \"quantity\": 1, \"unitCost\": 250, \"particular\": \"View Entries  Column Test #1\"}], \"pr_id\": \"31\", \"pr_no\": \"2026-05-010\", \"office\": \"Shipyards Regulation Service\", \"remarks\": \"View Entries  Column Test #1\", \"user_id\": \"2\", \"iac_date\": \"2026-06-08\", \"position\": \"admin_officer\", \"quantity\": 1, \"sp_value\": \"SPLV\", \"supplier\": \"View Entries  Column Test #1\", \"unit_cost\": 250, \"iac_iar_no\": \"2026-06-010\", \"total_cost\": 250, \"property_no\": \"View Entries  Column Test #1\", \"received_by\": \"View Entries  Column Test #1\", \"ics_entry_no\": \"SPLV-26ICS-05\", \"total_amount\": 250, \"date_acquired\": \"2026-06-08\", \"item_category\": \"office_supplies\", \"location_code\": \"08\", \"received_from\": \"View Entries  Column Test #1\", \"unit_of_measure\": \"pc\", \"division_section\": \"Shipping and Franchising Division\", \"inspection_notes\": \"View Entries  Column Test #1\", \"item_description\": \"View Entries  Column Test #1\", \"inventory_location\": \"08\", \"approved_by_position\": \"director\", \"estimated_useful_life\": \"5 yrs.\"}', NULL, NULL, '2026-05-25 00:57:08'),
(5, 5, 'ics_form_completed', '{\"unit\": \"bottle\", \"items\": [{\"id\": 1779675489563, \"unit\": \"bottle\", \"amount\": 2940, \"quantity\": 7, \"unitCost\": 420, \"particular\": \"BROTHER BT6000BK Ink (Black)\"}, {\"id\": 1779675809160, \"unit\": \"bottle\", \"amount\": 2520, \"quantity\": 6, \"unitCost\": 420, \"particular\": \"BROTHER BT5000C Ink (Cyan)\"}, {\"id\": 1779675836802, \"unit\": \"bottle\", \"amount\": 2520, \"quantity\": 6, \"unitCost\": 420, \"particular\": \"BROTHER BT5000M Ink (Magenta)\"}, {\"id\": 1779675857792, \"unit\": \"bottle\", \"amount\": 2520, \"quantity\": 6, \"unitCost\": 420, \"particular\": \"BROTHER BT5000Y Ink (Yellow)\"}, {\"id\": 1779675879277, \"unit\": \"pc\", \"amount\": 19250, \"quantity\": 35, \"unitCost\": 550, \"particular\": \"Ink Cartridge, HP F6V26AA (HP680)\"}, {\"id\": 1779675895999, \"unit\": \"pc\", \"amount\": 19250, \"quantity\": 35, \"unitCost\": 550, \"particular\": \"Ink Cartridge, HP F6V76AA (HP680)\"}], \"pr_id\": \"35\", \"pr_no\": \"2025-09-418-03\", \"office\": \"MARINA\", \"remarks\": \"\", \"user_id\": \"5\", \"iac_date\": \"2025-03-18\", \"position\": \"\", \"quantity\": 95, \"sp_value\": \"SPHV\", \"supplier\": \"SAVE MONEY TRADING\", \"unit_cost\": 420, \"iac_iar_no\": \"2025-02-020\", \"total_cost\": 49000, \"property_no\": \"\", \"received_by\": \"\", \"ics_entry_no\": \"26ICS-05-0148\", \"total_amount\": 49000, \"item_category\": \"office_supplies\", \"location_code\": \"\", \"received_from\": \"\", \"unit_of_measure\": \"bottle\", \"division_section\": \"Office of the Administrator\", \"inspection_notes\": \"We could change this with Stock/Property No. (Auto-Increments)\", \"item_description\": \"BROTHER BT6000BK Ink (Black), BROTHER BT5000C Ink (Cyan), BROTHER BT5000M Ink (Magenta), BROTHER BT5000Y Ink (Yellow), Ink Cartridge, HP F6V26AA (HP680), Ink Cartridge, HP F6V76AA (HP680)\", \"inventory_location\": \"storage\", \"approved_by_position\": \"\", \"estimated_useful_life\": \"\"}', NULL, NULL, '2026-05-25 02:35:23'),
(6, 5, 'ics_form_completed', '{\"unit\": \"bottle\", \"items\": [{\"id\": 1779677222760, \"unit\": \"bottle\", \"amount\": 2940, \"quantity\": 7, \"unitCost\": 420, \"particular\": \"BROTHER BT6000BK Ink (Black)\"}, {\"id\": 1779677289424, \"unit\": \"bottle\", \"amount\": 2520, \"quantity\": 6, \"unitCost\": 420, \"particular\": \"BROTHER BT5000C Ink (Cyan)\"}, {\"id\": 1779677302626, \"unit\": \"bottle\", \"amount\": 2520, \"quantity\": 6, \"unitCost\": 420, \"particular\": \"BROTHER BT5000M Ink (Magenta)\"}, {\"id\": 1779677319051, \"unit\": \"bottle\", \"amount\": 2520, \"quantity\": 6, \"unitCost\": 420, \"particular\": \"BROTHER BT5000Y Ink (Yellow)\"}, {\"id\": 1779677349716, \"unit\": \"pc\", \"amount\": 19250, \"quantity\": 35, \"unitCost\": 550, \"particular\": \"Ink Cartridge, HP F6V26AA (HP680)\"}, {\"id\": 1779677362577, \"unit\": \"pc\", \"amount\": 19250, \"quantity\": 35, \"unitCost\": 550, \"particular\": \"Ink Cartridge, HP F6V76AA (HP680)\"}], \"pr_id\": \"36\", \"pr_no\": \"2026-05-011\", \"office\": \"MARINA\", \"remarks\": \"Not Necessary\", \"user_id\": \"5\", \"iac_date\": \"2026-06-08\", \"position\": \"supply_officer\", \"quantity\": 95, \"sp_value\": \"SPHV\", \"supplier\": \"SAVE MONEY TRADING\", \"unit_cost\": 420, \"iac_iar_no\": \"2026-05-025\", \"total_cost\": 49000, \"property_no\": \"Add est_useful_life_column\", \"received_by\": \"Futoshi D. Mitsuki\", \"ics_entry_no\": \"SPHV-26ICS-05\", \"total_amount\": 49000, \"date_acquired\": \"2026-04-09\", \"item_category\": \"office_supplies\", \"location_code\": \"\", \"received_from\": \"Frank D. Davis\", \"unit_of_measure\": \"bottle\", \"division_section\": \"Office of the Administrator\", \"inspection_notes\": \"Not neccessary?\", \"item_description\": \"BROTHER BT6000BK Ink (Black), BROTHER BT5000C Ink (Cyan), BROTHER BT5000M Ink (Magenta), BROTHER BT5000Y Ink (Yellow), Ink Cartridge, HP F6V26AA (HP680), Ink Cartridge, HP F6V76AA (HP680)\", \"inventory_location\": \"storage\", \"approved_by_position\": \"director\", \"estimated_useful_life\": \"5 yrs.\"}', NULL, NULL, '2026-05-25 02:52:51');

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
(23, 1, 4, 'GRANT', 16, NULL, '172.20.0.1', '2026-04-22 05:52:31'),
(24, 1, 5, 'GRANT', 2, NULL, '172.25.0.1', '2026-05-25 00:13:31'),
(25, 1, 5, 'GRANT', 4, NULL, '172.25.0.1', '2026-05-25 00:13:33'),
(26, 1, 5, 'GRANT', 3, NULL, '172.25.0.1', '2026-05-25 00:13:35'),
(27, 1, 5, 'GRANT', 1, NULL, '172.25.0.1', '2026-05-25 00:13:36'),
(28, 1, 5, 'GRANT', 5, NULL, '172.25.0.1', '2026-05-25 00:13:37'),
(29, 1, 5, 'GRANT', 6, NULL, '172.25.0.1', '2026-05-25 00:13:38'),
(30, 1, 5, 'GRANT', 7, NULL, '172.25.0.1', '2026-05-25 00:13:39'),
(31, 1, 5, 'REVOKE', 7, NULL, '172.25.0.1', '2026-05-25 00:13:42'),
(32, 1, 5, 'GRANT', 7, NULL, '172.25.0.1', '2026-05-25 00:13:43'),
(33, 1, 5, 'GRANT', 17, NULL, '172.25.0.1', '2026-05-25 00:13:44'),
(34, 1, 5, 'GRANT', 16, NULL, '172.25.0.1', '2026-05-25 00:13:45'),
(35, 1, 5, 'GRANT', 15, NULL, '172.25.0.1', '2026-05-25 00:13:46');

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
  `Description` varchar(255) DEFAULT NULL,
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
(1, 300, 'items', NULL, 135.00, 40500.00, 'CUSTOMIZED PAPER BAS WITH MARINA LOGO', 'CUSTOMIZED PAPER BAS WITH MARINA LOGO', NULL, '2026-05-25', 'MARINA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(2, 13, 'items', NULL, 420.00, 5460.00, 'BROTHER BT6000BK Ink (Black), BROTHER BT5000C Ink (Cyan)', 'BROTHER BT6000BK Ink (Black), BROTHER BT5000C Ink (Cyan)', NULL, '2026-05-25', 'MARINA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(3, 7, 'items', NULL, 420.00, 2940.00, 'BROTHER BT6000BK Ink (Black)', 'BROTHER BT6000BK Ink (Black)', NULL, '2026-05-25', 'MARINA', '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ICS', NULL, NULL, NULL),
(4, 7, 'items', NULL, 420.00, 2940.00, 'BROTHER BT6000BK Ink (Black)', 'BROTHER BT6000BK Ink (Black)', NULL, '2026-05-25', 'MARINA', 'Add est_useful_life_column', '5 yrs.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ICS', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `ics_forms`
--

CREATE TABLE `ics_forms` (
  `id` int(11) NOT NULL,
  `pr_id` int(11) DEFAULT NULL,
  `pr_no` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ics_entry_no` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sp_value` enum('SPLV','SPHV') COLLATE utf8mb4_unicode_ci NOT NULL,
  `location_code` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `items` json DEFAULT NULL,
  `total_amount` decimal(15,2) DEFAULT NULL,
  `received_from` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `received_by` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approved_by_position` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `property_no` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estimated_useful_life` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remarks` text COLLATE utf8mb4_unicode_ci,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `ics_forms`
--

INSERT INTO `ics_forms` (`id`, `pr_id`, `pr_no`, `ics_entry_no`, `sp_value`, `location_code`, `items`, `total_amount`, `received_from`, `received_by`, `position`, `approved_by_position`, `property_no`, `estimated_useful_life`, `remarks`, `created_by`, `created_at`) VALUES
(1, 25, '2026-05-004', 'SPHV-26ICS-05', 'SPHV', '05', '[{\"id\": 1779668164909, \"unit\": \"pc\", \"amount\": 43932, \"quantity\": 1, \"unitCost\": 43932, \"particular\": \"Low Value Item #1\"}]', 43932.00, 'Kuzano', 'Yusho', 'admin_officer', 'director', 'Test', '5 yrs', 'Test', 5, '2026-05-25 00:18:27'),
(2, 29, '2026-05-002-01', 'SPLV-26ICS-05', 'SPLV', '11', '[{\"id\": 1779668892541, \"unit\": \"pc\", \"amount\": 420, \"quantity\": 1, \"unitCost\": 420, \"particular\": \"SP Low Value Item #1\"}]', 420.00, 'Positions dropdown values change if needed (same goes here)', '', 'budget_officer', 'director', 'Test', '', 'No Remarks needed', 2, '2026-05-25 00:35:11'),
(3, 30, '2026-05-002-02', 'SPLV-26ICS-05', 'SPLV', '06', '[{\"id\": 1779670063644, \"unit\": \"pc\", \"amount\": 455, \"quantity\": 1, \"unitCost\": 455, \"particular\": \"Form Type Test\"}]', 455.00, 'Form Type Test', 'Form Type Test', 'supply_officer', 'assistant_director', 'Form Type Test', '5 yrs.', 'Remove', 2, '2026-05-25 00:50:57'),
(4, 31, '2026-05-010', 'SPLV-26ICS-05', 'SPLV', '08', '[{\"id\": 1779670548281, \"unit\": \"pc\", \"amount\": 250, \"quantity\": 1, \"unitCost\": 250, \"particular\": \"View Entries  Column Test #1\"}]', 250.00, 'View Entries  Column Test #1', 'View Entries  Column Test #1', 'admin_officer', 'director', 'View Entries  Column Test #1', '5 yrs.', 'View Entries  Column Test #1', 2, '2026-05-25 00:57:08'),
(6, 36, '2026-05-011', 'SPHV-26ICS-05', 'SPHV', '', '[{\"id\": 1779677222760, \"unit\": \"bottle\", \"amount\": 2940, \"quantity\": 7, \"unitCost\": 420, \"particular\": \"BROTHER BT6000BK Ink (Black)\"}, {\"id\": 1779677289424, \"unit\": \"bottle\", \"amount\": 2520, \"quantity\": 6, \"unitCost\": 420, \"particular\": \"BROTHER BT5000C Ink (Cyan)\"}, {\"id\": 1779677302626, \"unit\": \"bottle\", \"amount\": 2520, \"quantity\": 6, \"unitCost\": 420, \"particular\": \"BROTHER BT5000M Ink (Magenta)\"}, {\"id\": 1779677319051, \"unit\": \"bottle\", \"amount\": 2520, \"quantity\": 6, \"unitCost\": 420, \"particular\": \"BROTHER BT5000Y Ink (Yellow)\"}, {\"id\": 1779677349716, \"unit\": \"pc\", \"amount\": 19250, \"quantity\": 35, \"unitCost\": 550, \"particular\": \"Ink Cartridge, HP F6V26AA (HP680)\"}, {\"id\": 1779677362577, \"unit\": \"pc\", \"amount\": 19250, \"quantity\": 35, \"unitCost\": 550, \"particular\": \"Ink Cartridge, HP F6V76AA (HP680)\"}]', 49000.00, 'Frank D. Davis', 'Futoshi D. Mitsuki', 'supply_officer', 'director', 'Add est_useful_life_column', '5 yrs.', 'Not Necessary', 5, '2026-05-25 02:52:51');

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
(1, 24, 2, 'completed', 'Test', 'Test', NULL, '2026-05-24 23:48:43', NULL, '2026-05-24 23:48:43', 0),
(2, 25, 5, 'completed', 'Test', 'Test', NULL, '2026-05-25 00:17:07', NULL, '2026-05-25 00:17:07', 0),
(3, 29, 2, 'completed', 'test', 'test', NULL, '2026-05-25 00:30:42', NULL, '2026-05-25 00:30:42', 0),
(4, 30, 2, 'completed', 'Requisitioning office not necessary', 'Requisitioning office not necessary', NULL, '2026-05-25 00:50:01', NULL, '2026-05-25 00:50:01', 0),
(5, 31, 2, 'completed', 'View Entries  Column Test #1', 'View Entries  Column Test #1', NULL, '2026-05-25 00:56:36', NULL, '2026-05-25 00:56:36', 0),
(6, 35, 5, 'completed', 'We could change this with Stock/Property No. (Auto-Increments)', 'We could change this with Stock/Property No. (Auto-Increments)', NULL, '2026-05-25 02:32:46', NULL, '2026-05-25 02:32:46', 0),
(7, 36, 5, 'completed', 'Not neccessary?', 'Not neccessary?', NULL, '2026-05-25 02:50:35', NULL, '2026-05-25 02:50:35', 0);

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
(3, 24, '2026-05-003', '2026-05-003-IT--20260525', 'Acer Veriton M630G', 'Test', 'DTVHH22030482D', 'set', '2026-06-08', '0', 61983.00, '0', 'serviceable', NULL, NULL, NULL, NULL, 2, '2026-05-25 00:10:31', '2026-05-25 00:10:31');

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
(1, 24, '2026-05-003', '2026-40503-0001-09', 'test', 'Test', 'TEST13', '', '2026-06-08', '', 61983.00, 'Shipping and Franchising Division', 'serviceable', 2, '2026-05-25 00:11:05', '2026-05-25 00:11:05');

-- --------------------------------------------------------

--
-- Table structure for table `purchase_requests`
--

CREATE TABLE `purchase_requests` (
  `id` int(11) NOT NULL,
  `pr_no` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` longtext COLLATE utf8mb4_unicode_ci,
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
(1, '2026-01-001', '0', '1', 'General Supply Division', 'test', 225, 'set', 225.00, 50625.00, 'approved', '2026-04-22 00:39:18', 2, 'Approved', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-04-22 00:39:16', '2026-04-22 00:39:18'),
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
(21, '2026-05-001', 'Test', '[{\"id\":1779666042663,\"particular\":\"Test\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":61329,\"amount\":61329}]', 'Shipyards Regulation Service', 'Shipping and Franchising Division', 1, 'items', 61329.00, 61329.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-05-24 23:40:44', '2026-05-24 23:40:44'),
(22, '2026-05-001-01', 'Test', '[{\"id\":1779666042663,\"particular\":\"Test\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":61329,\"amount\":61329}]', 'Shipyards Regulation Service', 'Shipping and Franchising Division', 1, 'items', 61329.00, 61329.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-05-24 23:41:16', '2026-05-24 23:41:16'),
(23, '2026-05-002', 'Test', '[{\"id\":1779666142978,\"particular\":\"Test\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":61993,\"amount\":61993}]', 'Shipyards Regulation Service', 'Shipping and Franchising Division', 1, 'items', 61993.00, 61993.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-05-24 23:42:25', '2026-05-24 23:42:25'),
(24, '2026-05-003', 'Test', '[{\"id\":1779666427269,\"particular\":\"Test\",\"unit\":\"set\",\"quantity\":1,\"unitCost\":61983,\"amount\":61983}]', 'Shipyards Regulation Service', 'Shipping and Franchising Division', 1, 'items', 61983.00, 61983.00, 'completed', '2026-05-24 23:47:46', 2, 'Approved', NULL, NULL, 'No delivery notes provided', NULL, '2026-06-08', 'Test', '2026-05-24 23:48:43', 2, 'ppe', 2, '2026-05-24 23:47:09', '2026-05-25 00:11:06'),
(26, '2026-05-005', 'SPLow Value Item Test #999', '[{\"id\":1779668433088,\"particular\":\"SPLow Value Item Test #999\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":420,\"amount\":420}]', 'Shipyards Regulation Service', 'Shipping and Franchising Division', 1, 'items', 420.00, 420.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 5, '2026-05-25 00:22:31', '2026-05-25 00:22:31'),
(27, '2026-05-005-01', 'SPLow Value Item Test #999, Multiple Items Test', '[{\"id\":1779668433088,\"particular\":\"SPLow Value Item Test #999\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":420,\"amount\":420},{\"id\":1779668602682,\"particular\":\"Multiple Items Test\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":480,\"amount\":480}]', 'Shipyards Regulation Service', 'Shipping and Franchising Division', 2, 'items', 450.00, 900.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 5, '2026-05-25 00:23:24', '2026-05-25 00:23:24'),
(28, '2026-05-005-01-01', 'SPLow Value Item Test #999, Multiple Items Test', '[{\"id\":1779668433088,\"particular\":\"SPLow Value Item Test #999\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":420,\"amount\":420},{\"id\":1779668602682,\"particular\":\"Multiple Items Test\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":480,\"amount\":480}]', 'Shipyards Regulation Service', 'Shipping and Franchising Division', 2, 'items', 450.00, 900.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 5, '2026-05-25 00:23:51', '2026-05-25 00:23:51'),
(29, '2026-05-002-01', 'SP Low Value Item #1', '[{\"id\":1779668892541,\"particular\":\"SP Low Value Item #1\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":420,\"amount\":420}]', 'Shipyards Regulation Service', 'Shipping and Franchising Division', 1, 'items', 420.00, 420.00, 'inspected', '2026-05-25 00:28:37', 2, 'Approved', NULL, NULL, 'No delivery notes provided', NULL, '2026-06-08', 'test', '2026-05-25 00:30:42', 2, 'ics', 2, '2026-05-25 00:28:33', '2026-05-25 00:30:42'),
(30, '2026-05-002-02', 'Form Type Test', '[{\"id\":1779670063644,\"particular\":\"Form Type Test\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":455,\"amount\":455}]', 'Shipyards Regulation Service', 'Shipping and Franchising Division', 1, 'items', 455.00, 455.00, 'inspected', '2026-05-25 00:48:25', 2, 'Approved', NULL, NULL, 'No delivery notes provided', NULL, NULL, 'Requisitioning office not necessary', '2026-05-25 00:50:01', 2, 'ics', 2, '2026-05-25 00:48:21', '2026-05-25 00:50:01'),
(31, '2026-05-010', 'View Entries  Column Test #1', '[{\"id\":1779670548281,\"particular\":\"View Entries  Column Test #1\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":250,\"amount\":250}]', 'Shipyards Regulation Service', 'Shipping and Franchising Division', 1, 'items', 250.00, 250.00, 'inspected', '2026-05-25 00:55:53', 2, 'Approved', NULL, NULL, 'No delivery notes provided', NULL, '2026-06-08', 'View Entries  Column Test #1', '2026-05-25 00:56:36', 2, 'ics', 2, '2026-05-25 00:55:50', '2026-05-25 00:56:36'),
(32, '2025-09-418', 'CUSTOMIZED PAPER BAS WITH MARINA LOGO', '[{\"id\":1779673564277,\"particular\":\"CUSTOMIZED PAPER BAS WITH MARINA LOGO\",\"unit\":\"pcs\",\"quantity\":300,\"unitCost\":135,\"amount\":40500}]', 'MARINA', 'Office of the Administrator', 300, 'items', 135.00, 40500.00, 'approved', '2026-05-25 01:47:11', 5, 'Approved', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 5, '2026-05-25 01:46:05', '2026-05-25 01:47:11'),
(33, '2025-09-418-01', 'BROTHER BT6000BK Ink (Black), BROTHER BT5000C Ink (Cyan)', '[{\"id\":1779673860708,\"particular\":\"BROTHER BT6000BK Ink (Black)\",\"unit\":\"bottle\",\"quantity\":7,\"unitCost\":420,\"amount\":2940},{\"id\":1779673940628,\"particular\":\"BROTHER BT5000C Ink (Cyan)\",\"unit\":\"bottle\",\"quantity\":6,\"unitCost\":420,\"amount\":2520}]', 'MARINA', 'Office of the Administrator', 13, 'items', 420.00, 5460.00, 'in_delivery', '2026-05-25 02:02:16', 5, 'Approved', NULL, NULL, 'No delivery notes provided', NULL, '2025-02-25', NULL, NULL, NULL, 'ics', 5, '2026-05-25 01:59:15', '2026-05-25 02:03:15'),
(34, '2025-09-418-02', 'BROTHER BT6000BK Ink (Black), BROTHER BT5000C Ink (Cyan), BROTHER BT5000M Ink (Magenta), BROTHER BT5000Y Ink (Yellow), Ink Cartridge, HP F6V26AA (HP680), Ink Cartridge, HP F6V76AA (HP680)', '[{\"id\":1779675489563,\"particular\":\"BROTHER BT6000BK Ink (Black)\",\"unit\":\"bottle\",\"quantity\":7,\"unitCost\":420,\"amount\":2940},{\"id\":1779675508627,\"particular\":\"BROTHER BT5000C Ink (Cyan)\",\"unit\":\"bottle\",\"quantity\":6,\"unitCost\":420,\"amount\":2520},{\"id\":1779675523969,\"particular\":\"BROTHER BT5000M Ink (Magenta)\",\"unit\":\"bottle\",\"quantity\":6,\"unitCost\":420,\"amount\":2520},{\"id\":1779675537235,\"particular\":\"BROTHER BT5000Y Ink (Yellow)\",\"unit\":\"bottle\",\"quantity\":6,\"unitCost\":420,\"amount\":2520},{\"id\":1779675554409,\"particular\":\"Ink Cartridge, HP F6V26AA (HP680)\",\"unit\":\"pc\",\"quantity\":35,\"unitCost\":550,\"amount\":19250},{\"id\":1779675612104,\"particular\":\"Ink Cartridge, HP F6V76AA (HP680)\",\"unit\":\"pc\",\"quantity\":35,\"unitCost\":550,\"amount\":19250}]', 'MARINA', 'Office of the Administrator', 95, 'items', 515.79, 49000.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 5, '2026-05-25 02:22:48', '2026-05-25 02:22:48'),
(35, '2025-09-418-03', 'BROTHER BT6000BK Ink (Black)', '[{\"id\":1779675489563,\"particular\":\"BROTHER BT6000BK Ink (Black)\",\"unit\":\"bottle\",\"quantity\":7,\"unitCost\":420,\"amount\":2940}]', 'MARINA', 'Office of the Administrator', 7, 'items', 420.00, 2940.00, 'inspected', '2026-05-25 02:23:11', 5, 'Approved', NULL, NULL, 'No delivery notes provided', NULL, NULL, 'We could change this with Stock/Property No. (Auto-Increments)', '2026-05-25 02:32:46', 5, 'ics', 5, '2026-05-25 02:23:07', '2026-05-25 02:32:46'),
(36, '2026-05-011', 'BROTHER BT6000BK Ink (Black)', '[{\"id\":1779677222760,\"particular\":\"BROTHER BT6000BK Ink (Black)\",\"unit\":\"bottle\",\"quantity\":7,\"unitCost\":420,\"amount\":2940}]', 'MARINA', 'Office of the Administrator', 7, 'items', 420.00, 2940.00, 'inspected', '2026-05-25 02:47:19', 5, 'Approved', NULL, NULL, 'No delivery notes provided', NULL, '2026-06-08', 'Not neccessary?', '2026-05-25 02:50:35', 5, 'ics', 5, '2026-05-25 02:47:15', '2026-05-25 02:50:35');

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
(4, 'admin01', 'admin01@gmail.com', '$2y$10$Lx1GVLQ0RzrKkmdhVabgAOHATCMUtDXuHJgV.vUMuElET.5JNhd0W', 2, 'active', 0, NULL, 0, NULL, '2026-04-22 05:52:09', '2026-04-22 05:52:09'),
(5, 'tester', 'tester@gmail.com', '$2y$10$ZcK0Fxq0pVgkor6TBhN0ee1vJDil3PUfd8ni7hSZEDUwusWnqhucW', 2, 'active', 0, NULL, 0, NULL, '2026-05-25 00:13:18', '2026-05-25 00:14:03');

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
(40, 4, 16, 1, '2026-04-22 05:52:31', NULL),
(41, 5, 2, 1, '2026-05-25 00:13:31', NULL),
(42, 5, 4, 1, '2026-05-25 00:13:33', NULL),
(43, 5, 3, 1, '2026-05-25 00:13:35', NULL),
(44, 5, 1, 1, '2026-05-25 00:13:36', NULL),
(45, 5, 5, 1, '2026-05-25 00:13:37', NULL),
(46, 5, 6, 1, '2026-05-25 00:13:38', NULL),
(48, 5, 7, 1, '2026-05-25 00:13:43', NULL),
(49, 5, 17, 1, '2026-05-25 00:13:44', NULL),
(50, 5, 16, 1, '2026-05-25 00:13:45', NULL),
(51, 5, 15, 1, '2026-05-25 00:13:46', NULL);

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
(43, 24, NULL, 'draft', 2, 'created', 'Purchase Request created', NULL, '2026-05-24 23:47:09'),
(44, 24, 'draft', 'approved', 2, '0', 'Approved', NULL, '2026-05-24 23:47:46'),
(45, 24, 'approved', 'in_delivery', 2, 'delivery_noted', 'No delivery notes provided', NULL, '2026-05-24 23:48:12'),
(46, 24, 'in_delivery', 'inspected', 2, 'inspection_completed', 'Test', NULL, '2026-05-24 23:48:43'),
(47, 25, NULL, 'draft', 5, 'created', 'Purchase Request created', NULL, '2026-05-25 00:16:08'),
(48, 25, 'draft', 'approved', 5, '0', 'Approved', NULL, '2026-05-25 00:16:12'),
(49, 25, 'approved', 'in_delivery', 5, 'delivery_noted', 'No delivery notes provided', NULL, '2026-05-25 00:16:45'),
(50, 25, 'in_delivery', 'inspected', 5, 'inspection_completed', 'Test', NULL, '2026-05-25 00:17:07'),
(51, 26, NULL, 'draft', 5, 'created', 'Purchase Request created', NULL, '2026-05-25 00:22:31'),
(52, 27, NULL, 'draft', 5, 'created', 'Purchase Request created', NULL, '2026-05-25 00:23:24'),
(53, 28, NULL, 'draft', 5, 'created', 'Purchase Request created', NULL, '2026-05-25 00:23:51'),
(54, 29, NULL, 'draft', 2, 'created', 'Purchase Request created', NULL, '2026-05-25 00:28:33'),
(55, 29, 'draft', 'approved', 2, '0', 'Approved', NULL, '2026-05-25 00:28:37'),
(56, 29, 'approved', 'in_delivery', 2, 'delivery_noted', 'No delivery notes provided', NULL, '2026-05-25 00:30:12'),
(57, 29, 'in_delivery', 'inspected', 2, 'inspection_completed', 'test', NULL, '2026-05-25 00:30:42'),
(58, 30, NULL, 'draft', 2, 'created', 'Purchase Request created', NULL, '2026-05-25 00:48:21'),
(59, 30, 'draft', 'approved', 2, '0', 'Approved', NULL, '2026-05-25 00:48:25'),
(60, 30, 'approved', 'in_delivery', 2, 'delivery_noted', 'No delivery notes provided', NULL, '2026-05-25 00:49:14'),
(61, 30, 'in_delivery', 'inspected', 2, 'inspection_completed', 'Requisitioning office not necessary', NULL, '2026-05-25 00:50:01'),
(62, 31, NULL, 'draft', 2, 'created', 'Purchase Request created', NULL, '2026-05-25 00:55:50'),
(63, 31, 'draft', 'approved', 2, '0', 'Approved', NULL, '2026-05-25 00:55:53'),
(64, 31, 'approved', 'in_delivery', 2, 'delivery_noted', 'No delivery notes provided', NULL, '2026-05-25 00:56:09'),
(65, 31, 'in_delivery', 'inspected', 2, 'inspection_completed', 'View Entries  Column Test #1', NULL, '2026-05-25 00:56:36'),
(66, 32, NULL, 'draft', 5, 'created', 'Purchase Request created', NULL, '2026-05-25 01:46:05'),
(67, 32, 'draft', 'approved', 5, '0', 'Approved', NULL, '2026-05-25 01:47:11'),
(68, 33, NULL, 'draft', 5, 'created', 'Purchase Request created', NULL, '2026-05-25 01:59:15'),
(69, 33, 'draft', 'approved', 5, '0', 'Approved', NULL, '2026-05-25 02:02:16'),
(70, 33, 'approved', 'in_delivery', 5, 'delivery_noted', 'No delivery notes provided', NULL, '2026-05-25 02:03:15'),
(71, 35, NULL, 'draft', 5, 'created', 'Purchase Request created', NULL, '2026-05-25 02:23:07'),
(72, 35, 'draft', 'approved', 5, '0', 'Approved', NULL, '2026-05-25 02:23:11'),
(73, 35, 'approved', 'in_delivery', 5, 'delivery_noted', 'No delivery notes provided', NULL, '2026-05-25 02:26:45'),
(74, 35, 'in_delivery', 'inspected', 5, 'inspection_completed', 'We could change this with Stock/Property No. (Auto-Increments)', NULL, '2026-05-25 02:32:46'),
(75, 36, NULL, 'draft', 5, 'created', 'Purchase Request created', NULL, '2026-05-25 02:47:15'),
(76, 36, 'draft', 'approved', 5, '0', 'Approved', NULL, '2026-05-25 02:47:19'),
(77, 36, 'approved', 'in_delivery', 5, 'delivery_noted', 'No delivery notes provided', NULL, '2026-05-25 02:49:36'),
(78, 36, 'in_delivery', 'inspected', 5, 'inspection_completed', 'Not neccessary?', NULL, '2026-05-25 02:50:35');

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
(1, 1, '2025-09-418', 32, 0, 0, 0, 0, 0, 1, NULL, NULL, NULL, NULL, NULL, 5, '2026-05-25 01:46:05', '2026-05-25 01:46:05'),
(2, 2, '2025-09-418-01', 33, 0, 0, 0, 0, 0, 1, NULL, NULL, NULL, NULL, NULL, 5, '2026-05-25 01:59:15', '2026-05-25 01:59:15'),
(3, 3, '2025-09-418-03', 35, 0, 0, 0, 0, 0, 1, NULL, NULL, NULL, NULL, NULL, 5, '2026-05-25 02:23:07', '2026-05-25 02:23:07'),
(4, 4, '2026-05-011', 36, 0, 0, 0, 0, 0, 1, NULL, NULL, NULL, NULL, NULL, 5, '2026-05-25 02:47:15', '2026-05-25 02:47:15');

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
-- Indexes for table `ics_forms`
--
ALTER TABLE `ics_forms`
  ADD PRIMARY KEY (`id`);

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `capabilities`
--
ALTER TABLE `capabilities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `capability_audit_log`
--
ALTER TABLE `capability_audit_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT for table `documents`
--
ALTER TABLE `documents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `entries`
--
ALTER TABLE `entries`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `ics_forms`
--
ALTER TABLE `ics_forms`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `inspection_assignments`
--
ALTER TABLE `inspection_assignments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `purchase_requests`
--
ALTER TABLE `purchase_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `role_audit_logs`
--
ALTER TABLE `role_audit_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `user_capabilities`
--
ALTER TABLE `user_capabilities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;

--
-- AUTO_INCREMENT for table `user_roles`
--
ALTER TABLE `user_roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `workflow_history`
--
ALTER TABLE `workflow_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=79;

--
-- AUTO_INCREMENT for table `workflow_status`
--
ALTER TABLE `workflow_status`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

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
