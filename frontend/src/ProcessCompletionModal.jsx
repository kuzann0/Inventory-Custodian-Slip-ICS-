import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import API_BASE_URL from './config/api';

const ProcessCompletionModal = ({ isOpen, prNo, onClose }) => {
  const navigate = useNavigate();
  const [summary, setSummary] = useState(null);

  useEffect(() => {
    if (isOpen && prNo) {
      fetchProcessSummary(prNo);
    }
  }, [isOpen, prNo]);

  const fetchProcessSummary = async (pr) => {
    try {
      const response = await fetch(`${API_BASE_URL}/get_process_summary.php?pr_no=${pr}`, {
        credentials: 'include'
      });
      if (response.ok) {
        const data = await response.json();
        setSummary(data);
      }
    } catch (error) {
      console.error('Error fetching summary:', error);
    }
  };

  const handleClose = () => {
    // Clear session data
    sessionStorage.removeItem('current_pr_no');
    sessionStorage.removeItem('process_completed');
    onClose();
    // Redirect to dashboard
    navigate('/dashboard');
  };

  if (!isOpen) return null;

  return (
    <div style={styles.overlay}>
      <div style={styles.modal}>
        <div style={styles.checkmark}>✓</div>
        <h2>Process Completed Successfully!</h2>
        
        {summary && (
          <div style={styles.summary}>
            <div style={styles.summaryRow}>
              <span>PR Number:</span>
              <strong>{summary.pr_no}</strong>
            </div>
            <div style={styles.summaryRow}>
              <span>Total Amount:</span>
              <strong>₱{parseFloat(summary.total_amount || 0).toFixed(2)}</strong>
            </div>
            <div style={styles.summaryRow}>
              <span>Category:</span>
              <strong>{summary.category}</strong>
            </div>
            <div style={styles.summaryRow}>
              <span>Completed Date:</span>
              <strong>{new Date().toLocaleDateString()}</strong>
            </div>
          </div>
        )}

        <p style={styles.message}>
          All required documentation has been completed and filed. 
          The inventory item has been registered in the system.
        </p>

        <button style={styles.button} onClick={handleClose}>
          OK - Return to Dashboard
        </button>
      </div>
    </div>
  );
};

const styles = {
  overlay: {
    position: 'fixed',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0,0,0,0.6)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 2000
  },
  modal: {
    backgroundColor: 'white',
    borderRadius: '12px',
    padding: '40px',
    maxWidth: '500px',
    width: '90%',
    textAlign: 'center',
    boxShadow: '0 10px 40px rgba(0,0,0,0.2)'
  },
  checkmark: {
    width: '80px',
    height: '80px',
    borderRadius: '50%',
    backgroundColor: '#28a745',
    color: 'white',
    fontSize: '48px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    margin: '0 auto 20px',
    fontWeight: 'bold'
  },
  summary: {
    backgroundColor: '#f8f9fa',
    padding: '20px',
    borderRadius: '8px',
    margin: '20px 0',
    textAlign: 'left'
  },
  summaryRow: {
    display: 'flex',
    justifyContent: 'space-between',
    padding: '10px 0',
    borderBottom: '1px solid #e0e0e0'
  },
  message: {
    color: '#666',
    fontSize: '14px',
    marginBottom: '25px',
    lineHeight: '1.6'
  },
  button: {
    padding: '12px 40px',
    backgroundColor: '#28a745',
    color: 'white',
    border: 'none',
    borderRadius: '4px',
    fontSize: '16px',
    fontWeight: 'bold',
    cursor: 'pointer'
  }
};

export default ProcessCompletionModal;
