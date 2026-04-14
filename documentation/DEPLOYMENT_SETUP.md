# ICS System - Complete Deployment Setup Guide

**Version**: 2.0 | **Date**: March 28, 2026 | **Status**: Production-Ready

---

## 🎯 Quick Start (30 seconds)

For users who just want to run the system:

```powershell
# Step 1: Build and start all containers
docker-compose up --build

# Step 2: Open browser (in a new terminal/window)
start http://localhost:3000

# OR with custom domain (after Step 3 below)
start http://ics.local:3000
```

**That's it!** The system will be running. No manual `npm install` needed.

---

## 📋 Prerequisites

Before you start, ensure you have installed:

- **Docker Desktop** (v4.10+) - [Download](https://www.docker.com/products/docker-desktop)
- **Docker Compose** (included with Docker Desktop)
- **Git** (optional, for cloning the repository)
- **Text Editor** (for editing hosts file; Notepad works fine)

### Verify Installation

```powershell
# Check Docker
docker --version

# Check Docker Compose
docker-compose --version

# Expected outputs:
# Docker version 24.0.0 or higher
# Docker Compose version 2.20.0 or higher
```

---

## 🔧 Setup Steps

### Step 1: Configure Custom Localhost Domain (Optional but Recommended)

**Purpose**: Access the system via `http://ics.local:3000` instead of `http://localhost:3000`

**For Windows:**

1. **Open Notepad as Administrator**
   - Press `Win + R`, type `notepad`, press `Ctrl + Shift + Enter`
   - Or right-click Notepad → "Run as administrator"

2. **Open the Hosts File**
   - File → Open
   - Navigate to: `C:\Windows\System32\drivers\etc\hosts`
   - Change file type filter to "All Files (_._)"
   - Select `hosts` file

3. **Add this line at the end of the file**

   ```
   127.0.0.1  ics.local
   ```

4. **Save and close file**
   - Press `Ctrl + S`
   - Close Notepad

5. **Flush DNS Cache** (so Windows recognizes the new entry)

   ```powershell
   ipconfig /flushdns
   ```

6. **Verify it works**
   ```powershell
   ping ics.local
   # Should respond: Reply from 127.0.0.1
   ```

**For macOS:**

```bash
# Open terminal and edit hosts file
sudo nano /etc/hosts

# Add this line at the end:
127.0.0.1  ics.local

# Press Ctrl+O, Enter, Ctrl+X to save and exit

# Flush DNS cache
sudo dscacheutil -flushcache

# Verify
ping ics.local
```

**For Linux:**

```bash
# Edit hosts file
sudo nano /etc/hosts

# Add this line at the end:
127.0.0.1  ics.local

# Save and exit (Ctrl+O, Enter, Ctrl+X)

# Flush DNS cache (if using systemd-resolved)
sudo systemctl restart systemd-resolved

# Verify
ping ics.local
```

---

### Step 2: Initial Build (First Time Only)

**Purpose**: Build Docker images for all services and install dependencies

```powershell
# Navigate to project directory
cd c:\Users\User\Downloads\Compressed\ICS\Inventory-Custodian-Slip-ICS--3\Inventory-Custodian-Slip-ICS--3

# Build and start all services
docker-compose up --build
```

**What happens during this step:**

1. **Frontend Dockerfile builds:**
   - Installs Node.js dependencies (npm install)
   - This is done ONCE and cached for future builds
   - Result: `node_modules` is now part of the Docker image

2. **Backend Dockerfile builds:**
   - Sets up PHP/Apache environment
   - Installs mysqli extension

3. **Database initializes:**
   - Creates MySQL container
   - Runs `entries_backup.sql` automatically
   - Creates tables and initial data

4. **Services start:**
   - MySQL will be ready first
   - Backend waits for MySQL (health check)
   - Frontend waits for Backend (health check)
   - PhpMyAdmin connects to MySQL

**You should see output like:**

```
ics-mysql ✓ healthy
ics-backend ✓ healthy
ics-frontend ✓ ready
```

**This takes 2-5 minutes the first time.** Subsequent starts are much faster (10-20 seconds).

---

### Step 3: Access the Application

Once all services show "healthy" or "ready", open your browser:

**Option A: Via Localhost (Works immediately)**

```
http://localhost:3000
```

**Option B: Via Custom Domain (After Step 1 setup)**

```
http://ics.local:3000
```

**Expected Result**: You should see the ICS System login page.

---

## 🚀 Subsequent Runs (After Initial Setup)

After the first build, starting the system is extremely fast:

```powershell
# Start all services (no rebuild)
docker-compose up

# Press Ctrl+C to stop services

# Optional: Stop and remove containers (keeps data)
docker-compose down

# Optional: Remove everything including volumes/data
docker-compose down -v
```

**Time to startup: ~10-20 seconds** (vs 2-5 minutes for first build)

---

## 🗂️ Project Architecture

### Directory Structure

```
ICS-System/
├── docker-compose.yml          ← Main orchestration file
├── frontend/
│   ├── Dockerfile              ← Frontend build instructions
│   ├── package.json            ← npm dependencies
│   ├── vite.config.js          ← Vite configuration
│   ├── src/
│   │   ├── App.jsx
│   │   ├── main.jsx
│   │   └── ...
│   └── node_modules/           ← Will be created by Docker
├── backend/
│   ├── Dockerfile              ← Backend build instructions
│   ├── connect.php
│   ├── login.php
│   ├── submit.php
│   ├── get_entries.php
│   └── database/
│       └── entries_backup.sql  ← Database initialization
├── documentation/
│   ├── Ports.md
│   ├── ColorCoding.md
│   └── Deployment.md
└── CONNECTIVITY_ANALYSIS.md    ← Network analysis
```

### Container Network

```
┌─ Your Local Machine ────────────────────────────────────────┐
│                                                              │
│  Browser (localhost:3000)                                   │
│       │                                                      │
│       ├─→ Docker Bridge Network (ics-network)              │
│       │                                                      │
│       ├─→ Frontend Container (port 3000→5173)             │
│       │   └─ Vite Dev Server + React                      │
│       │   └─ Makes API calls to: http://localhost:8080    │
│       │                                                      │
│       ├─→ Backend Container (port 8080→80)                │
│       │   └─ PHP/Apache                                    │
│       │   └─ Connects to MySQL via: db:3306               │
│       │                                                      │
│       ├─→ Database Container (port 3307→3306)             │
│       │   └─ MySQL 5.7                                    │
│       │   └─ Persisted volume: mysql_data                 │
│       │                                                      │
│       └─→ PhpMyAdmin Container (port 8086)                │
│           └─ Database Management UI                        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Port Mapping Reference

| Service          | Container Port | Host Port | Access URL            | Purpose                     |
| ---------------- | -------------- | --------- | --------------------- | --------------------------- |
| Frontend (Vite)  | 5173           | **3000**  | http://localhost:3000 | React Admin Dashboard       |
| Backend (Apache) | 80             | 8080      | http://localhost:8080 | PHP API Server              |
| Database (MySQL) | 3306           | 3307      | localhost:3307        | Direct DB access (optional) |
| PhpMyAdmin       | 80             | 8086      | http://localhost:8086 | Database UI                 |

---

## 🔐 Environment Configuration

### Database Credentials (Docker Setup)

These values are configured in `docker-compose.yml`:

```yaml
MYSQL_ROOT_PASSWORD: rootpassword
MYSQL_DATABASE: my_app_db
```

### Frontend Configuration

Frontend environment variables in `docker-compose.yml`:

```yaml
VITE_API_URL: http://localhost:8080
VITE_APP_NAME: ICS System
```

**Can be customized** by editing `docker-compose.yml` services → frontend → environment

### Backend Configuration

Backend auto-detects MySQL via service name `db` on the Docker network:

```php
$servername = "db";      // Docker service name
$username   = "root";    // From docker-compose.yml
$password   = "rootpassword";  // From docker-compose.yml
$dbname     = "my_app_db";    // From docker-compose.yml
```

---

## 🧹 Troubleshooting Guide

### Issue 1: Port Already in Use

**Error**: `bind: permission denied` or `Address already in use`

**Solution**:

```powershell
# Check what's using the port
netstat -ano | findstr "3000"

# Kill the process (if safe)
# OR modify docker-compose.yml port mapping:
# Change "3000:5173" to "3001:5173"
# Then access: http://localhost:3001
```

### Issue 2: Docker Containers Won't Start

**Error**: Containers keep restarting

**Solution**:

```powershell
# View logs
docker-compose logs

# View specific service logs
docker-compose logs frontend
docker-compose logs backend
docker-compose logs db

# Restart everything
docker-compose down
docker-compose up --build
```

### Issue 3: Frontend Shows Blank Page

**Error**: White/blank screen, no React app

**Possible causes**:

1. **Frontend build failed**: Check logs

   ```powershell
   docker-compose logs frontend
   ```

2. **API connection failed**: Check browser console (F12)
   - Should see API responses if database is connected

3. **Node modules issue**: Rebuild just frontend
   ```powershell
   docker-compose up --build frontend
   ```

### Issue 4: Database Connection Fails

**Error**: "Connection failed: Can't connect to MySQL"

**Solution**:

```powershell
# Check if MySQL is healthy
docker-compose logs db

# Wait for MySQL to fully start (30+ seconds on first run)
# Then restart backend
docker-compose restart backend
```

### Issue 5: phpMyAdmin Won't Load

**Error**: 404 or blank page at localhost:8086

**Solution**:

```powershell
# Restart phpmyadmin service
docker-compose restart phpmyadmin

# Check logs
docker-compose logs phpmyadmin
```

### Issue 6: Changes to Code Not Appearing

**Frontend changes not showing:**

```powershell
# Vite auto-reloads on save, but sometimes needs a hard refresh
# Try: Ctrl+Shift+R (hard refresh)
# Or restart the frontend service
docker-compose restart frontend
```

**Backend changes not showing:**

```powershell
# Backend changes auto-reload (hot reload)
# If not, restart backend service
docker-compose restart backend
```

---

## 🔄 Development Workflow

### Typical Development Session

```powershell
# Terminal 1: Start the application
cd ICS-System
docker-compose up

# Terminal 2: Edit code and watch it reload automatically
# Frontend changes: Auto-reloads via Vite HMR
# Backend changes: Auto-reloads via Apache

# When done:
# Press Ctrl+C in Terminal 1 to stop services
```

### Making Backend Database Changes

1. **Edit PHP files** → Auto-reloaded
2. **Add API endpoints** → Edit `.php` files
3. **Modify database schema**:

   ```powershell
   # Method 1: Use phpMyAdmin
   # Go to http://localhost:8086
   # Log in with root / rootpassword
   # Create tables, add columns, etc.

   # Method 2: Update entries_backup.sql then rebuild
   # Edit: backend/database/entries_backup.sql
   # Run: docker-compose down -v && docker-compose up --build
   ```

### Making Frontend Changes

1. **Edit React files** → Auto-reloads in Vite
2. **Add dependencies**:
   ```powershell
   # Can't use `npm install` directly
   # Instead, edit package.json then rebuild:
   docker-compose up --build frontend
   ```

---

## 📈 Performance Optimization

### Initial Build Time

**First build:** ~2-5 minutes

- Longer due to downloading images and installing dependencies

**Subsequent starts:** ~10-20 seconds

- Docker caches are used
- Dependencies were already installed

### Speeding Up Development

1. **Use volumes for live reload**:
   - Already configured for frontend and backend
   - Changes appear immediately without rebuilding

2. **Reduce Docker build context**:
   - Add `.dockerignore` files to exclude unnecessary files

3. **Pre-install dependencies**:
   - Happens in Dockerfile, already optimized

---

## 🚢 Deployment Preparation

### For Production

**Do NOT use this setup as-is in production.** Instead:

1. **Build frontend to static files**:

   ```dockerfile
   # Use multi-stage build
   FROM node:18-alpine as builder
   WORKDIR /app
   COPY package.json package-lock.json ./
   RUN npm install
   COPY . .
   RUN npm run build

   FROM nginx:alpine
   COPY --from=builder /app/dist /usr/share/nginx/html
   EXPOSE 80
   CMD ["nginx", "-g", "daemon off;"]
   ```

2. **Use environment variables**:
   - Store secrets in `.env` file (git-ignored)
   - Don't hardcode passwords

3. **Enable HTTPS**:
   - Use Let's Encrypt with Certbot
   - Or use reverse proxy with SSL termination

4. **Set resource limits**:

   ```yaml
   services:
     db:
       deploy:
         resources:
           limits:
             cpus: "2"
             memory: 2G
   ```

5. **Use health checks**:
   - Already configured in docker-compose.yml

---

## 🛠️ Docker Compose Commands Reference

### Essential Commands

```powershell
# Build and start all services
docker-compose up --build

# Start services (no rebuild)
docker-compose up

# Start in background
docker-compose up -d

# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# View logs
docker-compose logs

# View specific service logs
docker-compose logs frontend
docker-compose logs -f backend  # Follow (live)

# Restart services
docker-compose restart

# Restart specific service
docker-compose restart frontend

# View running containers
docker-compose ps

# Execute command in container
docker-compose exec frontend sh
docker-compose exec backend bash
docker-compose exec db mysql -uroot -prootpassword my_app_db

# View Docker images
docker images

# Remove unused images
docker image prune

# View volumes
docker volume ls

# Inspect service details
docker-compose config
```

---

## 📝 Files Modified/Created

### New/Updated Files

1. **frontend/Dockerfile** ✨ NEW
   - Installs npm dependencies at build time
   - Runs Vite dev server

2. **docker-compose.yml** 🔄 UPDATED
   - Added frontend service
   - Added MySQL health checks
   - Added named volumes
   - Added custom network
   - Added environment variables
   - Added proper restart policies

3. **backend/Dockerfile** 🔄 UPDATED
   - Added curl for health checks
   - Added Apache rewrite module
   - Improved permission handling

### Configuration Complete

✅ Automated npm install  
✅ Unified entry point (localhost:3000)  
✅ Custom domain support (ics.local)  
✅ Service health checks  
✅ Persistent database  
✅ Live code reload  
✅ Clean shutdown behavior  
✅ Production-ready structure

---

## ✅ Verification Checklist

After setup, verify everything works:

- [ ] Docker Desktop is running
- [ ] hosts file entry added (for ics.local)
- [ ] Initial build completed: `docker-compose up --build`
- [ ] Frontend loads: http://localhost:3000
- [ ] Can log in to ICS System
- [ ] PhpMyAdmin accessible: http://localhost:8086
- [ ] Database credentials work: root / rootpassword
- [ ] API calls succeed (check browser console)
- [ ] Code changes auto-reload (Vite HMR active)
- [ ] Services restart properly: `docker-compose down && docker-compose up`

---

## 📞 Support & Issues

### Common Issues & Solutions

| Issue                             | Solution                                   |
| --------------------------------- | ------------------------------------------ |
| npm modules not installing        | Rebuild: `docker-compose up --build`       |
| Port conflicts                    | Change port mapping in docker-compose.yml  |
| Database not ready                | Increase healthcheck timeout               |
| Frontend won't connect to backend | Check `/api` proxy in vite.config.js       |
| Docker won't start                | Restart Docker Desktop or restart computer |

### Debug Information

**Collect this when reporting issues**:

```powershell
docker-compose logs > logs.txt
docker-compose ps
docker ps
docker images
```

---

## 🎓 Next Steps

1. **Start the system**: Follow "Setup Steps" above
2. **Access admin dashboard**: http://localhost:3000
3. **Test login functionality**: Use provided credentials
4. **Explore database**: http://localhost:8086
5. **Review code**: Check frontend/ and backend/ directories
6. **Make modifications**: Add features or customize UI

---

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Vite Documentation](https://vitejs.dev/)
- [React Documentation](https://react.dev/)
- [PHP Documentation](https://www.php.net/docs.php)

---

**Document Version**: 2.0  
**Last Updated**: March 28, 2026  
**Status**: Production-Ready  
**Maintainer**: Systems Engineering Team
