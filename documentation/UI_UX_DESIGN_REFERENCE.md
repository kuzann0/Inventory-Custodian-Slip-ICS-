# UI/UX DESIGN REFERENCE GUIDE

## Visual Standards & Component Library

---

## 1. COLOR PALETTE OVERVIEW

### Primary Colors

```
Navy Blue (Primary Brand)
  Light    #5B6EC4  hsl(229, 75%, 38%)  - Hover states
  Main     #2C3E52  hsl(229, 75%, 28%)  - Logo, Headers, Buttons
  Dark     #1A2535  hsl(229, 75%, 18%)  - Active states
```

### Accent Colors

```
Purple (Highlights & Accents)
  Light    #A0AEF7  #667eea – 20% lighter
  Main     #667EEA  Used for: form focus, icons, highlights
  Dark     #4C5FC7  #667eea – 15% darker
```

### Semantic Colors

```
Success (Green)    #10B981    ✓ Confirmations
Warning (Amber)    #F59E0B    ⚠ Warnings
Danger (Red)       #EF4444    ✗ Errors, Destructive
Info (Blue)        #3B82F6    ℹ Information
```

### Grayscale

```
-50   #F9FAFB    Lightest (hover states, subtle bg)
-100  #F3F4F6    Off-white
-200  #E5E7EB    Light borders, dividers
-300  #D1D5DB    Medium borders
-400  #9CA3AF    Muted text
-500  #6B7280    Secondary text (use this for labels)
-600  #4B5563    Medium text
-700  #374151    Dark text
-800  #1F2937    Primary text (body copy)
-900  #111827    Darkest (rarely used)
```

---

## 2. TYPOGRAPHY SYSTEM

### Type Scale

```
H1  30px  bold    (Page titles)
H2  24px  bold    (Section headers)
H3  20px  semibold (Subsection headers)
H4  18px  semibold (Component headers)
H5  16px  semibold (Form labels, card titles)
H6  14px  semibold (Helper text, badges)

Body      14px  normal  (Default text)
Small     12px  normal  (Captions, hints)
Mono      14px  normal  (Code, data)
```

### Font Weight Usage

```
Light (300)      Rarely, large decorative text
Normal (400)     Body text
Medium (500)     Input placeholders, helper text
Semibold (600)   Form labels, section headers
Bold (700)       Headings, button text
Extrabold (800)  Large headings, emphasis
```

---

## 3. SPACING SCALE (8px Base)

```
4px   --space-1    Button padding (inside)
8px   --space-2    Small gaps, input spacing
12px  --space-3    Form group gaps
16px  --space-4    DEFAULT PADDING
20px  --space-5    Component padding
24px  --space-6    Section spacing
32px  --space-8    Large section gaps
40px  --space-10   Container padding
48px  --space-12   Extra large spacing
```

**Usage:**

- Buttons: `padding: 8px 16px` (--space-2 --space-4)
- Cards: `padding: 24px` (--space-6)
- Sections: `margin-bottom: 32px` (--space-8)
- Container: `padding: 40px` (--space-10)

---

## 4. COMPONENT LIBRARY

### 4.1 BUTTONS

```html
<!-- PRIMARY (Main Action) -->
<button class="btn btn-primary">Save Changes</button>
<button class="btn btn-primary btn-lg">Submit Form</button>
<button class="btn btn-primary btn-sm">OK</button>

<!-- SECONDARY (Alternative) -->
<button class="btn btn-secondary">Cancel</button>

<!-- DANGER (Destructive) -->
<button class="btn btn-danger">Delete</button>

<!-- SUCCESS (Positive) -->
<button class="btn btn-success">Confirm</button>

<!-- ACCENT (Highlight) -->
<button class="btn btn-accent">Special Action</button>

<!-- OUTLINE (Subtle Primary) -->
<button class="btn btn-outline">Learn More</button>

<!-- GHOST (Minimal) -->
<button class="btn btn-ghost">Skip</button>

<!-- DISABLED STATE -->
<button class="btn btn-primary" disabled>Loading...</button>
```

**Specifications:**

- Default Size: `padding: 12px 16px`, `font-size: 14px`
- Small: `padding: 8px 12px`, `font-size: 12px`
- Large: `padding: 16px 24px`, `font-size: 16px`
- Border Radius: `8px`
- Transition: `0.3s ease`

---

### 4.2 FORM INPUTS

```html
<!-- TEXT INPUT -->
<div class="form-group">
  <label class="form-label required">Full Name</label>
  <input type="text" class="form-input" placeholder="John Doe" />
  <div class="form-help">Enter your full legal name</div>
</div>

<!-- WITH ERROR -->
<div class="form-group">
  <label class="form-label required">Email</label>
  <input type="email" class="form-input error" value="invalid" />
  <div class="form-error">Invalid email format</div>
</div>

<!-- WITH SUCCESS -->
<div class="form-group">
  <label class="form-label">Username</label>
  <input type="text" class="form-input success" value="john_doe" />
  <div class="form-success">Username is available</div>
</div>

<!-- TEXTAREA -->
<div class="form-group">
  <label class="form-label">Description</label>
  <textarea placeholder="Enter description..." rows="4"></textarea>
</div>

<!-- SELECT -->
<div class="form-group">
  <label class="form-label required">Category</label>
  <select required>
    <option value="">Select a category...</option>
    <option value="1">Category 1</option>
    <option value="2">Category 2</option>
  </select>
</div>

<!-- CHECKBOX GROUP -->
<div class="checkbox-group">
  <div class="checkbox-item">
    <input type="checkbox" id="cb1" />
    <label for="cb1">Option 1</label>
  </div>
  <div class="checkbox-item">
    <input type="checkbox" id="cb2" />
    <label for="cb2">Option 2</label>
  </div>
</div>

<!-- RADIO GROUP -->
<div class="radio-group">
  <div class="radio-item">
    <input type="radio" id="rb1" name="choice" />
    <label for="rb1">Choice 1</label>
  </div>
  <div class="radio-item">
    <input type="radio" id="rb2" name="choice" />
    <label for="rb2">Choice 2</label>
  </div>
</div>
```

**Specifications:**

- Padding: `12px 16px`
- Border: `1px solid #E5E7EB`
- Border Radius: `8px`
- Focus: Blue outline + shadow
- Error: Red border + light red background
- Success: Green border + light green background

---

### 4.3 ALERTS/NOTIFICATIONS

```html
<!-- SUCCESS ALERT -->
<div class="alert alert-success">✓ Your entry has been saved successfully!</div>

<!-- ERROR ALERT -->
<div class="alert alert-error">⚠ Please fill in all required fields</div>

<!-- WARNING ALERT -->
<div class="alert alert-warning">⚠ This action cannot be undone</div>

<!-- INFO ALERT -->
<div class="alert alert-info">ℹ New inventory items are now available</div>
```

**Positioning:**

- Top of form: `margin: 0 0 24px 0`
- Inline with label: `margin-top: 4px`
- Auto-dismiss: `3000ms` for success/errors

---

### 4.4 CARDS/PANELS

```html
<!-- BASIC CARD -->
<div class="card">
  <h3>Card Title</h3>
  <p>Card content goes here...</p>
</div>

<!-- CARD WITH HEADER/FOOTER -->
<div class="card">
  <div class="card-header">
    <h3>Settings</h3>
    <button class="btn btn-ghost btn-sm">More</button>
  </div>

  <div class="card-body">
    <!-- Content here -->
  </div>

  <div class="card-footer">
    <button class="btn btn-secondary">Cancel</button>
    <button class="btn btn-primary">Save</button>
  </div>
</div>

<!-- CARD WITH SECTIONS -->
<div class="card">
  <div class="card-section">
    <h4 class="card-section-title">Personal Info</h4>
    <!-- Form fields -->
  </div>

  <div class="card-section">
    <h4 class="card-section-title">Contact Info</h4>
    <!-- Form fields -->
  </div>
</div>
```

**Specifications:**

- Padding: `24px`
- Border: `1px solid #E5E7EB`
- Border Radius: `12px`
- Shadow (rest): `0 1px 3px rgba(0, 0, 0, 0.1)`
- Shadow (hover): `0 10px 15px rgba(0, 0, 0, 0.1)`
- Background: White

---

### 4.5 TABLES

```html
<table class="table">
  <thead>
    <tr>
      <th>Item Name</th>
      <th>Serial Number</th>
      <th>Location</th>
      <th>Status</th>
      <th>Action</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Office Chair</td>
      <td>SN-2026-001</td>
      <td>Room 101</td>
      <td><span class="badge badge-success">Active</span></td>
      <td>
        <button class="btn btn-ghost btn-sm">Edit</button>
      </td>
    </tr>
  </tbody>
</table>
```

**Specifications:**

- Header: Gradient background (primary colors)
- Header Text: White, bold, pinned (sticky)
- Padding (cells): `16px`
- Border (bottom): `1px solid #E5E7EB`
- Row Hover: Light gray background
- Striping: Alternating rows (subtle)

---

## 5. LAYOUT STRUCTURE

### Desktop (>1024px)

```
┌─────────────────────────────────────────────┐
│         HEADER (Sticky, 72px height)        │
├──────────┬──────────────────────────────────┤
│          │  MAIN CONTENT AREA                │
│  NAVBAR  │  (with padding/margin)            │
│ (140px)  │                                   │
│          │  Max-width: 1400px                │
│          │  Padding: 40px                    │
│          │                                   │
└──────────┴──────────────────────────────────┘
```

### Tablet (768-1024px)

```
┌────────────────────────────────────┐
│    HEADER (Sticky, 72px)           │
├───┬──────────────────────────────┤
│   │  MAIN CONTENT AREA            │
│NAV│  (with adjusted padding)      │
│(90px)                             │
│   │                               │
│   │  Max-width: 1400px            │
│   │  Padding: 24px                │
└───┴──────────────────────────────┘
```

### Mobile (<768px)

```
┌───────────────────────────┐
│ HEADER (64px)             │
│ [☰] USER   [LOGOUT]       │
├───────────────────────────┤
│   MAIN CONTENT AREA       │
│   (Full width)            │
│   (No sidebar)            │
│   Padding: 16px           │
│                           │
│ (Drawer menu on tap ☰)    │
└───────────────────────────┘
```

---

## 6. BEFORE & AFTER COMPARISON

### Header Component

```
BEFORE:
┌────────────────────────────────────────────────┐
│ Inventory Custodian Slip | User • Role | Logout|  Inconsistent spacing
└────────────────────────────────────────────────────  Hardcoded colors
Gradient: #764ba2 (not in design system)

AFTER:
┌──────────────────────────────────────────────────┐
│ 📊 Inventory System    [Avatar] John Admin      │  Proper visual hierarchy
│ Manage items efficiently                         │  Design tokens used
│                              [🚪 Logout]         │  Semantic layout
└──────────────────────────────────────────────────┘
```

### Form Inputs

```
BEFORE:
[border-radius: 5px] [No focus indication] [No state styling]
[Input]
Input                              No validation feedback
(Minimal styling, inconsistent)

AFTER:
[border-radius: 8px with focus shadow] [Clear states: success/error]
* Full Name                            (required indicator)
[Input] ← Blue outline on focus      (form helper text)
Email format incorrect ⚠             (error message with icon)
```

### Buttons

```
BEFORE:
[Button] [Button] [Button]           No consistent sizing or spacing
(Mismatched padding, colors)         No clear visual hierarchy
Different styles across pages

AFTER:
[Save Changes]  [Cancel]  [Delete]   Clear primary/secondary/danger
(Consistent padding: 12px 16px)      Unified transitions
Same styling everywhere               Hover/active states defined
```

---

## 7. ACCESSIBILITY CHECKLIST

- [ ] Color Contrast ≥ 4.5:1 (WCAG AA)
  - Text on primary: White on Navy ✓
  - Text on surface: Gray-900 on White ✓
- [ ] Focus States Visible
  - All interactive elements have focus indicator
  - Focus outline: 2px solid with offset
- [ ] Keyboard Navigation
  - Tab order logical
  - Buttons and inputs focusable
- [ ] Touch Targets
  - Minimum 44px × 44px (buttons, links)
  - Adequate spacing between clickables
- [ ] Semantic HTML
  - Proper heading hierarchy (h1 > h2 > h3)
  - Forms use `<label>` elements
  - Buttons use `<button>`, links use `<a>`
- [ ] Alt Text & Labels
  - All images have descriptive alt text
  - Form inputs have associated labels
  - Form errors clearly labeled

---

## 8. ANIMATION GUIDELINES

### Transition Speeds

```
Fast (150ms)     - Hover effects, micro interactions
Normal (300ms)   - Form submissions, modals, page transitions
Slow (500ms)     - Large layout changes, loading states
```

### Common Animations

```
Slide In/Out     - Drawers, dropdowns
Fade In/Out      - Overlays, alerts
Scale            - Button presses (98%)
Pulse            - Loading indicators
```

**Never disable transitions!** They aid readability and feedback.

---

## 9. RESPONSIVE TYPOGRAPHY SCALING

```css
/* Mobile: 14px base */
body {
  font-size: 14px;
}

/* Tablet: 14px base + larger headings */
@media (min-width: 768px) {
  body {
    font-size: 14px;
  }
  h1 {
    font-size: 28px;
  }
  h2 {
    font-size: 22px;
  }
}

/* Desktop: 16px base */
@media (min-width: 1024px) {
  body {
    font-size: 14px;
  }
  h1 {
    font-size: 30px;
  }
  h2 {
    font-size: 24px;
  }
}
```

---

## 10. COMPONENT USAGE EXAMPLES

### Form Page (EntryForm)

```html
<div class="container">
  <div class="card">
    <div class="card-header">
      <h1>Add New Inventory Item</h1>
      <p>Complete all required fields</p>
    </div>

    <!-- Alert section -->
    <div id="alerts"><!-- success/error alerts here --></div>

    <form class="form-grid-2">
      <!-- Section 1: Item Details -->
      <div class="card-section">
        <h3 class="card-section-title">Item Details</h3>
        <div class="form-group">
          <label class="form-label required">Item Name</label>
          <input type="text" placeholder="e.g., Office Chair" />
        </div>
        <!-- More fields... -->
      </div>

      <!-- Section 2: Quantity Info -->
      <div class="card-section">
        <h3 class="card-section-title">Quantity Info</h3>
        <div class="form-group">
          <label class="form-label">Quantity</label>
          <input type="number" />
        </div>
        <!-- More fields... -->
      </div>
    </form>

    <div class="card-footer">
      <button class="btn btn-secondary">Reset</button>
      <button class="btn btn-primary btn-lg">Submit</button>
    </div>
  </div>
</div>
```

### Data Table Page (ViewEntries)

```html
<div class="container">
  <div class="card">
    <div class="card-header">
      <h2>Inventory Entries</h2>
      <div class="btn-group">
        <input type="search" placeholder="Search..." class="form-input" />
        <button class="btn btn-secondary">Export CSV</button>
      </div>
    </div>

    <table class="table">
      <thead>
        <tr>
          <th>Item Name ↑</th>
          <th>Serial No.</th>
          <th>Location</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Office Chair</td>
          <td>SN-2026-001</td>
          <td>Room 101</td>
          <td><span class="badge badge-success">Active</span></td>
        </tr>
      </tbody>
    </table>

    <!-- Pagination -->
    <div class="card-footer">
      <button class="btn btn-secondary">← Previous</button>
      <span>Page 1 of 5</span>
      <button class="btn btn-secondary">Next →</button>
    </div>
  </div>
</div>
```

---

## 11. QUALITY ASSURANCE CHECKLIST

**Before Deployment:**

- [ ] Colors match design palette
- [ ] Spacing is consistent (8px grid)
- [ ] Typography follows scale (h1-h6, body)
- [ ] Buttons use unified classes
- [ ] Forms have proper validation states
- [ ] Focus states visible on all interactive elements
- [ ] Responsive tested: 375px, 768px, 1024px, 1280px
- [ ] Accessibility score ≥ 90 (Lighthouse)
- [ ] No console errors
- [ ] No conflicting CSS rules
- [ ] Animations smooth and purposeful
- [ ] Dark mode ready (tokens support it)

---

**Design System Version:** 1.0  
**Last Updated:** March 28, 2026  
**Reference:** Navbar-ICS-1 Unified Design  
**Status:** Ready for Production
