# ICS System - Quick Reference Guide

**One-Page Cheat Sheet for Developers** | Last Updated: March 28, 2026

---

## 🚀 Quick Start (30 seconds)

```powershell
# Navigate to project
cd path\to\ICS-System

# Start everything (first time may take 2-5 min)
docker-compose up --build

# Subsequent runs (only 10-20 seconds)
docker-compose up

# Open browser
start http://localhost:3000
```

---

## 📍 Important URLs

| Service           | URL                   | Purpose          | Credentials         |
| ----------------- | --------------------- | ---------------- | ------------------- |
| **Frontend**      | http://localhost:3000 | Admin Dashboard  | App-specific        |
| **Backend**       | http://localhost:8080 | PHP API          | N/A                 |
| **phpMyAdmin**    | http://localhost:8086 | Database UI      | root / rootpassword |
| **Custom Domain** | http://ics.local:3000 | Same as frontend | (if configured)     |

---

## 🐳 Essential Docker Commands

```powershell
# Start services
docker-compose up

# Start in background
docker-compose up -d

# Stop services
docker-compose down

# View container status
docker-compose ps

# View logs (all services)
docker-compose logs

# View specific service logs
docker-compose logs frontend          # Frontend logs
docker-compose logs -f backend        # Backend logs (live)
docker-compose logs db --tail=50      # Last 50 MySQL lines

# Restart a service
docker-compose restart frontend

# Run command in container
docker-compose exec frontend sh       # Frontend shell
docker-compose exec backend bash      # Backend shell
docker-compose exec db mysql -uroot -prootpassword my_app_db

# Full rebuild
docker-compose down -v
docker-compose up --build

# Cleanup
docker image prune                    # Remove unused images
docker volume ls                      # List volumes
```

---

## 🔧 Development Workflow

### Frontend Changes

- Edit files in `frontend/src/`
- Save → Auto-reloads ~1-2 seconds (Vite HMR)
- No restart needed

### Backend Changes

- Edit PHP files in `backend/`
- Save → Auto-reloads
- No restart needed

### Database Changes

- **Via phpMyAdmin**: http://localhost:8086 → login → modify
- **Via SQL**: Edit `backend/database/entries_backup.sql` → `docker-compose down -v && docker-compose up --build`

### Add NPM Packages

```powershell
# Cannot use `npm install` directly while running in Docker
# Instead:
# 1. Edit frontend/package.json (add dependency)
# 2. Rebuild: docker-compose up --build frontend
```

---

## 🐞 Troubleshooting Quick Fixes

| Problem                    | Solution                                                              |
| -------------------------- | --------------------------------------------------------------------- |
| **Blank page**             | F12 → Console → Check for errors                                      |
| **API not connecting**     | Check logs: `docker-compose logs backend`                             |
| **Port already in use**    | Change port in docker-compose.yml                                     |
| **Package install failed** | `docker-compose up --build frontend`                                  |
| **Database error**         | Wait 30+ sec after start, then `docker-compose restart backend`       |
| **Changes not appearing**  | Hard refresh: Ctrl+Shift+R                                            |
| **Container won't start**  | `docker-compose logs SERVICE` to see error                            |
| **Everything broken**      | Nuclear option: `docker-compose down -v && docker-compose up --build` |

---

## 📁 Project Structure

```
├── docker-compose.yml          ← Main config (don't edit often)
├── frontend/
│   ├── Dockerfile              ← Frontend build instructions
│   ├── package.json            ← npm dependencies
│   ├── vite.config.js          ← Vite config (proxy setup)
│   └── src/                    ← React application
│       ├── App.jsx             ← Main component
│       ├── LoginForm.jsx
│       ├── EntryForm.jsx
│       └── ...
├── backend/
│   ├── Dockerfile              ← Backend build instructions
│   ├── connect.php             ← Database connection
│   ├── login.php               ← Login API
│   ├── submit.php              ← Entry submission
│   ├── get_entries.php         ← Fetch entries
│   └── database/
│       └── entries_backup.sql  ← Database schema
├── DEPLOYMENT_SETUP.md         ← Complete setup guide
├── INSTALLATION_CHECKLIST.md   ← Verification steps
└── ENGINEERING_GUIDE.md        ← Technical deep dive
```

---

## 🗄️ Database Access

### Via phpMyAdmin (Easiest)

1. Go to http://localhost:8086
2. Login: `root` / `rootpassword`
3. Select `my_app_db` database
4. Browse/modify tables

### Via Command Line

```powershell
# Connect to MySQL
docker-compose exec db mysql -uroot -prootpassword my_app_db

# Common commands
SHOW TABLES;
SELECT * FROM entries;
DESCRIBE entries;
```

### Connection Details (from PHP)

- **Host**: `db` (inside Docker), `localhost:3307` (from host)
- **User**: `root`
- **Password**: `rootpassword`
- **Database**: `my_app_db`

---

## 🔐 Security Notes

### Development ⚠️

- Passwords are hardcoded (acceptable for local dev)
- CORS allows all origins (acceptable for local dev)
- No HTTPS (not needed for localhost)

### Before Deployment 🚨

- [ ] Use strong passwords
- [ ] Enable HTTPS/SSL
- [ ] Restrict CORS to specific domains
- [ ] Use environment variables for secrets
- [ ] Implement input validation
- [ ] Add authentication/authorization
- [ ] Review PHP code for vulnerabilities
- [ ] Use prepared statements (already done)

---

## 📊 Performance Tips

### Faster Builds

1. Use `.dockerignore` (already configured)
2. Avoid clean rebuild if possible
3. Change code frequently, build rarely
4. Use `docker-compose up` not `--build` when not needed

### Faster Startup

1. Docker caches layers (first build slow, subsequent fast)
2. Health checks wait for actual readiness (not fixed delays)
3. Volumes preserve state (no re-download/reinstall)

### Faster Development

1. Use Vite HMR (hot reload for frontend)
2. Code auto-reloads on save (frontend & backend)
3. Keep containers running during development
4. Avoid frequent `docker-compose down/up` cycles

---

## 🎯 Common Tasks

### Make Code Changes Go Live

```powershell
# Frontend changes auto-appear within ~1 sec
# (Just save the file)

# Backend changes auto-reload on next request
# (Just save the PHP file)

# Database changes - use phpMyAdmin
# OR edit entries_backup.sql + rebuild
```

### Backup Database

```powershell
docker-compose exec -T db mysqldump -uroot -prootpassword my_app_db > backup.sql
```

### Restore Database

```powershell
docker-compose exec -T db mysql -uroot -prootpassword my_app_db < backup.sql
```

### Check Service Health

```powershell
docker-compose ps
# All should show "Up" status
```

### View Real-Time Logs

```powershell
docker-compose logs -f
# Press Ctrl+C to exit
```

### Stop Everything Gracefully

```powershell
docker-compose down
```

### Stop and Delete Everything (Clean Slate)

```powershell
docker-compose down -v
# This deletes ALL containers and volumes!
```

---

## 🌐 Client/Server Communication Flow

```
Browser Request:
  fetch('/api/get_entries.php')
       ↓
Vite Proxy rewrites to:
  http://localhost:8080/get_entries.php
       ↓
Apache/PHP receives request
       ↓
PHP queries MySQL: "SELECT * FROM entries"
       ↓
MySQL returns results
       ↓
PHP creates JSON response
       ↓
Browser receives & displays data
```

---

## 🆘 Emergency Procedures

### If Everything is Broken

```powershell
# Option 1: Clean restart (keeps database)
docker-compose down
docker-compose up --build

# Option 2: Total reset (DELETES EVERYTHING)
docker-compose down -v
docker-compose up --build

# Option 3: Check what's wrong
docker-compose logs
docker-compose ps
docker container ls -a
```

### If Port Already in Use

```powershell
# Find what's using the port
netstat -ano | findstr "3000"

# Option A: Kill the process
# taskkill /PID <PID> /F

# Option B: Use different port
# Edit docker-compose.yml
# Change "3000:5173" to "3001:5173"
# Access: http://localhost:3001
```

### If Docker Won't Start

```powershell
# Check Docker status
docker ps

# If not responding, restart Docker Desktop
# Or restart computer

# Check logs for clues
docker system diagnose
```

---

## 📚 Useful Links

- Docker Docs: https://docs.docker.com/
- Docker Compose: https://docs.docker.com/compose/
- Vite: https://vitejs.dev/
- React: https://react.dev/
- PHP: https://www.php.net/

---

## ✅ First-Time Setup Checklist

- [ ] Docker Desktop installed & running
- [ ] Project directory accessible
- [ ] hosts file configured (optional: add `127.0.0.1  ics.local`)
- [ ] Run `docker-compose up --build` (wait 2-5 min)
- [ ] All containers show "Up" in `docker-compose ps`
- [ ] Open http://localhost:3000 in browser
- [ ] Frontend loads without errors
- [ ] Can log in (or verify login page appears)
- [ ] phpMyAdmin accessible at http://localhost:8086
- [ ] Make code change, verify auto-reload works

**You're ready to develop!** 🚀

---

**Quick Reference Version**: 2.0  
**Last Updated**: March 28, 2026  
**For Full Details**: See DEPLOYMENT_SETUP.md & ENGINEERING_GUIDE.md
