# Comprehensive Codebase Audit Report

**V8 ICS System - UI/UX**
**Date:** April 6, 2026

---

## Executive Summary

The codebase contains **42 identified issues** across frontend, backend, configuration, and deployment layers. **9 CRITICAL** issues require immediate attention before production deployment. Most issues are related to security, configuration, and code quality.

---

## CRITICAL ISSUES (9)

### 1. **Hardcoded Database Credentials in Production Code**

- **Severity:** CRITICAL
- **Files Affected:**
  - `backend/approve_purchase_request.php` (line 23)
  - `backend/complete_process.php` (line 30)
  - `backend/download_document.php` (line 26)
  - `backend/get_purchase_requests.php` (line 5)
  - `backend/submit_purchase_request.php` (line 20)
  - `backend/submit_delivery_notes.php`
  - `backend/submit_inspection.php`
  - `backend/submit.php`
  - `backend/connect.php` (line 15-17)
- **Issue:** Database credentials hardcoded as `'db', 'root', 'rootpassword'`
- **Impact:** Credentials exposed in source code, version control, and backups
- **Fix:** Use environment variables consistently across ALL endpoints like:
  ```php
  $servername = getenv('MYSQL_HOST') ?? 'db';
  $username = getenv('MYSQL_USER') ?? 'root';
  ```

### 2. **Admin Bypass Authentication Vulnerability**

- **Severity:** CRITICAL
- **File:** `backend/admin_bypass.php`
- **Issue:** Endpoint allows authentication bypass with an admin key without proper security controls
- **Problems:**
  - No rate limiting on bypass attempts
  - Weak validation of bypass key format
  - Allows direct session creation without proper audit trail
  - Should only be used in development/testing
- **Fix:**
  - Remove this endpoint in production or restrict to localhost only
  - Add rate limiting and logging
  - Validate admin_key properly
  - Implement proper multi-factor authentication instead

### 3. **Overly Permissive CORS Configuration**

- **Severity:** CRITICAL
- **Files Affected:** All PHP endpoint files
- **Issue:**
  ```php
  header('Access-Control-Allow-Origin: ' . $_SERVER['HTTP_ORIGIN'] ?? '*');
  header('Access-Control-Allow-Credentials: true');
  ```

  - Allows requests from ANY origin with credentials
  - Enables cross-origin attacks
- **Impact:** CSRF, XSS from any website
- **Fix:** Whitelist specific origins:
  ```php
  $allowed_origins = ['http://localhost:5173', 'https://app.ics-system.com'];
  $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
  if (in_array($origin, $allowed_origins)) {
      header('Access-Control-Allow-Origin: ' . $origin);
  }
  ```

### 4. **Hardcoded Frontend API URL**

- **Severity:** CRITICAL
- **File:** `frontend/src/config/api.js` (line 6)
- **Issue:**
  ```javascript
  const API_BASE_URL = "http://127.0.0.1:3001";
  ```

  - Hardcoded to localhost and HTTP
  - Will fail in production, staging, any non-localhost environment
  - Not configurable via environment variables
- **Fix:** Use environment variable:
  ```javascript
  const API_BASE_URL = import.meta.env.VITE_API_URL || "http://localhost:3001";
  ```
  And add to `.env.example`:
  ```
  VITE_API_URL=http://localhost:3001
  ```

### 5. **Sensitive Data in Session Storage (XSS Vulnerability)**

- **Severity:** CRITICAL
- **File:** `frontend/src/*.jsx` (multiple components)
- **Issue:** Storing sensitive information in sessionStorage:
  ```javascript
  sessionStorage.setItem('session_token', loginData.token);
  sessionStorage.setItem('user_id', loginData.user.id);
  sessionStorage.setItem('role_id', loginData.user.role_id);
  sessionStorage.setItem('permissions', JSON.stringify(...));
  ```
- **Problem:** sessionStorage is accessible to JavaScript (vulnerable to XSS)
- **Fix:** Use httpOnly, secure cookies instead:
  ```javascript
  // Backend sets: Set-Cookie: session_token=...; HttpOnly; Secure; SameSite=Strict
  // Frontend reads from memory or encrypted IndexedDB
  ```

### 6. **Missing Environment Configuration for Database**

- **Severity:** CRITICAL
- **File:** `docker-compose.yml`, `.env` (MISSING)
- **Issue:**
  - Docker-compose hardcodes credentials and database names
  - No `.env` file (only `.env.example`)
  - Credentials visible in docker-compose.yml
  - Same credentials in all environments
- **Impact:** Cannot deploy to different environments, credentials in repo
- **Fix:**
  - Create `.env` file from `.env.example`
  - Reference .env in docker-compose: `${MYSQL_ROOT_PASSWORD}`
  - Never commit `.env` to version control

### 7. **Missing Logout Endpoint**

- **Severity:** CRITICAL
- **Issue:** No logout/session termination endpoint
- **Files:** `backend/src/AuthService.php` has logout() method (line 266) but no exposed PHP endpoint
  - Frontend has no logout API call
  - Tokens never invalidated
  - Sessions remain valid indefinitely
- **Impact:** Sessions linger, security risk
- **Fix:** Create `backend/logout.php` endpoint:
  ```php
  POST /logout.php
  - Accept token in Authorization header
  - Mark token as revoked in database
  - Destroy session
  ```

### 8. **Inconsistent Database Connection Error Handling**

- **Severity:** CRITICAL
- **Files:** Multiple backend files
- **Issue:**
  - Some files suppress errors with `@new mysqli()`
  - Some throw exceptions, some json_encode errors
  - connect.php exposes error messages to client
  - No consistent logging
- **Fix:** Implement centralized error handler:
  ```php
  // Create: backend/config/Database.php
  class Database {
      public static function connect() {
          $conn = new mysqli(...);
          if ($conn->connect_error) {
              error_log("DB Connection Error: " . $conn->connect_error);
              die(json_encode(['error' => 'Database unavailable']));
          }
          return $conn;
      }
  }
  ```

### 9. **No Frontend Authentication Error Handling**

- **Severity:** CRITICAL
- **File:** `frontend/src/LoginForm.jsx` (line 20-65)
- **Issue:**
  - No timeout handling for login requests
  - No retry logic
  - Network errors just show "Network error"
  - No protection against brute force
- **Impact:** UX issues, backend can be DOS attacked with login attempts
- **Fix:** Implement:
  - Request timeout (5-10 seconds)
  - Exponential backoff retry
  - Rate limiting on frontend (localStorage counter)
  - Account lockout feedback from backend

---

## HIGH SEVERITY ISSUES (11)

### 10. **Inconsistent Input Validation**

- **Severity:** HIGH
- **Files:** `backend/get_process_status.php`, `backend/get_audit_logs.php`, etc.
- **Issue:**
  ```php
  $status = isset($_GET['status']) ? $_GET['status'] : null;  // No sanitization
  if ($status) {
      $sql .= " AND status = ?";  // Good - prepared statement
      $params[] = $status;
  }
  ```

  - Some uses proper prepared statements ✓
  - But others not validating allowed values
  - No whitelist for status enum values
- **Fix:**
  ```php
  $allowed_statuses = ['draft', 'pending', 'approved', 'completed'];
  $status = $_GET['status'] ?? null;
  if ($status && !in_array($status, $allowed_statuses)) {
      throw new Exception('Invalid status');
  }
  ```

### 11. **SQL Injection in Conditional Queries**

- **Severity:** HIGH
- **Files:** `backend/get_audit_logs.php` (line 73-112)
- **Issue:** Query building with user input:
  ```php
  $countQuery = "SELECT COUNT(*) as total FROM capability_audit_log";
  // ... then adds WHERE clauses based on user input
  ```

  - Prepared statements used ✓ but query building is manual
  - Verify ALL parameters are properly bound
- **Fix:** Review and ensure all conditionals use prepared statements with bind_param

### 12. **Console Logs in Production Code**

- **Severity:** HIGH
- **Files:**
  - `frontend/src/Connect.jsx` (line 13, 15)
  - `frontend/src/LoginForm.jsx` (line 56, 59, 65, 98)
  - `frontend/src/DocumentManagement.jsx` (line 31, 82, 102)
  - And 10+ other components
- **Issue:** Multiple console.log() and console.error() calls expose sensitive info
- **Impact:** Debugging info visible to users, potential info leakage
- **Fix:**
  - Remove all console logs or wrap in debug flag:
    ```javascript
    const isDev = import.meta.env.DEV;
    if (isDev) console.log(...);
    ```

### 13. **Missing Request Timeout Handlers**

- **Severity:** HIGH
- **Files:** All fetch() calls in frontend components
- **Issue:** fetch() calls have no timeout:
  ```javascript
  const response = await fetch(`${API_BASE_URL}/login.php`, {
      method: "POST",
      credentials: 'include',
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({...})
  });
  ```
- **Impact:** Requests hang indefinitely, freezing UI
- **Fix:**
  ```javascript
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 10000);
  try {
      const response = await fetch(url, { signal: controller.signal, ...});
  } finally {
      clearTimeout(timeout);
  }
  ```

### 14. **No Token Refresh/Expiration Logic**

- **Severity:** HIGH
- **Files:** `frontend/src/*.jsx`, `backend/src/AuthService.php`
- **Issue:**
  - No token expiration time set
  - No refresh token mechanism
  - Sessions become invalid without user action
- **Impact:** Poor UX, stale sessions
- **Fix:**
  - Add token expiration (30 min - 1 day)
  - Implement refresh token endpoint
  - Redirect to login on 401

### 15. **No Error Boundary Component**

- **Severity:** HIGH
- **Files:** `frontend/src/App.jsx`
- **Issue:** No React Error Boundary component
  - App crashes silently on component errors
  - No fallback UI
  - Users see blank page
- **Fix:** Implement Error Boundary:
  ```javascript
  class ErrorBoundary extends React.Component {
    componentDidCatch(error, errorInfo) {
      console.error(error, errorInfo);
    }
    render() {
      if (this.state.hasError) {
        return <h1>Something went wrong. Please refresh.</h1>;
      }
      return this.props.children;
    }
  }
  ```

### 16. **Missing Authentication on Test Endpoints**

- **Severity:** HIGH
- **File:** `backend/connect.php`
- **Issue:** `/connect.php` endpoint has no authentication
  ```php
  // Just tests DB connection, no role/permission checks
  echo json_encode(["status" => "success", ...]);
  ```
- **Problem:** Leaks info that DB is up, reveals system status to unauthenticated users
- **Fix:** Remove from production or add authentication:
  ```php
  if (empty($_SERVER['HTTP_AUTHORIZATION'])) {
      http_response_code(401);
      exit(json_encode(['error' => 'Unauthorized']));
  }
  ```

### 17. **Inconsistent API Response Format**

- **Severity:** HIGH
- **Files:** All backend PHP files
- **Issue:** Different response formats:
  - Some use: `{status: 'error', message: '...'}`
  - Some use: `{success: false, error: '...'}`
  - Some use: `{status: 'success', message: '...'}`
  - Some use: `{success: true, data: {...}}`
- **Impact:** Frontend can't reliably parse responses
- **Fix:** Standardize to one format:
  ```javascript
  {
      success: boolean,
      status: 'success|'error|'validation_error',
      data: {...} | null,
      message: string,
      errors: {...}  // For validation errors
  }
  ```

### 18. **No File Permissions/Validation for Uploads**

- **Severity:** HIGH
- **Files:** `backend/upload_document.php`, `backend/download_document.php`
- **Issue:**
  - No file type validation
  - No file size limits
  - No virus scanning
  - Files uploaded to web root (potentially executable)
- **Fix:**
  - Add MIME type checking
  - Limit file size (5-10MB)
  - Store uploads outside web root
  - Implement virus scanning

### 19. **No Data Validation in Super Admin Operations**

- **Severity:** HIGH
- **Files:** `backend/create_admin.php`, `backend/grant_capability.php`
- **Issue:**
  - Admin bypass can create accounts/grant permissions
  - No verification of admin_key strength
  - Permissions stored as JSON without schema validation
- **Fix:**
  - Limit admin_bypass to localhost only
  - Require multi-factor authentication for sensitive ops
  - Validate permission keys against whitelist

### 20. **No Pagination/Limit on List Endpoints**

- **Severity:** HIGH
- **Files:**
  - `backend/get_all_users.php`
  - `backend/get_entries.php`
  - `backend/get_audit_logs.php`
- **Issue:** Could return thousands of records
  - No LIMIT clause
  - No offset/pagination parameters
- **Impact:** DOS vulnerability, slow queries, memory issues
- **Fix:** Add pagination:
  ```php
  $limit = min((int)($_GET['limit'] ?? 20), 100);
  $offset = (int)($_GET['offset'] ?? 0);
  $sql .= " LIMIT ? OFFSET ?";
  $stmt->bind_param('ii', $limit, $offset);
  ```

---

## MEDIUM SEVERITY ISSUES (13)

### 21. **Dead Code - Navbar_old.jsx**

- **File:** `frontend/src/Navbar_old.jsx`
- **Issue:** Old navigation component not used, not removed
- **Fix:** Remove from repo or use if needed

### 22. **React Strict Mode Issues**

- **File:** `frontend/src/main.jsx`
- **Issue:** Using `<StrictMode>` which causes double-rendering in development
  - May cause unexpected behavior
  - useEffect() effects run twice
- **Note:** This is OK for development but verify effects are idempotent

### 23. **No PropTypes or TypeScript**

- **Severity:** MEDIUM
- **Files:** All frontend components
- **Issue:** No prop validation
  - No type safety
  - Runtime errors possible
  - Hard to debug
- **Fix Option 1:** Add PropTypes:
  ```javascript
  import PropTypes from "prop-types";
  Component.propTypes = { prop: PropTypes.string.isRequired };
  ```
- **Fix Option 2:** Migrate to TypeScript

### 24. **Vite HMR Configuration**

- **File:** `frontend/vite.config.js` (line 23-26)
- **Issue:**
  ```javascript
  hmr: {
      host: 'localhost',  // Hardcoded
      port: 5173,
      protocol: 'ws'
  }
  ```

  - Won't work on different networks
  - Won't work with Docker from host
- **Fix:**
  ```javascript
  hmr: {
      host: process.env.VITE_HMR_HOST || 'localhost',
      port: parseInt(process.env.VITE_HMR_PORT || '5173'),
      protocol: process.env.VITE_HMR_PROTOCOL || 'ws'
  }
  ```

### 25. **No Frontend .env.example**

- **Severity:** MEDIUM
- **Issue:** No documentation of frontend environment variables
  - Frontend developers won't know what to set
  - Only backend has .env.example
- **Fix:** Create `frontend/.env.example`:
  ```
  VITE_API_URL=http://localhost:3001
  VITE_HMR_HOST=localhost
  VITE_HMR_PORT=5173
  VITE_HMR_PROTOCOL=ws
  ```

### 26. **Database Schema Version Management Missing**

- **Severity:** MEDIUM
- **Issue:**
  - Docker uses `entries_backup.sql` but `complete_database.sql` also exists
  - Unclear which is current
  - No migration system
  - No version tracking
- **Fix:** Implement migration system:
  - Create `/migrations/` folder
  - Each migration with up/down SQL
  - Track in `migrations_applied` table

### 27. **Inconsistent Data Types in Responses**

- **Severity:** MEDIUM
- **Example:** `backend/create_user.php`
  ```php
  'user_id' => $newUserId,  // Integer
  'created_at' => date('Y-m-d H:i:s')  // String
  ```

  - No consistent timestamp format
  - No ISO 8601 dates
- **Fix:** Always use ISO 8601 for dates:
  ```php
  'created_at' => (new DateTime())->format(DateTime::ISO8601)
  ```

### 28. **No Loading Indicators**

- **Severity:** MEDIUM
- **Files:** Multiple components
- **Issue:** Basic loading states but no visual indicators
  - No spinner/skeleton
  - Poor UX
- **Fix:** Add loading UI component:
  ```javascript
  {
    isLoading && <Spinner />;
  }
  {
    !isLoading && <Content />;
  }
  ```

### 29. **Missing Environment Variables in Docker-Compose**

- **Severity:** MEDIUM
- **File:** `docker-compose.yml`
- **Issue:**
  - No `.env` file reference in docker-compose
  - Credentials hardcoded in YAML
  - Frontend env vars not set
- **Fix:**
  ```yaml
  services:
    backend:
      environment:
        MYSQL_HOST: ${MYSQL_HOST:-db}
        MYSQL_USER: ${MYSQL_USER:-root}
        # ... more env vars from .env
  ```

### 30. **No Database Connection Pooling**

- **Severity:** MEDIUM
- **Issue:** Each request creates new mysqli connection
  - Not closed properly in all paths
  - No connection reuse
  - Could exhaust MySQL connections
- **Fix:** Implement connection pool or PDO with persistent connections

### 31. **No Audit Log for Sensitive Operations**

- **Severity:** MEDIUM (partially implemented)
- **Issue:**
  - User creation logs to capability_audit_log
  - But purchase request approvals not logged
  - Data deletion not fully logged
- **Fix:** Add audit logging to:
  - Purchase request status changes
  - Document uploads
  - User deletions

### 32. **Session Storage Vulnerable to XSS**

- **Severity:** MEDIUM
- **Issue:** Session data in storage can be wiped by XSS
  - No CSRF tokens
  - No CSP headers
- **Fix:**
  - Implement Content Security Policy
  - Add SameSite cookies
  - Escape all output

### 33. **No Input Sanitization for SQL**

- **Severity:** MEDIUM
- **Note:** Prepared statements used ✓
- **Still:** Some string comparisons not using prepared statements
  - Example: `status = 'draft'` hardcoded is OK
  - But user-provided status should be validated against whitelist

---

## LOW SEVERITY ISSUES (8)

### 34. **Missing favicon.svg**

- **File:** `frontend/index.html` (line 4)
- **Issue:** References `/favicon.svg` which may not exist
- **Fix:** Add favicon or remove reference

### 35. **API Port Conflicts in Documentation**

- **Issue:** Docker-compose shows different ports in different places
  - README might say different port than docker-compose
  - Could confuse developers
- **Fix:** Document all ports clearly in README

### 36. **No ESLint Configuration for Security**

- **File:** `frontend/eslint.config.js`
- **Issue:** Missing security-related rules (no-eval, no-implied-eval, etc.)
- **Fix:** Add eslint-plugin-security

### 37. **No Docker Layer Caching Optimization**

- **File:** `backend/Dockerfile`
- **Issue:**
  ```dockerfile
  COPY ./ /var/www/html/  # Before composer install
  RUN if [ -f composer.json ]; then composer install; fi
  ```

  - If any file changes, composer runs again
  - Should copy composer.json first
- **Fix:**
  ```dockerfile
  COPY composer.json composer.lock /var/www/html/
  RUN composer install
  COPY ./ /var/www/html/
  ```

### 38. **No Health Check Timeout**

- **File:** `backend/Dockerfile` (line 31-32)
- **Issue:** Health check might take too long
  ```dockerfile
  HEALTHCHECK --interval=10s --timeout=5s --retries=3
  ```

  - curl to /connect.php might hang
- **Fix:** Set appropriate timeout or add max_execution_time

### 39. **Missing .htaccess in Frontend**

- **Issue:** `.htaccess` in backend for routing but not backend/.htaccess found
- **Note:** Check if `000-default.conf` serves same purpose ✓

### 40. **No API Documentation**

- **Issue:** No OpenAPI/Swagger documentation
  - 30+ endpoints undocumented
  - Hard for frontend to know correct format
- **Fix:** Generate API docs:
  ```bash
  openapi-generator or swagger-ui
  ```

### 41. **Incomplete Environment Variable Documentation**

- **File:** `.env.example`
- **Issue:** Missing variables:
  - `MYSQL_HOST` (assumed from code)
  - `MYSQL_USER`
  - `MYSQL_PASSWORD`
  - `MYSQL_DATABASE`
  - `MYSQL_PORT`
- **Fix:** Add all variables to .env.example

### 42. **No Logging Framework**

- **Issue:** Using error_log() to file
  - No log rotation
  - No structured logging
  - No log levels
- **Fix:** Use Monolog or similar:
  ```php
  use Monolog\Logger;
  $log = new Logger('ICS');
  $log->info('User logged in', ['user_id' => 123]);
  ```

---

## SECURITY VULNERABILITIES SUMMARY

| Type          | Count                          | Status     |
| ------------- | ------------------------------ | ---------- |
| SQL Injection | Covered by prepared statements | ✓ GOOD     |
| CSRF          | No CSRF tokens                 | ⚠ MEDIUM   |
| XSS           | Session storage accessible     | ⚠ HIGH     |
| Auth Bypass   | admin_bypass.php endpoint      | ⚠ CRITICAL |
| CORS          | Overly permissive              | ⚠ CRITICAL |
| Data Leakage  | Debug logs, error messages     | ⚠ HIGH     |
| File Upload   | No validation                  | ⚠ HIGH     |
| Brute Force   | No rate limiting               | ⚠ MEDIUM   |

---

## DEPLOYMENT READINESS CHECKLIST

- [ ] Remove hardcoded credentials
- [ ] Enable HTTPS/TLS
- [ ] Implement proper CORS whitelist
- [ ] Set up environment variables
- [ ] Remove debug logging
- [ ] Implement API rate limiting
- [ ] Add database backups strategy
- [ ] Set up monitoring/alerting
- [ ] Test database failover
- [ ] Implement CDN for assets
- [ ] Set up log aggregation
- [ ] Security audit (3rd party)
- [ ] Penetration testing
- [ ] Load testing
- [ ] Disaster recovery plan

---

## QUICK FIX PRIORITY

### Immediate (Do Today):

1. Fix hardcoded credentials (CRITICAL #1)
2. Fix API URL (CRITICAL #4)
3. Fix CORS (CRITICAL #3)
4. Remove admin_bypass or secure it (CRITICAL #2)

### This Week:

5. Fix session storage to use HTTPOnly cookies
6. Add logout endpoint
7. Fix API response format consistency
8. Add error boundary to frontend

### This Sprint:

9. Add authentication to all endpoints
10. Implement pagination on list endpoints
11. Add file upload validation
12. Set up monitoring/logging

---

## Files That Need Review

**High Priority:**

- `backend/approve_purchase_request.php`
- `backend/admin_bypass.php`
- `frontend/src/config/api.js`
- `frontend/src/LoginForm.jsx`
- `docker-compose.yml`

**Medium Priority:**

- `backend/connect.php`
- `frontend/src/App.jsx`
- `backend/get_audit_logs.php`
- All `backend/upload_*.php` files

**Low Priority:**

- CSS and styling files
- Database migration scripts

---

## Recommendations

1. **Code Standards**: Implement ESLint + Prettier for frontend, PHPStan for backend
2. **Testing**: Add unit tests, integration tests, E2E tests
3. **CI/CD**: Set up GitHub Actions for automated testing and deployment
4. **Security**: Regular OWASP Top 10 reviews, pen testing
5. **Documentation**: API docs, deployment guide, architecture diagram
6. **Monitoring**: Application monitoring, error tracking (Sentry), log aggregation (ELK)

---

## Next Steps

1. Address all CRITICAL issues immediately
2. Create remediation plan for HIGH severity issues
3. Schedule code review with team
4. Implement security policy and checklist
5. Set up automated testing before deployment
