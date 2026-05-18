# Quick Start: PHPMailer & Offline Authentication

**Setup Time**: 10 minutes | **Difficulty**: Easy

---

## 🚀 Step 1: Docker Deployment

```bash
# From project root
docker-compose down -v
docker-compose up --build -d

# Wait for containers to be healthy
docker ps
# All 4 containers should show "Up" status
```

---

## 🔧 Step 2: Initialize Database

The migration runs automatically, but verify:

```bash
curl http://localhost:8080/database/migrate.php
```

Expected output includes:

- ✅ Users table created
- ✅ Login audit table created
- ✅ Offline emails table created
- ✅ Admin user created
- ✅ Demo user created

---

## ⚙️ Step 3: Configure Email (Optional)

### For Gmail

1. Enable 2-Step Verification
2. Create App Password:
   - Visit: https://myaccount.google.com/apppasswords
   - Select "Mail" and "Windows Computer"
   - Copy generated password

3. Update `docker-compose.yml`:

```yaml
environment:
  MAIL_MODE: online
  MAIL_HOST: smtp.gmail.com
  MAIL_PORT: 587
  MAIL_USERNAME: your-email@gmail.com
  MAIL_PASSWORD: your-app-password
  MAIL_ENCRYPTION: tls
  MAIL_VERIFY_SSL: false
```

4. Restart backend:

```bash
docker-compose restart backend
```

---

## 🔐 Step 4: Test Authentication

### Online Login

```bash
curl -X POST http://localhost:8080/login.php \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password123"}'
```

Response:

```json
{
  "status": "success",
  "message": "Authenticated online",
  "mode": "online",
  "token": "abc123...",
  "user": {...},
  "system_status": {
    "online": true,
    "mode": "online"
  }
}
```

### Save Token for Next Steps

```bash
TOKEN="abc123..."  # From response above
```

---

## 📧 Step 5: Test Email Sending

### Send Test Email (Online Mode)

```bash
curl -X POST http://localhost:8080/send_email.php \
  -H "Content-Type: application/json" \
  -d '{
    "to": "your-email@example.com",
    "subject": "Test Email from ICS",
    "body": "<h1>Hello!</h1><p>This is a test email.</p>",
    "altText": "Hello! This is a test email.",
    "token": "'$TOKEN'"
  }'
```

Response:

```json
{
  "success": true,
  "message": "Email sent successfully",
  "mode": "online",
  "to": "your-email@example.com"
}
```

---

## 📴 Step 6: Test Offline Mode

### Simulate Network Disconnect

```bash
# Stop MySQL container (simulates network failure)
docker-compose stop db

# Try to login
curl -X POST http://localhost:8080/login.php \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password123"}'
```

Expected response:

```json
{
  "status": "success",
  "message": "Authenticated offline (cached)",
  "mode": "offline",
  "token": "xyz789..."
}
```

### Send Email in Offline Mode

```bash
curl -X POST http://localhost:8080/send_email.php \
  -H "Content-Type: application/json" \
  -d '{
    "to": "user@example.com",
    "subject": "Offline Email",
    "body": "<p>This email will be sent when online</p>",
    "token": "'$TOKEN'"
  }'
```

Response:

```json
{
  "success": true,
  "message": "Email stored offline. Will be sent when connection restored.",
  "mode": "offline",
  "file": "backend/offline_emails/abc123.json"
}
```

Check queued emails:

```bash
docker exec ics-backend cat /var/www/html/offline_emails/*.json | jq .
```

### Restore Connection and Process Queue

```bash
# Restart MySQL
docker-compose start db

# Wait a few seconds for health check
sleep 5

# Manually trigger processing
curl -X POST http://localhost:8080/process_offline_emails.php \
  -H "Content-Type: application/json" \
  -d '{"token": "'$TOKEN'"}'
```

Response:

```json
{
  "success": true,
  "message": "Offline email queue processed",
  "summary": {
    "sent": 1,
    "failed": 0,
    "pending": 0,
    "details": [...]
  }
}
```

---

## 🧪 Step 7: Complete Offline Scenario

### Scenario: User loses internet, continues working, reconnects later

```bash
# 1. User logs in while ONLINE
curl -X POST http://localhost:8080/login.php \
  -H "Content-Type: application/json" \
  -d '{"username": "demo", "password": "demo123"}'
# ✅ Success: Token cached locally

# 2. User disconnects from internet
docker-compose stop db

# 3. User tries to login (OFFLINE)
curl -X POST http://localhost:8080/login.php \
  -H "Content-Type: application/json" \
  -d '{"username": "demo", "password": "demo123"}'
# ✅ Success: Authenticated using cached token

# 4. User sends email while offline
curl -X POST http://localhost:8080/send_email.php \
  -H "Content-Type: application/json" \
  -d '{
    "to": "manager@company.com",
    "subject": "Work Update",
    "body": "<p>Finished the report</p>",
    "token": "'$OFFLINE_TOKEN'"
  }'
# ✅ Success: Email queued

# 5. User connects back to internet
docker-compose start db
sleep 5

# 6. Email automatically retries (or manual trigger)
curl -X POST http://localhost:8080/process_offline_emails.php \
  -H "Content-Type: application/json" \
  -d '{"token": "'$OFFLINE_TOKEN'"}'
# ✅ Success: Email sent

# 7. User can login normally again
curl -X POST http://localhost:8080/login.php \
  -H "Content-Type: application/json" \
  -d '{"username": "demo", "password": "demo123"}'
# ✅ Success: Authenticated online
```

---

## 📊 Check System Status

```bash
# Get current system status
curl -X POST http://localhost:8080/login.php \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password123"}' | jq '.system_status'
```

Output:

```json
{
  "online": true,
  "mode": "online",
  "cached_users": 2,
  "active_sessions": 3
}
```

---

## 🗂️ File Locations

| What           | Where                            |
| -------------- | -------------------------------- |
| Queued emails  | `backend/offline_emails/`        |
| Cached tokens  | `backend/offline_tokens/`        |
| Mail config    | `backend/config/mail.config.php` |
| MailService    | `backend/src/MailService.php`    |
| AuthService    | `backend/src/AuthService.php`    |
| Database setup | `backend/database/migrate.php`   |

---

## 🔄 Common Tasks

### Change Admin Password

```bash
# Connect to MySQL
docker exec -it ics-mysql mysql -u root -p
# Enter password: rootpassword

# Update password
UPDATE my_app_db.users SET password_hash = PASSWORD('new-password') WHERE username = 'admin';
EXIT;
```

### Clear Offline Cache (if needed)

```bash
# Clear all cached tokens
docker exec ics-backend rm -f /var/www/html/offline_tokens/*.token

# Clear session tokens
docker exec ics-backend rm -f /var/www/html/offline_tokens/*.session

# Clear queued emails
docker exec ics-backend rm -f /var/www/html/offline_emails/*.json
```

### View Logs

```bash
# Backend logs
docker logs -f ics-backend | grep -i auth

# View email sending logs
docker logs -f ics-backend | grep -i mail

# Database logs
docker logs -f ics-mysql
```

---

## ✅ All Tests Passed?

- [ ] Docker containers healthy
- [ ] Database migrated successfully
- [ ] Online login works
- [ ] Email sends successfully
- [ ] Offline login works after online session
- [ ] Offline emails queue correctly
- [ ] Emails send after reconnecting

**You're ready to use the system!** 🎉

---

**Next**: Read [PHPMAILER_OFFLINE_AUTH_GUIDE.md](PHPMAILER_OFFLINE_AUTH_GUIDE.md) for detailed documentation.
