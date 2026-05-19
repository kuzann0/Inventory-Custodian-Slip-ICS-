-- ============================================================================
-- MIGRATION 004: Add Authorization & Audit Improvements
-- ============================================================================
-- Purpose: Enhance authorization enforcement and audit logging
-- 
-- Changes:
-- - Create login_rate_limit table for brute-force protection
-- - Rename audit_logs.admin_id to user_id for semantic clarity
-- - Add entries creation audit logging table
-- - Add workflow state audit table
-- - Add proper indexes and constraints
--
-- Risk Level: MEDIUM - Alters existing table structure (RENAME)
-- Rollback: Requires careful rollback of column rename
-- ============================================================================

USE my_app_db;

-- ============================================================================
-- Step 1: Create login rate limiting table
-- ============================================================================
-- Purpose: Implement brute-force protection on login endpoint

CREATE TABLE IF NOT EXISTS login_rate_limit (
  ip_address VARCHAR(45) PRIMARY KEY COMMENT 'IP address of login attempt',
  attempt_count INT DEFAULT 1 COMMENT 'Number of failed login attempts',
  last_attempt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 
    COMMENT 'Timestamp of last attempt',
  locked_until TIMESTAMP NULL COMMENT 'Until when this IP is locked (nullable)',
  
  KEY idx_last_attempt (last_attempt),
  KEY idx_locked_until (locked_until)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Track login attempts per IP for brute-force protection';

-- ============================================================================
-- Step 2: Enhance audit_logs table - Rename admin_id to user_id
-- ============================================================================
-- Purpose: More semantically correct - any user action can be logged, not just admins

-- First, check if column exists and rename
ALTER TABLE audit_logs 
CHANGE COLUMN admin_id user_id INT COMMENT 'FK to users table - who performed the action';

-- Ensure FK constraint is updated
ALTER TABLE audit_logs
DROP FOREIGN KEY audit_logs_ibfk_1;

ALTER TABLE audit_logs
ADD CONSTRAINT fk_audit_logs_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;

-- ============================================================================
-- Step 3: Create entry creation audit log table
-- ============================================================================
-- Purpose: Specific audit trail for inventory entry creation and modifications

CREATE TABLE IF NOT EXISTS entry_audit_log (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  entry_id INT NOT NULL COMMENT 'FK to entries table',
  action ENUM('CREATE', 'UPDATE', 'DELETE', 'VIEW') NOT NULL COMMENT 'Action performed',
  action_details JSON COMMENT 'Details of the action (old values, new values, etc.)',
  user_id INT NOT NULL COMMENT 'FK to users table - who performed action',
  ip_address VARCHAR(45) COMMENT 'IP address of user',
  user_agent TEXT COMMENT 'User agent string',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  KEY idx_entry_id (entry_id),
  KEY idx_user_id (user_id),
  KEY idx_action (action),
  KEY idx_created_at (created_at),
  
  FOREIGN KEY (entry_id) REFERENCES entries(order_id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Detailed audit trail for inventory entry operations';

-- ============================================================================
-- Step 4: Create workflow state transition audit table
-- ============================================================================
-- Purpose: Track all state transitions in purchase request workflow

CREATE TABLE IF NOT EXISTS workflow_state_audit (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  pr_id INT NOT NULL COMMENT 'FK to purchase_requests table',
  approval_level INT COMMENT 'Which approval level (1, 2, 3, etc.)',
  previous_status VARCHAR(50) COMMENT 'Status before transition (pending, approved, rejected, expired)',
  new_status VARCHAR(50) COMMENT 'Status after transition',
  action_by INT NOT NULL COMMENT 'FK to users table - who made the transition',
  reason TEXT COMMENT 'Reason for state change (approval reason, rejection reason, etc.)',
  ip_address VARCHAR(45),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  KEY idx_pr_id (pr_id),
  KEY idx_approval_level (approval_level),
  KEY idx_created_at (created_at),
  KEY idx_action_by (action_by),
  
  FOREIGN KEY (pr_id) REFERENCES purchase_requests(id) ON DELETE CASCADE,
  FOREIGN KEY (action_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Audit trail for PR workflow state machine transitions';

-- ============================================================================
-- Step 5: Create document upload audit table
-- ============================================================================
-- Purpose: Track all document uploads and modifications

CREATE TABLE IF NOT EXISTS document_audit_log (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  document_id INT NOT NULL COMMENT 'FK to documents table',
  action ENUM('UPLOAD', 'VERIFY', 'DOWNLOAD', 'DELETE') NOT NULL,
  uploaded_by INT COMMENT 'FK to users - uploader',
  verified_by INT COMMENT 'FK to users - who verified',
  file_size INT COMMENT 'File size in bytes',
  file_hash VARCHAR(64) COMMENT 'SHA256 hash of file for integrity check',
  ip_address VARCHAR(45),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  KEY idx_document_id (document_id),
  KEY idx_action (action),
  KEY idx_created_at (created_at),
  
  FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE,
  FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Audit trail for document management operations';

-- ============================================================================
-- Step 6: Add workflow_status tracking to purchase_requests
-- ============================================================================
-- Purpose: Add current workflow status to PR table for quick queries

ALTER TABLE purchase_requests
ADD COLUMN current_workflow_step INT DEFAULT 1 COMMENT 'Current step in 5-step workflow (1-5)',
ADD COLUMN workflow_started_at TIMESTAMP COMMENT 'When workflow started',
ADD COLUMN last_status_change TIMESTAMP COMMENT 'When last state change occurred',
ADD INDEX idx_current_step (current_workflow_step),
ADD INDEX idx_workflow_started_at (workflow_started_at);

-- ============================================================================
-- Step 7: Create admin bypass audit table
-- ============================================================================
-- Purpose: Enhanced audit for admin bypass events

CREATE TABLE IF NOT EXISTS admin_bypass_audit (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  admin_id INT NOT NULL COMMENT 'FK to users - admin performing bypass',
  bypassed_user_id INT COMMENT 'FK to users - user being bypassed to',
  bypassed_user_email VARCHAR(255) COMMENT 'Email of bypassed user (for reference)',
  verification_status ENUM('pending', 'verified', 'rejected') DEFAULT 'pending',
  ip_address VARCHAR(45),
  user_agent TEXT,
  reason TEXT COMMENT 'Admin-provided reason for bypass',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  KEY idx_admin_id (admin_id),
  KEY idx_created_at (created_at),
  KEY idx_verification_status (verification_status),
  
  FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (bypassed_user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Enhanced audit trail for admin bypass events';

-- ============================================================================
-- Verification Queries
-- ============================================================================
-- SELECT COUNT(*) FROM login_rate_limit;
-- SELECT COUNT(*) FROM entry_audit_log;
-- SELECT COUNT(*) FROM workflow_state_audit;
-- SHOW COLUMNS FROM purchase_requests LIKE '%workflow%';

-- ============================================================================
-- End Migration 004
-- ============================================================================
