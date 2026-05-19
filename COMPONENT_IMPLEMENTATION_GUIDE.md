# React Component Implementation Guide
## Using Professional UI/UX Styles

---

## 📋 Table of Contents
1. [Component Structure](#component-structure)
2. [Button Patterns](#button-patterns)
3. [Form Components](#form-components)
4. [Data Table Components](#data-table-components)
5. [Modal Implementation](#modal-implementation)
6. [Notification System](#notification-system)
7. [Best Practices](#best-practices)

---

## Component Structure

### Import Statements
```jsx
import React, { useState, useEffect } from 'react';
import styles from './css/ViewEntries.module.css';
import enhancedStyles from './css/AdvancedUIPatterns.module.css';
import designSystem from './css/EnhancedSystemDesign.module.css';
```

### File Organization
```
src/
├── components/
│   ├── DataTable/
│   │   ├── DataTable.jsx
│   │   ├── TableHeader.jsx
│   │   ├── TableRow.jsx
│   │   └── Pagination.jsx
│   ├── Forms/
│   │   ├── FormInput.jsx
│   │   ├── FormGroup.jsx
│   │   └── FormButton.jsx
│   ├── Modals/
│   │   ├── Modal.jsx
│   │   └── ConfirmDialog.jsx
│   └── Notifications/
│       └── Toast.jsx
└── css/
    ├── EnhancedSystemDesign.module.css
    ├── AdvancedUIPatterns.module.css
    └── [component-specific styles]
```

---

## Button Patterns

### Primary Button
```jsx
// ✅ Correct Implementation
function PrimaryButton({ onClick, children, disabled = false, loading = false }) {
  return (
    <button
      className={`${enhancedStyles.buttonBase} ${enhancedStyles.buttonPrimary} ${
        loading ? enhancedStyles.buttonLoading : ''
      } ${disabled ? enhancedStyles.buttonDisabled : ''}`}
      onClick={onClick}
      disabled={disabled || loading}
      aria-busy={loading}
    >
      {loading ? (
        <>
          <span className={enhancedStyles.loadingSpinner} />
          Processing...
        </>
      ) : (
        children
      )}
    </button>
  );
}
```

### Button Variants
```jsx
// Primary
<button className={`${enhancedStyles.buttonBase} ${enhancedStyles.buttonPrimary}`}>
  Submit
</button>

// Secondary
<button className={`${enhancedStyles.buttonBase} ${enhancedStyles.buttonSecondary}`}>
  Cancel
</button>

// Small
<button className={`${enhancedStyles.buttonBase} ${enhancedStyles.buttonPrimary} ${enhancedStyles.buttonSmall}`}>
  OK
</button>

// Large
<button className={`${enhancedStyles.buttonBase} ${enhancedStyles.buttonPrimary} ${enhancedStyles.buttonLarge}`}>
  Get Started
</button>
```

---

## Form Components

### Form Field Wrapper
```jsx
function FormField({ label, error, success, helper, children }) {
  return (
    <div className={enhancedStyles.formFieldWrapper}>
      {label && (
        <label className={enhancedStyles.formLabel}>
          {label}
          {required && <span className={styles.required}> *</span>}
        </label>
      )}
      
      <div className={enhancedStyles.formInputWrapper}>
        {children}
      </div>
      
      {error && (
        <p className={enhancedStyles.formErrorText}>
          ⚠️ {error}
        </p>
      )}
      
      {success && (
        <p className={enhancedStyles.formSuccessText}>
          ✓ {success}
        </p>
      )}
      
      {helper && !error && (
        <p className={enhancedStyles.formHelperText}>
          {helper}
        </p>
      )}
    </div>
  );
}

// Usage
<FormField
  label="Email Address"
  error={errors.email}
  helper="We'll never share your email"
  required
>
  <input
    type="email"
    className={enhancedStyles.formInput}
    placeholder="your@email.com"
    onChange={(e) => setEmail(e.target.value)}
  />
</FormField>
```

### Input States
```jsx
// ✅ Valid Input
<input
  className={enhancedStyles.formInput}
  value={value}
  onChange={handleChange}
/>

// ❌ Error State
<input
  className={`${enhancedStyles.formInput} ${enhancedStyles.formInput}`}
  value={value}
  onChange={handleChange}
  aria-invalid="true"
/>

// ⏳ Disabled State
<input
  className={enhancedStyles.formInput}
  disabled
  value={value}
/>
```

---

## Data Table Components

### Table Implementation
```jsx
function DataTable({ columns, data, onRowClick, loading }) {
  const [sortConfig, setSortConfig] = useState({ key: null, direction: 'asc' });

  return (
    <div className={enhancedStyles.tableContainer}>
      <table className={enhancedStyles.table}>
        <thead>
          <tr>
            {columns.map((col) => (
              <th
                key={col.key}
                className={enhancedStyles.tableHeaderCell}
                onClick={() => handleSort(col.key)}
              >
                {col.label}
                {sortConfig.key === col.key && (
                  <span className={styles.sortIcon}>
                    {sortConfig.direction === 'asc' ? '↑' : '↓'}
                  </span>
                )}
              </th>
            ))}
          </tr>
        </thead>
        
        <tbody>
          {loading ? (
            <tr>
              <td colSpan={columns.length} className={enhancedStyles.tableCell}>
                <div className={enhancedStyles.loadingWrapper}>
                  <div className={enhancedStyles.loadingSpinner} />
                  <p className={enhancedStyles.loadingText}>Loading...</p>
                </div>
              </td>
            </tr>
          ) : data.length === 0 ? (
            <tr>
              <td colSpan={columns.length} className={enhancedStyles.tableCell}>
                <p className={styles.emptyStateText}>No data available</p>
              </td>
            </tr>
          ) : (
            data.map((row) => (
              <tr
                key={row.id}
                className={enhancedStyles.tableRow}
                onClick={() => onRowClick?.(row)}
              >
                {columns.map((col) => (
                  <td
                    key={`${row.id}-${col.key}`}
                    className={`${enhancedStyles.tableCell} ${
                      col.numeric ? enhancedStyles.tableCellNumber : ''
                    }`}
                  >
                    {col.render ? col.render(row[col.key], row) : row[col.key]}
                  </td>
                ))}
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
}

// Usage
<DataTable
  columns={[
    { key: 'name', label: 'Name' },
    { key: 'email', label: 'Email' },
    { key: 'status', label: 'Status', render: (value) => (
      <span className={enhancedStyles.badgeSuccess}>{value}</span>
    )},
  ]}
  data={users}
  onRowClick={handleRowClick}
  loading={isLoading}
/>
```

### Badge Components
```jsx
// Status Badge
<span className={enhancedStyles.badgeSuccess}>Active</span>
<span className={enhancedStyles.badgeWarning}>Pending</span>
<span className={enhancedStyles.badgeDanger}>Inactive</span>
<span className={enhancedStyles.badgeInfo}>Info</span>

// With Status Dot
<span className={enhancedStyles.badgeSuccess}>
  <span className={`${enhancedStyles.statusDot} ${enhancedStyles.statusDotActive}`} />
  Online
</span>
```

---

## Modal Implementation

### Basic Modal
```jsx
function Modal({ isOpen, onClose, title, children }) {
  if (!isOpen) return null;

  return (
    <div className={enhancedStyles.modalOverlay} onClick={onClose}>
      <div
        className={enhancedStyles.modal}
        onClick={(e) => e.stopPropagation()}
      >
        <div className={enhancedStyles.modalHeader}>
          <h2 className={enhancedStyles.modalTitle}>{title}</h2>
          <button
            className={enhancedStyles.modalCloseButton}
            onClick={onClose}
            aria-label="Close modal"
          >
            ✕
          </button>
        </div>
        
        <div className={enhancedStyles.modalContent}>
          {children}
        </div>
      </div>
    </div>
  );
}

// Usage
const [isModalOpen, setIsModalOpen] = useState(false);

<button onClick={() => setIsModalOpen(true)}>
  Open Modal
</button>

<Modal
  isOpen={isModalOpen}
  onClose={() => setIsModalOpen(false)}
  title="Create Item"
>
  <form>
    {/* Form content */}
  </form>
  
  <div className={enhancedStyles.modalFooter}>
    <button
      className={`${enhancedStyles.buttonBase} ${enhancedStyles.buttonSecondary}`}
      onClick={() => setIsModalOpen(false)}
    >
      Cancel
    </button>
    <button
      className={`${enhancedStyles.buttonBase} ${enhancedStyles.buttonPrimary}`}
      onClick={handleSubmit}
    >
      Create
    </button>
  </div>
</Modal>
```

---

## Notification System

### Toast/Alert Component
```jsx
function Toast({ type = 'info', message, onClose }) {
  useEffect(() => {
    const timer = setTimeout(onClose, 5000);
    return () => clearTimeout(timer);
  }, [onClose]);

  const icons = {
    success: '✓',
    error: '✕',
    warning: '⚠',
    info: 'ℹ',
  };

  return (
    <div className={`${enhancedStyles.notificationBase} ${enhancedStyles[`notification${type.charAt(0).toUpperCase() + type.slice(1)}`]}`}>
      <span className={enhancedStyles.notificationIcon}>
        {icons[type]}
      </span>
      
      <div className={enhancedStyles.notificationContent}>
        <p className={enhancedStyles.notificationMessage}>
          {message}
        </p>
      </div>
      
      <button
        className={enhancedStyles.notificationCloseButton}
        onClick={onClose}
        aria-label="Close notification"
      >
        ✕
      </button>
    </div>
  );
}

// Usage
const [notifications, setNotifications] = useState([]);

const showNotification = (message, type = 'info') => {
  const id = Date.now();
  setNotifications(prev => [...prev, { id, message, type }]);
  
  setTimeout(() => {
    setNotifications(prev => prev.filter(n => n.id !== id));
  }, 5000);
};

// In render
<div className="notifications-container">
  {notifications.map(notification => (
    <Toast
      key={notification.id}
      type={notification.type}
      message={notification.message}
      onClose={() => setNotifications(prev => prev.filter(n => n.id !== notification.id))}
    />
  ))}
</div>
```

---

## Best Practices

### 1. **Semantic HTML**
```jsx
✅ Correct
<button onClick={handler} className={styles.button}>Click</button>

❌ Incorrect
<div onClick={handler} className={styles.button}>Click</div>
```

### 2. **Accessibility**
```jsx
// Always include aria labels
<button aria-label="Close modal" onClick={onClose}>✕</button>

// Use aria-busy for loading states
<button aria-busy={isLoading}>{isLoading ? 'Loading...' : 'Submit'}</button>

// Use aria-invalid for error states
<input aria-invalid={hasError} aria-describedby={`error-${id}`} />
<span id={`error-${id}`}>{errorMessage}</span>
```

### 3. **Performance**
```jsx
// Use useMemo for expensive computations
const sortedData = useMemo(() => {
  return [...data].sort((a, b) => {
    if (sortConfig.direction === 'asc') {
      return a[sortConfig.key] - b[sortConfig.key];
    }
    return b[sortConfig.key] - a[sortConfig.key];
  });
}, [data, sortConfig]);

// Use useCallback for event handlers
const handleSort = useCallback((key) => {
  setSortConfig(prev => ({
    key,
    direction: prev.key === key && prev.direction === 'asc' ? 'desc' : 'asc',
  }));
}, []);
```

### 4. **Responsive Design**
```jsx
// Always test on multiple screen sizes
// Use CSS media queries for responsive layouts
// Ensure touch targets are at least 44x44px on mobile
// Test with reduced motion preference
```

### 5. **Animations**
```jsx
// Keep animations under 300ms for UI feedback
// Use cubic-bezier(0.2, 0, 0.38, 0.9) for smooth natural motion
// Respect prefers-reduced-motion
// Only animate performance-friendly properties (opacity, transform)
```

### 6. **Color Usage**
```jsx
// Always maintain sufficient contrast
// Don't rely solely on color to convey information
// Use semantic colors: success, warning, danger, info
// Support dark mode with @media (prefers-color-scheme: dark)
```

### 7. **Component Composition**
```jsx
// Break down complex components
// Keep components focused and single-responsibility
// Use composition over inheritance
// Pass down only necessary props

// Example: Button component family
<PrimaryButton />
<SecondaryButton />
<SmallButton />
<LargeButton />
<LoadingButton />
```

---

## Migration Checklist

When updating existing components to use the new styles:

- [ ] Import new CSS modules
- [ ] Replace old class names with new semantic ones
- [ ] Update button styling to use buttonBase + variant
- [ ] Update form inputs to use formInput with validation states
- [ ] Update tables with new tableContainer structure
- [ ] Add loading states with spinners
- [ ] Add empty states with appropriate messaging
- [ ] Update modals to use new modal structure
- [ ] Add notifications/toast system
- [ ] Test keyboard navigation
- [ ] Test with screen readers
- [ ] Test responsive design
- [ ] Test with reduced motion preference
- [ ] Performance audit

---

**Version**: 1.0  
**Last Updated**: May 19, 2026  
**Status**: Ready for Implementation
