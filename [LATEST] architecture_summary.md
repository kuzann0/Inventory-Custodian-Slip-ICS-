# System Architecture Summary

## 1. Overview

**System Type:** Monolithic web application with decoupled frontend and backend

**Description:** Inventory Custodian Slip (ICS) System – a comprehensive inventory and purchase request management platform. The system enables employees, admins, and super-admins to create, track, approve, and manage inventory items and purchase requests through a multi-step workflow. It features role-based access control, audit logging, dynamic data binding, and administrative capability management.

**Core Functionality:**
- Inventory entry management (CRUD operations)
- Purchase request workflow (5-step approval and delivery process)
- Role-based employee/admin/super-admin hierarchy
- Document and inspection assignment management
- Audit trail and admin bypass logging
- Capability-based authorization system

**Deployment Model:** Docker-based containerization (MySQL, PHP/Apache backend, React frontend, PHPMyAdmin)

---

## 2. Frontend (React JS)

### Technology Stack
- **Framework:** React 18.2.0 with React Router DOM 7.13.1
- **Build Tool:** Vite 8.0.1 with React plugin
- **Language:** JavaScript (ES Modules)
- **Styling:** CSS Modules (component-scoped CSS)
- **HTTP Client:** Fetch API

### Component Hierarchy

**Root Components:**
- `App.jsx` – Main routing hub with protected route wrappers
- `main.jsx` – Application entry point
- `Connect.jsx` – Database connection test utility

**Protected Route Wrappers (Role-Based):**
- `ProtectedRoute` – Requires valid `session_token` and `verified_email`
- `SuperAdminRoute` – Requires `role_id === 1`
- `AdminRoute` – Requires `role_id === 2`
- `EmployeeRoute` (implied) – Requires `role_id === 3`

**Layout Components:**
- `DashboardLayout.jsx` – Main dashboard wrapper with Header and content area
- `Header.jsx` – Top navigation and user info
- `Navbar.jsx` – Sidebar navigation menu

**Feature Components:**

*Authentication & User Management:*
- `LoginForm.jsx` – Login with username/password; stores session data in `sessionStorage`; includes admin bypass functionality
- `SuperAdminPage.jsx` – Super-admin dashboard and controls
- `EmployeeCapabilities.jsx` – User capability assignment and viewing

*Inventory Management:*
- `EntryForm.jsx` – Form to create new inventory entries; validates required fields (Item, SerialNo, InventoryItemNo)
- `ViewEntries.jsx` – Display all/own inventory entries with optional filtering

*Purchase Request Workflow:*
- `PurchaseRequest.jsx` – Multi-step PR submission UI (styled with design tokens)
- `NewPurchaseRequest.jsx` – Create new purchase request form
- `ProcessStatus.jsx` – Track PR approval and process status
- `ProcessCompletionModal.jsx` – Modal dialog for process completion

*Specialized Forms:*
- `ICSForm.jsx` – Inventory Custodian Slip form (items < 50k threshold)
- `PPEForm.jsx` – Personal Protective Equipment form (items >= 50k)
- `InspectionAssignment.jsx` – Assign and manage inspections
- `PropertyInventoryTag.jsx` – Property tagging for inventory

*Supporting Features:*
- `DocumentManagement.jsx` – Upload, retrieve, verify documents
- `PanelContent.jsx` – Generic content panel wrapper
- `Sorter.jsx` – Data sorting utility component

### State Management
- **Pattern:** React Hooks (`useState`, `useEffect`)
- **Session Storage:** Client-side `sessionStorage` (not cookies) for authentication tokens and user metadata
- **Stored Data:**
  - `session_token` – Auth token from backend
  - `verified_email`, `user_id`, `username`, `role_id`, `role_name`
  - `permissions` – JSON array of user capabilities
- **No Redux/Context:** Direct component state management with prop drilling (suitable for current app complexity)

### Routing Structure

**Routes (from App.jsx):**
- `/` → `LoginForm` (public)
- `/dashboard` → `DashboardLayout` + `PanelContent` (protected, role-based)
- `/entry` → `EntryForm` (protected)
- `/view-entries` → `ViewEntries` (protected)
- `/superadmin` → `SuperAdminPage` (SuperAdminRoute)
- `/purchase-request` → `PurchaseRequest` (protected)
- `/process-status` → `ProcessStatus` (protected)
- `/inspection-assignment` → `InspectionAssignment` (protected)
- `/documents` → `DocumentManagement` (protected)
- `/ics-form`, `/ppe-form` → Conditional forms based on PR amount
- `/property-tag` → `PropertyInventoryTag` (protected)
- `/employees` → `EmployeeCapabilities` (AdminRoute)

**Smart Redirection:** Post-login navigation based on `role_id`:
- `role_id = 1` → `/superadmin`
- `role_id = 2, 3` → `/dashboard`

### API Communication Layer

**Configuration (`config/api.js`):**
- Base URL determined by environment (Docker: `http://localhost:3001`, dev: `http://localhost:3001`, production: relative path)
- Fallback to `http://localhost:3001` if URL is undefined

**HTTP Patterns:**
- Method: `POST` for mutations, `GET` for queries
- Headers: `Content-Type: application/json` or `application/x-www-form-urlencoded`
- Credentials: `include` (send cookies/session data with cross-origin requests)
- Response Format: JSON

**Endpoint Examples:**
- `POST /login.php` – Authenticate user
- `POST /submit.php` – Create inventory entry
- `GET /get_entries.php` – Fetch inventory entries
- `POST /submit_purchase_request.php` – Submit PR
- `POST /admin_bypass.php` – Emergency admin access

### Styling Approach
- **CSS Modules:** Each component has a corresponding `.module.css` file (e.g., `LoginForm.module.css`)
- **Design Tokens:** Navy palette (`--navy`, `--navy-deep`, etc.), accent colors, typography (DM Sans font), radius, and shadows defined in PurchaseRequest component
- **Approach:** Component-scoped styles prevent naming conflicts; CSS custom properties (variables) for theming

### Dependencies
- `react@18.2.0` – UI library
- `react-dom@18.2.0` – DOM renderer
- `react-router-dom@7.13.1` – Client-side routing

**Dev Dependencies:**
- `vite@8.0.1` – Bundler and dev server
- `@vitejs/plugin-react@6.0.1` – React Fast Refresh
- `eslint@9.39.4` + plugins – Code linting

### Strengths
- Clean routing with role-based protection
- Reusable protected route patterns
- Component-scoped CSS prevents naming conflicts
- Efficient use of sessionStorage for lightweight state
- Responsive design with CSS modules

### Issues & Observations
- **State Management:** No global state library (Redux/Zustand) – could lead to prop drilling if app grows
- **Error Handling:** Limited error boundaries; no centralized error handling
- **Session Expiry:** No visible token refresh mechanism or expiry handling
- **Admin Bypass:** Security concern – admin bypass key passed in plain prompt() call
- **Fetch API:** No request/response interceptors; each endpoint call manually manages `credentials` and headers
- **Type Safety:** No TypeScript – difficult to refactor at scale
- **Testing:** No test files visible

---

## 3. Backend (PHP)

### Architecture
- **Type:** Custom PHP REST API (not a framework; raw procedural code)
- **Pattern:** File-per-endpoint (e.g., `login.php`, `submit.php`, `get_entries.php`)
- **Server:** Apache via Docker (port 3001)
- **Database:** MySQLi (procedural, not ORM)

### API Endpoints & Organization

**Authentication & User Management:**
- `login.php` – POST: Authenticate user with username/password; returns token, user data, role info
- `logout.php` – Session termination
- `login_debug.php` – Debug endpoint for login troubleshooting
- `admin_bypass.php` – POST: Emergency admin access via bypass key

**User & Admin Operations:**
- `get_all_users.php` – GET: List all users (admin/super-admin only)
- `create_user.php` – POST: Create new user account
- `update_user.php` – POST: Update user details
- `delete_user.php` – POST: Delete user
- `create_admin.php` – POST: Create admin account (super-admin only)
- `get_admins.php` – GET: List all admins
- `delete_admin.php` – POST: Delete admin account

**Inventory Entry Management:**
- `submit.php` – POST: Create new inventory entry (with duplicate checking)
- `get_entries.php` – GET: Fetch all/filtered entries; dynamic column selection based on workflow stage
- `get_last_entry_number.php` – GET: Retrieve last entry number (for form defaults)

**Purchase Request Workflow:**
- `submit_purchase_request.php` – POST: Submit PR with JSON validation; creates workflow entry
- `submit_purchase_request_binding.php` – POST: Alternative binding version using DynamicDataBinding
- `get_purchase_requests.php` – GET: Fetch all PRs with status
- `get_pr_details.php` – GET: Fetch single PR with full details
- `approve_purchase_request.php` – POST: Approve PR at approval level
- `complete_process.php` – POST: Mark PR as complete

**Workflow & Status Tracking:**
- `get_process_status.php` – GET: Fetch workflow status for a PR
- `get_process_summary.php` – GET: Summary of all processes
- `get_workflow_entry_binding.php` – GET: Fetch workflow entry using dynamic binding
- `get_all_workflow_entries_binding.php` – GET: Fetch all workflow entries

**Document Management:**
- `upload_document.php` – POST: Upload document with file validation
- `get_documents.php` – GET: List documents for a PR
- `download_document.php` – GET: Download document with access control

**Inspection & Delivery:**
- `submit_inspection.php` – POST: Record inspection results
- `get_inspection_assignments.php` – GET: Fetch inspection assignments
- `submit_delivery_notes.php` – POST: Submit delivery notes
- `submit_ics_form.php` – POST: Submit ICS form (inventory < 50k)
- `submit_ppe_form.php` – POST: Submit PPE form (inventory >= 50k)
- `submit_property_tag.php` – POST: Submit property inventory tag

**Capability & Authorization:**
- `get_capabilities.php` – GET: List all capabilities
- `get_user_capabilities.php` – GET: User's assigned capabilities
- `grant_capability.php` – POST: Assign capability to user
- `get_employees.php` – GET: List employees with capability info

**Audit & Logging:**
- `get_audit_logs.php` – GET: Fetch audit log entries
- `admin_bypass_log` table – Tracks admin bypass usage

**Database Management (Development):**
- `database/` folder contains migration and setup files

### Authentication Mechanism

**Session-Based Authentication:**
- Sessions started with `session_start()` (standard PHP sessions)
- Cookie parameters set before session start:
  - `lifetime: 3600` (1 hour)
  - `httponly: true` (no JavaScript access)
  - `samesite: Lax` (CSRF protection)
- Token stored in `$_SESSION` and returned as `session_token` in JSON response
- User data retrieved via `$_SESSION['user_id']`, `$_SESSION['role_id']`, etc.

**Login Flow (login.php):**
1. Parse JSON body (username, password)
2. Query `users` table with prepared statement
3. Left JOIN `user_roles` to get role and permissions
4. Verify password with `password_verify()` against `password_hash`
5. Return token, user object, role info on success
6. HTTP 401 on invalid credentials

**Session Validation:**
- Most endpoints check `$_SESSION['user_id']` or accept via `X-User-ID` header (fallback)
- Role-based filtering: employees see own entries; admins/super-admins see all

### Middleware & Request Handling

**CORS Configuration (`config/cors.php`):**
- Whitelist-based CORS (specific origins allowed)
- Allowed origins:
  - `http://10.20.10.37:3000`, `:5173` (IP-based)
  - `http://localhost:3000`, `:5173` (dev localhost)
  - `http://127.0.0.1:3000`, `:5173`
- Security headers: `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `X-XSS-Protection`, `HSTS`

**Global Patterns:**
- `session_start()` called in most endpoints
- CORS headers required
- Preflight (`OPTIONS`) requests handled and exit with 200
- JSON response type enforced
- Error logging via `error_log()` (PHP error log)

### Error Handling & Logging

**Error Patterns:**
- Errors returned as JSON: `{"status": "error", "message": "..."}`
- HTTP status codes used correctly (400 Bad Request, 401 Unauthorized, 500 Server Error)
- Database errors caught and logged; sanitized error message returned to client

**Debug Logging:**
- `error_log()` used for sensitive info (login attempts, DB errors)
- Error reporting enabled (`E_ALL`) but display suppressed (`display_errors: 0`)
- Logs should go to `/var/log/php_errors.log` (commented configuration in `submit_purchase_request.php`)

**JSON Error Helpers (submit_purchase_request.php pattern):**
- `jsonError($message, $code, $debug)` – Consistent error responses
- `jsonOk($payload)` – Consistent success responses
- Ensures frontend never receives malformed JSON

### Key Dependencies

**Composer.json:**
- `phpmailer/phpmailer@^6.8` – Email sending (configured but may be offline mode)
- PHP >= 7.4 required
- Custom PSR-4 autoloader mapping `ICS\` namespace to `src/`

**Database Libraries:**
- Built-in `mysqli` extension (procedural API)
- No ORM; raw SQL queries with prepared statements

### Database Interaction Patterns

**Prepared Statements:** Used extensively
```php
$stmt = $conn->prepare("SELECT * FROM users WHERE id = ?");
$stmt->bind_param('i', $userId);
$stmt->execute();
```

**Direct Queries:** Some queries use `$conn->query()` without parameterization (potential SQL injection risk in certain contexts)

**Transactions:**
- Some endpoints use `$conn->begin_transaction()` and `$conn->commit()`
- Example: `DynamicDataBinding.php` wraps multi-step operations in transactions

### Special Features

**Dynamic Data Binding (`DynamicDataBinding.php`):**
- Class-based wrapper for complex workflow operations
- Maps 5-step purchase request workflow to centralized `entries` table
- Handles entry creation, workflow tracking, and status updates
- Implements transactional integrity for multi-step processes

**Capability System:**
- Granular permission control (`view_entries`, `create_entries`, `edit_entries`, etc.)
- Capabilities assigned via `user_capabilities` table
- Categories: INVENTORY, ADMIN, SYSTEM, USER

**Admin Bypass Mechanism:**
- Super-admins can bypass authentication with a secret key
- Logs bypass attempts in `admin_bypass_log` table
- Security concern: key passed via POST body with email and reason

### Strengths
- Simple file-per-endpoint structure is easy to understand
- Prepared statements prevent SQL injection in most places
- Session-based auth with secure cookie settings
- CORS whitelist prevents unauthorized cross-origin requests
- Transactional support for complex workflows
- Comprehensive audit logging

### Issues & Observations
- **No Framework:** Raw PHP makes code repetitive and harder to maintain
- **No ORM:** Manual query construction increases SQL injection risk if not careful
- **Inconsistent Error Handling:** Some endpoints return `{"status": "error"}`, others use HTTP status codes inconsistently
- **Mixed Patterns:** Some use sessions, some use headers, some fallback to defaults
- **Offline Email Mode:** Email functionality appears to have offline fallback; unclear if fully implemented
- **Admin Bypass:** Security risk – allows unauthorized access with a key
- **No Request Validation:** Limited input validation; relies on DB constraints
- **Database Connection Hardcoded:** Connection details in each file instead of centralized config (though env vars are used)
- **Missing Error Responses:** Some operations may fail silently if query fails
- **No Rate Limiting:** No protection against brute-force attacks

---

## 4. MySQL Database

### Overview
- **Version:** MySQL 5.7.44 (via Docker)
- **Database:** `my_app_db`
- **Charset:** UTF-8MB4 (Unicode support)
- **Collation:** `utf8mb4_unicode_ci` (case-insensitive)

### Core Tables

**User Management:**
- `users` – Main user accounts table
  - Columns: `id`, `username`, `email`, `password_hash`, `role_id`, `account_status`, created_at, updated_at
  - Primary Key: `id`
  - FK: `role_id` → `user_roles.id`
  - Constraints: Unique `username`, `email`

- `user_roles` – Role definitions
  - Columns: `id`, `role_name`, `permissions` (JSON)
  - Roles: SuperAdmin (1), Admin (2), Employee (3)

- `admin_accounts` – Audit trail for admin creations
  - Columns: `id`, `admin_user_id`, `created_by_superadmin_id`, `username`, `email`, `permissions`, `is_active`, `last_login`, created_at, updated_at
  - FK: `created_by_superadmin_id` → `users.id`

**Capabilities & Authorization:**
- `capabilities` – Define system capabilities
  - Columns: `id`, `capability_key`, `category`, `description`, `required_role_id`, `is_active`, created_at
  - Categories: INVENTORY, ADMIN, SYSTEM, USER
  - Examples: `view_entries`, `create_entries`, `edit_entries`, `edit_admin_caps`

- `user_capabilities` – Maps users to capabilities
  - Columns: `id`, `user_id`, `capability_id`, `assigned_by`, `assigned_at`, `expires_at`
  - FK: `user_id` → `users.id`, `capability_id` → `capabilities.id`

**Inventory Management:**
- `entries` – Core inventory items table
  - Columns: `order_id` (PK, auto-increment), `Quantity`, `Unit`, `Amount`, `UnitCost`, `TotalCost`, `Description`, `Item`, `SerialNo`, `DateAcquired`, `Location`, `InventoryItemNo`, `EstimatedUsefulLife`
  - Constraints: Unique `SerialNo`, Unique `InventoryItemNo`
  - Charset: latin1 (legacy; should migrate to utf8mb4)

- `property_inventory` – Property tag tracking
  - Columns: `id`, `entry_id`, `tag_number`, `custodian_name`, `office`, `status`, created_at, updated_at
  - FK: `entry_id` → `entries.order_id`

**Purchase Request Workflow:**
- `purchase_requests` – PR metadata
  - Columns: `id`, `pr_number`, `requested_by`, `total_amount`, `status`, `priority`, created_at, updated_at
  - FK: `requested_by` → `users.id`

- `approval_queue` – Multi-level approval tracking
  - Columns: `id`, `pr_id`, `approval_level`, `required_role_id`, `assigned_to`, `is_required`, `status` (pending|approved|rejected|expired), `approved_by`, `approval_date`, `rejection_reason`, `due_date`, created_at, updated_at
  - FK: `pr_id` → `purchase_requests.id`, `assigned_to` → `users.id`, `approved_by` → `users.id`
  - Status transitions: pending → approved/rejected/expired

- `workflow_history` – Audit trail for workflow changes
  - Columns: `id`, `pr_id`, `step`, `action`, `timestamp`, `user_id`, `notes`

**Document Management:**
- `documents` – File uploads for PRs
  - Columns: `id`, `pr_id`, `pr_no`, `document_type`, `filename`, `file_path`, `file_size`, `uploaded_by`, `upload_date`, `verified`, `verified_by`, `verified_at`
  - FK: `pr_id` → `purchase_requests.id`, `uploaded_by` → `users.id`

**Inspection & Delivery:**
- `inspection_assignments` – Assign inspectors to PRs
  - Columns: `id`, `pr_id`, `assigned_to`, `status`, created_at, updated_at
  - FK: `pr_id` → `purchase_requests.id`, `assigned_to` → `users.id`

**Audit & Logging:**
- `audit_logs` – General system audit trail
  - Columns: `id`, `admin_id`, `action`, `action_details` (JSON), `ip_address`, `user_agent`, created_at
  - FK: `admin_id` → `users.id`

- `capability_audit_log` – Tracks capability grant/revoke
  - Columns: `id`, `actor_id`, `target_id`, `action` (GRANT|REVOKE|EXPIRE), `capability_id`, `reason`, `ip_address`, created_at
  - FK: `actor_id` → `users.id`, `target_id` → `users.id`

- `admin_bypass_log` – Tracks admin bypass usage
  - Columns: `id`, `admin_id`, `bypassed_user_email`, `bypass_key`, `ip_address`, `user_agent`, created_at

- `login_audit` – Login attempt tracking
  - Columns: `id`, `user_id`, `login_time`, `ip_address`, `success_flag`

**OTP & Email (Optional):**
- `otp_codes` – One-time password storage
  - Columns: `id`, `user_id`, `code`, `created_at`, `expires_at`

- `offline_emails` – Email queue for offline mode
  - Columns: `id`, `recipient`, `subject`, `body`, `sent_flag`, created_at

### Indexes

**Explicit Indexes (for query performance):**
- `entries`: Primary key on `order_id`; Unique on `SerialNo`, `InventoryItemNo`
- `purchase_requests`: Foreign keys on `requested_by`
- `approval_queue`: FK indexes on `pr_id`, `assigned_to`, `approved_by`; regular indexes on `status`, `approval_level`
- `audit_logs`: Index on `admin_id`, `action`, `created_at`
- `users`: Unique on `username`, `email`

**Implicitly Indexed (via Foreign Keys):**
- All FK relationships automatically indexed

### Query Patterns

**Dynamic Column Selection (get_entries.php):**
- Checks which columns exist before including in SELECT
- Adapts to workflow stage (different columns for different steps)
- Uses LEFT JOINs for optional workflow metadata

**Role-Based Filtering:**
- Employee sees: Own entries only (`WHERE user_id = ?`)
- Admin/SuperAdmin sees: All entries

**Transactional Operations (DynamicDataBinding):**
- Multi-step operations wrapped in transactions
- Ensures data consistency across `entries` → `purchase_requests` → `approval_queue`

### Security & Constraints

**SQL Injection Protection:**
- Prepared statements used extensively
- Parameter binding: `bind_param('i', $userId)`
- However, some queries may still be vulnerable if user input used in dynamic SQL

**Data Validation:**
- Unique constraints on `SerialNo` and `InventoryItemNo` prevent duplicates
- Foreign keys enforce referential integrity
- Character set UTF-8MB4 handles international characters safely

**Audit Trail:**
- Multiple log tables track user actions (login_audit, audit_logs, capability_audit_log, admin_bypass_log)
- Enables compliance and security monitoring

### Stored Procedures & Triggers
- None visible in schema – all logic in application layer (PHP)

### Views
- None visible

### Potential Optimizations

1. **Add Indexes:**
   - `CREATE INDEX idx_user_id ON entries(user_id)` – For filtering by user
   - `CREATE INDEX idx_pr_status ON purchase_requests(status)` – For PR status queries
   - `CREATE INDEX idx_created_at ON audit_logs(created_at)` – For time-range queries

2. **Partitioning:**
   - Audit and log tables could be partitioned by date for faster queries on large datasets

3. **Archive Old Data:**
   - Move old entries, audit logs to archive tables after 1-2 years

4. **Charset Migration:**
   - Migrate `entries` table from latin1 to utf8mb4 for consistency

5. **Query Optimization:**
   - Review dynamic column queries in `get_entries.php` for efficiency
   - Consider caching capability lists

---

## 5. Frontend ↔ Backend Integration

### HTTP Request Flow

**1. Request Initiation (Frontend):**
```javascript
const response = await fetch(`${API_BASE_URL}/login.php`, {
  method: "POST",
  credentials: 'include',  // Send cookies/session
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ username, password })
});
```

**2. Request Reception (Backend):**
- CORS check: verify origin is whitelisted
- Preflight (`OPTIONS`): return 200 + CORS headers
- Actual request: parse body, process logic, return JSON

**3. Response Handling (Frontend):**
```javascript
const data = await response.json();
if (data.status === 'success') {
  // Store session token, user data, redirect
  sessionStorage.setItem('session_token', data.token);
  navigate("/dashboard");
}
```

### Authentication Token & Session Passing

**Token Storage:**
- Stored in browser `sessionStorage` (cleared on tab close)
- NOT stored in cookies (controlled by backend via `httponly` flag)
- Frontend sends token via:
  - Session persistence (PHP sessions)
  - Optional: `X-User-ID` header (for fallback in stateless mode)

**Session Maintenance:**
- Backend maintains PHP `$_SESSION` indexed by session cookie
- Frontend includes credentials: `credentials: 'include'` in fetch options
- Session cookie automatically sent by browser on each request

### CORS Configuration

**Allowed Origins (from backend/config/cors.php):**
- `http://10.20.10.37:3000`, `:5173` (development network)
- `http://localhost:3000`, `:5173` (local development)
- `http://127.0.0.1:3000`, `:5173`

**CORS Headers Sent by Backend:**
- `Access-Control-Allow-Origin`: Matched to request origin
- `Access-Control-Allow-Credentials: true`
- `Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS`
- `Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-User-ID`

### Data Format

**Request Format:**
- Content-Type: `application/json` (for purchase request, login) or `application/x-www-form-urlencoded` (for inventory entry)
- JSON body example:
  ```json
  {
    "username": "john",
    "password": "secure123"
  }
  ```

**Response Format:**
- Content-Type: `application/json`
- Success response:
  ```json
  {
    "status": "success",
    "token": "session_token_xyz",
    "user": {
      "id": 1,
      "username": "john",
      "email": "john@example.com",
      "role_id": 2,
      "role_name": "Admin",
      "permissions": ["view_entries", "create_entries"]
    }
  }
  ```
- Error response:
  ```json
  {
    "status": "error",
    "message": "Invalid credentials"
  }
  ```

### Error Handling Across Stack

**Backend → Frontend:**
- Errors returned as JSON with `status: "error"` or `success: false`
- HTTP status codes indicate severity (400, 401, 403, 500)
- Frontend checks `response.ok` or `data.status` before proceeding

**Frontend Error Display:**
- `setError(message)` updates component state
- Error rendered in red alert box: `className={styles.alertError}`
- Network errors caught in `catch` block: `setError("Network error. Please try again.")`

**Backend Error Logging:**
- Sensitive errors logged to PHP error log (not returned to client)
- Example: `error_log("LOGIN FAILED: User '$username' not found")`
- Client receives generic message: `"Invalid credentials"`

### Example Integration: Login Flow

**Frontend (LoginForm.jsx):**
```javascript
1. User enters username/password
2. handleLogin() sends POST to /login.php
3. Response received: check data.status
4. If success: store token + user data in sessionStorage, navigate to /dashboard or /superadmin
5. If error: display error message, remain on /
```

**Backend (login.php):**
```php
1. Receive JSON { username, password }
2. Query users table with prepared statement
3. Verify password_hash
4. Set $_SESSION['user_id'], $_SESSION['role_id'], etc.
5. Return JSON with session_token, user object, role info
6. Frontend stores token in sessionStorage
```

**Subsequent Requests (get_entries.php):**
```
1. Frontend sends GET to /get_entries.php
2. Browser automatically includes session cookie (credentials: 'include')
3. Backend retrieves user_id from $_SESSION
4. Filters entries based on role_id (employee sees own, admin sees all)
5. Returns JSON array of entries
```

### API Communication Patterns

**Pattern 1: Form Submission**
```javascript
const response = await fetch(`${API_BASE_URL}/submit.php`, {
  method: "POST",
  credentials: 'include',
  headers: { "Content-Type": "application/x-www-form-urlencoded" },
  body: new URLSearchParams(formData)
});
```

**Pattern 2: JSON POST (New PRs)**
```javascript
const response = await fetch(`${API_BASE_URL}/submit_purchase_request.php`, {
  method: "POST",
  credentials: 'include',
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify(prData)
});
```

**Pattern 3: Query String GET**
```javascript
const response = await fetch(`${API_BASE_URL}/get_entries.php?user_id=${userId}`, {
  credentials: 'include'
});
```

---

## 6. Overall Architecture Assessment

### Scalability

**Current State:**
- Monolithic architecture: frontend and backend tightly integrated
- Single MySQL instance: suitable for < 10,000 concurrent users
- Session-based: no horizontal scaling without sticky sessions
- Docker: single-container deployment; not horizontally scalable

**Scaling Challenges:**
- PHP file-per-endpoint approach becomes unwieldy with 50+ endpoints
- No API versioning or deprecation strategy
- Database: single connection per request; connection pooling not implemented
- Frontend: no lazy loading or code splitting (Vite capable but not used)

**Recommendations:**
1. Implement API gateway or versioning (`/api/v2/endpoint`)
2. Add database connection pooling
3. Implement caching layer (Redis) for capabilities, roles
4. Split frontend into chunks for lazy loading
5. Consider microservices for distinct domains (auth, inventory, purchasing)

### Security Posture

**Strengths:**
- Prepared statements prevent SQL injection
- Session cookies marked `httponly` and `samesite=Lax`
- Password hashed with `password_hash()`
- CORS whitelisting prevents unauthorized cross-origin requests
- Audit logging on capabilities, admin actions, logins
- Role-based access control enforced

**Vulnerabilities & Risks:**

1. **Admin Bypass Mechanism:**
   - Allows super-admins to bypass authentication
   - Bypass key passed in plain text via POST body
   - Logged but not enough protection
   - **Risk:** High – if key leaked, system is compromised
   - **Recommendation:** Require multi-factor confirmation (email, 2FA)

2. **Session Fixation:**
   - No session regeneration on login
   - **Risk:** Medium – attacker could hijack session
   - **Recommendation:** Regenerate session ID on successful login: `session_regenerate_id(true)`

3. **CSRF Protection:**
   - No CSRF token in forms
   - Relies on `SameSite` cookie flag
   - **Risk:** Medium if cookies can be sent cross-site
   - **Recommendation:** Implement CSRF token validation

4. **Input Validation:**
   - Limited validation on user inputs
   - Database constraints relied upon (e.g., unique SerialNo)
   - **Risk:** Medium – could lead to unexpected data or errors
   - **Recommendation:** Validate all inputs server-side (email format, length, type)

5. **XSS (Cross-Site Scripting):**
   - React auto-escapes JSX by default (good)
   - No CSP (Content Security Policy) header set
   - **Risk:** Low-Medium – depends on DOM manipulation
   - **Recommendation:** Set CSP header: `Content-Security-Policy: default-src 'self'`

6. **SQL Injection in Dynamic Queries:**
   - Some endpoints build queries dynamically (e.g., `get_entries.php` column selection)
   - Whitelist used but could be bypassed
   - **Risk:** Medium if whitelist not properly maintained
   - **Recommendation:** Use parameterized columns via mapping array, not dynamic inclusion

7. **Logging Sensitive Data:**
   - Passwords checked in logs during login attempts
   - **Risk:** Low (dev/debug mode) but dangerous in production
   - **Recommendation:** Remove detailed logging in production

8. **No Rate Limiting:**
   - No protection against brute-force attacks on login
   - **Risk:** High – attackers can try unlimited password combinations
   - **Recommendation:** Implement rate limiting (e.g., max 5 login attempts per IP per 15 min)

9. **File Upload (documents):**
   - File upload functionality visible but validation unclear
   - **Risk:** High – file upload is common attack vector
   - **Recommendation:** Validate file type (whitelist), size, scan for malware

10. **Sensitive Data Exposure:**
    - DB credentials hardcoded in source (uses env vars, mitigated)
    - Admin bypass key not encrypted
    - **Risk:** Medium if source code or environment exposed
    - **Recommendation:** Encrypt sensitive keys, use secrets management

### Maintainability

**Strengths:**
- Clear component structure in React (one feature per component)
- CORS and database connection patterns consistent across endpoints
- CSS Modules prevent naming conflicts and cascading issues
- Comments and documentation present in key files

**Weaknesses:**
- **Code Duplication:** Same connection logic repeated in every PHP file
- **No Abstraction:** Database queries not abstracted into query builder or repository pattern
- **No Type Safety:** JavaScript and PHP lack types (JSDoc or TypeScript would help)
- **File Organization:** 40+ PHP endpoints at root level; should be organized into folders (e.g., `endpoints/user/`, `endpoints/inventory/`)
- **No Framework:** Building everything from scratch; no routing, middleware, ORM
- **Inconsistent Error Handling:** Some endpoints use `status` field, others use HTTP codes
- **Magic Strings:** Role IDs hardcoded as 1, 2, 3 throughout (should be constants)
- **No Dependency Injection:** Every file manually creates DB connection
- **Test Coverage:** None visible

**Recommendations:**
1. Adopt a PHP framework (Laravel, Slim, or Symfony)
2. Use TypeScript for frontend
3. Organize endpoints into feature modules
4. Extract shared logic (DB connection, error handling) into reusable services
5. Add unit and integration tests
6. Document API with OpenAPI/Swagger
7. Use code linting and formatting (Prettier, PHP-CS-Fixer)

### Critical Risks

1. **Data Loss:**
   - No backup strategy visible
   - Single database instance; no replication
   - **Impact:** High – all system data could be lost
   - **Mitigation:** Automated daily backups, database replication

2. **Admin Bypass Compromise:**
   - If bypass key exposed, entire system compromised
   - **Impact:** High – unauthorized access
   - **Mitigation:** Rotate keys regularly, require multi-factor confirmation

3. **Scalability Limits:**
   - Current architecture can't handle growth beyond ~100 concurrent users
   - **Impact:** Medium – app will slow down significantly
   - **Mitigation:** Implement caching, database optimization, horizontal scaling

4. **Workflow State Inconsistency:**
   - Purchase requests tracked across multiple tables (`purchases`, `approval_queue`, `workflow_history`)
   - Risk of inconsistency if transaction fails mid-update
   - **Impact:** Medium – workflow could stall
   - **Mitigation:** More comprehensive transaction management, event-sourcing

5. **Email Delivery (if used):**
   - Offline email mode could lose emails if not properly persisted
   - **Impact:** Medium – notifications won't reach users
   - **Mitigation:** Use reliable email service (SendGrid, AWS SES)

---

## 7. Tech Stack Summary

### Frontend
- React 18.2.0
- React Router DOM 7.13.1
- Vite 8.0.1 (bundler, dev server)
- CSS Modules
- Fetch API
- Node.js (runtime)
- npm (package manager)

### Backend
- PHP 7.4+
- Apache (web server, via Docker)
- MySQLi (database driver)
- PHPMailer 6.8 (email, optional)
- PSR-4 autoloading

### Database
- MySQL 5.7.44
- UTF-8MB4 charset
- InnoDB storage engine

### Infrastructure
- Docker & Docker Compose
- MySQL 5.7 container
- Apache PHP container
- PHPMyAdmin 5.2 (database UI)
- Port forwarding:
  - Frontend: 5173 (Vite dev)
  - Backend: 3001 (Apache)
  - Database: 3307 (MySQL)
  - PHPMyAdmin: 8086 (web UI)

### Development Tools
- ESLint 9.39.4 (code linting)
- Vite plugins (React Fast Refresh)
- Docker (containerization)

---

## 8. Additional Notes

### Assumptions Due to Missing or Unclear Files

1. **Frontend Build Process:**
   - Assumed Vite's default build output to `dist/` folder
   - Production build: `npm run build` → compiled assets served by backend or CDN

2. **Email Functionality:**
   - PHPMailer included but unclear if actively used
   - Offline email mode mentioned but not fully implemented in visible code
   - Assumed optional feature or in-progress

3. **Database Schema Evolution:**
   - Multiple backup files (04-27-26-LATESTDB.sql, COMPLETE_DATABASE_FIX_20260514.sql) suggest recent migrations
   - Schema may have pending optimizations

4. **Environment Configuration:**
   - `.env.example` files visible; actual `.env` likely contains real credentials
   - Assumed Docker Compose passes env vars to backend

5. **Frontend Deployment:**
   - How frontend assets served to users unclear
   - Assumed: Vite build output → Docker volume → Apache serves static files

6. **Authentication Flow:**
   - Admin bypass mechanism suggests legacy migration or special use case
   - No documentation on intended usage (emergency access?)

7. **Data Model:**
   - Workflow tables (`approval_queue`, `workflow_history`) suggest complex approval process
   - Specific thresholds (< 50k for ICS, >= 50k for PPE) mentioned in forms but logic not clearly centralized

8. **Testing Infrastructure:**
   - Multiple test endpoints visible (`test.php`, `test_login.php`)
   - No automated test suite found
   - Assumed manual testing or CI/CD not yet implemented

### Observations on Code Quality

**Positive:**
- Consistent use of prepared statements
- CORS configuration properly considered
- Audit logging implemented
- Role-based access control in place
- Comments present on complex logic

**Areas for Improvement:**
- No framework structure; more organization needed
- Error handling inconsistent across endpoints
- Limited input validation
- No automated tests
- Session security could be strengthened (regeneration, timeout)
- Admin bypass is a security risk

### Recommended Next Steps

1. **Short Term (1-2 weeks):**
   - Add session regeneration on login
   - Implement CSRF token validation
   - Add rate limiting to login endpoint
   - Organize PHP endpoints into folders
   - Extract database connection logic into shared service

2. **Medium Term (1 month):**
   - Migrate to Laravel or Slim framework
   - Add TypeScript to frontend
   - Implement automated unit tests
   - Document API with Swagger/OpenAPI
   - Add database indexes for slow queries

3. **Long Term (2-3 months):**
   - Implement caching layer (Redis)
   - Add JWT tokens for stateless authentication
   - Separate concerns into microservices
   - Set up CI/CD pipeline (GitHub Actions, GitLab CI)
   - Plan database replication and backup strategy
   - Conduct security audit and penetration testing

