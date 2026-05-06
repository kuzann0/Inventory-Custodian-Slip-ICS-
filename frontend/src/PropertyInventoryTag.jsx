import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import API_BASE_URL from './config/api';

const PropertyInventoryTag = () => {
  const navigate = useNavigate();
  const [prData, setPrData] = useState(null);
  const [prId, setPrId] = useState(null);
  const [formData, setFormData] = useState({
    property_number: '',
    model_number: '',
    description: '',
    unit_cost: '',
    acquisition_date: '',
    assignee: '',
    estimated_cost: '',
    serial_number: '',
    location: '',
    inspected_by: '',
    status: 'serviceable'
  });
  const [message, setMessage] = useState('');
  const [messageType, setMessageType] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Get PR data from session storage (stored from PurchaseRequest workflow)
    const prno = sessionStorage.getItem('current_pr_no');
    const currentPrId = sessionStorage.getItem('current_pr_id');
    const prCompleteData = sessionStorage.getItem('pr_complete_data');
    
    if (currentPrId) {
      setPrId(parseInt(currentPrId));
    }

    // Try to get data from stored complete PR data first
    if (prCompleteData) {
      try {
        const parsedData = JSON.parse(prCompleteData);
        setPrData(parsedData);
        setFormData(prev => ({
          ...prev,
          description: parsedData.item_description || '',
          unit_cost: parsedData.unit_cost || '',
          acquisition_date: parsedData.po_date || parsedData.date_requested || '',
          estimated_cost: parsedData.total_amount || '',
          assignee: parsedData.assignee || '',
          inspected_by: parsedData.inspected_by || ''
        }));  
      } catch (error) {
        console.error('Error parsing PR data:', error);
      }
    }

    // Don't need to fetch separately since we have all data from workflow
    setLoading(false);
  }, []);

  const fetchPRData = async (prno) => {
    // This function is deprecated - data is now loaded from sessionStorage
    // Keeping for backwards compatibility
    try {
      const response = await fetch(`${API_BASE_URL}/get_pr_details.php?pr_no=${prno}`, {
        credentials: 'include'
      });
      if (response.ok) {
        const data = await response.json();
        setPrData(data);
        setFormData(prev => ({
          ...prev,
          description: data.description || '',
          unit_cost: data.unit_cost || '',
          acquisition_date: data.date_acquired || '',
          estimated_cost: data.total_cost || ''
        }));
      }
    } catch (error) {
      // Silently fail - data from sessionStorage is used as primary source
      console.warn('Could not fetch PR data from server, using sessionStorage data');
    }
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    // Validate required fields
    if (!formData.property_number || !formData.description) {
      setMessage('Property Number and Description are required');
      setMessageType('error');
      return;
    }

    try {
      const response = await fetch(`${API_BASE_URL}/submit_property_tag.php`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({
          pr_id: prId,
          pr_no: sessionStorage.getItem('current_pr_no'),
          ...formData
        })
      });

      const result = await response.json();

      if (result.success) {
        setMessage('✓ Property Inventory Tag created successfully!');
        setMessageType('success');
        
        // Call complete_process endpoint to finalize workflow
        try {
          const completeResponse = await fetch(`${API_BASE_URL}/complete_process.php`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include',
            body: JSON.stringify({ pr_id: prId })
          });
          
          const completeResult = await completeResponse.json();
          
          if (completeResult.success) {
            sessionStorage.setItem('process_completed', 'true');
            setTimeout(() => {
              // Trigger completion modal
              window.dispatchEvent(new CustomEvent('processCompleted', {
                detail: { pr_no: sessionStorage.getItem('current_pr_no') }
              }));
              
              // Redirect to dashboard after 3 seconds to allow user to see the completion modal
              setTimeout(() => {
                navigate('/dashboard');
              }, 3000);
            }, 1500);
          }
        } catch (completeError) {
          console.error('Error completing process:', completeError);
          // Still redirect even if complete_process fails
          setTimeout(() => navigate('/dashboard'), 2000);
        }
      } else {
        setMessage(result.error || 'Failed to submit property tag');
        setMessageType('error');
      }
    } catch (error) {
      console.error('Error submitting property tag:', error);
      setMessage('Error submitting property tag');
      setMessageType('error');
    }
  };

  if (loading) {
    return <div style={styles.loading}>Loading...</div>;
  }

  return (
    <div style={styles.container}>
      <div style={styles.header}>
        <h2>Property Inventory Tag</h2>
        <p>Register item as fixed asset (ABOVE PAR - Amount ≥ ₱50,000)</p>
      </div>

      {message && (
        <div style={{
          ...styles.message,
          backgroundColor: messageType === 'success' ? '#d4edda' : '#f8d7da',
          color: messageType === 'success' ? '#155724' : '#721c24',
          borderColor: messageType === 'success' ? '#c3e6cb' : '#f5c6cb'
        }}>
          {message}
        </div>
      )}

      <form onSubmit={handleSubmit} style={styles.form}>
        <div style={styles.formSection}>
          <h3>Asset Information</h3>

          <div style={styles.formRow}>
            <div style={styles.formGroup}>
              <label>Property Number *</label>
              <input
                type="text"
                name="property_number"
                placeholder="e.g., PROP-2026-001"
                value={formData.property_number}
                onChange={handleInputChange}
                style={styles.input}
                required
              />
            </div>
            <div style={styles.formGroup}>
              <label>Model Number</label>
              <input
                type="text"
                name="model_number"
                placeholder="e.g., Dell-XPS-15"
                value={formData.model_number}
                onChange={handleInputChange}
                style={styles.input}
              />
            </div>
          </div>

          <div style={styles.formGroup}>
            <label>Description *</label>
            <input
              type="text"
              name="description"
              placeholder="Item description"
              value={formData.description}
              onChange={handleInputChange}
              style={styles.input}
              required
            />
          </div>

          <div style={styles.formRow}>
            <div style={styles.formGroup}>
              <label>Serial Number</label>
              <input
                type="text"
                name="serial_number"
                placeholder="Serial No."
                value={formData.serial_number}
                onChange={handleInputChange}
                style={styles.input}
              />
            </div>
            {/* <div style={styles.formGroup}>
              <label>Unit of Measure</label>
              <input
                type="text"
                name="unit_cost"
                placeholder="e.g., pc, set, box"
                value={formData.unit_cost}
                onChange={handleInputChange}
                style={styles.input}
              />
            </div> */}
          </div>

          <div style={styles.formRow}>
            <div style={styles.formGroup}>
              <label>Inventory Date</label>
              <input
                type="date"
                name="inventory_date"
                value={formData.inventory_date}
                onChange={handleInputChange}
                style={styles.input}
              />
            </div>
            <div style={styles.formGroup}>
              <label>Unit Cost</label>
              <input
                type="number"
                name="unit_cost"
                placeholder="0.00"
                value={formData.unit_cost}
                onChange={handleInputChange}
                style={styles.input}
                step="0.01"
              />
            </div>
          </div>

          <div style={styles.formRow}>
            <div style={styles.formGroup}>
              <label>Assignee</label>
              <input
                type="text"
                name="assignee"
                placeholder="Assignee name"
                value={formData.assignee}
                onChange={handleInputChange}
                style={styles.input}
              />
            </div>
            <div style={styles.formGroup}>
              <label>Location</label>
              <input
                type="text"
                name="location"
                placeholder="Storage location"
                value={formData.location}
                onChange={handleInputChange}
                style={styles.input}
              />
            </div>
          </div>

          <div style={styles.formGroup}>
            <label>Asset Status</label>
            <select
              name="status"
              value={formData.status}
              onChange={handleInputChange}
              style={styles.input}
            >
              <option value="serviceable">Serviceable</option>
              <option value="under_repair">Under Repair</option>
              <option value="obsolete">Obsolete</option>
              <option value="for_disposal">For Disposal</option>
            </select>
          </div>
             <  div style={styles.formGroup}>
              <label>Inspected By</label>
              <input
                type="text"
                name="inspected"
                placeholder="Inspector Name"
                value={formData.inspected_by}
                onChange={handleInputChange}
                style={styles.input}
              />
            </div>
        </div>



        <div style={styles.buttonGroup}>
          <button
            type="submit"
            style={{...styles.button, backgroundColor: '#28a745'}}
          >
            Submit Property Tag
          </button>
          <button
            type="button"
            style={{...styles.button, backgroundColor: '#6c757d'}}
            onClick={() => window.history.back()}
          >
            Cancel
          </button>
        </div>
      </form>
    </div>
  );
};

const styles = {
  container: {
    padding: '30px',
    maxWidth: '800px',
    margin: '0 auto'
  },
  header: {
    marginBottom: '30px',
    paddingBottom: '20px',
    borderBottom: '2px solid #007bff'
  },
  message: {
    padding: '12px 16px',
    borderRadius: '4px',
    marginBottom: '20px',
    border: '1px solid',
    display: 'flex',
    alignItems: 'center',
    gap: '10px'
  },
  form: {
    backgroundColor: 'white',
    padding: '20px',
    borderRadius: '8px',
    boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
  },
  formSection: {
    marginBottom: '25px'
  },
  formGroup: {
    marginBottom: '20px'
  },
  formRow: {
    display: 'grid',
    gridTemplateColumns: '1fr 1fr',
    gap: '20px'
  },
  input: {
    width: '100%',
    padding: '10px 12px',
    border: '1px solid #ddd',
    borderRadius: '4px',
    fontSize: '14px',
    boxSizing: 'border-box'
  },
  button: {
    padding: '12px 24px',
    color: 'white',
    border: 'none',
    borderRadius: '4px',
    cursor: 'pointer',
    fontSize: '14px',
    fontWeight: 'bold'
  },
  buttonGroup: {
    display: 'flex',
    gap: '10px',
    justifyContent: 'flex-end'
  },
  loading: {
    textAlign: 'center',
    padding: '40px'
  }
};

export default PropertyInventoryTag;
