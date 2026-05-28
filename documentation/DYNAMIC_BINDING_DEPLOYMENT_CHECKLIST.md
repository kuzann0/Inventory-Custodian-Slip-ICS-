# DYNAMIC DATA BINDING - DEPLOYMENT CHECKLIST

**Project**: Purchase Request Workflow - Dynamic Data Binding  
**Date**: 2026-04-27  
**Version**: 1.0  
**Status**: Ready for Deployment

---

## Pre-Deployment Verification

### Environment Check
- [ ] Database server is accessible
- [ ] MySQL version 5.7+ confirmed
- [ ] PHP 7.4+ available on server
- [ ] Write permissions to backend/ directory
- [ ] Write permissions to database
- [ ] Current user has admin/root DB access

### Code Review
- [ ] DynamicDataBinding.php reviewed for logic
- [ ] All 5 endpoint files reviewed
- [ ] Migration script syntax verified
- [ ] No hardcoded credentials in files
- [ ] Error handling complete in all endpoints
- [ ] Comments and documentation inline

### Documentation Review
- [ ] Implementation guide reviewed
- [ ] Technical spec reviewed
- [ ] API endpoints documented
- [ ] Examples verified
- [ ] Troubleshooting guide complete
- [ ] Rollback procedures documented

---

## Backup & Safety

### Backup Procedures
- [ ] Full database backup created: `backup_20260427_before_migration.sql`
- [ ] Backup verified (restore tested in staging)
- [ ] Backup location: `__________________` (document path)
- [ ] Backup retention: 30 days minimum
- [ ] Backup owner: `__________________`

### Staging Environment
- [ ] Staging database available
- [ ] Migration script tested on staging
- [ ] New endpoints tested on staging
- [ ] Data consistency verified on staging
- [ ] No errors in staging logs
- [ ] Performance baseline recorded

### Change Control
- [ ] Change request submitted (if required)
- [ ] Approval obtained from: `__________________`
- [ ] Maintenance window scheduled: `__________________`
- [ ] Stakeholders notified: `__________________`
- [ ] Rollback plan reviewed: YES / NO
- [ ] Team on standby: YES / NO

---

## Phase 1: Database Migration

### Execute Migration
```bash
Command: mysql -u [USERNAME] -p [DATABASE] < backend/database/dynamic_binding_migration.sql
```

- [ ] Migration script executed successfully
- [ ] No errors in migration output
- [ ] Execution time recorded: `_____ seconds`

### Verify Migration Success

#### Table Verification
```sql
SHOW TABLES LIKE 'entry_%';
```
- [ ] `entry_workflow_status` exists
- [ ] `entry_step_mapping` exists
- [ ] `entry_binding_audit` exists

#### Column Verification (entries table)
```sql
DESCRIBE entries;
```
- [ ] ApprovalStatus column exists
- [ ] ApprovedBy column exists
- [ ] ApprovedDate column exists
- [ ] DeliveryNotes column exists
- [ ] DeliveryDate column exists
- [ ] DeliveryStatus column exists
- [ ] InspectionNotes column exists
- [ ] InspectionDate column exists
- [ ] InspectionStatus column exists
- [ ] InspectedBy column exists
- [ ] FormType column exists
- [ ] FormData column exists
- [ ] FormSubmitDate column exists
- [ ] FormStatus column exists
- [ ] PrId column exists
- [ ] WorkflowStep column exists

#### View Verification
```sql
SELECT COUNT(*) FROM workflow_data_binding;
```
- [ ] workflow_data_binding view accessible
- [ ] Returns results without error

#### Data Check
```sql
SELECT COUNT(*) as total_entries FROM entries;
SELECT COUNT(*) as total_workflows FROM entry_workflow_status;
```
- [ ] Entry count recorded: `_______`
- [ ] Workflow count recorded: `_______`
- [ ] No data loss detected

### Index Creation
```sql
SHOW INDEXES FROM entries;
SHOW INDEXES FROM entry_workflow_status;
```
- [ ] idx_pr_id exists
- [ ] idx_workflow_step exists
- [ ] idx_approval_status exists
- [ ] idx_form_type exists
- [ ] idx_entry_pr exists
- [ ] idx_current_step exists

---

## Phase 2: Code Deployment

### Copy Files to Server
```bash
cp backend/DynamicDataBinding.php /path/to/backend/
cp backend/submit_purchase_request_binding.php /path/to/backend/
cp backend/workflow_step_binding.php /path/to/backend/
cp backend/get_workflow_entry_binding.php /path/to/backend/
cp backend/get_all_workflow_entries_binding.php /path/to/backend/
```

- [ ] DynamicDataBinding.php deployed
- [ ] submit_purchase_request_binding.php deployed
- [ ] workflow_step_binding.php deployed
- [ ] get_workflow_entry_binding.php deployed
- [ ] get_all_workflow_entries_binding.php deployed

### File Permissions
```bash
chmod 644 /path/to/backend/*.php
chmod 755 /path/to/backend/
```

- [ ] Files readable by web server
- [ ] Directory readable and executable
- [ ] No permission errors

### Web Server Configuration
- [ ] PHP error logging enabled
- [ ] PHP error display configured (production: off)
- [ ] Web server restarted (if required)
- [ ] Web server status checked

---

## Phase 3: Endpoint Testing

### Test 1: Create Purchase Request (Step 1)

**Endpoint**: POST /submit_purchase_request_binding.php

**Request**:
```json
{
    "pr_no": "TEST-2026-04-27-001",
    "item_name": "Test Equipment",
    "quantity": 10,
    "unit": "units",
    "unit_cost": 5000.00,
    "office": "Test Department",
    "division_section": "Test Section",
    "description": "Test purchase request",
    "user_id": 1
}
```

- [ ] Request sent successfully
- [ ] HTTP Status: 201 (Created)
- [ ] Response contains entry_id: `_______`
- [ ] Response contains pr_id: `_______`
- [ ] Response contains form_type: `_______`
- [ ] Total cost calculated correctly: `_______`
- [ ] Entry created in database
- [ ] Workflow tracking record created

**Variables for Next Tests**:
- `PR_ID = _______`
- `ENTRY_ID = _______`

### Test 2: Approve Request (Step 2)

**Endpoint**: POST /workflow_step_binding.php

**Request**:
```json
{
    "pr_id": [PR_ID],
    "step": 2,
    "data": {
        "approval_notes": "Test approval - deployment verification",
        "approved_by": 2
    },
    "user_id": 2
}
```

- [ ] Request sent successfully
- [ ] HTTP Status: 200
- [ ] Response success: true
- [ ] step_2_completed flag: true
- [ ] ApprovalStatus updated in database
- [ ] ApprovedDate recorded
- [ ] Workflow step incremented to 2

### Test 3: Submit Delivery (Step 3)

**Endpoint**: POST /workflow_step_binding.php

**Request**:
```json
{
    "pr_id": [PR_ID],
    "step": 3,
    "data": {
        "delivery_notes": "Test delivery - deployment verification",
        "delivery_date": "2026-04-28",
        "delivery_status": "pending"
    },
    "user_id": 3
}
```

- [ ] Request sent successfully
- [ ] HTTP Status: 200
- [ ] Response success: true
- [ ] step_3_completed flag: true
- [ ] DeliveryNotes updated in database
- [ ] DeliveryDate recorded
- [ ] Workflow step incremented to 3

### Test 4: Submit Inspection (Step 4)

**Endpoint**: POST /workflow_step_binding.php

**Request**:
```json
{
    "pr_id": [PR_ID],
    "step": 4,
    "data": {
        "inspection_notes": "Test inspection - deployment verification",
        "inspection_status": "completed",
        "inspected_by": 4
    },
    "user_id": 4
}
```

- [ ] Request sent successfully
- [ ] HTTP Status: 200
- [ ] Response success: true
- [ ] step_4_completed flag: true
- [ ] InspectionNotes updated in database
- [ ] InspectionDate recorded
- [ ] Workflow step incremented to 4

### Test 5: Submit Form (Step 5)

**Endpoint**: POST /workflow_step_binding.php

**Request**:
```json
{
    "pr_id": [PR_ID],
    "step": 5,
    "data": {
        "form_type": "ics",
        "form_status": "submitted",
        "additional_field": "test value"
    },
    "user_id": 5
}
```

- [ ] Request sent successfully
- [ ] HTTP Status: 200
- [ ] Response success: true
- [ ] step_5_completed flag: true
- [ ] FormType updated in database
- [ ] FormData stored as JSON
- [ ] FormSubmitDate recorded
- [ ] Workflow step incremented to 5

### Test 6: Retrieve Single Entry

**Endpoint**: GET /get_workflow_entry_binding.php?pr_id=[PR_ID]

- [ ] Request sent successfully
- [ ] HTTP Status: 200
- [ ] Response success: true
- [ ] All step fields present
- [ ] Step completion flags correct
- [ ] JSON data properly parsed
- [ ] Entry ID matches: `_______`
- [ ] PR number matches: `_______`

### Test 7: Get All Entries

**Endpoint**: GET /get_all_workflow_entries_binding.php

- [ ] Request sent successfully
- [ ] HTTP Status: 200
- [ ] Response success: true
- [ ] Count includes new entry
- [ ] Data array populated
- [ ] All fields present

### Test 8: Filter by Status

**Endpoint**: GET /get_all_workflow_entries_binding.php?status=completed

- [ ] Request sent successfully
- [ ] HTTP Status: 200
- [ ] Filtering works correctly
- [ ] Only completed entries returned
- [ ] Count >= 1

### Test 9: Filter by Form Type

**Endpoint**: GET /get_all_workflow_entries_binding.php?form_type=ics

- [ ] Request sent successfully
- [ ] HTTP Status: 200
- [ ] Filtering works correctly
- [ ] Only ICS forms returned
- [ ] Count >= 1

---

## Phase 4: Data Consistency Verification

### Database Consistency Checks

```sql
-- Check for orphaned entries
SELECT COUNT(*) as orphaned
FROM entries e
LEFT JOIN entry_workflow_status ews ON e.order_id = ews.entry_id
WHERE ews.id IS NULL AND e.order_id = [ENTRY_ID];
```
- [ ] Orphaned count: 0

```sql
-- Check workflow status completeness
SELECT * FROM entry_workflow_status WHERE pr_id = [PR_ID];
```
- [ ] All step flags correct
- [ ] current_step = 5
- [ ] All JSON data present

```sql
-- Verify purchase_requests sync
SELECT * FROM purchase_requests WHERE id = [PR_ID];
```
- [ ] Status synchronized
- [ ] Approval data present
- [ ] Delivery data present
- [ ] Inspection data present

```sql
-- Check audit trail
SELECT * FROM audit_logs WHERE action LIKE '%binding%' ORDER BY created_at DESC LIMIT 5;
```
- [ ] Audit entries created
- [ ] Correct actions logged
- [ ] Timestamps accurate

### Data Validation

```sql
-- Verify data types
SELECT 
    COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'entries'
AND COLUMN_NAME IN ('ApprovalStatus', 'FormData', 'TotalCost');
```
- [ ] All data types correct
- [ ] Nullable flags appropriate

---

## Phase 5: Performance Baseline

### Query Performance Testing

```sql
-- Single entry retrieval
SELECT SQL_NO_CACHE * FROM entries e
LEFT JOIN entry_workflow_status ews ON e.order_id = ews.entry_id
WHERE ews.pr_id = [PR_ID];
```
- [ ] Query executed
- [ ] Response time recorded: `_____ ms` (target: < 5ms)
- [ ] Using index confirmed

```sql
-- All entries retrieval
SELECT SQL_NO_CACHE COUNT(*) FROM workflow_data_binding;
```
- [ ] Query executed
- [ ] Response time recorded: `_____ ms` (target: < 100ms)
- [ ] Index usage verified

### Resource Usage
- [ ] Memory usage stable
- [ ] CPU usage normal
- [ ] Disk I/O reasonable
- [ ] No slow queries detected

---

## Phase 6: Monitoring Setup

### Logging Configuration
- [ ] Error log enabled
- [ ] Log rotation configured
- [ ] Log retention: 30 days minimum
- [ ] Log location documented: `__________________`

### Monitoring Queries Prepared
```bash
# Health check script created
cat > /scripts/check_binding_health.sh << 'EOF'
#!/bin/bash
mysql -u [USER] -p[PASS] [DB] << 'SQL'
-- Binding health check
SELECT 'Entries' as table_name, COUNT(*) as count FROM entries
UNION ALL
SELECT 'Workflows', COUNT(*) FROM entry_workflow_status
UNION ALL
SELECT 'Audit', COUNT(*) FROM entry_binding_audit;
SQL
EOF
```
- [ ] Health check script created
- [ ] Script executable
- [ ] Cron job scheduled (every 15 minutes)

### Alerts Configured
- [ ] Error log monitoring enabled
- [ ] Alert threshold: > 5 errors in 1 hour
- [ ] Alert recipient: `__________________`
- [ ] Alert method: Email / Slack / Other: `__________________`

---

## Phase 7: Documentation Handoff

### Files Provided
- [ ] DYNAMIC_BINDING_IMPLEMENTATION.md reviewed
- [ ] DYNAMIC_BINDING_QUICK_REFERENCE.md reviewed
- [ ] DYNAMIC_BINDING_TECHNICAL_SPEC.md reviewed
- [ ] DYNAMIC_BINDING_SUMMARY.md reviewed
- [ ] API documentation complete
- [ ] Troubleshooting guide complete

### Team Training
- [ ] Developers briefed on new endpoints
- [ ] DBA trained on monitoring
- [ ] Support team has escalation procedures
- [ ] Documentation available in: `__________________`

### Knowledge Transfer
- [ ] Code walkthrough completed
- [ ] Architecture explained
- [ ] Common issues documented
- [ ] Q&A session completed

---

## Phase 8: Go-Live

### Pre-Go-Live (24 hours before)
- [ ] Final backup taken
- [ ] Staging environment matches production
- [ ] All tests passed
- [ ] Team briefed and on-call
- [ ] Rollback plan reviewed
- [ ] Success criteria agreed upon

### Go-Live (Execution)
- [ ] Deployment window opened
- [ ] Migration script executed
- [ ] Code deployed
- [ ] Endpoints tested in production
- [ ] Basic functionality verified
- [ ] Team monitoring active

### Post-Go-Live (First 72 hours)
- [ ] Error logs monitored continuously
- [ ] Performance baselines verified
- [ ] Data consistency confirmed
- [ ] User feedback collected
- [ ] Issues tracked and logged
- [ ] Team available for support

### Success Criteria Met?
- [ ] All endpoints operational: YES / NO
- [ ] No critical errors: YES / NO
- [ ] Performance acceptable: YES / NO
- [ ] Data consistent: YES / NO
- [ ] Team confident: YES / NO
- [ ] Ready to celebrate: YES / NO

---

## Rollback Plan (If Needed)

### Rollback Trigger
Rollback if:
- [ ] Critical errors in logs
- [ ] Data corruption detected
- [ ] Performance severely degraded
- [ ] Data inconsistency found
- [ ] Business continuity at risk

### Rollback Steps
1. [ ] Notify team immediately
2. [ ] Stop new submissions
3. [ ] Restore from backup: `backup_20260427_before_migration.sql`
4. [ ] Remove new endpoint files
5. [ ] Clear cached data
6. [ ] Verify system restored
7. [ ] Resume normal operations
8. [ ] Root cause analysis

**Estimated Rollback Time**: 30-45 minutes

---

## Sign-Off

### Deployment Team
- **Prepared by**: `__________________` Date: `__________`
- **Reviewed by**: `__________________` Date: `__________`
- **Approved by**: `__________________` Date: `__________`
- **Deployed by**: `__________________` Date: `__________`

### Verification
- **Database verified by**: `__________________`
- **Application verified by**: `__________________`
- **Tests completed by**: `__________________`
- **Go-live approved by**: `__________________`

### Post-Deployment (72 hours)
- **Monitoring completed by**: `__________________`
- **All issues resolved**: YES / NO
- **System stable**: YES / NO
- **Deployment successful**: YES / NO

---

## Notes & Issues

### Deployment Notes
```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

### Issues Encountered
```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

### Resolutions Applied
```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

**Deployment Status**: ⬜ Not Started | 🟡 In Progress | 🟢 Completed

**Final Status**: `__________________`

**Lessons Learned**: 
```
_________________________________________________________________

_________________________________________________________________
```

---

**End of Deployment Checklist**  
Print this document and complete during deployment.  
File completed checklist as deployment record.
