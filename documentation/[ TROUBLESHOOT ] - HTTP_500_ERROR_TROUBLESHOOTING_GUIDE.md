# HTTP 500 Error Troubleshooting Guide

## Problem Identification

You see these errors in the browser console:
```
Failed to load resource: the server responded with a status of 500 (Internal Server Error)
index.css:1, EntryForm.jsx:1, LoginForm.jsx:1, ViewEntries.jsx:1, etc.
```

---

## Root Causes

1. **Database Schema Mismatch** - PHP code queries for columns that don't exist in the database
2. **CSS Filename Mismatch** - Frontend imports `.module.css` files but actual files are named `_module.css`
3. **Stale Docker Image** - Frontend Docker image built from old code with wrong filenames

---

## Step-by-Step Fix Process

### PART 1: Check Database (if backend 500 errors)

#### Check Error Logs
```bash
# View PHP error logs
docker exec ics-backend tail -20 /var/www/html/php_errors.log

# Look for errors like:
# - Unknown column 'pr.pr_no' in 'field list'
# - Unknown column 'e.approved_by_name' in 'field list'
# - Table 'my_app_db.entry_workflow_status' doesn't exist
```

#### Fix Database
```bash
# 1. Stop all containers
docker-compose down

# 2. Remove MySQL volume (this deletes old data)
docker volume rm ics_mysql_data

# 3. Update docker-compose.yml to use latest backup
# Change the db service volumes section to:
#   - ./backend/database/COMPLETE_DATABASE_FIX_20260514.sql:/docker-entrypoint-initdb.d/init.sql

# 4. Start containers
docker-compose up -d

# 5. Verify database initialized correctly
docker logs ics-mysql | tail -20

# 6. Clear PHP error log
docker exec ics-backend bash -c "truncate -s 0 /var/www/html/php_errors.log"
```

#### Verify Database Schema
```bash
# Test that API works now
curl http://localhost:3001/get_entries.php

# Should return JSON with status: "success", not 500 error
```

---

### PART 2: Check Frontend (if static asset 500 errors)

#### Check Frontend Logs
```bash
# View frontend build logs
docker logs ics-frontend | tail -30

# Look for errors like:
# - Failed to resolve import './css/NewPurchaseRequest.module.css'
# - ENOENT: no such file or directory
# - CSS file naming issues
```

#### Fix Frontend CSS Filenames

**Step 1: Identify the problem**
```bash
# Check what CSS files exist
dir d:\ICS\v23.1_modified2\frontend\src\css\

# Look for _module.css (wrong) vs .module.css (correct)
# Expected: *.module.css
# Found: *_module.css (this is the problem!)
```

**Step 2: Rename files**
```powershell
# Open PowerShell and navigate to CSS directory
cd 'd:\ICS\v23.1_modified2\frontend\src\css\'

# Rename all _module.css files to .module.css
Get-ChildItem -Filter '*_module.css' | ForEach-Object { 
    Rename-Item $_.FullName -NewName ($_.Name -replace '_module\.css', '.module.css') -Verbose
}

# Delete any duplicate files (e.g., if Header_module.css and Header.module.css both exist)
Remove-Item 'Header_module.css' -ErrorAction SilentlyContinue -Verbose
```

**Step 3: Rebuild Docker image**
```bash
# This is CRITICAL! Docker image must be rebuilt with the corrected files
docker-compose down frontend

# Rebuild with no cache
docker-compose build --no-cache frontend

# Start frontend
docker-compose up -d frontend

# Wait 10 seconds for startup
# sleep 10  (Linux/Mac) or Start-Sleep -Seconds 10 (PowerShell)

# Verify build succeeded
docker logs ics-frontend | tail -20
# Should NOT show any "Failed to resolve import" errors
```

---

### PART 3: Clear Cache & Test

#### Hard Refresh Browser
```
Windows/Linux:  Ctrl + Shift + R
Mac:            Cmd + Shift + R
```

#### Test API Endpoints
```bash
# Test backend API
curl http://localhost:3001/get_entries.php
curl http://localhost:3001/get_purchase_requests.php
curl http://localhost:3001/get_employees.php

# All should return 200 OK with JSON data
```

#### Verify All Containers Running
```bash
# Check container status
docker ps

# Expected output:
# - ics-frontend (port 3000->5173, status Up)
# - ics-backend (port 3001->80, status Up, HEALTHY)
# - ics-mysql (port 3307->3306, status Up, HEALTHY)
# - ics-phpmyadmin (port 8086->80, status Up)
```

---

## Quick Reference Checklist

| Issue | Check | Fix |
|-------|-------|-----|
| **Backend 500** | `docker logs ics-backend \| tail -20` for SQL errors | Update database schema from backup |
| **Frontend static assets 500** | `docker logs ics-frontend \| tail -20` for import errors | Rename CSS files & rebuild image |
| **Still seeing errors after fix** | Browser cache | Hard refresh: `Ctrl+Shift+R` |
| **Container won't start** | `docker logs [container-name]` | Check logs for specific errors |
| **Database connection failed** | `docker logs ics-mysql` | Check MySQL initialization logs |

---

## Key Files to Monitor

```
Backend PHP errors:     /var/www/html/php_errors.log
Frontend build logs:    docker logs ics-frontend
Database init logs:     docker logs ics-mysql
CSS files:              frontend/src/css/
Database backup:        backend/database/COMPLETE_DATABASE_FIX_20260514.sql
Docker config:          docker-compose.yml
```

---

## Essential Docker Commands

### View Status
```bash
# Check all containers
docker ps

# Check specific container logs
docker logs ics-backend
docker logs ics-frontend
docker logs ics-mysql
docker logs ics-phpmyadmin

# Show last N lines
docker logs --tail 50 ics-backend
```

### Restart Services
```bash
# Restart specific service
docker-compose restart frontend
docker restart ics-backend

# Restart everything
docker-compose restart
```

### Rebuild Images
```bash
# Rebuild specific service
docker-compose build --no-cache frontend

# Rebuild all services
docker-compose build --no-cache
```

### Full Reset
```bash
# Stop all containers
docker-compose down

# Remove database volume
docker volume rm ics_mysql_data

# Rebuild everything
docker-compose build --no-cache

# Start all services
docker-compose up -d

# Verify everything started
docker ps
```

---

## Troubleshooting Flowchart

```
See HTTP 500 Errors?
│
├─ Error in: PHP endpoints (get_entries.php, etc.)
│  └─ Check: docker logs ics-backend
│     └─ "Unknown column" error?
│        └─ FIX: Reset database with backup (PART 1)
│
├─ Error in: Static assets (CSS, JSX files)
│  └─ Check: docker logs ics-frontend
│     └─ "Failed to resolve import" error?
│        └─ FIX: Rename CSS files & rebuild image (PART 2)
│
└─ Errors fixed but still seeing them?
   └─ FIX: Hard refresh browser (PART 3)
```

---

## Prevention Tips

1. **After file changes** → Rebuild Docker image: `docker-compose build --no-cache [service]`
2. **After database changes** → Reset MySQL volume and reinit
3. **When CSS/JS fails** → Check file naming consistency
4. **Always clear browser cache** after deploying (`Ctrl+Shift+R`)
5. **Check logs first** → Always start with `docker logs [container]` to identify root cause
6. **Use the latest database backup** → Ensure docker-compose.yml points to the correct backup file

---

## When to Use Each Fix

### Use PART 1 (Database) when:
- Backend API endpoints return 500
- PHP error log shows "Unknown column" errors
- PHP error log shows "Table doesn't exist" errors
- get_entries.php, get_purchase_requests.php fail

### Use PART 2 (Frontend) when:
- CSS files fail to load (index.css:1)
- JSX component files fail to load (EntryForm.jsx:1)
- Frontend build logs show "Failed to resolve import"
- Frontend shows blank page or styling issues

### Use PART 3 (Browser) when:
- Errors are fixed on backend/frontend but browser still shows old errors
- Need to reload application after fixes
- Seeing stale cached resources

---

## Contact & Support

If errors persist after following these steps:

1. **Collect diagnostics:**
   ```bash
   docker logs ics-backend > backend-logs.txt
   docker logs ics-frontend > frontend-logs.txt
   docker logs ics-mysql > mysql-logs.txt
   ```

2. **Check docker-compose.yml** - Ensure it's configured correctly

3. **Verify file structure:**
   ```bash
   dir d:\ICS\v23.1_modified2\frontend\src\css\
   dir d:\ICS\v23.1_modified2\backend\database\
   ```

4. **Share logs** with the development team for further investigation

---

**Last Updated:** May 19, 2026  
**Version:** 1.0
