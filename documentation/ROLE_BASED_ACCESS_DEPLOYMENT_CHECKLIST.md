# Role-Based Access Control - Deployment Checklist

Use this checklist to ensure complete and correct deployment of the login validation and role management system.

---

## Pre-Deployment

### Project Structure Verification

- [ ] `backend/database/create_user_management_tables.php` exists
- [ ] `backend/create_admin.php` exists
- [ ] `backend/get_admins.php` exists
- [ ] `backend/delete_admin.php` exists
- [ ] `frontend/src/SuperAdminPage.jsx` exists
- [ ] `frontend/src/css/SuperAdminPage.module.css` exists
- [ ] `frontend/src/App.jsx` contains SuperAdminRoute component
- [ ] `frontend/src/App.jsx` contains /superadmin route

### File Content Verification

- [ ] `create_user_management_tables.php` creates 4 tables (user_roles, users, admin_accounts, audit_logs)
- [ ] `SuperAdminPage.jsx` imports SuperAdminPage.module.css
- [ ] `App.jsx` imports SuperAdminPage component
- [ ] `App.jsx` has `<SuperAdminRoute>` component defined
- [ ] Routes include `/superadmin` path

---

## Database Setup

### Migration Execution

- [ ] Run migration via curl:
  ```bash
  curl http://localhost:8080/database/create_user_management_tables.php
  ```
- [ ] Receive success response
- [ ] No error messages in response

### Table Verification (phpMyAdmin)

- [ ] `user_roles` table exists
  - [ ] Has columns: id, role_name, role_description, permissions, is_active
  - [ ] Contains "SuperAdmin" role
  - [ ] Contains "Admin" role

- [ ] `users` table exists
  - [ ] Has columns: id, username, email, password_hash, role_id, is_superadmin
  - [ ] Has default user: superadmin / superadmin@ics.local
  - [ ] Super admin marked with is_superadmin = 1

- [ ] `admin_accounts` table exists
  - [ ] Has columns: id, admin_user_id, created_by_superadmin_id, permissions
  - [ ] Has foreign keys to users table

- [ ] `audit_logs` table exists
  - [ ] Has columns: id, admin_id, action, action_details, ip_address, created_at

---

## Backend Configuration

### File Permissions

- [ ] All new PHP files have correct permissions (644 or readable by web server)
- [ ] `create_user_management_tables.php` is accessible
- [ ] `create_admin.php` is accessible
- [ ] `get_admins.php` is accessible
- [ ] `delete_admin.php` is accessible

### CORS Headers

- [ ] All new PHP files include CORS headers:
  ```php
  header('Access-Control-Allow-Origin: *');
  header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
  header('Access-Control-Allow-Headers: Content-Type');
  ```

### Error Handling

- [ ] Test each endpoint returns proper JSON responses
- [ ] Error responses include helpful messages
- [ ] Success responses include required data

---

## Frontend Configuration

### Component Updates

- [ ] `SuperAdminPage.jsx` exports correctly:

  ```javascript
  export default SuperAdminPage;
  ```

- [ ] `SuperAdminPage.jsx` imports dependencies:
  - [ ] React hooks (useState, useEffect)
  - [ ] useNavigate from react-router-dom
  - [ ] CSS module: `SuperAdminPage.module.css`

- [ ] `App.jsx` imports SuperAdminPage:

  ```javascript
  import SuperAdminPage from "./SuperAdminPage";
  ```

- [ ] `App.jsx` has SuperAdminRoute component:
  - [ ] Checks session_token in sessionStorage
  - [ ] Checks user_role = 'SuperAdmin'
  - [ ] Checks is_superadmin = 'true'
  - [ ] Redirects non-SuperAdmin to /dashboard

### Route Configuration

- [ ] Routes in `App.jsx` include:
  - [ ] `<Route path="/" element={<LoginForm />} />` - Public
  - [ ] `<Route path="/verify-otp" element={<OTPRoute />} />` - OTP Session
  - [ ] `<Route path="/dashboard" element={<ProtectedRoute>...</ProtectedRoute>} />` - Session Token
  - [ ] `<Route path="/superadmin" element={<ProtectedRoute><SuperAdminRoute>...</SuperAdminRoute></ProtectedRoute>} />` - SuperAdmin Only

---

## CSS Styling

### SuperAdminPage.module.css

- [ ] File contains MARINA theme colors
- [ ] Primary color: hsl(229, 75%, 28%)
- [ ] Includes responsive media queries for mobile
- [ ] Contains classes:
  - [ ] `.container`
  - [ ] `.header`
  - [ ] `.form`, `.formGroup`, `.row`
  - [ ] `.adminsList`, `.adminCard`
  - [ ] `.successMessage`, `.errorMessage`
  - [ ] Mobile breakpoints (768px, 480px)

---

## Testing

### Login & Session

- [ ] Can log in with default credentials:
  - [ ] Username: `superadmin`
  - [ ] Password: `SuperAdmin@2026`

- [ ] OTP verification works:
  - [ ] OTP email received
  - [ ] OTP can be entered
  - [ ] Successful verification creates session

- [ ] Session storage validated:
  - [ ] `session_token` stored in sessionStorage
  - [ ] `user_role` stored (should be "SuperAdmin")
  - [ ] `is_superadmin` stored (should be "true")
  - [ ] `verified_email` stored

### Route Protection

- [ ] Cannot directly access `/dashboard` without session
  - [ ] Redirects to `/`
- [ ] Cannot directly access `/superadmin` without session
  - [ ] Redirects to `/`

- [ ] Cannot access `/superadmin` as non-SuperAdmin user
  - [ ] Redirects to `/dashboard`

- [ ] Can access `/dashboard` after OTP verification
  - [ ] Main app loads
  - [ ] Navbar and Header display

- [ ] Can access `/superadmin` as SuperAdmin
  - [ ] SuperAdmin page loads
  - [ ] "Create New Admin Account" section visible
  - [ ] Admin list displays

### SuperAdmin Functions

- [ ] **Create Admin**
  - [ ] Form displays all fields:
    - [ ] Username (required)
    - [ ] Email (required, validated)
    - [ ] Password (required, min 8 chars)
    - [ ] Confirm Password (must match)
    - [ ] Permissions (checkboxes)
    - [ ] Notes (optional)
  - [ ] Form validation works:
    - [ ] Cannot submit with empty fields
    - [ ] Cannot submit if passwords don't match
    - [ ] Cannot submit with password < 8 chars
  - [ ] Successful creation:
    - [ ] Success message displays
    - [ ] New admin appears in list
    - [ ] Admin record created in database

- [ ] **View Admins**
  - [ ] Admin list displays all created admins
  - [ ] Each admin card shows:
    - [ ] Username and email
    - [ ] Status (Active/Inactive)
    - [ ] Created date
    - [ ] Last login (if available)
    - [ ] Permissions assigned
    - [ ] Notes (if any)

- [ ] **Delete Admin**
  - [ ] Delete button visible on each admin card
  - [ ] Clicking delete shows confirmation
  - [ ] Confirmation prevents accidental deletion
  - [ ] Successful deletion:
    - [ ] Success message displays
    - [ ] Admin removed from list
    - [ ] Admin removed from database
    - [ ] Audit log entry created

- [ ] **Refresh Button**
  - [ ] Refresh button reloads admin list
  - [ ] Displays latest admins
  - [ ] Reflects deletions and new creations

### Database Verification

- [ ] Admin creation creates records in:
  - [ ] `users` table (new user row)
  - [ ] `admin_accounts` table (admin record)
  - [ ] `audit_logs` table (CREATE_ADMIN action)

- [ ] Admin deletion removes from:
  - [ ] `users` table
  - [ ] `admin_accounts` table
  - [ ] Creates entry in `audit_logs` (DELETE_ADMIN action)

- [ ] Audit logs contain:
  - [ ] Admin ID who performed action
  - [ ] Action type (CREATE_ADMIN, DELETE_ADMIN)
  - [ ] Action details (JSON)
  - [ ] IP address
  - [ ] User agent
  - [ ] Timestamp

---

## Performance & Error Handling

### API Response Times

- [ ] `GET /get_admins.php` responds in < 1 second
- [ ] `POST /create_admin.php` responds in < 2 seconds
- [ ] `POST /delete_admin.php` responds in < 1 second

### Error Scenarios

- [ ] Creating admin with duplicate username:
  - [ ] Returns error: "Username already exists"
- [ ] Creating admin with duplicate email:
  - [ ] Returns error: "Email already exists"

- [ ] Creating admin with invalid email:
  - [ ] Form validation prevents submission

- [ ] Deleting non-existent admin:
  - [ ] Returns error: "Admin not found"

- [ ] Database connection failure:
  - [ ] Returns error: "Database connection failed"
  - [ ] User sees helpful error message

---

## Browser Compatibility

- [ ] Works in Chrome/Chromium
- [ ] Works in Firefox
- [ ] Works in Safari
- [ ] Works in Edge
- [ ] Mobile responsive (tested on 480px width)
- [ ] Mobile responsive (tested on 768px width)

---

## Security Verification

### Password Security

- [ ] Passwords hashed with BCRYPT
- [ ] Passwords NOT stored in plain text
- [ ] Minimum 8 characters enforced
- [ ] Default password changed after first login

### Session Security

- [ ] Session tokens are 32-byte random
- [ ] Tokens stored in sessionStorage (not localStorage)
- [ ] No sensitive data in URLs
- [ ] CORS configured properly

### Admin Actions

- [ ] All admin creation logged in audit_logs
- [ ] All admin deletion logged in audit_logs
- [ ] IP addresses recorded
- [ ] User agents recorded
- [ ] Timestamps recorded

---

## Documentation

- [ ] `ROLE_BASED_ACCESS_SETUP.md` exists and contains:
  - [ ] System overview
  - [ ] Step-by-step setup instructions
  - [ ] Testing procedures
  - [ ] Troubleshooting section
  - [ ] API reference
  - [ ] Security considerations
- [ ] `ROLE_BASED_ACCESS_QUICK_REFERENCE.md` exists
- [ ] README files updated with new features

---

## Final Verification

### Full End-to-End Test

1. [ ] Start fresh: Clear browser storage
2. [ ] Visit `http://127.0.0.1:3000/`
3. [ ] Log in as superadmin
4. [ ] Receive OTP email
5. [ ] Enter OTP
6. [ ] Redirected to `/superadmin`
7. [ ] Create test admin account
8. [ ] See new admin in list
9. [ ] Delete test admin
10. [ ] Confirm deletion
11. [ ] Admin removed from list
12. [ ] Check audit_logs in database
13. [ ] Log out and log in again with different admin (if created)
14. [ ] Verify redirects to `/dashboard` (not `/superadmin`)

### Production Readiness Checklist

- [ ] All tests passing
- [ ] No console errors in browser DevTools
- [ ] No errors in server logs
- [ ] Database backups taken
- [ ] Default password will be changed
- [ ] HTTPS will be configured
- [ ] Email service verified working
- [ ] Admin users created for production
- [ ] User documentation prepared

---

## Sign-Off

| Item           | Responsible | Verified | Date   |
| -------------- | ----------- | -------- | ------ |
| Database Setup | Admin       | [ ]      | **\_** |
| Backend Code   | Admin       | [ ]      | **\_** |
| Frontend Code  | Admin       | [ ]      | **\_** |
| Testing        | QA          | [ ]      | **\_** |
| Documentation  | Admin       | [ ]      | **\_** |
| Final Approval | Manager     | [ ]      | **\_** |

---

## Deployment Approval

- [ ] All checklist items completed
- [ ] All tests passed
- [ ] Ready for production deployment

**Deployed By**: ******\_\_\_\_******  
**Date**: ******\_\_\_\_******  
**Notes**: **********************************\_\_\_\_**********************************

---

**Version**: 1.0  
**Last Updated**: March 28, 2026
