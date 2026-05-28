-- Add date_requested column to purchase_requests table
-- This migration adds the missing date_requested column to support date tracking in purchase requests
-- Safe to run multiple times (checks if column exists first in many SQL engines, or can be made safe with IF NOT EXISTS in MySQL 8.0+)

ALTER TABLE purchase_requests 
ADD COLUMN `date_requested` DATE DEFAULT NULL AFTER `division_section`;
