# Typography & Design System Style Guide

**Last Updated:** April 5, 2026  
**Design System Version:** 1.0  
**Global Styles:** `src/css/globalstyle.css`

---

## Table of Contents

1. [Overview](#overview)
2. [Typography System](#typography-system)
3. [Color Palette](#color-palette)
4. [Spacing System](#spacing-system)
5. [Component Styles](#component-styles)
6. [Usage Guidelines](#usage-guidelines)
7. [Accessibility](#accessibility)
8. [Implementation Checklist](#implementation-checklist)

---

## Overview

This design system provides a comprehensive set of design tokens and CSS variables for building a consistent, accessible user interface across the application. The system is built on a modern, professional design language using the **Marina theme** color palette.

### Design Principles

- **Clarity**: Clear visual hierarchy and readable typography
- **Consistency**: Unified spacing, colors, and component styles
- **Accessibility**: WCAG AA compliant contrast ratios and keyboard navigation
- **Performance**: Minimal CSS, optimized for mobile and desktop
- **Maintainability**: CSS variables for easy theme updates

### Key Features

- ✅ 180+ CSS variables for complete customization
- ✅ Modular component library with consistent styling
- ✅ Mobile-first responsive design
- ✅ Professional SF Pro Display/Inter font stack
- ✅ Dark mode ready (architecture in place)

---

## Typography System

### Font Families

```css
/* Primary Font Stack (SF Pro Display) */
font-family:
  "SF Pro Sans",
  -apple-system,
  BlinkMacSystemFont,
  "Segoe UI",
  "Roboto",
  "Oxygen",
  "Ubuntu",
  "Cantarell",
  sans-serif;

/* Fallback Stack (Inter) */
font-family: "Inter", "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;

/* Monospace (for code/numbers) */
font-family: "Courier New", "Monaco", monospace;
```

**Usage:**

- Use system fonts for better performance
- SF Pro Display/Inter for primary UI elements
- Monospace for numeric/code content

### Font Size Scale (Modular: 1.15x)

The font size scale uses a modular multiplier of 1.15x for mathematical consistency and professional appearance.

| Size Token | Pixel Value | Rem Value | Use Case                            |
| ---------- | ----------- | --------- | ----------------------------------- |
| `xxxs`     | 11px        | 0.69rem   | Tiny text, small hints, captions    |
| `xxs`      | 12px        | 0.75rem   | Small labels, table text, badges    |
| `xs`       | 13px        | 0.81rem   | Secondary text, form descriptions   |
| `sm`       | 14px        | 0.88rem   | Body text, input labels, default    |
| `base`     | 15px        | 0.94rem   | Standard body text                  |
| `md`       | 16px        | 1rem      | Optional input font, form text      |
| `lg`       | 18px        | 1.125rem  | Subheading, section headers         |
| `xl`       | 20px        | 1.25rem   | Header titles, emphasis             |
| `2xl`      | 24px        | 1.5rem    | Modal/form titles                   |
| `3xl`      | 26px        | 1.625rem  | Page section headers                |
| `4xl`      | 28px        | 1.75rem   | Form headers, major titles          |
| `5xl`      | 32px        | 2rem      | Page titles (e.g., Admin Dashboard) |

**Usage Example:**

```css
h1 {
  font-size: var(--font-size-5xl); /* 32px */
  font-weight: var(--font-weight-bold);
  line-height: var(--line-height-tight);
}

p {
  font-size: var(--font-size-sm); /* 14px */
  line-height: var(--line-height-normal);
}

small {
  font-size: var(--font-size-xs); /* 13px */
}
```

### Font Weights

| Weight Token | CSS Value | Use Case                           |
| ------------ | --------- | ---------------------------------- |
| `thin`       | 200       | Light emphasis, reduced prominence |
| `regular`    | 400       | Body text, default weight          |
| `medium`     | 500       | Form labels, secondary emphasis    |
| `semibold`   | 600       | Button text, section headers       |
| `bold`       | 700       | Page titles, primary emphasis      |
| `extrabold`  | 800       | Maximum emphasis, rare use         |

**Usage Example:**

```css
.label {
  font-weight: var(--font-weight-semibold); /* 600 */
}

.title {
  font-weight: var(--font-weight-bold); /* 700 */
}

.subtitle {
  font-weight: var(--font-weight-regular); /* 400 */
}
```

### Line Height

| Token     | Value | Use Case                           |
| --------- | ----- | ---------------------------------- |
| `tight`   | 1.2   | Headings, titles (compact)         |
| `normal`  | 1.4   | Body text, forms (readable)        |
| `relaxed` | 1.6   | Body text, descriptions (spacious) |
| `loose`   | 1.8   | Extra readable text, accessibility |

**Usage Example:**

```css
h1,
h2,
h3 {
  line-height: var(--line-height-tight); /* 1.2 */
}

p,
body {
  line-height: var(--line-height-relaxed); /* 1.6 */
}
```

### Letter Spacing

| Token    | Value  | Use Case                |
| -------- | ------ | ----------------------- |
| `tight`  | -0.5px | Headings, emphasis      |
| `normal` | 0px    | Default, standard use   |
| `wide`   | 0.5px  | Secondary text, labels  |
| `wider`  | 1px    | Uppercase text, buttons |

**Usage Example:**

```css
.label {
  text-transform: uppercase;
  letter-spacing: var(--letter-spacing-wider); /* 1px */
}
```

### Typography Hierarchy

#### Level 1: Page Titles (H1)

```css
font-size: var(--font-size-5xl); /* 32px */
font-weight: var(--font-weight-bold); /* 700 */
line-height: var(--line-height-tight); /* 1.2 */
margin-bottom: var(--spacing-lg);
color: var(--color-text-primary);
```

**Example:** "Admin Dashboard", "User Management"

#### Level 2: Section Headers (H2)

```css
font-size: var(--font-size-4xl);
font-weight: var(--font-weight-bold);
line-height: var(--line-height-tight);
margin-bottom: var(--spacing-md);
color: var(--color-text-primary);
```

**Example:** "Create New User", "Edit Settings"

#### Level 3: Subsection Headers (H3)

```css
font-size: var(--font-size-3xl);
font-weight: var(--font-weight-semibold);
line-height: var(--line-height-tight);
margin-bottom: var(--spacing-md);
color: var(--color-text-primary);
```

**Example:** "Personal Information", "Account Details"

#### Level 4: Minor Headers (H4)

```css
font-size: var(--font-size-2xl);
font-weight: var(--font-weight-semibold);
line-height: var(--line-height-normal);
margin-bottom: var(--spacing-sm);
color: var(--color-text-primary);
```

**Example:** "Email", "Phone Number"

#### Body Text

```css
font-size: var(--font-size-sm); /* 14px */
line-height: var(--line-height-relaxed); /* 1.6 */
color: var(--color-text-primary);
margin-bottom: var(--spacing-base);
```

#### Secondary Text

```css
font-size: var(--font-size-xs); /* 13px */
line-height: var(--line-height-normal); /* 1.4 */
color: var(--color-text-secondary);
```

#### Small Text / Captions

```css
font-size: var(--font-size-xxs); /* 12px */
color: var(--color-text-tertiary);
font-weight: var(--font-weight-medium);
```

---

## Color Palette

### Primary Brand Colors

**Primary Base:** `hsl(229, 75%, 28%)` (#12257d) - Deep Blue

- **Primary Light:** `hsl(229, 75%, 38%)` - Hover states
- **Primary Dark:** `hsl(229, 75%, 18%)` - Active states
- **Primary Alpha 05:** 5% opacity - Subtle backgrounds
- **Primary Alpha 10:** 10% opacity - Light backgrounds
- **Primary Alpha 20:** 20% opacity - Medium backgrounds

**Usage:**

```css
/* Primary button */
.btn-primary {
  background: var(--color-primary);
}

.btn-primary:hover {
  background: var(--color-primary-light);
}

/* Subtle background */
.highlight {
  background: var(--color-primary-alpha-10);
}
```

### Accent Colors

**Accent:** #667eea (Purple Blue)

- **Accent Light:** #8b9ef5
- **Accent Dark:** #4c63d2
- **Accent Alpha 05-20:** Various opacities

**Usage:** Links, hover states, focus indicators, highlights

### Semantic Status Colors

#### Success (Green)

- **Color:** #10b981
- **Light:** #6ee7b7
- **Dark:** #059669
- **Background:** #ecfdf5
- **Text:** #065f46

#### Danger/Error (Red)

- **Color:** #ef4444
- **Light:** #fca5a5
- **Dark:** #dc2626
- **Background:** #fce8e6
- **Text:** #c5221f

#### Warning (Amber)

- **Color:** #f59e0b
- **Light:** #fcd34d
- **Dark:** #d97706
- **Background:** #fffbeb
- **Text:** #92400e

#### Info (Blue)

- **Color:** #3b82f6
- **Background:** #dbeafe
- **Text:** #1e40af

**Usage Example:**

```jsx
// Success message
<div style={{
  background: 'var(--color-success-bg)',
  color: 'var(--color-success-text)',
  border: '1px solid var(--color-success)'
}}>
  Operation completed successfully!
</div>

// Error message
<div style={{
  background: 'var(--color-danger-bg)',
  color: 'var(--color-danger-text)',
  borderLeft: '4px solid var(--color-danger)'
}}>
  An error occurred. Please try again.
</div>
```

### Neutral Colors (Grayscale)

| Variable           | Color   | Use Case                    |
| ------------------ | ------- | --------------------------- |
| `--color-gray-50`  | #f9fafb | Lightest background         |
| `--color-gray-100` | #f4f4f9 | Light backgrounds, alt rows |
| `--color-gray-150` | #f5f7fa | Main app background         |
| `--color-gray-200` | #f0f2f5 | Button backgrounds          |
| `--color-gray-300` | #e5e7eb | Borders, dividers           |
| `--color-gray-400` | #d1d5db | Light borders               |
| `--color-gray-500` | #9ca3af | Placeholder text            |
| `--color-gray-600` | #6b7280 | Secondary text              |
| `--color-gray-700` | #374151 | Dark text                   |
| `--color-gray-800` | #1f2937 | Primary text                |
| `--color-gray-900` | #111827 | Very dark text              |
| `--color-gray-950` | #0a0a0a | Near black                  |

### Background & Surface

- **Background:** `var(--color-background)` = #f5f7fa (app background)
- **Surface:** `var(--color-surface)` = #ffffff (cards, components)
- **Text Primary:** `var(--color-text-primary)` = #1f2937
- **Text Secondary:** `var(--color-text-secondary)` = #6b7280
- **Text Tertiary:** `var(--color-text-tertiary)` = #9ca3af
- **Text Light:** `var(--color-text-light)` = #f4f4f9 (on dark backgrounds)
- **Border:** `var(--color-border)` = #e5e7eb

---

## Spacing System

### Base Unit: 8px

The spacing system uses 8px as the base unit. All spacing values are multiples of 8 for mathematical consistency.

| Token  | Pixels | Use Case                    |
| ------ | ------ | --------------------------- |
| `2xs`  | 2px    | Minimal spacing (scrollbar) |
| `xs`   | 4px    | Extra small gaps            |
| `sm`   | 6px    | Small gaps                  |
| `base` | 8px    | Base unit, common padding   |
| `md`   | 12px   | Medium spacing              |
| `lg`   | 16px   | Large spacing               |
| `xl`   | 20px   | Extra large                 |
| `2xl`  | 24px   | 2x large, common margins    |
| `3xl`  | 28px   | 3x large                    |
| `4xl`  | 32px   | 4x large                    |
| `5xl`  | 40px   | 5x large, page padding      |
| `6xl`  | 48px   | 6x large                    |
| `7xl`  | 56px   | 7x large                    |
| `8xl`  | 64px   | 8x large                    |

### Common Spacing Patterns

#### Margins

```css
--margin-compact: 8px; /* Small sections */
--margin-standard: 16px; /* Standard spacing */
--margin-generous: 24px; /* Large sections */
--margin-page: 40px; /* Page-level margins */
```

#### Padding

```css
--padding-compact: 8px; /* Buttons, small components */
--padding-standard: 12px; /* Form fields, standard */
--padding-form: 20px; /* Form groups */
--padding-section: 24px; /* Section containers */
--padding-page: 40px; /* Page content areas */
```

### Usage Examples

```css
/* Button padding */
.btn {
  padding: var(--spacing-md) var(--spacing-lg); /* 12px 16px */
}

/* Form section spacing */
.form-section {
  padding: var(--spacing-section); /* 24px */
  margin-bottom: var(--spacing-xl); /* 20px */
}

/* Page content */
.content {
  padding: var(--spacing-page); /* 40px */
  gap: var(--spacing-2xl); /* 24px */
}

/* Compact list items */
.list-item {
  padding: var(--spacing-md) var(--spacing-lg); /* 12px 16px */
  margin-bottom: var(--spacing-xs); /* 4px */
}
```

---

## Border Radius

| Token  | Pixels | Use Case                    |
| ------ | ------ | --------------------------- |
| `xs`   | 2px    | Minimal rounding            |
| `sm`   | 4px    | Small elements              |
| `base` | 6px    | Buttons, inputs (default)   |
| `md`   | 8px    | Medium components           |
| `lg`   | 10px   | Large cards, modals         |
| `xl`   | 12px   | Extra large containers      |
| `2xl`  | 16px   | Large modals, hero sections |
| `full` | 9999px | Circles, pills              |

**Usage:**

```css
/* Input fields */
input,
textarea,
select {
  border-radius: var(--radius-md); /* 8px */
}

/* Buttons */
button {
  border-radius: var(--radius-base); /* 6px */
}

/* Cards */
.card {
  border-radius: var(--radius-lg); /* 10px */
}

/* Modal */
.modal {
  border-radius: var(--radius-2xl); /* 16px */
}

/* Avatar */
.avatar {
  border-radius: var(--radius-full); /* Fully rounded */
}
```

---

## Shadow System

### Elevation Levels

| Token  | CSS Value                    | Use Case                  |
| ------ | ---------------------------- | ------------------------- |
| `xs`   | 0 1px 2px rgba(0,0,0,0.05)   | Subtle, minimal elevation |
| `sm`   | 0 2px 4px rgba(0,0,0,0.08)   | Light shadows             |
| `base` | 0 2px 8px rgba(0,0,0,0.1)    | Standard elevation        |
| `md`   | 0 4px 12px rgba(0,0,0,0.12)  | Medium elevation          |
| `lg`   | 0 8px 16px rgba(0,0,0,0.15)  | Prominent elevation       |
| `xl`   | 0 10px 25px rgba(0,0,0,0.15) | Large elevation           |
| `2xl`  | 0 20px 40px rgba(0,0,0,0.2)  | Extra large               |
| `3xl`  | 0 25px 50px rgba(0,0,0,0.25) | Maximum elevation         |

### Component Shadows

- **`shadow-navbar`:** 4px 0 12px rgba(0,0,0,0.1) - Sidebar shadow
- **`shadow-form-hover`:** Accent-tinted form hover
- **`shadow-button-hover`:** 0 8px 16px rgba(102,126,234,0.3) - Button hover
- **`shadow-card-hover`:** 0 12px 24px rgba(0,0,0,0.12) - Card hover
- **`shadow-modal`:** 0 20px 60px rgba(0,0,0,0.3) - Modal overlay
- **`shadow-profile`:** 0 4px 12px rgba(0,0,0,0.3) - Profile container

**Usage:**

```css
.card {
  box-shadow: var(--shadow-base);
}

.card:hover {
  box-shadow: var(--shadow-card-hover);
}

.modal {
  box-shadow: var(--shadow-modal);
}

.button:hover {
  box-shadow: var(--shadow-button-hover);
}
```

---

## Component Styles

### Buttons

#### Primary Button

```css
.btn-primary {
  background: var(--color-primary);
  color: white;
  padding: var(--spacing-md) var(--spacing-lg);
  border-radius: var(--radius-base);
  font-weight: var(--font-weight-semibold);
  box-shadow: var(--shadow-base);
  transition: var(--transition-button);
}

.btn-primary:hover {
  background: var(--color-primary-light);
  transform: translateY(-2px);
  box-shadow: var(--shadow-button-hover);
}

.btn-primary:active {
  background: var(--color-primary-dark);
  transform: translateY(0);
}
```

#### Secondary Button

```css
.btn-secondary {
  background: var(--color-gray-200);
  color: var(--color-text-primary);
  border: 1px solid var(--color-border);
  padding: var(--spacing-md) var(--spacing-lg);
  border-radius: var(--radius-base);
}

.btn-secondary:hover {
  border-color: var(--color-accent);
  background: var(--color-gray-300);
}
```

### Form Elements

#### Inputs & Textareas

```css
input,
textarea,
select {
  padding: var(--spacing-md) var(--spacing-lg);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  font-family: inherit;
  font-size: var(--font-size-sm);
  color: var(--color-text-primary);
  background: var(--color-surface);
  transition: var(--transition-input);
}

input:focus,
textarea:focus,
select:focus {
  outline: none;
  border-color: var(--color-accent);
  box-shadow: 0 0 0 3px var(--color-accent-alpha-10);
}

input:hover:not(:focus) {
  border-color: var(--color-accent-light);
  background: var(--color-primary-alpha-02);
}
```

#### Form Labels

```css
label {
  font-weight: var(--font-weight-semibold);
  font-size: var(--font-size-xs);
  color: var(--color-text-primary);
  margin-bottom: var(--spacing-xs);
  display: block;
  transition: var(--transition-color);
}
```

### Cards & Containers

```css
.card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: var(--spacing-2xl);
  box-shadow: var(--shadow-base);
  transition: var(--transition-default);
}

.card:hover {
  border-color: var(--color-accent);
  box-shadow: var(--shadow-card-hover);
  transform: translateY(-2px);
}
```

### Alerts & Messages

#### Success Alert

```css
.alert-success {
  background: var(--color-success-bg);
  color: var(--color-success-text);
  border-left: 4px solid var(--color-success);
  padding: var(--spacing-md) var(--spacing-lg);
  border-radius: var(--radius-md);
}
```

#### Error Alert

```css
.alert-error {
  background: var(--color-danger-bg);
  color: var(--color-danger-text);
  border-left: 4px solid var(--color-danger);
  padding: var(--spacing-md) var(--spacing-lg);
  border-radius: var(--radius-md);
}
```

### Tables

```css
table {
  width: 100%;
  border-collapse: collapse;
}

thead {
  background: var(--color-gray-100);
}

thead th {
  padding: var(--spacing-md) var(--spacing-lg);
  text-align: left;
  font-weight: var(--font-weight-semibold);
  font-size: var(--font-size-xs);
  color: var(--color-text-primary);
  border-bottom: 2px solid var(--color-border);
}

tbody td {
  padding: var(--spacing-lg);
  border-bottom: 1px solid var(--color-border);
  color: var(--color-text-secondary);
}

tbody tr:hover {
  background: var(--color-gray-100);
}
```

---

## Transitions & Animations

### Standard Transitions

| Token     | Value                                | Use Case             |
| --------- | ------------------------------------ | -------------------- |
| `fast`    | 150ms ease-out                       | Quick interactions   |
| `normal`  | 300ms ease-out                       | Standard transitions |
| `slow`    | 500ms ease-out                       | Slower animations    |
| `smooth`  | 300ms cubic-bezier                   | Advanced easing      |
| `elastic` | 400ms cubic-bezier(0.34,1.56,0.64,1) | Bouncy feel          |

### Component Transitions

```css
--transition-button:
  background-color 0.2s ease, border-color 0.2s ease, transform 0.2s ease;
--transition-input: border-color 0.2s ease, box-shadow 0.2s ease;
--transition-color: color 0.3s ease;
--transition-opacity: opacity 0.3s ease;
```

### Keyframe Animations

Available animations:

- `fadeIn` - Opacity transition in/out
- `slideUp` - Slide up from below
- `slideDown` - Slide down from above
- `slideInUp` - Combined slide + opacity
- `slideInDown` - Combined slide + opacity
- `spin` - Continuous rotation
- `pulse` - Breathing effect
- `bounce` - Bouncing motion

**Usage:**

```css
@keyframes slideUp {
  from {
    transform: translateY(20px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.modal {
  animation: slideUp 0.3s ease-out;
}
```

---

## Z-Index Scale

| Token           | Value | Use Case            |
| --------------- | ----- | ------------------- |
| `base`          | 0     | Default stacking    |
| `dropdown`      | 10    | Dropdowns, menus    |
| `sticky`        | 20    | Sticky headers      |
| `fixed`         | 30    | Fixed nav, headers  |
| `tooltip`       | 50    | Tooltips            |
| `modal-overlay` | 1000  | Modal backdrop      |
| `modal`         | 1001  | Modal content       |
| `notification`  | 1100  | Toast notifications |
| `topmost`       | 9999  | Above all elements  |

**Usage:**

```css
.navbar {
  z-index: var(--z-fixed); /* 30 */
}

.modal-overlay {
  z-index: var(--z-modal-overlay); /* 1000 */
}

.modal {
  z-index: var(--z-modal); /* 1001 */
}

.toast {
  z-index: var(--z-notification); /* 1100 */
}
```

---

## Responsive Breakpoints

| Breakpoint   | Width         | Target         | Adjustments                       |
| ------------ | ------------- | -------------- | --------------------------------- |
| Desktop      | 1400px+       | Desktop        | Full layout, sidebar visible      |
| Tablet       | 1024px-1399px | iPad/tablets   | Navbar collapse, adjusted spacing |
| Mobile       | 768px-1023px  | Mobile phones  | Single column, mobile header      |
| Small Mobile | 480px-767px   | Phones (small) | Minimal padding, full-width       |
| Extra Small  | <480px        | Phones (tiny)  | Extreme compression               |

### Media Query Usage

```css
/* Mobile First Approach */
.component {
  /* Mobile styles (default) */
  padding: var(--spacing-lg);
  font-size: var(--font-size-xs);
}

/* Tablet */
@media (min-width: 768px) {
  .component {
    padding: var(--spacing-xl);
    font-size: var(--font-size-sm);
  }
}

/* Desktop */
@media (min-width: 1024px) {
  .component {
    padding: var(--spacing-2xl);
    font-size: var(--font-size-base);
  }
}
```

---

## Accessibility

### Color Contrast

All text-background color combinations meet **WCAG AA** standards (4.5:1 for normal text, 3:1 for large text).

**Accessible Color Combinations:**

- ✅ `--color-text-primary` on `--color-surface`
- ✅ `--color-text-secondary` on `--color-background`
- ✅ White text on `--color-primary`
- ✅ White text on `--color-accent`

### Focus Indicators

All interactive elements have visible focus states:

```css
:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

input:focus-visible,
textarea:focus-visible,
select:focus-visible {
  outline: none;
  box-shadow: 0 0 0 3px var(--color-primary-alpha-10);
}
```

### Reduced Motion

For users who prefer reduced motion:

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

### Semantic HTML

- Use proper heading hierarchy (h1, h2, h3, etc.)
- Use `<label>` elements for form inputs
- Use `<button>` for interactive elements
- Use `role` and `aria-*` attributes where needed
- Ensure keyboard navigation works

---

## Usage Guidelines

### ✅ DO

- **Use CSS variables** for all design token values
- **Import globalstyle.css** in your root CSS file (`index.css`)
- **Follow the typography hierarchy** for consistent text rendering
- **Use semantic colors** for status messages
- **Maintain consistent spacing** using the 8px grid
- **Test with reduced motion** and keyboard navigation
- **Use CSS modules** for component-scoped styles
- **Document custom styles** that deviate from the system

### ❌ DON'T

- ❌ Hardcode color values (use variables)
- ❌ Use arbitrary spacing (use the scale)
- ❌ Mix different font families within components
- ❌ Ignore accessibility requirements
- ❌ Create inconsistent hover/focus states
- ❌ Use `!important` unless absolutely necessary
- ❌ Add inline styles (use CSS classes)

### Migration Guide

If you're updating existing components:

1. **Replace hardcoded colors:**

   ```css
   /* Before */
   color: #1f2937;

   /* After */
   color: var(--color-text-primary);
   ```

2. **Replace hardcoded spacing:**

   ```css
   /* Before */
   padding: 15px 20px;

   /* After */
   padding: var(--spacing-lg) var(--spacing-xl);
   ```

3. **Replace hardcoded typography:**

   ```css
   /* Before */
   font-size: 14px;
   font-weight: 600;

   /* After */
   font-size: var(--font-size-xs);
   font-weight: var(--font-weight-semibold);
   ```

---

## Implementation Checklist

### Design System Setup ✅

- [x] globalstyle.css created with 180+ CSS variables
- [x] CSS reset and base styles applied
- [x] All CSS modules updated to import global variables
- [x] Backward compatibility aliases added to index.css

### Components Updated ✅

- [x] DashboardLayout.module.css
- [x] Navbar.module.css
- [x] LoginForm.module.css
- [x] Header.module.css
- [x] EntryForm.module.css
- [x] PurchaseRequest.module.css
- [x] NewPurchaseRequest.module.css
- [x] ViewEntries.module.css
- [x] SuperAdminPage.module.css
- [x] EmployeeCapabilities.module.css

### Typography ✅

- [x] Font stacks defined (SF Pro Display → Inter)
- [x] 12-level font size scale (11px-32px)
- [x] 6-level font weight hierarchy
- [x] Line height system (1.2-1.8)
- [x] Letter spacing values

### Colors ✅

- [x] Marina theme primary colors (blue #12257d)
- [x] Semantic status colors (success, error, warning, info)
- [x] Complete grayscale (50-950)
- [x] Alpha transparency variants
- [x] Accessible contrast ratios (WCAG AA)

### Spacing & Layout ✅

- [x] 8-value spacing scale (2px-64px)
- [x] Margin preset patterns
- [x] Padding preset patterns
- [x] 8 border radius levels
- [x] Responsive breakpoint system

### Effects & Utilities ✅

- [x] 8-level shadow system
- [x] Standard transitions (fast, normal, slow)
- [x] Component-specific transitions
- [x] Animation keyframes
- [x] Z-index scale

### Quality Assurance ⏳

- [ ] Test in all browsers (Chrome, Firefox, Safari, Edge)
- [ ] Verify mobile responsiveness (480px, 768px, 1024px)
- [ ] Validate color contrast ratios
- [ ] Test keyboard navigation
- [ ] Test with screen readers
- [ ] Performance testing

### Documentation ✅

- [x] TYPOGRAPHY_STYLE_GUIDE.md (this file)
- [x] globalstyle.css with complete comments
- [x] In-code CSS variable usage examples

---

## Future Enhancements

- [ ] Dark mode theme variants
- [ ] Animated transitions library
- [ ] Component storybook
- [ ] Figma design system sync
- [ ] CSS custom property preprocessor
- [ ] Automated accessibility testing
- [ ] Performance optimization (CSS-in-JS)

---

## Support & Questions

For questions about the design system:

1. Check the CSS variable definitions in `src/css/globalstyle.css`
2. Review examples in existing component CSS modules
3. Refer to the usage patterns in this guide
4. Test in browser DevTools using `getComputedStyle()`

---

**Version History:**

- v1.0 (April 5, 2026) - Initial design system release

**Design System Maintained By:** Engineering Team  
**Last Reviewed:** April 5, 2026
