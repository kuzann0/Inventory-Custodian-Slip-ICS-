import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import styles from './css/Navbar.module.css';
import API_BASE_URL from "./config/api";

function PanelContent({ activePanel, setActivePanel, navbarCollapsed = false }) {
    const [dashboardStats, setDashboardStats] = useState({
        totalEntries: 0,
        pendingCount: 0,
        completedCount: 0
    });
    const [auditLogs, setAuditLogs] = useState([]);
    const [recentEntries, setRecentEntries] = useState([]);
    const navigate = useNavigate();

    // Fetch dashboard statistics
    useEffect(() => {
        const fetchDashboardData = async () => {
            try {
                const response = await fetch(`${API_BASE_URL}/get_entries.php`, {
                    credentials: 'include'
                });
                const data = await response.json();
                
                if (data.status === "success" && Array.isArray(data.data)) {
                    const entries = data.data;
                    setRecentEntries(entries.slice(0, 5));
                    setDashboardStats({
                        totalEntries: entries.length,
                        pendingCount: entries.filter(e => e.status === 'pending').length || 0,
                        completedCount: entries.filter(e => e.status === 'completed').length || 0
                    });
                }
            } catch (err) {
                console.error("Error fetching dashboard data:", err);
            }
        };

        const fetchAuditLogs = async () => {
            try {
                const response = await fetch(`${API_BASE_URL}/get_audit_logs.php`, {
                    credentials: 'include'
                });
                const data = await response.json();
                
                if (data.status === "success" && Array.isArray(data.data)) {
                    setAuditLogs(data.data.slice(0, 10));
                }
            } catch (err) {
                console.error("Error fetching audit logs:", err);
            }
        };

        // Fetch data when dashboard, auditLogs, dataManagement, or history panels are active
        if (activePanel === "dashboard" || activePanel === "auditLogs" || activePanel === "dataManagement" || activePanel === "history") {
            fetchDashboardData();
            fetchAuditLogs();
        }
    }, [activePanel]);

    return (
        <div className={`${styles.panelContentSection} ${navbarCollapsed ? styles.collapsed : ''}`}>
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
                                <button className={styles.actionButton} onClick={() => {
                                    sessionStorage.clear();
                                    navigate('/');
                                }}>Logout</button>
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
    );
}

export default PanelContent;
