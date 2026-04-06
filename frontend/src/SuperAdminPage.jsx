import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import styles from './css/SuperAdminPage.module.css';
import API_BASE_URL from './config/api';

/**
 * Enhanced SuperAdminPage
 * 
 * Comprehensive admin dashboard with:
 * - User management (CRUD Admins & Employees)
 * - Capability assignment & management
 * - Audit trail viewing
 * - Role-based restrictions
 */

function SuperAdminPage() {
  const [activeTab, setActiveTab] = useState('users'); // users, capabilities, audit-logs
  const [users, setUsers] = useState([]);
  const [allCapabilities, setAllCapabilities] = useState([]);
  const [userCapabilities, setUserCapabilities] = useState([]);
  const [auditLogs, setAuditLogs] = useState([]);

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const [showCreateForm, setShowCreateForm] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null);
  const [selectedUserForCapabilities, setSelectedUserForCapabilities] = useState(null);

  const navigate = useNavigate();
  const actorId = parseInt(sessionStorage.getItem('user_id'), 10);
  const roleId = parseInt(sessionStorage.getItem('role_id'), 10);

  // Form state for create user
  const [createForm, setCreateForm] = useState({
    username: '',
    email: '',
    password: '',
    confirmPassword: '',
    role_id: 3, // Default to Employee
    notes: ''
  });

  // Form state for edit user
  const [editForm, setEditForm] = useState(null);

  // Initialize
  useEffect(() => {
    if (roleId !== 1) {
      setError('Access Denied: SuperAdmin only');
      return;
    }
    loadAllData();
  }, []);

  // Load data based on active tab
  useEffect(() => {
    if (activeTab === 'users') {
      loadUsers();
    } else if (activeTab === 'capabilities') {
      loadCapabilities();
    } else if (activeTab === 'audit-logs') {
      loadAuditLogs();
    }
  }, [activeTab]);

  /* ============ DATA LOADING ============ */

  const loadAllData = async () => {
    await Promise.all([
      loadUsers(),
      loadCapabilities()
    ]);
  };

  const loadUsers = async () => {
    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/get_all_users.php`, {
        credentials: 'include'
      });
      const data = await response.json();

      if (data.success) {
        // Filter out current user for selection
        const filtered = data.users.filter(u => u.id !== actorId);
        setUsers(filtered);
      } else {
        throw new Error(data.error);
      }
    } catch (err) {
      setError('Failed to load users: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const loadCapabilities = async () => {
    try {
      setLoading(true);
      const response = await fetch(
        `${API_BASE_URL}/get_capabilities.php?requester_role_id=${roleId}`,
        { credentials: 'include' }
      );
      const data = await response.json();

      if (data.success) {
        setAllCapabilities(data.capabilities || []);
      } else {
        throw new Error(data.error);
      }
    } catch (err) {
      setError('Failed to load capabilities: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const loadAuditLogs = async () => {
    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/get_audit_logs.php`, {
        credentials: 'include'
      });
      const data = await response.json();

      if (data.success) {
        setAuditLogs(data.logs || []);
      } else {
        throw new Error(data.error);
      }
    } catch (err) {
      setError('Failed to load audit logs: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const loadUserCapabilities = async (userId) => {
    try {
      const response = await fetch(
        `${API_BASE_URL}/get_user_capabilities.php?user_id=${userId}`,
        { credentials: 'include' }
      );
      const data = await response.json();

      if (data.success) {
        setUserCapabilities(data.capabilities || []);
      } else {
        throw new Error(data.error);
      }
    } catch (err) {
      setError('Failed to load user capabilities: ' + err.message);
    }
  };

  /* ============ USER MANAGEMENT ============ */

  const handleCreateUser = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    // Validation
    if (!createForm.username.trim()) {
      setError('Username is required');
      return;
    }
    if (!createForm.email.trim()) {
      setError('Email is required');
      return;
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(createForm.email)) {
      setError('Invalid email format');
      return;
    }
    if (createForm.password.length < 8) {
      setError('Password must be at least 8 characters');
      return;
    }
    if (createForm.password !== createForm.confirmPassword) {
      setError('Passwords do not match');
      return;
    }

    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/create_user.php`, {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          actor_id: actorId,
          username: createForm.username,
          email: createForm.email,
          password: createForm.password,
          role_id: parseInt(createForm.role_id),
          notes: createForm.notes
        })
      });

      const data = await response.json();

      if (data.status === 'success') {
        setSuccess(`User "${createForm.username}" created successfully!`);
        setCreateForm({
          username: '',
          email: '',
          password: '',
          confirmPassword: '',
          role_id: 3,
          notes: ''
        });
        setShowCreateForm(false);
        await loadUsers();
      } else {
        setError((data.message || 'Failed to create user'));
      }
    } catch (err) {
      setError('Network error: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleUpdateUser = async () => {
    if (!editForm) return;
    setError('');
    setSuccess('');

    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/update_user.php`, {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          actor_id: actorId,
          target_id: editForm.id,
          username: editForm.username,
          email: editForm.email,
          role_id: parseInt(editForm.role_id)
        })
      });

      const data = await response.json();

      if (data.status === 'success') {
        setSuccess(`User updated successfully!`);
        setEditForm(null);
        setSelectedUser(null);
        await loadUsers();
      } else {
        setError((data.message || 'Failed to update user'));
      }
    } catch (err) {
      setError('Network error: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteUser = async (userId, username) => {
    if (!window.confirm(`Delete user "${username}"? This cannot be undone.`)) return;

    setError('');
    setSuccess('');

    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/delete_user.php`, {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          actor_id: actorId,
          target_id: userId
        })
      });

      const data = await response.json();

      if (data.status === 'success') {
        setSuccess(`User deleted successfully!`);
        setSelectedUser(null);
        await loadUsers();
      } else {
        setError((data.message || 'Failed to delete user'));
      }
    } catch (err) {
      setError('Network error: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  /* ============ CAPABILITY MANAGEMENT ============ */

  const handleSelectUserForCapabilities = (user) => {
    setSelectedUserForCapabilities(user);
    loadUserCapabilities(user.id);
  };

  const handleToggleCapability = async (capabilityId, shouldGrant) => {
    if (!selectedUserForCapabilities) return;

    setError('');
    setSuccess('');

    try {
      const response = await fetch(`${API_BASE_URL}/grant_capability.php`, {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          actor_id: actorId,
          target_id: selectedUserForCapabilities.id,
          capability_id: capabilityId,
          action: shouldGrant ? 'GRANT' : 'REVOKE'
        })
      });

      const data = await response.json();

      if (data.success) {
        setSuccess(`Capability ${shouldGrant ? 'granted' : 'revoked'}!`);
        await loadUserCapabilities(selectedUserForCapabilities.id);
      } else {
        setError((data.message || data.error || 'Failed to update capability'));
      }
    } catch (err) {
      setError('Network error: ' + err.message);
    }
  };

  /* ============ UI HELPERS ============ */

  const getRoleLabel = (roleId) => {
    const roles = { 1: 'SuperAdmin', 2: 'Admin', 3: 'Employee' };
    return roles[roleId] || 'Unknown';
  };

  const getRoleColor = (roleId) => {
    const colors = { 1: '#e74c3c', 2: '#f39c12', 3: '#27ae60' };
    return colors[roleId] || '#95a5a6';
  };

  const handleLogout = () => {
    sessionStorage.clear();
    navigate('/');
  };

  if (error && error.includes('Access Denied')) {
    return (
      <div className={styles.container}>
        <div className={styles.accessDenied}>
          <h2>Access Denied</h2>
          <p>This page is for SuperAdmins only.</p>
          <button onClick={() => navigate('/dashboard')} className={styles.btn}>
            Return to Dashboard
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className={styles.container}>
      {/* Header */}
      <div className={styles.header}>
        <div>
          <h1 className={styles.title}>SuperAdmin Dashboard</h1>
          <p className={styles.subtitle}>System administration & management</p>
        </div>
        <button className={styles.logoutBtn} onClick={handleLogout}>
          Logout
        </button>
      </div>

      {/* Alerts */}
      {error && (
        <div className={styles.alert} style={{ borderColor: '#e74c3c' }}>
          {error}
          <button onClick={() => setError('')} className={styles.closeAlert}>Close</button>
        </div>
      )}
      {success && (
        <div className={styles.alert} style={{ borderColor: '#27ae60' }}>
          {success}
          <button onClick={() => setSuccess('')} className={styles.closeAlert}>Close</button>
        </div>
      )}

      {/* Tabs */}
      <div className={styles.tabs}>
        <button
          className={`${styles.tab} ${activeTab === 'users' ? styles.active : ''}`}
          onClick={() => setActiveTab('users')}
        >
          User Management
        </button>
        <button
          className={`${styles.tab} ${activeTab === 'capabilities' ? styles.active : ''}`}
          onClick={() => setActiveTab('capabilities')}
        >
          Capabilities
        </button>
        <button
          className={`${styles.tab} ${activeTab === 'audit-logs' ? styles.active : ''}`}
          onClick={() => setActiveTab('audit-logs')}
        >
          Audit Logs
        </button>
      </div>

      {/* Tab Content */}
      <div className={styles.content}>
        {/* USERS TAB */}
        {activeTab === 'users' && (
          <div className={styles.tabContent}>
            <div className={styles.section}>
              <div className={styles.sectionHeader}>
                <h2>Create New User</h2>
                <button
                  className={styles.toggleBtn}
                  onClick={() => setShowCreateForm(!showCreateForm)}
                >
                  {showCreateForm ? '▼ Hide' : '▶ Show'}
                </button>
              </div>

              {showCreateForm && (
                <form onSubmit={handleCreateUser} className={styles.form}>
                  <div className={styles.formRow}>
                    <div className={styles.formGroup}>
                      <label>Username *</label>
                      <input
                        type="text"
                        value={createForm.username}
                        onChange={(e) =>
                          setCreateForm({ ...createForm, username: e.target.value })
                        }
                        placeholder="Enter username"
                        disabled={loading}
                        required
                      />
                    </div>
                    <div className={styles.formGroup}>
                      <label>Email *</label>
                      <input
                        type="email"
                        value={createForm.email}
                        onChange={(e) =>
                          setCreateForm({ ...createForm, email: e.target.value })
                        }
                        placeholder="user@example.com"
                        disabled={loading}
                        required
                      />
                    </div>
                  </div>

                  <div className={styles.formRow}>
                    <div className={styles.formGroup}>
                      <label>Password *</label>
                      <input
                        type="password"
                        value={createForm.password}
                        onChange={(e) =>
                          setCreateForm({ ...createForm, password: e.target.value })
                        }
                        placeholder="Min. 8 characters"
                        disabled={loading}
                        required
                      />
                    </div>
                    <div className={styles.formGroup}>
                      <label>Confirm Password *</label>
                      <input
                        type="password"
                        value={createForm.confirmPassword}
                        onChange={(e) =>
                          setCreateForm({ ...createForm, confirmPassword: e.target.value })
                        }
                        placeholder="Re-enter password"
                        disabled={loading}
                        required
                      />
                    </div>
                  </div>

                  <div className={styles.formRow}>
                    <div className={styles.formGroup}>
                      <label>Role *</label>
                      <select
                        value={createForm.role_id}
                        onChange={(e) =>
                          setCreateForm({ ...createForm, role_id: e.target.value })
                        }
                        disabled={loading}
                      >
                        <option value={2}>Admin (Can manage employees)</option>
                        <option value={3}>Employee (Standard user)</option>
                      </select>
                    </div>
                    <div className={styles.formGroup}>
                      <label>Notes</label>
                      <input
                        type="text"
                        value={createForm.notes}
                        onChange={(e) =>
                          setCreateForm({ ...createForm, notes: e.target.value })
                        }
                        placeholder="Optional notes"
                        disabled={loading}
                      />
                    </div>
                  </div>

                  <button
                    type="submit"
                    className={styles.submitBtn}
                    disabled={loading}
                  >
                    {loading ? 'Creating...' : 'Create User'}
                  </button>
                </form>
              )}
            </div>

            {/* Users List */}
            <div className={styles.section}>
              <div className={styles.sectionHeader}>
                <h2>All Users ({users.length})</h2>
                <button
                  className={styles.refreshBtn}
                  onClick={loadUsers}
                  disabled={loading}
                >
                   Refresh
                </button>
              </div>

              {users.length === 0 ? (
                <div className={styles.emptyState}>
                  <p>No users found</p>
                </div>
              ) : (
                <div className={styles.usersGrid}>
                  {users.map((user) => (
                    <div
                      key={user.id}
                      className={`${styles.userCard} ${
                        selectedUser?.id === user.id ? styles.selected : ''
                      }`}
                      onClick={() => setSelectedUser(selectedUser?.id === user.id ? null : user)}
                    >
                      <div className={styles.userHeader}>
                        <div>
                          <h3>{user.username}</h3>
                          <p className={styles.email}>{user.email}</p>
                        </div>
                        <div
                          className={styles.roleBadge}
                          style={{ background: getRoleColor(user.role_id) }}
                        >
                          {getRoleLabel(user.role_id)}
                        </div>
                      </div>

                      {selectedUser?.id === user.id && (
                        <div className={styles.userActions}>
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              setEditForm(user);
                            }}
                            className={styles.editBtn}
                          >
                            Edit
                          </button>
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              handleDeleteUser(user.id, user.username);
                            }}
                            className={styles.deleteBtn}
                          >
                            Delete
                          </button>
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Edit User Modal */}
            {editForm && (
              <div className={styles.modal}>
                <div className={styles.modalContent}>
                  <div className={styles.modalHeader}>
                    <h2>Edit User: {editForm.username}</h2>
                    <button
                      onClick={() => setEditForm(null)}
                      className={styles.closeModal}
                    >
                      Close
                    </button>
                  </div>

                  <div className={styles.modalBody}>
                    <div className={styles.formRow}>
                      <div className={styles.formGroup}>
                        <label>Username</label>
                        <input
                          type="text"
                          value={editForm.username}
                          onChange={(e) =>
                            setEditForm({ ...editForm, username: e.target.value })
                          }
                        />
                      </div>
                      <div className={styles.formGroup}>
                        <label>Email</label>
                        <input
                          type="email"
                          value={editForm.email}
                          onChange={(e) =>
                            setEditForm({ ...editForm, email: e.target.value })
                          }
                        />
                      </div>
                    </div>

                    <div className={styles.formRow}>
                      <div className={styles.formGroup}>
                        <label>Role</label>
                        <select
                          value={editForm.role_id}
                          onChange={(e) =>
                            setEditForm({ ...editForm, role_id: e.target.value })
                          }
                        >
                          <option value={2}>Admin</option>
                          <option value={3}>Employee</option>
                        </select>
                      </div>
                      <div className={styles.formGroup}>
                        <label>Notes</label>
                        <input
                          type="text"
                          value={editForm.notes || ''}
                          onChange={(e) =>
                            setEditForm({ ...editForm, notes: e.target.value })
                          }
                        />
                      </div>
                    </div>
                  </div>

                  <div className={styles.modalFooter}>
                    <button
                      onClick={() => setEditForm(null)}
                      className={styles.cancelBtn}
                    >
                      Cancel
                    </button>
                    <button
                      onClick={handleUpdateUser}
                      className={styles.submitBtn}
                      disabled={loading}
                    >
                      {loading ? 'Updating...' : 'Update User'}
                    </button>
                  </div>
                </div>
              </div>
            )}
          </div>
        )}

        {/* CAPABILITIES TAB */}
        {activeTab === 'capabilities' && (
          <div className={styles.tabContent}>
            <div className={styles.capabilitiesLayout}>
              {/* User Selector */}
              <div className={styles.userSelector}>
                <h3>Select User</h3>
                <div className={styles.userList}>
                  {users.map((user) => (
                    <button
                      key={user.id}
                      className={`${styles.userListItem} ${
                        selectedUserForCapabilities?.id === user.id ? styles.active : ''
                      }`}
                      onClick={() => handleSelectUserForCapabilities(user)}
                    >
                      <div className={styles.userListName}>{user.username}</div>
                      <div
                        className={styles.userListRole}
                        style={{ background: getRoleColor(user.role_id) }}
                      >
                        {getRoleLabel(user.role_id)}
                      </div>
                    </button>
                  ))}
                </div>
              </div>

              {/* Capabilities */}
              <div className={styles.capabilitiesGrid}>
                {selectedUserForCapabilities ? (
                  <>
                    <h3>{selectedUserForCapabilities.username}'s Capabilities</h3>
                    {allCapabilities.length === 0 ? (
                      <p className={styles.emptyState}>No capabilities available</p>
                    ) : (
                      <div className={styles.capabilityCards}>
                        {allCapabilities.map((cap) => {
                          const isGranted = userCapabilities.some(
                            (uc) => uc.id === cap.id
                          );
                          return (
                            <div key={cap.id} className={styles.capabilityCard}>
                              <div className={styles.capName}>{cap.capability_key}</div>
                              <p className={styles.capDesc}>{cap.description}</p>
                              <label className={styles.capCheckbox}>
                                <input
                                  type="checkbox"
                                  checked={isGranted}
                                  onChange={(e) =>
                                    handleToggleCapability(cap.id, e.target.checked)
                                  }
                                  disabled={loading}
                                />
                                <span>{isGranted ? 'Granted' : 'Not Granted'}</span>
                              </label>
                            </div>
                          );
                        })}
                      </div>
                    )}
                  </>
                ) : (
                  <div className={styles.emptyState}>
                    <p>← Select a user to manage capabilities</p>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}

        {/* AUDIT LOGS TAB */}
        {activeTab === 'audit-logs' && (
          <div className={styles.tabContent}>
            <div className={styles.section}>
              <div className={styles.sectionHeader}>
                <h2>Activity Audit Logs</h2>
                <button
                  className={styles.refreshBtn}
                  onClick={loadAuditLogs}
                  disabled={loading}
                >
                  🔄 Refresh
                </button>
              </div>

              {auditLogs.length === 0 ? (
                <div className={styles.emptyState}>
                  <p>No audit logs available</p>
                </div>
              ) : (
                <div className={styles.auditTable}>
                  <table>
                    <thead>
                      <tr>
                        <th>Actor</th>
                        <th>Action</th>
                        <th>Target</th>
                        <th>Timestamp</th>
                        <th>Details</th>
                      </tr>
                    </thead>
                    <tbody>
                      {auditLogs.slice(0, 50).map((log, idx) => (
                        <tr key={idx}>
                          <td>{log.actor_username}</td>
                          <td>
                            <span
                              className={styles.actionBadge}
                              style={{
                                background:
                                  log.action === 'GRANT'
                                    ? '#27ae60'
                                    : log.action === 'REVOKE'
                                    ? '#e74c3c'
                                    : '#3498db'
                              }}
                            >
                              {log.action}
                            </span>
                          </td>
                          <td>{log.target_username || '-'}</td>
                          <td>{new Date(log.timestamp).toLocaleString()}</td>
                          <td className={styles.details}>{log.details || '-'}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default SuperAdminPage;
