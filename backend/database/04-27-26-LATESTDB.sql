-- MySQL dump 10.13  Distrib 5.7.44, for Linux (x86_64)
--
-- Host: localhost    Database: LATEST_DATABASE_COPY
-- ------------------------------------------------------
-- Server version	5.7.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admin_accounts`
--

DROP TABLE IF EXISTS `admin_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_user_id` int(11) NOT NULL,
  `created_by_superadmin_id` int(11) NOT NULL,
  `username` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `permissions` json DEFAULT NULL COMMENT 'JSON array of admin permissions',
  `is_active` tinyint(1) DEFAULT '1',
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `notes` text COLLATE utf8mb4_unicode_ci COMMENT 'Notes about this admin account',
  PRIMARY KEY (`id`),
  UNIQUE KEY `admin_user_id` (`admin_user_id`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_created_at` (`created_at`),
  KEY `created_by_superadmin_id` (`created_by_superadmin_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_accounts`
--

LOCK TABLES `admin_accounts` WRITE;
/*!40000 ALTER TABLE `admin_accounts` DISABLE KEYS */;
/*!40000 ALTER TABLE `admin_accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_bypass_log`
--

DROP TABLE IF EXISTS `admin_bypass_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_bypass_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) DEFAULT NULL,
  `bypassed_user_email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bypass_key` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_admin_id` (`admin_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_bypass_log`
--

LOCK TABLES `admin_bypass_log` WRITE;
/*!40000 ALTER TABLE `admin_bypass_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `admin_bypass_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `approval_queue`
--

DROP TABLE IF EXISTS `approval_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
  KEY `approved_by` (`approved_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `approval_queue`
--

LOCK TABLES `approval_queue` WRITE;
/*!40000 ALTER TABLE `approval_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `approval_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audit_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) DEFAULT NULL,
  `action` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_details` json DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_admin_id` (`admin_id`),
  KEY `idx_action` (`action`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `capabilities`
--

DROP TABLE IF EXISTS `capabilities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `capabilities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `capability_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Identifier: edit_admin_caps',
  `category` enum('INVENTORY','ADMIN','SYSTEM','USER') COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `required_role_id` int(11) DEFAULT NULL COMMENT 'Minimum role_id that can have this: 1=SuperAdmin, 2=Admin, 3=Employee',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `capability_key` (`capability_key`),
  KEY `idx_capability_key` (`capability_key`),
  KEY `idx_category` (`category`),
  KEY `idx_required_role` (`required_role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `capabilities`
--

LOCK TABLES `capabilities` WRITE;
/*!40000 ALTER TABLE `capabilities` DISABLE KEYS */;
INSERT INTO `capabilities` VALUES (1,'view_entries','INVENTORY','View inventory entries',2,1,'2026-04-22 00:32:32'),(2,'create_entries','INVENTORY','Create new inventory entries',2,1,'2026-04-22 00:32:32'),(3,'edit_entries','INVENTORY','Edit existing inventory entries',2,1,'2026-04-22 00:32:32'),(4,'delete_entries','INVENTORY','Delete inventory entries',2,1,'2026-04-22 00:32:32'),(5,'create_employee','ADMIN','Create new employee account',2,1,'2026-04-22 00:32:32'),(6,'edit_employee_caps','ADMIN','Edit employee capabilities',2,1,'2026-04-22 00:32:32'),(7,'view_employees','ADMIN','View employee list',2,1,'2026-04-22 00:32:32'),(8,'create_admin','ADMIN','Create new admin account',1,1,'2026-04-22 00:32:32'),(9,'edit_admin_caps','ADMIN','Edit admin capabilities',1,1,'2026-04-22 00:32:32'),(10,'delete_admin','ADMIN','Delete admin account',1,1,'2026-04-22 00:32:32'),(11,'view_admin_list','ADMIN','View all admins',1,1,'2026-04-22 00:32:32'),(12,'view_audit_logs','SYSTEM','View all system audit logs',1,1,'2026-04-22 00:32:32'),(13,'manage_roles','SYSTEM','Create or modify roles',1,1,'2026-04-22 00:32:32'),(14,'system_settings','SYSTEM','Access system configuration',1,1,'2026-04-22 00:32:32'),(15,'view_own_entries','USER','View own inventory entries',3,1,'2026-04-22 00:32:32'),(16,'view_own_capabilities','USER','View own assigned capabilities',3,1,'2026-04-22 00:32:32'),(17,'view_own_audit_history','USER','View own action history',3,1,'2026-04-22 00:32:32');
/*!40000 ALTER TABLE `capabilities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `capability_audit_log`
--

DROP TABLE IF EXISTS `capability_audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `capability_audit_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `actor_id` int(11) NOT NULL COMMENT 'Who made the change',
  `target_id` int(11) NOT NULL COMMENT 'Who was the target',
  `action` enum('GRANT','REVOKE','EXPIRE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `capability_id` int(11) NOT NULL,
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `capability_id` (`capability_id`),
  KEY `idx_actor_id` (`actor_id`),
  KEY `idx_target_id` (`target_id`),
  KEY `idx_action` (`action`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `capability_audit_log`
--

LOCK TABLES `capability_audit_log` WRITE;
/*!40000 ALTER TABLE `capability_audit_log` DISABLE KEYS */;
INSERT INTO `capability_audit_log` VALUES (1,1,2,'GRANT',2,NULL,'172.20.0.1','2026-04-22 00:33:45'),(2,1,2,'GRANT',4,NULL,'172.20.0.1','2026-04-22 00:33:46'),(3,1,2,'GRANT',3,NULL,'172.20.0.1','2026-04-22 00:33:47'),(4,1,2,'GRANT',1,NULL,'172.20.0.1','2026-04-22 00:33:49'),(5,1,2,'GRANT',5,NULL,'172.20.0.1','2026-04-22 00:33:50'),(6,1,2,'GRANT',6,NULL,'172.20.0.1','2026-04-22 00:33:51'),(7,1,2,'GRANT',17,NULL,'172.20.0.1','2026-04-22 00:33:52'),(8,1,2,'GRANT',7,NULL,'172.20.0.1','2026-04-22 00:33:54'),(9,1,2,'GRANT',16,NULL,'172.20.0.1','2026-04-22 00:33:55'),(10,1,2,'GRANT',15,NULL,'172.20.0.1','2026-04-22 00:33:57'),(11,1,3,'GRANT',17,NULL,'172.20.0.1','2026-04-22 01:04:16'),(12,1,3,'GRANT',16,NULL,'172.20.0.1','2026-04-22 01:04:17'),(13,1,3,'GRANT',15,NULL,'172.20.0.1','2026-04-22 01:04:18'),(14,1,4,'GRANT',2,NULL,'172.20.0.1','2026-04-22 05:52:22'),(15,1,4,'GRANT',4,NULL,'172.20.0.1','2026-04-22 05:52:23'),(16,1,4,'GRANT',3,NULL,'172.20.0.1','2026-04-22 05:52:24'),(17,1,4,'GRANT',1,NULL,'172.20.0.1','2026-04-22 05:52:25'),(18,1,4,'GRANT',17,NULL,'172.20.0.1','2026-04-22 05:52:26'),(19,1,4,'GRANT',7,NULL,'172.20.0.1','2026-04-22 05:52:27'),(20,1,4,'GRANT',6,NULL,'172.20.0.1','2026-04-22 05:52:28'),(21,1,4,'GRANT',15,NULL,'172.20.0.1','2026-04-22 05:52:30'),(22,1,4,'GRANT',5,NULL,'172.20.0.1','2026-04-22 05:52:30'),(23,1,4,'GRANT',16,NULL,'172.20.0.1','2026-04-22 05:52:31');
/*!40000 ALTER TABLE `capability_audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents`
--

DROP TABLE IF EXISTS `documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
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
  PRIMARY KEY (`id`),
  KEY `idx_pr_id` (`pr_id`),
  KEY `idx_document_type` (`document_type`),
  KEY `idx_upload_date` (`upload_date`),
  KEY `uploaded_by` (`uploaded_by`),
  KEY `verified_by` (`verified_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents`
--

LOCK TABLES `documents` WRITE;
/*!40000 ALTER TABLE `documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `entries`
--

DROP TABLE IF EXISTS `entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `entries` (
  `order_id` int(11) NOT NULL AUTO_INCREMENT,
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
  PRIMARY KEY (`order_id`),
  UNIQUE KEY `unique_serial` (`SerialNo`),
  UNIQUE KEY `unique_inventory` (`InventoryItemNo`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entries`
--

LOCK TABLES `entries` WRITE;
/*!40000 ALTER TABLE `entries` DISABLE KEYS */;
/*!40000 ALTER TABLE `entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inspection_assignments`
--

DROP TABLE IF EXISTS `inspection_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inspection_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
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
  PRIMARY KEY (`id`),
  KEY `idx_pr_id` (`pr_id`),
  KEY `idx_assigned_to` (`assigned_to`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inspection_assignments`
--

LOCK TABLES `inspection_assignments` WRITE;
/*!40000 ALTER TABLE `inspection_assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `inspection_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `login_audit`
--

DROP TABLE IF EXISTS `login_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `login_audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `login_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `mode` enum('online','offline') COLLATE utf8mb4_unicode_ci DEFAULT 'online',
  `success` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_username` (`username`),
  KEY `idx_login_time` (`login_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login_audit`
--

LOCK TABLES `login_audit` WRITE;
/*!40000 ALTER TABLE `login_audit` DISABLE KEYS */;
/*!40000 ALTER TABLE `login_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `offline_emails`
--

DROP TABLE IF EXISTS `offline_emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `offline_emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recipient_email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` longtext COLLATE utf8mb4_unicode_ci,
  `status` enum('pending','sent','failed') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `attempts` int(11) DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sent_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_recipient` (`recipient_email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `offline_emails`
--

LOCK TABLES `offline_emails` WRITE;
/*!40000 ALTER TABLE `offline_emails` DISABLE KEYS */;
/*!40000 ALTER TABLE `offline_emails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `otp_codes`
--

DROP TABLE IF EXISTS `otp_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
  `used_at` timestamp NULL DEFAULT NULL COMMENT 'When OTP was used',
  PRIMARY KEY (`otp_id`),
  KEY `idx_email` (`email`),
  KEY `idx_status` (`status`),
  KEY `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `otp_codes`
--

LOCK TABLES `otp_codes` WRITE;
/*!40000 ALTER TABLE `otp_codes` DISABLE KEYS */;
/*!40000 ALTER TABLE `otp_codes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `otp_settings`
--

DROP TABLE IF EXISTS `otp_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `otp_settings` (
  `id` int(11) NOT NULL DEFAULT '1',
  `enabled` tinyint(1) DEFAULT '1',
  `expiry_minutes` int(11) DEFAULT '5',
  `max_attempts` int(11) DEFAULT '5',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `otp_settings`
--

LOCK TABLES `otp_settings` WRITE;
/*!40000 ALTER TABLE `otp_settings` DISABLE KEYS */;
INSERT INTO `otp_settings` VALUES (1,1,5,5,'2026-04-22 00:32:32');
/*!40000 ALTER TABLE `otp_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `property_inventory`
--

DROP TABLE IF EXISTS `property_inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `property_inventory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
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
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `property_number` (`property_number`),
  KEY `idx_property_number` (`property_number`),
  KEY `idx_pr_no` (`pr_no`),
  KEY `idx_status` (`status`),
  KEY `idx_location` (`location`),
  KEY `pr_id` (`pr_id`),
  KEY `assigned_to` (`assigned_to`),
  KEY `created_by` (`created_by`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `property_inventory`
--

LOCK TABLES `property_inventory` WRITE;
/*!40000 ALTER TABLE `property_inventory` DISABLE KEYS */;
INSERT INTO `property_inventory` VALUES (1,4,'2026-01-007','2026-01-007-EQU-20260422','Test','test','Test','set','2026-05-06','0',224.00,'0','serviceable',NULL,NULL,NULL,NULL,3,'2026-04-22 03:14:08','2026-04-22 03:14:08'),(2,20,'2026-01-014','2026-01-014-TOO-20260422','TEST13','TEST13','TEST13','set','2026-04-30','0',783225.00,'0','serviceable',NULL,NULL,NULL,NULL,2,'2026-04-22 06:36:56','2026-04-22 06:36:56');
/*!40000 ALTER TABLE `property_inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `property_inventory_tags`
--

DROP TABLE IF EXISTS `property_inventory_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `property_inventory_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
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
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_property_number` (`property_number`),
  KEY `idx_pr_id` (`pr_id`),
  KEY `idx_pr_no` (`pr_no`),
  KEY `idx_status` (`status`),
  KEY `idx_acquisition_date` (`acquisition_date`),
  KEY `idx_created_by` (`created_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `property_inventory_tags`
--

LOCK TABLES `property_inventory_tags` WRITE;
/*!40000 ALTER TABLE `property_inventory_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `property_inventory_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `purchase_requests`
--

DROP TABLE IF EXISTS `purchase_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `purchase_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pr_no` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
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
  PRIMARY KEY (`id`),
  UNIQUE KEY `pr_no` (`pr_no`),
  KEY `idx_status` (`status`),
  KEY `idx_pr_no` (`pr_no`),
  KEY `idx_office` (`office`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_approved_by` (`approved_by`),
  KEY `rejected_by` (`rejected_by`),
  KEY `inspected_by` (`inspected_by`),
  KEY `created_by` (`created_by`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_requests`
--

LOCK TABLES `purchase_requests` WRITE;
/*!40000 ALTER TABLE `purchase_requests` DISABLE KEYS */;
INSERT INTO `purchase_requests` VALUES (1,'2026-01-001','0','1','General Supply Division','test',225,'set',225.00,50625.00,'approved','2026-04-22 00:39:18',2,'Approved',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ppe',2,'2026-04-22 00:39:16','2026-04-22 00:39:18'),(2,'2026-01-002','0','1','General Supply Division','test2',226,'set',225.00,50850.00,'approved','2026-04-22 00:53:29',2,'Approved',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ppe',2,'2026-04-22 00:53:26','2026-04-22 00:53:29'),(3,'2026-01-006','0','1','General Supply Division','test3',227,'set',226.00,51302.00,'in_delivery','2026-04-22 01:11:33',3,'Approved',NULL,NULL,'TEST3',NULL,NULL,NULL,NULL,NULL,'ppe',3,'2026-04-22 01:11:30','2026-04-22 01:11:40'),(4,'2026-01-007','0','1','General Supply Division','TEST4',226,'set',226.00,51076.00,'inspected','2026-04-22 01:14:17',3,'Approved',NULL,NULL,'test',NULL,NULL,'test\n','2026-04-22 03:12:37',3,'ppe',3,'2026-04-22 01:14:14','2026-04-22 03:12:37'),(5,'2026-01-008','0','1','General Supply Division','test6',226,'set',225.00,50850.00,'approved','2026-04-22 04:45:31',2,'Approved',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ppe',2,'2026-04-22 04:45:28','2026-04-22 04:45:31'),(6,'2026-01-009','0','1','General Supply Division','testing7',359,'set',359.00,128881.00,'approved','2026-04-22 04:46:55',2,'Approved',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ppe',2,'2026-04-22 04:46:51','2026-04-22 04:46:55'),(7,'PR-TEST-20260422125924','0','Test Item','Test Office','Testing',2,'units',20000.00,40000.00,'in_delivery','2026-04-22 04:59:24',3,'Test approval',NULL,NULL,'Items received',NULL,'2026-04-22',NULL,NULL,NULL,'ics',3,'2026-04-22 04:59:24','2026-04-22 04:59:24'),(8,'PR-LOW-20260422125924','0','Low Value','Branch','Operations',1,'units',5000.00,5000.00,'draft',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ics',3,'2026-04-22 04:59:25','2026-04-22 04:59:25'),(9,'PR-HIGH-20260422125925','0','High Value','HQ','Infrastructure',3,'units',25000.00,75000.00,'draft',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ppe',3,'2026-04-22 04:59:25','2026-04-22 04:59:25'),(10,'PR-TEST-20260422130031','0','Test Item','Test Office','Testing',2,'units',20000.00,40000.00,'in_delivery','2026-04-22 05:00:31',3,'Test approval',NULL,NULL,'Items received',NULL,'2026-04-22',NULL,NULL,NULL,'ics',3,'2026-04-22 05:00:31','2026-04-22 05:00:31'),(11,'PR-LOW-20260422130031','0','Low Value','Branch','Operations',1,'units',5000.00,5000.00,'draft',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ics',3,'2026-04-22 05:00:32','2026-04-22 05:00:32'),(12,'PR-HIGH-20260422130032','0','High Value','HQ','Infrastructure',3,'units',25000.00,75000.00,'draft',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ppe',3,'2026-04-22 05:00:32','2026-04-22 05:00:32'),(13,'2026-01-010','0','1','Planning and Policy Service','TESTING',226,'set',226.00,51076.00,'approved','2026-04-22 05:04:18',2,'Approved',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ppe',2,'2026-04-22 05:04:15','2026-04-22 05:04:18'),(14,'2026-01-011','0','1','Manpower Development Service','TESTING9',229,'set',299.00,68471.00,'approved','2026-04-22 05:07:10',2,'Approved',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ppe',2,'2026-04-22 05:07:06','2026-04-22 05:07:10'),(15,'PR-TEST-20260422133317','0','Test Item','Test Office','Testing',2,'units',20000.00,40000.00,'in_delivery','2026-04-22 05:33:17',3,'Test approval',NULL,NULL,'Items received',NULL,'2026-04-22',NULL,NULL,NULL,'ics',3,'2026-04-22 05:33:17','2026-04-22 05:33:17'),(16,'PR-LOW-20260422133317','0','Low Value','Branch','Operations',1,'units',5000.00,5000.00,'draft',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ics',3,'2026-04-22 05:33:17','2026-04-22 05:33:17'),(17,'PR-HIGH-20260422133317','0','High Value','HQ','Infrastructure',3,'units',25000.00,75000.00,'draft',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ppe',3,'2026-04-22 05:33:17','2026-04-22 05:33:17'),(18,'2026-01-012','0','1','General Supply Division','test',832,'set',831.00,691392.00,'approved','2026-04-22 05:46:41',2,'Approved',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ppe',2,'2026-04-22 05:46:37','2026-04-22 05:46:41'),(19,'2026-01-013','0','1','General Supply Division','TESTING11',225,'set',225.00,50625.00,'approved','2026-04-22 06:25:15',4,'Approved',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ppe',4,'2026-04-22 06:25:12','2026-04-22 06:25:15'),(20,'2026-01-014','0','1','General Supply Division','test12',755,'set',755.00,570025.00,'inspected','2026-04-22 06:31:44',2,'Approved',NULL,NULL,'TEST13',NULL,NULL,'TEST13\n','2026-04-22 06:35:54',2,'ppe',2,'2026-04-22 06:31:42','2026-04-22 06:35:54');
/*!40000 ALTER TABLE `purchase_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_audit_logs`
--

DROP TABLE IF EXISTS `role_audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role_audit_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'create, update, delete',
  `admin_id` int(11) DEFAULT NULL,
  `target_admin_id` int(11) DEFAULT NULL,
  `details` json DEFAULT NULL COMMENT 'Additional details about the action',
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_admin_id` (`admin_id`),
  KEY `idx_target_admin_id` (`target_admin_id`),
  KEY `idx_action` (`action`),
  KEY `idx_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_audit_logs`
--

LOCK TABLES `role_audit_logs` WRITE;
/*!40000 ALTER TABLE `role_audit_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `role_audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_capabilities`
--

DROP TABLE IF EXISTS `user_capabilities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_capabilities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `capability_id` int(11) NOT NULL,
  `granted_by_id` int(11) DEFAULT NULL COMMENT 'Which admin granted this, NULL=system',
  `granted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NULL DEFAULT NULL COMMENT 'NULL = permanent',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_cap` (`user_id`,`capability_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_capability_id` (`capability_id`),
  KEY `idx_granted_by` (`granted_by_id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_capabilities`
--

LOCK TABLES `user_capabilities` WRITE;
/*!40000 ALTER TABLE `user_capabilities` DISABLE KEYS */;
INSERT INTO `user_capabilities` VALUES (1,1,1,NULL,'2026-04-22 00:32:32',NULL),(2,1,2,NULL,'2026-04-22 00:32:32',NULL),(3,1,3,NULL,'2026-04-22 00:32:32',NULL),(4,1,4,NULL,'2026-04-22 00:32:32',NULL),(5,1,5,NULL,'2026-04-22 00:32:32',NULL),(6,1,6,NULL,'2026-04-22 00:32:32',NULL),(7,1,7,NULL,'2026-04-22 00:32:32',NULL),(8,1,8,NULL,'2026-04-22 00:32:32',NULL),(9,1,9,NULL,'2026-04-22 00:32:32',NULL),(10,1,10,NULL,'2026-04-22 00:32:32',NULL),(11,1,11,NULL,'2026-04-22 00:32:32',NULL),(12,1,12,NULL,'2026-04-22 00:32:32',NULL),(13,1,13,NULL,'2026-04-22 00:32:32',NULL),(14,1,14,NULL,'2026-04-22 00:32:32',NULL),(15,1,15,NULL,'2026-04-22 00:32:32',NULL),(16,1,16,NULL,'2026-04-22 00:32:32',NULL),(17,1,17,NULL,'2026-04-22 00:32:32',NULL),(18,2,2,1,'2026-04-22 00:33:45',NULL),(19,2,4,1,'2026-04-22 00:33:46',NULL),(20,2,3,1,'2026-04-22 00:33:47',NULL),(21,2,1,1,'2026-04-22 00:33:49',NULL),(22,2,5,1,'2026-04-22 00:33:50',NULL),(23,2,6,1,'2026-04-22 00:33:51',NULL),(24,2,17,1,'2026-04-22 00:33:52',NULL),(25,2,7,1,'2026-04-22 00:33:54',NULL),(26,2,16,1,'2026-04-22 00:33:55',NULL),(27,2,15,1,'2026-04-22 00:33:57',NULL),(28,3,17,1,'2026-04-22 01:04:16',NULL),(29,3,16,1,'2026-04-22 01:04:17',NULL),(30,3,15,1,'2026-04-22 01:04:18',NULL),(31,4,2,1,'2026-04-22 05:52:22',NULL),(32,4,4,1,'2026-04-22 05:52:23',NULL),(33,4,3,1,'2026-04-22 05:52:24',NULL),(34,4,1,1,'2026-04-22 05:52:25',NULL),(35,4,17,1,'2026-04-22 05:52:26',NULL),(36,4,7,1,'2026-04-22 05:52:27',NULL),(37,4,6,1,'2026-04-22 05:52:28',NULL),(38,4,15,1,'2026-04-22 05:52:30',NULL),(39,4,5,1,'2026-04-22 05:52:30',NULL),(40,4,16,1,'2026-04-22 05:52:31',NULL);
/*!40000 ALTER TABLE `user_capabilities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'SuperAdmin or Admin',
  `role_description` text COLLATE utf8mb4_unicode_ci,
  `permissions` json DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_roles`
--

LOCK TABLES `user_roles` WRITE;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
INSERT INTO `user_roles` VALUES (1,'SuperAdmin','Super Administrator - Full system access including admin creation','[\"create_admins\", \"edit_admins\", \"delete_admins\", \"view_all_users\", \"system_settings\", \"view_audit_logs\", \"manage_roles\"]',1,'2026-04-22 00:32:32','2026-04-22 00:32:32'),(2,'Admin','Administrator - Can manage inventory and entries','[\"view_entries\", \"create_entries\", \"edit_entries\", \"delete_entries\", \"view_users\", \"change_inventory\"]',1,'2026-04-22 00:32:32','2026-04-22 00:32:32'),(3,'Employee','Employee - Can view and create inventory entries','[\"view_entries\", \"create_entries\", \"edit_own_entries\"]',1,'2026-04-22 00:32:32','2026-04-22 00:32:32');
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
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
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_username` (`username`),
  KEY `idx_email` (`email`),
  KEY `idx_role_id` (`role_id`),
  KEY `idx_account_status` (`account_status`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'superadmin','superadmin@ics.local','$2y$10$JuzdwISa4W1yBM9gkP2fTe0lACKEm/q4YI.dAE.3v8uMYphygFw4S',1,'active',1,NULL,0,NULL,'2026-04-22 00:32:32','2026-04-22 00:32:32'),(2,'kuzano','kuzano@gmail.com','$2y$10$eH9ZykvL1jBkjem9SCiSluy3t9rilE9VXtBI.Yl65gQGuWOxFoZBK',2,'active',0,NULL,0,NULL,'2026-04-22 00:33:35','2026-04-22 00:33:35'),(3,'employee','employee_0001@gmail.com','$2y$10$QNGOV3091lJqlDHAusdESucgWSXqqyyOKwixTB/vG/Lpo1yPhF8mW',3,'active',0,NULL,0,NULL,'2026-04-22 01:04:10','2026-04-22 01:04:10'),(4,'admin01','admin01@gmail.com','$2y$10$Lx1GVLQ0RzrKkmdhVabgAOHATCMUtDXuHJgV.vUMuElET.5JNhd0W',2,'active',0,NULL,0,NULL,'2026-04-22 05:52:09','2026-04-22 05:52:09');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `workflow_history`
--

DROP TABLE IF EXISTS `workflow_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `workflow_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pr_id` int(11) NOT NULL,
  `status_from` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status_to` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_by` int(11) DEFAULT NULL,
  `action_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pr_id` (`pr_id`),
  KEY `idx_status_to` (`status_to`),
  KEY `idx_action_date` (`action_date`),
  KEY `action_by` (`action_by`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `workflow_history`
--

LOCK TABLES `workflow_history` WRITE;
/*!40000 ALTER TABLE `workflow_history` DISABLE KEYS */;
INSERT INTO `workflow_history` VALUES (1,1,NULL,'draft',2,'created','Purchase Request created',NULL,'2026-04-22 00:39:16'),(2,1,'draft','approved',2,'0','Approved',NULL,'2026-04-22 00:39:18'),(3,2,NULL,'draft',2,'created','Purchase Request created',NULL,'2026-04-22 00:53:26'),(4,2,'draft','approved',2,'0','Approved',NULL,'2026-04-22 00:53:29'),(5,3,NULL,'draft',3,'created','Purchase Request created',NULL,'2026-04-22 01:11:30'),(6,3,'draft','approved',3,'0','Approved',NULL,'2026-04-22 01:11:33'),(7,3,'approved','in_delivery',3,'delivery_noted','TEST3',NULL,'2026-04-22 01:11:40'),(8,4,NULL,'draft',3,'created','Purchase Request created',NULL,'2026-04-22 01:14:14'),(9,4,'draft','approved',3,'0','Approved',NULL,'2026-04-22 01:14:17'),(10,4,'approved','in_delivery',3,'delivery_noted','test',NULL,'2026-04-22 03:12:30'),(11,4,'in_delivery','inspected',3,'inspection_completed','test\n',NULL,'2026-04-22 03:12:37'),(12,5,NULL,'draft',2,'created','Purchase Request created',NULL,'2026-04-22 04:45:28'),(13,5,'draft','approved',2,'0','Approved',NULL,'2026-04-22 04:45:31'),(14,6,NULL,'draft',2,'created','Purchase Request created',NULL,'2026-04-22 04:46:51'),(15,6,'draft','approved',2,'0','Approved',NULL,'2026-04-22 04:46:55'),(16,7,NULL,'draft',3,'created','Purchase Request created',NULL,'2026-04-22 04:59:24'),(17,7,'draft','approved',3,'0','Test approval',NULL,'2026-04-22 04:59:24'),(18,7,'approved','in_delivery',3,'delivery_noted','Items received',NULL,'2026-04-22 04:59:24'),(19,8,NULL,'draft',3,'created','Purchase Request created',NULL,'2026-04-22 04:59:25'),(20,9,NULL,'draft',3,'created','Purchase Request created',NULL,'2026-04-22 04:59:25'),(21,10,NULL,'draft',3,'created','Purchase Request created',NULL,'2026-04-22 05:00:31'),(22,10,'draft','approved',3,'0','Test approval',NULL,'2026-04-22 05:00:31'),(23,10,'approved','in_delivery',3,'delivery_noted','Items received',NULL,'2026-04-22 05:00:31'),(24,11,NULL,'draft',3,'created','Purchase Request created',NULL,'2026-04-22 05:00:32'),(25,12,NULL,'draft',3,'created','Purchase Request created',NULL,'2026-04-22 05:00:32'),(26,13,NULL,'draft',2,'created','Purchase Request created',NULL,'2026-04-22 05:04:15'),(27,13,'draft','approved',2,'0','Approved',NULL,'2026-04-22 05:04:18'),(28,14,NULL,'draft',2,'created','Purchase Request created',NULL,'2026-04-22 05:07:06'),(29,14,'draft','approved',2,'0','Approved',NULL,'2026-04-22 05:07:10'),(30,15,NULL,'draft',3,'created','Purchase Request created',NULL,'2026-04-22 05:33:17'),(31,15,'draft','approved',3,'0','Test approval',NULL,'2026-04-22 05:33:17'),(32,15,'approved','in_delivery',3,'delivery_noted','Items received',NULL,'2026-04-22 05:33:17'),(33,16,NULL,'draft',3,'created','Purchase Request created',NULL,'2026-04-22 05:33:17'),(34,17,NULL,'draft',3,'created','Purchase Request created',NULL,'2026-04-22 05:33:17'),(35,18,NULL,'draft',2,'created','Purchase Request created',NULL,'2026-04-22 05:46:37'),(36,18,'draft','approved',2,'0','Approved',NULL,'2026-04-22 05:46:41'),(37,19,NULL,'draft',4,'created','Purchase Request created',NULL,'2026-04-22 06:25:12'),(38,19,'draft','approved',4,'0','Approved',NULL,'2026-04-22 06:25:15'),(39,20,NULL,'draft',2,'created','Purchase Request created',NULL,'2026-04-22 06:31:42'),(40,20,'draft','approved',2,'0','Approved',NULL,'2026-04-22 06:31:44'),(41,20,'approved','in_delivery',2,'delivery_noted','TEST13',NULL,'2026-04-22 06:34:40'),(42,20,'in_delivery','inspected',2,'inspection_completed','TEST13\n',NULL,'2026-04-22 06:35:54');
/*!40000 ALTER TABLE `workflow_history` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-22  7:07:22
