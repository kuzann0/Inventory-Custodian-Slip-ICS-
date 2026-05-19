-- ============================================================================
-- MIGRATION 001: Add User Tracking to Inventory Entries Table
-- ============================================================================
-- Purpose: Add created_by and created_at columns to entries table for audit trail
-- 
-- Changes:
-- - Add created_by INT column with FK to users.id
-- - Add created_at TIMESTAMP column with default CURRENT_TIMESTAMP
-- - Add indexes for query performance
-- - Convert entries table charset to utf8mb4 for consistency
--
-- Risk Level: LOW - Additive changes, non-destructive
-- Rollback: Possible - drop columns if needed
-- ============================================================================

USE my_app_db;

-- Step 1: Add created_by column (Foreign Key to users table)
ALTER TABLE entries 
ADD COLUMN created_by INT,
ADD CONSTRAINT fk_entries_created_by FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

-- Step 2: Add created_at timestamp column
ALTER TABLE entries 
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Step 3: Add indexes for better query performance
ALTER TABLE entries 
ADD INDEX idx_created_by (created_by),
ADD INDEX idx_created_at (created_at),
ADD INDEX idx_created_by_created_at (created_by, created_at);

-- Step 4: Convert entries table to utf8mb4 charset for Unicode support and consistency
ALTER TABLE entries 
CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Step 5: Update existing entries (set created_by to default user if needed for data integrity)
-- Uncomment this if you want to assign existing entries to a default user (e.g., super-admin with id=1)
-- UPDATE entries SET created_by = 1 WHERE created_by IS NULL;
-- Or set to NULL to indicate unknown creator (better for audit purposes)

-- Verification queries (run after migration to verify)
-- SELECT COUNT(*) as entries_with_creator FROM entries WHERE created_by IS NOT NULL;
-- SELECT COUNT(*) as entries_without_creator FROM entries WHERE created_by IS NULL;
-- SHOW COLUMNS FROM entries;

-- ============================================================================
-- End Migration 001
-- ============================================================================
