# ICS Gmail OTP Authentication System

Complete Gmail OTP (One-Time Password) two-factor authentication integration for the Inventory Custodian Slip (ICS) project.

## 🚀 Quick Start

**Get this system running in 5 minutes:**

1. Generate Gmail App Password
   - Visit [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)
   - Copy 16-character password

2. Update `docker-compose.yml` backend service environment:

```yaml
MAIL_HOST: smtp.gmail.com
MAIL_PORT: 587
MAIL_USERNAME: your-email@gmail.com
MAIL_PASSWORD: your-16-char-password
MAIL_ENCRYPTION: tls
MAIL_FROM_ADDRESS: your-email@gmail.com
ADMIN_BYPASS_KEY: generate-random-32-char-key
```

3. Restart container:

```bash
docker-compose restart ics-backend
```

4. Run database migration:

```bash
curl http://localhost:8080/database/migrate_otp.php
```

5. Test the flow:

- Login at `http://127.0.0.1:3000/`
- Check email for OTP
- Enter 6-digit code
- Access granted to main app

## 📚 Documentation

Choose based on your needs:

| Document                          | Purpose                | Read Time |
| --------------------------------- | ---------------------- | --------- |
| **OTP_QUICK_REFERENCE.md**        | Quick reference guide  | 5 min     |
| **SETUP_OTP.md**                  | Complete setup guide   | 20 min    |
| **OTP_DEPLOYMENT_CHECKLIST.md**   | Step-by-step checklist | 30 min    |
| **OTP_IMPLEMENTATION_SUMMARY.md** | System overview        | 10 min    |

## ✨ What's Implemented

### Security Features

✅ 6-digit random OTP codes  
✅ 5-minute automatic expiry  
✅ Max 5 verification attempts  
✅ Secure session tokens (32-byte random)  
✅ Admin bypass with audit logging  
✅ Email verification via Gmail SMTP

### User Experience

✅ Auto-focus on OTP input fields  
✅ Paste support for full codes  
✅ 5-minute countdown timer  
✅ Resend button with cooldown  
✅ Professional error messaging  
✅ Mobile-responsive design  
✅ MARINA theme integrated

### Admin Features

✅ Emergency admin bypass  
✅ Complete audit trail  
✅ Configurable OTP settings  
✅ Automatic cleanup of expired codes  
✅ Database tracking

## 📦 What's Included

### Backend (5 PHP files)

- `backend/src/OTPService.php` - Core OTP service
- `backend/send_otp.php` - Send OTP endpoint
- `backend/verify_otp.php` - Verify OTP endpoint
- `backend/resend_otp.php` - Resend OTP endpoint
- `backend/admin_bypass.php` - Admin bypass endpoint

### Database (3 tables)

- `otp_codes` - OTP sessions
- `admin_bypass_log` - Audit trail
- `otp_settings` - Configuration

### Frontend (4 React files)

- `frontend/src/LoginForm.jsx` - Updated login
- `frontend/src/OTPInput.jsx` - OTP component
- `frontend/src/App.jsx` - Route protection
- `frontend/src/css/OTPInput.module.css` - Styling

### Migration

- `backend/database/migrate_otp.php` - Database setup

## 🔧 Configuration

### Required Environment Variables

Add to `docker-compose.yml` backend service:

```yaml
services:
  ics-backend:
    environment:
      # Gmail Configuration
      MAIL_HOST: smtp.gmail.com
      MAIL_PORT: 587
      MAIL_USERNAME: your-email@gmail.com
      MAIL_PASSWORD: your-app-password
      MAIL_ENCRYPTION: tls
      MAIL_FROM_ADDRESS: your-email@gmail.com
      MAIL_FROM_NAME: ICS System

      # Admin Bypass Key
      ADMIN_BYPASS_KEY: your-secure-random-key

      # Optional (Defaults shown)
      OTP_EXPIRY_MINUTES: 5
      OTP_MAX_ATTEMPTS: 5
      OTP_RESEND_COOLDOWN: 60
```

## 🔐 API Endpoints

### POST /send_otp.php

Sends OTP after login verification

```json
Request: { "email": "user@example.com", "username": "admin" }
Response: { "success": true, "otp_id": "...", "expires_in": 300 }
```

### POST /verify_otp.php

Verifies OTP code

```json
Request: { "otp_id": "...", "otp_code": "123456" }
Response: { "success": true, "session_token": "...", "email": "..." }
```

### POST /resend_otp.php

Resends OTP (60-second cooldown)

```json
Request: { "otp_id": "..." }
Response: { "success": true, "message": "OTP resent" }
```

### POST /admin_bypass.php

Emergency admin access

```json
Request: { "admin_key": "...", "email": "admin@ics.local" }
Response: { "success": true, "session_token": "..." }
```

## 🧪 Testing

### Test Checklist

- [ ] Gmail App Password generated and working
- [ ] Environment variables set in docker-compose.yml
- [ ] Database migration runs successfully
- [ ] Login page loads
- [ ] OTP email received after login
- [ ] OTP verification page displays
- [ ] Can enter 6-digit code
- [ ] Successful verification redirects to /entry
- [ ] Cannot access /entry without session_token
- [ ] Resend OTP works with 60-second cooldown
- [ ] Timer counts down from 5 minutes
- [ ] Admin bypass works (dev mode)

**Full testing procedure**: See `OTP_DEPLOYMENT_CHECKLIST.md`

## 🐛 Troubleshooting

### Email not sending

- Verify Gmail App Password (not regular password)
- Check MAIL_USERNAME and MAIL_PASSWORD
- Verify 2FA enabled on Gmail
- Check server logs: `docker-compose logs ics-backend | grep SMTP`

### "Session invalid" error

- Refresh page and login again
- Check sessionStorage is enabled in browser
- Verify session_token exists in sessionStorage

### "Invalid admin key"

- Verify ADMIN_BYPASS_KEY in docker-compose.yml
- Restart backend container after env changes
- Check for extra spaces in key

### Cannot access /entry directly

This is expected! The route is protected. You must:

1. Log in first
2. Enter OTP code
3. Get session_token
4. Then access /entry

**For more troubleshooting**: See `SETUP_OTP.md → Troubleshooting`

## 📋 Production Checklist

Before going live:

- [ ] Gmail App Password generated and secured
- [ ] ADMIN_BYPASS_KEY generated and secured
- [ ] docker-compose.yml updated with env vars
- [ ] Database migration completed
- [ ] All API endpoints tested
- [ ] Complete login flow tested
- [ ] Session protection working
- [ ] Admin bypass tested and audit logged
- [ ] Switch to HTTPS (not HTTP)
- [ ] Hide "[DEV] Admin Bypass" button (set NODE_ENV=production)
- [ ] Review security audit log
- [ ] Back up database
- [ ] User communication sent

**Full checklist**: See `OTP_DEPLOYMENT_CHECKLIST.md`

## 🔗 Routes

| Route         | Access        | Purpose          |
| ------------- | ------------- | ---------------- |
| `/`           | Public        | Login page       |
| `/verify-otp` | OTP Session   | OTP verification |
| `/entry`      | Session Token | Main application |

**Unauthorized access automatically redirects to `/`**

## 📞 Support

### Getting Help

1. Check `OTP_QUICK_REFERENCE.md` for common questions
2. Review `SETUP_OTP.md` → Troubleshooting section
3. Check server logs: `docker-compose logs ics-backend`
4. Verify database setup: Check `otp_codes` table

### Key Resources

- **Quick Start**: `OTP_QUICK_REFERENCE.md`
- **Full Setup**: `SETUP_OTP.md`
- **Deployment**: `OTP_DEPLOYMENT_CHECKLIST.md`
- **Overview**: `OTP_IMPLEMENTATION_SUMMARY.md`

## 🎨 Design

The OTP system uses the **MARINA theme** to match your existing design:

- Primary color: `hsl(229, 75%, 28%)`
- Responsive layout (mobile/tablet/desktop)
- Smooth animations and transitions
- Professional error states

## 🔄 User Flow

```
User Visits Login
    ↓
Enters Credentials
    ↓
Backend Verifies Login
    ↓
send_otp.php Sends Email
    ↓
User Redirected to /verify-otp
    ↓
User Enters 6-Digit Code
    ↓
verify_otp.php Validates Code
    ↓
Session Token Created
    ↓
User Redirected to /entry (Main App)
    ↓
Session Token Stored in sessionStorage
```

## ⚙️ System Requirements

- PHP 7.4+
- MySQL 5.7+
- Node 14+
- React 18.2+
- Docker & Docker Compose

## 📄 License & Support

This implementation was created for the ICS project.

**Version**: 1.0  
**Status**: Production Ready  
**Last Updated**: January 2024

---

## 🚦 Next Steps

1. **Start Here**: Read `OTP_QUICK_REFERENCE.md` (5 minutes)
2. **Detailed Setup**: Follow `SETUP_OTP.md` (20 minutes)
3. **Complete Deployment**: Use `OTP_DEPLOYMENT_CHECKLIST.md` (30 minutes)
4. **Launch**: System is ready for production use

**Questions?** Check the documentation files listed above.

---

**Status**: ✅ Production Ready - Implement Now!
