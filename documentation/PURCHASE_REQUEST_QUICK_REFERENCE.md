# Purchase Request Feature - Quick Reference

## 🎯 At a Glance

**Status**: ✅ FULLY IMPLEMENTED
**User Flow**: Sidebar "Add Entry" → Modal (name input) → Full PR Form
**Key Components**: `NewPurchaseRequest.jsx`, `PurchaseRequest.jsx`, `Navbar.jsx`

---

## 📁 Critical Files

| File                                                                                                | Purpose                                              | Lines    |
| --------------------------------------------------------------------------------------------------- | ---------------------------------------------------- | -------- |
| [frontend/src/Navbar.jsx](../frontend/src/Navbar.jsx)                                               | Sidebar "Add Entry" button                           | 20-68    |
| [frontend/src/NewPurchaseRequest.jsx](../frontend/src/NewPurchaseRequest.jsx)                       | Modal component                                      | 1-108    |
| [frontend/src/css/NewPurchaseRequest.module.css](../frontend/src/css/NewPurchaseRequest.module.css) | Modal styling                                        | Complete |
| [frontend/src/App.jsx](../frontend/src/App.jsx)                                                     | Routes `/new-purchase-request` & `/purchase-request` | 145-160  |
| [frontend/src/PurchaseRequest.jsx](../frontend/src/PurchaseRequest.jsx)                             | Full PR form                                         | 1-45     |

---

## 🔄 User Flow

```
Click "Add Entry"
    ↓
Modal page loads (/new-purchase-request)
    ↓
Enter PR name (3-100 chars)
    ↓
Press Enter or click "Create & Continue"
    ↓
Name saved → sessionStorage.new_pr_name
    ↓
Navigate to PR form (/purchase-request)
    ↓
PurchaseRequest.jsx reads sessionStorage
    ↓
Pre-fills PR name field
    ↓
User completes 5-step form
    ↓
Submit to database
```

---

## 💾 Data Flow

```
Modal Input → sessionStorage (key: 'new_pr_name')
                    ↓
            PurchaseRequest component
                    ↓
            Pre-fill form field (setPrNo)
                    ↓
            Submit API payload
                    ↓
            Backend: submit_purchase_request.php
                    ↓
            Database: purchase_requests table
```

---

## 🎨 Design Key Points

- **Modal**: Fixed overlay (rgba 0,0,0,0.5), centered white card, 500px max
- **Animations**: 0.3s fadeIn (overlay), slideUp (modal)
- **Colors**: Primary blue (#1f73e6), gray (#f8f9fa), red error (#d33b27)
- **Mobile**: Responsive breakpoint at 600px
- **Accessibility**: Auto-focus input, keyboard shortcuts (Enter/Esc)

---

## ✅ Validation Rules

```javascript
// Must pass all checks:
- ✓ Not empty
- ✓ Minimum 3 characters
- ✓ Maximum 100 characters
- ✓ Error message on invalid
- ✓ Submit button disabled until valid
```

---

## 🔌 API Integration

**Endpoint**: `backend/submit_purchase_request.php` (POST)

**Payload**:

```json
{
  "pr_no": "Office Supplies - April 2026",
  "item_name": "Item ID",
  "description": "Item description",
  "quantity": 10,
  "unit": "pieces",
  "unit_cost": 150.0,
  "office": "Main Office",
  "division_section": "IT Department"
}
```

**Response**: `{ success: true, pr_id: 123 }`

---

## 🔒 Security & Isolation

- ✅ Protected routes (requires session token)
- ✅ Own CSS module (no global pollution)
- ✅ sessionStorage only (no state pollution)
- ✅ Input validation on client & server
- ✅ No modifications to other components

---

## 🧪 Quick Test Steps

1. Start app: `npm run dev` (port 3000)
2. Login with credentials
3. Click "Add Entry" in sidebar
4. Enter name (e.g., "Office Supplies - April 2026")
5. Press Enter or click "Create & Continue"
6. Verify redirected to PR form with name pre-filled
7. Complete form and submit

---

## 🛠️ Common Edits

### Change Modal Title

**File**: NewPurchaseRequest.jsx, line 45

```jsx
<h2 className={styles.modalTitle}>Custom Title</h2>
```

### Adjust Min Character Length

**File**: NewPurchaseRequest.jsx, line 18

```jsx
if (trimmedName.length < 5) {  // Was: 3
```

### Change Primary Button Color

**File**: NewPurchaseRequest.module.css

```css
.create {
  background-color: #10b981; /* Green */
}
```

### Update Route Path

**File 1**: App.jsx, line 145: `path="/custom-path"`
**File 2**: Navbar.jsx, line 24: `navigate('/custom-path')`

---

## 🐛 Troubleshooting

| Issue                | Solution                                                     |
| -------------------- | ------------------------------------------------------------ |
| Modal not showing    | Check route in App.jsx, verify session token                 |
| Data not pre-filling | Check sessionStorage in DevTools, verify PurchaseRequest.jsx |
| Styling broken       | Clear browser cache (Ctrl+Shift+R), check CSS module import  |
| Navigation fails     | Verify React Router setup, check useNavigate hook            |
| Button doesn't work  | Ensure input has min 3 characters, check onClick handler     |

---

## 📊 Component Dependencies

```
App.jsx
├── Navbar.jsx
│   └── Navbar.module.css
├── NewPurchaseRequest.jsx
│   └── NewPurchaseRequest.module.css
└── PurchaseRequest.jsx
    └── PurchaseRequest.module.css
        └── submit_purchase_request.php (backend)
```

---

## 🎯 Key Constants

| Item               | Value     | Location |
| ------------------ | --------- | -------- |
| Modal Max Width    | 500px     | CSS      |
| Min Name Length    | 3 chars   | JS       |
| Max Name Length    | 100 chars | JS       |
| Animation Duration | 0.3s      | CSS      |
| Overlay Opacity    | 0.5 (50%) | CSS      |
| Primary Color      | #1f73e6   | CSS      |
| Z-Index            | 1000      | CSS      |

---

## 📋 Checklist for Custom Implementations

- [ ] Route configured in App.jsx
- [ ] Component exported/imported correctly
- [ ] CSS module imported in component
- [ ] Protected route applied
- [ ] sessionStorage keys documented
- [ ] Validation logic defined
- [ ] Error messages user-friendly
- [ ] Keyboard shortcuts supported
- [ ] Mobile responsive tested
- [ ] Database integration tested

---

## 🚀 Deployment Verification

```bash
# 1. Build frontend
npm run build

# 2. Check console for warnings/errors
# ✓ No CSS warnings
# ✓ No module warnings
# ✓ No console errors

# 3. Test in production build
npm run preview

# 4. Verify features
✓ Modal appears
✓ Input validation works
✓ Navigation succeeds
✓ Data pre-fills
✓ Form submits
```

---

**Quick Links**:

- [Full Implementation Guide](./PURCHASE_REQUEST_FEATURE_GUIDE.md)
- [Navbar Component](../frontend/src/Navbar.jsx)
- [Modal Component](../frontend/src/NewPurchaseRequest.jsx)
- [Form Component](../frontend/src/PurchaseRequest.jsx)
- [Routing Config](../frontend/src/App.jsx)

---

_Status: ✅ Production Ready_
_Last Updated: April 4, 2026_
