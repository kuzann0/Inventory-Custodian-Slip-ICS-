# ICS System - Complete Setup & Troubleshooting Guide

## Problems Fixed (Step-by-Step)

### **Problem 1: MySQL Connection Password Mismatch**
**Status**: ✅ FIXED

**What was wrong**:
- Docker Compose set `MYSQL_ROOT_PASSWORD: rootpassword`
- But `connect.php` used empty password: `$password = ""`
- This prevented PHP from connecting to MySQL inside Docker

**What I did**:
- Updated `backend/connect.php` password from `""` to `"rootpassword"`
- Updated `backend/submit.php` to initialize database connection with correct password
- Updated `backend/get_entries.php` to initialize database connection with correct password
- All files now use matching credentials: `root / rootpassword`

**Files Modified**:
1. `backend/connect.php` - Fixed password + added JSON output
2. `backend/submit.php` - Added database initialization
3. `backend/get_entries.php` - Added database initialization
4. `backend/login.php` - Added CORS preflight support

---

### **Problem 2: Missing API Response in connect.php**
**Status**: ✅ FIXED

**What was wrong**:
- `connect.php` had incomplete code: called `$stmt->close()` on non-existent variable
- Never returned any JSON output
- Frontend couldn't parse response

**What I did**:
- Added proper JSON response: `{"status": "success", "message": "Connected to database successfully"}`
- Added error handling: `{"status": "error", "message": "..."}`
- Removed buggy `$stmt->close()` call
- Now returns valid JSON on both success and failure

---

### **Problem 3: Missing CORS Preflight Handling**
**Status**: ✅ FIXED

**What was wrong**:
- PHP files had basic CORS headers but missed **OPTIONS method** support
- Modern browsers send `OPTIONS` preflight requests before POST/GET requests
- Without handling this, API calls would fail silently

**What I did**:
- Added `Access-Control-Allow-Methods` header
- Added `Access-Control-Allow-Headers` header
- Added preflight handler:
```php
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
  exit(0);
}
```

**Files Modified**:
- `backend/connect.php`
- `backend/submit.php`
- `backend/get_entries.php`
- `backend/login.php`

---

### **Problem 4: Port Configuration**
**Status**: ✅ VERIFIED (No changes needed)

**Configuration verified**:
- Frontend Vite: port **8082** ✅
- Backend PHP/Apache: port **8080** ✅
- MySQL (internal): 3306 → (external: 3307) ✅
- phpMyAdmin: port **8086** ✅
- API Proxy: `/api` → `http://localhost:8080` ✅

---

## Quick Start Guide

### **Step 1: Install Frontend Dependencies**
```powershell
cd d:\xampp\htdocs\ics_sys\frontend
npm install
```

### **Step 2: Start Docker Services**
```powershell
cd d:\xampp\htdocs\ics_sys

# Make sure Docker Desktop is running, then:
docker-compose up -d
```

**Verify containers started**:
```powershell
docker ps
# Should show: mysql, phpmyadmin, web (Apache/PHP)
```

### **Step 3: Start Frontend Development Server**
```powershell
# In a NEW terminal/tab
cd d:\xampp\htdocs\ics_sys\frontend
npm run dev
```

You should see:
```
VITE v8.0.1  ready in 234 ms

➜  Local:   http://localhost:8082/
➜  press h to show help
```

### **Step 4: Access the Application**

| Service | URL | Purpose |
|---------|-----|---------|
| **Frontend** | http://localhost:8082 | React App (Login → Entry Form) |
| **Backend API** | http://localhost:8080 | PHP APIs (through proxy) |
| **phpMyAdmin** | http://localhost:8086 | Database Management |

### **Step 5: Test the Connection**
1. Open browser console (F12)
2. Go to http://localhost:8082
3. Check console logs:
   - Should see: `"Database response: {status: "success"...}"`
   - If error, check Docker logs: `docker-compose logs web`

---

## Connection Flow Explained

### Frontend → Backend
```
1. Frontend (localhost:8082) makes request
   fetch("/api/connect.php")
   
2. Vite proxy intercepts /api requests
   vite.config.js: /api → http://localhost:8080
   
3. Request becomes: http://localhost:8080/connect.php
   
4. Apache/PHP processes request
   
5. PHP connects to MySQL using "db" hostname
   (inside Docker network, resolves to MySQL container)
   
6. MySQL returns data
   
7. PHP responds with JSON
   CORS headers allow response to reach frontend
   
8. Frontend receives and processes response
```

---

## Docker Network Diagram

```
Docker Bridge Network (internal)
├── Service: db (MySQL)
│   ├── Internal: db:3306
│   └── Port mapping: 3307:3306 (host access)
├── Service: web (PHP/Apache)
│   ├── Internal: web:80
│   ├── Port mapping: 8080:80 (host access)
│   └── Connects to db using hostname "db"
└── Service: phpmyadmin
    ├── Internal: phpmyadmin:80
    └── Port mapping: 8086:80 (host access)
```

---

## Troubleshooting Checklist

### **Issue: localhost:8082 "Unsafe attempt to load URL"**
- Solution: Run `npm run dev` in frontend directory

### **Issue: "ERR_CONNECTION_REFUSED" on API calls**
- Check: `docker ps` - are containers running?
- Fix: `docker-compose up -d`

### **Issue: MySQL Connection Error**
- Check: Database password matches (now fixed to `rootpassword`)
- Check: Container logs: `docker-compose logs db`

### **Issue: CORS errors in console**
- Fixed: All PHP files now have proper CORS headers + preflight support

### **Issue: Can't import database**
- Fix: Import `backend/database/entries_backup.sql` via phpMyAdmin (localhost:8086)

---

## Environment Variables

See `.env.example` for reference. Key variables:
- `MYSQL_ROOT_PASSWORD=rootpassword`
- `MYSQL_DATABASE=my_app_db`
- `FRONTEND_PORT=8082`
- `BACKEND_PORT=8080`

---

## Stopping Services

```powershell
# Stop and remove containers
docker-compose down

# Stop Vite dev server
# Ctrl+C in the npm run dev terminal
```

---

## Summary of Changes Made

| File | Change | Reason |
|------|--------|--------|
| `connect.php` | Added password + JSON response | Fix DB connection & API output |
| `submit.php` | Added DB initialization | Allow form submissions |
| `get_entries.php` | Added DB initialization | Allow data retrieval |
| `login.php` | Added CORS preflight support | Support browser OPTIONS requests |
| `.env.example` | Created | Document configuration |
| `NETWORK_CONFIG.md` | Created | Document architecture |
| `SETUP_GUIDE.md` | Created | Setup instructions (this file) |

All port configurations and routing were already correct - only DB connectivity and CORS needed fixes.
