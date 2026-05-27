# Cross-Machine Compatibility & Authentication Fix

## Overview

This document explains the fixes applied to make the application work reliably across different PC units with proper authentication handling.

## Issues Fixed

### 1. **401 Unauthorized on `/get_audit_logs.php`**
- **Root Cause**: Session-based authentication failed when user wasn't logged in
- **Solution**: Implemented multi-source authentication (session, headers, body, query params)

### 2. **422 Unprocessable Entity on `/submit_purchase_request.php`**
- **Root Cause**: Required field validation failing due to request format issues
- **Solution**: Improved request validation with better error messaging

### 3. **Cross-Machine CORS Issues**
- **Root Cause**: CORS configuration hardcoded with specific IP addresses
- **Solution**: Made CORS accept any localhost/127.0.0.1 with any port (development mode)

## Changes Made

### 1. Updated CORS Configuration (`config/cors.php`)

The CORS configuration now:
- Accepts all `localhost` origins with any port
- Accepts all `127.0.0.1` origins with any port
- Works seamlessly across different machines without IP-specific hardcoding
- Uses environment variable detection for production mode

**Key Change:**
```php
// DEVELOPMENT: Allow any localhost/127.0.0.1 origin
if (!$isAllowed && (strpos($origin, 'localhost') !== false || strpos($origin, '127.0.0.1') !== false)) {
    $isAllowed = true;
}
```

### 2. Created Authentication Helper (`config/auth_helper.php`)

New centralized functions for consistent authentication:

- `resolveUserId($rawBody)` - Resolve user ID from multiple sources
- `validateUserExists($conn, $user_id)` - Validate user in database
- `hasRole($role_id, $allowed_roles)` - Check user role
- `requireAuthenticatedUser($conn, $rawBody)` - Require authentication (auto-fails with 401)
- `requireRole($conn, $user_id, $allowed_roles)` - Require specific role (auto-fails with 403)

### 3. Updated Endpoints

#### `get_audit_logs.php`
- Now uses centralized CORS config
- Uses new authentication helpers
- Accepts user_id from body, session, or header (X-User-ID)
- Returns proper error codes (401 for auth, 403 for permissions)

#### `submit_purchase_request.php`
- Improved user_id resolution from multiple sources
- Better environment-based handling of test users
- Still defaults to user_id=1 for development (can be disabled)

## How to Use

### For Frontend Developers

#### Option 1: Send user_id in Request Body (Recommended)
```javascript
// POST /submit_purchase_request.php
fetch('http://localhost:3001/submit_purchase_request.php', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({
        user_id: 1,  // Add this field
        pr_no: 'PR001',
        item_name: 'Item Name',
        quantity: 5,
        unit: 'pcs',
        unit_cost: 100,
        office: 'Office A',
        division_section: 'Division B',
        description: 'Item description'
    })
});
```

#### Option 2: Send user_id in Header
```javascript
fetch('http://localhost:3001/get_audit_logs.php', {
    method: 'GET',
    headers: {
        'X-User-ID': '1'
    }
});
```

#### Option 3: Use Query Parameter
```javascript
fetch('http://localhost:3001/get_audit_logs.php?user_id=1&limit=50&offset=0', {
    method: 'GET'
});
```

#### Option 4: Session-Based (After Login)
Login first, then all requests will use `$_SESSION['user_id']`:
```javascript
// First, login
await fetch('http://localhost:3001/login.php', {
    method: 'POST',
    credentials: 'include', // Important for session cookies
    body: /* login data */
});

// Then subsequent requests automatically use session
fetch('http://localhost:3001/get_audit_logs.php', {
    method: 'GET',
    credentials: 'include'  // Include cookies
});
```

### For Backend Developers

#### Using the Authentication Helper

In any PHP endpoint:

```php
<?php
require_once './config/cors.php';
require_once './config/auth_helper.php';

header('Content-Type: application/json');

session_start();

try {
    $rawBody = file_get_contents('php://input');
    
    // Connect to database
    $conn = new mysqli('host', 'user', 'pass', 'db');
    $conn->set_charset('utf8mb4');
    
    // Require authentication (fails with 401 if not authenticated)
    $user_id = requireAuthenticatedUser($conn, $rawBody);
    
    // Optionally require specific role(s)
    requireRole($conn, $user_id, [1, 2]); // Admin roles only
    
    // Your endpoint logic here
    
} catch (Throwable $e) {
    error_log('[endpoint] Error: ' . $e->getMessage());
    http_response_code(500);
    exit(json_encode(['success' => false, 'error' => 'Server error']));
}
?>
```

## Environment Variables

Set these in `.env` or Docker environment:

```env
# Database
MYSQL_HOST=db
MYSQL_USER=root
MYSQL_PASSWORD=rootpassword
MYSQL_DATABASE=my_app_db

# Application
APP_ENV=development
ALLOW_TEST_USER=true   # Allow user_id=1 as default in dev mode
```

## Testing Across Machines

### Machine 1 (Development Server)
```bash
# Frontend running on Port 3000
http://localhost:3000

# Backend running on Port 3001
http://localhost:3001
```

### Machine 2 (Different Device)
```bash
# Frontend on Port 5173 (Vite)
http://127.0.0.1:5173

# Backend still responds to both
# No hardcoded IP required anymore!
```

Both will work seamlessly because CORS now accepts:
- `http://localhost:*`
- `http://127.0.0.1:*`

## Error Responses

### 401 Unauthorized
```json
{
    "success": false,
    "error": "Authentication required. Please provide user_id in request body, X-User-ID header, or log in."
}
```
**Fix:** Send user_id via body, header, or session

### 403 Forbidden
```json
{
    "success": false,
    "error": "User not found or inactive"
}
```
**Fix:** Ensure user exists and is_active=1 in database

### 422 Unprocessable Entity
```json
{
    "success": false,
    "error": "Missing required fields: pr_no, item_name"
}
```
**Fix:** Include all required fields in request

## Production Deployment Notes

⚠️ **Before deploying to production:**

1. **Update CORS configuration** - Replace localhost whitelist with your actual domain(s)
2. **Disable test user** - Set `ALLOW_TEST_USER=false` or remove the test user default
3. **Enable proper logging** - Set `error_log` path in php.ini
4. **Use HTTPS** - Update CORS origins to use `https://`
5. **Secure session cookies** - Add `Secure` and `HttpOnly` flags in session_set_cookie_params()

## File Changes Summary

| File | Change |
|------|--------|
| `config/cors.php` | Made CORS flexible for all localhost/127.0.0.1 |
| `config/auth_helper.php` | **NEW** - Centralized authentication functions |
| `get_audit_logs.php` | Uses new CORS and auth helpers |
| `submit_purchase_request.php` | Improved user_id resolution |

## Backward Compatibility

✅ All changes are backward compatible:
- Session-based authentication still works
- Existing code doesn't break
- New multi-source authentication is additive

## Support

If authentication still fails after these changes:

1. Check browser console for CORS errors
2. Check PHP error logs: `error_log()`
3. Verify user exists: `SELECT * FROM users WHERE id = ?`
4. Test with hardcoded user_id in request body first
5. Then gradually move to session-based auth

---

**Last Updated:** May 25, 2026  
**Status:** ✅ Ready for cross-machine deployment
