-- =====================================================
-- DYNAMIC DATA BINDING MIGRATION SCRIPT
-- =====================================================
-- 
-- This migration adds tables and columns to support
-- dynamic data binding for the purchase request workflow.
-- 
-- IMPORTANT: This is non-destructive. Existing tables
-- and data are preserved.
--
-- Created: 2026-04-27
-- Purpose: Centralize data management via entries table
-- =====================================================

-- =====================================================
-- 1. EXTEND entries TABLE - Add workflow fields
-- =====================================================
-- (Non-destructive: only adding new columns)

ALTER TABLE entries ADD COLUMN IF NOT EXISTS `ApprovalStatus` VARCHAR(50) DEFAULT NULL COMMENT 'Approval status (pending, approved, rejected)';
ALTER TABLE entries ADD COLUMN IF NOT EXISTS `ApprovedBy` INT(11) DEFAULT NULL COMMENT 'User ID who approved';
ALTER TABLE entries ADD COLUMN IF NOT EXISTS `ApprovedDate` TIMESTAMP NULL DEFAULT NULL COMMENT 'When approved';

ALTER TABLE entries ADD COLUMN IF NOT EXISTS `DeliveryNotes` TEXT DEFAULT NULL COMMENT 'Delivery notes from Step 3';
ALTER TABLE entries ADD COLUMN IF NOT EXISTS `DeliveryDate` DATE DEFAULT NULL COMMENT 'Expected delivery date';
ALTER TABLE entries ADD COLUMN IF NOT EXISTS `DeliveryStatus` VARCHAR(50) DEFAULT NULL COMMENT 'Delivery status (pending, in_transit, delivered)';
ALTER TABLE entries ADD COLUMN IF NOT EXISTS `ActualDeliveryDate` DATE DEFAULT NULL COMMENT 'Actual delivery date';

ALTER TABLE entries ADD COLUMN IF NOT EXISTS `InspectionNotes` TEXT DEFAULT NULL COMMENT 'Inspection notes from Step 4';
ALTER TABLE entries ADD COLUMN IF NOT EXISTS `InspectionDate` TIMESTAMP NULL DEFAULT NULL COMMENT 'When inspection was performed';
ALTER TABLE entries ADD COLUMN IF NOT EXISTS `InspectionStatus` VARCHAR(50) DEFAULT NULL COMMENT 'Inspection status (pending, in_progress, completed, rejected)';
ALTER TABLE entries ADD COLUMN IF NOT EXISTS `InspectedBy` INT(11) DEFAULT NULL COMMENT 'User ID who performed inspection';

ALTER TABLE entries ADD COLUMN IF NOT EXISTS `FormType` VARCHAR(50) DEFAULT NULL COMMENT 'Form type (ics, ppe, none)';
ALTER TABLE entries ADD COLUMN IF NOT EXISTS `FormData` JSON DEFAULT NULL COMMENT 'Complete form data from Step 5';
ALTER TABLE entries ADD COLUMN IF NOT EXISTS `FormSubmitDate` TIMESTAMP NULL DEFAULT NULL COMMENT 'When form was submitted';
ALTER TABLE entries ADD COLUMN IF NOT EXISTS `FormStatus` VARCHAR(50) DEFAULT NULL COMMENT 'Form status (pending, completed, rejected)';

ALTER TABLE entries ADD COLUMN IF NOT EXISTS `PrId` INT(11) DEFAULT NULL COMMENT 'Reference to purchase_requests.id for backward compatibility';
ALTER TABLE entries ADD COLUMN IF NOT EXISTS `WorkflowStep` INT(1) DEFAULT 1 COMMENT 'Current workflow step (1-5)';

-- =====================================================
-- 2. CREATE entry_workflow_status TABLE - Workflow tracking
-- =====================================================

CREATE TABLE IF NOT EXISTS `entry_workflow_status` (
  `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'Workflow status ID',
  `entry_id` INT(11) NOT NULL COMMENT 'Foreign key to entries table',
  `pr_id` INT(11) DEFAULT NULL COMMENT 'Foreign key to purchase_requests table',
  `pr_no` VARCHAR(100) NOT NULL COMMENT 'Purchase request number',
  
  -- Step tracking
  `current_step` INT(1) DEFAULT 1 COMMENT 'Current workflow step (1-5)',
  `step_1_completed` TINYINT(1) DEFAULT 0 COMMENT 'Step 1 (Purchase Request) complete',
  `step_2_completed` TINYINT(1) DEFAULT 0 COMMENT 'Step 2 (Approval) complete',
  `step_3_completed` TINYINT(1) DEFAULT 0 COMMENT 'Step 3 (Notice of Delivery) complete',
  `step_4_completed` TINYINT(1) DEFAULT 0 COMMENT 'Step 4 (Inspection & Acceptance) complete',
  `step_5_completed` TINYINT(1) DEFAULT 0 COMMENT 'Step 5 (Conditional Form) complete',
  
  -- Step data (JSON storage)
  `step_1_data` JSON COMMENT 'Step 1 data snapshot',
  `step_2_data` JSON COMMENT 'Step 2 data snapshot',
  `step_3_data` JSON COMMENT 'Step 3 data snapshot',
  `step_4_data` JSON COMMENT 'Step 4 data snapshot',
  `step_5_data` JSON COMMENT 'Step 5 data snapshot',
  
  -- Metadata
  `created_by` INT(11) DEFAULT NULL COMMENT 'User who created workflow',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_pr_id` (`pr_id`),
  UNIQUE KEY `unique_entry_id` (`entry_id`),
  KEY `idx_pr_no` (`pr_no`),
  KEY `idx_current_step` (`current_step`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_entry_workflow_entry` FOREIGN KEY (`entry_id`) REFERENCES `entries` (`order_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_entry_workflow_pr` FOREIGN KEY (`pr_id`) REFERENCES `purchase_requests` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Centralized workflow status tracking linked to entries table';

-- =====================================================
-- 3. CREATE entry_step_mapping TABLE - Dynamic field mapping
-- =====================================================
-- This table allows dynamic configuration of which entry
-- fields map to which workflow steps, making the system
-- more flexible for future changes

CREATE TABLE IF NOT EXISTS `entry_step_mapping` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `step_number` INT(1) NOT NULL COMMENT 'Workflow step (1-5)',
  `entry_field` VARCHAR(100) NOT NULL COMMENT 'Column name in entries table',
  `field_label` VARCHAR(255) COMMENT 'Human-readable label',
  `field_type` VARCHAR(50) COMMENT 'Data type (text, number, date, json, etc)',
  `is_required` TINYINT(1) DEFAULT 0,
  `validation_rules` JSON COMMENT 'Validation rules',
  `description` TEXT COMMENT 'Field description',
  `active` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_step_field` (`step_number`, `entry_field`),
  KEY `idx_step_number` (`step_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Maps workflow steps to entry table columns for dynamic binding';

-- =====================================================
-- 4. POPULATE entry_step_mapping - Configure field bindings
-- =====================================================

INSERT INTO entry_step_mapping (step_number, entry_field, field_label, field_type, is_required, description) VALUES
-- Step 1: Purchase Request
(1, 'Item', 'Item Name', 'text', 1, 'Name of the item being purchased'),
(1, 'Quantity', 'Quantity', 'number', 1, 'Quantity of items'),
(1, 'Unit', 'Unit of Measure', 'text', 1, 'Unit (set, units, boxes, etc)'),
(1, 'UnitCost', 'Unit Cost', 'number', 1, 'Cost per unit'),
(1, 'TotalCost', 'Total Cost', 'number', 1, 'Total cost (auto-calculated)'),
(1, 'Description', 'Description', 'text', 0, 'Additional description'),
(1, 'Location', 'Office/Location', 'text', 1, 'Office or location'),
(1, 'DateAcquired', 'Date Acquired', 'date', 0, 'Date of acquisition'),

-- Step 2: Approval
(2, 'ApprovalStatus', 'Status', 'text', 1, 'Approval status'),
(2, 'ApprovedBy', 'Approved By', 'number', 1, 'User ID of approver'),
(2, 'ApprovedDate', 'Approval Date', 'date', 1, 'Date of approval'),

-- Step 3: Notice of Delivery
(3, 'DeliveryNotes', 'Delivery Notes', 'text', 1, 'Delivery notes'),
(3, 'DeliveryDate', 'Expected Delivery Date', 'date', 1, 'Expected delivery date'),
(3, 'DeliveryStatus', 'Delivery Status', 'text', 1, 'Delivery status'),
(3, 'ActualDeliveryDate', 'Actual Delivery Date', 'date', 0, 'Actual delivery date'),

-- Step 4: Inspection & Acceptance
(4, 'InspectionNotes', 'Inspection Notes', 'text', 1, 'Inspection findings'),
(4, 'InspectionDate', 'Inspection Date', 'date', 1, 'Date of inspection'),
(4, 'InspectionStatus', 'Inspection Status', 'text', 1, 'Inspection result'),
(4, 'InspectedBy', 'Inspected By', 'number', 1, 'User ID of inspector'),

-- Step 5: Conditional Form (ICS/PPE)
(5, 'FormType', 'Form Type', 'text', 1, 'ICS or PPE'),
(5, 'FormData', 'Form Data', 'json', 1, 'Complete form submission'),
(5, 'FormStatus', 'Form Status', 'text', 1, 'Form submission status');

-- =====================================================
-- 5. CREATE workflow_data_binding VIEW - Real-time binding view
-- =====================================================
-- This view provides real-time access to bound data across
-- all workflow steps, making it easy for frontend to fetch
-- complete workflow state

CREATE OR REPLACE VIEW workflow_data_binding AS
SELECT 
  e.order_id as entry_id,
  e.Item,
  e.Quantity,
  e.Unit,
  e.UnitCost,
  e.TotalCost,
  e.Description,
  e.Location,
  e.DateAcquired,
  
  -- Approval Step Fields
  e.ApprovalStatus,
  e.ApprovedBy,
  e.ApprovedDate,
  
  -- Delivery Step Fields
  e.DeliveryNotes,
  e.DeliveryDate,
  e.DeliveryStatus,
  e.ActualDeliveryDate,
  
  -- Inspection Step Fields
  e.InspectionNotes,
  e.InspectionDate,
  e.InspectionStatus,
  e.InspectedBy,
  
  -- Form Step Fields
  e.FormType,
  e.FormData,
  e.FormSubmitDate,
  e.FormStatus,
  
  -- Workflow Status
  ews.pr_no,
  ews.pr_id,
  ews.current_step,
  ews.step_1_completed,
  ews.step_2_completed,
  ews.step_3_completed,
  ews.step_4_completed,
  ews.step_5_completed,
  
  -- Purchase Request Reference
  pr.status as pr_status,
  pr.form_type as pr_form_type,
  pr.created_at as pr_created_at
  
FROM entries e
LEFT JOIN entry_workflow_status ews ON e.order_id = ews.entry_id
LEFT JOIN purchase_requests pr ON ews.pr_id = pr.id;

-- =====================================================
-- 6. CREATE INDEXES for performance
-- =====================================================

ALTER TABLE entries ADD INDEX IF NOT EXISTS `idx_pr_id` (`PrId`);
ALTER TABLE entries ADD INDEX IF NOT EXISTS `idx_workflow_step` (`WorkflowStep`);
ALTER TABLE entries ADD INDEX IF NOT EXISTS `idx_approval_status` (`ApprovalStatus`);
ALTER TABLE entries ADD INDEX IF NOT EXISTS `idx_form_type` (`FormType`);
ALTER TABLE entry_workflow_status ADD INDEX IF NOT EXISTS `idx_entry_pr` (`entry_id`, `pr_id`);

-- =====================================================
-- 7. Create audit trail for data binding changes
-- =====================================================

CREATE TABLE IF NOT EXISTS `entry_binding_audit` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `entry_id` INT(11) NOT NULL,
  `step_number` INT(1) NOT NULL,
  `action` VARCHAR(50) COMMENT 'insert, update, delete',
  `field_changed` VARCHAR(100) COMMENT 'Which field changed',
  `old_value` LONGTEXT COMMENT 'Previous value',
  `new_value` LONGTEXT COMMENT 'New value',
  `changed_by` INT(11),
  `changed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  PRIMARY KEY (`id`),
  KEY `idx_entry_id` (`entry_id`),
  KEY `idx_step_number` (`step_number`),
  KEY `idx_changed_at` (`changed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Audit trail for entry data binding changes';

-- =====================================================
-- 8. VERIFICATION QUERIES
-- =====================================================
-- Run these to verify the migration was successful:

-- Check new columns in entries table:
-- SELECT COLUMN_NAME, COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='entries';

-- Check new tables created:
-- SHOW TABLES LIKE 'entry_%';

-- Check the workflow_data_binding view:
-- SELECT * FROM workflow_data_binding LIMIT 1;

-- =====================================================
-- END OF MIGRATION
-- =====================================================
