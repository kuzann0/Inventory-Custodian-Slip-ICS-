# Item Description Migration - Step 1: Purchase Request

## Summary
Altering the `item_name` column in the `purchase_requests` table from `VARCHAR(255)` to `LONGTEXT` to support storing complex item descriptions and JSON arrays without truncation.

## Changes Made

### 1. SQL Migration File
**File:** `backend/database/alter_item_description_to_longtext.sql`

```sql
-- Alter item_name from VARCHAR(255) to LONGTEXT
ALTER TABLE purchase_requests
MODIFY COLUMN item_name LONGTEXT COLLATE utf8mb4_unicode_ci;

-- Also update description for consistency
ALTER TABLE purchase_requests
MODIFY COLUMN description LONGTEXT COLLATE utf8mb4_unicode_ci;
```

### 2. PHP Migration Script
**File:** `backend/migrate_item_description.php`

Automated script to apply the migration via HTTP request.

## How to Apply

### Option 1: Direct HTTP Request (Recommended)
```bash
curl -X GET http://localhost:8086/migrate_item_description.php
```

Expected response:
```json
{
  "success": true,
  "message": "Migration completed successfully",
  "columns_altered": {
    "item_name": "longtext",
    "description": "longtext"
  }
}
```

### Option 2: MySQL CLI
```bash
mysql -h db -u root -p my_app_db < backend/database/alter_item_description_to_longtext.sql
```

### Option 3: phpMyAdmin
1. Go to `http://localhost:8086/phpmyadmin`
2. Select database `my_app_db`
3. Select table `purchase_requests`
4. Go to "Structure" tab
5. Click "Edit" on `item_name` column
6. Change Type from `VARCHAR(255)` to `LONGTEXT`
7. Click "Save"

## Database Changes

### Before
- `item_name`: VARCHAR(255) - Limited to 255 characters
- `description`: TEXT - Limited to 65,535 characters

### After
- `item_name`: LONGTEXT - Up to 4GB (practical limit ~1-2MB per item)
- `description`: LONGTEXT - Up to 4GB

## Impact
- ✅ Supports storing multiple items as JSON arrays
- ✅ No data loss from truncation
- ✅ Maintains backward compatibility
- ✅ PurchaseRequest.jsx can now send complex item structures

## Verification
To verify the migration was successful, run:
```sql
SELECT COLUMN_NAME, COLUMN_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME='purchase_requests' 
AND COLUMN_NAME IN ('item_name', 'description');
```

Expected result:
| COLUMN_NAME | COLUMN_TYPE |
|---|---|
| item_name | longtext |
| description | longtext |

## Related Files
- Frontend: `frontend/src/PurchaseRequest.jsx` - Already sends item arrays to `item_name`
- Backend: `backend/submit_purchase_request.php` - Receives and stores item data
