-- ============================================================================
-- MIGRATION 003: Add Workflow Step Tracking to Documents and Inspection Tables
-- ============================================================================
-- Purpose: Enable workflow step-specific document and inspection tracking
-- 
-- Changes:
-- - Add workflow_step column to documents table
-- - Add workflow_step column to inspection_assignments table
-- - Add unique constraint to prevent duplicate inspections per step
-- - Add indexes for query optimization
--
-- Risk Level: LOW - Additive changes with default values
-- Rollback: DROP COLUMN workflow_step FROM documents, inspection_assignments;
-- ============================================================================

USE my_app_db;

-- ============================================================================
-- Step 1: Add workflow_step to documents table
-- ============================================================================
-- Purpose: Track which workflow step (1-5) the document belongs to
-- Default: NULL to maintain backward compatibility with existing documents

ALTER TABLE documents
ADD COLUMN workflow_step INT DEFAULT NULL COMMENT 'Workflow step (1-5) this document belongs to: 1=PR, 2=Approval, 3=Delivery, 4=Inspection, 5=Forms',
ADD CONSTRAINT chk_doc_workflow_step CHECK (workflow_step IS NULL OR (workflow_step >= 1 AND workflow_step <= 5));

-- Add index for filtering documents by step
ALTER TABLE documents
ADD INDEX idx_workflow_step (workflow_step),
ADD INDEX idx_pr_id_step (pr_id, workflow_step);

-- ============================================================================
-- Step 2: Add workflow_step to inspection_assignments table
-- ============================================================================
-- Purpose: Track which workflow step each inspection assignment is for
-- Default: 4 (Inspection is always step 4)

ALTER TABLE inspection_assignments
ADD COLUMN workflow_step INT DEFAULT 4 COMMENT 'Workflow step (always 4 for inspection)',
ADD CONSTRAINT chk_inspection_workflow_step CHECK (workflow_step = 4);

-- Add index for filtering inspections by step and PR
ALTER TABLE inspection_assignments
ADD INDEX idx_pr_workflow (pr_id, workflow_step),
ADD INDEX idx_assigned_to_workflow (assigned_to, workflow_step);

-- ============================================================================
-- Step 3: Add unique constraint to prevent duplicate inspections per PR step
-- ============================================================================
-- Purpose: Ensure only one active inspection per PR at step 4
-- This prevents multiple inspectors being assigned to the same approval queue step

ALTER TABLE inspection_assignments
ADD UNIQUE KEY uk_pr_step (pr_id, workflow_step) COMMENT 'One inspection per PR per step';

-- ============================================================================
-- Step 4: Update existing inspection records to step 4 (if not already set)
-- ============================================================================
UPDATE inspection_assignments 
SET workflow_step = 4 
WHERE workflow_step IS NULL OR workflow_step != 4;

-- ============================================================================
-- Step 5: Create audit log for document workflow step updates
-- ============================================================================
-- Optional: Track when documents are assigned to workflow steps

CREATE TABLE IF NOT EXISTS document_workflow_audit (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  document_id INT NOT NULL,
  pr_id INT NOT NULL,
  previous_step INT,
  new_step INT,
  updated_by INT NOT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  reason VARCHAR(255),
  
  KEY idx_document_id (document_id),
  KEY idx_pr_id (pr_id),
  KEY idx_updated_at (updated_at),
  
  FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE,
  FOREIGN KEY (pr_id) REFERENCES purchase_requests(id) ON DELETE CASCADE,
  FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Audit trail for document workflow step assignments';

-- ============================================================================
-- Verification Queries
-- ============================================================================
-- SELECT COUNT(*) as inspections FROM inspection_assignments;
-- SELECT COUNT(DISTINCT pr_id) as prs_with_inspections FROM inspection_assignments WHERE workflow_step = 4;
-- SHOW COLUMNS FROM documents LIKE '%workflow%';
-- SHOW COLUMNS FROM inspection_assignments LIKE '%workflow%';

-- ============================================================================
-- End Migration 003
-- ============================================================================
