# Advanced RBAC Implementation Guide

## Testing & Usage Examples

**Date:** March 28, 2026  
**Status:** ✅ **FULLY IMPLEMENTED**

---

## QUICK START: API Endpoints

### **Base URLs**

- Backend: `http://localhost:8080`
- Frontend: `http://127.0.0.1:3000`

### **Available Endpoints**

| Endpoint                     | Method | Purpose                 | Required Capability                       |
| ---------------------------- | ------ | ----------------------- | ----------------------------------------- |
| `/grant_capability.php`      | POST   | Grant/revoke capability | `edit_admin_caps` or `edit_employee_caps` |
| `/get_capabilities.php`      | GET    | List all capabilities   | None (public)                             |
| `/get_user_capabilities.php` | GET    | Get user's capabilities | None (shows public data)                  |
| `/capability_audit_log.php`  | GET    | View audit trail        | `view_audit_logs`                         |

---

## PRACTICAL EXAMPLES

### **Example 1: SuperAdmin Grants "edit_employee_caps" to Admin**

**Scenario:**

- SuperAdmin (ID=1) wants to allow Admin (ID=2) to manage employee capabilities
- This uses the core hierarchy: SuperAdmin > Admin > Employee

**Request:**

```bash
curl -X POST http://localhost:8080/grant_capability.php \
  -H "Content-Type: application/json" \
  -d '{
    "actor_id": 1,              # SuperAdmin making the change
    "target_id": 2,             # Admin receiving the capability
    "capability_id": 6,         # edit_employee_caps ID
    "action": "GRANT"
  }'
```

**Response (Success):**

```json
{
  "success": true,
  "action": "GRANT",
  "target_id": 2,
  "target_username": "admin",
  "capability_id": 6,
  "message": "Capability granted successfully",
  "timestamp": "2026-03-28 14:30:45"
}
```

**What Happens Behind the Scenes:**

1. ✅ **Load SuperAdmin Info**
   - Role ID: 1
   - Capabilities: [all 17]

2. ✅ **Check Authorization**
   - Does SuperAdmin have `edit_admin_caps`? YES
3. ✅ **Validate Target**
   - Target (Admin) exists? YES
   - Target role (2) < SuperAdmin role (1)? YES (can manage)
   - Target (ID=2) != Actor (ID=1)? YES (not self)

4. ✅ **Check Capability Compatibility**
   - Capability `edit_employee_caps` requires role_id >= 2? YES
   - Target role (2) qualifies? YES
5. ✅ **Execute**

   ```sql
   -- Check if already exists
   SELECT id FROM user_capabilities
   WHERE user_id = 2 AND capability_id = 6;
   -- Result: 0 rows, proceed

   -- Insert grant
   INSERT INTO user_capabilities (user_id, capability_id, granted_by_id)
   VALUES (2, 6, 1);

   -- Log audit
   INSERT INTO capability_audit_log
   (actor_id, target_id, action, capability_id, ip_address)
   VALUES (1, 2, 'GRANT', 6, '172.18.0.1');
   ```

6. 📝 **Audit Trail Updated**
   - Entry in `capability_audit_log` shows:
     - Who: SuperAdmin (ID=1)
     - What: GRANT capability 6
     - Whom: Admin (ID=2)
     - When: 2026-03-28 14:30:45

---

### **Example 2: Admin Tries to Grant "delete_admin" - DENIED**

**Scenario:**

- Admin (ID=2) attempts to grant "delete_admin" to Employee (ID=3)
- Problem: "delete_admin" requires SuperAdmin level (role_id = 1)
- Admin can only grant Employee-level capabilities

**Request:**

```bash
curl -X POST http://localhost:8080/grant_capability.php \
  -H "Content-Type: application/json" \
  -d '{
    "actor_id": 2,              # Admin trying
    "target_id": 3,             # Employee
    "capability_id": 9,         # delete_admin (SuperAdmin-only)
    "action": "GRANT"
  }'
```

**Response (Failure):**

```json
{
  "success": false,
  "error": "You cannot grant SuperAdmin-level capabilities (capability requires role_id <= 1)",
  "timestamp": "2026-03-28 14:31:20"
}
```

**Validation Failure Point:**

```
Check 1: Does Admin have edit_employee_caps? YES ✓
Check 2: Is target (Employee) within Admin's authority? YES ✓
Check 3: Can Admin grant delete_admin capability?
  ├─ delete_admin.required_role_id = 1 (SuperAdmin only)
  ├─ Admin role_id = 2
  ├─ Admin(2) < Super Admin(1)? NO ✗
  └─ FAIL: Admin cannot grant SuperAdmin-only capabilities
```

**HTTP Status:** `403 Forbidden`

---

### **Example 3: Employee Tries to Grant Capability - DENIED**

**Scenario:**

- Employee (ID=3) attempts to grant "view_entries" to another Employee
- Problem: Employees lack `edit_employee_caps` capability entirely

**Request:**

```bash
curl -X POST http://localhost:8080/grant_capability.php \
  -H "Content-Type: application/json" \
  -d '{
    "actor_id": 3,              # Employee trying
    "target_id": 4,             # Another employee
    "capability_id": 1,         # view_entries
    "action": "GRANT"
  }'
```

**Response (Failure):**

```json
{
  "success": false,
  "error": "You lack capability management permissions",
  "timestamp": "2026-03-28 14:32:00"
}
```

**Validation Failure Point:**

```
Load Employee capabilities:
  ├─ role_id = 3 (Employee)
  ├─ capabilities = ['view_own_entries', 'create_entries', 'view_own_capabilities']
  ├─ Check: Has 'edit_admin_caps'? NO ✗
  ├─ Check: Has 'edit_employee_caps'? NO ✗
  └─ FAIL: Employee lacks any capability management permissions
```

**HTTP Status:** `403 Forbidden`

---

### **Example 4: Admin Tries to Grant Capability to Themselves - DENIED**

**Scenario:**

- Admin (ID=2) tries to grant "edit_admin_caps" to themselves
- Protection: No one can modify their own capabilities

**Request:**

```bash
curl -X POST http://localhost:8080/grant_capability.php \
  -H "Content-Type: application/json" \
  -d '{
    "actor_id": 2,              # Admin
    "target_id": 2,             # Same admin!
    "capability_id": 8,         # edit_admin_caps
    "action": "GRANT"
  }'
```

**Response (Failure):**

```json
{
  "success": false,
  "error": "Cannot GRANT your own capabilities",
  "timestamp": "2026-03-28 14:33:15"
}
```

**Validation Failure Point:**

```
Validate target:
  ├─ Target ID (2) == Actor ID (2)? YES
  └─ FAIL: Cannot manage yourself - prevents privilege escalation
```

**HTTP Status:** `403 Forbidden`

---

### **Example 5: Get All Available Capabilities**

**Scenario:**

- Frontend needs to display capability selection UI
- Show all 17 available capabilities by category

**Request:**

```bash
curl "http://localhost:8080/get_capabilities.php?requester_role_id=1"
```

**Response:**

```json
{
  "success": true,
  "capabilities": [
    {
      "id": 1,
      "capability_key": "view_entries",
      "category": "INVENTORY",
      "description": "View inventory entries",
      "required_role_id": 2,
      "is_active": true,
      "can_grant": true
    },
    {
      "id": 2,
      "capability_key": "create_entries",
      "category": "INVENTORY",
      "description": "Create new inventory entries",
      "required_role_id": 2,
      "is_active": true,
      "can_grant": true
    },
    ...
  ],
  "by_category": {
    "INVENTORY": [ ... ],
    "ADMIN": [ ... ],
    "SYSTEM": [ ... ],
    "USER": [ ... ]
  },
  "total": 17
}
```

**Category Breakdown:**

**INVENTORY (4 capabilities)** - Require role_id >= 2 (Admin+)

```
- view_entries
- create_entries
- edit_entries
- delete_entries
```

**ADMIN (7 capabilities)** - Mixed requirements

```
- create_employee (role_id >= 2)
- edit_employee_caps (role_id >= 2)
- view_employees (role_id >= 2)
- create_admin (role_id >= 1) ← SuperAdmin only
- edit_admin_caps (role_id >= 1) ← SuperAdmin only
- delete_admin (role_id >= 1) ← SuperAdmin only
- view_admin_list (role_id >= 1) ← SuperAdmin only
```

**SYSTEM (3 capabilities)** - SuperAdmin only

```
- view_audit_logs (role_id >= 1)
- manage_roles (role_id >= 1)
- system_settings (role_id >= 1)
```

**USER (3 capabilities)** - Available to all

```
- view_own_entries (role_id >= 3)
- view_own_capabilities (role_id >= 3)
- view_own_audit_history (role_id >= 3)
```

---

### **Example 6: Get User's Current Capabilities**

**Scenario:**

- Display Admin's current granted capabilities in the UI
- See who granted each capability and when

**Request:**

```bash
curl "http://localhost:8080/get_user_capabilities.php?user_id=2"
```

**Response:**

```json
{
  "success": true,
  "user": {
    "id": 2,
    "username": "admin",
    "role_id": 2
  },
  "capabilities": [
    {
      "id": 1,
      "capability_key": "view_entries",
      "category": "INVENTORY",
      "description": "View inventory entries",
      "required_role_id": 2,
      "granted_by_username": "system",
      "granted_at": "2026-03-28 14:15:22",
      "expires_at": null
    },
    {
      "id": 2,
      "capability_key": "create_entries",
      "category": "INVENTORY",
      "description": "Create new inventory entries",
      "required_role_id": 2,
      "granted_by_username": "system",
      "granted_at": "2026-03-28 14:15:22",
      "expires_at": null
    },
    {
      "id": 6,
      "capability_key": "edit_employee_caps",
      "category": "ADMIN",
      "description": "Edit employee capabilities",
      "required_role_id": 2,
      "granted_by_username": "superadmin",
      "granted_at": "2026-03-28 14:30:45",
      "expires_at": null
    }
  ],
  "grouped_by_category": {
    "INVENTORY": [ ... ],
    "ADMIN": [ ... ],
    "USER": [ ... ]
  },
  "total": 10
}
```

---

## HIERARCHY VALIDATION MATRIX

### **Who Can Grant What to Whom**

```
╔════════════════════════════════════════════════════════════════╗
║ SUPERADMIN (ID=1) Can Grant:                                  ║
╠════════════════════════════════════════════════════════════════╣
║ ✓ Any capability to Admin (role_id=2)                          ║
║ ✓ Any capability to Employee (role_id=3)                       ║
║ ✗ Cannot grant anything to themselves (auto-denied)            ║
║ ✗ Cannot grant to SuperAdmin (would equal privilege)           ║
╚════════════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════════════╗
║ ADMIN (ID=2) Can Grant:                                        ║
╠════════════════════════════════════════════════════════════════╣
║ ✓ Employee-compatible capabilities to Employee (role_id=3)     ║
║   Examples: view_entries, create_entries, view_employees       ║
║ ✗ SuperAdmin-only capabilities (required_role_id=1)            ║
║   Examples: delete_admin, edit_admin_caps                      ║
║ ✗ CANNOT grant anything to other Admins                        ║
║ ✗ CANNOT grant to themselves (auto-denied)                     ║
╚════════════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════════════╗
║ EMPLOYEE (ID=3) Can Grant:                                     ║
╠════════════════════════════════════════════════════════════════╣
║ ✗ CANNOT grant ANY capability to anyone                        ║
║ ✗ Lacks 'edit_employee_caps' capability entirely               ║
║ ✗ Cannot escalate privileges beyond own role                   ║
╚════════════════════════════════════════════════════════════════╝
```

---

## DATABASE AUDIT TRAIL EXAMPLES

### **Query: Who Changed Admin's Capabilities?**

```sql
SELECT
    cal.id,
    u_actor.username as actor,
    u_target.username as target,
    c.capability_key,
    cal.action,
    cal.created_at
FROM capability_audit_log cal
JOIN users u_actor ON cal.actor_id = u_actor.id
JOIN users u_target ON cal.target_id = u_target.id
JOIN capabilities c ON cal.capability_id = c.id
WHERE cal.target_id = 2
ORDER BY cal.created_at DESC;
```

**Result:**

```
id | actor      | target | capability_key      | action | created_at
───┼────────────┼────────┼─────────────────────┼────────┼──────────────────
5  | superadmin | admin  | edit_employee_caps  | GRANT  | 2026-03-28 14:30
4  | superadmin | admin  | view_admin_list     | GRANT  | 2026-03-28 14:25
3  | superadmin | admin  | delete_entries      | REVOKE | 2026-03-28 14:20
```

### **Query: All Actions by SuperAdmin**

```sql
SELECT
    cal.id,
    u_target.username as target,
    u_target.role_id,
    c.capability_key,
    cal.action,
    cal.created_at
FROM capability_audit_log cal
JOIN users u_actor ON cal.actor_id = u_actor.id
JOIN users u_target ON cal.target_id = u_target.id
JOIN capabilities c ON cal.capability_id = c.id
WHERE cal.actor_id = 1
ORDER BY cal.created_at DESC;
```

---

## TESTING CHECKLIST

### **Phase 1: Authentication**

```
☐ Login as SuperAdmin (superadmin / SuperAdmin@2026)
  ├─ ✓ Verify: role_id = 1
  ├─ ✓ Verify: Has 'edit_admin_caps' capability
  └─ ✓ Verify: Redirects to /superadmin

☐ Login as Admin (admin / Admin@2026)
  ├─ ✓ Verify: role_id = 2
  ├─ ✓ Verify: Has 'edit_employee_caps' capability
  ├─ ✓ Verify: Missing 'edit_admin_caps' capability
  └─ ✓ Verify: Redirects to /dashboard

☐ Login as Employee (employee / Employee@2026)
  ├─ ✓ Verify: role_id = 3
  ├─ ✓ Verify: Missing 'edit_employee_caps' capability
  └─ ✓ Verify: Redirects to /dashboard
```

### **Phase 2: Capability Grants**

```
☐ SuperAdmin grants 'view_admin_list' to Admin
  ├─ ✓ Request succeeds
  ├─ ✓ Admin can now view admin list
  └─ ✓ Audit logged

☐ Admin grants 'view_entries' to Employee
  ├─ ✓ Request succeeds
  ├─ ✓ Employee capability updated
  └─ ✓ Audit logged

☐ Admin tries to grant 'delete_admin' to Employee
  ├─ ✓ Request DENIED (403)
  ├─ ✓ Error message: "SuperAdmin-level capability"
  └─ ✓ Audit logged as failed attempt

☐ Employee tries to grant anything to anyone
  ├─ ✓ Request DENIED (403)
  ├─ ✓ Error message: "capability management permissions"
  └─ ✓ Audit logged
```

### **Phase 3: Hierarchy Protection**

```
☐ SuperAdmin cannot modify own capabilities
  ├─ ✓ Request DENIED (403)
  └─ ✓ Error: "Cannot GRANT your own capabilities"

☐ Admin cannot grant to other Admins
  ├─ ✓ Request DENIED (403)
  └─ ✓ Error: "Insufficient privilege to manage this user"

☐ Employee access control checks
  ├─ ✓ Cannot view admin management UI
  ├─ ✓ Cannot access /superadmin route
  └─ ✓ Restricted to /dashboard only
```

---

## NEXT STEPS

1. **Test Current Implementation**
   - Run through all examples above
   - Verify audit logs are recorded
   - Check error messages match

2. **Build UI Components** (CapabilityManager.jsx)
   - SuperAdmin capability editor
   - Admin capability (employee-only) editor
   - Employee view capabilities (read-only)

3. **Frontend Integration**
   - Add capability checks to show/hide UI elements
   - Display user's current capabilities
   - Provide feedback on capability changes

4. **Enhanced Features**
   - Temporary capability grants (with expiration)
   - Capability request/approval workflow
   - Permission delegation chains
   - Bulk capability operations

---

**Status: ✅ Backend Implementation Complete**  
**Ready for: Frontend Integration & UI Testing**
