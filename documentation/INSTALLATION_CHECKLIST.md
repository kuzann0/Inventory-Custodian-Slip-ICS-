# ICS System - Installation & Verification Checklist

**Last Updated**: March 28, 2026 | **Version**: 2.0 | **Status**: Production-Ready

---

## 📋 Pre-Installation Checklist

Before starting the setup, ensure you have completed these prerequisites:

### System Requirements

- [ ] Windows 10/11, macOS 10.15+, or Linux (Ubuntu 20.04+)
- [ ] Minimum 4GB RAM (8GB recommended)
- [ ] Minimum 50GB free disk space
- [ ] Stable internet connection (for downloading Docker images)

### Software Installation

- [ ] **Docker Desktop** installed (v4.10+)
  - [ ] Download from https://www.docker.com/products/docker-desktop
  - [ ] For Windows: WSL2 backend enabled
  - [ ] Verify: Open PowerShell and run `docker --version`
- [ ] **Git** installed (optional but recommended)
  - [ ] Verify: Open PowerShell and run `git --version`
- [ ] **Text Editor** available
  - [ ] Notepad (Windows - built in)
  - [ ] VS Code (recommended)
  - [ ] Any text editor works

- [ ] **Web Browser** (any modern browser)
  - [ ] Chrome, Firefox, Safari, or Edge

### Verification Commands

```powershell
# Test Docker installation
docker --version
# Expected: Docker version 24.0.0 or higher

# Test Docker Compose
docker-compose --version
# Expected: Docker Compose version 2.20.0 or higher

# Test Docker daemon
docker ps
# Expected: No error, shows container list (empty initially)
```

---

## 🔧 Step-by-Step Installation

### **PHASE 1: Pre-Deployment Preparation** (5-10 minutes)

#### Step 1.1: Download/Clone Project

- [ ] Project directory exists at: `c:\Users\User\Downloads\Compressed\ICS\Inventory-Custodian-Slip-ICS--3\Inventory-Custodian-Slip-ICS--3`
- [ ] Verify folder contains:
  - [ ] `docker-compose.yml`
  - [ ] `frontend/` folder with Dockerfile
  - [ ] `backend/` folder with Dockerfile
  - [ ] `DEPLOYMENT_SETUP.md` (this guide)

#### Step 1.2: Configure Custom Domain (Optional)

**For Windows:**

- [ ] Open Notepad as Administrator
- [ ] Go to: `File → Open`
- [ ] Navigate to: `C:\Windows\System32\drivers\etc`
- [ ] Change file type to "All Files (_._)"
- [ ] Select: `hosts`
- [ ] Add this line at the end: `127.0.0.1  ics.local`
- [ ] Save file (Ctrl+S)
- [ ] Open PowerShell as Administrator
- [ ] Run: `ipconfig /flushdns`
- [ ] Verify with: `ping ics.local` (should ping 127.0.0.1)

**For macOS/Linux:**

- [ ] Open Terminal
- [ ] Run: `sudo nano /etc/hosts`
- [ ] Add: `127.0.0.1  ics.local`
- [ ] Save: Ctrl+O, Enter, Ctrl+X
- [ ] For macOS: `sudo dscacheutil -flushcache`
- [ ] For Linux: `sudo systemctl restart systemd-resolved`
- [ ] Verify: `ping ics.local`

- [ ] Hosts file configuration complete

#### Step 1.3: Verify Docker Desktop

- [ ] Docker Desktop is running (check system tray)
- [ ] Run test command: `docker ps`
- [ ] Result should be success with no errors

---

### **PHASE 2: Initial Build & Deployment** (5-20 minutes)

#### Step 2.1: Navigate to Project Directory

**Windows PowerShell:**

```powershell
cd "c:\Users\User\Downloads\Compressed\ICS\Inventory-Custodian-Slip-ICS--3\Inventory-Custodian-Slip-ICS--3"
```

- [ ] Successfully navigated to project directory
- [ ] Prompt shows correct path

#### Step 2.2: Build and Start Containers

```powershell
docker-compose up --build
```

- [ ] Build started without errors
- [ ] Watch for output messages:

**Expected messages during build:**

```
ics-mysql   | 2026-03-28 10:00:00 0 [System]
ics-backend | Step 1/12 FROM php:7.4-apache
ics-frontend | Step 1/13 FROM node:18-alpine
```

**Build progress:**

- [ ] Database image pulling... (1-2 min)
- [ ] Backend image building... (1 min)
- [ ] Frontend image building... (2-5 min - npm install)
- [ ] Containers starting... (30 seconds)

**Expected final messages:**

```
✓ ics-mysql   HEALTHY
✓ ics-backend HEALTHY
✓ ics-frontend ready
```

- [ ] All three containers show healthy/ready status
- [ ] No error messages
- [ ] Console shows ready state

_This takes 2-5 minutes on first run. Subsequent builds are much faster._

#### Step 2.3: Verify Services are Running

Open **NEW** PowerShell window (keep build window open):

```powershell
docker-compose ps
```

- [ ] Shows 4 running containers:
  - [ ] ics-mysql (Up)
  - [ ] ics-backend (Up)
  - [ ] ics-frontend (Up)
  - [ ] ics-phpmyadmin (Up)

---

### **PHASE 3: Application Access & Verification** (5-10 minutes)

#### Step 3.1: Access the Application

**Option A: Via Localhost** (Works immediately)

- [ ] Open browser (Chrome, Firefox, etc.)
- [ ] Navigate to: `http://localhost:3000`
- [ ] Page loads without error
- [ ] Login page displays

**Option B: Via Custom Domain** (If configured in Step 1.2)

- [ ] Open browser
- [ ] Navigate to: `http://ics.local:3000`
- [ ] Page loads without error
- [ ] Login page displays

- [ ] Frontend application is accessible

#### Step 3.2: Test Login Functionality

- [ ] Enter test credentials
- [ ] Click "Login" button
- [ ] Verify no console errors (Press F12, check Console tab)
- [ ] Application responds to login attempt

#### Step 3.3: Access Database Management UI

- [ ] Open new browser tab
- [ ] Navigate to: `http://localhost:8086`
- [ ] phpMyAdmin page loads
- [ ] Login with:
  - [ ] Username: `root`
  - [ ] Password: `rootpassword`
- [ ] Can see database tables
- [ ] Can access `my_app_db` database

- [ ] phpMyAdmin is accessible and working

#### Step 3.4: Verify Backend API

- [ ] In browser console (F12), check Network tab
- [ ] Make a request through the app
- [ ] Verify API calls to `/api/` succeed (status 200)
- [ ] Responses are valid JSON

- [ ] Backend API is responding correctly

---

### **PHASE 4: Development Verification** (5 minutes)

#### Step 4.1: Test Frontend Hot Reload

- [ ] Keep application running in browser
- [ ] Open `frontend/src/App.jsx` in text editor
- [ ] Make a small change to the code (e.g., change a label text)
- [ ] Save file
- [ ] Browser automatically reloads (within 1-2 seconds)
- [ ] Change is visible in browser

- [ ] Vite hot module replacement (HMR) is working

#### Step 4.2: Test Backend Auto-Reload

- [ ] Open `backend/connect.php` in text editor
- [ ] Make a small change (e.g., add a comment)
- [ ] Save file
- [ ] Click "Test Connection" button in app (or refresh page)
- [ ] Backend responds with updated code

- [ ] Backend hot reload is working

#### Step 4.3: Check Container Logs

```powershell
# In a new PowerShell window
docker-compose logs frontend
```

- [ ] Shows Vite server output
- [ ] No persistent error messages
- [ ] Shows successful build

```powershell
docker-compose logs backend
```

- [ ] Shows Apache startup messages
- [ ] No fatal errors
- [ ] Status shows running

```powershell
docker-compose logs db
```

- [ ] Shows "ready for connections"
- [ ] No connection errors
- [ ] Database is healthy

- [ ] All container logs are healthy

---

## ✅ Verification Checklist - Complete Installation

### Basic Functionality

- [ ] Docker Desktop is running
- [ ] All 4 containers are running: `docker-compose ps`
- [ ] Frontend loads at `http://localhost:3000`
- [ ] No JavaScript errors in browser console (F12)
- [ ] Login page displays correctly

### Backend Connectivity

- [ ] Backend API responds to requests
- [ ] Database connection successful
- [ ] API calls show status 200
- [ ] phpMyAdmin accessible at `http://localhost:8086`

### Development Features

- [ ] Vite hot reload works (edit frontend file, save, auto-reload)
- [ ] Backend files auto-reload on save
- [ ] Code changes appear immediately
- [ ] Console logs show proper output

### Data Persistence

- [ ] Database persists across container restarts
- [ ] MySQL named volume exists: `docker volume ls`
- [ ] Changes to database are retained after restart

### Environment

- [ ] Custom domain ics.local resolves (if configured)
- [ ] No port conflicts
- [ ] Services restart cleanly: `docker-compose down && docker-compose up`
- [ ] No permission errors in logs

---

## 🚀 Post-Installation Tasks

### Recommended Next Steps

1. **Review Project Structure**
   - [ ] Explore `frontend/src/` to understand React components
   - [ ] Review `backend/` PHP files to understand API endpoints
   - [ ] Check `documentation/` for additional guides

2. **Customization**
   - [ ] Update application name/branding
   - [ ] Modify login credentials
   - [ ] Adjust database schema as needed
   - [ ] Add new features to frontend/backend

3. **Testing**
   - [ ] Test all login scenarios
   - [ ] Test data entry submission
   - [ ] Test data viewing and filtering
   - [ ] Test database management features

4. **Backup**
   - [ ] Export database: Use phpMyAdmin → Export
   - [ ] Commit code to version control if using Git
   - [ ] Document any configuration changes

5. **Documentation**
   - [ ] Update README with deployment instructions
   - [ ] Document any custom modifications
   - [ ] Record environment-specific settings

---

## 🔄 Daily Workflow

### Starting Development Session

```powershell
# Open PowerShell and navigate to project
cd "c:\Users\User\Downloads\Compressed\ICS\Inventory-Custodian-Slip-ICS--3\Inventory-Custodian-Slip-ICS--3"

# Start services
docker-compose up

# In browser, open: http://localhost:3000
```

### Ending Development Session

```powershell
# In PowerShell where docker-compose is running:
# Press Ctrl+C to stop

# Optional: Stop and remove containers (keeps data)
docker-compose down

# Optional: Full cleanup (removes all images/volumes)
docker-compose down -v
```

### Quick Commands

```powershell
# View all services
docker-compose ps

# View live logs
docker-compose logs -f

# Restart specific service
docker-compose restart frontend

# Execute command in container
docker-compose exec frontend sh
```

---

## ❌ Troubleshooting During Installation

### Issue: "Docker is not running"

**Solution:**

```powershell
# Restart Docker Desktop
# Or:
wsl --list --verbose  # Check WSL 2 status (Windows)
# Restart computer if needed
```

### Issue: "Port already in use"

**Solution:**

```powershell
# Find what's using port 3000
netstat -ano | findstr "3000"

# Kill that process or modify docker-compose.yml
# Change "3000:5173" to "3001:5173"
# Then access http://localhost:3001
```

### Issue: "npm install fails in Docker"

**Solution:**

```powershell
# Rebuild frontend
docker-compose up --build frontend

# Or clean rebuild
docker-compose down
docker image prune -f
docker-compose up --build
```

### Issue: "Database connection fails"

**Solution:**

```powershell
# Check if MySQL is healthy
docker-compose logs db

# Wait 30+ seconds (MySQL needs time to initialize)
# Then restart backend
docker-compose restart backend
```

### Issue: "Frontend shows blank page"

**Solution:**

1. Open browser console (F12)
2. Check for error messages
3. If API error: `docker-compose logs backend`
4. If build error: `docker-compose logs frontend`
5. Rebuild if needed: `docker-compose up --build frontend`

### Issue: "Changes not appearing"

**For Frontend:**

```powershell
# Hard refresh browser
Ctrl+Shift+R (most browsers)

# Or restart frontend container
docker-compose restart frontend
```

**For Backend:**

```powershell
# Restart backend container
docker-compose restart backend

# Or check file permissions
docker-compose logs backend
```

---

## 📊 Installation Success Indicators

### Green Lights ✅

- All containers healthy/running
- Frontend loads in browser
- No JavaScript errors in console
- Backend API responding
- Database accessible via phpMyAdmin
- Code changes auto-reload
- No port conflicts
- Services survive restart

### Red Flags ❌

- Any container marked "unhealthy"
- Browser shows "Connection refused"
- Console full of error messages
- API calls return non-200 status
- Database unreachable
- Changes don't auto-reload
- Port conflict errors
- Containers crash on restart

---

## 📞 Getting Help

### Information to Collect

```powershell
# Container status
docker-compose ps

# All service logs
docker-compose logs > c:\temp\ics-logs.txt

# Docker system info
docker system info

# List all images
docker images

# List volumes
docker volume ls
```

### Common Resources

- Docker Docs: https://docs.docker.com/
- Vite Docs: https://vitejs.dev/guide/
- React Docs: https://react.dev/
- PHP Docs: https://www.php.net/docs.php

---

## 🎉 Congratulations!

You have successfully:

- ✅ Configured Docker environment
- ✅ Built and deployed ICS System containers
- ✅ Verified all services are working
- ✅ Tested frontend and backend integration
- ✅ Confirmed database connectivity
- ✅ Enabled development hot reload

**Your ICS System is ready for development!**

---

**Next**: Open the [DEPLOYMENT_SETUP.md](DEPLOYMENT_SETUP.md) for comprehensive usage documentation.
