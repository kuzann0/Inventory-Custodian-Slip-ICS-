-- Add approver information columns to purchase_requests table
ALTER TABLE `purchase_requests` 
ADD COLUMN `approver_name` VARCHAR(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `approval_notes`,
ADD COLUMN `approver_position` VARCHAR(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `approver_name`,
ADD COLUMN `approver_office` VARCHAR(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `approver_position`;
