# Capability Updates - v12

## Date: April 12, 2026

### Database Changes

#### Employee (Role ID: 3) Capabilities

Employees can now have access to:

- **create_entries** (NEW - lowered from role 2)
- **edit_entries** (NEW - lowered from role 2)
- **view_entries** (NEW - lowered from role 2)
- **manage_roles** (NEW - lowered from role 2)
- **view_own_audit_history**
- **view_own_capabilities**
- **view_own_entries**

#### Admin (Role ID: 2) Capabilities

Admins have access to:

- **All Employee Capabilities** (inherited from role 3)
- **delete_entries**
- **create_employee**
- **edit_employee** (NEW)
- **delete_employee** (NEW)
- **edit_employee_caps**
- **view_employees**

#### SuperAdmin (Role ID: 1) Capabilities

SuperAdmins have access to:

- **All Capabilities** including:
  - create_admin
  - delete_admin
  - edit_admin_caps
  - view_admin_list
  - system_settings
  - view_audit_logs

### Migration SQL

```sql
-- Lower capability requirements for employees
UPDATE capabilities SET required_role_id = 3 WHERE capability_key IN ('create_entries', 'edit_entries', 'view_entries', 'manage_roles');

-- Add missing employee management capabilities for admins
INSERT INTO capabilities (capability_key, category, description, required_role_id, is_active)
VALUES
('edit_employee', 'ADMIN', 'Edit employee account details', 2, TRUE),
('delete_employee', 'ADMIN', 'Delete employee account', 2, TRUE);
```

### Testing

✅ Employee capabilities properly filtered in SuperAdmin dashboard
✅ Admin capabilities properly filtered in SuperAdmin dashboard
✅ SuperAdmin sees all capabilities
✅ Frontend filtering logic working correctly
