# UI/UX IMPLEMENTATION GUIDE

## Ready-to-Apply Code for Unified Design System

---

## STEP 1: CREATE UNIFIED DESIGN TOKENS FILE

### File: `frontend/src/css/_design-tokens.css`

```css
/**
 * UNIFIED DESIGN TOKENS - Navbar-ICS-1 Reference
 * Single source of truth for all component styling
 * Updated: March 28, 2026
 */

:root {
  /* ========== COLOR TOKENS ========== */

  /* PRIMARY BRAND COLORS */
  --color-primary: hsl(229, 75%, 28%); /* Deep Navy - Main Brand */
  --color-primary-light: hsl(229, 75%, 38%); /* Light Navy - Hover */
  --color-primary-dark: hsl(229, 75%, 18%); /* Dark Navy - Active */

  /* GRADIENT COLORS (Navbar-ICS-1 Reference) */
  --color-gradient-start: hsl(229, 75%, 28%); /* Navy Start */
  --color-gradient-end: hsl(261, 80%, 40%); /* Purple End */

  /* SECONDARY/ACCENT COLORS */
  --color-accent: #667eea; /* Soft Purple - Highlights */
  --color-accent-light: #a0aef7; /* Light Purple - Hover */
  --color-accent-dark: #4c5fc7; /* Dark Purple - Active */

  /* SEMANTIC COLORS */
  --color-success: #10b981; /* Green - Success states */
  --color-success-light: #d1fae5; /* Light Green - Background */
  --color-success-dark: #059669; /* Dark Green - Text */

  --color-warning: #f59e0b; /* Amber - Warning states */
  --color-warning-light: #fef3c7; /* Light Amber - Background */
  --color-warning-dark: #d97706; /* Dark Amber - Text */

  --color-danger: #ef4444; /* Red - Error/Danger states */
  --color-danger-light: #fee2e2; /* Light Red - Background */
  --color-danger-dark: #dc2626; /* Dark Red - Text */

  --color-info: #3b82f6; /* Blue - Info states */
  --color-info-light: #dbeafe; /* Light Blue - Background */
  --color-info-dark: #1d4ed8; /* Dark Blue - Text */

  /* NEUTRAL GRAY SCALE */
  --color-white: #ffffff;
  --color-gray-50: #f9fafb;
  --color-gray-100: #f3f4f6;
  --color-gray-200: #e5e7eb;
  --color-gray-300: #d1d5db;
  --color-gray-400: #9ca3af;
  --color-gray-500: #6b7280;
  --color-gray-600: #4b5563;
  --color-gray-700: #374151;
  --color-gray-800: #1f2937;
  --color-gray-900: #111827;

  /* BACKGROUND COLORS */
  --background-page: #f5f7fa; /* Page background */
  --background-surface: #ffffff; /* Card/surface background */
  --background-surface-hover: #f9fafb; /* Surface hover state */

  /* TEXT COLORS */
  --text-primary: #1f2937; /* Primary text */
  --text-secondary: #6b7280; /* Secondary text */
  --text-tertiary: #9ca3af; /* Tertiary/muted text */
  --text-inverted: #ffffff; /* Text on dark backgrounds */

  /* BORDER COLORS */
  --border-color: #e5e7eb; /* Standard border */
  --border-color-dark: #d1d5db; /* Darker border */

  /* ========== SHADOWS ========== */
  --shadow-xs: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1), 0 2px 4px rgba(0, 0, 0, 0.06);
  --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.1), 0 4px 6px rgba(0, 0, 0, 0.05);
  --shadow-xl: 0 20px 25px rgba(0, 0, 0, 0.1), 0 10px 10px rgba(0, 0, 0, 0.04);
  --shadow-inset: inset 0 2px 4px rgba(0, 0, 0, 0.06);

  /* ========== TRANSITIONS ========== */
  --transition-fast: all 0.15s cubic-bezier(0.4, 0, 0.2, 1);
  --transition-normal: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  --transition-slow: all 0.5s cubic-bezier(0.4, 0, 0.2, 1);
  --transition-bounce: all 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55);

  /* ========== BORDER RADIUS ========== */
  --radius-xs: 4px;
  --radius-sm: 6px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-xl: 16px;
  --radius-2xl: 20px;
  --radius-full: 9999px;

  /* ========== TYPOGRAPHY ========== */

  /* Font Families */
  --font-sans:
    -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto", "Oxygen",
    sans-serif;
  --font-mono: "Menlo", "Monaco", "Courier New", monospace;

  /* Font Sizes - Mobile First */
  --text-xs: 12px; /* Extra small */
  --text-sm: 14px; /* Small - Default */
  --text-base: 16px; /* Base */
  --text-lg: 18px; /* Large */
  --text-xl: 20px; /* Extra Large */
  --text-2xl: 24px; /* 2XL */
  --text-3xl: 30px; /* 3XL */
  --text-4xl: 36px; /* 4XL */

  /* Font Weights */
  --weight-light: 300;
  --weight-normal: 400;
  --weight-medium: 500;
  --weight-semibold: 600;
  --weight-bold: 700;
  --weight-extrabold: 800;

  /* Line Heights */
  --leading-tight: 1.25;
  --leading-normal: 1.5;
  --leading-relaxed: 1.625;
  --leading-loose: 2;

  /* Letter Spacing */
  --tracking-tight: -0.02em;
  --tracking-normal: 0;
  --tracking-wide: 0.02em;

  /* ========== SPACING SCALE (8px base) ========== */
  --space-0: 0;
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-5: 20px;
  --space-6: 24px;
  --space-7: 28px;
  --space-8: 32px;
  --space-10: 40px;
  --space-12: 48px;
  --space-16: 64px;
  --space-20: 80px;

  /* ========== CONTAINER CONSTRAINTS ========== */
  --container-sm: 640px;
  --container-md: 768px;
  --container-lg: 1024px;
  --container-xl: 1280px;
  --container-2xl: 1400px;

  /* ========== LAYOUT CONSTANTS ========== */

  /* Navbar Dimensions */
  --navbar-width-desktop: 140px; /* Expanded */
  --navbar-width-desktop-collapsed: 80px; /* Collapsed */
  --navbar-width-tablet: 90px;
  --navbar-width-mobile: 0;

  /* Header Dimensions */
  --header-height: 72px;
  --header-height-mobile: 64px;

  /* Z-Index Stack */
  --z-hide: -1;
  --z-base: 0;
  --z-dropdown: 10;
  --z-sticky: 20;
  --z-fixed: 30;
  --z-modal-bg: 40;
  --z-modal: 50;
  --z-notification: 60;
  --z-tooltip: 70;
}

/* ========== RESPONSIVE OVERRIDES ========== */

/* Tablet: 768px+ */
@media (min-width: 768px) {
  :root {
    --text-xs: 13px;
    --text-sm: 15px;
    --text-base: 16px;
  }
}

/* Desktop: 1024px+ */
@media (min-width: 1024px) {
  :root {
    --text-xs: 12px;
    --text-sm: 14px;
    --text-base: 16px;
  }
}

/* Large Screens: 1280px+ */
@media (min-width: 1280px) {
  :root {
    --space-4: 18px;
    --space-6: 28px;
  }
}
```

---

## STEP 2: UPDATE GLOBAL index.css

```css
/* index.css - UPDATED */

@import "./css/_design-tokens.css";

/* ========== GLOBAL RESET ========== */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  transition: var(--transition-fast);
}

html,
body,
#root {
  width: 100%;
  height: 100%;
  font-family: var(--font-sans);
  background: var(--background-page);
  color: var(--text-primary);
}

body {
  line-height: var(--leading-normal);
  font-size: var(--text-sm);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

/* ========== TYPOGRAPHY ========== */

h1 {
  font-size: var(--text-3xl);
  font-weight: var(--weight-bold);
  line-height: var(--leading-tight);
  margin-bottom: var(--space-4);
}

h2 {
  font-size: var(--text-2xl);
  font-weight: var(--weight-bold);
  line-height: var(--leading-tight);
  margin-bottom: var(--space-3);
}

h3 {
  font-size: var(--text-xl);
  font-weight: var(--weight-semibold);
  line-height: var(--leading-normal);
  margin-bottom: var(--space-3);
}

h4 {
  font-size: var(--text-lg);
  font-weight: var(--weight-semibold);
  line-height: var(--leading-normal);
  margin-bottom: var(--space-2);
}

h5,
h6 {
  font-size: var(--text-base);
  font-weight: var(--weight-semibold);
  line-height: var(--leading-normal);
  margin-bottom: var(--space-2);
}

p {
  margin-bottom: var(--space-4);
}

/* ========== SCROLLBAR STYLING ========== */

::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  background: var(--color-gray-100);
}

::-webkit-scrollbar-thumb {
  background: var(--color-gray-400);
  border-radius: var(--radius-full);
}

::-webkit-scrollbar-thumb:hover {
  background: var(--color-gray-500);
}

/* ========== FOCUS VISIBLE (Accessibility) ========== */

:focus-visible {
  outline: 2px solid var(--color-accent);
  outline-offset: 2px;
}

/* ========== DASHBOARD LAYOUT ========== */

.dashboard-main {
  display: flex;
  min-height: 100vh;
  background: var(--background-page);
}

.dashboard-navbar {
  position: fixed;
  left: 0;
  top: 0;
  height: 100vh;
  width: var(--navbar-width-desktop);
  z-index: var(--z-fixed);
}

.dashboard-content {
  margin-left: var(--navbar-width-desktop);
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: auto;
}

/* Tablet: Collapse navbar */
@media (max-width: 1024px) {
  .dashboard-navbar {
    width: var(--navbar-width-tablet);
  }

  .dashboard-content {
    margin-left: var(--navbar-width-tablet);
  }
}

/* Mobile: Hide navbar */
@media (max-width: 768px) {
  .dashboard-navbar {
    width: var(--navbar-width-mobile);
  }

  .dashboard-content {
    margin-left: var(--navbar-width-mobile);
  }
}

/* ========== UTILITY CLASSES ========== */

.container {
  width: 100%;
  max-width: var(--container-2xl);
  margin: 0 auto;
  padding: 0 var(--space-4);
}

@media (min-width: 768px) {
  .container {
    padding: 0 var(--space-6);
  }
}

@media (min-width: 1024px) {
  .container {
    padding: 0 var(--space-8);
  }
}

/* Text Colors */
.text-primary {
  color: var(--text-primary);
}
.text-secondary {
  color: var(--text-secondary);
}
.text-tertiary {
  color: var(--text-tertiary);
}
.text-success {
  color: var(--color-success-dark);
}
.text-danger {
  color: var(--color-danger-dark);
}
.text-warning {
  color: var(--color-warning-dark);
}
.text-info {
  color: var(--color-info-dark);
}

/* Opacity Utilities */
.opacity-50 {
  opacity: 0.5;
}
.opacity-75 {
  opacity: 0.75;
}

/* Display Utilities */
.hidden {
  display: none;
}
.visible {
  display: block;
}

/* Cursor Utilities */
.cursor-pointer {
  cursor: pointer;
}
.cursor-default {
  cursor: default;
}
.cursor-not-allowed {
  cursor: not-allowed;
}
```

---

## STEP 3: UNIFIED BUTTON COMPONENT

### File: `frontend/src/css/_buttons.css`

```css
/**
 * UNIFIED BUTTON SYSTEM
 * Applied via .btn-* classes
 */

/* ========== BUTTON BASE ========== */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);

  padding: var(--space-3) var(--space-4);
  font-size: var(--text-sm);
  font-weight: var(--weight-medium);
  font-family: var(--font-sans);

  border: none;
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: var(--transition-fast);

  text-decoration: none;
  white-space: nowrap;
  user-select: none;

  /* Remove default button styles */
  appearance: none;
  -webkit-appearance: none;
  -moz-appearance: none;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  pointer-events: none;
}

.btn:active {
  transform: scale(0.98);
}

/* ========== BUTTON VARIANTS ========== */

/* PRIMARY BUTTON */
.btn-primary {
  background: var(--color-primary);
  color: var(--text-inverted);
  box-shadow: var(--shadow-sm);
}

.btn-primary:hover:not(:disabled) {
  background: var(--color-primary-dark);
  box-shadow: var(--shadow-md);
}

.btn-primary:active:not(:disabled) {
  background: var(--color-primary-dark);
  box-shadow: var(--shadow-sm);
}

/* SECONDARY BUTTON */
.btn-secondary {
  background: var(--color-gray-100);
  color: var(--text-primary);
  border: 1px solid var(--border-color);
  box-shadow: var(--shadow-xs);
}

.btn-secondary:hover:not(:disabled) {
  background: var(--color-gray-200);
  border-color: var(--border-color-dark);
}

.btn-secondary:active:not(:disabled) {
  background: var(--color-gray-100);
}

/* ACCENT BUTTON */
.btn-accent {
  background: var(--color-accent);
  color: var(--text-inverted);
  box-shadow: var(--shadow-sm);
}

.btn-accent:hover:not(:disabled) {
  background: var(--color-accent-dark);
  box-shadow: var(--shadow-md);
}

/* DANGER BUTTON */
.btn-danger {
  background: var(--color-danger);
  color: var(--text-inverted);
  box-shadow: var(--shadow-sm);
}

.btn-danger:hover:not(:disabled) {
  background: var(--color-danger-dark);
  box-shadow: var(--shadow-md);
}

/* SUCCESS BUTTON */
.btn-success {
  background: var(--color-success);
  color: var(--text-inverted);
  box-shadow: var(--shadow-sm);
}

.btn-success:hover:not(:disabled) {
  background: var(--color-success-dark);
  box-shadow: var(--shadow-md);
}

/* OUTLINE BUTTON */
.btn-outline {
  background: transparent;
  color: var(--color-primary);
  border: 2px solid var(--color-primary);
}

.btn-outline:hover:not(:disabled) {
  background: var(--color-primary);
  color: var(--text-inverted);
}

/* GHOST BUTTON (Minimal) */
.btn-ghost {
  background: transparent;
  color: var(--text-primary);
  border: none;
}

.btn-ghost:hover:not(:disabled) {
  background: var(--background-surface-hover);
}

/* ========== BUTTON SIZES ========== */

.btn-sm {
  padding: var(--space-2) var(--space-3);
  font-size: var(--text-xs);
}

.btn-lg {
  padding: var(--space-4) var(--space-6);
  font-size: var(--text-base);
}

.btn-icon {
  padding: var(--space-2);
  width: 36px;
  height: 36px;
}

.btn-icon.lg {
  width: 48px;
  height: 48px;
  padding: var(--space-3);
}

/* ========== BUTTON GROUPS ========== */

.btn-group {
  display: flex;
  gap: var(--space-2);
  flex-wrap: wrap;
}

.btn-group.vertical {
  flex-direction: column;
}

/* ========== ICON BUTTONS ========== */

.btn-icon-only {
  width: 40px;
  height: 40px;
  padding: 0;
  border-radius: var(--radius-full);
}
```

---

## STEP 4: UNIFIED FORM ELEMENTS

### File: `frontend/src/css/_forms.css`

```css
/**
 * UNIFIED FORM SYSTEM
 */

/* ========== INPUT/TEXTAREA/SELECT BASE ========== */

input[type="text"],
input[type="email"],
input[type="password"],
input[type="number"],
input[type="date"],
input[type="time"],
input[type="search"],
textarea,
select {
  width: 100%;
  padding: var(--space-3) var(--space-4);
  font-size: var(--text-sm);
  font-family: var(--font-sans);

  background: var(--background-surface);
  color: var(--text-primary);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);

  transition: var(--transition-fast);

  /* Remove default browser styling */
  appearance: none;
  -webkit-appearance: none;
  -moz-appearance: none;
}

/* Remove default dropdown arrow for select (Firefox) */
select {
  background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%236b7280' stroke-width='2'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e");
  background-repeat: no-repeat;
  background-position: right var(--space-2) center;
  background-size: 20px;
  padding-right: var(--space-8);
}

/* Placeholder styling */
input::placeholder,
textarea::placeholder {
  color: var(--text-tertiary);
}

/* Focus state */
input:focus,
textarea:focus,
select:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
  background: var(--background-surface);
}

/* Disabled state */
input:disabled,
textarea:disabled,
select:disabled {
  background: var(--color-gray-100);
  color: var(--text-tertiary);
  cursor: not-allowed;
  opacity: 0.6;
}

/* Error state */
input.error,
textarea.error,
select.error {
  border-color: var(--color-danger);
  background: var(--color-danger-light);
}

input.error:focus,
textarea.error:focus,
select.error:focus {
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
}

/* Success state */
input.success,
textarea.success,
select.success {
  border-color: var(--color-success);
  background: var(--color-success-light);
}

input.success:focus,
textarea.success:focus,
select.success:focus {
  box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
}

/* ========== FORM GROUP ========== */

.form-group {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  margin-bottom: var(--space-4);
}

.form-group:last-child {
  margin-bottom: 0;
}

/* ========== FORM LABEL ========== */

.form-label {
  font-size: var(--text-sm);
  font-weight: var(--weight-medium);
  color: var(--text-primary);
  display: flex;
  gap: var(--space-1);
  align-items: baseline;
}

.form-label.required::after {
  content: "*";
  color: var(--color-danger);
  font-weight: var(--weight-bold);
}

.form-label.optional::after {
  content: "(Optional)";
  color: var(--text-tertiary);
  font-size: var(--text-xs);
  font-weight: var(--weight-normal);
  margin-left: var(--space-1);
}

/* ========== FORM HELPER TEXT ========== */

.form-help {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  margin-top: var(--space-1);
  line-height: var(--leading-tight);
}

.form-error {
  font-size: var(--text-xs);
  color: var(--color-danger-dark);
  margin-top: var(--space-1);
  display: flex;
  gap: var(--space-1);
  align-items: flex-start;
}

.form-error::before {
  content: "⚠";
  flex-shrink: 0;
}

.form-success {
  font-size: var(--text-xs);
  color: var(--color-success-dark);
  margin-top: var(--space-1);
  display: flex;
  gap: var(--space-1);
  align-items: flex-start;
}

.form-success::before {
  content: "✓";
  flex-shrink: 0;
}

/* ========== FORM GRID LAYOUT ========== */

.form-grid {
  display: grid;
  gap: var(--space-4);
  margin-bottom: var(--space-6);
}

.form-grid-2 {
  grid-template-columns: 1fr 1fr;
}

.form-grid-3 {
  grid-template-columns: 1fr 1fr 1fr;
}

/* Mobile: Stack all columns */
@media (max-width: 768px) {
  .form-grid-2,
  .form-grid-3 {
    grid-template-columns: 1fr;
  }
}

/* Tablet: 2 columns */
@media (min-width: 768px) and (max-width: 1024px) {
  .form-grid-3 {
    grid-template-columns: 1fr 1fr;
  }
}

/* ========== CHECKBOX & RADIO ========== */

input[type="checkbox"],
input[type="radio"] {
  width: 18px;
  height: 18px;
  cursor: pointer;
  accent-color: var(--color-primary);
}

.checkbox-group,
.radio-group {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.checkbox-item,
.radio-item {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  cursor: pointer;
}

.checkbox-item label,
.radio-item label {
  cursor: pointer;
  margin-bottom: 0;
}

/* ========== FIELDSET ========== */

fieldset {
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  padding: var(--space-4);
  margin-bottom: var(--space-6);
}

legend {
  font-size: var(--text-base);
  font-weight: var(--weight-semibold);
  color: var(--text-primary);
  padding: 0 var(--space-2);
  margin-bottom: var(--space-3);
}
```

---

## STEP 5: APPLY TO NAVBAR.JSX

Replace color tokens in `frontend/src/css/Navbar.module.css`:

```css
/* Navbar.module.css - UPDATED */

@import "./_design-tokens.css";

.mainNav {
  display: flex;
  flex-direction: column;
  height: 100vh;
  width: var(--navbar-width-desktop);
  background: linear-gradient(
    180deg,
    var(--color-gradient-start) 0%,
    var(--color-gradient-end) 100%
  );
  color: var(--text-inverted);
  z-index: var(--z-fixed);
  box-shadow: var(--shadow-lg);
  overflow-y: auto;
  position: fixed;
  left: 0;
  top: 0;
  transition: var(--transition-normal);
}

.mainNav.collapsed {
  width: var(--navbar-width-desktop-collapsed);
}

/* Profile Section */
.profileContainer {
  padding: var(--space-6);
  text-align: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.profileInitial {
  width: 60px;
  height: 60px;
  border-radius: var(--radius-full);
  background: var(--color-accent);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: var(--text-xl);
  font-weight: var(--weight-bold);
  color: var(--text-inverted);
  margin: 0 auto var(--space-3);
}

/* Navigation Items */
.navButton {
  width: 100%;
  padding: var(--space-3) var(--space-4);
  background: transparent;
  border: none;
  color: var(--text-inverted);
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: var(--space-3);
  transition: var(--transition-normal);
  border-left: 4px solid transparent;
}

.navButton:hover {
  background: rgba(255, 255, 255, 0.1);
  border-left-color: var(--color-accent);
}

.navButton.active {
  background: rgba(255, 255, 255, 0.2);
  border-left-color: var(--color-accent);
}

/* Mobile Drawer */
.mobileDrawer {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100vh;
  background: var(--background-surface);
  z-index: var(--z-modal);
  animation: slideInLeft 0.3s var(--transition-normal);
}

@keyframes slideInLeft {
  from {
    transform: translateX(-100%);
  }
  to {
    transform: translateX(0);
  }
}
```

---

## STEP 6: APPLY TO HEADER.JSX

```css
/* Header.module.css - UPDATED */

@import "./_design-tokens.css";

.headerContainer {
  background: linear-gradient(
    135deg,
    var(--color-gradient-start) 0%,
    var(--color-gradient-end) 100%
  );
  color: var(--text-inverted);
  box-shadow: var(--shadow-lg);
  position: sticky;
  top: 0;
  z-index: var(--z-sticky);
  padding: var(--space-5) var(--space-6);
}

.headerContent {
  max-width: var(--container-2xl);
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: var(--space-8);
  flex-wrap: wrap;
}

.brandSection h1 {
  font-size: var(--text-2xl);
  font-weight: var(--weight-bold);
  margin: 0;
  color: var(--text-inverted);
}

/* User Section */
.userSection {
  display: flex;
  align-items: center;
  gap: var(--space-4);
  background: rgba(255, 255, 255, 0.1);
  padding: var(--space-3) var(--space-4);
  border-radius: var(--radius-lg);
  backdrop-filter: blur(10px);
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: var(--radius-full);
  background: var(--color-accent);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: var(--weight-bold);
  color: var(--text-inverted);
}

.logoutBtn {
  padding: var(--space-2) var(--space-3);
  background: rgba(255, 255, 255, 0.2);
  color: var(--text-inverted);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: var(--transition-fast);
  font-size: var(--text-sm);
  font-weight: var(--weight-medium);
}

.logoutBtn:hover {
  background: rgba(255, 255, 255, 0.3);
  border-color: rgba(255, 255, 255, 0.5);
}
```

---

## IMPLEMENTATION CHECKLIST

- [ ] Create `_design-tokens.css`
- [ ] Update `index.css` to import tokens
- [ ] Create `_buttons.css`
- [ ] Create `_forms.css`
- [ ] Update `Header.module.css`
- [ ] Update `Navbar.module.css`
- [ ] Update `EntryForm.module.css`
- [ ] Update `ViewEntries.module.css`
- [ ] Update `LoginForm.module.css`
- [ ] Test all responsive breakpoints
- [ ] Accessibility audit (contrast, focus states)
- [ ] Browser testing (Chrome, Firefox, Safari, Edge)

---

**Ready to implement! Copy and paste the files above, then test thoroughly before deploying.**
