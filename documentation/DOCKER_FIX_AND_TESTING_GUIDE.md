# 🐳 DOCKER IMAGE CONFLICT FIX & WORKFLOW TESTING

**Date**: 2026-04-27  
**Purpose**: Resolve Docker image conflicts and verify workflow functionality

---

## 🔧 QUICK FIX (5 minutes)

### Option A: Full Clean Rebuild (Recommended)
```powershell
# 1. Navigate to workspace
cd c:\Users\User\Documents\v19

# 2. Stop all running containers
docker-compose down

# 3. Clean up old images (optional but recommended)
docker image rm v17_backend:2.0.0 2>$null
docker image rm v17_frontend:2.0.0 2>$null
docker image rm v17_mysql:5.7 2>$null

# 4. Rebuild images from scratch
docker-compose build --no-cache

# 5. Start services
docker-compose up -d

# 6. Check status
docker-compose ps
```

### Option B: Quick Rebuild (keeps cache)
```powershell
cd c:\Users\User\Documents\v19
docker-compose up -d --build
```

### Option C: Force Remove Orphans
```powershell
cd c:\Users\User\Documents\v19
docker-compose up -d --remove-orphans --build
```

---

## ✅ VERIFY DOCKER IS RUNNING

```powershell
# Check Docker daemon
docker ps

# Should return: CONTAINER ID, IMAGE, COMMAND, CREATED, STATUS, PORTS, NAMES
# If you get "Cannot connect to Docker daemon", start Docker Desktop
```

---

## 🔍 DIAGNOSIS COMMANDS

### Check all images
```powershell
docker images

# Look for any hanging or duplicate images
# Remove old ones with: docker rmi IMAGE_NAME
```

### Check container logs
```powershell
# Database container
docker logs ics-mysql --tail 50

# Backend container
docker logs ics-backend --tail 50

# Frontend container
docker logs ics-frontend --tail 50
```

### Check networks
```powershell
docker network ls
docker network inspect ics-network
```

### Check volumes
```powershell
docker volume ls
docker volume inspect v19_mysql_data
```

---

## 🚀 WORKFLOW VERIFICATION STEPS

### Step 1: Verify Services Are Running

```powershell
# Check all services
docker-compose ps

# Expected output:
# NAME                 COMMAND                  SERVICE     STATUS      PORTS
# ics-mysql           docker-entrypoint.sh     db          Up (healthy)
# ics-backend         apache2-foreground       backend     Up          0.0.0.0:3001->80/tcp
# ics-frontend        npm run dev              frontend    Up          0.0.0.0:3000->5173/tcp
# ics-phpmyadmin      /docker-entrypoint.sh    phpmyadmin  Up          0.0.0.0:8086->80/tcp
```

### Step 2: Test Database Connection

```bash
# Using Docker exec
docker exec ics-mysql mysqladmin -u root -prootpassword ping

# Should return: mysqld is alive
```

### Step 3: Access Frontend

```
Open browser: http://localhost:3000
Expected: Login form or dashboard appears
```

### Step 4: Test Login

```
Use credentials:
- Username: admin
- Password: Admin@2026
OR
- Username: employee
- Password: Employee@2026
```

### Step 5: Test Each Workflow Step

#### Step 1: Create Purchase Request
```
1. Click "New Purchase Request"
2. Enter:
   - PR Number: PR-2026-001
   - Item Name: Test Item
   - Quantity: 1
   - Unit: pcs
   - Unit Cost: 25000
   - Office: Finance
   - Division: Accounts
3. Click "Submit"
4. Expected: PR created successfully, note the PR ID
```

#### Step 2: Approve Purchase Request
```
1. Navigate to "Approvals" or "Pending Approvals"
2. Find the PR created in Step 1
3. Click "Approve"
4. Add note: "Approved for testing"
5. Click "Submit Approval"
6. Expected: Status changes to "Approved"
```

#### Step 3: Submit Delivery Notes
```
1. Navigate to "Delivery"
2. Find the approved PR
3. Enter delivery notes
4. Select delivery date
5. Click "Submit Delivery"
6. Expected: Status changes to "In Delivery"
```

#### Step 4: Inspection & Acceptance
```
1. Navigate to "Inspections"
2. Find the PR in delivery status
3. Enter inspection notes
4. Add condition report
5. Click "Submit Inspection"
6. Expected: Status changes to "Inspected"
```

#### Step 5: Submit Form (ICS/PPE)
```
Since our test PR is 25000 < 50000, it should trigger ICS form:

1. Fill ICS Form fields:
   - Item Description
   - Category
   - Location
   - etc.
2. Click "Submit Form"
3. Expected: Status changes to "Completed"
4. Modal appears: "Process Completed Successfully"
```

---

## 🧪 API TESTING (Using cURL or Postman)

### Test Backend Health
```powershell
# Check if backend is responding
curl http://localhost:3001/connect.php

# Should return JSON with connection status
```

### Test Step 1: Create PR
```powershell
$body = @{
    pr_no = "PR-TEST-001"
    item_name = "Test Item"
    quantity = 5
    unit = "pcs"
    unit_cost = 10000
    office = "Finance"
    division_section = "Accounts"
    user_id = 1
} | ConvertTo-Json

curl -X POST http://localhost:3001/submit_purchase_request.php `
  -H "Content-Type: application/json" `
  -d $body
```

### Test Step 2: Approve
```powershell
$body = @{
    pr_id = 1
    action = "approve"
    notes = "Test approval"
    user_id = 1
} | ConvertTo-Json

curl -X POST http://localhost:3001/approve_purchase_request.php `
  -H "Content-Type: application/json" `
  -d $body
```

### Retrieve PR Details
```powershell
curl "http://localhost:3001/get_pr_details.php?pr_id=1"
```

---

## 📊 DATABASE VERIFICATION

### Access via phpMyAdmin
```
URL: http://localhost:8086
Username: root
Password: rootpassword
```

### Check Tables Exist
```sql
-- In phpMyAdmin or mysql shell
USE my_app_db;

SHOW TABLES;

-- Should show:
-- purchase_requests
-- entries
-- inspection_assignments
-- workflow_history
-- audit_logs
-- users
-- roles
-- etc.
```

### Verify Step 1 Data
```sql
SELECT * FROM purchase_requests 
WHERE pr_no LIKE 'PR-TEST%' 
ORDER BY created_at DESC;
```

### Verify Workflow History
```sql
SELECT * FROM workflow_history 
ORDER BY created_at DESC 
LIMIT 10;
```

---

## ⚠️ TROUBLESHOOTING

### Issue: Docker containers won't start

**Solution**:
```powershell
# Check Docker status
docker ps

# Check for port conflicts
netstat -ano | findstr :3001
netstat -ano | findstr :3000
netstat -ano | findstr :3307

# Kill process if needed
taskkill /PID <PID> /F

# Rebuild with fresh state
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

### Issue: MySQL won't connect

**Solution**:
```powershell
# Check MySQL logs
docker logs ics-mysql

# Verify connection
docker exec ics-mysql mysql -u root -prootpassword -e "SELECT 1"

# Check health
docker-compose ps | grep mysql
# Should show (healthy) status
```

### Issue: Backend returns 502 Bad Gateway

**Solution**:
```powershell
# Check backend logs
docker logs ics-backend

# Restart backend
docker-compose restart backend

# Verify PHP is running
docker exec ics-backend php -v
```

### Issue: Frontend won't load

**Solution**:
```powershell
# Check frontend logs
docker logs ics-frontend

# Verify npm packages installed
docker exec ics-frontend npm list

# Rebuild frontend
docker-compose down
docker image rm v17_frontend:2.0.0
docker-compose build --no-cache frontend
docker-compose up -d frontend
```

### Issue: Port already in use

**Solution**:
```powershell
# Find what's using the port
netstat -ano | findstr :3001

# Kill the process
taskkill /PID <PID> /F

# Or modify docker-compose.yml ports
# Change "3001:80" to "3002:80" for backend
# Change "3000:5173" to "3001:5173" for frontend
```

---

## 🔄 RESTARTING SERVICES

### Restart All Services
```powershell
docker-compose restart
```

### Restart Specific Service
```powershell
docker-compose restart backend
docker-compose restart frontend
docker-compose restart db
```

### Restart with Fresh State
```powershell
docker-compose down
docker-compose up -d
```

---

## 📝 TEST RESULT TEMPLATE

```
TEST DATE: 2026-04-27
TESTED BY: [Your Name]

✅ Step 1: Purchase Request Creation
   - PR Created: PR-2026-[ID]
   - Total Amount: 25,000
   - Form Type: ICS (correct)
   - Database Entry: Verified in purchase_requests

✅ Step 2: Approval
   - PR Approved by: admin
   - Approval Date: [timestamp]
   - Status Updated: ✅
   - Workflow History: Logged

✅ Step 3: Delivery Notes
   - Delivery Date: [date]
   - Notes Recorded: ✅
   - Status Updated to In_Delivery: ✅

✅ Step 4: Inspection
   - Inspection Notes: [recorded]
   - Condition Report: [recorded]
   - Status Updated to Inspected: ✅

✅ Step 5: ICS Form
   - Form Type Selected: ICS ✅
   - Form Submitted: ✅
   - Process Completed: ✅
   - Final Status: Completed

OVERALL RESULT: ✅ ALL STEPS WORKING

Issues Found: None
Recommendations: None
```

---

## ✅ FINAL CHECKLIST

- [ ] Docker containers running (docker-compose ps shows all healthy)
- [ ] Frontend loads at http://localhost:3000
- [ ] Login works with valid credentials
- [ ] Step 1: Can create PR
- [ ] Step 2: Can approve PR
- [ ] Step 3: Can submit delivery notes
- [ ] Step 4: Can submit inspection
- [ ] Step 5: Can submit form (ICS for <50k, PPE for >=50k)
- [ ] Database has entries for all 5 steps
- [ ] No errors in Docker logs

---

## 🎯 NEXT STEPS

1. **Run Docker Clean Build**:
   ```powershell
   docker-compose down -v
   docker-compose build --no-cache
   docker-compose up -d
   ```

2. **Verify Services**:
   ```powershell
   docker-compose ps
   ```

3. **Run Workflow Tests** (see above)

4. **Check Logs** if issues occur

5. **Document Results** using template above

---

**Status**: Ready for deployment  
**Expected Duration**: 5-10 minutes for full verification
**Support**: Check Docker logs for detailed error messages
