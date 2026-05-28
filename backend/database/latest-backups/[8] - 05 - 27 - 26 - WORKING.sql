-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: db
-- Generation Time: May 27, 2026 at 10:17 AM
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
-- Table structure for table `purchase_requests`
--

CREATE TABLE `purchase_requests` (
  `id` int(11) NOT NULL,
  `pr_no` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `office` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `division_section` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_requested` date DEFAULT NULL,
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

INSERT INTO `purchase_requests` (`id`, `pr_no`, `description`, `item_name`, `office`, `division_section`, `date_requested`, `quantity`, `unit`, `unit_cost`, `total_amount`, `status`, `approval_date`, `approved_by`, `approval_notes`, `rejected_by`, `rejection_reason`, `delivery_notes`, `expected_delivery_date`, `actual_delivery_date`, `inspection_notes`, `inspection_date`, `inspected_by`, `form_type`, `created_by`, `created_at`, `updated_at`) VALUES
(1, '2026-01-001', '0', '1', 'General Supply Division', 'test', NULL, 225, 'set', 225.00, 50625.00, 'approved', '2026-04-22 00:39:18', 2, 'Approved', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-04-22 00:39:16', '2026-04-22 00:39:18'),
(2, '2026-01-002', '0', '1', 'General Supply Division', 'test2', NULL, 226, 'set', 225.00, 50850.00, 'approved', '2026-04-22 00:53:29', 2, 'Approved', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-04-22 00:53:26', '2026-04-22 00:53:29'),
(3, '2026-01-006', '0', '1', 'General Supply Division', 'test3', NULL, 227, 'set', 226.00, 51302.00, 'in_delivery', '2026-04-22 01:11:33', 3, 'Approved', NULL, NULL, 'TEST3', NULL, NULL, NULL, NULL, NULL, 'ppe', 3, '2026-04-22 01:11:30', '2026-04-22 01:11:40'),
(4, '2026-01-007', '0', '1', 'General Supply Division', 'TEST4', NULL, 226, 'set', 226.00, 51076.00, 'inspected', '2026-04-22 01:14:17', 3, 'Approved', NULL, NULL, 'test', NULL, NULL, 'test\n', '2026-04-22 03:12:37', 3, 'ppe', 3, '2026-04-22 01:14:14', '2026-04-22 03:12:37'),
(5, '2026-01-008', '0', '1', 'General Supply Division', 'test6', NULL, 226, 'set', 225.00, 50850.00, 'approved', '2026-04-22 04:45:31', 2, 'Approved', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-04-22 04:45:28', '2026-04-22 04:45:31'),
(6, '2026-01-009', '0', '1', 'General Supply Division', 'testing7', NULL, 359, 'set', 359.00, 128881.00, 'approved', '2026-04-22 04:46:55', 2, 'Approved', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-04-22 04:46:51', '2026-04-22 04:46:55'),
(7, 'PR-TEST-20260422125924', '0', 'Test Item', 'Test Office', 'Testing', NULL, 2, 'units', 20000.00, 40000.00, 'in_delivery', '2026-04-22 04:59:24', 3, 'Test approval', NULL, NULL, 'Items received', NULL, '2026-04-22', NULL, NULL, NULL, 'ics', 3, '2026-04-22 04:59:24', '2026-04-22 04:59:24'),
(8, 'PR-LOW-20260422125924', '0', 'Low Value', 'Branch', 'Operations', NULL, 1, 'units', 5000.00, 5000.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 3, '2026-04-22 04:59:25', '2026-04-22 04:59:25'),
(9, 'PR-HIGH-20260422125925', '0', 'High Value', 'HQ', 'Infrastructure', NULL, 3, 'units', 25000.00, 75000.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 3, '2026-04-22 04:59:25', '2026-04-22 04:59:25'),
(10, 'PR-TEST-20260422130031', '0', 'Test Item', 'Test Office', 'Testing', NULL, 2, 'units', 20000.00, 40000.00, 'in_delivery', '2026-04-22 05:00:31', 3, 'Test approval', NULL, NULL, 'Items received', NULL, '2026-04-22', NULL, NULL, NULL, 'ics', 3, '2026-04-22 05:00:31', '2026-04-22 05:00:31'),
(11, 'PR-LOW-20260422130031', '0', 'Low Value', 'Branch', 'Operations', NULL, 1, 'units', 5000.00, 5000.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 3, '2026-04-22 05:00:32', '2026-04-22 05:00:32'),
(12, 'PR-HIGH-20260422130032', '0', 'High Value', 'HQ', 'Infrastructure', NULL, 3, 'units', 25000.00, 75000.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 3, '2026-04-22 05:00:32', '2026-04-22 05:00:32'),
(13, '2026-01-010', '0', '1', 'Planning and Policy Service', 'TESTING', NULL, 226, 'set', 226.00, 51076.00, 'approved', '2026-04-22 05:04:18', 2, 'Approved', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-04-22 05:04:15', '2026-04-22 05:04:18'),
(14, '2026-01-011', '0', '1', 'Manpower Development Service', 'TESTING9', NULL, 229, 'set', 299.00, 68471.00, 'approved', '2026-04-22 05:07:10', 2, 'Approved', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-04-22 05:07:06', '2026-04-22 05:07:10'),
(15, 'PR-TEST-20260422133317', '0', 'Test Item', 'Test Office', 'Testing', NULL, 2, 'units', 20000.00, 40000.00, 'in_delivery', '2026-04-22 05:33:17', 3, 'Test approval', NULL, NULL, 'Items received', NULL, '2026-04-22', NULL, NULL, NULL, 'ics', 3, '2026-04-22 05:33:17', '2026-04-22 05:33:17'),
(16, 'PR-LOW-20260422133317', '0', 'Low Value', 'Branch', 'Operations', NULL, 1, 'units', 5000.00, 5000.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 3, '2026-04-22 05:33:17', '2026-04-22 05:33:17'),
(17, 'PR-HIGH-20260422133317', '0', 'High Value', 'HQ', 'Infrastructure', NULL, 3, 'units', 25000.00, 75000.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 3, '2026-04-22 05:33:17', '2026-04-22 05:33:17'),
(18, '2026-01-012', '0', '1', 'General Supply Division', 'test', NULL, 832, 'set', 831.00, 691392.00, 'approved', '2026-04-22 05:46:41', 2, 'Approved', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-04-22 05:46:37', '2026-04-22 05:46:41'),
(19, '2026-01-013', '0', '1', 'General Supply Division', 'TESTING11', NULL, 225, 'set', 225.00, 50625.00, 'approved', '2026-04-22 06:25:15', 4, 'Approved', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 4, '2026-04-22 06:25:12', '2026-04-22 06:25:15'),
(20, '2026-01-014', '0', '1', 'General Supply Division', 'test12', NULL, 755, 'set', 755.00, 570025.00, 'inspected', '2026-04-22 06:31:44', 2, 'Approved', NULL, NULL, 'TEST13', NULL, NULL, 'TEST13\n', '2026-04-22 06:35:54', 2, 'ppe', 2, '2026-04-22 06:31:42', '2026-04-22 06:35:54'),
(21, '2026-05-001', 'Test 1', '[{\"id\":1779866329087,\"particular\":\"Test 1\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":52123,\"amount\":52123}]', 'MARINA', 'Management, Financial and Administrative Service', NULL, 1, 'items', 52123.00, 52123.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-05-27 07:19:03', '2026-05-27 07:19:03'),
(22, '2026-05-002', 'Test 1', '[{\"id\":1779867239197,\"particular\":\"Test 1\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":42313,\"amount\":42313}]', 'MARINA', 'Management, Financial and Administrative Service', NULL, 1, 'items', 42313.00, 42313.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 2, '2026-05-27 07:34:11', '2026-05-27 07:34:11'),
(23, '2026-05-003', 'Item 1', '[{\"id\":1779867570619,\"particular\":\"Item 1\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":412312,\"amount\":412312}]', 'MARINA', 'Management, Financial and Administrative Service', NULL, 1, 'items', 412312.00, 412312.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-05-27 07:39:36', '2026-05-27 07:39:36'),
(24, '2026-05-004', 'asdasdasd123', '[{\"id\":1779867787419,\"particular\":\"asdasdasd123\",\"unit\":\"pcs\",\"quantity\":1,\"unitCost\":223,\"amount\":223}]', 'MARINA', 'Management, Financial and Administrative Service', NULL, 1, 'items', 223.00, 223.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 2, '2026-05-27 07:43:11', '2026-05-27 07:43:11'),
(25, '2026-05-005', 'Test 1', '[{\"id\":1779868369469,\"particular\":\"Test 1\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":1235,\"amount\":1235}]', 'MARINA', 'Management, Financial and Administrative Service', NULL, 1, 'items', 1235.00, 1235.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 2, '2026-05-27 07:52:54', '2026-05-27 07:52:54'),
(26, '2026-05-005-01', 'Test 1', '[{\"id\":1779868369469,\"particular\":\"Test 1\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":1235,\"amount\":1235}]', 'MARINA', 'Management, Financial and Administrative Service', NULL, 1, 'items', 1235.00, 1235.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 2, '2026-05-27 07:52:58', '2026-05-27 07:52:58'),
(27, '2026-05-005-02', 'Test 1', '[{\"id\":1779868369469,\"particular\":\"Test 1\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":1235,\"amount\":1235}]', 'MARINA', 'Management, Financial and Administrative Service', NULL, 1, 'items', 1235.00, 1235.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 2, '2026-05-27 07:53:00', '2026-05-27 07:53:00'),
(28, '2026-05-005-03', 'Test 1', '[{\"id\":1779868369469,\"particular\":\"Test 1\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":1235,\"amount\":1235}]', 'MARINA', 'Management, Financial and Administrative Service', NULL, 1, 'items', 1235.00, 1235.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 2, '2026-05-27 07:53:03', '2026-05-27 07:53:03'),
(29, '2026-05-005-04', 'Test 1', '[{\"id\":1779868369469,\"particular\":\"Test 1\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":1235,\"amount\":1235}]', 'MARINA', 'Management, Financial and Administrative Service', NULL, 1, 'items', 1235.00, 1235.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 2, '2026-05-27 07:53:03', '2026-05-27 07:53:03'),
(30, '2026-05-005-05', 'Test 1', '[{\"id\":1779868369469,\"particular\":\"Test 1\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":1235,\"amount\":1235}]', 'MARINA', 'Management, Financial and Administrative Service', NULL, 1, 'items', 1235.00, 1235.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 2, '2026-05-27 07:53:03', '2026-05-27 07:53:03'),
(31, '2026-05-005-06', 'Test 1', '[{\"id\":1779868369469,\"particular\":\"Test 1\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":1235,\"amount\":1235}]', 'MARINA', 'Management, Financial and Administrative Service', NULL, 1, 'items', 1235.00, 1235.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 2, '2026-05-27 07:53:03', '2026-05-27 07:53:03'),
(32, '2026-05-007', 'Test 123c21123c', '[{\"id\":1779868616937,\"particular\":\"Test 123c21123c\",\"unit\":\"pcs\",\"quantity\":3948,\"unitCost\":2314,\"amount\":9135672}]', 'MARINA', 'Management, Financial and Administrative Service', NULL, 3948, 'items', 2314.00, 9135672.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-05-27 07:57:00', '2026-05-27 07:57:00'),
(33, '2026-05-008', 'Test', '[{\"id\":1779870278700,\"particular\":\"Test\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":24231,\"amount\":24231}]', 'MARINA', 'Management, Financial and Administrative Service', NULL, 1, 'items', 24231.00, 24231.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 2, '2026-05-27 08:24:40', '2026-05-27 08:24:40'),
(34, '2026-05-009', 'Test 1', '[{\"id\":1779870437350,\"particular\":\"Test 1\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":2323,\"amount\":2323}]', 'MARINA', 'Management, Financial and Administrative Service', NULL, 1, 'items', 2323.00, 2323.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 2, '2026-05-27 08:27:28', '2026-05-27 08:27:28'),
(35, '2026-05-010', 'Screw 12 inches, Screw 5 inches', '[{\"id\":1779870671370,\"particular\":\"Screw 12 inches\",\"unit\":\"pcs\",\"quantity\":20,\"unitCost\":42,\"amount\":840},{\"id\":1779870683266,\"particular\":\"Screw 5 inches\",\"unit\":\"pcs\",\"quantity\":10,\"unitCost\":420,\"amount\":4200}]', 'MARINA', 'General Supply Division', NULL, 30, 'items', 168.00, 5040.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 2, '2026-05-27 08:31:47', '2026-05-27 08:31:47'),
(36, '2026-05-010-01', 'Screw 12 inches, Screw 5 inches', '[{\"id\":1779870671370,\"particular\":\"Screw 12 inches\",\"unit\":\"pcs\",\"quantity\":20,\"unitCost\":42,\"amount\":840},{\"id\":1779870683266,\"particular\":\"Screw 5 inches\",\"unit\":\"pcs\",\"quantity\":10,\"unitCost\":420,\"amount\":4200}]', 'MARINA', 'General Supply Division', NULL, 30, 'items', 168.00, 5040.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 2, '2026-05-27 08:37:16', '2026-05-27 08:37:16'),
(37, '2026-05-002-01', 'Test 1', '[{\"id\":1779871274677,\"particular\":\"Test 1\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":4203,\"amount\":4203}]', 'MARINA', 'Management, Financial and Administrative Service', NULL, 1, 'items', 4203.00, 4203.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 2, '2026-05-27 08:41:15', '2026-05-27 08:41:15'),
(38, '2026-05-002-02', 'Test', '[{\"id\":1779874229267,\"particular\":\"Test\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":1124124,\"amount\":1124124}]', 'MARINA', 'Maritime Safety Service', NULL, 1, 'items', 1124124.00, 1124124.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ppe', 2, '2026-05-27 09:30:52', '2026-05-27 09:30:52'),
(39, '2026-05-002-03', 'Test1', '[{\"id\":1779875158362,\"particular\":\"Test1\",\"unit\":\"pc\",\"quantity\":1,\"unitCost\":5231,\"amount\":5231}]', 'MARINA', 'Management, Financial and Administrative Service', NULL, 1, 'items', 5231.00, 5231.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 2, '2026-05-27 09:45:59', '2026-05-27 09:45:59'),
(40, '2026-05-002-04', 'TEST 1', '[{\"id\":1779876555136,\"particular\":\"TEST 1\",\"unit\":\"pcs\",\"quantity\":1,\"unitCost\":1345,\"amount\":1345}]', 'MARINA', 'General Supply Division', '2026-06-10', 1, 'items', 1345.00, 1345.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 2, '2026-05-27 10:09:18', '2026-05-27 10:09:18'),
(41, '2026-05-002-05', 'TESTWETVB24B6', '[{\"id\":1779876942892,\"particular\":\"TESTWETVB24B6\",\"unit\":\"pcs\",\"quantity\":20,\"unitCost\":25,\"amount\":500}]', 'MARINA', 'General Supply Division', '2026-06-03', 20, 'items', 25.00, 500.00, 'draft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'ics', 2, '2026-05-27 10:15:46', '2026-05-27 10:15:46');

--
-- Indexes for dumped tables
--

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
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `purchase_requests`
--
ALTER TABLE `purchase_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
