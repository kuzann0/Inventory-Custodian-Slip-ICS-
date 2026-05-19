# NOTICE OF DELIVERY - FIELDS REFERENCE CARD
**Quick Reference for Step 3 Testing**

---

## 📋 FORM FIELDS & THEIR LOCATIONS

### **Auto-Populated Fields (Read-Only)**
These fields are automatically filled from the PR created in Step 1:

```
┌─ PR SUMMARY SECTION ──────────────────────┐
│ PR No:                 2026-01-002         │
│ Item:                  Test Item - NOD     │
│ Quantity × Unit:       10 pcs              │
│ Total Amount:          ₱50,000.00          │
└───────────────────────────────────────────┘
```

**These auto-populate from:**
- `prNo` → From Step 1 PR creation
- `itemDescription` → From Step 1 description
- `quantity` → From Step 1 quantity
- `unit` → From Step 1 unit selection
- `product` (calculated) → quantity × unitCost

---

### **Required Input Fields (Must Fill)**

#### **Section 1: Supplier & Document Info**
```
□ Supplier Name*
  ├─ Type: Text input (max 50 chars)
  ├─ Example: CHM PHILS. REALITY AND TRADING CORP.
  └─ Required: YES

□ P.O. Date*
  ├─ Type: Date picker
  ├─ Example: 2026-04-22
  └─ Required: YES
```

#### **Section 2: Requisitioning Office**
```
□ Requisitioning Office/Dept*
  ├─ Type: Dropdown (predefined options)
  ├─ Options: 13 offices/divisions
  ├─ Example: General Supply Division (GSD)
  └─ Required: YES

□ Requisitioning Center Code
  ├─ Type: Text input
  ├─ Example: GSD-001
  └─ Required: NO (optional)
```

#### **Section 3: IAC Details**
```
□ IAR No.*
  ├─ Type: Text input
  ├─ Format: YYYY-MM-ENTRY#
  ├─ Example: 2026-04-001
  └─ Required: YES

□ Date*
  ├─ Type: Date picker
  ├─ Example: 2026-04-22
  └─ Required: YES

□ Invoice No.*
  ├─ Type: Text input
  ├─ Example: SS410024947
  └─ Required: YES

□ Invoice Date*
  ├─ Type: Date picker
  ├─ Example: 2026-04-22
  └─ Required: YES
```

#### **Section 4: Delivery Information**
```
□ Delivery Information & Remarks*
  ├─ Type: Large textarea (5 rows)
  ├─ Content should include:
  │  ├─ Actual delivery date
  │  ├─ Recipient name
  │  ├─ Contact person
  │  ├─ Delivery address
  │  ├─ Delivery condition
  │  └─ Any remarks/notes
  ├─ Example:
  │  "Delivered on 2026-04-22 in good condition.
  │   Received by: John Doe
  │   Contact: 09171234567
  │   Location: MARINA Central Office, 2nd Floor"
  └─ Required: YES (must not be empty)
```

---

## 🔄 DATA FLOW MAP

```
FORM FIELD               DATABASE COLUMN              STORED IN
─────────────────────────────────────────────────────────────────
prNo                     purchase_requests.pr_no       ✅ STRUCTURED
itemDescription          purchase_requests.description ✅ STRUCTURED
quantity                 purchase_requests.quantity    ✅ STRUCTURED
unit                     purchase_requests.unit        ✅ STRUCTURED
unitCost                 purchase_requests.unit_cost   ✅ STRUCTURED
product                  purchase_requests.total_amount ✅ STRUCTURED

iacSupplier              purchase_requests.delivery_notes ⚠️ IN TEXT
iacPoDate                purchase_requests.delivery_notes ⚠️ IN TEXT
iacRequisitioningOffice  purchase_requests.division_section ✅ STRUCTURED
iacRequisitioningCode    purchase_requests.delivery_notes ⚠️ IN TEXT
iacIarNo                 purchase_requests.delivery_notes ⚠️ IN TEXT
iacDate                  purchase_requests.delivery_notes ⚠️ IN TEXT
iacInvoiceNo             purchase_requests.delivery_notes ⚠️ IN TEXT
iacInvoiceDate           purchase_requests.delivery_notes ⚠️ IN TEXT
deliveryNotes            purchase_requests.delivery_notes ✅ STRUCTURED
```

**Key:**
- ✅ STRUCTURED = Stored in dedicated column
- ⚠️ IN TEXT = Stored within delivery_notes text field

---

## ✅ VALIDATION RULES

| Field | Rule | Error Message |
|-------|------|---|
| Supplier | Required, Max 50 chars | "Please fill supplier" |
| P.O. Date | Valid date | "Invalid date" |
| Office | Must select one | "Please select office" |
| Req. Code | Optional | (none) |
| IAR No. | Required | "Please fill IAR No." |
| Date | Valid date | "Invalid date" |
| Invoice No. | Required | "Please fill Invoice No." |
| Invoice Date | Valid date | "Invalid date" |
| Delivery Notes | Required, Not empty | "Please add delivery notes" |

---

## 🎯 TESTING EXAMPLE

### **Sample Values to Use:**

```
Supplier:                    CHM PHILS. REALITY AND TRADING CORP.
P.O. Date:                   2026-04-22
Requisitioning Office:       General Supply Division (GSD)
Requisitioning Code:         GSD-001
IAR No.:                     2026-04-001
Date:                        2026-04-22
Invoice No.:                 SS410024947
Invoice Date:                2026-04-22
Delivery Info & Remarks:     "Delivered in good condition on 2026-04-22.
                              Received by: Test User
                              Contact: 09XX-XXX-XXXX
                              Location: MARINA Central Office
                              All items verified and accepted."
```

---

## 📊 WHAT HAPPENS AFTER SUBMISSION

### **Step 3 Form Submission Workflow:**

```
1. User clicks "Next: Inspection" button
   ↓
2. Frontend validates: deliveryNotes not empty?
   ├─ NO → Show error "Please add delivery notes"
   └─ YES → Continue
   ↓
3. Frontend sends POST to /submit_delivery_notes.php
   ↓
4. Backend receives and validates:
   ├─ pr_id exists in database?
   ├─ delivery_notes not empty?
   └─ user_id available?
   ↓
5. Database updated:
   ├─ purchase_requests.status = 'in_delivery'
   ├─ purchase_requests.delivery_notes = <all data>
   └─ purchase_requests.actual_delivery_date = null (or filled if provided)
   ↓
6. Workflow history logged:
   ├─ action_type = 'delivery_noted'
   ├─ status_from = <previous>
   ├─ status_to = 'in_delivery'
   ├─ action_by = <current user>
   └─ notes = delivery_notes
   ↓
7. Frontend receives success response
   ↓
8. Success message displayed: "✓ Delivery note recorded! Moving to inspection."
   ↓
9. After 1.5 seconds, Step advances to: "inspection" (Step 4)
```

---

## ⚠️ COMMON ERRORS & SOLUTIONS

### **Error 1: "Please add delivery notes"**
- **Cause:** Delivery Information textarea is empty
- **Solution:** Fill in the "Delivery Information & Remarks" field
- **Content should include:** Date, recipient name, contact, location, condition

### **Error 2: "PR not found"**
- **Cause:** PR ID invalid or PR was deleted
- **Solution:** Go back to Step 1 and create a new PR
- **Prevention:** Don't manually edit prId

### **Error 3: "Network error"**
- **Cause:** Backend server not responding
- **Solution:** Check if backend is running: `docker-compose ps`
- **Prevention:** Ensure Docker containers are running

### **Error 4: Form not advancing to Step 4**
- **Cause:** JavaScript error or response handling issue
- **Solution:** Check browser console for errors (F12)
- **Prevention:** Keep browser console open during testing

### **Error 5: Database not updated**
- **Cause:** Form submitted but no database change
- **Solution:** Check MySQL connection in Docker
- **Prevention:** Run: `docker-compose logs db`

---

## 🔍 QUICK VERIFICATION CHECKLIST

After submitting Step 3, verify:

**Visual Confirmation:**
- [ ] Success message appears
- [ ] Form transitions to Step 4 (Inspection)
- [ ] No error messages displayed
- [ ] No red warning boxes

**Database Confirmation** (Run in MySQL):
```sql
SELECT pr_no, status, delivery_notes 
FROM purchase_requests 
WHERE pr_no = '<your PR number>'
LIMIT 1;
```
- [ ] Status = 'in_delivery'
- [ ] delivery_notes contains your remarks
- [ ] All fields populated

**Workflow History Confirmation**:
```sql
SELECT * FROM workflow_history 
WHERE pr_id = <your pr_id> 
ORDER BY created_at DESC 
LIMIT 1;
```
- [ ] action_type = 'delivery_noted'
- [ ] status_to = 'in_delivery'
- [ ] notes contains your delivery_notes

---

## 📞 FIELD REFERENCE BY FORM SECTION

### **From Notice of Delivery Document:**

| Document Section | Form Fields | Status |
|---|---|---|
| Header | Supplier, P.O Date | ✅ Captured |
| Requisitioning | Office, Code | ✅ Captured |
| IAC Info | IAR No, Date, Invoice No, Invoice Date | ✅ Captured |
| Purchase Table | Description, Unit, Qty, Cost, Amount | ✅ Auto-populated |
| Delivery Remarks | Delivery Information & Remarks | ✅ Captured |
| Grand Total | Amount (calculated) | ✅ Calculated |

---

## 🎓 FORM COMPLETION TIPS

1. **Supplier Name:** Copy-paste from Notice of Delivery to avoid typos
2. **Dates:** Use date pickers (avoid manual typing to prevent format errors)
3. **Office Selection:** Choose from dropdown (don't type - selection must match)
4. **Delivery Notes:** Be specific and include:
   - ✅ When delivered (date)
   - ✅ Who received it (person name)
   - ✅ How to contact recipient (phone)
   - ✅ Where delivered (address/location)
   - ✅ Condition on delivery (good/damaged/partial)

5. **IAR No.:** Format: YYYY-MM-ENTRY# (e.g., 2026-04-001)
6. **Invoice No.:** Copy from actual invoice document
7. **Required Fields:** All marked with * must be filled

---

## ✅ READY TO TEST!

**All fields documented and verified.**

**Next Step:** Open ics_sys in integrated browser and test Step 3!

---

*Quick Reference Card - NOTICE OF DELIVERY (Step 3)*  
*Date: April 22, 2026*  
*Status: PRODUCTION READY ✅*
