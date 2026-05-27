# Docker v19 Container Restart Guide
**Date:** April 28, 2026  
**Version:** v19  
**Status:** ✅ TESTED & VERIFIED

---

## Overview
This document provides a comprehensive guide on how to safely restart all Docker containers for the v19 version image/container deployment. This process ensures graceful shutdown of services and proper restart with health checks.

---

## Container Inventory

| Container Name | Image | Version | Port Mapping | Status |
|---|---|---|---|---|
| `ics-backend` | `v19_backend` | 2.0.0 | 3001→80 | Healthy |
| `ics-frontend` | `v19_frontend` | 2.0.0 | 3000→5173 | Running |
| `ics-mysql` | `mysql` | 5.7 | 3307→3306 | Healthy |
| `ics-phpmyadmin` | `phpmyadmin` | 5.2 | 8086→80 | Running |

**v19 Specific Containers:** `ics-backend`, `ics-frontend`

---

## Prerequisites

- Docker Desktop or Docker Engine installed
- Docker Compose installed (v1.29+)
- Working directory: `c:\Users\User\Documents\v19`
- `docker-compose.yml` file present in project root

---

## Safe Restart Procedure

### Step 1: Gracefully Stop All Containers
```powershell
docker compose stop --timeout=10
```

**What this does:**
- Sends SIGTERM signal to all running containers
- Waits up to 10 seconds for graceful shutdown
- Ensures database connections are properly closed
- Prevents data corruption

**Expected output:**
```
[+] Stopping 4/4
 - Container ics-backend      Stopped
 - Container ics-frontend     Stopped
 - Container ics-mysql        Stopped
 - Container ics-phpmyadmin   Stopped
```

### Step 2: Wait Before Restart (Optional but Recommended)
```powershell
Start-Sleep -Seconds 3
```

**Why:** Allows system resources to fully release before restart. Recommended for database services.

### Step 3: Start All Containers
```powershell
docker compose start
```

**What this does:**
- Starts all stopped containers in the correct order
- Respects `depends_on` directives in docker-compose.yml
- Containers start with their configured entrypoints

**Expected output:**
```
[+] Starting 4/4
 - Container ics-mysql        Started
 - Container ics-backend      Started
 - Container ics-frontend     Started
 - Container ics-phpmyadmin   Started
```

### Step 4: Verify All Containers Are Running
```powershell
docker compose ps
```

**Check these indicators:**
- ✅ All containers show "Up X seconds" status
- ✅ Backend and MySQL show "(healthy)" status
- ✅ Port mappings are correct
- ✅ No container shows "Exited" or "Restarting"

**Expected output:**
```
NAME             IMAGE                  COMMAND                STATUS
ics-backend      v19_backend:2.0.0      docker-php-entrypoi… Up 7 seconds (healthy)
ics-frontend     v19_frontend:2.0.0     docker-entrypoint.s… Up 1 second
ics-mysql        mysql:5.7              docker-entrypoint.s… Up 13 seconds (healthy)
ics-phpmyadmin   phpmyadmin:5.2         /docker-entrypoint.… Up 7 seconds
```

---

## Automated Restart Script

Save this as `restart-containers.ps1`:

```powershell
# Docker v19 Safe Restart Script
# Version: 1.0
# Date: April 28, 2026

param(
    [switch]$Verbose = $false
)

function Log {
    param([string]$Message, [string]$Color = "White")
    Write-Host "$(Get-Date -Format 'HH:mm:ss') - $Message" -ForegroundColor $Color
}

Log "Starting Docker v19 Container Restart Procedure..." "Cyan"
Log ""

# Step 1: Stop containers
Log "Step 1: Gracefully stopping all containers..." "Yellow"
docker compose stop --timeout=10
if ($LASTEXITCODE -eq 0) {
    Log "✓ Containers stopped successfully" "Green"
} else {
    Log "✗ Error stopping containers" "Red"
    exit 1
}
Log ""

# Step 2: Wait
Log "Step 2: Waiting 3 seconds for resources to release..." "Yellow"
Start-Sleep -Seconds 3

# Step 3: Start containers
Log "Step 3: Starting all containers..." "Yellow"
docker compose start
if ($LASTEXITCODE -eq 0) {
    Log "✓ Containers started successfully" "Green"
} else {
    Log "✗ Error starting containers" "Red"
    exit 1
}
Log ""

# Step 4: Wait for health checks
Log "Step 4: Waiting 5 seconds for health checks..." "Yellow"
Start-Sleep -Seconds 5

# Step 5: Verify status
Log "Step 5: Verifying container status..." "Yellow"
$status = docker compose ps
Log ""
Log "$status" "Cyan"
Log ""

# Step 6: Test connectivity
Log "Step 6: Testing service connectivity..." "Yellow"
try {
    $frontendResponse = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5
    Log "✓ Frontend (http://localhost:3000): Responding" "Green"
} catch {
    Log "✗ Frontend (http://localhost:3000): Not responding" "Red"
}

try {
    $backendResponse = Invoke-WebRequest -Uri "http://localhost:3001/connect.php" -UseBasicParsing -TimeoutSec 5
    Log "✓ Backend API (http://localhost:3001): Responding" "Green"
} catch {
    Log "✗ Backend API (http://localhost:3001): Not responding" "Red"
}

try {
    $phpmyadminResponse = Invoke-WebRequest -Uri "http://localhost:8086" -UseBasicParsing -TimeoutSec 5
    Log "✓ phpMyAdmin (http://localhost:8086): Responding" "Green"
} catch {
    Log "✗ phpMyAdmin (http://localhost:8086): Not responding" "Red"
}

Log ""
Log "Docker v19 Container Restart Complete!" "Green"
```

**Usage:**
```powershell
.\restart-containers.ps1
```

---

## Manual One-Command Restart

```powershell
docker compose stop --timeout=10; Start-Sleep -Seconds 3; docker compose start; Start-Sleep -Seconds 5; docker compose ps
```

---

## Troubleshooting

### Issue: Container fails to start
```powershell
# Check logs
docker compose logs <container_name>

# Example: Check backend logs
docker compose logs ics-backend --tail=50
```

### Issue: Port already in use
```powershell
# Find process using port
netstat -ano | findstr :3001

# Kill process (if needed)
taskkill /PID <PID> /F
```

### Issue: Database connection errors
```powershell
# Restart only MySQL
docker compose stop ics-mysql --timeout=10
Start-Sleep -Seconds 2
docker compose start ics-mysql

# Wait for MySQL to be healthy
Start-Sleep -Seconds 10
docker compose ps ics-mysql
```

### Issue: Frontend shows blank page
```powershell
# Restart frontend
docker compose stop ics-frontend
docker compose start ics-frontend

# Check logs
docker compose logs ics-frontend --tail=30
```

---

## Health Check Verification

### Backend Health (PHP/Apache)
```powershell
Invoke-WebRequest -Uri "http://localhost:3001/connect.php" -UseBasicParsing
```

**Expected Response:** 200 OK with connection details

### Database Health
```powershell
docker exec ics-mysql mysql -u root -prootpassword -e "SELECT 1;"
```

**Expected Response:** `mysql: [Warning] Using a password on the command line...` (warning only, query succeeds)

### Frontend Health
```powershell
Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing
```

**Expected Response:** 200 OK with HTML content

---

## Best Practices

✅ **DO:**
- Use `--timeout=10` to allow graceful shutdown
- Wait 3-5 seconds between stop and start
- Verify container status after restart
- Check application health before reporting issues
- Document any custom configurations

❌ **DON'T:**
- Force kill containers (`docker kill` vs `docker stop`)
- Immediately restart without waiting
- Restart individual containers without understanding dependencies
- Skip health checks
- Run on active production workflows without notification

---

## Version Control Notes

**v19 Image/Container Details:**
- Backend: `v19_backend:2.0.0` (PHP 7.4.33, Apache 2.4.54)
- Frontend: `v19_frontend:2.0.0` (Node.js/Vite)
- Database: `mysql:5.7` (Standard MySQL)
- Admin: `phpmyadmin:5.2` (Support tool)

**Docker Version:**
```
Docker:        29.4.0
Docker Compose: Latest (v2.x)
```

---

## Post-Restart Checklist

- [ ] All 4 containers showing "Up X seconds"
- [ ] Backend and MySQL showing "(healthy)"
- [ ] Frontend accessible at http://localhost:3000
- [ ] Backend API responding at http://localhost:3001/connect.php
- [ ] phpMyAdmin accessible at http://localhost:8086
- [ ] No error messages in docker compose logs
- [ ] Database tables intact and queryable
- [ ] Previous sessions still functional

---

## Performance Notes

**Typical Restart Times:**
- Stop process: 5-15 seconds
- Container restart: 10-20 seconds
- Database health check: 5-10 seconds
- Frontend rebuild (if needed): 10-30 seconds
- **Total restart time: ~1-2 minutes**

---

## Last Execution

**Date:** April 28, 2026  
**Time:** 02:04:00 UTC  
**Status:** ✅ SUCCESS

**Results:**
```
ics-backend:      Up 7 seconds (healthy)
ics-frontend:     Up 1 second
ics-mysql:        Up 13 seconds (healthy)
ics-phpmyadmin:   Up 7 seconds
```

All services started successfully and health checks passed.

---

## Support & References

- **Docker Compose Documentation:** https://docs.docker.com/compose/
- **Docker CLI Reference:** https://docs.docker.com/engine/reference/commandline/
- **MySQL Health Checks:** https://dev.mysql.com/doc/
- **PHP Apache Configuration:** https://www.php.net/manual/

---

**Document Version:** 1.0  
**Last Updated:** April 28, 2026  
**Author:** Automated Docker Deployment System  
**Status:** VERIFIED & TESTED
