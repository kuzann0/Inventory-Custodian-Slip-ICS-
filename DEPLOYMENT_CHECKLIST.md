# ✅ Deployment Checklist - ICS System

Use this checklist to verify your project is correctly set up for cross-machine deployment.

---

## 🔧 Pre-Deployment Verification

### 1. **File Integrity**
- [ ] All project files are copied to target machine
- [ ] No files are corrupted (file size > 0 KB)
- [ ] `.env.local` template exists
- [ ] `docker-compose.yml` exists and is valid
- [ ] Database initialization script exists: `backend/database/COMPLETE_DATABASE_FIX_20260514.sql`

**Command to verify:**
```bash
ls -la backend/database/COMPLETE_DATABASE_FIX_20260514.sql
```

### 2. **Docker & Prerequisites**
- [ ] Docker Desktop installed (v24.0+)
- [ ] Docker Compose installed (v2.20+)
- [ ] Sufficient disk space (minimum 5GB)
- [ ] Sufficient RAM (minimum 4GB)
- [ ] Docker daemon is running

**Verify with:**
```bash
docker --version
docker compose version
docker ps
```

### 3. **Configuration Files**
- [ ] `.env.local` exists in project root
- [ ] `docker-compose.yml` has correct service names
- [ ] `frontend/Dockerfile` exists
- [ ] `backend/Dockerfile` exists
- [ ] `backend/composer.json` exists
- [ ] `frontend/package.json` exists

### 4. **Code Quality**
- [ ] No hardcoded localhost paths in backend code
- [ ] Frontend uses `import.meta.env.VITE_API_URL` for API URL
- [ ] Backend uses `getenv()` for database credentials
- [ ] No sensitive data in docker-compose.yml

---

## 🚀 First-Time Launch Checklist

### 1. **Pre-Launch Steps**
```bash
# Navigate to project directory
cd /path/to/ICS

# Verify docker-compose.yml syntax
docker compose config

# Pull latest images (optional)
docker compose pull
```

- [ ] `docker compose config` runs without errors
- [ ] All services are listed in output

### 2. **Start Services**
```bash
docker compose up -d
```

- [ ] No errors during startup
- [ ] All containers start successfully

### 3. **Wait for Health Checks**
```bash
# Monitor startup (2-3 minutes)
docker compose logs -f

# Check service status
docker compose ps
```

- [ ] MySQL container shows "Up" and "(healthy)"
- [ ] Backend container shows "Up" and "(healthy)"
- [ ] Frontend container shows "Up"

### 4. **Verify Connectivity**

**Frontend:**
```bash
curl http://localhost:3000
```
- [ ] Returns HTML page (not connection error)

**Backend API:**
```bash
curl http://localhost:3001/connect.php
```
- [ ] Returns JSON response with success message

**Database:**
```bash
docker exec -it ics-mysql mysql -u root -prootpassword -e "SELECT COUNT(*) FROM my_app_db.users;"
```
- [ ] Returns a number (users table initialized)

**phpMyAdmin:**
- [ ] Can access http://localhost:8086
- [ ] Can login with username "root" and password "rootpassword"

### 5. **Application Functionality**
- [ ] Can access login page at http://localhost:3000
- [ ] Can view documentation in http://localhost:3000
- [ ] No console errors in browser DevTools (F12)
- [ ] No backend errors in `docker compose logs backend`

---

## 🔍 Post-Deployment Checks

### 1. **Service Status**
```bash
docker compose ps
```
Expected output:
```
NAME                COMMAND             STATUS              PORTS
ics-frontend        npm run dev...      Up (healthy)        0.0.0.0:3000->5173/tcp
ics-backend         apache2-foreground  Up (healthy)        0.0.0.0:3001->80/tcp
ics-phpmyadmin      /docker-entrypoin.. Up                  0.0.0.0:8086->80/tcp
ics-mysql           docker-entrypoint.. Up (healthy)        0.0.0.0:3307->3306/tcp
```

- [ ] All services show "Up"
- [ ] Health checks showing "(healthy)" where applicable

### 2. **Log Verification**
```bash
docker compose logs backend | grep -i error
docker compose logs frontend | grep -i error
```

- [ ] No error messages in backend logs
- [ ] No error messages in frontend logs
- [ ] MySQL showing successful connections

### 3. **Data Persistence**
```bash
# Check volume persistence
docker volume ls | grep ics
```

- [ ] `ics_mysql_data` volume exists
- [ ] Volume is accessible

### 4. **Network Connectivity**
```bash
# Test inter-service communication
docker exec ics-backend curl http://db:3306

# Test frontend can reach backend
curl http://localhost:3000
```

- [ ] Services can communicate (no "Connection refused")
- [ ] Frontend loads successfully

---

## 🛠️ Troubleshooting Guide

### Issue: Services won't start
```bash
# Check for errors
docker compose logs

# Full reset
docker compose down -v
docker compose up -d --build
```

### Issue: Port already in use
```bash
# Edit .env file
# Change FRONTEND_PORT, BACKEND_PORT, PHPMYADMIN_PORT

# Restart
docker compose down
docker compose up -d
```

### Issue: Database connection fails
```bash
# Check MySQL health
docker compose ps db

# Access MySQL container
docker exec -it ics-mysql mysql -u root -prootpassword

# If needed, reinitialize
docker compose down -v
docker compose up -d
```

### Issue: Frontend shows connection error
```bash
# Verify backend is running
docker compose ps backend

# Check backend logs
docker compose logs backend

# Test connectivity
curl http://localhost:3001/connect.php
```

---

## 📊 Health Check Report

Fill in the date and status after each successful deployment:

| Date | Environment | Status | Notes |
|------|-------------|--------|-------|
| YYYY-MM-DD | Windows/Mac/Linux | ✅ Pass/❌ Fail | Any issues encountered |
| | | | |
| | | | |

---

## 🎯 Success Criteria

Your deployment is **SUCCESSFUL** when:

✅ All services show "Up" in `docker compose ps`
✅ Can access http://localhost:3000 without errors
✅ Can access http://localhost:3001/connect.php and receive JSON response
✅ Can login to phpMyAdmin at http://localhost:8086
✅ Database contains tables and data
✅ Browser console has no errors
✅ Backend logs show no errors

---

## 📝 Notes

Add any observations or configurations specific to your deployment:

```
Machine: __________________
OS: __________________
Docker Version: __________________
Date: __________________
Notes: __________________
```

---

**✨ Ready for production! All checks passed? You're good to go! 🚀**
