  import React, { useState, useEffect } from 'react';
  import API_BASE_URL from './config/api';
  import PurchaseRequest from './PurchaseRequest';

  // OOP Java Concept
  // const pr_unitCost = PurchaseRequest.unitCost;
  // const pr_quantity = PurchaseRequest.quantity;
  // const pr_unit = PurchaseRequest.unit;
  // const pr_total_cost = pr_unitCost * pr_quantity;





  const ICSForm = () => {

    // const [pr_unitCost, setPrUnitCost] = useState(null);

    const [prData, setPrData] = useState(null);
    const [prId, setPrId] = useState(null);
    const [prNo, setPrNo] = useState(null);
    const [prAmount, setPrAmount] = useState(null);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [message, setMessage] = useState('');
    const [messageType, setMessageType] = useState('');
    const [sp_value, setSpValue] = useState('SPLV');
    const [unitCostValue, setUnitCostValue] = useState(0);
    const [quantityValue, setQuantityValue] = useState(1);
    const [unitValue, setUnitValue] = useState('');
    const [totalCostValue, setTotalCostValue] = useState('');

    const [item_description, setItemDescription] = useState('');

    const [icsEntryNo, setIcsEntryNo] = useState('');
    const [loading, setLoading] = useState(true);
    const [addEntryNumberEditable, setAddEntryNumberEditable] = useState(false);
    const [formData, setFormData] = useState({

      ics_sp_value: '',
      ics_year: '',
      ics_month: '',
      ics_entry_no: '',

      unit: '',
      unit_of_measure: '',
      unit_cost: 0,
      total_cost: 0,
      item_description: '',
      item_category: '',
      quantity: 1,
      inventory_item_no: '',
      inventory_location: '',
      estimated_useful_life: '',
      person_received_by: '',
      person_receive_from: '',
      position: '',
      date_received: '',
      date_issued: '',
    });


    // const unitPRValue = pr_unitCost > 5000 ? 'SPHV' : 'SPLV';

    useEffect(() => {
    const newTotal = quantityValue * unitCostValue;
    setTotalCostValue(newTotal);
    }, [quantityValue, unitCostValue]);
  
    useEffect(() => {
      // Get PR data from session storage (set by PurchaseRequest workflow)
      const currentPrNo = sessionStorage.getItem('current_pr_no');
      const currentPrId = sessionStorage.getItem('current_pr_id');
      const currentPrAmount = sessionStorage.getItem('current_pr_amount');
      const prCompleteData = sessionStorage.getItem('pr_complete_data');
      
      if (currentPrId) setPrId(parseInt(currentPrId));
      if (currentPrNo) setPrNo(currentPrNo);
      if (currentPrAmount) setPrAmount(parseFloat(currentPrAmount));

      // Use complete PR data from workflow if available
      if (prCompleteData) {
        try {
          const parsedData = JSON.parse(prCompleteData);
          setPrData(parsedData);
          
          // Pre-fill form with all PR data from workflow
          setFormData(prev => ({
            ...prev,
            quantity: parsedData.quantity || 1,
            unit: parsedData.unit || '',
            unit_of_measure: parsedData.unit || '',
            unit_cost: parsedData.unit_cost || 0,
            total_cost: parsedData.total_amount || 0,
            item_description: parsedData.item_description || '',
            inventory_item_no: parsedData.item_no || '',
            inventory_location: 'Storage',
            estimated_useful_life: '',
            person_received_by: sessionStorage.getItem('user_id') || '',
            person_receive_from: parsedData.supplier || '',
            position: '',
            date_received: parsedData.date_requested || new Date().toISOString().split('T')[0],
            date_issued: parsedData.date_requested || new Date().toISOString().split('T')[0]
          }));
          
          setLoading(false);
        } catch (error) {
          console.error('Error parsing PR data:', error);
          setLoading(false);
        }
      } else {
        setLoading(false);
      }
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
          
          // Pre-fill form with PR data
          setFormData(prev => ({
            ...prev,
            ics_no: data.ics_no || '',
            quantity: data.quantity || 1,
            unit: data.unit || '',
            unit_cost: data.unit_cost || 0,
            total_cost: data.total_amount || 0,
            item_description: data.description || data.item_description || '',
            inventory_item_no: data.inventory_item_no || '',
            estimated_useful_life: data.estimated_useful_life || '',
            unit_of_measure: data.unit || '',
            person_received_by: data.requested_by_name || '',
            person_receive_from: data.requested_by_name || '',
            position: data.position || '',
            date_received: data.date_requested || '',
            date_issued: data.date_requested || ''
          }));
        }
      } catch (error) {
        console.warn('Could not fetch PR data from server, using sessionStorage data');
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
      // if (name === 'unit_cost' || name === 'quantity') {
      //   const qty = name === 'quantity' ? parseFloat(value) || 0 : formData.quantity;
      //   const cost = name === 'unit_cost' ? parseFloat(value) || 0 : formData.unit_cost;
      //   const total = qty * cost;
      //   setFormData(prev => ({ ...prev, total_cost: total }));
      // }
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
            <legend style={{ fontSize: '16px', fontWeight: 'bold', color: '#0066cc' }}>ICS No.</legend>
            
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '25px' }}>
              <div style={{ gridColumn: 'span 2' }}>
                <label htmlFor="ics_no" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                  ICS No. *
                </label>

                <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap'}}>
                    
                    <input
                        id="ics_sp_value"
                        name="ics_sp_value"
                        value={formData.ics_sp_value}
                        type="text"
                        onChange={handleInputChange}
                        placeholder={sp_value}
                        rows="3"
                        required
                        style={{ width: '150px', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
                    disabled/>

                    <input
                        id="ics_year"
                        name="ics_year"
                        value={formData.ics_year}
                        type="text"
                        onChange={handleInputChange}
                        placeholder="26ICS"
                        rows="3"
                        required
                        style={{ width: '150px', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
                    disabled/>

                    <input
                        id="ics_month"
                        name="ics_month"
                        value={formData.ics_month}
                        type="text"
                        onChange={handleInputChange}
                        placeholder="01"
                        rows="3"
                        required
                        style={{ width: '150px', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
                    disabled/>
                    
                    
                    <input
                      id="ics_entry_no"
                      name="ics_entry_no"
                      value={formData.ics_entry_no}
                      type="text"
                      onChange={handleInputChange}
                      placeholder="0001"
                      required
                      disabled={!addEntryNumberEditable}
                      readOnly={!addEntryNumberEditable}
                      style={{ 
                        width: '150px', 
                        padding: '10px', 
                        border: '1px solid #ddd', 
                        borderRadius: '4px',
                        backgroundColor: addEntryNumberEditable ? '#fff' : '#f5f5f5'
                      }}
                    />
                    
                    <button 
                      type="button"
                      className="entry-number-edit-btn"
                      onClick={() => {
                        setAddEntryNumberEditable(!addEntryNumberEditable);
                        if (!addEntryNumberEditable) {
                          setTimeout(() => document.getElementById("ics_entry_no").focus(), 0);
                        }
                      }}
                      title="Edit Entry Number"
                      style={{
                        padding: '8px 12px',
                        cursor: 'pointer',
                        background: '#f0f0f0',
                        border: '1px solid #ddd',
                        borderRadius: '4px',
                        display: 'inline-flex',
                        alignItems: 'center'
                      }}
                    >
                      <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2">
                        <path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path>
                      </svg>
                    </button>
                  </div>

                {/* <div style={{ display: 'flex', gap: '25px', flexWrap: 'wrap' }}>
                  <label htmlFor="ics_sp_value" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>

                </label>
                <input
                  id="ics_sp_value"
                  name="ics_sp_value"
                  value={formData.ics_sp_value}
                  type="text"
                  onChange={handleInputChange}
                  placeholder="SPLV | SPHV"
                  rows="3"
                  required
                  style={{ width: '150px', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
                disabled/>

                <input
                  id="ics_year"
                  name="ics_year"
                  value={formData.ics_year}
                  type="text"
                  onChange={handleInputChange}
                  placeholder="26ICS"
                  rows="3"
                  required
                  style={{ width: '150px', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
                disabled/>


                <input
                  id="ics_month"
                  name="ics_month"
                  value={formData.ics_month}
                  type="text"
                  onChange={handleInputChange}
                  placeholder="01"
                  rows="3"
                  required
                  style={{ width: '150px', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
                disabled/>

                <input
                  id="ics_entry_no"
                  name="ics_entry_no"
                  value={formData.ics_entry_no}
                  type="text"
                  onChange={handleInputChange}
                  placeholder="0001"
                  rows="3"
                  required
                  style={{ width: '150px', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
                  disabled/>

                                <div style={{ height: '10px', width: 'auto',  }}>
                  <button 
              type="button"
              className="entry-number-edit-btn"
              onClick={() => {
                setAddEntryNumberEditable(!addEntryNumberEditable);
                if (!addEntryNumberEditable) {
                  setTimeout(() => document.getElementById("entryNumber").focus(), 0);
                }
              }}
              title="Edit Entry Number"
            >
              <svg viewBox="0 0 3 3" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path>
              </svg>
            </button>

                </div>
                
                    </div> */}
            
                    </div> 

            </div>


          </fieldset>

          {/* Section 2: Quantity & Cost */}
          <fieldset style={{ border: '1px solid #ddd', padding: '20px', borderRadius: '8px' }}>
            <legend style={{ fontSize: '16px', fontWeight: 'bold', color: '#0066cc' }}>2. Quantity & Cost</legend>
            
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '15px' }}>
              <div>
                <label htmlFor="quantityValue" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                  Quantity *
                </label>
                <input
                  id="quantityValue"
                  type="number"
                  name="quantity"
                  value={quantityValue}
                  onChange={(e) => setQuantityValue(e.target.value)}
                  min="1"
                  required
                  style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
                />
              </div>

              <div>
                <label htmlFor="unitValue" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                  Unit
                </label>
                <select
                  id="unitValue"
                  name="unit"
                  value={unitValue}
                  onChange={(e) => setUnitValue(e.target.value)}
                  required
                  style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
                >
                  <option value="set">set</option>
                  <option value="piece">piece</option>
                  <option value="ream">ream</option>
                  <option value="box">box</option>
                  <option value="dozen">dozen</option>
                </select>
              </div>

              {/* <div>
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
              </div> */}

              

              <div>
                <label htmlFor="unitCostValue" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                  Unit Cost (₱) *
                </label>
                <input
                  id="unitCostValue"
                  type="number"
                  name="unit_cost"
                  value={unitCostValue}
                  onChange={handleInputChange}
                  min="0"
                  step="0.01"
                  required
                  style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
                />
              </div>

              <div>
                <label htmlFor="totalCostValue" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                  Total Cost (₱) *
                </label>
                <input
                  id="totalCostValue"
                  type="number"
                  name="total_cost"
                  value={totalCostValue}
                  readOnly
                  style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px', backgroundColor: '#f5f5f5' }}
                />
                <small style={{ color: '#666' }}>Auto-calculated: Quantity × Unit Cost</small>
              </div>
            </div>
          </fieldset>

          {/* Section 3: Acquisition Details */}
          <fieldset style={{ border: '1px solid #ddd', padding: '20px', borderRadius: '8px' }}>
            <legend style={{ fontSize: '16px', fontWeight: 'bold', color: '#0066cc' }}>3. Description</legend>
            
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '15px' }}>
              <div>
                <label htmlFor="item_description" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                  Item Description *
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
                  <option value="">-- Select Category --</option>
                  <option value="consumable">Consumable Supplies</option>
                  <option value="tools">Tools & Equipment</option>
                  <option value="supplies">Office Supplies</option>
                  <option value="furniture">Furniture & Fixtures</option>
                  <option value="misc">Miscellaneous</option>
                </select>
              </div>

              {/* <div>
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
              </div> */}

              {/* <div>
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
              </div> */}
            </div>
          </fieldset>

          {/* Section 4: Inventory Location & Responsibility */}
          <fieldset style={{ border: '1px solid #ddd', padding: '20px', borderRadius: '8px' }}>
            <legend style={{ fontSize: '16px', fontWeight: 'bold', color: '#0066cc' }}>4. Inventory Location & Responsibility</legend>
            
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '15px' }}>
              <div>
                <label htmlFor="inventory_location" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                  Storage Location *
                </label>
                <input
                  id="inventory_location"
                  type="text"
                  name="inventory_location"
                  value={formData.inventory_location}
                  onChange={handleInputChange}
                  placeholder="e.g., Supply Room, Warehouse, Office, Storage Bin A"
                  required
                  style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
                />
              </div>

              <div>
                <label htmlFor="issued_to" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                  Estimated Useful Life 
                </label>
                <input
                  id="estimated_useful_life"
                  type="text"
                  name="Estimated Useful Life"
                  value={formData.estimated_useful_life}
                  onChange={handleInputChange}
                  placeholder="e.g., 5 years, 1000 hours, maintenance annually"
                  style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
                />
              </div>

              {/* <div>
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
              </div> */}
            </div>
          </fieldset>

          {/* Section 5: Remarks */}
          <fieldset style={{ border: '1px solid #ddd', padding: '20px', borderRadius: '8px' }}>
            <legend style={{ fontSize: '16px', fontWeight: 'bold', color: '#0066cc' }}>5. Involved Personnel</legend>
            
            <div>
              <label htmlFor="remarks" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Received by:
              </label>
              <textarea
                id="person_received_by"
                name="person_received_by"
                value={formData.person_received_by}
                onChange={handleInputChange}
                placeholder="Name and designation of the person who received the item"
                rows="4"
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>
            <div>
              <label htmlFor="remarks" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Received from:
              </label>
              <textarea
                id="person_received_from" 
                name="person_received_from"
                value={formData.person_received_from}
                onChange={handleInputChange}
                placeholder="Name and designation of the person the item was from"
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
