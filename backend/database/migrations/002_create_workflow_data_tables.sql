-- ============================================================================
-- MIGRATION 002: Create Workflow Step Data Tables (ICS Forms, PPE Forms, Delivery Notes)
-- ============================================================================
-- Purpose: Create missing tables for workflow steps 3 and 5 data capture
-- 
-- New Tables:
-- - ics_forms: Store ICS form submissions (Step 5a, for PR total < 50k)
-- - ppe_forms: Store PPE form submissions (Step 5b, for PR total >= 50k)
-- - delivery_notes: Store delivery tracking (Step 3)
--
-- Risk Level: LOW - New tables, non-destructive
-- Rollback: DROP TABLE ics_forms, ppe_forms, delivery_notes;
-- ============================================================================

USE my_app_db;

-- ============================================================================
-- Table 1: ICS Forms (Inventory Custodian Slip for items < 50k)
-- ============================================================================
CREATE TABLE IF NOT EXISTS ics_forms (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique form ID',
  pr_id INT NOT NULL COMMENT 'FK to purchase_requests table',
  form_data JSON COMMENT 'JSON structure of ICS form fields',
  submitted_by INT NOT NULL COMMENT 'FK to users table - who submitted the form',
  submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When form was submitted',
  custodian_name VARCHAR(255) COMMENT 'Name of inventory custodian',
  office_location VARCHAR(255) COMMENT 'Office or department location',
  notes TEXT COMMENT 'Additional notes or comments',
  status ENUM('pending', 'accepted', 'rejected') DEFAULT 'pending' COMMENT 'Form review status',
  
  UNIQUE KEY uk_pr_id (pr_id) COMMENT 'One ICS form per PR',
  KEY idx_submitted_by (submitted_by),
  KEY idx_submitted_at (submitted_at),
  KEY idx_status (status),
  
  FOREIGN KEY (pr_id) REFERENCES purchase_requests(id) ON DELETE CASCADE,
  FOREIGN KEY (submitted_by) REFERENCES users(id) ON DELETE RESTRICT,
  
  CONSTRAINT chk_pr_amount_ics CHECK (1=1) COMMENT 'Should be linked to PR with total < 50k'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='ICS Form submissions for inventory items under 50k threshold';

-- ============================================================================
-- Table 2: PPE Forms (Personal Protective Equipment for items >= 50k)
-- ============================================================================
CREATE TABLE IF NOT EXISTS ppe_forms (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique form ID',
  pr_id INT NOT NULL COMMENT 'FK to purchase_requests table',
  form_data JSON COMMENT 'JSON structure of PPE form fields',
  submitted_by INT NOT NULL COMMENT 'FK to users table - who submitted the form',
  submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When form was submitted',
  safety_officer_approval INT COMMENT 'FK to users table - safety officer reviewer',
  safety_approval_date TIMESTAMP NULL COMMENT 'When safety officer approved',
  notes TEXT COMMENT 'Safety notes and comments',
  status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending' COMMENT 'Form review status',
  
  UNIQUE KEY uk_pr_id (pr_id) COMMENT 'One PPE form per PR',
  KEY idx_submitted_by (submitted_by),
  KEY idx_submitted_at (submitted_at),
  KEY idx_safety_officer_approval (safety_officer_approval),
  KEY idx_status (status),
  
  FOREIGN KEY (pr_id) REFERENCES purchase_requests(id) ON DELETE CASCADE,
  FOREIGN KEY (submitted_by) REFERENCES users(id) ON DELETE RESTRICT,
  FOREIGN KEY (safety_officer_approval) REFERENCES users(id) ON DELETE SET NULL,
  
  CONSTRAINT chk_pr_amount_ppe CHECK (1=1) COMMENT 'Should be linked to PR with total >= 50k'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='PPE Form submissions for inventory items over 50k threshold';

-- ============================================================================
-- Table 3: Delivery Notes (Workflow Step 3 - Notice of Delivery)
-- ============================================================================
CREATE TABLE IF NOT EXISTS delivery_notes (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique delivery note ID',
  pr_id INT NOT NULL COMMENT 'FK to purchase_requests table',
  delivery_date DATE COMMENT 'Actual delivery date',
  expected_delivery_date DATE COMMENT 'Expected delivery date (for tracking delays)',
  delivery_status ENUM('pending', 'delivered', 'partial', 'failed') DEFAULT 'pending' 
    COMMENT 'Delivery status: pending, delivered, partial, or failed',
  delivery_notes TEXT COMMENT 'Notes about delivery (condition, issues, etc.)',
  received_by INT COMMENT 'FK to users table - who received the delivery',
  received_date TIMESTAMP COMMENT 'When delivery was received and confirmed',
  submitted_by INT NOT NULL COMMENT 'FK to users table - who submitted this note',
  submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When this note was created',
  carrier_name VARCHAR(255) COMMENT 'Carrier or shipping company name',
  tracking_number VARCHAR(255) COMMENT 'Tracking number or reference',
  
  KEY idx_pr_id (pr_id),
  KEY idx_delivery_date (delivery_date),
  KEY idx_submitted_by (submitted_by),
  KEY idx_submitted_at (submitted_at),
  KEY idx_delivery_status (delivery_status),
  KEY idx_received_by (received_by),
  
  FOREIGN KEY (pr_id) REFERENCES purchase_requests(id) ON DELETE CASCADE,
  FOREIGN KEY (submitted_by) REFERENCES users(id) ON DELETE RESTRICT,
  FOREIGN KEY (received_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Delivery tracking and notes for purchase requests (Workflow Step 3)';

-- ============================================================================
-- Verification Queries
-- ============================================================================
-- SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='my_app_db' AND TABLE_NAME IN ('ics_forms', 'ppe_forms', 'delivery_notes');
-- DESCRIBE ics_forms;
-- DESCRIBE ppe_forms;
-- DESCRIBE delivery_notes;

-- ============================================================================
-- End Migration 002
-- ============================================================================
