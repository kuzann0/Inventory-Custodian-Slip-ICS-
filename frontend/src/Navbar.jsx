import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import styles from "./css/Navbar.module.css";

/* ── SVG Icon Library ──────────────────────────────────────── */
const Icons = {
  dashboard: (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <rect x="3" y="3" width="7" height="7" rx="1.5"/>
      <rect x="14" y="3" width="7" height="7" rx="1.5"/>
      <rect x="3" y="14" width="7" height="7" rx="1.5"/>
      <rect x="14" y="14" width="7" height="7" rx="1.5"/>
    </svg>
  ),
  data: (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <ellipse cx="12" cy="5" rx="9" ry="3"/>
      <path d="M3 5v4c0 1.66 4.03 3 9 3s9-1.34 9-3V5"/>
      <path d="M3 9v4c0 1.66 4.03 3 9 3s9-1.34 9-3V9"/>
      <path d="M3 13v4c0 1.66 4.03 3 9 3s9-1.34 9-3v-4"/>
    </svg>
  ),
  audit: (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
      <polyline points="14 2 14 8 20 8"/>
      <line x1="9" y1="13" x2="15" y2="13"/>
      <line x1="9" y1="17" x2="12" y2="17"/>
    </svg>
  ),
  history: (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <polyline points="12 8 12 12 14.5 14.5"/>
      <path d="M3.05 11a9 9 0 1 1 .5 4M3 16v-5h5"/>
    </svg>
  ),
  add: (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="9"/>
      <line x1="12" y1="8" x2="12" y2="16"/>
      <line x1="8" y1="12" x2="16" y2="12"/>
    </svg>
  ),
  settings: (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="3"/>
      <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>
    </svg>
  ),
  signout: (
    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
      <polyline points="16 17 21 12 16 7"/>
      <line x1="21" y1="12" x2="9" y2="12"/>
    </svg>
  ),
  chevronLeft: (
    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <polyline points="15 18 9 12 15 6"/>
    </svg>
  ),
  close: (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round">
      <line x1="18" y1="6" x2="6" y2="18"/>
      <line x1="6" y1="6" x2="18" y2="18"/>
    </svg>
  ),
  chevronRight: (
    <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <polyline points="9 18 15 12 9 6"/>
    </svg>
  ),
};

const NAV_ITEMS = [
  { icon: Icons.dashboard, label: "Dashboard",       id: "dashboard"      },
  { icon: Icons.data,      label: "Data Management", id: "dataManagement" },
  { icon: Icons.audit,     label: "Audit Logs",      id: "auditLogs"      },
  { icon: Icons.history,   label: "History",         id: "history"        },
  { icon: Icons.add,       label: "Add Entry",       id: "addEntry",  cta: true },
  { icon: Icons.settings,  label: "Settings",        id: "settings"       },
];

/* ── NavItem ─────────────────────────────────────────────────── */
function NavItem({ item, isActive, collapsed, onClick }) {
  const [hovered, setHovered] = useState(false);

  const btnClass = [
    styles.navButton,
    isActive && !item.cta ? styles.active : "",
    item.cta ? styles.addEntryBtn : "",
  ].filter(Boolean).join(" ");

  return (
    <li className={styles.navItem}>
      <button
        className={btnClass}
        onClick={onClick}
        onMouseEnter={() => setHovered(true)}
        onMouseLeave={() => setHovered(false)}
        aria-label={item.label}
        aria-current={isActive ? "page" : undefined}
        title={collapsed ? item.label : undefined}
      >
        {/* Active left pill */}
        {isActive && !item.cta && (
          <span className={styles.activeIndicator} aria-hidden="true" />
        )}

        {/* Icon */}
        <span className={`${styles.iconWrap} ${item.cta ? styles.ctaIconWrap : ""}`}>
          <span className={styles.icon}>{item.icon}</span>
        </span>

        {/* Label */}
        {!collapsed && (
          <span className={styles.label}>{item.label}</span>
        )}

        {/* Collapsed tooltip */}
        {collapsed && hovered && (
          <span className={styles.tooltip}>{item.label}</span>
        )}
      </button>
    </li>
  );
}

/* ── SignOutButton ───────────────────────────────────────────── */
function SignOutButton({ collapsed, onClick, isMobile = false }) {
  return (
    <button
      className={`${styles.logoutBtn} ${isMobile ? styles.logoutBtnMobile : ""}`}
      onClick={onClick}
      aria-label="Sign out"
    >
      <span className={styles.logoutIconWrap}>
        <span className={styles.icon}>{Icons.signout}</span>
      </span>
      {!collapsed && <span className={styles.logoutLabel}>Sign Out</span>}
    </button>
  );
}

/* ── Main Navbar ─────────────────────────────────────────────── */
export default function Navbar({
  activePanel = "dashboard",
  setActivePanel = () => {},
  collapsed = false,
  setCollapsed = () => {},
}) {
  const navigate = useNavigate();
  const [mobileOpen, setMobileOpen] = useState(false);

  const username = sessionStorage.getItem("username") || "User";
  const roleName = sessionStorage.getItem("role_name") || "Guest";
  const initial = username.charAt(0).toUpperCase();

  const handleLogout = () => {
    sessionStorage.clear();
    navigate("/");
  };

  const handlePanelClick = (id) => {
    if (id === "addEntry") {
      navigate("/new-purchase-request");
      setMobileOpen(false);
    } else {
      setActivePanel(id);
      setMobileOpen(false);
    }
  };

  // Lock body scroll when mobile drawer open
  useEffect(() => {
    document.body.style.overflow = mobileOpen ? "hidden" : "";
    return () => { document.body.style.overflow = ""; };
  }, [mobileOpen]);

  /* ── Shared sidebar inner content ── */
  const SidebarContent = ({ isMobile = false }) => (
    <>
      {/* Profile */}
      <button
        className={styles.profileContainer}
        onClick={() => { handlePanelClick("profile"); }}
        aria-label="View profile"
        aria-pressed={activePanel === "profile"}
      >
        <div className={styles.avatarRing}>
          <div className={styles.avatarInner}>
            <span className={styles.profileInitial}>{initial}</span>
          </div>
        </div>
        {(!collapsed || isMobile) && (
          <div className={styles.profileMeta}>
            <span className={styles.profileName}>{username}</span>
            <span className={styles.profileRole}>{roleName}</span>
          </div>
        )}
      </button>

      <div className={styles.divider} />

      {/* Nav list */}
      <div className={styles.panelContainer}>
        <ul className={styles.navList}>
          {NAV_ITEMS.map((item) => (
            <NavItem
              key={item.id}
              item={item}
              isActive={activePanel === item.id}
              collapsed={collapsed && !isMobile}
              onClick={() => handlePanelClick(item.id)}
            />
          ))}
        </ul>
      </div>

      {/* Sign out */}
      <div className={styles.bottomControls}>
        <div className={styles.divider} />
        <SignOutButton
          collapsed={collapsed && !isMobile}
          onClick={handleLogout}
          isMobile={isMobile}
        />
      </div>
    </>
  );

  return (
    <>
      {/* ── Keyframes ── */}
      <style>{`
        @keyframes nb-tooltipIn {
          from { opacity: 0; transform: translateY(-50%) translateX(-5px); }
          to   { opacity: 1; transform: translateY(-50%) translateX(0); }
        }
        @keyframes nb-overlayIn {
          from { opacity: 0; }
          to   { opacity: 1; }
        }
      `}</style>

      {/* ── Desktop Sidebar ── */}
      <nav
        aria-label="Main navigation"
        className={`${styles.mainNav} ${collapsed ? styles.collapsed : ""}`}
      >
        {/* Top accent line */}
        <div className={styles.accentLine} />

        {/* Content wrapper */}
        <div className={styles.navWrapper}>
          <SidebarContent />
        </div>

        {/* Collapse toggle */}
        <button
          className={`${styles.collapseBtn} ${collapsed ? styles.collapseBtnCollapsed : ""}`}
          onClick={() => setCollapsed(!collapsed)}
          aria-label={collapsed ? "Expand sidebar" : "Collapse sidebar"}
          aria-expanded={!collapsed}
          title={collapsed ? "Expand sidebar" : "Collapse sidebar"}
        >
          <span className={styles.chevron}>{Icons.chevronLeft}</span>
        </button>
      </nav>

      {/* ── Mobile Hamburger ── */}
      <div className={styles.mobileToggleWrap}>
        <button
          className={`${styles.mobileMenuBtn} ${mobileOpen ? styles.mobileMenuBtnOpen : ""}`}
          onClick={() => setMobileOpen(!mobileOpen)}
          aria-label={mobileOpen ? "Close menu" : "Open menu"}
          aria-expanded={mobileOpen}
        >
          <span className={styles.hamburger}>
            <span /><span /><span />
          </span>
        </button>
      </div>

      {/* ── Mobile Overlay ── */}
      {mobileOpen && (
        <div
          className={styles.mobileOverlay}
          onClick={() => setMobileOpen(false)}
          aria-hidden="true"
        />
      )}

      {/* ── Mobile Drawer ── */}
      <div
        className={`${styles.mobileDrawer} ${mobileOpen ? styles.mobileDrawerOpen : ""}`}
        aria-hidden={!mobileOpen}
      >
        <div className={styles.accentLine} />

        {/* Drawer header — close button */}
        <div className={styles.mobileHeader}>
          <button
            className={styles.closeBtn}
            onClick={() => setMobileOpen(false)}
            aria-label="Close menu"
          >
            {Icons.close}
          </button>
        </div>

        <div className={styles.mobileContent}>
          <SidebarContent isMobile />
        </div>
      </div>
    </>
  );
}
