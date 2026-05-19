# Migration Deployment Guide

## Overview

This directory contains SQL migration scripts for implementing Priority 1 data integrity fixes to the ICS system. All migrations are non-destructive and can be deployed independently or sequentially.

## Migration Files

### 001_add_user_tracking_to_entries.sql
**Purpose:** Add user attribution to inventory entries

**Changes:**
- Add `created_by` column (FK to users.id)
- Add `created_at` timestamp
- Add indexes for query performance
- Convert entries table to utf8mb4 charset

**Risk Level:** LOW
**Deployment Time:** < 1 second
**Rollback:** `ALTER TABLE entries DROP COLUMN created_by, DROP COLUMN created_at;`

**Why Critical:**
- Enables audit trail for entry creation
- Allows filtering entries by creator
- Required for compliance/traceability

---

### 002_create_workflow_data_tables.sql
**Purpose:** Create missing workflow step data capture tables

**New Tables:**
- `ics_forms` - ICS form submissions (Step 5a, PR total < 50k)
- `ppe_forms` - PPE form submissions (Step 5b, PR total >= 50k)
- `delivery_notes` - Delivery tracking (Step 3)

**Risk Level:** LOW
**Deployment Time:** < 1 second
**Rollback:** `DROP TABLE ics_forms, ppe_forms, delivery_notes;`

**Why Critical:**
- Provides persistent storage for form submissions
- Enables workflow step 3 (delivery) and step 5 (forms) completion
- Prevents data loss when users submit forms

---

### 003_add_workflow_step_tracking.sql
**Purpose:** Add workflow step-specific document and inspection tracking

**Changes:**
- Add `workflow_step` column to documents table
- Add `workflow_step` column to inspection_assignments table
- Add unique constraint to prevent duplicate inspections per step
- Create audit table for document workflow step changes

**Risk Level:** LOW
**Deployment Time:** < 1 second
**Rollback:** `ALTER TABLE documents DROP COLUMN workflow_step; ALTER TABLE inspection_assignments DROP COLUMN workflow_step;`

**Why Critical:**
- Enables enforcement of step-specific document requirements
- Prevents mixing documents from different workflow phases
- Improves workflow integrity validation

---

### 004_add_authorization_and_audit_improvements.sql
**Purpose:** Enhance authorization and audit logging

**New Tables/Changes:**
- `login_rate_limit` - Brute-force protection
- `entry_audit_log` - Entry creation/modification audit trail
- `workflow_state_audit` - Workflow state transition audit
- `document_audit_log` - Document upload audit trail
- `admin_bypass_audit` - Admin bypass event tracking
- Rename `audit_logs.admin_id` → `audit_logs.user_id`

**Risk Level:** MEDIUM (column rename)
**Deployment Time:** 1-5 seconds (depends on table size)
**Rollback:** Requires data migration script

**Why Important:**
- Implements brute-force protection
- Improves audit trail completeness and accuracy
- Better semantic clarity (user_id instead of admin_id)

---

### 005_add_capability_and_session_improvements.sql
**Purpose:** Enhance capability expiration and session security

**New Tables:**
- `active_sessions` - Explicit session store
- `session_config` - Session configuration
- `capability_expiration_log` - Expiration enforcement tracking
- `capability_renewal_log` - Capability renewal history
- `session_regeneration_log` - Session ID regeneration audit
- `password_change_log` - Password change audit

**Risk Level:** LOW
**Deployment Time:** < 1 second
**Rollback:** `DROP TABLE active_sessions, capability_expiration_log, etc.;`

**Why Important:**
- Enables capability expiration enforcement
- Improves session security with explicit tracking
- Provides password security audit trail

---

## Deployment Instructions

### Prerequisites
- Backup current database: `mysqldump my_app_db > backup_before_migrations.sql`
- Database credentials and access to `my_app_db`
- MySQL client or access to phpMyAdmin

### Option 1: Sequential Deployment (Recommended for first-time)

```bash
# Execute each migration in order
mysql -h localhost -u root -prootpassword my_app_db < 001_add_user_tracking_to_entries.sql
mysql -h localhost -u root -prootpassword my_app_db < 002_create_workflow_data_tables.sql
mysql -h localhost -u root -prootpassword my_app_db < 003_add_workflow_step_tracking.sql
mysql -h localhost -u root -prootpassword my_app_db < 004_add_authorization_and_audit_improvements.sql
mysql -h localhost -u root -prootpassword my_app_db < 005_add_capability_and_session_improvements.sql
```

### Option 2: Combined Deployment (Production-style)

```bash
# Create a combined migration file
cat 001_*.sql 002_*.sql 003_*.sql 004_*.sql 005_*.sql > COMBINED_MIGRATIONS.sql

# Deploy as single transaction
mysql -h localhost -u root -prootpassword my_app_db < COMBINED_MIGRATIONS.sql
```

### Option 3: Docker Deployment

If using Docker Compose:

```bash
# Copy migration files to container
docker cp 001_*.sql ics-mysql:/migrations/

# Execute inside container
docker exec ics-mysql mysql -u root -prootpassword my_app_db < 001_*.sql
```

---

## Verification Checklist

After deployment, verify each migration:

### 001 - User Tracking
```sql
SHOW COLUMNS FROM entries LIKE '%created%';
SELECT COUNT(*) FROM entries WHERE created_by IS NOT NULL;
```

### 002 - Workflow Tables
```sql
SHOW TABLES LIKE '%forms%';
SHOW TABLES LIKE '%delivery%';
DESCRIBE ics_forms;
DESCRIBE ppe_forms;
DESCRIBE delivery_notes;
```

### 003 - Workflow Step Tracking
```sql
SHOW COLUMNS FROM documents LIKE '%workflow%';
SHOW COLUMNS FROM inspection_assignments LIKE '%workflow%';
```

### 004 - Authorization & Audit
```sql
SHOW TABLES LIKE '%audit%';
SHOW TABLES LIKE 'login_rate%';
SELECT COUNT(*) FROM session_config;
```

### 005 - Capability & Session
```sql
SHOW TABLES LIKE 'active_sessions';
SHOW TABLES LIKE 'capability_%';
SELECT COUNT(*) FROM session_config;
```

---

## Backend Code Changes Required

After migrations are deployed, the following backend code files must be updated to use new tables:

### For Migration 001:
- **`submit.php`** - Update to capture `created_by` from `$_SESSION['user_id']`
- **`get_entries.php`** - Can now filter by `created_by` at SQL level

### For Migration 002:
- **`submit_ics_form.php`** - INSERT into `ics_forms` table
- **`submit_ppe_form.php`** - INSERT into `ppe_forms` table
- **`submit_delivery_notes.php`** - INSERT into `delivery_notes` table

### For Migration 003:
- **`upload_document.php`** - Accept and validate `workflow_step` parameter
- **`submit_inspection.php`** - Set `workflow_step = 4`

### For Migration 004:
- **`login.php`** - Call rate limit checks, update `login_rate_limit` table
- **`submit.php`** - Log to `entry_audit_log`
- **`approve_purchase_request.php`** - Log to `workflow_state_audit`

### For Migration 005:
- **`login.php`** - Call session regeneration, update `active_sessions`
- **`get_user_capabilities.php`** - Filter by `expires_at > NOW()`
- **`grant_capability.php`** - Track in `capability_renewal_log`

---

## Performance Considerations

### Indexes Added
- entries: `idx_created_by`, `idx_created_at`, `idx_created_by_created_at`
- documents: `idx_workflow_step`, `idx_pr_id_step`
- inspection_assignments: `idx_pr_workflow`, `idx_assigned_to_workflow`
- user_capabilities: `idx_expires_at`, `idx_user_expires`

**Expected Query Performance Impact:** Positive (5-10x faster filtered queries)

### Table Size Impact
- New tables combined: ~1-5 MB initially
- Growth rate: Depends on volume of auditing

---

## Rollback Procedures

If any migration needs to be rolled back:

### Partial Rollback (Single Migration)
```bash
# Create rollback script
mysql -h localhost -u root -prootpassword my_app_db << EOF
  ALTER TABLE entries DROP FOREIGN KEY fk_entries_created_by;
  ALTER TABLE entries DROP COLUMN created_by, DROP COLUMN created_at;
EOF
```

### Complete Rollback (All Migrations)
```bash
# Restore from backup
mysql -h localhost -u root -prootpassword my_app_db < backup_before_migrations.sql
```

---

## Troubleshooting

### Error: "Table already exists"
- Tables may have been created previously
- Solution: Check if tables exist with `SHOW TABLES;` before rerunning

### Error: "Foreign key constraint failed"
- Referenced table or user doesn't exist
- Solution: Verify users table exists and is populated

### Error: "Out of disk space"
- Database storage full
- Solution: Clean up old backups or increase disk space

### Slow Migration Execution
- Normal for large `audit_logs` or `documents` tables
- Can take 5-30 seconds depending on table size
- Monitor progress: `SELECT COUNT(*) FROM entries;`

---

## Safety Notes

1. **Always backup first:** `mysqldump my_app_db > backup.sql`
2. **Test in dev environment first** before production
3. **Deploy during maintenance window** (no active users)
4. **Monitor logs** during and after deployment
5. **Verify data integrity** with verification queries
6. **Keep migration files** for future reference and auditing

---

## Support

For issues or questions during migration:
1. Check application logs: `/var/log/php_errors.log`
2. Check MySQL logs: `/var/log/mysql/error.log`
3. Verify database connectivity: `mysql -h localhost -u root -p my_app_db -e "SELECT 1;"`
4. Review this guide's Troubleshooting section

---

**Last Updated:** May 17, 2026  
**Version:** 1.0  
**Status:** Ready for Deployment
