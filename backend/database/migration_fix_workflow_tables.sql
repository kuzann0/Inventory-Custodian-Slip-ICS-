-- ============================================================================
-- MIGRATION: Fix Missing Workflow Tables and Columns
-- Date: 2026-05-14
-- Purpose: Create missing entry_workflow_status table and add missing columns
--          to entries table for Dynamic Data Binding support
-- ============================================================================

-- Step 1: Create entry_workflow_status table if it doesn't exist
CREATE TABLE IF NOT EXISTS `entry_workflow_status` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `entry_id` int(11) NOT NULL,
  `pr_no` varchar(50) DEFAULT NULL,
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
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_entry_id` (`entry_id`),
  KEY `idx_pr_id` (`pr_id`),
  KEY `idx_pr_no` (`pr_no`),
  KEY `idx_current_step` (`current_step`),
  FOREIGN KEY (`pr_id`) REFERENCES `purchase_requests`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`entry_id`) REFERENCES `entries`(`order_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Step 2: Add missing columns to entries table
ALTER TABLE `entries` 
ADD COLUMN `Amount` decimal(10,2) DEFAULT NULL AFTER `TotalCost`,
ADD COLUMN `ApprovalStatus` varchar(50) DEFAULT NULL AFTER `Amount`,
ADD COLUMN `ApprovedBy` int(11) DEFAULT NULL AFTER `ApprovalStatus`,
ADD COLUMN `ApprovedDate` datetime DEFAULT NULL AFTER `ApprovedBy`,
ADD COLUMN `DeliveryNotes` text DEFAULT NULL AFTER `ApprovedDate`,
ADD COLUMN `DeliveryDate` date DEFAULT NULL AFTER `DeliveryNotes`,
ADD COLUMN `DeliveryStatus` varchar(50) DEFAULT NULL AFTER `DeliveryDate`,
ADD COLUMN `InspectionNotes` text DEFAULT NULL AFTER `DeliveryStatus`,
ADD COLUMN `InspectionDate` datetime DEFAULT NULL AFTER `InspectionNotes`,
ADD COLUMN `InspectionStatus` varchar(50) DEFAULT NULL AFTER `InspectionDate`,
ADD COLUMN `InspectedBy` int(11) DEFAULT NULL AFTER `InspectionStatus`,
ADD COLUMN `FormType` varchar(50) DEFAULT NULL AFTER `InspectedBy`,
ADD COLUMN `FormData` json DEFAULT NULL AFTER `FormType`,
ADD COLUMN `FormSubmitDate` datetime DEFAULT NULL AFTER `FormData`,
ADD COLUMN `FormStatus` varchar(50) DEFAULT NULL AFTER `FormSubmitDate`;

-- Step 3: Create indices for new columns
CREATE INDEX idx_approval_status ON entries(ApprovalStatus);
CREATE INDEX idx_delivery_status ON entries(DeliveryStatus);
CREATE INDEX idx_inspection_status ON entries(InspectionStatus);
CREATE INDEX idx_form_status ON entries(FormStatus);

-- Commit changes
COMMIT;
