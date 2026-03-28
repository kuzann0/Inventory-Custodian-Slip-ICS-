# PHP Mailer & Offline Authentication Integration Guide

Complete guide for email functionality and offline authentication in the ICS System.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [PHPMailer Setup](#phpmailer-setup)
5. [Offline Authentication](#offline-authentication)
6. [API Endpoints](#api-endpoints)
7. [Usage Examples](#usage-examples)
8. [Troubleshooting](#troubleshooting)

---

## 🔍 Overview

This integration provides:

- **Dual-Mode Email**: Online SMTP + Offline file-based queue
- **Hybrid Authentication**: Database auth + Token caching + Fallback credentials
- **Offline Resilience**: Full system access without internet
- **Email Queuing**: Failed emails auto-stored and retry when online

### Architecture

```
┌─────────────────────────────────────┐
│         Login Request               │
└────────────────┬────────────────────┘
                 │
         ┌───────▼────────┐
         │  Online Mode?  │
         └───┬────────┬───┘
             │        │
        YES  │        │  NO
             │        │
    ┌────────▼──┐   ┌─▼──────────────┐
    │ Database  │   │ Offline Token  │
    │   Auth    │   │    Cache       │
    └────────┬──┘   └─┬──────────────┘
             │        │
             └────┬───┘
                  │
        ┌─────────▼──────────┐
        │  Issue JWT Token   │
        └────────┬───────────┘
                 │
        ┌────────▼──────────┐
        │ Cache for Offline │
        └───────────────────┘
```

---

## ⚙️ Installation

### Step 1: Install Composer Dependencies

```bash
cd backend
composer install
```

This installs PHPMailer 6.8+

### Step 2: Create Required Directories

```bash
# These are created automatically, but you can pre-create them:
mkdir -p backend/offline_emails
mkdir -p backend/offline_tokens
mkdir -p backend/config
chmod 755 backend/offline_emails
chmod 755 backend/offline_tokens
```

### Step 3: Run Database Migration

Since you're using Docker, the migration runs automatically on container startup.

**Manual run (if needed):**

```bash
curl http://localhost:8080/database/migrate.php
```

Expected response:

```json
[
  {"success": true, "message": "Users table created successfully"},
  {"success": true, "message": "Login audit table created successfully"},
  {"success": true, "message": "Offline emails table created successfully"},
  {"success": true, "message": "Default admin user created", "credentials": {...}},
  {"success": true, "message": "Demo user created", "credentials": {...}}
]
```

---

## 🔧 Configuration

### Email Configuration

Edit `.env` or `docker-compose.yml`:

```env
# Gmail Example
MAIL_MODE=online
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
MAIL_FROM_ADDRESS=noreply@ics-system.local
MAIL_FROM_NAME=ICS System
MAIL_ENCRYPTION=tls
```

### Gmail Setup (Recommended)

1. Enable 2-Step Verification in Google Account
2. Generate App Password:
   - Go to [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)
   - Select Mail and Windows Computer
   - Copy the generated password
3. Use this password in `MAIL_PASSWORD`

### Office365 Setup

```env
MAIL_HOST=smtp.office365.com
MAIL_PORT=587
MAIL_USERNAME=your-email@company.com
MAIL_PASSWORD=your-password
MAIL_ENCRYPTION=tls
```

### Custom SMTP

```env
MAIL_HOST=mail.yourdomain.com
MAIL_PORT=587
MAIL_USERNAME=no-reply@yourdomain.com
MAIL_PASSWORD=your-password
MAIL_ENCRYPTION=tls
MAIL_VERIFY_SSL=false
```

---

## 📧 PHPMailer Setup

### Automatic Fallback

If online SMTP fails:

1. Email automatically saved to `backend/offline_emails/`
2. System returns `"mode": "offline"` in response
3. Emails retry when connection restored

### Offline Email Queue

Stored emails waiting to send:

```bash
ls backend/offline_emails/
# Output: abc123.json, def456.json, ...
```

### Retry Mechanism

Emails automatically retry when:

- System comes back online
- Administrator manually triggers via API endpoint

---

## 🔐 Offline Authentication

### How It Works

#### Online Mode (Normal)

1. User submits credentials
2. System checks database (users table)
3. Password verified via bcrypt
4. Session token issued
5. **Token cached** for offline use

#### Offline Mode (No Internet)

1. User submits credentials
2. Database unavailable
3. System checks cached tokens
4. If valid token exists:
   - Password verified against cached hash
   - Session issued
5. If no token, fallback to hardcoded admin credentials

### Default Credentials

**Admin Account** (created on first migration):

- Username: `admin`
- Password: `password123`
- Role: `admin`

**Demo Account**:

- Username: `demo`
- Password: `demo123`
- Role: `user`

⚠️ **IMPORTANT**: Change these passwords in production!

```bash
# Change admin password (when online):
UPDATE users SET password_hash = PASSWORD('new-password') WHERE username = 'admin';
```

### Token Caching

When user logs in online:

1. Session token issued
2. Token cached in `backend/offline_tokens/{username}.token`
3. Cache valid for **7 days**
4. Password hash stored (hashed)

Cache format:

```json
{
  "username": "admin",
  "token": "abc123...",
  "password_hash": "$2y$10$...",
  "created": 1711612800,
  "expiry": 1712217600,
  "user": {
    "username": "admin",
    "role": "admin"
  }
}
```

---

## 🔌 API Endpoints

### 1. Authentication

**Endpoint**: `POST /login.php`

**Request**:

```json
{
  "username": "admin",
  "password": "password123"
}
```

**Successful Response** (200):

```json
{
  "status": "success",
  "message": "Authenticated online",
  "mode": "online",
  "token": "abc123def456...",
  "user": {
    "id": 1,
    "username": "admin",
    "email": "admin@ics-system.local",
    "role": "admin"
  },
  "system_status": {
    "online": true,
    "mode": "online",
    "cached_users": 2,
    "active_sessions": 3
  }
}
```

**Offline Fallback Response** (200):

```json
{
  "status": "success",
  "message": "Authenticated offline (cached)",
  "mode": "offline",
  "token": "xyz789...",
  "user": {
    "id": 0,
    "username": "admin",
    "email": "admin@ics-system.local",
    "role": "admin"
  },
  "system_status": {
    "online": false,
    "mode": "offline",
    "cached_users": 2,
    "active_sessions": 1
  }
}
```

**Error Response** (401):

```json
{
  "status": "error",
  "message": "No offline credentials available. System is offline.",
  "mode": "offline",
  "system_status": {
    "online": false,
    "mode": "offline",
    "cached_users": 0,
    "active_sessions": 0
  }
}
```

### 2. Send Email

**Endpoint**: `POST /send_email.php`

**Request**:

```json
{
  "to": "user@example.com",
  "subject": "Welcome to ICS",
  "body": "<h1>Hello</h1><p>Welcome!</p>",
  "altText": "Hello\n\nWelcome!",
  "token": "abc123def456..."
}
```

**Online Success Response** (200):

```json
{
  "success": true,
  "message": "Email sent successfully",
  "mode": "online",
  "to": "user@example.com"
}
```

**Offline Queue Response** (200):

```json
{
  "success": true,
  "message": "Email stored offline. Will be sent when connection restored.",
  "mode": "offline",
  "to": "user@example.com",
  "file": "backend/offline_emails/abc123.json"
}
```

### 3. Check System Status

**Endpoint**: `POST /login.php` (response includes `system_status`)

Returns:

```json
{
  "online": true/false,
  "mode": "online/offline",
  "cached_users": 2,
  "active_sessions": 3
}
```

---

## 💻 Usage Examples

### Example 1: Simple Login (Frontend)

```javascript
// React example
async function handleLogin(username, password) {
  try {
    const response = await fetch("http://localhost:8080/login.php", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ username, password }),
    });

    const data = await response.json();

    if (data.status === "success") {
      // Store token in localStorage
      localStorage.setItem("auth_token", data.token);
      localStorage.setItem("user", JSON.stringify(data.user));

      // Show system mode
      console.log(`Authenticated in ${data.mode} mode`);

      // If offline, warn user
      if (data.mode === "offline") {
        alert("System running in offline mode");
      }

      return true;
    } else {
      alert(data.message);
      return false;
    }
  } catch (error) {
    console.error("Login failed:", error);
  }
}
```

### Example 2: Send Email (Backend)

```php
<?php
require_once __DIR__ . '/vendor/autoload.php';

use ICS\MailService;

$mailService = new MailService();

// Send email
$result = $mailService->send(
  'user@example.com',
  'Welcome to ICS System',
  '<h1>Welcome</h1><p>You have been registered.</p>',
  'Welcome\n\nYou have been registered.'
);

if ($result['success']) {
    echo "Email sent via {$result['mode']} mode";
} else {
    echo "Failed: {$result['message']}";
}
?>
```

### Example 3: Send Email with Attachment (Backend)

```php
<?php
require_once __DIR__ . '/vendor/autoload.php';

use ICS\MailService;

$mailService = new MailService();

// Send with attachment
$result = $mailService->send(
  'user@example.com',
  'Your Invoice',
  '<p>Please see attached invoice</p>',
  'Please see attached invoice',
  [
    [
      'path' => '/path/to/invoice.pdf',
      'name' => 'invoice_2024.pdf'
    ]
  ]
);

echo json_encode($result);
?>
```

### Example 4: Retry Offline Emails (Backend Cron)

```php
<?php
// This should run periodically (e.g., every 5 minutes)

require_once __DIR__ . '/vendor/autoload.php';

use ICS\MailService;

$mailService = new MailService();

// Check if online and process queued emails
if (function_exists('mysqli_ping')) {
    $summary = $mailService->processOfflineEmails();

    error_log('Offline email processing results: ' . json_encode($summary));

    echo json_encode([
        'success' => true,
        'summary' => $summary
    ]);
}
?>
```

### Example 5: Create New User (Backend Admin Panel)

```php
<?php
require_once __DIR__ . '/vendor/autoload.php';

use ICS\AuthService;

$db = new mysqli('db', 'root', 'rootpassword', 'my_app_db');
$auth = new AuthService($db);

// Create new user (requires online connection)
$result = $auth->createUser(
  'johnsmith',
  'john@example.com',
  'secure_password_123',
  'user'
);

echo json_encode($result);
?>
```

### Example 6: Display System Status (Frontend Dashboard)

```javascript
// After login, check system status
async function getSystemStatus(token) {
  try {
    const response = await fetch("http://localhost:8080/login.php", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        username: "admin",
        password: "password123",
      }),
    });

    const data = await response.json();

    return {
      isOnline: data.system_status.online,
      mode: data.system_status.mode,
      cachedUsers: data.system_status.cached_users,
      activeSessions: data.system_status.active_sessions,
    };
  } catch (error) {
    return { isOnline: false, mode: "offline" };
  }
}

// Usage
async function renderDashboard() {
  const status = await getSystemStatus();

  const statusBadge = status.isOnline ? "🟢 ONLINE" : "🔴 OFFLINE";

  return `
    <div class="system-status">
      <h3>${statusBadge}</h3>
      <p>Mode: ${status.mode}</p>
      <p>Cached Users: ${status.cachedUsers}</p>
      <p>Active Sessions: ${status.activeSessions}</p>
    </div>
  `;
}
```

---

## 🔄 Workflow Examples

### Scenario 1: Normal Online Operation

```
User has internet → Login → Database authentication → Token issued
                                                    ↓
                            Token cached for offline use
                                    ↓
User sends email → SMTP connection → Email sent immediately
```

### Scenario 2: Internet Disconnects

```
User logged in → Internet DOWN → Tries to send email
                                     ↓
                     SMTP unavailable → Email queued
                                     ↓
              Stored in offline_emails/ directory
                                     ↓
        Waits for connection restoration
```

### Scenario 3: Offline Authentication

```
Internet DOWN → User tries login → Database unavailable
                                     ↓
                    Checks cached tokens
                                     ↓
            Token found AND not expired?
                    ↙          ↘
                  YES          NO
                   ↓            ↓
             Allow login    Check fallback credentials
                           (admin/password123)
```

### Scenario 4: Connection Restored

```
Internet back → System detects connection
                        ↓
        Automatically processes queued emails
                        ↓
        Check offline_emails/ directory
                        ↓
        Retry each stored email via SMTP
                        ↓
        Delete successfully sent emails
                        ↓
        Log failures for retry later
```

---

## 🐛 Troubleshooting

### Email Not Sending

**Problem**: "Email sent successfully" but no email received

**Solutions**:

1. Check SMTP credentials in environment variables
2. Verify `MAIL_VERIFY_SSL=false` for self-signed certificates
3. Check offline queue: `ls backend/offline_emails/`
4. Verify recipient email is not in spam folder

**Debug**:

```bash
# Check if email was queued offline
docker exec ics-backend ls -la /var/www/html/offline_emails/

# Check backend logs
docker logs ics-backend | grep -i mail
```

### Cannot Login Offline

**Problem**: "No offline credentials available" when system is offline

**Solutions**:

1. User must log in once while online to cache token
2. Cached tokens expire after 7 days
3. Use fallback credentials: `admin` / `password123`

**Check cached tokens**:

```bash
docker exec ics-backend ls -la /var/www/html/offline_tokens/
```

### SMTP Connection Timeout

**Problem**: "Connection refused" or timeout errors

**Solutions**:

1. Verify SMTP host and port in environment
2. Check firewall/network blocking SMTP port 587
3. Test Gmail: Enable "Less secure app access" (deprecated)
   - Better: Use App Passwords
4. For corporate networks: Request SMTP relay access

**Test SMTP**:

```bash
# From backend container
docker exec ics-backend telnet smtp.gmail.com 587
```

### Offline Emails Not Retrying

**Problem**: Mails queued but not being sent when back online

**Solutions**:

1. Ensure cron job is running (if using one)
2. Or manually trigger processing:
   ```bash
   curl http://localhost:8080/process_offline_emails.php
   ```
3. Check permissions on `offline_emails/` directory
4. Verify SMTP is working (test manual send first)

### Token Expiration Issues

**Problem**: User logged out unexpectedly

**Solutions**:

1. Session tokens expire after **24 hours**
2. Cached tokens expire after **7 days**
3. User needs to re-login for new token
4. In offline mode: Use cached token (expires slower)

**Clear tokens** (admin):

```bash
# Clear all session tokens
docker exec ics-backend rm -f /var/www/html/offline_tokens/*.session

# Clear cached user tokens
docker exec ics-backend rm -f /var/www/html/offline_tokens/*.token
```

---

## 📊 Database Schema

### Users Table

```sql
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('admin', 'user', 'moderator') DEFAULT 'user',
  status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
  last_login TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Login Audit Table

```sql
CREATE TABLE login_audit (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ip_address VARCHAR(45),
  user_agent TEXT,
  mode ENUM('online', 'offline') DEFAULT 'online',
  success BOOLEAN DEFAULT false
);
```

### Offline Emails Table (Backup)

```sql
CREATE TABLE offline_emails (
  id INT AUTO_INCREMENT PRIMARY KEY,
  recipient_email VARCHAR(100) NOT NULL,
  subject VARCHAR(255) NOT NULL,
  body LONGTEXT,
  status ENUM('pending', 'sent', 'failed') DEFAULT 'pending',
  attempts INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  sent_at TIMESTAMP NULL
);
```

---

## 🚀 Production Checklist

- [ ] Change default passwords (admin, demo)
- [ ] Configure real SMTP credentials
- [ ] Enable SSL verification for SMTP
- [ ] Set up cron job for offline email processing
- [ ] Configure log rotation
- [ ] Set up monitoring alerts
- [ ] Regular backup of offline_tokens/ and offline_emails/
- [ ] Test offline scenario before live deployment
- [ ] Document custom SMTP settings for team
- [ ] Set up automated tests for auth endpoints

---

## 📝 Quick Reference

| Component      | Location                         | Purpose              |
| -------------- | -------------------------------- | -------------------- |
| Mail Config    | `backend/config/mail.config.php` | Email settings       |
| MailService    | `backend/src/MailService.php`    | Email logic          |
| AuthService    | `backend/src/AuthService.php`    | Authentication logic |
| Login Endpoint | `backend/login.php`              | User authentication  |
| Mail Endpoint  | `backend/send_email.php`         | Send email           |
| Migration      | `backend/database/migrate.php`   | Setup database       |
| Offline Emails | `backend/offline_emails/`        | Queued emails        |
| Offline Tokens | `backend/offline_tokens/`        | Cached credentials   |

---

**Version**: 1.0  
**Last Updated**: March 28, 2024  
**Status**: Production Ready
