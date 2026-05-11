# SuperAdmin & Role Management - Quick Reference Guide

## 🚀 What's New?

Your ICS system now includes:

- ✅ Login validation (users cannot bypass OTP to access dashboard)
- ✅ Role-based access control (SuperAdmin, Admin, User)
- ✅ SuperAdmin dashboard to create/delete admin accounts
- ✅ Complete audit logging of all admin actions
- ✅ Database tables for user management

---

## 📋 Default Credentials

After running the database migration:

```
Username: superadmin
Password: SuperAdmin@2026
⚠️  CHANGE THIS IMMEDIATELY AFTER FIRST LOGIN!
```

---

## 🔐 Access Routes

| URL                                | Protected             | Purpose            |
| ---------------------------------- | --------------------- | ------------------ |
| `http://127.0.0.1:3000/`           | No                    | Login page         |
| `http://127.0.0.1:3000/verify-otp` | Yes (OTP Session)     | OTP verification   |
| `http://127.0.0.1:3000/dashboard`  | Yes (Session Token)   | Main inventory app |
| `http://127.0.0.1:3000/superadmin` | Yes (SuperAdmin Only) | Admin management   |

---

## ⚙️ Quick Setup (10 Minutes)

### 1. Run Database Migration

```bash
curl http://localhost:8080/database/create_user_management_tables.php
```

Expected: ✅ Response with success message

### 2. Start the Application

```bash
docker-compose up
# Frontend: npm start
```

### 3. Test Login

- Visit `http://127.0.0.1:3000/`
- Username: `superadmin`
- Password: `SuperAdmin@2026`
- Enter OTP from email
- **SuperAdmin** → Redirected to `/superadmin`
- **Admin** → Redirected to `/dashboard`

### 4. Create First Admin (optional)

1. On `/superadmin` page
2. Click "Show Form"
3. Fill in admin details (min 8 char password)
4. Select permissions
5. Click "Create Admin Account"

---

## 📊 Database Tables

### user_roles

```
SuperAdmin - Full system access
Admin - Inventory management
```

### users

```
id, username, email, password_hash, role_id, is_superadmin
```

### admin_accounts

```
admin_user_id, created_by_superadmin_id, permissions, is_active
```

### audit_logs

```
admin_id, action, action_details, ip_address, created_at
```

---

## 🛡️ Security

| Feature            | Implementation                 |
| ------------------ | ------------------------------ |
| Password Hashing   | BCRYPT (PHP's password_hash)   |
| OTP Expiry         | 5 minutes                      |
| Session Token      | 32-byte random (crypto-secure) |
| Audit Trail        | All SuperAdmin actions logged  |
| Email Verification | OTP sent via Gmail SMTP        |

---

## 🔧 Admin Permissions

When creating admin accounts, choose:

- ✓ View Entries
- ✓ Create Entries
- ✓ Edit Entries
- ✓ Delete Entries
- ✓ View Users
- ✓ Change Inventory

---

## ❌ What Users CANNOT Do

- ❌ Access `/dashboard` without session_token
- ❌ Access `/superadmin` as non-SuperAdmin
- ❌ Skip OTP verification
- ❌ Create admin accounts (non-SuperAdmin)
- ❌ Delete admin accounts (non-SuperAdmin)

---

## 🔄 Login Flow

```
User → Login Form → Verify Credentials → Send OTP
  → Enter OTP → Verify OTP Code → Create Session Token
  → Store in sessionStorage → Redirect by Role
```

---

## 📱 File Locations

**Backend:**

- Database migration: `backend/database/create_user_management_tables.php`
- Create admin: `backend/create_admin.php`
- Get admins: `backend/get_admins.php`
- Delete admin: `backend/delete_admin.php`

**Frontend:**

- SuperAdmin page: `frontend/src/SuperAdminPage.jsx`
- SuperAdmin CSS: `frontend/src/css/SuperAdminPage.module.css`
- Updated routing: `frontend/src/App.jsx`

**Documentation:**

- Full setup guide: `ROLE_BASED_ACCESS_SETUP.md`
- This file: `ROLE_BASED_ACCESS_QUICK_REFERENCE.md`

---

## 🐛 Troubleshooting

| Problem                   | Solution                                           |
| ------------------------- | -------------------------------------------------- |
| Migration fails           | Check database connection, verify MySQL is running |
| Cannot access /superadmin | Ensure you're logged in as SuperAdmin user         |
| Session validation fails  | Clear sessionStorage and log in again              |
| Admin creation fails      | Verify all required fields are filled              |
| Emails not received       | Check Gmail SMTP credentials in docker-compose.yml |

---

## 💾 Useful Database Queries

**Get all SuperAdmins:**

```sql
SELECT * FROM users WHERE is_superadmin = TRUE;
```

**Get all Admins:**

```sql
SELECT * FROM admin_accounts WHERE is_active = TRUE;
```

**View admin actions:**

```sql
SELECT * FROM audit_logs ORDER BY created_at DESC LIMIT 20;
```

---

## 📞 Support Documentation

- `ROLE_BASED_ACCESS_SETUP.md` - Complete setup & troubleshooting
- `SETUP_OTP.md` - OTP system documentation
- `README_OTP.md` - OTP quick reference

---

**Status**: ✅ Ready to Deploy  
**Version**: 1.0  
**Last Updated**: March 28, 2026
