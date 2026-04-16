import React, { useState, useEffect } from 'react';
import API_BASE_URL from './config/api';

const ICSForm = () => {
  const [prData, setPrData] = useState(null);
  const [prId, setPrId] = useState(null);
  const [prNo, setPrNo] = useState(null);
  const [prAmount, setPrAmount] = useState(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [message, setMessage] = useState('');
  const [messageType, setMessageType] = useState('');
  const [loading, setLoading] = useState(true);

  const [formData, setFormData] = useState({
    item_description: '',
    item_category: 'consumable',
    unit_of_measure: '',
    quantity: 1,
    unit_cost: 0,
    total_cost: 0,
    supplier_name: '',
    invoice_number: '',
    receipt_date: '',
    inventory_location: '',
    issued_to: '',
    remarks: '',
    physical_condition: 'good'
  });

  useEffect(() => {
    // Get PR data from session
    const currentPrNo = sessionStorage.getItem('current_pr_no');
    const currentPrId = sessionStorage.getItem('current_pr_id');
    const currentPrAmount = sessionStorage.getItem('current_pr_amount');
    
    if (currentPrId) setPrId(parseInt(currentPrId));
    if (currentPrNo) setPrNo(currentPrNo);
    if (currentPrAmount) setPrAmount(parseFloat(currentPrAmount));

    if (currentPrNo) {
      fetchPRData(currentPrNo);
    } else {
      setLoading(false);
    }
  }, []);

  const fetchPRData = async (prno) => {
    try {
      const response = await fetch(`${API_BASE_URL}/get_pr_details.php?pr_no=${prno}`, {
        credentials: 'include'
      });
      if (response.ok) {
        const data = await response.json();
        setPrData(data);
        
        // Pre-fill form with PR data
        setFormData(prev => ({
          ...prev,
          item_description: data.description || data.item_description || '',
          supplier_name: data.supplier_name || '',
          unit_of_measure: data.unit || '',
          quantity: data.quantity || 1,
          unit_cost: data.unit_cost || 0,
          total_cost: data.total_amount || 0
        }));
      }
    } catch (error) {
      console.error('Error fetching PR data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e) => {
    const { name, value, type } = e.target;
    const newValue = type === 'number' ? parseFloat(value) || 0 : value;
    
    setFormData(prev => ({
      ...prev,
      [name]: newValue
    }));

    // Auto-calculate total cost
    if (name === 'unit_cost' || name === 'quantity') {
      const qty = name === 'quantity' ? parseFloat(value) || 0 : formData.quantity;
      const cost = name === 'unit_cost' ? parseFloat(value) || 0 : formData.unit_cost;
      const total = qty * cost;
      setFormData(prev => ({ ...prev, total_cost: total }));
    }
  };

  const handleSelectChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);
    setMessage('');

    try {
      const submissionData = {
        ...formData,
        pr_id: prId,
        pr_no: prNo,
        user_id: sessionStorage.getItem('user_id') || 1
      };

      const response = await fetch(`${API_BASE_URL}/submit_ics_form.php`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': sessionStorage.getItem('user_id') || '1'
        },
        credentials: 'include',
        body: JSON.stringify(submissionData)
      });

      const result = await response.json();

      if (response.ok && result.success) {
        setMessage('✓ ICS Form submitted successfully! Purchase Request workflow complete.');
        setMessageType('success');

        // Navigate to dashboard after a short delay
        setTimeout(() => {
          window.location.href = '/dashboard';
        }, 2000);
      } else {
        setMessage(`Error: ${result.message || 'Failed to submit ICS form'}`);
        setMessageType('error');
      }
    } catch (error) {
      console.error('Error submitting form:', error);
      setMessage(`Error: ${error.message}`);
      setMessageType('error');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (loading) {
    return <div style={{ padding: '20px' }}>Loading...</div>;
  }

  return (
    <div style={{ padding: '20px', maxWidth: '900px' }}>
      <div style={{ marginBottom: '30px' }}>
        <h2>Inventory Form - ICS (LESS: ₱ &lt; 50,000)</h2>
        <p style={{ color: '#666', marginTop: '10px' }}>
          LESS: ICS Inventory Form for items under ₱50,000
        </p>
        {prNo && (
          <p style={{ marginTop: '10px', fontSize: '14px', color: '#0066cc', fontWeight: 'bold' }}>
            PR: {prNo} | Amount: ₱{prAmount?.toFixed(2)}
          </p>
        )}
      </div>

      <form onSubmit={handleSubmit} style={{ display: 'grid', gap: '20px' }}>
        {/* Section 1: Item Description */}
        <fieldset style={{ border: '1px solid #ddd', padding: '20px', borderRadius: '8px' }}>
          <legend style={{ fontSize: '16px', fontWeight: 'bold', color: '#0066cc' }}>1. Item Description</legend>
          
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '15px' }}>
            <div style={{ gridColumn: 'span 2' }}>
              <label htmlFor="item_description" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Item/Equipment Description *
              </label>
              <textarea
                id="item_description"
                name="item_description"
                value={formData.item_description}
                onChange={handleInputChange}
                placeholder="e.g., Office Supplies, Tools, Small Equipment"
                rows="3"
                required
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>

            <div>
              <label htmlFor="item_category" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Item Category *
              </label>
              <select
                id="item_category"
                name="item_category"
                value={formData.item_category}
                onChange={handleSelectChange}
                required
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              >
                <option value="consumable">Consumable Supplies</option>
                <option value="tools">Tools & Equipment</option>
                <option value="supplies">Office Supplies</option>
                <option value="furniture">Furniture & Fixtures</option>
                <option value="misc">Miscellaneous</option>
              </select>
            </div>
          </div>
        </fieldset>

        {/* Section 2: Quantity & Cost */}
        <fieldset style={{ border: '1px solid #ddd', padding: '20px', borderRadius: '8px' }}>
          <legend style={{ fontSize: '16px', fontWeight: 'bold', color: '#0066cc' }}>2. Quantity & Cost</legend>
          
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '15px' }}>
            <div>
              <label htmlFor="quantity" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Quantity *
              </label>
              <input
                id="quantity"
                type="number"
                name="quantity"
                value={formData.quantity}
                onChange={handleInputChange}
                min="1"
                required
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>

            <div>
              <label htmlFor="unit_of_measure" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Unit of Measure *
              </label>
              <input
                id="unit_of_measure"
                type="text"
                name="unit_of_measure"
                value={formData.unit_of_measure}
                onChange={handleInputChange}
                placeholder="e.g., piece, ream, box, dozen"
                required
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>

            <div>
              <label htmlFor="unit_cost" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Unit Cost (₱) *
              </label>
              <input
                id="unit_cost"
                type="number"
                name="unit_cost"
                value={formData.unit_cost}
                onChange={handleInputChange}
                min="0"
                step="0.01"
                required
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>

            <div>
              <label htmlFor="total_cost" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Total Cost (₱) *
              </label>
              <input
                id="total_cost"
                type="number"
                name="total_cost"
                value={formData.total_cost.toFixed(2)}
                readOnly
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px', backgroundColor: '#f5f5f5' }}
              />
              <small style={{ color: '#666' }}>Auto-calculated: Quantity × Unit Cost</small>
            </div>
          </div>
        </fieldset>

        {/* Section 3: Acquisition Details */}
        <fieldset style={{ border: '1px solid #ddd', padding: '20px', borderRadius: '8px' }}>
          <legend style={{ fontSize: '16px', fontWeight: 'bold', color: '#0066cc' }}>3. Acquisition Details</legend>
          
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '15px' }}>
            <div>
              <label htmlFor="supplier_name" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Supplier/Vendor Name
              </label>
              <input
                id="supplier_name"
                type="text"
                name="supplier_name"
                value={formData.supplier_name}
                onChange={handleInputChange}
                placeholder="Name of supplier or vendor"
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>

            <div>
              <label htmlFor="invoice_number" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Invoice/Bill Number
              </label>
              <input
                id="invoice_number"
                type="text"
                name="invoice_number"
                value={formData.invoice_number}
                onChange={handleInputChange}
                placeholder="Invoice or bill reference number"
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>

            <div>
              <label htmlFor="receipt_date" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Date of Receipt
              </label>
              <input
                id="receipt_date"
                type="date"
                name="receipt_date"
                value={formData.receipt_date}
                onChange={handleInputChange}
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>
          </div>
        </fieldset>

        {/* Section 4: Inventory Location & Responsibility */}
        <fieldset style={{ border: '1px solid #ddd', padding: '20px', borderRadius: '8px' }}>
          <legend style={{ fontSize: '16px', fontWeight: 'bold', color: '#0066cc' }}>4. Inventory Location & Responsibility</legend>
          
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '15px' }}>
            <div>
              <label htmlFor="inventory_location" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Storage/Inventory Location *
              </label>
              <input
                id="inventory_location"
                type="text"
                name="inventory_location"
                value={formData.inventory_location}
                onChange={handleInputChange}
                placeholder="e.g., Supply Room, Warehouse, Office"
                required
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>

            <div>
              <label htmlFor="issued_to" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Issued To / Responsible Person
              </label>
              <input
                id="issued_to"
                type="text"
                name="issued_to"
                value={formData.issued_to}
                onChange={handleInputChange}
                placeholder="Name and designation of responsible person"
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>

            <div>
              <label htmlFor="physical_condition" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Physical Condition *
              </label>
              <select
                id="physical_condition"
                name="physical_condition"
                value={formData.physical_condition}
                onChange={handleSelectChange}
                required
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              >
                <option value="good">Good</option>
                <option value="acceptable">Acceptable</option>
                <option value="fair">Fair</option>
                <option value="poor">Poor</option>
                <option value="damaged">Damaged</option>
              </select>
            </div>
          </div>
        </fieldset>

        {/* Section 5: Remarks */}
        <fieldset style={{ border: '1px solid #ddd', padding: '20px', borderRadius: '8px' }}>
          <legend style={{ fontSize: '16px', fontWeight: 'bold', color: '#0066cc' }}>5. Remarks & Additional Information</legend>
          
          <div>
            <label htmlFor="remarks" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
              Remarks/Notes
            </label>
            <textarea
              id="remarks"
              name="remarks"
              value={formData.remarks}
              onChange={handleInputChange}
              placeholder="Any additional notes or special instructions"
              rows="4"
              style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
            />
          </div>
        </fieldset>

        {/* Form Actions */}
        <div style={{ display: 'flex', gap: '15px', marginTop: '30px' }}>
          <button
            type="submit"
            disabled={isSubmitting}
            style={{
              padding: '12px 30px',
              fontSize: '16px',
              backgroundColor: '#0066cc',
              color: 'white',
              border: 'none',
              borderRadius: '4px',
              cursor: isSubmitting ? 'not-allowed' : 'pointer',
              opacity: isSubmitting ? 0.6 : 1
            }}
          >
            {isSubmitting ? 'Submitting...' : 'Complete & Submit'}
          </button>
          
          <button
            type="button"
            onClick={() => window.history.back()}
            style={{
              padding: '12px 30px',
              fontSize: '16px',
              backgroundColor: '#666',
              color: 'white',
              border: 'none',
              borderRadius: '4px',
              cursor: 'pointer'
            }}
          >
            Back
          </button>
        </div>
      </form>

      {message && (
        <div
          style={{
            marginTop: '20px',
            padding: '15px',
            borderRadius: '4px',
            backgroundColor: messageType === 'success' ? '#d4edda' : '#f8d7da',
            color: messageType === 'success' ? '#155724' : '#721c24',
            border: `1px solid ${messageType === 'success' ? '#c3e6cb' : '#f5c6cb'}`
          }}
        >
          {message}
        </div>
      )}
    </div>
  );
};

export default ICSForm;
