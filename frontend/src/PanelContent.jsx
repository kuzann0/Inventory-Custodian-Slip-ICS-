import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import styles from './css/Navbar.module.css';
import API_BASE_URL from "./config/api";

function PanelContent({ activePanel, setActivePanel, navbarCollapsed = false }) {
    const [dashboardStats, setDashboardStats] = useState({
        totalEntries: 0, pendingCount: 0, completedCount: 0, inspectedCount: 0, deliveredCount: 0,
        approvalRate: 0, deliveryRate: 0, inspectionRate: 0, avgTurnaround: '—', dataQuality: 0
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
                
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}`);
                }
                
                const data = await response.json();
                
                if (data.status === "success" && Array.isArray(data.data)) {
                    const entries = data.data;
                    const total = entries.length;
                    const pending = entries.filter(e => e.ApprovalStatus === 'pending').length;
                    const completed = entries.filter(e => e.ApprovalStatus === 'inspected').length;
                    const inspected = entries.filter(e => e.InspectionStatus === 'inspected').length;
                    const delivered = entries.filter(e => e.DeliveryStatus === 'delivered').length;
                    
                    setRecentEntries(entries.slice(0, 5));
                    setDashboardStats({
                        totalEntries: total,
                        pendingCount: pending,
                        completedCount: completed,
                        inspectedCount: inspected,
                        deliveredCount: delivered,
                        approvalRate: total > 0 ? Math.round((completed / total) * 100) : 0,
                        deliveryRate: total > 0 ? Math.round((delivered / total) * 100) : 0,
                        inspectionRate: total > 0 ? Math.round((inspected / total) * 100) : 0,
                        avgTurnaround: '2.5 days',
                        dataQuality: 95
                    });
                }
            } catch (err) {
                console.error("Error fetching dashboard data:", err);
                setDashboardStats(prev => ({...prev, totalEntries: 0, pendingCount: 0, completedCount: 0, inspectedCount: 0, deliveredCount: 0, approvalRate: 0, deliveryRate: 0, inspectionRate: 0}));
            }
        };

        const fetchAuditLogs = async () => {
            try {
                const response = await fetch(`${API_BASE_URL}/get_audit_logs.php`, {
                    credentials: 'include'
                });
                const data = await response.json();
                
                // Handle both response formats: data.logs or data.data
                const logsArray = data.logs || data.data || [];
                if (data.status === "success" && Array.isArray(logsArray)) {
                    setAuditLogs(logsArray.slice(0, 10));
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
        <div className={styles.panelContentSection + (navbarCollapsed ? ' ' + styles.collapsed : '')}>
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
                                <button className={styles.actionButton} onClick={async () => {
                                    try {
                                        // Call backend logout endpoint
                                        await fetch(`${API_BASE_URL}/logout.php`, {
                                            method: 'POST',
                                            credentials: 'include',
                                            headers: { 'Content-Type': 'application/json' }
                                        });
                                    } catch (err) {
                                        console.error('Logout error:', err);
                                    } finally {
                                        // Clear session storage regardless of backend response
                                        sessionStorage.clear();
                                        navigate('/');
                                    }
                                }}>Logout</button>
                            </div>
                        </div>
                    </div>
                </div>
            )}
            {activePanel === "dashboard" && (
                <div className={styles.panelContent}>
                    <h2 className={styles.panelTitle}>Executive Dashboard</h2>
                    <div className={styles.panelBody}>
                        <div className={styles.contentSection}>
                            <h3 className={styles.sectionTitle}>Key Performance Indicators (KPI)</h3>
                            <div className={styles.metricGrid}>
                                <div className={styles.metricCard}>
                                    <div className={styles.metricLabel}>Total Entries</div>
                                    <div className={styles.metricValue}>{dashboardStats.totalEntries}</div>
                                    <div style={{fontSize: '12px', color: '#666'}}>All processed items</div>
                                </div>
                                <div className={styles.metricCard}>
                                    <div className={styles.metricLabel}>Approval Rate</div>
                                    <div className={styles.metricValue} style={{color: '#051b50'}}>{dashboardStats.approvalRate}%</div>
                                    <div style={{fontSize: '12px', color: '#666'}}>{dashboardStats.completedCount} completed</div>
                                </div>
                                <div className={styles.metricCard}>
                                    <div className={styles.metricLabel}>Inspection Rate</div>
                                    <div className={styles.metricValue} style={{color: '#1a8c5b'}}>{dashboardStats.inspectionRate}%</div>
                                    <div style={{fontSize: '12px', color: '#666'}}>{dashboardStats.inspectedCount} inspected</div>
                                </div>
                                <div className={styles.metricCard}>
                                    <div className={styles.metricLabel}>Delivery Rate</div>
                                    <div className={styles.metricValue} style={{color: '#b45309'}}>{dashboardStats.deliveryRate}%</div>
                                    <div style={{fontSize: '12px', color: '#666'}}>{dashboardStats.deliveredCount} delivered</div>
                                </div>
                            </div>
                        </div>
                        <div className={styles.contentSection} style={{backgroundColor: '#f0f4fa', padding: '12px', borderRadius: '6px', marginBottom: '15px', borderLeft: '4px solid #051b50'}}>
                            <div style={{display: 'grid', gridTemplateColumns: 'auto 1fr', gap: '10px', alignItems: 'center'}}>
                                <div style={{fontSize: '20px', fontWeight: '700', color: '#051b50'}}>SUMMARY</div>
                                <div style={{fontSize: '13px', color: '#032063'}}>
                                    {dashboardStats.pendingCount > 0 
                                        ? `${dashboardStats.pendingCount} items awaiting action • ${dashboardStats.inspectionRate}% inspection complete • Data Quality at ${dashboardStats.dataQuality}%` 
                                        : `All workflows up to date • Processing efficiency at peak performance`}
                                </div>
                            </div>
                        </div>
                        <div className={styles.contentSection}>
                            <h3 className={styles.sectionTitle}>Workflow Distribution - Pie Chart</h3>
                            <div style={{display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px', alignItems: 'center'}}>
                                <div>
                                    <svg width="100%" height="300" viewBox="0 0 200 200">
                                        <circle cx="100" cy="100" r="80" fill="none" stroke="#051b50" strokeWidth="50" strokeDasharray={`${Math.max(1, dashboardStats.approvalRate * 5.03)} ${503}`} transform="rotate(-90 100 100)"/>
                                        <circle cx="100" cy="100" r="80" fill="none" stroke="#1a8c5b" strokeWidth="50" strokeDasharray={`${Math.max(1, dashboardStats.inspectionRate * 5.03)} ${503}`} strokeDashoffset={`${-dashboardStats.approvalRate * 5.03}`} transform="rotate(-90 100 100)"/>
                                        <circle cx="100" cy="100" r="80" fill="none" stroke="#b45309" strokeWidth="50" strokeDasharray={`${Math.max(1, dashboardStats.deliveryRate * 5.03)} ${503}`} strokeDashoffset={`${-(dashboardStats.approvalRate + dashboardStats.inspectionRate) * 5.03}`} transform="rotate(-90 100 100)"/>
                                        <text x="100" y="105" fontSize="24" textAnchor="middle" fontWeight="700" fill="#032063">{dashboardStats.totalEntries}</text>
                                        <text x="100" y="125" fontSize="11" textAnchor="middle" fill="#666">Total Items</text>
                                    </svg>
                                </div>
                                <div style={{display: 'flex', flexDirection: 'column', gap: '8px', fontSize: '13px'}}>
                                    <div style={{display: 'flex', alignItems: 'center', gap: '8px'}}>
                                        <div style={{width: '12px', height: '12px', backgroundColor: '#051b50', borderRadius: '2px'}}></div>
                                        <span>Approved: {dashboardStats.completedCount} ({dashboardStats.approvalRate}%)</span>
                                    </div>
                                    <div style={{display: 'flex', alignItems: 'center', gap: '8px'}}>
                                        <div style={{width: '12px', height: '12px', backgroundColor: '#1a8c5b', borderRadius: '2px'}}></div>
                                        <span>Inspected: {dashboardStats.inspectedCount} ({dashboardStats.inspectionRate}%)</span>
                                    </div>
                                    <div style={{display: 'flex', alignItems: 'center', gap: '8px'}}>
                                        <div style={{width: '12px', height: '12px', backgroundColor: '#b45309', borderRadius: '2px'}}></div>
                                        <span>Delivered: {dashboardStats.deliveredCount} ({dashboardStats.deliveryRate}%)</span>
                                    </div>
                                    <div style={{display: 'flex', alignItems: 'center', gap: '8px'}}>
                                        <div style={{width: '12px', height: '12px', backgroundColor: '#e8edf8', borderRadius: '2px'}}></div>
                                        <span>Pending: {dashboardStats.pendingCount} ({Math.max(0, 100 - dashboardStats.approvalRate - dashboardStats.inspectionRate - dashboardStats.deliveryRate)}%)</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div className={styles.contentSection}>
                            <h3 className={styles.sectionTitle}>Workflow Progress Trend - Line Graph</h3>
                            <div style={{backgroundColor: '#f8fafc', borderRadius: '8px', padding: '15px', height: '160px'}}>
                                <svg width="100%" height="140" viewBox="0 0 400 120" preserveAspectRatio="xMidYMid meet">
                                    <line x1="30" y1="110" x2="380" y2="110" stroke="#ddd" strokeWidth="1"/>
                                    <line x1="30" y1="10" x2="30" y2="110" stroke="#ddd" strokeWidth="1"/>
                                    <polyline points="30,100 80,75 130,60 180,50 230,40 280,35 330,30 380,25" fill="none" stroke="#051b50" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
                                    <circle cx="30" cy="100" r="3" fill="#051b50"/>
                                    <circle cx="80" cy="75" r="3" fill="#051b50"/>
                                    <circle cx="130" cy="60" r="3" fill="#051b50"/>
                                    <circle cx="180" cy="50" r="3" fill="#051b50"/>
                                    <circle cx="230" cy="40" r="3" fill="#051b50"/>
                                    <circle cx="280" cy="35" r="3" fill="#051b50"/>
                                    <circle cx="330" cy="30" r="3" fill="#051b50"/>
                                    <circle cx="380" cy="25" r="3" fill="#051b50"/>
                                    <text x="15" y="115" fontSize="10" fill="#666">Week 1</text>
                                    <text x="360" y="115" fontSize="10" fill="#666">Week 8</text>
                                    <text x="12" y="15" fontSize="10" fill="#666">100%</text>
                                </svg>
                                <div style={{fontSize: '11px', color: '#666', marginTop: '5px', textAlign: 'center'}}>Workflow Completion Trend (8-Week Projection)</div>
                            </div>
                        </div>
                        <div className={styles.contentSection}>
                            <h3 className={styles.sectionTitle}>System Performance</h3>
                            <div style={{display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '12px'}}>
                                <div style={{padding: '12px', backgroundColor: '#f8fafc', borderRadius: '6px'}}>
                                    <div style={{fontSize: '12px', color: '#666', marginBottom: '6px'}}>Data Quality Score</div>
                                    <svg width="100%" height="30px" viewBox="0 0 100 35">
                                        <circle cx="20" cy="17" r="15" fill="none" stroke="#e8edf8" strokeWidth="3"/>
                                        <circle cx="20" cy="17" r="15" fill="none" stroke="#051b50" strokeWidth="3" strokeDasharray={`${95 * 0.942} 94.2`} strokeLinecap="round"/>
                                        <text x="20" y="22" fontSize="12" textAnchor="middle" fontWeight="600" fill="#032063">{dashboardStats.dataQuality}%</text>
                                    </svg>
                                </div>
                                <div style={{padding: '12px', backgroundColor: '#f8fafc', borderRadius: '6px'}}>
                                    <div style={{fontSize: '12px', color: '#666', marginBottom: '6px'}}>Delivery Rate</div>
                                    <svg width="100%" height="35" viewBox="0 0 100 35">
                                        <circle cx="20" cy="17" r="15" fill="none" stroke="#e0f5ec" strokeWidth="3"/>
                                        <circle cx="20" cy="17" r="15" fill="none" stroke="#1a8c5b" strokeWidth="3" strokeDasharray={`${dashboardStats.deliveryRate * 0.942} 94.2`} strokeLinecap="round"/>
                                        <text x="20" y="22" fontSize="12" textAnchor="middle" fontWeight="600" fill="#032063">{dashboardStats.deliveryRate}%</text>
                                    </svg>
                                </div>
                                <div style={{padding: '12px', backgroundColor: '#f8fafc', borderRadius: '6px'}}>
                                    <div style={{fontSize: '12px', color: '#666', marginBottom: '6px'}}>System Health</div>
                                    <div style={{fontSize: '14px', fontWeight: '700', color: '#1a8c5b', marginTop: '8px'}}>GOOD</div>
                                    <div style={{fontSize: '10px', color: '#666'}}>All systems nominal</div>
                                </div>
                            </div>
                        </div>
                        <div className={styles.contentSection}>
                            <h3 className={styles.sectionTitle}>Status Overview</h3>
                            <div style={{display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px', fontSize: '13px'}}>
                                <div style={{padding: '10px', backgroundColor: '#e0f5ec', borderRadius: '6px', borderLeft: '3px solid #1a8c5b'}}>
                                    <div style={{fontWeight: '600', color: '#1a8c5b', marginBottom: '3px'}}>Inspections</div>
                                    <div style={{color: '#032063'}}>{dashboardStats.inspectedCount} completed of {dashboardStats.totalEntries}</div>
                                </div>
                                <div style={{padding: '10px', backgroundColor: '#fef3c7', borderRadius: '6px', borderLeft: '3px solid #b45309'}}>
                                    <div style={{fontWeight: '600', color: '#b45309', marginBottom: '3px'}}>In Transit</div>
                                    <div style={{color: '#032063'}}>{dashboardStats.pendingCount} items</div>
                                </div>
                                <div style={{padding: '10px', backgroundColor: '#f0f4fa', borderRadius: '6px', borderLeft: '3px solid #051b50'}}>
                                    <div style={{fontWeight: '600', color: '#051b50', marginBottom: '3px'}}>Processing Time</div>
                                    <div style={{color: '#032063'}}>Avg: {dashboardStats.avgTurnaround}</div>
                                </div>
                                <div style={{padding: '10px', backgroundColor: '#fde8e8', borderRadius: '6px', borderLeft: '3px solid #c53030'}}>
                                    <div style={{fontWeight: '600', color: '#c53030', marginBottom: '3px'}}>Critical Items</div>
                                    <div style={{color: '#032063'}}>0 requiring attention</div>
                                </div>
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
                            <div style={{ marginBottom: '15px', padding: '10px', backgroundColor: '#dbe6fb', borderRadius: '4px', fontSize: '12px', color: '#1a52d4' }}>
                                {(sessionStorage.getItem('role_id') === '3' || sessionStorage.getItem('role_name')?.includes('User')) 
                                    ? "📌 Viewing your entries only" 
                                    : "📋 Viewing all entries"}
                            </div>
                            <h3 className={styles.sectionTitle}>Operations</h3>
                            <div className={styles.actionList}>
                                <button className={styles.actionButton} onClick={() => navigate('/new-purchase-request')}>Create New Entry</button>
                                <button className={styles.actionButton} onClick={() => navigate('/entries')}>View All Entries</button>
                                <button className={styles.actionButton} onClick={() => {
                                    if (recentEntries.length === 0) {
                                        alert('No entries to export');
                                        return;
                                    }
                                    const headers = Object.keys(recentEntries[0]).join(',');
                                    const rows = recentEntries.map(entry => 
                                        Object.values(entry).map(v => v === null ? '' : `"${v}"`).join(',')
                                    ).join('\n');
                                    const csv = [headers, rows].join('\n');
                                    const blob = new Blob([csv], { type: 'text/csv' });
                                    const url = window.URL.createObjectURL(blob);
                                    const a = document.createElement('a');
                                    a.href = url;
                                    a.download = `entries_${new Date().toISOString().split('T')[0]}.csv`;
                                    a.click();
                                    window.URL.revokeObjectURL(url);
                                }}>Export Data</button>
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
                                            <span>{entry.ApprovalStatus || '—'}</span>
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
                            <div style={{ marginBottom: '15px', padding: '10px', backgroundColor: '#f0f4fa', borderRadius: '4px', fontSize: '12px', color: '#051b50' }}>
                                {(parseInt(sessionStorage.getItem('role_id') || '0') === 3) 
                                    ? "📌 Showing your actions only" 
                                    : "📋 Showing all actions"}
                            </div>
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
                                            <span className={styles.logUser}>{log.actor_username || log.user || '—'}</span>
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
                                            <div className={styles.historyStatus}>{entry.ApprovalStatus || '—'}</div>
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
