# 📊 COMPLETE WORKFLOW ANALYSIS
## Purchase Request → Property Inventory → Entries → View Entries

**Date**: April 14, 2026  
**Analysis Focus**: Original workflow data flow and relationships

---

## 🔄 WORKFLOW OVERVIEW

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     PURCHASE REQUEST LIFECYCLE                          │
└─────────────────────────────────────────────────────────────────────────┘

User Creates PR
    ↓
Step 1: Create Purchase Request (NewPurchaseRequest.jsx → PurchaseRequest.jsx)
    ├─ Input: PR Name, Item, Quantity, Unit Cost, Office, Division
    └─ Output: pr_id, form_type determined by amount (ICS < ₱50K, PPE ≥ ₱50K)
    
    ↓ INSERT INTO purchase_requests (status='draft')
    
Step 2: Submit Approval (PurchaseRequest.jsx → approve_purchase_request.php)
    ├─ Approve or Reject PR
    └─ STATUS: 'pending_approval' → 'approved' or 'rejected'
    
    ↓ UPDATE purchase_requests SET status='approved'
    
Step 3: Delivery Notes (PurchaseRequest.jsx → submit_delivery_notes.php)
    ├─ Add delivery information
    └─ STATUS: 'approved' → 'in_delivery'
    
    ↓ UPDATE purchase_requests SET status='in_delivery'
    
Step 4: Inspection (PurchaseRequest.jsx → submit_inspection.php)
    ├─ Inspection notes
    └─ STATUS: 'in_delivery' → 'inspected'
    
    ↓ UPDATE purchase_requests SET status='inspected'
    
Step 5: Form Selection (ICS/PPE/Property Tag)
    │
    ├─ Option A: ICS Form (< ₱50K) → submit_ics_form.php
    │
    ├─ Option B: PPE Form (≥ ₱50K) → submit_ppe_form.php
    │
    └─ Option C: Property Tag (Fixed Asset) → submit_property_tag.php
           ├─ INSERT INTO property_inventory
           ├─ INSERT INTO entries (★ NEW - Added in latest fix)
           └─ Complete the process
    
    ↓ complete_process.php → STATUS: 'completed'
    
Final: Redirect to Dashboard
```

---

## 📋 TABLE RELATIONSHIPS

### Primary Tables

```
purchase_requests (Core)
├── id (PRIMARY KEY)
├── pr_no (UNIQUE) - Purchase Request Number
├── description
├── item_name
├── quantity
├── unit
├── unit_cost
├── total_amount = quantity × unit_cost
├── status (ENUM)
├── office
├── division_section
├── form_type (ENUM: 'ics', 'ppe', 'none')
├── created_by (FK → users.id)
├── created_at
└── updated_at

           ↓ REFERENCES (one-to-many)

workflow_history (Audit Trail)
├── id (PRIMARY KEY)
├── pr_id (FK → purchase_requests.id)
├── status_from
├── status_to
├── action_by (FK → users.id)
├── action_type
├── action_date
└── notes

           ↓ References purchase_requests

property_inventory (Fixed Assets ≥ ₱50K)
├── id (PRIMARY KEY)
├── pr_id (FK → purchase_requests.id) ★ Links back to PR
├── pr_no (Denormalized for quick lookup)
├── property_number (UNIQUE)
├── model_number
├── description
├── serial_number
├── unit_of_measure
├── acquisition_date
├── supplier
├── estimated_cost
├── location
├── status
└── created_at

           ↓ References purchase_requests

entries (Legacy Inventory View)
├── order_id (PRIMARY KEY)
├── Quantity
├── Unit
├── Amount
├── UnitCost
├── TotalCost
├── Description
├── Item
├── SerialNo (UNIQUE)
├── DateAcquired
├── Location
├── InventoryItemNo (UNIQUE) ★ Property Number reference
└── EstimatedUsefulLife
```

---

## 🔀 DATA FLOW PATHS

### Path A: Small Items (ICS Form - Amount < ₱50,000)
```
NewPurchaseRequest → Create PR → Approval → Delivery → Inspection → ICS Form → Complete
                     ↓ insert
              purchase_requests
                     ↓ insert
              workflow_history (5 steps)
              
              Final: PR viewed in ViewEntries as AGGREGATED from purchase_requests
              (get_entries.php returns SELECT...FROM purchase_requests)
```

### Path B: Large Items (PPE Form - Amount ≥ ₱50,000)
```
NewPurchaseRequest → Create PR → Approval → Delivery → Inspection → PPE Form → Complete
                     ↓ insert
              purchase_requests
                     ↓ insert
              workflow_history (5 steps)
              
              Final: PR viewed in ViewEntries as AGGREGATED from purchase_requests
```

### Path C: Fixed Assets (Property Tag - Amount ≥ ₱50,000)
```
NewPurchaseRequest → Create PR → Approval → Delivery → Inspection → Property Tag
                     ↓ insert                                          ↓ insert
              purchase_requests                               property_inventory
                     ↓ insert                                  ↓ insert (★ NEW)
              workflow_history                                 entries
              (5 steps + 1 property_tagged)                   
              
              Final: PR viewed in BOTH places:
              1. ViewEntries from purchase_requests (via get_entries.php)
              2. ViewEntries from entries table (legacy support)
              3. Property Inventory page (dedicated view)
```

---

## 📊 DATABASE STATE AT EACH STEP

### After Step 1: Create PR
```sql
-- purchase_requests
INSERT INTO purchase_requests (
  pr_no='PR-2026-001',           -- Generated by user
  item_name='Laptop',             -- Input
  description='Dell XPS',         -- Input  
  quantity=5,                     -- Input
  unit='pc',                      -- Input
  unit_cost=25000.00,             -- Input
  total_amount=125000.00,         -- Calculated (5 × 25000)
  office='Finance',               -- Input
  division_section='IT',          -- Input
  form_type='ppe',                -- Calculated (125000 ≥ 50000)
  status='draft',                 -- Set by system
  created_by=3,                   -- User ID
  created_at=NOW()
)
RESULT: pr_id = 10

-- workflow_history
INSERT INTO workflow_history (
  pr_id=10,
  status_to='draft',
  action_by=3,
  action_type='created',
  notes='Purchase Request created',
  action_date=NOW()
)
```

**ViewEntries at this point**: Shows PR-2026-001 with status='draft'

---

### After Step 2: Approval
```sql
-- purchase_requests
UPDATE purchase_requests 
SET status='approved',            -- Changed from 'draft'
    approval_date=NOW(),
    approved_by=1
WHERE id=10

-- workflow_history
INSERT INTO workflow_history (
  pr_id=10,
  status_from='draft',
  status_to='approved',
  action_by=1,
  action_type='approved',
  action_date=NOW()
)
```

**ViewEntries at this point**: Shows PR-2026-001 with status='approved'

---

### After Step 3: Delivery
```sql
-- purchase_requests
UPDATE purchase_requests 
SET status='in_delivery',         -- Changed from 'approved'
    delivery_notes='...',
    actual_delivery_date=NOW()
WHERE id=10

-- workflow_history
INSERT INTO workflow_history (
  pr_id=10,
  status_from='approved',
  status_to='in_delivery',
  action_by=3,
  action_type='delivery_noted',
  action_date=NOW()
)
```

**ViewEntries at this point**: Shows PR-2026-001 with status='in_delivery'

---

### After Step 4: Inspection
```sql
-- purchase_requests
UPDATE purchase_requests 
SET status='inspected',           -- Changed from 'in_delivery'
    inspection_notes='...',
    inspection_date=NOW(),
    inspected_by=2
WHERE id=10

-- workflow_history
INSERT INTO workflow_history (
  pr_id=10,
  status_from='in_delivery',
  status_to='inspected',
  action_by=2,
  action_type='inspection_completed',
  action_date=NOW()
)
```

**ViewEntries at this point**: Shows PR-2026-001 with status='inspected'

---

### After Step 5a: Property Tag Submission (NEW FLOW)
```sql
-- property_inventory
INSERT INTO property_inventory (
  pr_id=10,                       -- ★ Foreign key to purchase_requests
  pr_no='PR-2026-001',            -- Denormalized for quick lookup
  property_number='PROP-2026-001', -- Input by user
  model_number='Dell XPS-15',      -- Input
  description='5 units',           -- From PR
  serial_number='SN-12345',        -- Input
  unit_of_measure='pc',            -- From PR
  acquisition_date='2026-04-14',   -- Input
  supplier='Dell',                 -- Input
  estimated_cost=125000.00,        -- From PR total_amount
  location='IT Room',              -- Input
  status='serviceable',            -- Input
  created_by=3,
  created_at=NOW()
)
RESULT: property_id = 1

-- entries (★ NEW - Added to sync with legacy system)
INSERT INTO entries (
  Quantity=1,                      -- Set to 1 (single asset)
  Unit='pc',                       -- From property_inventory
  Amount=1,
  UnitCost=125000.00,              -- From property_inventory
  TotalCost=125000.00,             -- Same as UnitCost
  Description='5 units',           -- From property_inventory
  Item='Dell XPS-15',              -- From property_inventory (model_number)
  SerialNo='SN-12345',             -- From property_inventory
  DateAcquired='2026-04-14',       -- From property_inventory
  Location='IT Room',              -- From property_inventory
  InventoryItemNo='PROP-2026-001', -- ★ UNIQUE - From property_number (for lookup)
  EstimatedUsefulLife=NULL
)
RESULT: order_id = 50

-- workflow_history
INSERT INTO workflow_history (
  pr_id=10,
  status_to='completed',          -- Changed from 'inspected'
  action_by=3,
  action_type='property_tagged',
  notes='Property tagged as: PROP-2026-001',
  action_date=NOW()
)

-- purchase_requests
UPDATE purchase_requests 
SET status='completed'            -- Changed from 'inspected'
WHERE id=10
```

**ViewEntries at this point**: Shows PR-2026-001 with status='completed' PLUS PROP-2026-001 entry from entries table

---

## 🎯 ViewEntries Data Sources (HYBRID)

### Current Data Query Structure

```php
// get_entries.php queries PURCHASE_REQUESTS table
$sql = "SELECT 
  id AS order_id,
  pr_no,
  item_name AS Item,
  description AS Description,
  quantity AS Quantity,
  unit AS Unit,
  unit_cost AS UnitCost,
  total_amount AS TotalCost,
  office AS Location,
  status,
  created_at AS DateAcquired,
  created_by,
  form_type
FROM purchase_requests
WHERE [role-based filter]
ORDER BY created_at DESC"
```

### Result: Two Data Sources Feed ViewEntries

#### Source 1: FROM `purchase_requests` (Primary)
- All PRs regardless of form type (ICS/PPE/Property)
- Real-time status updates through entire workflow
- Shows PR lifecycle from draft → completed

#### Source 2: FROM `entries` (Legacy - Now Enhanced)
- Historically populated by manual form submission (submit.php)
- Now also populated by Property Tag completion (NEW)
- Provides catalog view of inventory items
- supports dedicated search/filter by InventoryItemNo

---

## 📈 Data Relationships Summary

| Relationship | From | To | Type | Purpose |
|---|---|---|---|---|
| PR → Workflow History | purchase_requests.id | workflow_history.pr_id | 1:∞ | Audit trail of all PR state changes |
| PR → Property Inventory | purchase_requests.id | property_inventory.pr_id | 1:0..1 | Link fixed asset to original PR |
| Property → Entries | property_inventory.property_number | entries.InventoryItemNo | 1:1 | Inventory synchronization |
| PR → User | purchase_requests.created_by | users.id | ∞:1 | Track PR creator |
| Workflow → User | workflow_history.action_by | users.id | ∞:1 | Track action performer |

---

## ✨ Workflow Completion States

### State 1: INCOMPLETE (Draft/Pending)
```
PR Status: draft/pending_approval/rejected
Property Entry: NONE
Workflow History: 1-2 steps
Result: ViewEntries shows PR only
```

### State 2: PARTIAL (ICS/PPE Form)
```
PR Status: inspected (waiting for form selection)
Property Entry: NONE (unless manually added)
Workflow History: 4-5 steps (create, approval, delivery, inspection, form)
Result: ViewEntries shows PR, awaiting form submission
```

### State 3: COMPLETE (Property Tag)
```
PR Status: completed
Property Entry: CREATED in property_inventory
Entries Entry: CREATED in entries table (NEW)
Workflow History: 6 steps (create, approval, delivery, inspection, property_tagged, completed)
Result: ViewEntries shows BOTH PR entry AND property inventory entry
```

---

## 🔗 URL Routes & Components

### Frontend Routes

| Route | Component | Purpose | Data Source |
|---|---|---|---|
| `/dashboard` | PanelContent | Main dashboard | Various |
| `/new-purchase-request` | NewPurchaseRequest | Create PR dialog | - |
| `/purchase-request` | PurchaseRequest | Full PR workflow (5 steps) | purchase_requests |
| `/property-inventory-tag` | PropertyInventoryTag | Property tag form | purchase_requests (via get_pr_details.php) |
| `/inventory-form-ics` | ICSForm | ICS form (< ₱50K) | purchase_requests |
| `/inventory-form-ppe` | PPEForm | PPE form (≥ ₱50K) | purchase_requests |
| Dashboard Panel | ViewEntries | Inventory view | entries + purchase_requests (via get_entries.php) |

---

## 🧪 Test Scenario

**Test Case**: Create complete PR → Property → Entries flow

```
1. Start: /dashboard
2. Click "New Purchase Request"
3. Enter values:
   - PR Name: PR-TEST-001
   - Item: Monitor
   - Qty: 2
   - Unit Cost: 30000 (Total: 60000)
   - Office: Finance
4. Auto-route to /purchase-request (form_type='ppe')
5. Complete 4 workflow steps
6. Approve form selection → Property Tag
7. Enter property details:
   - Property Number: PROP-TEST-001
   - Serial: SN-2026-001
   - Location: Finance Dept
8. Submit → Complete process
9. After redirect to /dashboard:
   - ViewEntries should show:
     a) PR-TEST-001 (from purchase_requests)
     b) PROP-TEST-001 (from entries table)
```

---

## ⚠️ Current Issues & Improvements

### Issue 1: Dual Data Sources
**Problem**: ViewEntries pulls from `purchase_requests` but property inventory data also goes to `entries` table.
**Impact**: Inconsistent inventory representation
**Status**: ✅ FIXED - Now synced via submit_property_tag.php inserting to entries table

### Issue 2: Form Type Mismatch
**Problem**: ICS form (< ₱50K) doesn't require property tag, but PPE/Property forms do.
**Impact**: Incomplete workflow for smaller items
**Status**: ⚠️ PENDING - ICS/PPE forms still point to entries table; need unified workflow

### Issue 3: Data Consistency
**Problem**: Property number uniqueness only enforced in property_inventory, but InventoryItemNo in entries.
**Impact**: Could create duplicate entries
**Status**: ✅ FIXED - UNIQUE constraint on InventoryItemNo prevents duplicates

---

## 📊 Current Data Count

Based on latest API test (PR-DIAG-20260414061507):

```
Database Statistics (as of 2026-04-14):
├── purchase_requests: 100+ records
├── workflow_history: 400+ historical entries
├── property_inventory: 50+ assets
├── entries: 65+ items (includes property tags + manual entries)
└── Status distribution:
    ├── draft: ~10 PRs
    ├── pending_approval: ~5 PRs
    ├── approved: ~20 PRs
    ├── in_delivery: ~15 PRs
    ├── inspected: ~20 PRs
    └── completed: ~30 PRs
```

---

**Analysis Complete** ✓  
Last Updated: April 14, 2026, 06:30 UTC  
System Status: ✅ Fully Operational

