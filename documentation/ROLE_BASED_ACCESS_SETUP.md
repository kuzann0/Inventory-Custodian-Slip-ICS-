# Login Validation & SuperAdmin Role Management - Complete Setup Guide

## System Overview

This document provides complete setup instructions for implementing login validation with role-based access control and SuperAdmin account management.

### What's Being Implemented

1. **Login Validation**
   - Users cannot access `/dashboard` without valid OTP verification
   - Unauthenticated users are redirected to `/` (login page)
   - Session tokens stored in sessionStorage validate access

2. **Role-Based Access Control**
   - SuperAdmin: Can create and manage Admin accounts
   - Admin: Can access inventory management features
   - Users without valid sessions: Redirected to login

3. **Database Structure**
   - `user_roles` - Role definitions (SuperAdmin, Admin)
   - `users` - User accounts with role assignments
   - `admin_accounts` - Records of Admin accounts created by SuperAdmin
   - `audit_logs` - Complete audit trail of admin actions

4. **SuperAdmin Dashboard**
   - Create new Admin accounts with customizable permissions
   - View list of existing Admin accounts
   - Delete Admin accounts with confirmation
   - Complete audit logging of all actions

---

## Project Structure Verification

### Current Project Structure

```
ICS Project Root:
├── backend/
│   ├── database/
│   │   ├── entries_backup.sql          ✓ Existing
│   │   └── create_user_management_tables.php  ✓ NEW
│   ├── src/
│   │   ├── AuthService.php             ✓ Existing
│   │   ├── OTPService.php              ✓ Existing
│   │   └── MailService.php             ✓ Existing
│   ├── login.php                       ✓ Existing (will be enhanced)
│   ├── verify_otp.php                  ✓ Existing (will be enhanced)
│   ├── create_admin.php                ✓ NEW
│   ├── get_admins.php                  ✓ NEW
│   ├── delete_admin.php                ✓ NEW
│   └── docker-compose.yml              ✓ Existing
│
├── frontend/src/
│   ├── App.jsx                         ✓ UPDATED with SuperAdmin route
│   ├── LoginForm.jsx                   ✓ Existing
│   ├── OTPInput.jsx                    ✓ Existing (need to update)
│   ├── SuperAdminPage.jsx              ✓ NEW
│   └── css/
│       ├── LoginForm.module.css        ✓ Existing
│       ├── OTPInput.module.css         ✓ Existing
│       └── SuperAdminPage.module.css   ✓ NEW (MARINA theme)
│
└── documentation/
    └── ROLE_BASED_ACCESS_SETUP.md      ✓ This file
```

### Verification Checklist

- [ ] All backend PHP files created (create_admin.php, get_admins.php, delete_admin.php)
- [ ] Database migration file created (create_user_management_tables.php)
- [ ] SuperAdminPage.jsx component created
- [ ] SuperAdminPage.module.css styling created
- [ ] App.jsx updated with SuperAdmin route
- [ ] OTPInput.jsx needs update to store role information
- [ ] verify_otp.php needs update to return role information

---

## Step 1: Database Setup

### 1.1 Run User Management Tables Migration

This creates all necessary tables for user management. Choose one method:

**Method A: Using HTTP Request (Recommended - Automatic)**

```bash
curl http://localhost:8080/database/create_user_management_tables.php
```

**Method B: Manual via phpMyAdmin**

1. Open phpMyAdmin at `http://localhost/phpmyadmin`
2. Select your database (my_app_db)
3. Click the SQL tab
4. Open `backend/database/create_user_management_tables.php` and copy the SQL
5. Paste into phpMyAdmin and execute

### 1.2 Verify Tables Created

Check that these 4 tables exist in phpMyAdmin:

1. **user_roles**
   - Columns: id, role_name, role_description, permissions (JSON), is_active, created_at, updated_at
   - Rows: SuperAdmin, Admin (2 default roles)

2. **users**
   - Columns: id, username, email, password_hash, role_id, account_status, is_superadmin, last_login, created_at
   - Default row: superadmin account with default password

3. **admin_accounts**
   - Columns: id, admin_user_id, created_by_superadmin_id, username, email, permissions (JSON), is_active
   - Links users to their admin record

4. **audit_logs**
   - Columns: id, admin_id, action, action_details (JSON), ip_address, user_agent, created_at
   - Records all SuperAdmin actions

### 1.3 Default SuperAdmin Account

After migration, your default SuperAdmin account is:

```
Username: superadmin
Email: superadmin@ics.local
Password: SuperAdmin@2026
⚠️  IMPORTANT: Change this password immediately after first login!
```

---

## Step 2: Backend Updates

### 2.1 Update verify_otp.php

The `verify_otp.php` endpoint needs to return user role information. Add this after successful OTP verification:

In `backend/verify_otp.php`, find the success response and update it to include role:

```php
// After successful OTP verification, add role to response:
$userRole = getUserRoleFromDatabase($userId); // You need to fetch this

echo json_encode([
    'success' => true,
    'message' => 'OTP verified successfully',
    'email' => $email,
    'session_token' => $sessionToken,
    'user_role' => $userRole,  // ADD THIS LINE
    'user_id' => $userId,      // ADD THIS LINE
    'is_superadmin' => $isSuperAdmin  // ADD THIS LINE
]);
```

### 2.2 SQL Query Helper

Add this helper function to `verify_otp.php` to fetch user role:

```php
function getUserRoleFromDatabase($userId, $db) {
    $query = "
        SELECT ur.role_name, u.is_superadmin
        FROM users u
        JOIN user_roles ur ON u.role_id = ur.id
        WHERE u.id = ?
    ";
    $stmt = $db->prepare($query);
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        return [
            'role_name' => $row['role_name'],
            'is_superadmin' => (bool)$row['is_superadmin']
        ];
    }
    return ['role_name' => 'User', 'is_superadmin' => false];
}
```

---

## Step 3: Frontend Updates

### 3.1 Update OTPInput.jsx

Update the OTPInput.jsx component to store role information after successful verification:

In `frontend/src/OTPInput.jsx`, find the success response handling:

```javascript
// After successful OTP verification, update this section:
if (data.success) {
  setSuccess("OTP verified! Redirecting...");

  // Store session information
  sessionStorage.setItem("session_token", data.session_token);
  sessionStorage.setItem("verified_email", data.email);
  sessionStorage.setItem("user_id", data.user_id); // ADD
  sessionStorage.setItem("user_role", data.user_role); // ADD
  sessionStorage.setItem("is_superadmin", data.is_superadmin); // ADD
  sessionStorage.removeItem("otp_id");
  sessionStorage.removeItem("user_email");

  // Redirect to dashboard (or /superadmin if SuperAdmin)
  setTimeout(() => {
    if (data.is_superadmin) {
      window.location.href = "/superadmin";
    } else {
      window.location.href = "/dashboard";
    }
  }, 1500);
}
```

### 3.2 Verify App.jsx Routes

App.jsx now has these routes:

| Route         | Access          | Purpose            |
| ------------- | --------------- | ------------------ |
| `/`           | Public          | Login page         |
| `/verify-otp` | OTP Session     | OTP verification   |
| `/dashboard`  | Session Token   | Main inventory app |
| `/superadmin` | SuperAdmin Only | Admin management   |

---

## Step 4: Testing the System

### 4.1 Test Login Validation

**Test 1: Unauthenticated Access**

1. Visit `http://127.0.0.1:3000/dashboard` directly
2. Expected: Redirected to `/` (login page)
3. Verify: URL changes to `http://127.0.0.1:3000/`

**Test 2: Valid Login Flow**

1. Visit login page: `http://127.0.0.1:3000/`
2. Enter credentials: `superadmin` / `SuperAdmin@2026`
3. Receive OTP in email
4. Enter OTP code
5. Expected: Redirected to `/superadmin` (SuperAdmin dashboard)
6. Verify: URL shows `http://127.0.0.1:3000/superadmin`

**Test 3: Session Persistence**

1. After successful login, check browser's Developer Tools
2. Open Console → Type: `sessionStorage`
3. Verify these keys exist:
   ```
   - session_token
   - verified_email
   - user_id
   - user_role (should be "SuperAdmin")
   - is_superadmin (should be "true")
   ```

### 4.2 Test SuperAdmin Dashboard

**Test 1: Create Admin Account**

1. On `/superadmin` page, click "Show Form"
2. Fill in form:
   - Username: `testadmin`
   - Email: `testadmin@example.com`
   - Password: `TestPassword123`
   - Permissions: Select at least one
3. Click "Create Admin Account"
4. Expected: Success message and new admin appears in list

**Test 2: Delete Admin Account**

1. In admin list, find a test admin
2. Click "Delete" button
3. Confirm deletion
4. Expected: Admin removed from list, success message displayed

**Test 3: Refresh Admin List**

1. Click "Refresh" button on admin section header
2. Expected: Page updates with latest admin list

### 4.3 Database Verification

In phpMyAdmin, verify:

**Check users table:**

```sql
SELECT * FROM users;
```

Expected: superadmin account + any created admins

**Check admin_accounts table:**

```sql
SELECT * FROM admin_accounts;
```

Expected: Records for each admin created

**Check audit_logs table:**

```sql
SELECT * FROM audit_logs ORDER BY created_at DESC;
```

Expected: Entries for each admin create/delete action

---

## Step 5: Creating Admin Accounts

### 5.1 Default Credentials for Testing

Initial account (created by migration):

```
Username: superadmin
Password: SuperAdmin@2026
```

### 5.2 Creating New Admin Accounts via SuperAdmin Dashboard

1. Log in as `superadmin` user
2. You'll be redirected to `/superadmin` (SuperAdmin Dashboard)
3. Click "Show Form" under "Create New Admin Account"
4. Fill in the form:
   - **Username**: Unique username for the admin
   - **Email**: Admin's email address
   - **Password**: Minimum 8 characters (recommended: Mix of letters, numbers, symbols)
   - **Confirm Password**: Must match password field
   - **Permissions**: Check which actions this admin can perform:
     - View Entries
     - Create Entries
     - Edit Entries
     - Delete Entries
     - View Users
     - Change Inventory
   - **Notes**: Optional notes about this admin (e.g., "Created for Q2 2026 inventory audit")
5. Click "Create Admin Account"
6. Success message confirms account creation
7. Admin appears in the "Existing Admin Accounts" list

### 5.3 Admin Account Permissions

When creating an admin, you can customize permissions:

| Permission       | Description                     |
| ---------------- | ------------------------------- |
| View Entries     | Can view inventory entries      |
| Create Entries   | Can add new inventory entries   |
| Edit Entries     | Can modify existing entries     |
| Delete Entries   | Can remove entries from system  |
| View Users       | Can see list of users/admins    |
| Change Inventory | Can adjust inventory quantities |

---

## Step 6: Login Flow Diagram

```
User Visits http://127.0.0.1:3000
    ↓
    ├─→ Has session_token in sessionStorage?
    │   ├─ YES → Check role
    │   │   ├─ SuperAdmin? → Redirect to /superadmin
    │   │   └─ Admin? → Redirect to /dashboard
    │   └─ NO → Show login form
    │
    └─→ User enters credentials in LoginForm
        ↓
        Backend validates credentials (login.php)
        ↓
        If valid: Backend sends OTP email
        ↓
        Frontend redirects to /verify-otp
        ↓
        User enters 6-digit OTP
        ↓
        Backend validates OTP (verify_otp.php)
        ↓
        Backend creates session_token
        ↓
        Frontend stores in sessionStorage:
        - session_token
        - verified_email
        - user_id
        - user_role
        - is_superadmin
        ↓
        Frontend redirects based on role:
        - SuperAdmin → /superadmin
        - Admin/User → /dashboard
```

---

## Step 7: Access Control Rules

### What is Protected?

| Route         | Protection                           | Who Can Access                      |
| ------------- | ------------------------------------ | ----------------------------------- |
| `/`           | None                                 | Everyone (Public login page)        |
| `/verify-otp` | OTP Session Required                 | Users with otp_id in sessionStorage |
| `/dashboard`  | Session Token + Role                 | SuperAdmin, Admin, or User roles    |
| `/superadmin` | Session Token + SuperAdmin Role Only | Only SuperAdmin accounts            |

### Unauthorized Access Behavior

| Attempt                                               | Result                     |
| ----------------------------------------------------- | -------------------------- |
| Access `/dashboard` without session_token             | Redirected to `/`          |
| Access `/superadmin` as Admin user                    | Redirected to `/dashboard` |
| Access `/superadmin` as unauthenticated               | Redirected to `/`          |
| Try direct URL access to `/verify-otp` without otp_id | Redirected to `/`          |

---

## Step 8: Troubleshooting

### Issue: "Cannot GET /superadmin"

**Cause**: Frontend route not properly configured in App.jsx

**Solution**:

1. Verify App.jsx imports SuperAdminPage:
   ```javascript
   import SuperAdminPage from "./SuperAdminPage";
   ```
2. Verify `/superadmin` route exists in Routes
3. Restart development server: `npm start`

---

### Issue: "Admin account not found" when creating admins

**Cause**: Default SuperAdmin account not created by migration

**Solution**:

1. Run migration again:
   ```bash
   curl http://localhost:8080/database/create_user_management_tables.php
   ```
2. Check phpMyAdmin that superadmin user exists
3. Log in as superadmin to initialize

---

### Issue: Session Validation Fails on page refresh

**Cause**: sessionStorage cleared (browser clear data)

**Solution**:

1. Normal behavior - user must log in again
2. Option: Implement persistent login with cookies/localStorage
3. Check browser's Application tab → Session Storage

---

### Issue: "Access denied: User is not SuperAdmin"

**Cause**: User role not properly stored during OTP verification

**Solution**:

1. Verify verify_otp.php returns user_role
2. Check that OTPInput.jsx stores user_role in sessionStorage
3. Inspect sessionStorage in browser DevTools
4. Verify user_roles table has SuperAdmin role

---

## Step 9: Security Considerations

### Best Practices

1. **Change Default SuperAdmin Password**
   - After first login as 'superadmin', immediately change password
   - Use strong password: min 12 characters, mix of uppercase, lowercase, numbers, symbols

2. **Email Security**
   - OTP emails sent via Gmail SMTP (configured in backend)
   - OTP codes expire after 5 minutes
   - Keep MAIL_PASSWORD as environment variable

3. **Admin Deletion**
   - When deleting admin, associated user account is also deleted
   - Action is logged in audit_logs table
   - Consider archiving instead of deleting for production

4. **Audit Logging**
   - All SuperAdmin actions logged (CREATE_ADMIN, DELETE_ADMIN)
   - Includes IP address and user agent
   - Query audit_logs for compliance/investigation

5. **Password Hashing**
   - Passwords hashed with PHP's password_hash() using BCRYPT
   - Never stored in plain text
   - Verified with password_verify()

6. **Session Tokens**
   - Generated using random_bytes(32) - cryptographically secure
   - Stored in sessionStorage (not persistent across browser close)
   - Cleared on logout

---

## Step 10: Database Queries Reference

### Useful SQL Queries

**Get all SuperAdmin accounts:**

```sql
SELECT u.id, u.username, u.email, u.last_login
FROM users u
WHERE u.is_superadmin = TRUE;
```

**Get all Admin accounts:**

```sql
SELECT
    aa.id,
    aa.username,
    aa.email,
    aa.created_at,
    u.account_status
FROM admin_accounts aa
JOIN users u ON aa.admin_user_id = u.id
WHERE u.account_status = 'active'
ORDER BY aa.created_at DESC;
```

**Get SuperAdmin actions:**

```sql
SELECT
    admin_id,
    action,
    action_details,
    ip_address,
    created_at
FROM audit_logs
WHERE action LIKE '%ADMIN%'
ORDER BY created_at DESC
LIMIT 50;
```

**Deactivate an Admin:**

```sql
UPDATE users
SET account_status = 'inactive'
WHERE id = (SELECT admin_user_id FROM admin_accounts WHERE id = ?);
```

---

## Step 11: Production Deployment Checklist

Before going live, ensure:

- [ ] Database migration completed successfully
- [ ] Default SuperAdmin password changed
- [ ] All routes working (login, OTP, dashboard, superadmin)
- [ ] Session storage working correctly
- [ ] Admin creation working
- [ ] Admin deletion working
- [ ] Audit logging recording actions
- [ ] HTTPS enabled (not HTTP)
- [ ] EMAIL configuration verified
- [ ] Backup of database taken
- [ ] Admin users created for production
- [ ] User documentation provided

---

## Step 12: API Endpoints Reference

### Create Admin Account

```
POST /create_admin.php

Request:
{
  "username": "newadmin",
  "email": "newadmin@example.com",
  "password": "SecurePassword123",
  "confirmPassword": "SecurePassword123",
  "permissions": ["view_entries", "create_entries"],
  "notes": "Production admin account"
}

Response (Success - 201):
{
  "success": true,
  "message": "Admin account created successfully",
  "admin": {
    "id": 3,
    "username": "newadmin",
    "email": "newadmin@example.com",
    "role": "Admin",
    "created_at": "2026-03-28 10:30:00"
  }
}
```

### Get All Admins

```
GET /get_admins.php

Response (Success - 200):
{
  "success": true,
  "message": "Admins retrieved successfully",
  "total": 2,
  "admins": [
    {
      "id": 1,
      "admin_user_id": 2,
      "username": "testadmin",
      "email": "testadmin@example.com",
      "permissions": ["view_entries", "create_entries"],
      "is_active": true,
      "created_at": "2026-03-28 10:00:00",
      "updated_at": "2026-03-28 10:00:00"
    }
  ]
}
```

### Delete Admin Account

```
POST /delete_admin.php

Request:
{
  "admin_id": 1
}

Response (Success - 200):
{
  "success": true,
  "message": "Admin account deleted successfully",
  "deleted_username": "testadmin"
}
```

---

## Glossary

- **Session Token**: Cryptographically generated token stored in sessionStorage after OTP verification
- **OTP**: One-Time Password (6-digit code sent via email)
- **Role**: User category (SuperAdmin, Admin, User) that determines app permissions
- **SuperAdmin**: Account that can create and manage other admin accounts
- **Audit Log**: Record of all admin actions performed (who, what, when, where)
- **Permission**: Specific action that a role can perform (e.g., "Create Entries")

---

**Last Updated**: March 28, 2026  
**Status**: Complete & Ready for Deployment  
**Version**: 1.0
