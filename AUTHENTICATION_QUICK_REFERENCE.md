# Authentication Quick Reference Guide

## Frontend Routes Protection

### Login Page - Can Only Access When NOT Logged In
```jsx
// App.jsx - Line ~37
<Route path="/" element={
  <LoginOnlyRoute>
    <LoginForm />
  </LoginOnlyRoute>
} />
```

**Behavior:**
- Logged out user visits `/` → Shows login form ✅
- Logged in user visits `/` → Redirects to `/dashboard` or `/superadmin` ❌

### Dashboard - Can Only Access When Logged In
```jsx
// App.jsx - Line ~49
<Route path="/dashboard" element={
  <ProtectedRoute>
    <Dashboard />
  </ProtectedRoute>
} />
```

**Behavior:**
- Logged in user visits `/dashboard` → Shows dashboard ✅
- Logged out user visits `/dashboard` → Redirects to `/` ❌

---

## Backend Endpoint Protection

### Pattern 1: Any Authenticated User (submit_purchase_request.php)
```php
require_once './config/auth_helper.php';

$user_id = resolveUserId($rawBody); // Gets user from body/session/header
if (!$user_id) {
    jsonError('User not identified', 401);
}
```

### Pattern 2: Specific Role Required (get_all_users.php)
```php
require_once './config/auth_helper.php';

$user_id = requireAuthenticatedUser($conn, $rawBody);  // 401 if not auth
requireRole($conn, $user_id, [1]);  // 403 if not SuperAdmin
```

### Pattern 3: Admin or SuperAdmin (grant_capability.php)
```php
$user_id = requireAuthenticatedUser($conn, $rawBody);
requireRole($conn, $user_id, [1, 2]);  // SuperAdmin (1) or Admin (2)
```

---

## Role IDs

```
1 = SuperAdmin    (Can do everything)
2 = Admin         (Can manage users and capabilities)
3 = Employee      (Limited permissions)
```

---

## User ID Resolution Priority

When authenticating, user ID is resolved from:

**1. Request Body (highest priority)**
```json
{"user_id": 1, ...}
```

**2. Session (if session exists)**
```php
$_SESSION['user_id']
```

**3. HTTP Header**
```
X-User-ID: 1
```

**4. Query Parameter (lowest priority)**
```
?user_id=1
```

---

## Common API Patterns

### Send with Body (Recommended)
```javascript
fetch('/submit_purchase_request.php', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
        user_id: sessionStorage.getItem('user_id'),
        pr_no: 'PR001',
        item_name: 'Item',
        quantity: 1,
        unit: 'pcs',
        unit_cost: 100,
        office: 'Office A',
        division_section: 'Division B'
    })
});
```

### Send with Header (For GET requests)
```javascript
fetch('/get_audit_logs.php', {
    method: 'GET',
    headers: {
        'X-User-ID': sessionStorage.getItem('user_id')
    }
});
```

### Send with Session (After Login)
```javascript
fetch('/get_entries.php', {
    method: 'GET',
    credentials: 'include'  // Include session cookie
});
```

---

## Error Responses

### 401 Unauthorized (Not logged in)
```json
{
    "success": false,
    "error": "Authentication required..."
}
```
**Fix:** Login first or provide user_id

### 403 Forbidden (Wrong role)
```json
{
    "success": false,
    "error": "Insufficient permissions..."
}
```
**Fix:** User needs higher role

### 422 Unprocessable Entity (Missing fields)
```json
{
    "success": false,
    "error": "Missing required fields: pr_no, item_name"
}
```
**Fix:** Include all required fields in request

---

## Logout Workflow

```javascript
// Frontend
const handleLogout = async () => {
    // 1. Call backend logout
    await fetch('/logout.php', {
        method: 'POST',
        credentials: 'include'
    });
    
    // 2. Clear session storage
    sessionStorage.clear();
    
    // 3. Redirect to login
    navigate('/');
    
    // 4. LoginOnlyRoute will show login form
};
```

---

## Testing Authentication

### Test 1: Try SuperAdmin endpoint as Employee
```bash
curl -H "X-User-ID: 3" http://localhost:3001/get_all_users.php
# Returns: 403 Forbidden
```

### Test 2: Try without authentication
```bash
curl http://localhost:3001/get_audit_logs.php
# Returns: 401 Unauthorized
```

### Test 3: Try with valid SuperAdmin
```bash
curl -H "X-User-ID: 1" http://localhost:3001/get_all_users.php
# Returns: User list (assuming user ID 1 is SuperAdmin)
```

---

## Checklist for New Endpoints

When creating a new endpoint, follow this pattern:

- [ ] Include CORS: `require_once './config/cors.php';`
- [ ] Include auth helpers: `require_once './config/auth_helper.php';`
- [ ] Handle OPTIONS: Preflight request handling
- [ ] Authenticate user: `$user_id = requireAuthenticatedUser(...)`
- [ ] Check role if needed: `requireRole($conn, $user_id, [...])`
- [ ] Return JSON: Never return HTML on error
- [ ] Log actions: Use audit logs for sensitive operations
- [ ] Validate input: Check required fields
- [ ] Error codes: 401, 403, 422, 500

---

## Common Mistakes to Avoid

❌ **Don't:**
```php
$user_id = $_GET['user_id'];  // User can fake this
$user_id = $input['user_id'] ?? 1;  // Default to 1 is insecure
```

✅ **Do:**
```php
$user_id = requireAuthenticatedUser($conn, $rawBody);
$user = validateUserExists($conn, $user_id);  // Always verify
```

❌ **Don't:**
```php
if (!$authenticated) {
    echo "Not authenticated";  // Might output HTML
}
```

✅ **Do:**
```php
if (!$authenticated) {
    jsonError('Not authenticated', 401);  // Always JSON
}
```

---

## More Information

See full implementation guide:  
📄 [COMPLETE_AUTHENTICATION_IMPLEMENTATION.md](COMPLETE_AUTHENTICATION_IMPLEMENTATION.md)

---

**Version:** 1.0  
**Last Updated:** May 25, 2026
