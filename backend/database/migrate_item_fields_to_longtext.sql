-- Migration: Alter item_name and description fields to LONGTEXT
-- Date: 2026-05-25
-- Purpose: Support storing multiple items (JSON array) without truncation

ALTER TABLE purchase_requests
MODIFY COLUMN item_name LONGTEXT,
MODIFY COLUMN description LONGTEXT;

-- Verify the changes
-- SELECT COLUMN_NAME, COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
-- WHERE TABLE_NAME='purchase_requests' AND COLUMN_NAME IN ('item_name', 'description');
