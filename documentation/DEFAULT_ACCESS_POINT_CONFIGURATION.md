# 127.0.0.1:3000 Default Access Point - Configuration Verified

## ✅ Configuration Status

The system is now configured to use **127.0.0.1:3000** as the default access point across all environments.

---

## 🔧 Current Configuration

### 1. Frontend Dev Server (vite.config.js)

```javascript
server: {
  port: process.env.VITE_PORT || 3000,
  host: '127.0.0.1',  // ← Uses 127.0.0.1
  hmr: {
    host: '127.0.0.1',  // ← Uses 127.0.0.1 (updated)
    port: 3000,
    protocol: 'http'
  }
}
```

**Access**: `http://127.0.0.1:3000`

### 2. Frontend Production Server (serve.js)

```javascript
const PORT = 3000;
server.listen(PORT, "127.0.0.1", () => {
  console.log(`✓ Frontend served at http://127.0.0.1:${PORT}/`);
});
```

**Access**: `http://127.0.0.1:3000`

### 3. API Base URL (config/api.js)

```javascript
const API_BASE_URL = "http://127.0.0.1:3000";
```

**Endpoint**: Backend API on `http://127.0.0.1:3000`

### 4. Backend API Server (Docker)

```yaml
backend:
  ports:
    - "3000:80" # ← Exposed on 127.0.0.1:3000
```

**Access**: `http://127.0.0.1:3000`

---

## 🚀 How to Access

### Local Development

```bash
# Terminal 1: Start Backend (Docker)
docker-compose up backend

# Terminal 2: Start Frontend (Dev Server)
cd frontend
npm run dev

# Access at:
http://127.0.0.1:3000
```

### Production

```bash
# Build frontend
cd frontend
npm run build

# Serve from port 3000
node serve.js

# Access at:
http://127.0.0.1:3000
```

---

## 📊 Port Summary

| Component           | Port | Host      | Type          |
| ------------------- | ---- | --------- | ------------- |
| Frontend Dev        | 3000 | 127.0.0.1 | React (Vite)  |
| Frontend Production | 3000 | 127.0.0.1 | Static Server |
| Backend API         | 3000 | 127.0.0.1 | PHP/Apache    |
| Database            | 3307 | 127.0.0.1 | MySQL         |
| phpMyAdmin          | 8086 | 127.0.0.1 | Web UI        |

---

## 🔄 Data Flow

```
User Browser
    ↓
http://127.0.0.1:3000  ← Primary Access Point
    ↓
Frontend (React or Static)
    ↓
API Calls to http://127.0.0.1:3000/php-endpoint
    ↓
Backend (Apache/PHP)
    ↓
Database (MySQL)
```

---

## ✨ Key Points

✅ **Consistent Access Point**: All services use `127.0.0.1:3000`
✅ **API Endpoint**: Backend accessible at `127.0.0.1:3000`
✅ **Frontend Dev**: Runs on `127.0.0.1:3000`
✅ **Frontend Production**: Runs on `127.0.0.1:3000`
✅ **No Port Conflicts**: Clear separation in local vs Docker environments

---

## 🛠️ Environment Variables

To override defaults, set these environment variables:

```bash
# Override frontend port
export VITE_PORT=3001

# Override API URL
export VITE_API_URL=http://127.0.0.1:8080
```

---

## 📝 Files Updated

- ✅ `frontend/vite.config.js` - Updated HMR to use 127.0.0.1
- ✅ `frontend/src/config/api.js` - Confirms 127.0.0.1:3000
- ✅ `frontend/serve.js` - Confirms 127.0.0.1:3000
- ✅ `docker-compose.yml` - Backend on port 3000

---

**Default Access Point: http://127.0.0.1:3000 ✅**

_Configuration Verified: April 4, 2026_
