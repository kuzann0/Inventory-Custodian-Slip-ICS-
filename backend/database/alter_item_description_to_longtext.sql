-- Migration: Alter item_name (item description) field to LONGTEXT
-- Date: 2026-05-26
-- Purpose: Support storing multiple item descriptions/JSON arrays without truncation
-- This prevents data loss when storing complex item structures

-- Step 1: Alter item_name from VARCHAR(255) to LONGTEXT
ALTER TABLE purchase_requests
MODIFY COLUMN item_name LONGTEXT COLLATE utf8mb4_unicode_ci;

-- Step 2: Verify the change was successful
-- Run this query to confirm:
-- SELECT COLUMN_NAME, COLUMN_TYPE, CHARACTER_MAXIMUM_LENGTH 
-- FROM INFORMATION_SCHEMA.COLUMNS 
-- WHERE TABLE_NAME='purchase_requests' AND COLUMN_NAME='item_name';

-- Expected result: item_name should show LONGTEXT with no CHARACTER_MAXIMUM_LENGTH limit

-- Step 3: Additional field validation (description is already TEXT, but ensure it's optimal)
ALTER TABLE purchase_requests
MODIFY COLUMN description LONGTEXT COLLATE utf8mb4_unicode_ci;
