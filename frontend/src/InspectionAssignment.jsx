import React, { useState, useEffect } from 'react';
import API_BASE_URL from './config/api';

const InspectionAssignment = () => {
  const [assignments, setAssignments] = useState([]);
  const [loading, setLoading] = useState(false);
  const [selectedAssignment, setSelectedAssignment] = useState(null);
  const [inspectionNotes, setInspectionNotes] = useState('');
  const [submitMessage, setSubmitMessage] = useState('');
  const [messageType, setMessageType] = useState(''); // 'success' or 'error'

  useEffect(() => {
    fetchAssignments();
  }, []);

  const fetchAssignments = async () => {
    setLoading(true);
    try {
      const response = await fetch(`${API_BASE_URL}/get_inspection_assignments.php`, {
        credentials: 'include'
      });
      if (response.ok) {
        const data = await response.json();
        setAssignments(data.assignments || []);
      }
    } catch (error) {
      console.error('Error fetching assignments:', error);
      setSubmitMessage('Failed to load assignments');
      setMessageType('error');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmitInspection = async (assignmentId) => {
    if (!inspectionNotes.trim()) {
      setSubmitMessage('Please add inspection notes');
      setMessageType('error');
      return;
    }

    try {
      const response = await fetch(`${API_BASE_URL}/submit_inspection.php`, {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          assignment_id: assignmentId,
          inspection_notes: inspectionNotes,
          status: 'inspected'
        })
      });

      const result = await response.json();
      
      if (result.success) {
        setSubmitMessage('✓ Inspection submitted successfully');
        setMessageType('success');
        setInspectionNotes('');
        setSelectedAssignment(null);
        fetchAssignments();
        setTimeout(() => setSubmitMessage(''), 3000);
      } else {
        setSubmitMessage(result.error || 'Failed to submit inspection');
        setMessageType('error');
      }
    } catch (error) {
      console.error('Error submitting inspection:', error);
      setSubmitMessage('Error submitting inspection');
      setMessageType('error');
    }
  };

  return (
    <div style={styles.container}>
      <div style={styles.header}>
        <h2>Inspection & Assignment</h2>
        <p>Review and assign items for inspection</p>
      </div>

      {submitMessage && (
        <div style={{
          ...styles.message,
          backgroundColor: messageType === 'success' ? '#d4edda' : '#f8d7da',
          color: messageType === 'success' ? '#155724' : '#721c24',
          borderColor: messageType === 'success' ? '#c3e6cb' : '#f5c6cb'
        }}>
          {submitMessage}
        </div>
      )}

      {loading ? (
        <div style={styles.loading}>Loading assignments...</div>
      ) : assignments.length === 0 ? (
        <div style={styles.empty}>No pending assignments</div>
      ) : (
        <div style={styles.table}>
          <table style={styles.tableElement}>
            <thead>
              <tr>
                <th>PR No.</th>
                <th>Item</th>
                <th>Quantity</th>
                <th>Unit Cost</th>
                <th>Assigned To</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {assignments.map((assignment) => (
                <tr key={assignment.id}>
                  <td>{assignment.pr_no}</td>
                  <td>{assignment.item_name}</td>
                  <td>{assignment.quantity}</td>
                  <td>₱{parseFloat(assignment.unit_cost).toFixed(2)}</td>
                  <td>{assignment.assigned_to}</td>
                  <td>
                    <span style={{
                      ...styles.badge,
                      backgroundColor: assignment.status === 'pending' ? '#ffc107' : '#28a745'
                    }}>
                      {assignment.status}
                    </span>
                  </td>
                  <td>
                    <button
                      style={styles.button}
                      onClick={() => setSelectedAssignment(assignment.id)}
                    >
                      Inspect
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {selectedAssignment && (
        <div style={styles.modal}>
          <div style={styles.modalContent}>
            <h3>Submit Inspection Notes</h3>
            <textarea
              style={styles.textarea}
              placeholder="Enter inspection notes, condition report, findings..."
              value={inspectionNotes}
              onChange={(e) => setInspectionNotes(e.target.value)}
              rows="6"
            />
            <div style={styles.modalButtons}>
              <button
                style={{...styles.primaryButton, backgroundColor: '#007bff'}}
                onClick={() => handleSubmitInspection(selectedAssignment)}
              >
                Submit Inspection
              </button>
              <button
                style={{...styles.primaryButton, backgroundColor: '#6c757d'}}
                onClick={() => {
                  setSelectedAssignment(null);
                  setInspectionNotes('');
                }}
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
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
  message: {
    padding: '12px 16px',
    borderRadius: '4px',
    marginBottom: '20px',
    border: '1px solid'
  },
  loading: {
    textAlign: 'center',
    padding: '40px',
    color: '#666'
  },
  empty: {
    textAlign: 'center',
    padding: '40px',
    color: '#999',
    fontSize: '16px'
  },
  table: {
    overflowX: 'auto'
  },
  tableElement: {
    width: '100%',
    borderCollapse: 'collapse',
    backgroundColor: 'white',
    borderRadius: '8px',
    boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
  },
  badge: {
    padding: '4px 8px',
    borderRadius: '4px',
    color: 'white',
    fontSize: '12px'
  },
  button: {
    padding: '6px 12px',
    backgroundColor: '#007bff',
    color: 'white',
    border: 'none',
    borderRadius: '4px',
    cursor: 'pointer',
    fontSize: '12px'
  },
  primaryButton: {
    padding: '10px 20px',
    color: 'white',
    border: 'none',
    borderRadius: '4px',
    cursor: 'pointer',
    fontSize: '14px'
  },
  modal: {
    position: 'fixed',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0,0,0,0.5)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 1000
  },
  modalContent: {
    backgroundColor: 'white',
    padding: '30px',
    borderRadius: '8px',
    width: '90%',
    maxWidth: '500px'
  },
  textarea: {
    width: '100%',
    padding: '10px',
    marginBottom: '20px',
    border: '1px solid #ddd',
    borderRadius: '4px',
    fontFamily: 'Arial, sans-serif',
    fontSize: '14px'
  },
  modalButtons: {
    display: 'flex',
    gap: '10px',
    justifyContent: 'flex-end'
  }
};

export default InspectionAssignment;
