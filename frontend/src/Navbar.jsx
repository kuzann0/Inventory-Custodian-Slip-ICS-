import { useState } from "react";
import { useNavigate } from "react-router-dom";
import styles from './css/Navbar.module.css'
import dashboardIcon from './assets/admin_dashboard.svg';
import dataIcon from './assets/data_management.svg';
import auditIcon from './assets/audit.png';
import historyIcon from './assets/history.svg';
import addIcon from './assets/addEntry.svg';
import settingsIcon from './assets/settings.svg';

function Navbar({ activePanel, setActivePanel, collapsed = false, setCollapsed = () => {} }) {
    const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
    const navigate = useNavigate();

    const handleLogout = () => {
        sessionStorage.clear();
        navigate('/');
    };

    const navItems = [
        { icon: dashboardIcon, label: "Dashboard", title: "View Dashboard", id: "dashboard" },
        { icon: dataIcon, label: "Data Management", title: "Manage Data", id: "dataManagement" },
        { icon: auditIcon, label: "Audit Logs", title: "View Audit Logs", id: "auditLogs" },
        { icon: historyIcon, label: "History", title: "View History", id: "history" },
        { icon: addIcon, label: "Add Entry", title: "Add New Entry", id: "addEntry" },
        { icon: settingsIcon, label: "Settings", title: "Settings", id: "settings" },
    ];

    const handlePanelClick = (panelId) => {
        if (panelId === "addEntry") {
            navigate('/new-purchase-request');
            setMobileMenuOpen(false);
        } else {
            setActivePanel(activePanel === panelId ? "dashboard" : panelId);
        }
    };

    return (
        <>
            {/* Desktop Navbar */}
            <div className={`${styles.mainNav} ${collapsed ? styles.collapsed : ""}`}>
                <div className={styles.navWrapper}>
                    {/* Profile Section */}
                    <div 
                        className={`${styles.profileContainer} ${activePanel === "profile" ? styles.profileActive : ""}`}
                        onClick={() => setActivePanel(activePanel === "profile" ? "dashboard" : "profile")}
                        style={{ cursor: "pointer" }}
                        title="Click to view profile"
                    >
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
                                                className={`${styles.navButton} ${item.id === "addEntry" ? styles.addEntryBtn : ""} ${activePanel === item.id ? styles.active : ""}`}
                                                title={item.title}
                                                aria-label={item.label}
                                                onClick={() => handlePanelClick(item.id)}
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

                        {/* Collapse Button Overlay - Fixed Position */}
                        <button
                            className={`${styles.collapseBtnOverlay} ${collapsed ? styles.collapsed : ""}`}
                            onClick={() => setCollapsed(!collapsed)}
                            title={collapsed ? "Expand sidebar" : "Collapse sidebar"}
                            aria-label="Toggle sidebar"
                        >
                            <span className={styles.arrow}></span>
                        </button>
                    </div>
                </div>

                {/* Bottom Controls - Logout Only */}
                <div className={styles.bottomControls}>
                    {/* Logout Button */}
                    <button
                        className={styles.logoutBtn}
                        onClick={handleLogout}
                        title="Logout"
                        aria-label="Logout"
                    >
                        {!collapsed && <span className={styles.logoutLabel}>Logout</span>}
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
                                    className={`${styles.mobileNavItem} ${item.id === "addEntry" ? styles.mobileAddEntry : ""} ${activePanel === item.id ? styles.active : ""}`}
                                    onClick={() => handlePanelClick(item.id)}
                                >
                                    <img src={item.icon} alt={item.label} />
                                    <span>{item.label}</span>
                                </button>
                            </li>
                        ))}
                    </ul>
                    <button
                        className={styles.mobileLogoutBtn}
                        onClick={handleLogout}
                    >
                        🚪 Logout
                    </button>
                </div>
            )}
        </>
    );
}

export default Navbar;
