# ICS System - Network & Port Configuration Guide

## Project Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         LOCAL MACHINE                            │
│                                                                   │
│  ┌──────────────────────┐         ┌──────────────────────────┐  │
│  │   FRONTEND (React)   │         │   DOCKER CONTAINERS      │  │
│  │   http://localhost   │         │                          │  │
│  │   :8082              │         │  ┌──────────────────┐    │  │
│  │                      │         │  │  MySQL DB        │    │  │
│  │  - Vite Dev Server   │         │  │  Port: 3306      │    │  │
│  │  - React Components  │         │  │  (Maps to 3307)  │    │  │
│  │  - API Proxy         │────────→│  └──────────────────┘    │  │
│  │    (/api -> :8080)   │         │                          │  │
│  │                      │         │  ┌──────────────────┐    │  │
│  └──────────────────────┘         │  │  PHP/Apache Web  │    │  │
│                                   │  │  Port: 80        │    │  │
│                                   │  │  (Maps to 8080)  │    │  │
│                                   │  │                  │    │  │
│                                   │  │  - connect.php   │    │  │
│                                   │  │  - submit.php    │    │  │
│                                   │  │  - get_entries   │    │  │
│                                   │  │  - login.php     │    │  │
│                                   │  └──────────────────┘    │  │
│  ┌──────────────────────┐         │                          │  │
│  │   phpMyAdmin         │         │  ┌──────────────────┐    │  │
│  │   http://localhost   │         │  │  Docker Network  │    │  │
│  │   :8086              │         │  │  (bridge)        │    │  │
│  │                      │────────→│  └──────────────────┘    │  │
│  └──────────────────────┘         │                          │  │
│                                   └──────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Network Details

### Docker Network Setup
- **Network Type**: Default bridge network (created automatically by docker-compose)
- **Service Names**: Services communicate by name (db, web, phpmyadmin)
- **Internal Communication**:
  - PHP/Apache service connects to MySQL using hostname: `db:3306`
  - Frontend connects to backend via proxy: `http://localhost:8080`

### Port Mapping

| Service | Port Inside | Port Outside | Access URL |
|---------|-------------|--------------|-----------|
| MySQL | 3306 | 3307 | localhost:3307 |
| PHP/Apache | 80 | 8080 | localhost:8080 |
| phpMyAdmin | 80 | 8086 | localhost:8086 |
| Vite Dev | N/A | 8082 | localhost:8082 |

### CORS (Cross-Origin Resource Sharing)
All PHP files include:
```php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
```
This allows the frontend (port 8082) to make requests to backend (port 8080).

## API Endpoints

Frontend routes:
- `GET /` → Login page
- `GET /entry` → Entry form + view entries

Backend API routes (proxied through /api prefix):
- `POST /api/connect.php` → Test database connection
- `POST /api/login.php` → Authenticate user
- `POST /api/submit.php` → Add new entry
- `GET /api/get_entries.php` → Fetch all entries

## Database

- **Host**: db (inside docker), localhost:3307 (from host)
- **Root User**: root
- **Root Password**: rootpassword
- **Database**: my_app_db
- **Tables**: entries (auto-created from entries_backup.sql)

## No Changes Made to These Core Files
- docker-compose.yml (port mappings correct)
- Dockerfile (PHP/Apache setup correct)
- vite.config.js (proxy and port configured correctly)
