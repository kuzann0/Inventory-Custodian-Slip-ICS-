import React, { useState, useEffect } from 'react';

const ProcessStatus = () => {
  const [processes, setProcesses] = useState([]);
  const [loading, setLoading] = useState(false);
  const [selectedProcess, setSelectedProcess] = useState(null);
  const [filterStatus, setFilterStatus] = useState('all');
  const [message, setMessage] = useState('');

  useEffect(() => {
    fetchProcesses();
  }, [filterStatus]);

  const fetchProcesses = async () => {
    setLoading(true);
    try {
      const url = filterStatus === 'all' 
        ? '/get_process_status.php'
        : `/get_process_status.php?status=${filterStatus}`;
      
      const response = await fetch(url);
      if (response.ok) {
        const data = await response.json();
        setProcesses(data.processes || []);
      }
    } catch (error) {
      console.error('Error fetching processes:', error);
      setMessage('Failed to load process data');
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status) => {
    const colors = {
      'pending': '#ffc107',
      'in_progress': '#0066ff',
      'under_inspection': '#ff9800',
      'in_delivery': '#2196f3',
      'delivered': '#8bc34a',
      'completed': '#28a745',
      'cancelled': '#dc3545'
    };
    return colors[status] || '#666';
  };

  const getProgressPercentage = (status) => {
    const stages = {
      'pending': 10,
      'purchased': 25,
      'in_delivery': 50,
      'under_inspection': 75,
      'delivered': 90,
      'completed': 100,
      'cancelled': 0
    };
    return stages[status] || 0;
  };

  return (
    <div style={styles.container}>
      <div style={styles.header}>
        <h2>Process Status Tracking</h2>
        <p>Monitor the complete lifecycle of purchase requests</p>
      </div>

      <div style={styles.filterBar}>
        <label>Filter by Status:</label>
        <select
          value={filterStatus}
          onChange={(e) => setFilterStatus(e.target.value)}
          style={styles.filterSelect}
        >
          <option value="all">All</option>
          <option value="pending">Pending</option>
          <option value="purchased">Purchased</option>
          <option value="in_delivery">In Delivery</option>
          <option value="under_inspection">Under Inspection</option>
          <option value="delivered">Delivered</option>
          <option value="completed">Completed</option>
        </select>
      </div>

      {message && (
        <div style={{...styles.message, backgroundColor: '#e8f4f8', color: '#0066cc'}}>
          {message}
        </div>
      )}

      {loading ? (
        <div style={styles.loading}>Loading process data...</div>
      ) : processes.length === 0 ? (
        <div style={styles.empty}>No processes found</div>
      ) : (
        <div style={styles.processList}>
          {processes.map((process) => (
            <div
              key={process.id}
              style={{
                ...styles.processCard,
                borderLeft: `4px solid ${getStatusColor(process.status)}`
              }}
              onClick={() => setSelectedProcess(process.id === selectedProcess ? null : process.id)}
            >
              <div style={styles.processHeader}>
                <div>
                  <h3>PR-{process.pr_no}</h3>
                  <p>{process.description}</p>
                </div>
                <div style={styles.processStatus}>
                  <span style={{
                    ...styles.statusBadge,
                    backgroundColor: getStatusColor(process.status)
                  }}>
                    {process.status.replace(/_/g, ' ').toUpperCase()}
                  </span>
                </div>
              </div>

              <div style={styles.progressBar}>
                <div style={{
                  ...styles.progressFill,
                  width: `${getProgressPercentage(process.status)}%`,
                  backgroundColor: getStatusColor(process.status)
                }} />
              </div>

              {selectedProcess === process.id && (
                <div style={styles.processDetails}>
                  <div style={styles.detailRow}>
                    <span>Created Date:</span>
                    <span>{new Date(process.created_at).toLocaleDateString()}</span>
                  </div>
                  <div style={styles.detailRow}>
                    <span>Last Updated:</span>
                    <span>{new Date(process.updated_at).toLocaleDateString()}</span>
                  </div>
                  <div style={styles.detailRow}>
                    <span>Item Count:</span>
                    <span>{process.item_count || 0}</span>
                  </div>
                  <div style={styles.detailRow}>
                    <span>Total Amount:</span>
                    <span>₱{parseFloat(process.total_amount || 0).toFixed(2)}</span>
                  </div>
                  {process.notes && (
                    <div style={styles.detailRow}>
                      <span>Notes:</span>
                      <span>{process.notes}</span>
                    </div>
                  )}
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      {/* Status Legend */}
      <div style={styles.legend}>
        <h4>Status Legend</h4>
        <div style={styles.legendItems}>
          <div style={styles.legendItem}>
            <span style={{...styles.legendColor, backgroundColor: '#ffc107'}} />
            Pending
          </div>
          <div style={styles.legendItem}>
            <span style={{...styles.legendColor, backgroundColor: '#0066ff'}} />
            In Progress
          </div>
          <div style={styles.legendItem}>
            <span style={{...styles.legendColor, backgroundColor: '#ff9800'}} />
            Under Inspection
          </div>
          <div style={styles.legendItem}>
            <span style={{...styles.legendColor, backgroundColor: '#2196f3'}} />
            In Delivery
          </div>
          <div style={styles.legendItem}>
            <span style={{...styles.legendColor, backgroundColor: '#8bc34a'}} />
            Delivered
          </div>
          <div style={styles.legendItem}>
            <span style={{...styles.legendColor, backgroundColor: '#28a745'}} />
            Completed
          </div>
        </div>
      </div>
    </div>
  );
};

const styles = {
  container: {
    padding: '20px',
    flex: 1,
    overflowY: 'auto'
  },
  header: {
    marginBottom: '30px'
  },
  filterBar: {
    display: 'flex',
    alignItems: 'center',
    gap: '10px',
    marginBottom: '20px',
    padding: '15px',
    backgroundColor: '#f8f9fa',
    borderRadius: '4px'
  },
  filterSelect: {
    padding: '8px 12px',
    border: '1px solid #ddd',
    borderRadius: '4px',
    fontSize: '14px',
    cursor: 'pointer'
  },
  message: {
    padding: '12px 16px',
    borderRadius: '4px',
    marginBottom: '20px',
    border: '1px solid #0066cc'
  },
  loading: {
    textAlign: 'center',
    padding: '40px',
    color: '#666'
  },
  empty: {
    textAlign: 'center',
    padding: '40px',
    color: '#999'
  },
  processList: {
    display: 'grid',
    gap: '15px',
    marginBottom: '30px'
  },
  processCard: {
    backgroundColor: 'white',
    padding: '20px',
    borderRadius: '8px',
    boxShadow: '0 2px 4px rgba(0,0,0,0.1)',
    cursor: 'pointer',
    transition: 'all 0.3s ease'
  },
  processHeader: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: '15px'
  },
  processStatus: {
    textAlign: 'right'
  },
  statusBadge: {
    padding: '6px 12px',
    borderRadius: '20px',
    color: 'white',
    fontSize: '12px',
    fontWeight: 'bold'
  },
  progressBar: {
    width: '100%',
    height: '8px',
    backgroundColor: '#e0e0e0',
    borderRadius: '4px',
    overflow: 'hidden',
    marginBottom: '15px'
  },
  progressFill: {
    height: '100%',
    transition: 'width 0.3s ease'
  },
  processDetails: {
    marginTop: '15px',
    paddingTop: '15px',
    borderTop: '1px solid #eee'
  },
  detailRow: {
    display: 'flex',
    justifyContent: 'space-between',
    padding: '8px 0',
    fontSize: '14px'
  },
  legend: {
    backgroundColor: '#f8f9fa',
    padding: '20px',
    borderRadius: '8px',
    marginTop: '30px'
  },
  legendItems: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fit, minmax(150px, 1fr))',
    gap: '15px',
    marginTop: '10px'
  },
  legendItem: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
    fontSize: '14px'
  },
  legendColor: {
    width: '20px',
    height: '20px',
    borderRadius: '3px'
  }
};

export default ProcessStatus;
