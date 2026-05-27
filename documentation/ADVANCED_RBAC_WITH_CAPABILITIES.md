# Advanced RBAC System with Capability Management

## Complete Design & Implementation Guide

**Date:** March 28, 2026  
**Version:** 2.0 (Advanced Edition)  
**Status:** 🔧 In Development

---

## STEP 1: LOGIN FLOW SIMULATION

### **Scenario A: SuperAdmin Login (role_id = 1)**

```
┌─────────────────────────────────────────────────────────┐
│ SUPERADMIN LOGIN FLOW                                   │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ 1. User enters: superadmin / SuperAdmin@2026           │
│    ↓                                                    │
│ 2. Backend login.php validates credentials             │
│    ↓                                                    │
│ 3. Query: SELECT FROM users WHERE username='superadmin'│
│    Result: role_id=1, permissions=[7 items]            │
│    ↓                                                    │
│ 4. backend/login.php returns:                          │
│    {                                                    │
│      role_id: 1,                                        │
│      role_name: 'SuperAdmin',                           │
│      permissions: [                                     │
│        'create_admins',                                 │
│        'edit_admins',          ← Can edit admin caps    │
│        'delete_admins',                                 │
│        'create_employees',                              │
│        'edit_employee_caps',   ← Can edit employee caps │
│        'delete_employees',                              │
│        'view_audit_logs'                                │
│      ]                                                  │
│    }                                                    │
│    ↓                                                    │
│ 5. Frontend LoginForm.jsx:                             │
│    - Stores session_token, role_id=1                   │
│    - Stores permissions array                          │
│    - Detects role_id === 1 ✓                           │
│    ↓                                                    │
│ 6. Smart redirect: navigate("/superadmin")             │
│    ↓                                                    │
│ 7. SuperAdminPage.jsx loads:                           │
│    - "Admin Management" card                           │
│    - "Employee Management" card ← Can edit BOTH        │
│    - "Audit Logs" viewer                               │
│    - Capability Editor (can modify ANY role's caps)    │
│    ↓                                                    │
│ 8. SuperAdmin can:                                     │
│    ✓ List all admins                                   │
│    ✓ Create new admin                                  │
│    ✓ Edit admin capabilities (e.g., add/remove perms)  │
│    ✓ Delete admin                                      │
│    ✓ Edit employee capabilities directly               │
│    ✓ View all audit logs                               │
│    ↓                                                    │
│ RESULT: ✓ Full system control with no restrictions     │
└─────────────────────────────────────────────────────────┘
```

### **Scenario B: Admin Login (role_id = 2)**

```
┌─────────────────────────────────────────────────────────┐
│ ADMIN LOGIN FLOW                                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ 1. User enters: admin / Admin@2026                      │
│    ↓                                                    │
│ 2. Backend validates credentials                       │
│    ↓                                                    │
│ 3. Query: SELECT FROM users WHERE username='admin'     │
│    Result: role_id=2, permissions=[4 items]            │
│    ↓                                                    │
│ 4. backend/login.php returns:                          │
│    {                                                    │
│      role_id: 2,                                        │
│      role_name: 'Admin',                                │
│      permissions: [                                     │
│        'view_entries',                                  │
│        'create_entries',                                │
│        'edit_employee_caps',   ← Can edit ONLY employees│
│        'view_admin_logs'       ← Limited audit access   │
│      ]                                                  │
│    }                                                    │
│    ↓                                                    │
│ 5. Frontend LoginForm.jsx:                             │
│    - Stores session_token, role_id=2                   │
│    - Stores permissions array                          │
│    - Detects role_id !== 1, so NOT SuperAdmin          │
│    ↓                                                    │
│ 6. Smart redirect: navigate("/dashboard")              │
│    ↓                                                    │
│ 7. Dashboard.jsx loads:                                │
│    - Entry management interface                        │
│    - Employee management card (LIMITED)                │
│      └─ Can ONLY edit employee capabilities            │
│      └─ CANNOT see/edit admin capabilities             │
│      └─ CANNOT edit own capabilities                   │
│    - Limited audit logs (for own actions only)         │
│    ↓                                                    │
│ 8. Admin can:                                          │
│    ✓ Create/edit/delete inventory entries              │
│    ✓ View list of employees                            │
│    ✓ Edit EMPLOYEE capabilities only                   │
│    ✗ CANNOT create/edit/delete admins                  │
│    ✗ CANNOT edit their own or other admins' caps       │
│    ✗ CANNOT view full audit logs                       │
│    ↓                                                    │
│ RESULT: ✓ Limited control - employees only             │
└─────────────────────────────────────────────────────────┘
```

### **Scenario C: Employee Login (role_id = 3)**

```
┌─────────────────────────────────────────────────────────┐
│ EMPLOYEE LOGIN FLOW                                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ 1. User enters: employee / Employee@2026               │
│    ↓                                                    │
│ 2. Backend validates credentials                       │
│    ↓                                                    │
│ 3. Query: SELECT FROM users WHERE username='employee'  │
│    Result: role_id=3, permissions=[3 items]            │
│    ↓                                                    │
│ 4. backend/login.php returns:                          │
│    {                                                    │
│      role_id: 3,                                        │
│      role_name: 'Employee',                             │
│      permissions: [                                     │
│        'view_own_entries',                              │
│        'create_entries',                                │
│        'view_own_capabilities'  ← READ ONLY             │
│      ]                                                  │
│    }                                                    │
│    ↓                                                    │
│ 5. Frontend LoginForm.jsx:                             │
│    - Stores session_token, role_id=3                   │
│    - Stores permissions array                          │
│    ↓                                                    │
│ 6. Smart redirect: navigate("/dashboard")              │
│    ↓                                                    │
│ 7. Dashboard.jsx loads:                                │
│    - Only show: "My Entries"                           │
│    - Entry form (can create)                           │
│    - My capabilities (READ ONLY - cannot change)       │
│    - NO admin/superadmin sections visible              │
│    ↓                                                    │
│ 8. Employee can:                                       │
│    ✓ View own entries                                  │
│    ✓ Create new entry                                  │
│    ✓ View own capabilities (assigned by Admin)         │
│    ✗ CANNOT modify own capabilities                    │
│    ✗ CANNOT view/manage other employees                │
│    ✗ CANNOT access admin functions AT ALL              │
│    ↓                                                    │
│ RESULT: ✓ Read-mostly access to own data only          │
└─────────────────────────────────────────────────────────┘
```

---

## STEP 2: DIAGNOSIS - PROBLEMS IDENTIFIED

### **Current System Issues:**

| #   | Issue                                     | Severity    | Impact                                                   |
| --- | ----------------------------------------- | ----------- | -------------------------------------------------------- |
| 1   | No capability management system           | 🔴 CRITICAL | Can't modify permissions after creation                  |
| 2   | Permissions hardcoded by role             | 🔴 CRITICAL | No flexibility for custom permissions                    |
| 3   | Admin cannot manage employee capabilities | 🔴 CRITICAL | Admins lack essential management tools                   |
| 4   | No hierarchy validation                   | 🟡 HIGH     | Admins could theoretically manage admins (security risk) |
| 5   | No permission checks on backend           | 🟡 HIGH     | CRUD operations not validated by role                    |
| 6   | Frontend shows all options to all roles   | 🟡 HIGH     | Confusing UX for limited users                           |
| 7   | No audit trail for permission changes     | 🟠 MEDIUM   | Can't track who changed what capabilities                |
| 8   | No delegation of specific capabilities    | 🟠 MEDIUM   | All-or-nothing permission model                          |

### **Security Vulnerabilities:**

```javascript
// ❌ PROBLEM 1: No backend validation
// Admin could theoretically fetch edit_admin_capacities endpoint
POST /api/edit_capability.php
{
    "target_user_id": 2,  // Another admin's ID
    "capability": "delete_admins",  // Try to add to another admin
    "action": "add"
}
// Backend currently: "Is this user authenticated? Yes → Allow"
// Missing: "Verify user's role allows managing this target!"

// ❌ PROBLEM 2: No hierarchy check
// Admin (role_id=2) tries to manage another Admin (role_id=2)
// System allows it because both are >= 2
// Should only allow: SuperAdmin(1) > Admin(2) > Employee(3)

// ❌ PROBLEM 3: Hardcoded permissions
// If Admin role needs new permission "audit_export"
// Must manually: Update role in DB, update frontend dropdown
// Should: Add to DB, automatically available in UI
```

---

## STEP 3: CORRECTED ROLE MAPPING WITH HIERARCHY

### **Role Hierarchy (Clear Authority Chain)**

```
                    ┌─────────────────────┐
                    │   SuperAdmin (1)    │
                    │   Authority: ∞      │
                    │   Level: SYSTEM     │
                    └──────────┬──────────┘
                               │
                   Can manage: ↓
            ┌──────────────────┴──────────────────┐
            │                                     │
        ┌───▼─────────────────┐    ┌────────────▼───┐
        │ Admin (2)           │    │ Employee (3)   │
        │ Authority: Medium   │    │ Authority: Low │
        │ Level: OPERATIONAL  │    │ Level: USER    │
        └───┬─────────────────┘    └────────────────┘
            │
    Can manage: ↓
            └──────────┐
                       │
                   ┌───▼─────────────┐
                   │ Employee (3)    │
                   │                 │
                   └─────────────────┘
```

### **Database Schema (NEW)**

```sql
-- 1. user_roles table (ALREADY EXISTS - no change)
┌─────────────────────────────────────────────────────┐
│ user_roles                                          │
├────┬───────────┬─────────────────┬──────────────────┤
│ id │ role_name │ role_level      │ permissions (JSON)│
├────┼───────────┼─────────────────┼──────────────────┤
│ 1  │ SuperAdmin│ 3 (highest)     │ [7 core perms]   │
│ 2  │ Admin     │ 2 (medium)      │ [4 base perms]   │
│ 3  │ Employee  │ 1 (lowest)      │ [3 user perms]   │
└────┴───────────┴─────────────────┴──────────────────┘

-- 2. capabilities table (NEW - List of ALL possible capabilities)
┌──────────────────────────────────────────────────────────────┐
│ capabilities                                                 │
├────┬──────────────────────┬─────────────┬──────────────────┤
│ id │ capability_key       │ category    │ required_role_id │
├────┼──────────────────────┼─────────────┼──────────────────┤
│ 1  │ view_entries         │ INVENTORY   │ 2 (Admin+)       │
│ 2  │ create_entries       │ INVENTORY   │ 2 (Admin+)       │
│ 3  │ edit_entries         │ INVENTORY   │ 2 (Admin+)       │
│ 4  │ delete_entries       │ INVENTORY   │ 2 (Admin+)       │
│ 5  │ create_employee      │ ADMIN       │ 1 (SuperAdmin)   │
│ 6  │ edit_employee_caps   │ ADMIN       │ 2 (Admin+)       │
│ 7  │ create_admin         │ ADMIN       │ 1 (SuperAdmin)   │
│ 8  │ edit_admin_caps      │ ADMIN       │ 1 (SuperAdmin)   │
│ 9  │ delete_admin         │ ADMIN       │ 1 (SuperAdmin)   │
│ 10 │ view_audit_logs      │ SYSTEM      │ 1 (SuperAdmin)   │
│ 11 │ view_own_capabilities│ USER        │ 3 (Employee+)    │
└────┴──────────────────────┴─────────────┴──────────────────┘

-- 3. user_capabilities table (NEW - Which user has which capabilities)
┌──────────────────────────────────────────────────────────────┐
│ user_capabilities                                            │
├───────┬─────────────────┬────────────────┬───────────────────┤
│ id    │ user_id         │ capability_id  │ granted_by_id     │
├───────┼─────────────────┼────────────────┼───────────────────┤
│ 1     │ 1 (superadmin)  │ 1 (view_ent)   │ null (system)     │
│ 2     │ 1 (superadmin)  │ 2 (cre_ent)    │ null (system)     │
│ ...   │ ...             │ ...            │ ...               │
│ 100   │ 2 (admin)       │ 1 (view_ent)   │ 1 (granted by SA) │
│ 101   │ 2 (admin)       │ 6 (ed_emp_cp)  │ 1 (granted by SA) │
│ ...   │ ...             │ ...            │ ...               │
│ 200   │ 3 (employee)    │ 11 (view_own)  │ 2 (granted by Ad) │
└───────┴─────────────────┴────────────────┴───────────────────┘

-- 4. capability_audit_log table (NEW - Track permission changes)
┌────────────────────────────────────────────────────────────────┐
│ capability_audit_log                                           │
├────────┬──────────────┬────────────┬─────────┬────────────────┤
│ id     │ actor_id     │ target_id  │ action  │ capability_id  │
├────────┼──────────────┼────────────┼─────────┼────────────────┤
│ 1      │ 1 (SuperA)   │ 2 (Admin)  │ GRANT   │ 6 (edit_emp)   │
│ 2      │ 1 (SuperA)   │ 2 (Admin)  │ REVOKE  │ 9 (delete_ad)  │
│ 3      │ 2 (Admin)    │ 3 (Emp)    │ GRANT   │ 1 (view_ent)   │
└────────┴──────────────┴────────────┴─────────┴────────────────┘
```

### **Role Capabilities Matrix (Who Can Do What)**

```
ACTION                          SuperAdmin  Admin   Employee
═══════════════════════════════════════════════════════════════
Inventory Management
  View entries                     ✓         ✓        ✓
  Create entries                   ✓         ✓        ✓
  Edit entries                     ✓         ✓        ✗
  Delete entries                   ✓         ✓        ✗

User Management
  Create Admin                     ✓         ✗        ✗
  View Admin list                  ✓         ✗        ✗
  Edit Admin capabilities          ✓         ✗        ✗
  Delete Admin                     ✓         ✗        ✗
  Create Employee                  ✓         ✓        ✗
  View Employee list               ✓         ✓        ✗
  Edit Employee capabilities       ✓         ✓        ✗
  Delete Employee                  ✓         ✗        ✗

System Management
  View all audit logs              ✓         ✗        ✗
  Edit system settings             ✓         ✗        ✗
  Manage roles                     ✓         ✗        ✗

Self Management
  View own capabilities            ✓         ✓        ✓
  Edit own capabilities            ✗         ✗        ✗
  View own audit history           ✓         ✓        ✓
```

---

## STEP 4: CRUD LOGIC WITH ROLE-BASED OPERATIONS

### **Backend Validation Pattern**

```php
// File: backend/lib/PermissionValidator.php
// NEW - Core validation class for all CRUD operations

class PermissionValidator {
    private $conn;
    private $actorId;
    private $actorRoleId;
    private $actorCapabilities;

    public function __construct($conn, $actorId) {
        $this->conn = $conn;
        $this->actorId = $actorId;
        $this->loadActorInfo();
    }

    private function loadActorInfo() {
        // Get actor's role and capabilities
        $stmt = $this->conn->prepare(
            "SELECT u.role_id, GROUP_CONCAT(c.capability_key) as caps
             FROM users u
             LEFT JOIN user_capabilities uc ON u.id = uc.user_id
             LEFT JOIN capabilities c ON uc.capability_id = c.id
             WHERE u.id = ? GROUP BY u.id"
        );
        $stmt->bind_param('i', $this->actorId);
        $stmt->execute();
        $result = $stmt->get_result()->fetch_assoc();

        $this->actorRoleId = $result['role_id'];
        $this->actorCapabilities = explode(',', $result['caps'] ?? '');
    }

    // ═══════════════════════════════════════════════════════
    // CHECK #1: Verify capability exists
    // ═══════════════════════════════════════════════════════
    public function hasCapability($capabilityKey) {
        return in_array($capabilityKey, $this->actorCapabilities);
    }

    // ═══════════════════════════════════════════════════════
    // CHECK #2: Verify hierarchy (can only manage lower roles)
    // ═══════════════════════════════════════════════════════
    public function canManageRole($targetRoleId) {
        // SuperAdmin (1) can manage: Admin (2), Employee (3)
        // Admin (2) can manage: Employee (3) only
        // Employee (3) cannot manage anyone

        if ($this->actorRoleId == 1) {
            return $targetRoleId >= 2;  // Can manage Admin and Employee
        }
        if ($this->actorRoleId == 2) {
            return $targetRoleId == 3;  // Can manage Employee only
        }
        return false;  // Employees cannot manage anyone
    }

    // ═══════════════════════════════════════════════════════
    // CHECK #3: Verify capability can be granted to target
    // ═══════════════════════════════════════════════════════
    public function canGrantCapability($capabilityId, $targetRoleId) {
        // Get capability's required role level
        $stmt = $this->conn->prepare(
            "SELECT required_role_id FROM capabilities WHERE id = ?"
        );
        $stmt->bind_param('i', $capabilityId);
        $stmt->execute();
        $result = $stmt->get_result()->fetch_assoc();
        $requiredRoleId = $result['required_role_id'];

        // Admin cannot grant capabilities that require > Admin level
        if ($this->actorRoleId == 2 && $requiredRoleId < 2) {
            return false;  // Admin cannot grant SuperAdmin-only caps
        }

        // Target role must be able to have this capability
        return $targetRoleId >= $requiredRoleId;
    }

    // ═══════════════════════════════════════════════════════
    // CHECK #4: Verify target user exists and role is valid
    // ═══════════════════════════════════════════════════════
    public function validateTarget($targetUserId, $action) {
        $stmt = $this->conn->prepare(
            "SELECT role_id FROM users WHERE id = ?"
        );
        $stmt->bind_param('i', $targetUserId);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows == 0) {
            throw new Exception('Target user not found');
        }

        $targetRoleId = $result->fetch_assoc()['role_id'];

        // Cannot manage yourself
        if ($targetUserId == $this->actorId) {
            throw new Exception('Cannot manage your own capabilities');
        }

        // Check hierarchy
        if (!$this->canManageRole($targetRoleId)) {
            throw new Exception('Insufficient privilege to manage this user');
        }

        return $targetRoleId;
    }
}
```

### **Example 1: SuperAdmin Granting Capability to Admin**

```php
// File: backend/grant_capability.php
// Scenario: SuperAdmin (ID=1) grants "edit_employee_caps" to Admin (ID=2)

header('Content-Type: application/json');

$input = json_decode(file_get_contents('php://input'), true);
$actorId = $input['actor_id'];         // 1 (SuperAdmin)
$targetUserId = $input['target_id'];   // 2 (Admin)
$capabilityKey = $input['capability']; // 'edit_employee_caps'
$action = $input['action'];            // 'GRANT' or 'REVOKE'

try {
    $validator = new PermissionValidator($conn, $actorId);

    // ════════════════════════════════════════════════════════
    // VALIDATION CHAIN
    // ════════════════════════════════════════════════════════

    // 1️⃣  Does SuperAdmin have "edit_admin_caps" capability?
    if (!$validator->hasCapability('edit_admin_caps')) {
        throw new Exception('You lack edit_admin_caps capability');
    }

    // 2️⃣  Get capability ID for 'edit_employee_caps'
    $stmt = $conn->prepare("SELECT id FROM capabilities WHERE capability_key = ?");
    $stmt->bind_param('s', $capabilityKey);
    $stmt->execute();
    $capabilityId = $stmt->get_result()->fetch_assoc()['id'];

    // 3️⃣  Can SuperAdmin grant this capability to Admin role?
    $targetRoleId = $validator->validateTarget($targetUserId, $action);

    if (!$validator->canGrantCapability($capabilityId, $targetRoleId)) {
        throw new Exception('Cannot grant this capability to target role');
    }

    // ════════════════════════════════════════════════════════
    // EXECUTE OPERATION
    // ════════════════════════════════════════════════════════

    if ($action === 'GRANT') {
        // Check if already granted
        $checkStmt = $conn->prepare(
            "SELECT id FROM user_capabilities
             WHERE user_id = ? AND capability_id = ?"
        );
        $checkStmt->bind_param('ii', $targetUserId, $capabilityId);
        $checkStmt->execute();

        if ($checkStmt->get_result()->num_rows == 0) {
            $grantStmt = $conn->prepare(
                "INSERT INTO user_capabilities
                 (user_id, capability_id, granted_by_id)
                 VALUES (?, ?, ?)"
            );
            $grantStmt->bind_param('iii', $targetUserId, $capabilityId, $actorId);
            $grantStmt->execute();

            // Log audit
            $auditStmt = $conn->prepare(
                "INSERT INTO capability_audit_log
                 (actor_id, target_id, action, capability_id)
                 VALUES (?, ?, 'GRANT', ?)"
            );
            $auditStmt->bind_param('iii', $actorId, $targetUserId, $capabilityId);
            $auditStmt->execute();

            echo json_encode(['success' => true, 'message' => 'Capability granted']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Already has this capability']);
        }
    } else {
        // REVOKE logic here (similar but DELETE instead of INSERT)
    }

} catch (Exception $e) {
    http_response_code(403);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
```

### **Example 2: Admin Granting Capability to Employee**

```php
// File: backend/grant_capability.php (SAME FILE - different execution)
// Scenario: Admin (ID=2) grants "view_entries" to Employee (ID=3)

// VALIDATION CHAIN EXECUTION:

// ✅ PASS: Does Admin have "edit_employee_caps" capability?
validator->hasCapability('edit_employee_caps') // TRUE

// ✅ PASS: Is target (Employee ID=3) within Admin's authority?
validator->canManageRole(3) // TRUE (Admin role=2 can manage Employee role=3)

// ✅ PASS: Can this capability be granted to Employee role?
validator->canGrantCapability(capId, 3) // TRUE

// ✅ GRANT SUCCEEDS
// New row added to user_capabilities: { user_id: 3, capability_id: 1, granted_by_id: 2 }

// ═════════════════════════════════════════════════════════════
// SAME SCENARIO: Admin tries to grant "edit_admin_caps" to Employee
// ═════════════════════════════════════════════════════════════

// ✅ PASS: Does Admin have "edit_employee_caps" capability?
validator->hasCapability('edit_employee_caps') // TRUE

// ❌ FAIL: canGrantCapability check
// Reason: "edit_admin_caps" requires role_id >= 2 (Admin level)
// But Employee is role_id = 3 (lower level)
// Actually... this needs different logic:

// CORRECTED LOGIC:
// "edit_admin_caps" is marked: required_role_id = 1 (SuperAdmin only)
// Admin (role_id=2) cannot grant SuperAdmin-only capabilities
// Throws: "Cannot grant SuperAdmin-level capability as Admin"
```

### **Example 3: Employee Cannot Perform Admin Actions**

```php
// Scenario: Employee (ID=3) tries to execute grant_capability.php

$validator = new PermissionValidator($conn, 3); // Employee ID

// ❌ FAIL: Does Employee have "edit_employee_caps" capability?
validator->hasCapability('edit_employee_caps') // FALSE

// Response: 403 Forbidden
{
    "success": false,
    "error": "You lack edit_employee_caps capability"
}

// Result: Operation never proceeds to role check
// Employee CANNOT grant any capability to anyone (including themselves)
```

---

## STEP 5: CAPABILITY MANAGEMENT SYSTEM

### **SuperAdmin Capability Editor (UI Component)**

```jsx
// File: frontend/src/CapabilityManager.jsx
// NEW - Component for SuperAdmin to manage capabilities

import { useState, useEffect } from "react";
import styles from "./css/CapabilityManager.module.css";

export default function CapabilityManager() {
  const [users, setUsers] = useState([]);
  const [selectedUser, setSelectedUser] = useState(null);
  const [selectedCapabilities, setSelectedCapabilities] = useState([]);
  const [allCapabilities, setAllCapabilities] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadUsers();
    loadCapabilities();
  }, []);

  const loadUsers = async () => {
    // Fetch all users (Admins and Employees)
    // Filter out own user
    const response = await fetch("http://localhost:8080/get_all_users.php");
    const data = await response.json();
    setUsers(
      data.users.filter((u) => u.id !== sessionStorage.getItem("user_id")),
    );
    setLoading(false);
  };

  const loadCapabilities = async () => {
    // Fetch all capabilities that SuperAdmin can grant
    const response = await fetch("http://localhost:8080/get_capabilities.php");
    const data = await response.json();
    setAllCapabilities(data.capabilities);
  };

  const handleUserSelect = async (userId) => {
    setSelectedUser(userId);

    // Fetch current capabilities for this user
    const response = await fetch(
      `http://localhost:8080/get_user_capabilities.php?user_id=${userId}`,
    );
    const data = await response.json();
    setSelectedCapabilities(data.capabilities.map((c) => c.id));
  };

  const handleCapabilityToggle = async (capabilityId, isGranting) => {
    const response = await fetch("http://localhost:8080/grant_capability.php", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        actor_id: sessionStorage.getItem("user_id"),
        target_id: selectedUser,
        capability_id: capabilityId,
        action: isGranting ? "GRANT" : "REVOKE",
      }),
    });

    const data = await response.json();

    if (data.success) {
      if (isGranting) {
        setSelectedCapabilities([...selectedCapabilities, capabilityId]);
      } else {
        setSelectedCapabilities(
          selectedCapabilities.filter((id) => id !== capabilityId),
        );
      }
    } else {
      alert(`Error: ${data.error}`);
    }
  };

  return (
    <div className={styles.container}>
      <h2>🔐 Capability Manager</h2>

      <div className={styles.mainGrid}>
        {/* LEFT: User List */}
        <div className={styles.userList}>
          <h3>Select User</h3>
          {loading ? (
            <p>Loading users...</p>
          ) : (
            users.map((user) => (
              <div
                key={user.id}
                className={`${styles.userItem} ${
                  selectedUser === user.id ? styles.selected : ""
                }`}
                onClick={() => handleUserSelect(user.id)}
              >
                <div className={styles.userName}>{user.username}</div>
                <div className={styles.userRole}>{user.role_name}</div>
              </div>
            ))
          )}
        </div>

        {/* RIGHT: Capability Grid */}
        <div className={styles.capabilityGrid}>
          {selectedUser ? (
            <>
              <h3>Manage Capabilities</h3>
              <div className={styles.capabilities}>
                {allCapabilities.map((cap) => (
                  <div key={cap.id} className={styles.capabilityCard}>
                    <div className={styles.capHeader}>
                      <strong>{cap.capability_key}</strong>
                      <span className={styles.category}>{cap.category}</span>
                    </div>
                    <label className={styles.checkbox}>
                      <input
                        type="checkbox"
                        checked={selectedCapabilities.includes(cap.id)}
                        onChange={(e) =>
                          handleCapabilityToggle(cap.id, e.target.checked)
                        }
                      />
                      {selectedCapabilities.includes(cap.id)
                        ? "✓ Granted"
                        : "○ Not Granted"}
                    </label>
                  </div>
                ))}
              </div>
            </>
          ) : (
            <p>← Select a user to manage capabilities</p>
          )}
        </div>
      </div>
    </div>
  );
}
```

### **Admin Capability Editor (Limited Version)**

```jsx
// File: frontend/src/AdminCapabilityEditor.jsx
// Admins can ONLY edit Employee capabilities

export default function AdminCapabilityEditor() {
  const [employees, setEmployees] = useState([]);
  const [employeeCapabilities, setEmployeeCapabilities] = useState([]);
  const [selectedEmployee, setSelectedEmployee] = useState(null);

  useEffect(() => {
    // RESTRICTED: Only load Employees (role_id = 3)
    loadEmployees();
  }, []);

  const loadEmployees = async () => {
    const response = await fetch(
      "http://localhost:8080/get_employees.php", // Only returns role_id=3
    );
    const data = await response.json();
    setEmployees(data.employees);
  };

  // Note: allCapabilities will be FILTERED on backend
  // to only show capabilities that:
  //  1. This Admin can grant (required_role_id >= 3)
  //  2. Are appropriate for Employees

  return (
    <div>
      <h3>👥 Manage Employee Capabilities</h3>
      {/* Same UI as SuperAdmin version, but restricted data */}
    </div>
  );
}
```

### **Employee View Capabilities (Read-Only)**

```jsx
// File: frontend/src/EmployeeCapabilities.jsx
// Employees can ONLY VIEW their assigned capabilities (read-only)

export default function EmployeeCapabilities() {
  const [capabilities, setCapabilities] = useState([]);

  useEffect(() => {
    loadOwnCapabilities();
  }, []);

  const loadOwnCapabilities = async () => {
    const response = await fetch(
      "http://localhost:8080/get_own_capabilities.php",
    );
    const data = await response.json();
    setCapabilities(data.capabilities);
  };

  return (
    <div className={styles.readOnlyContainer}>
      <h3>📋 Your Assigned Capabilities</h3>
      <p className={styles.note}>
        ⓘ These capabilities are assigned by your administrator. You cannot
        modify them.
      </p>

      <div className={styles.capList}>
        {capabilities.map((cap) => (
          <div key={cap.id} className={styles.capItem}>
            <span className={styles.capName}>✓ {cap.capability_key}</span>
            <span className={styles.capDesc}>{cap.description}</span>
          </div>
        ))}
      </div>

      {/* Disabled checkboxes - for visual reference only */}
      {/* NO grant/revoke buttons exist for Employees */}
    </div>
  );
}
```

---

## STEP 6: ENHANCED RBAC DESIGN WITH MIDDLEWARE

### **Backend Middleware (NEW)**

```php
// File: backend/middleware/RoleBasedMiddleware.php
// Centralized middleware for ALL protected routes

class RoleBasedMiddleware {
    private $conn;
    private $userId;
    private $requiredCapabilities = [];
    private $requiredMinRole = null;

    public function __construct($conn, $userId) {
        $this->conn = $conn;
        $this->userId = $userId;
    }

    /**
     * Verify user has required capability
     * Usage: $middleware->requireCapability('edit_employees')->validate()
     */
    public function requireCapability($capabilityKey) {
        $this->requiredCapabilities[] = $capabilityKey;
        return $this;
    }

    /**
     * Verify user has minimum role level
     * Usage: $middleware->requireMinRole(2)->validate() // Admin or above
     */
    public function requireMinRole($roleId) {
        $this->requiredMinRole = $roleId;
        return $this;
    }

    public function validate() {
        try {
            // Get user's role and capabilities
            $stmt = $this->conn->prepare(
                "SELECT u.role_id, GROUP_CONCAT(c.capability_key) as caps
                 FROM users u
                 LEFT JOIN user_capabilities uc ON u.id = uc.user_id
                 LEFT JOIN capabilities c ON uc.capability_id = c.id
                 WHERE u.id = ? GROUP BY u.id"
            );
            $stmt->bind_param('i', $this->userId);
            $stmt->execute();
            $result = $stmt->get_result()->fetch_assoc();

            if (!$result) {
                throw new Exception('User not found');
            }

            $userRoleId = $result['role_id'];
            $userCapabilities = explode(',', $result['caps'] ?? '');

            // Check minimum role requirement
            if ($this->requiredMinRole && $userRoleId < $this->requiredMinRole) {
                throw new Exception('Insufficient role level');
            }

            // Check required capabilities
            foreach ($this->requiredCapabilities as $requiredCap) {
                if (!in_array($requiredCap, $userCapabilities)) {
                    throw new Exception("Missing required capability: $requiredCap");
                }
            }

            return true;

        } catch (Exception $e) {
            http_response_code(403);
            exit(json_encode([
                'success' => false,
                'error' => $e->getMessage()
            ]));
        }
    }
}
```

### **Using Middleware in Routes**

```php
// File: backend/delete_admin.php
// BEFORE: No capability checks

$adminId = $_POST['admin_id'];
$conn->query("DELETE FROM users WHERE id = $adminId");

// ═════════════════════════════════════════════════════════════

// File: backend/delete_admin.php
// AFTER: With middleware validation

header('Content-Type: application/json');

$input = json_decode(file_get_contents('php://input'), true);
$adminId = $input['admin_id'];
$actorId = $input['actor_id'] ?? $_SESSION['user_id'];

try {
    // Validate user has required capability
    $middleware = new RoleBasedMiddleware($conn, $actorId);
    $middleware->requireCapability('delete_admin')
              ->requireMinRole(1)  // SuperAdmin only
              ->validate();

    // Check target is actually an admin
    $stmt = $conn->prepare("SELECT role_id FROM users WHERE id = ?");
    $stmt->bind_param('i', $adminId);
    $stmt->execute();
    $result = $stmt->get_result()->fetch_assoc();

    if (!$result || $result['role_id'] >= 2) {
        throw new Exception('Target is not a SuperAdmin-managed user');
    }

    // Perform deletion
    $deleteStmt = $conn->prepare("DELETE FROM users WHERE id = ?");
    $deleteStmt->bind_param('i', $adminId);
    $deleteStmt->execute();

    // Log audit
    logAudit($conn, $actorId, $adminId, 'DELETE_ADMIN');

    echo json_encode(['success' => true, 'message' => 'Admin deleted']);

} catch (Exception $e) {
    http_response_code(403);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
```

---

## STEP 7: COMPLETE SYSTEM ARCHITECTURE

### **Request Flow Diagram**

```
┌─────────────────────────────────────────────────────────────┐
│ CLIENT REQUEST (Frontend)                                   │
│ POST /grant_capability.php                                  │
│ { actor_id: 1, target_id: 2, capability_id: 6, ... }       │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 1. PARSE & VALIDATE INPUT                                   │
│    - Check JSON structure                                   │
│    - Verify required fields                                 │
│    - Sanitize inputs                                        │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. MIDDLEWARE AUTHENTICATION & AUTHORIZATION                │
│                                                             │
│    RoleBasedMiddleware::validate()                          │
│    ├─ Load actor's role_id and capabilities                │
│    ├─ Check: Does actor have "edit_admin_caps"? ✓          │
│    ├─ Check: Minimum role check (SuperAdmin?) ✓            │
│    └─ Continue if ALL pass                                  │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. BUSINESS LOGIC VALIDATION                                │
│                                                             │
│    ├─ Load target user's role_id                           │
│    ├─ Verify hierarchy: Actor can manage Target? ✓         │
│    ├─ Verify capability can be granted to role? ✓          │
│    ├─ Prevent self-management? ✓                           │
│    └─ Continue if ALL checks pass                          │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. DATABASE TRANSACTION                                     │
│                                                             │
│    BEGIN;                                                   │
│    INSERT INTO user_capabilities (...)                      │
│    INSERT INTO capability_audit_log (...)                   │
│    COMMIT;                                                  │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. SUCCESS RESPONSE                                         │
│                                                             │
│    {                                                        │
│      "success": true,                                       │
│      "message": "Capability granted",                       │
│      "updated_at": "2026-03-28T..."                         │
│    }                                                        │
└─────────────────────────────────────────────────────────────┘

FAILURE PATHS:

Failure at Step 2 (Auth):
    ├─ 403 Forbidden: "You lack edit_admin_caps capability"
    ├─ 403 Forbidden: "Insufficient role level"
    └─ Return error, log failed attempt

Failure at Step 3 (Business):
    ├─ 403 Forbidden: "Cannot manage admin-level users"
    ├─ 403 Forbidden: "Cannot grant AdminSuper only capability"
    ├─ 403 Forbidden: "Cannot manage yourself"
    └─ Return error, log failed attempt

Failure at Step 4 (Database):
    ├─ 500 Internal Error: "Database transaction failed"
    ├─ Rollback changes
    └─ Log error for debugging
```

---

## KEY IMPROVEMENTS SUMMARY

### **Security Enhancements**

| Enhancement                      | Benefit                                       |
| -------------------------------- | --------------------------------------------- |
| **Role Hierarchy Validation**    | Admin cannot manage other Admins              |
| **Capability-Level Checks**      | Fine-grained permission validation            |
| **Audit Trail**                  | Track who changed whose capabilities          |
| **Principle of Least Privilege** | Employees have minimal permissions by default |
| **Middleware Validation**        | Centralized access control                    |

### **Scalability Features**

| Feature                          | Benefit                                               |
| -------------------------------- | ----------------------------------------------------- |
| **Database-Driven Capabilities** | Add new permissions without code changes              |
| **User-Specific Capabilities**   | Customize permissions per user                        |
| **Audit Logging**                | Full compliance and debugging trail                   |
| **Permission Inheritance**       | Hierarchy determines default capabilities             |
| **Dynamic UI Rendering**         | Interface changes based on user's actual capabilities |

### **Current System → New System**

```
BEFORE:
├─ Hardcoded permissions per role
├─ No capability grants
├─ No hierarchy validation
├─ No audit trail
└─ Admins cannot manage other admins ✓ but no Self-management prevention

AFTER:
├─ Dynamic capabilities per user (can override role defaults)
├─ Full capability grant/revoke system
├─ Strict hierarchy validation (Admin only manages Employees)
├─ Complete audit trail (who changed what, when)
├─ Self-management protection
├─ Permission inheritance with overrides
├─ Role-level requirements for capabilities
├─ Middleware validation framework
└─ Multi-level permission checks
```

---

**Next Step: Implement database migrations and backend endpoints**
