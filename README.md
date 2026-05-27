# 🏢 ICS - Inventory Custodian System

**Fully Containerized | Cross-Platform | Production-Ready**

> A comprehensive inventory management system built with React, PHP, and MySQL. Deploy anywhere with Docker.

---

## 🎯 Quick Start

### Prerequisites
- Docker Desktop v24.0+
- 4GB RAM minimum
- 2GB disk space

### Launch in 3 Steps

```bash
# 1. Navigate to project
cd ICS

# 2. Start all services
docker compose up -d

# 3. Open browser
# Frontend:    http://localhost:3000
# API:         http://localhost:3001
# Database UI: http://localhost:8086
```

**✅ System ready in ~2 minutes!**

---

## 📚 Documentation

- **[QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md)** ← **Start here for full setup**
- [Backend API Reference](./documentation/)
- [Frontend Architecture](./frontend/README.md)
- [Database Schema](./backend/database/)

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    DOCKER NETWORK                            │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Frontend (Vite)      Backend (PHP)      Database (MySQL)   │
│  :3000                :3001              :3307              │
│  ↕                    ↕                  ↕                   │
│  React+Router    Apache+Composer    MySQL 5.7              │
│                                                               │
│                  phpMyAdmin (Admin)                          │
│                       :8086                                  │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎨 Features

- ✅ **Modern Frontend** - React 18 + Vite + React Router
- ✅ **Robust Backend** - PHP 7.4 + Apache + MySQL
- ✅ **Database Management** - phpMyAdmin included
- ✅ **Auto-Init Database** - Automatic on first run
- ✅ **Cross-Platform** - Works on Windows, Mac, Linux
- ✅ **Production Ready** - Environment-based configuration
- ✅ **Email Integration** - Optional Gmail/Office365 support

---

## 📋 Services

| Service | Port | Purpose | Access |
|---------|------|---------|--------|
| **Frontend** | 3000 | React Application | http://localhost:3000 |
| **Backend API** | 3001 | PHP REST API | http://localhost:3001 |
| **Database** | 3307 | MySQL Server | Via docker exec |
| **phpMyAdmin** | 8086 | DB Management | http://localhost:8086 |

---

## 🔧 Configuration

### Default Setup (Works Out-of-the-Box)

```env
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_DATABASE=my_app_db
MAIL_MODE=offline
```

### Custom Configuration

1. Copy `.env.local` → `.env`
2. Edit values as needed
3. Restart: `docker compose down && docker compose up -d`

### Enable Email (Optional)

Edit `.env`:
```env
MAIL_MODE=online
MAIL_HOST=smtp.gmail.com
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
```

---

## 🚀 Common Commands

```bash
# Start services
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose stop

# Full restart
docker compose restart

# Clean reset (removes all data)
docker compose down -v && docker compose up -d --build

# Access MySQL
docker exec -it ics-mysql mysql -u root -prootpassword my_app_db

# Rebuild specific service
docker compose up -d --build backend
```

---

## 📁 Project Structure

```
ICS/
├── docker-compose.yml              # Service definitions
├── .env.local                       # Config template
├── QUICK_START_GUIDE.md            # Detailed setup instructions
├── frontend/                       # React application
│   ├── Dockerfile
│   ├── package.json
│   └── src/
├── backend/                        # PHP API server
│   ├── Dockerfile
│   ├── composer.json
│   ├── database/
│   │   └── COMPLETE_DATABASE_FIX_20260514.sql
│   └── *.php files
└── documentation/                  # Guides and references
```

---

## 🐛 Troubleshooting

### Services won't start?
```bash
# Check Docker Desktop is running, then:
docker compose logs backend
```

### Port conflict?
```bash
# Edit .env and change ports, then:
docker compose up -d
```

### Database not initializing?
```bash
# Reset database
docker compose down -v
docker compose up -d --build
```

---

## 📊 System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 4GB | 8GB |
| CPU | 2 cores | 4+ cores |
| Disk | 2GB | 10GB |
| Docker | v24.0 | Latest |

---

## 🔐 Security

- ✅ CORS protection
- ✅ Session authentication
- ✅ Password hashing (bcrypt)
- ✅ Input validation
- ⚠️ Change default password for production
- ⚠️ Use strong credentials for email

---

## 📞 Support

**Stuck?** Check these first:

1. Read [QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md)
2. View logs: `docker compose logs -f`
3. Verify Docker: `docker ps`
4. Reset: `docker compose down -v && docker compose up -d --build`

---

## 📄 License

ISC License - See LICENSE file for details

---

**🎉 Ready to go! Start with the [QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md)**
