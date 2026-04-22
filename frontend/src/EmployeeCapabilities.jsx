import { useState, useEffect } from 'react';
import styles from './css/EmployeeCapabilities.module.css';

/**
 * EmployeeCapabilities Component
 * 
 * Employee interface for viewing assigned capabilities
 * - Read-only display of permissions
 * - Shows grant history (who granted when)
 * - Organized by category for easy understanding
 * - No modification capabilities (viewing only)
 */

export default function EmployeeCapabilities() {
  const [capabilities, setCapabilities] = useState([]);
  const [capabilitiesByCategory, setCapabilitiesByCategory] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const userId = parseInt(sessionStorage.getItem('user_id'), 10);
  const roleId = parseInt(sessionStorage.getItem('role_id'), 10);
  const username = sessionStorage.getItem('username') || 'User';

  useEffect(() => {
    loadCapabilities();
  }, []);

  const loadCapabilities = async () => {
    try {
      setLoading(true);
      const response = await fetch(
        `/get_user_capabilities.php?user_id=${userId}`
      );
      const data = await response.json();

      if (data.success) {
        setCapabilities(data.capabilities);
        
        // Group by category
        const byCategory = {};
        data.capabilities.forEach(cap => {
          const category = cap.category || 'OTHER';
          if (!byCategory[category]) {
            byCategory[category] = [];
          }
          byCategory[category].push(cap);
        });
        setCapabilitiesByCategory(byCategory);
      } else {
        throw new Error(data.error || 'Failed to load capabilities');
      }
    } catch (err) {
      setError('Error loading capabilities: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const getWhoGrantedBadge = (grantedBy, grantedAt) => {
    if (grantedBy === 'DEFAULT') {
      return (
        <span className={styles.badge} style={{ background: '#6c757d' }}>
          Default Assignment
        </span>
      );
    }
    return (
      <span className={styles.badge}>
        Granted by Administrator
      </span>
    );
  };

  const formatDate = (dateString) => {
    try {
      return new Date(dateString).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      });
    } catch {
      return 'Unknown date';
    }
  };

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <h1>My Capabilities</h1>
        <p className={styles.subtitle}>
          View your access permissions and capabilities
        </p>
        <div className={styles.userInfo}>
          <span>{username}</span>
          <span className={styles.roleTag}>Employee</span>
        </div>
      </div>

      {error && (
        <div className={styles.alertError}>
          ⚠️ {error}
        </div>
      )}

      {loading ? (
        <div className={styles.loadingState}>
          <p>Loading your capabilities...</p>
          <div className={styles.spinner}></div>
        </div>
      ) : capabilities.length === 0 ? (
        <div className={styles.emptyState}>
          <h3>📭 No Capabilities Assigned</h3>
          <p>You don't have any special capabilities assigned yet.</p>
          <p className={styles.helpText}>
            Contact your administrator if you should have access to additional features.
          </p>
        </div>
      ) : (
        <div className={styles.capabilitiesList}>
          <div className={styles.capabilitiesSummary}>
            <div className={styles.stat}>
              <span className={styles.statNumber}>{capabilities.length}</span>
              <span className={styles.statLabel}>Capability</span>
              {capabilities.length > 1 && <span>ies</span>}
            </div>
            <div className={styles.stat}>
              <span className={styles.statNumber}>
                {Object.entries(capabilitiesByCategory).length}
              </span>
              <span className={styles.statLabel}>Category</span>
              {Object.entries(capabilitiesByCategory).length > 1 && (
                <span>ies</span>
              )}
            </div>
          </div>

          {Object.entries(capabilitiesByCategory).map(([category, caps]) => (
            <div key={category} className={styles.categorySection}>
              <div className={styles.categoryHeader}>
                <span className={styles.categoryIcon}>
                  {category === 'INVENTORY' && '📦'}
                  {category === 'ADMIN' && ''}
                  {category === 'SYSTEM' && ''}
                  {category === 'USER' && ''}
                  {!['INVENTORY', 'ADMIN', 'SYSTEM', 'USER'].includes(
                    category
                  ) && ''}
                </span>
                <h2 className={styles.categoryTitle}>{category}</h2>
                <span className={styles.capCount}>{caps.length}</span>
              </div>

              <div className={styles.capabilitiesGrid}>
                {caps.map(cap => (
                  <div key={cap.id} className={styles.capabilityCard}>
                    <div className={styles.capabilityBody}>
                      <h3 className={styles.capabilityName}>
                        ✓ {cap.capability_key}
                      </h3>

                      <p className={styles.capabilityDesc}>
                        {cap.description}
                      </p>

                      <div className={styles.grantInfo}>
                        {getWhoGrantedBadge(cap.granted_by, cap.granted_at)}

                        <div className={styles.grantDate}>
                          📅 {formatDate(cap.granted_at)}
                        </div>
                      </div>

                      {cap.notes && (
                        <div className={styles.notes}>
                          <strong>Note:</strong> {cap.notes}
                        </div>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          ))}

          <div className={styles.infoBox}>
            <h4>ℹ️ About Your Capabilities</h4>
            <ul>
              <li>
                These permissions define what you can access and modify in the system.
              </li>
              <li>
                If you believe you should have additional capabilities, contact your
                administrator.
              </li>
              <li>
                Your capabilities can be modified by your administrator at any time.
              </li>
              <li>
                All capability changes are logged and can be audited by administrators.
              </li>
            </ul>
          </div>
        </div>
      )}
    </div>
  );
}
