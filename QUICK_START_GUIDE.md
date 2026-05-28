# 🚀 ICS System - Cross-Machine Setup Guide

> **Ensure Perfect Portability**: Complete setup instructions for deploying this project on any PC.

---

## ✅ Prerequisites

Before starting, ensure you have the following installed:

- **Docker Desktop** (v24.0+) - [Download](https://www.docker.com/products/docker-desktop)
- **Docker Compose** (v2.20+) - Usually bundled with Docker Desktop
- **Git** (optional, for cloning) - [Download](https://git-scm.com/)

### Verify Installation

```bash
docker --version
docker compose version
```

Expected output:
```
Docker version 24.0.0 or higher
Docker Compose version 2.20.0 or higher
```

---

## 📋 Quick Start (5 minutes)

### 1. **Copy Project Files**

Copy the entire project folder to your machine:
```bash
# On Windows (PowerShell)
Copy-Item -Path "D:\ICS\v25" -Destination "C:\Projects\ICS" -Recurse
cd C:\Projects\ICS
```

### 2. **Configure Environment**

Create your environment configuration from the template:

```bash
# Copy the template environment file
copy .env.example .env.local

# Edit .env.local with your preferred values (optional)
# Most defaults work out-of-the-box
```

### 3. **Start Docker Services**

```bash
# Build and start all services
docker compose up -d

# Expected output:
# [+] Running 4/4
#  ✔ ics-mysql      Started
#  ✔ ics-phpmyadmin Started
#  ✔ ics-backend    Started
#  ✔ ics-frontend   Started
```

### 4. **Access the Application**

Once all services are healthy (1-2 minutes):

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| **Frontend** | http://localhost:3000 | (Login after setup) |
| **Backend API** | http://localhost:3001 | N/A |
| **phpMyAdmin** | http://localhost:8086 | User: `root` / Pass: `rootpassword` |

### 5. **Wait for Database Initialization**

The database will auto-initialize on first run. Check status:

```bash
# Check if MySQL is healthy
docker compose ps

# View service logs
docker compose logs db  # Database logs
docker compose logs backend  # Backend logs
```

---

## 🔍 Troubleshooting

### **Port Already in Use**

If you get "Address already in use" errors:

```bash
# Option 1: Stop existing containers
docker compose down

# Option 2: Change ports in .env or docker-compose.yml
# Then restart: docker compose up -d
```

### **Database Connection Failed**

```bash
# Check database health
docker compose ps db

# If unhealthy, reset the database
docker compose exec db mysql -u root -prootpassword -e "DROP DATABASE IF EXISTS my_app_db; CREATE DATABASE my_app_db;"
```

### **Frontend Can't Connect to Backend**

```bash
# Check backend connectivity
curl http://localhost:3001/connect.php

# If it fails, check backend logs
docker compose logs backend
```

### **Rebuild Services** (if code changes don't appear)

```bash
# Rebuild and restart
docker compose up -d --build

# Or clean rebuild
docker compose down
docker compose up -d --build
```

---

## 📁 Project Structure

```
ICS/
├── docker-compose.yml          # Docker services configuration
├── .env.local                  # Environment variables template
├── .env.example                # Reference configuration
├── frontend/                   # React + Vite application
│   ├── Dockerfile
│   ├── package.json
│   └── src/
├── backend/                    # PHP + Apache API server
│   ├── Dockerfile
│   ├── composer.json
│   ├── database/
│   │   └── COMPLETE_DATABASE_FIX_20260514.sql  # Init script
│   └── *.php files
└── documentation/              # Setup guides and references
```

---

## 🔐 Security Notes

### **Production Deployment**

Before deploying to production:

1. **Change Default Passwords**
   ```bash
   # Update in .env before first start
   MYSQL_ROOT_PASSWORD=your-secure-password
   ```

2. **Enable HTTPS**
   - Set up SSL certificates
   - Configure reverse proxy (Nginx/Traefik)

3. **Restrict Database Access**
   - Don't expose MySQL (port 3307) to the internet
   - Use strong authentication

4. **Disable phpMyAdmin**
   - Remove `phpmyadmin` service from docker-compose.yml in production

---

## 🛠️ Advanced Configuration

### **Using Custom Email (Optional)**

To enable email notifications:

1. Edit `.env` and set:
   ```
   MAIL_MODE=online
   MAIL_HOST=smtp.gmail.com
   MAIL_PORT=587
   MAIL_USERNAME=your-email@gmail.com
   MAIL_PASSWORD=your-app-password
   ```

2. Generate Gmail App Password:
   - Go to https://myaccount.google.com/apppasswords
   - Select "Mail" and "Windows Computer"
   - Use the generated 16-character password

3. Restart services:
   ```bash
   docker compose down
   docker compose up -d
   ```

### **Using Office365 Email**

Update `.env`:
```
MAIL_HOST=smtp.office365.com
MAIL_USERNAME=your-email@company.com
MAIL_PASSWORD=your-password
```

---

## 📊 Health Checks

Verify all services are running properly:

```bash
# Check all services
docker compose ps

# Expected status: all "Up"

# Check specific service logs (last 50 lines)
docker compose logs --tail=50 frontend
docker compose logs --tail=50 backend
docker compose logs --tail=50 db
```

---

## 🧹 Cleanup

### **Stop Services** (keeps data)
```bash
docker compose stop
```

### **Stop and Remove Containers** (keeps data)
```bash
docker compose down
```

### **Full Reset** (deletes everything)
```bash
docker compose down -v    # -v removes volumes (database)
docker compose up -d      # Rebuild from scratch
```

---

## 📝 Common Commands

```bash
# View all services
docker compose ps

# View logs
docker compose logs -f          # All services (follow)
docker compose logs -f backend  # Single service
docker compose logs --tail=100  # Last 100 lines

# Access MySQL container
docker exec -it ics-mysql bash
docker exec -it ics-mysql mysql -u root -prootpassword my_app_db

# Access backend container
docker exec -it ics-backend bash

# Rebuild specific service
docker compose up -d --build backend

# Stop all services
docker compose down

# Remove all containers and images
docker system prune -a
```

---

## ✨ Success Checklist

- [ ] Docker and Docker Compose installed
- [ ] Project copied to your machine
- [ ] `.env` configured (or using defaults)
- [ ] `docker compose up -d` executed
- [ ] All services showing as "Up" in `docker compose ps`
- [ ] Can access http://localhost:3000
- [ ] Can access http://localhost:3001/connect.php
- [ ] Can login to phpMyAdmin at http://localhost:8086

---

## 📞 Support

If you encounter issues:

1. Check the logs: `docker compose logs backend`
2. Verify Docker Desktop is running
3. Ensure no port conflicts
4. Try a full reset: `docker compose down -v && docker compose up -d --build`

---

**Ready to deploy! 🚀**
