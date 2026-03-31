import { useState } from "react";
import styles from './css/Navbar.module.css'
import dashboardIcon from './assets/admin_dashboard.svg';
import dataIcon from './assets/data_management.svg';
import auditIcon from './assets/audit.png';
import historyIcon from './assets/history.svg';
import addIcon from './assets/addEntry.svg';
import settingsIcon from './assets/settings.svg';
import collapseIcon from './assets/collapse_btn.png';

function Navbar() {
    const [collapsed, setCollapsed] = useState(false);
    const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

    const navItems = [
        { icon: dashboardIcon, label: "Dashboard", title: "View Dashboard" },
        { icon: dataIcon, label: "Data Management", title: "Manage Data" },
        { icon: auditIcon, label: "Audit Logs", title: "View Audit Logs" },
        { icon: historyIcon, label: "History", title: "View History" },
        { icon: addIcon, label: "Add Entry", title: "Add New Entry", id: "addEntry" },
        { icon: settingsIcon, label: "Settings", title: "Settings" },
    ];

    return (
        <>
            {/* Desktop Navbar */}
            <div className={`${styles.mainNav} ${collapsed ? styles.collapsed : ""}`}>
                <div className={styles.navWrapper}>
                    {/* Profile Section */}
                    <div className={styles.profileContainer}>
                        <div className={styles.profileWrapper}>
                            <div className={styles.profileInitial}>
                                {sessionStorage.getItem("username")?.charAt(0).toUpperCase() || "U"}
                            </div>
                            {!collapsed && (
                                <div className={styles.profileName}>
                                    {sessionStorage.getItem("username") || "User"}
                                </div>
                            )}
                        </div>
                    </div>

                    {/* Panel Section */}
                    <div className={styles.panelContainer}>
                        <div className={styles.panelWrapper}>
                            <div className={styles.panelContents}>
                                <ul>
                                    {navItems.map((item, idx) => (
                                        <li key={idx} className={styles.navItem}>
                                            <button
                                                className={`${styles.navButton} ${item.id === "addEntry" ? styles.addEntryBtn : ""}`}
                                                title={item.title}
                                                aria-label={item.label}
                                            >
                                                <img src={item.icon} alt={item.label} className={styles.icon} />
                                                {!collapsed && <span className={styles.label}>{item.label}</span>}
                                            </button>
                                            <div className={styles.tooltip}>{item.label}</div>
                                        </li>
                                    ))}
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Collapse Button */}
                <div className={styles.collapseBtnContainer}>
                    <button
                        className={styles.collapseBtn}
                        onClick={() => setCollapsed(!collapsed)}
                        title={collapsed ? "Expand" : "Collapse"}
                        aria-label="Toggle sidebar"
                    >
                        <img src={collapseIcon} alt="Toggle sidebar" className={styles.collapseBtnImg} />
                    </button>
                </div>
            </div>

            {/* Mobile Menu Button */}
            <div className={styles.mobilMenuToggle}>
                <button
                    className={styles.mobileMenuBtn}
                    onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                    title="Menu"
                    aria-label="Toggle menu"
                >
                    {mobileMenuOpen ? "✕" : "☰"}
                </button>
            </div>

            {/* Mobile Drawer */}
            {mobileMenuOpen && (
                <div className={styles.mobileDrawer}>
                    <div className={styles.mobileHeader}>
                        <h3>{sessionStorage.getItem("username") || "User"}</h3>
                        <button
                            className={styles.closeBtn}
                            onClick={() => setMobileMenuOpen(false)}
                            aria-label="Close menu"
                        >
                            ✕
                        </button>
                    </div>
                    <ul className={styles.mobileNavList}>
                        {navItems.map((item, idx) => (
                            <li key={idx}>
                                <button
                                    className={`${styles.mobileNavItem} ${item.id === "addEntry" ? styles.mobileAddEntry : ""}`}
                                    onClick={() => setMobileMenuOpen(false)}
                                >
                                    <img src={item.icon} alt={item.label} />
                                    <span>{item.label}</span>
                                </button>
                            </li>
                        ))}
                    </ul>
                </div>
            )}
        </>
    );
}

export default Navbar;


