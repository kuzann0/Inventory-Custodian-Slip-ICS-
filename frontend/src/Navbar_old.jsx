import { useState } from "react";
import { useNavigate } from "react-router-dom";
import styles from './css/Navbar.module.css'
import dashboardIcon from './assets/admin_dashboard.svg';
import dataIcon from './assets/data_management.svg';
import auditIcon from './assets/audit.png';
import historyIcon from './assets/history.svg';
import addIcon from './assets/addEntry.svg';
import settingsIcon from './assets/settings.svg';
import collapseIcon from './assets/collapse_btn.png';

function Navbar({ activePanel, setActivePanel }) {
    const [collapsed, setCollapsed] = useState(false);
    const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
    const navigate = useNavigate();

    const navItems = [
        { icon: dashboardIcon, label: "Dashboard", title: "View Dashboard", id: "dashboard" },
        { icon: dataIcon, label: "Data Management", title: "Manage Data", id: "dataManagement" },
        { icon: auditIcon, label: "Audit Logs", title: "View Audit Logs", id: "auditLogs" },
        { icon: historyIcon, label: "History", title: "View History", id: "history" },
        { icon: addIcon, label: "Add Entry", title: "Add New Entry", id: "addEntry" },
        { icon: settingsIcon, label: "Settings", title: "Settings", id: "settings" },
    ];

    const handleLogout = () => {
        sessionStorage.clear();
        navigate('/');
    };

    const handlePanelClick = (panelId) => {
        // Navigation items that should navigate away
        if (panelId === "addEntry") {
            navigate('/new-purchase-request');
            setMobileMenuOpen(false);
        } else {
            // Inline panel items that toggle
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
                    </div>
                </div>

                {/* Panel Content Section */}
                {activePanel && (
                    <div className={styles.panelContentSection}>
                        {activePanel === "profile" && (
                            <div className={styles.panelContent}>
                                <h2 className={styles.panelTitle}>Profile</h2>
                                <div className={styles.panelBody}>
                                    <div className={styles.contentSection}>
                                        <div className={styles.profileInfo}>
                                            <div className={styles.profileAvatar}>
                                                {sessionStorage.getItem("username")?.charAt(0).toUpperCase() || "U"}
                                            </div>
                                            <div className={styles.profileDetails}>
                                                <p className={styles.profileField}>
                                                    <span className={styles.fieldLabel}>Username:</span>
                                                    <span>{sessionStorage.getItem("username") || "User"}</span>
                                                </p>
                                                <p className={styles.profileField}>
                                                    <span className={styles.fieldLabel}>Role:</span>
                                                    <span>{sessionStorage.getItem("role") || "User"}</span>
                                                </p>
                                                <p className={styles.profileField}>
                                                    <span className={styles.fieldLabel}>Status:</span>
                                                    <span className={styles.statusActive}>Active</span>
                                                </p>
                                            </div>
                                        </div>
                                    </div>
                                    <div className={styles.contentSection}>
                                        <h3 className={styles.sectionTitle}>Actions</h3>
                                        <div className={styles.actionList}>
                                            <button className={styles.actionButton} disabled title="Coming soon">Edit Profile</button>
                                            <button className={styles.actionButton} disabled title="Coming soon">Change Password</button>
                                            <button className={styles.actionButton} onClick={handleLogout}>Logout</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        )}
                        {activePanel === "dashboard" && (
                            <div className={styles.panelContent}>
                                <h2 className={styles.panelTitle}>Dashboard</h2>
                                <div className={styles.panelBody}>
                                    <div className={styles.contentSection}>
                                        <h3 className={styles.sectionTitle}>Overview</h3>
                                        <div className={styles.metricGrid}>
                                            <div className={styles.metricCard}>
                                                <div className={styles.metricLabel}>Total Entries</div>
                                                <div className={styles.metricValue}>{dashboardStats.totalEntries}</div>
                                            </div>
                                            <div className={styles.metricCard}>
                                                <div className={styles.metricLabel}>Pending</div>
                                                <div className={styles.metricValue}>{dashboardStats.pendingCount}</div>
                                            </div>
                                            <div className={styles.metricCard}>
                                                <div className={styles.metricLabel}>Completed</div>
                                                <div className={styles.metricValue}>{dashboardStats.completedCount}</div>
                                            </div>
                                        </div>
                                    </div>
                                    <div className={styles.contentSection}>
                                        <h3 className={styles.sectionTitle}>Performance</h3>
                                        <div className={styles.performanceList}>
                                            <p className={styles.performanceItem}>Average Processing Time: —</p>
                                            <p className={styles.performanceItem}>System Status: Operational</p>
                                            <p className={styles.performanceItem}>Last Updated: Today</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        )}

                        {activePanel === "dataManagement" && (
                            <div className={styles.panelContent}>
                                <h2 className={styles.panelTitle}>Data Management</h2>
                                <div className={styles.panelBody}>
                                    <div className={styles.contentSection}>
                                        <h3 className={styles.sectionTitle}>Operations</h3>
                                        <div className={styles.actionList}>
                                            <button className={styles.actionButton} onClick={() => navigate('/new-purchase-request')}>Create New Entry</button>
                                            <button className={styles.actionButton}>View All Entries</button>
                                            <button className={styles.actionButton}>Export Data</button>
                                        </div>
                                    </div>
                                    <div className={styles.contentSection}>
                                        <h3 className={styles.sectionTitle}>Recent Entries</h3>
                                        <div className={styles.tablePreview}>
                                            <div className={styles.tableHeader}>
                                                <span>Item</span>
                                                <span>Qty.</span>
                                                <span>Status</span>
                                            </div>
                                            {recentEntries.length > 0 ? (
                                                recentEntries.map((entry, idx) => (
                                                    <div key={idx} className={styles.tableRow}>
                                                        <span>{entry.Item || '—'}</span>
                                                        <span>{entry.Quantity || '—'}</span>
                                                        <span>{entry.status || '—'}</span>
                                                    </div>
                                                ))
                                            ) : (
                                                <div className={styles.tableRow}>
                                                    <span>—</span>
                                                    <span>—</span>
                                                    <span>—</span>
                                                </div>
                                            )}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        )}

                        {activePanel === "auditLogs" && (
                            <div className={styles.panelContent}>
                                <h2 className={styles.panelTitle}>Audit Logs</h2>
                                <div className={styles.panelBody}>
                                    <div className={styles.contentSection}>
                                        <h3 className={styles.sectionTitle}>Transaction Tracking</h3>
                                        <div className={styles.logList}>
                                            <div className={styles.logItem}>
                                                <span className={styles.logTime}>Timestamp</span>
                                                <span className={styles.logAction}>Action</span>
                                                <span className={styles.logUser}>User</span>
                                            </div>
                                            {auditLogs.length > 0 ? (
                                                auditLogs.map((log, idx) => (
                                                    <div key={idx} className={styles.logItem}>
                                                        <span className={styles.logTime}>{log.timestamp ? new Date(log.timestamp).toLocaleTimeString() : '—'}</span>
                                                        <span className={styles.logAction}>{log.action || '—'}</span>
                                                        <span className={styles.logUser}>{log.user || '—'}</span>
                                                    </div>
                                                ))
                                            ) : (
                                                <div className={styles.logItem}>
                                                    <span className={styles.logTime}>—</span>
                                                    <span className={styles.logAction}>No logs available</span>
                                                    <span className={styles.logUser}>—</span>
                                                </div>
                                            )}
                                        </div>
                                    </div>
                                    <div className={styles.contentSection}>
                                        <h3 className={styles.sectionTitle}>Details</h3>
                                        <p className={styles.logInfo}>Monitor all system transactions, user actions, and important activities in real-time.</p>
                                    </div>
                                </div>
                            </div>
                        )}

                        {activePanel === "history" && (
                            <div className={styles.panelContent}>
                                <h2 className={styles.panelTitle}>History</h2>
                                <div className={styles.panelBody}>
                                    <div className={styles.contentSection}>
                                        <h3 className={styles.sectionTitle}>Transaction History</h3>
                                        <div className={styles.historyList}>
                                            <div className={styles.historyItem}>
                                                <div className={styles.historyDate}>Date</div>
                                                <div className={styles.historyDesc}>Description</div>
                                                <div className={styles.historyStatus}>Status</div>
                                            </div>
                                            {recentEntries.length > 0 ? (
                                                recentEntries.map((entry, idx) => (
                                                    <div key={idx} className={styles.historyItem}>
                                                        <div className={styles.historyDate}>{entry.DateAcquired ? new Date(entry.DateAcquired).toLocaleDateString() : '—'}</div>
                                                        <div className={styles.historyDesc}>{entry.Item || '—'}</div>
                                                        <div className={styles.historyStatus}>{entry.status || '—'}</div>
                                                    </div>
                                                ))
                                            ) : (
                                                <div className={styles.historyItem}>
                                                    <div className={styles.historyDate}>—</div>
                                                    <div className={styles.historyDesc}>No history available</div>
                                                    <div className={styles.historyStatus}>—</div>
                                                </div>
                                            )}
                                        </div>
                                    </div>
                                    <div className={styles.contentSection}>
                                        <p className={styles.historyInfo}>Complete record of all past transactions and activities.</p>
                                    </div>
                                </div>
                            </div>
                        )}

                        {activePanel === "settings" && (
                            <div className={styles.panelContent}>
                                <h2 className={styles.panelTitle}>Settings</h2>
                                <div className={styles.panelBody}>
                                    <div className={styles.contentSection}>
                                        <div className={styles.wip}>
                                            <p className={styles.wipText}>Work in Progress</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        )}
                    </div>
                )}
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
                                    className={`${styles.mobileNavItem} ${item.id === "addEntry" ? styles.mobileAddEntry : ""} ${activePanel === item.id ? styles.active : ""}`}
                                    onClick={() => handlePanelClick(item.id)}
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


