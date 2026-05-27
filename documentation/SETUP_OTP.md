# Gmail OTP Authentication Setup Guide

This guide provides complete setup instructions for the integrated Gmail OTP (One-Time Password) authentication system for the ICS (Inventory Custodian Slip) project.

## Table of Contents

1. [System Overview](#system-overview)
2. [Prerequisites](#prerequisites)
3. [Gmail Configuration](#gmail-configuration)
4. [Backend Setup](#backend-setup)
5. [Frontend Integration](#frontend-integration)
6. [Database Setup](#database-setup)
7. [Environment Configuration](#environment-configuration)
8. [Testing](#testing)
9. [API Reference](#api-reference)
10. [Troubleshooting](#troubleshooting)

---

## System Overview

The OTP authentication system adds an additional security layer to the ICS application by requiring users to verify their identity with a one-time password sent to their registered email.

### Authentication Flow

```
User Login
    ↓
Verify Credentials
    ↓
Generate & Send OTP Email
    ↓
User Enters OTP on Verification Page
    ↓
Validate OTP Code
    ↓
Create Session Token
    ↓
Grant Access to Main Application
```

### Security Features

- **Secure OTP Generation**: 6-digit random codes
- **Time-Based Expiry**: OTPs expire after 5 minutes
- **Attempt Limiting**: Maximum 5 verification attempts
- **Admin Bypass**: Secure backdoor with audit logging
- **Session-Based**: Cryptographically secure session tokens
- **Email Verification**: PHPMailer with Gmail SMTP

---

## Prerequisites

### Server Requirements

- PHP 7.4 or higher
- MySQL 5.7 or higher
- Docker & Docker Compose (for containerized deployment)
- Composer (for PHP dependencies)

### Frontend Requirements

- Node.js 14+ with npm/yarn
- React 18.2+
- React Router v6

### Gmail Account

- Active Gmail account
- Google Account with 2FA enabled (for App Password generation)
- Gmail SMTP access permissions

---

## Gmail Configuration

### Step 1: Enable 2-Factor Authentication

1. Go to [myaccount.google.com](https://myaccount.google.com)
2. Navigate to **Security** (left sidebar)
3. Scroll to "How you sign in to Google"
4. Enable **2-Step Verification** if not already enabled

### Step 2: Generate App Password

1. Go to [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)
2. Select:
   - **App**: Mail
   - **Device**: Windows PC (or your device)
3. Click **Generate**
4. Copy the 16-character password generated

**Important**: Save this password securely. You'll need it for environment configuration.

### Example Gmail Credentials

```
Gmail Address: your-email@gmail.com
App Password: abcd efgh ijkl mnop  (16 characters, remove spaces)
SMTP Host: smtp.gmail.com
SMTP Port: 587
Encryption: TLS
```

---

## Backend Setup

### Step 1: Verify PHPMailer Installation

Check that PHPMailer is already in your `composer.json`:

```bash
cd backend
cat composer.json | grep -A 2 "phpmailer"
```

Expected output:

```json
"phpmailer/phpmailer": "^6.8"
```

If not present, install dependencies:

```bash
composer install
```

### Step 2: Create OTP Service Class

The file `backend/src/OTPService.php` should already exist. Verify it contains:

- `generateAndSendOTP()` - Main OTP generation and sending method
- `verifyOTP()` - OTP code verification
- `resendOTP()` - Resend OTP to email
- `cleanupExpiredOTPs()` - Maintenance function

### Step 3: Verify API Endpoints

Ensure these files exist in the backend:

```
backend/
├── send_otp.php          # POST endpoint to send OTP
├── verify_otp.php        # POST endpoint to verify OTP code
├── resend_otp.php        # POST endpoint to resend OTP
├── admin_bypass.php      # POST endpoint for admin bypass
└── src/
    └── OTPService.php    # Core OTP service class
```

Each endpoint should have CORS headers configured:

```php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
```

---

## Frontend Integration

### Step 1: Verify React Components

Ensure these frontend files exist:

```
frontend/src/
├── LoginForm.jsx            # Modified to call send_otp.php
├── OTPInput.jsx             # OTP input and verification component
├── App.jsx                  # Modified with protected routes
└── css/
    └── OTPInput.module.css  # MARINA-themed OTP styling
```

### Step 2: LoginForm Integration

The `LoginForm.jsx` has been updated to:

1. Accept username and password
2. Send credentials to backend `/login.php`
3. On success, trigger `/send_otp.php`
4. Store `otp_id` and `user_email` in sessionStorage
5. Redirect to `/verify-otp` page

No additional changes needed.

### Step 3: OTPInput Component

The `OTPInput.jsx` component provides:

- 6-digit OTP input with auto-focus
- 5-minute countdown timer with visual warning
- Resend button with 60-second cooldown
- Error and success messaging
- Email display confirmation

No configuration changes needed.

### Step 4: Route Protection

The `App.jsx` includes:

- `ProtectedRoute` component - Checks for `session_token` before allowing access to `/entry`
- `OTPRoute` component - Validates OTP session exists before accessing `/verify-otp`
- Automatic redirect to `/` for unauthorized access

---

## Database Setup

### Step 1: Run Migration

Access your database container:

```bash
docker-compose exec ics-mysql mysql -u root -p your_password
```

Option A: Run migration via HTTP (automatic on first deployment):

```bash
curl http://localhost:8080/database/migrate_otp.php
```

Option B: Run SQL directly in MySQL client:

Execute the SQL migration from `backend/database/migrate_otp.php`:

```sql
-- Create OTP codes table
CREATE TABLE IF NOT EXISTS otp_codes (
    otp_id VARCHAR(64) PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    code VARCHAR(10) NOT NULL,
    status ENUM('pending', 'verified', 'expired') DEFAULT 'pending',
    attempts INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    resend_count INT DEFAULT 0,
    resend_at TIMESTAMP NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create admin bypass log table
CREATE TABLE IF NOT EXISTS admin_bypass_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id VARCHAR(255) NOT NULL,
    bypassed_email VARCHAR(255) NOT NULL,
    key_hash VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create OTP settings table
CREATE TABLE IF NOT EXISTS otp_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_name VARCHAR(255) UNIQUE,
    setting_value VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert default settings
INSERT IGNORE INTO otp_settings (setting_name, setting_value) VALUES
('otp_enabled', '1'),
('otp_expiry_minutes', '5'),
('max_attempts', '5');
```

### Step 2: Verify Tables

Check that tables were created:

```sql
SHOW TABLES LIKE 'otp%';
```

Expected tables:

- `otp_codes`
- `admin_bypass_log`
- `otp_settings`

---

## Environment Configuration

### Step 1: Update docker-compose.yml

Add the following environment variables to the backend service:

```yaml
services:
  ics-backend:
    environment:
      # Existing variables
      - DB_HOST=ics-mysql
      - DB_USER=root
      - DB_PASSWORD=your_password
      - DB_NAME=ICS_DB

      # Gmail SMTP Configuration
      - MAIL_MODE=online
      - MAIL_DRIVER=smtp
      - MAIL_HOST=smtp.gmail.com
      - MAIL_PORT=587
      - MAIL_USERNAME=your-email@gmail.com
      - MAIL_PASSWORD=your-app-password-16-chars
      - MAIL_ENCRYPTION=tls
      - MAIL_FROM_ADDRESS=your-email@gmail.com
      - MAIL_FROM_NAME=ICS System

      # Admin Bypass Key (generate a secure random key)
      - ADMIN_BYPASS_KEY=your-secure-random-key-min-32-chars

      # OTP Configuration
      - OTP_EXPIRY_MINUTES=5
      - OTP_MAX_ATTEMPTS=5
      - OTP_RESEND_COOLDOWN=60
```

### Step 2: Generate Secure Admin Bypass Key

Generate a random 32-character secure key:

**On Linux/Mac:**

```bash
openssl rand -hex 16
```

**On Windows PowerShell:**

```powershell
[Convert]::ToBase64String((1..32 | ForEach-Object { [byte](Get-Random -Maximum 256) }))
```

**Or use this online generator:**
https://www.random.org/strings/ (settings: 32 characters, a-zA-Z0-9)

### Step 3: Create .env File (Optional, for Local Development)

Create `backend/.env`:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=password
DB_NAME=ICS_DB

MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=abcdefghijklmnop
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=your-email@gmail.com
MAIL_FROM_NAME=ICS System

ADMIN_BYPASS_KEY=your-secure-random-key
```

Load environment variables in PHP files:

```php
<?php
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__);
$dotenv->load();

$mailHost = $_ENV['MAIL_HOST'];
$mailPassword = $_ENV['MAIL_PASSWORD'];
// etc.
```

---

## Testing

### Test 1: OTP Email Sending

1. Navigate to login page: `http://127.0.0.1:3000/`
2. Enter credentials (default: `admin` / `password123`)
3. Check your email for OTP code
4. Enter the 6-digit code on the verification page
5. Should redirect to `/entry`

### Test 2: Manual Resend

1. On OTP verification page, click "Resend OTP"
2. Wait 5 minutes for first OTP to expire, or request new one immediately
3. Should show "New OTP sent to your email"
4. Enter new code within 5 minutes

### Test 3: Direct URL Access Prevention

1. Try to access `http://127.0.0.1:3000/entry` directly (before login)
2. Should redirect to `/` (login page)

### Test 4: Admin Bypass (Development Mode)

1. Click "[DEV] Admin Bypass" button on login form (dev mode only)
2. Enter your admin bypass key
3. Should creates session token and redirect to `/entry`
4. Check `admin_bypass_log` table for audit trail

### Test 5: Timer and Expiry

1. Start OTP process
2. Watch 5-minute countdown timer
3. At 1 minute, timer should turn red (warning state)
4. After 5 minutes, should show "OTP expired" error

---

## API Reference

### 1. Send OTP Endpoint

**Endpoint**: `POST /send_otp.php`

**Request**:

```json
{
  "email": "user@example.com",
  "username": "admin"
}
```

**Response (Success)**:

```json
{
  "success": true,
  "message": "OTP sent successfully",
  "otp_id": "abc123def456...",
  "expires_in": 300,
  "email": "user@example.com"
}
```

**Response (Error)**:

```json
{
  "success": false,
  "message": "Email sending failed"
}
```

---

### 2. Verify OTP Endpoint

**Endpoint**: `POST /verify_otp.php`

**Request**:

```json
{
  "otp_id": "abc123def456...",
  "otp_code": "123456"
}
```

**Response (Success)**:

```json
{
  "success": true,
  "message": "OTP verified successfully",
  "email": "user@example.com",
  "session_token": "random_32_byte_token...",
  "expires_at": "2024-01-15 14:30:00"
}
```

**Response (Error)**:

```json
{
  "success": false,
  "message": "Invalid OTP code",
  "attempts_remaining": 3
}
```

---

### 3. Resend OTP Endpoint

**Endpoint**: `POST /resend_otp.php`

**Request**:

```json
{
  "otp_id": "abc123def456..."
}
```

**Response (Success)**:

```json
{
  "success": true,
  "message": "OTP code resent successfully",
  "otp_id": "abc123def456...",
  "expires_in": 300,
  "resend_count": 1
}
```

**Response (Error - Cooldown)**:

```json
{
  "success": false,
  "message": "Please wait 45 seconds before resending",
  "wait_time": 45
}
```

---

### 4. Admin Bypass Endpoint

**Endpoint**: `POST /admin_bypass.php`

**Request**:

```json
{
  "admin_key": "your-secure-admin-key",
  "email": "user@example.com",
  "reason": "Emergency access required"
}
```

**Response (Success)**:

```json
{
  "success": true,
  "message": "Bypass successful",
  "session_token": "random_32_byte_token...",
  "email": "user@example.com",
  "bypass_mode": true
}
```

**Response (Error)**:

```json
{
  "success": false,
  "message": "Invalid admin key"
}
```

---

## Troubleshooting

### Issue: "Email sending failed"

**Possible Causes**:

1. Gmail App Password incorrect
2. Gmail SMTP credentials not set in environment variables
3. 2FA not enabled on Gmail account
4. Gmail blocking less secure app access

**Solution**:

```bash
# Verify Gmail credentials
docker-compose logs ics-backend | grep -i mail

# Regenerate Gmail App Password and update docker-compose.yml
# Restart the container
docker-compose restart ics-backend
```

---

### Issue: "OTP not received in email"

**Possible Causes**:

1. Check spam folder
2. Email address misconfigured
3. SMTP connection timeout
4. Email domain blacklisted

**Solution**:

1. Check spam/junk folders
2. Verify email is correct: `SELECT email FROM otp_codes ORDER BY created_at DESC LIMIT 1;`
3. Check server logs: `docker-compose logs ics-backend`
4. Resend OTP

---

### Issue: "Session invalid" or "OTP expired"

**Possible Causes**:

1. Page refreshed (sessionStorage cleared)
2. OTP code expired (5 minutes)
3. Browser session cleared
4. Multiple browser tabs

**Solution**:

1. Go back to login page
2. Request new OTP
3. Clear browser data if needed
4. Use single tab

---

### Issue: "Invalid OTP code" after entering correct code

**Possible Causes**:

1. Spaces in code (copy-paste issue)
2. OTP already used
3. Code expired
4. Database desync

**Solution**:

1. Manually type code without spaces
2. Try resending new OTP
3. Check that timer hasn't expired
4. Try refreshing and entering again

---

### Issue: Admin bypass returns "Invalid admin key"

**Possible Causes**:

1. Admin key not set in environment variables
2. Admin key typo
3. Container not restarted after env change
4. Key hash mismatch

**Solution**:

```bash
# Verify admin key is set
docker-compose exec ics-backend env | grep ADMIN_BYPASS_KEY

# If not set, update docker-compose.yml and restart
docker-compose restart ics-backend

# Use correct key (copy from docker-compose.yml)
```

---

### Issue: Database migration not working

**Possible Causes**:

1. MySQL container not running
2. Database user permissions
3. Table already exists (partial migration)
4. PHP not able to connect to database

**Solution**:

```bash
# Check MySQL is running
docker-compose ps ics-mysql

# Verify database connection
docker-compose exec ics-backend php -r "
  \$conn = new mysqli('ics-mysql', 'root', 'password', 'ICS_DB');
  if (\$conn->connect_error) echo 'Connection failed';
  else echo 'Connected successfully';
"

# Run migration manually
docker-compose exec ics-mysql mysql -u root -p'password' ICS_DB < backend/database/migrate_otp.php
```

---

### Issue: CORS errors in browser console

**Possible Causes**:

1. Backend CORS headers not configured
2. Frontend URL not in CORS whitelist
3. Fetch request missing credentials

**Solution**:

Backend (verify in PHP files):

```php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
```

Frontend:

```javascript
const response = await fetch('http://localhost:8080/verify_otp.php', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  credentials: 'include', // Include cookies if needed
  body: JSON.stringify({...})
});
```

---

### Issue: OTP UI not displaying correctly

**Possible Causes**:

1. CSS module not imported
2. CSS class names incorrect
3. MARINA colors not loaded
4. React component errors

**Solution**:

1. Check browser console for errors
2. Verify `OTPInput.module.css` exists and has content
3. Check that `OTPInput.jsx` imports the CSS module
4. Check CSS classes match component

---

## Advanced Configuration

### Custom OTP Settings

Update OTP settings in database:

```sql
-- Change OTP expiry to 10 minutes
UPDATE otp_settings SET setting_value = '10' WHERE setting_name = 'otp_expiry_minutes';

-- Change max attempts to 3
UPDATE otp_settings SET setting_value = '3' WHERE setting_name = 'max_attempts';

-- Disable OTP temporarily
UPDATE otp_settings SET setting_value = '0' WHERE setting_name = 'otp_enabled';
```

### Email Template Customization

Edit `backend/src/OTPService.php`, method `sendOTPEmail()`:

```php
$mailBody = '
<html>
  <body style="font-family: Arial, sans-serif;">
    <h2>Your One-Time Password</h2>
    <p>Your OTP code is: <strong style="font-size: 24px;">' . $code . '</strong></p>
    <p>This code expires in 5 minutes.</p>
    <hr>
    <p style="font-size: 12px; color: #666;">
      If you did not request this code, please ignore this email.
    </p>
  </body>
</html>
';
```

---

## Security Best Practices

1. **Always use HTTPS** in production (not http://)
2. **Rotate admin keys** periodically
3. **Monitor bypass logs** for suspicious activity
4. **Update PHPMailer** regularly for security patches
5. **Use strong passwords** for Gmail App Passwords
6. **Limit OTP resends** per user per day
7. **Log all authentication events**
8. **Implement rate limiting** on endpoints

---

## Support

For issues or questions:

1. Check the **Troubleshooting** section above
2. Review server logs: `docker-compose logs ics-backend`
3. Check database tables: `SELECT * FROM otp_codes LIMIT 10;`
4. Verify environment variables: `docker-compose exec ics-backend env`

---

**Last Updated**: January 2024
**Version**: 1.0
**Status**: Production Ready
