import React, { useState, useEffect } from 'react';
import API_BASE_URL from './config/api';

const PPEForm = () => {
  const [prData, setPrData] = useState(null);
  const [prId, setPrId] = useState(null);
  const [prNo, setPrNo] = useState(null);
  const [prAmount, setPrAmount] = useState(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [message, setMessage] = useState('');
  const [messageType, setMessageType] = useState('');
  const [loading, setLoading] = useState(true);



  const [formData, setFormData] = useState({
    property_description: '',
    category: 'equipment',
    supplier_name: '',
    invoice_number: '',
    purchase_date: '',
    acquisition_date: '',
    unit_of_measure: '',
    quantity: 1,
    unit_cost: 0,
    total_cost: 0,
    estimated_useful_life: 5,
    depreciation_method: 'straight-line',
    model_number: '',
    serial_number: '',
    manufacturer: '',
    location_building: 'Main Office', // Default value to avoid missing required field error
    location_room: '',
    responsible_person: '',
    condition: 'serviceable',
    warranty_expiry: '',
    maintenance_schedule: '',
    notes: ''
  }); 

useEffect(() => {
    const currentPrId = sessionStorage.getItem('current_pr_id');
    const currentPrNo = sessionStorage.getItem('current_pr_no');
    const prCompleteData = sessionStorage.getItem('pr_complete_data');

    if (currentPrId) setPrId(parseInt(currentPrId));
    if (currentPrNo) setPrNo(currentPrNo);

    if (prCompleteData) {
        const parsed = JSON.parse(prCompleteData);
        setPrData(parsed);
        setPrAmount(parseFloat(parsed.total_amount) || 0);

        setFormData(prev => ({
            ...prev,
            property_description: parsed.item_description || parsed.items?.[0]?.particular || '',
            supplier_name: parsed.iac_supplier || parsed.supplier || '',
            unit_of_measure: parsed.items?.[0]?.unit || '',
            quantity: parsed.items?.reduce((sum, i) => sum + i.quantity, 0) || 1,
            unit_cost: parsed.items?.[0]?.unitCost || 0,
            total_cost: parseFloat(parsed.total_amount) || 0,
            manufacturer: parsed.iac_supplier || parsed.supplier || '',
            po_date: parsed.iac_po_date || parsed.po_date || '',
            iar_no: parsed.iac_iar_no || '',
            office: parsed.office || '',
            division_section: parsed.division_section || '',
            location_building: parsed.division_section || parsed.office || '',
        }));
    }

    setLoading(false);
}, []);



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

  const handleCategoryChange = (e) => {
    setFormData(prev => ({ ...prev, category: e.target.value }));
  };

  const handleConditionChange = (e) => {
    setFormData(prev => ({ ...prev, condition: e.target.value }));
  };

  const handleDepreciationChange = (e) => {
    setFormData(prev => ({ ...prev, depreciation_method: e.target.value }));
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
            items: prData?.items || [],
            total_amount: prData?.total_amount,
            office: prData?.office || '',
            division_section: prData?.division_section || '',
            iac_supplier: prData?.iac_supplier || prData?.supplier || '',
            iac_po_date: prData?.iac_po_date || prData?.po_date || '',
            iac_iar_no: prData?.iac_iar_no || '',
            iac_date: prData?.iac_date || '',
            iac_invoice_no: prData?.iac_invoice_no || '',
            iac_invoice_date: prData?.iac_invoice_date || '',
            inspection_notes: prData?.inspection_notes || '',
            user_id: sessionStorage.getItem('user_id') || 1,
        };

        const response = await fetch(`${API_BASE_URL}/submit_ppe_form.php`, {
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
            setMessage('✓ PPE Form submitted! Proceeding to Property Inventory Tag...');
            setMessageType('success');

            if (result.property_id) {
                sessionStorage.setItem('current_property_id', result.property_id);
            }

            sessionStorage.setItem('pr_complete_data', JSON.stringify({
                ...prData,
                property_id: result.property_id,
            }));

            setTimeout(() => {
                window.location.href = '/property-inventory-tag';
            }, 1500);
        } else {
            setMessage(`Error: ${result.message || 'Failed to submit PPE form'}`);
            setMessageType('error');
        }
    } catch (error) {
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
    <div style={{ padding: '20px', maxWidth: '1000px' }}>
      <div style={{ marginBottom: '30px' }}>
        <h2>Inventory Form - PPE (ABOVE: PAR ₱ ≥ 50,000)</h2>
        <p style={{ color: '#666', marginTop: '10px' }}>
          PPE/Fixed Assets Inventory Form for items ₱50,000 and above
        </p>
        {prNo && (
          <p style={{ marginTop: '10px', fontSize: '14px', color: '#0066cc', fontWeight: 'bold' }}>
            PR: {prNo} | Amount: ₱{prAmount?.toFixed(2)}
          </p>
        )}
      </div>

      <form onSubmit={handleSubmit} style={{ display: 'grid', gap: '20px' }}>
        {/* Section 1: Property Description */}
        <fieldset style={{ border: '1px solid #ddd', padding: '20px', borderRadius: '8px' }}>
          <legend style={{ fontSize: '16px', fontWeight: 'bold', color: '#0066cc' }}>1. Property Description</legend>
          
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '15px' }}>
            <div>
              <label htmlFor="property_description" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Property/Item Description *
              </label>
              <textarea
                id="property_description"
                name="property_description"
                value={formData.property_description}
                onChange={handleInputChange}
                placeholder="e.g., Dell XPS Laptop, Server Hardware, Furniture Unit"
                rows="3"
                required
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>

            <div>
              <label htmlFor="category" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Asset Category *
              </label>
              <select
                id="category"
                value={formData.category}
                onChange={handleCategoryChange}
                required
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              >
                <option value="equipment">Equipment</option>
                <option value="furniture">Furniture & Fixtures</option>
                <option value="vehicles">Vehicles</option>
                <option value="tools">Tools & Machinery</option>
                <option value="buildings">Buildings & Structures</option>
                <option value="it-hardware">IT Hardware</option>
                <option value="other">Other</option>
              </select>
            </div>

            <div>
              <label htmlFor="manufacturer" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Manufacturer/Brand
              </label>
              <input
                id="manufacturer"
                type="text"
                name="manufacturer"
                value={formData.manufacturer}
                onChange={handleInputChange}
                placeholder="e.g., Dell, HP, Toyota"
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>
          </div>
        </fieldset>

        {/* Section 2: Acquisition Details */}
        <fieldset style={{ border: '1px solid #ddd', padding: '20px', borderRadius: '8px' }}>
          <legend style={{ fontSize: '16px', fontWeight: 'bold', color: '#0066cc' }}>2. Acquisition Details</legend>
          
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
              <label htmlFor="purchase_date" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Purchase Date
              </label>
              <input
                id="purchase_date"
                type="date"
                name="purchase_date"
                value={formData.purchase_date}
                onChange={handleInputChange}
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>

            <div>
              <label htmlFor="acquisition_date" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Acquisition/Receipt Date
              </label>
              <input
                id="acquisition_date"
                type="date"
                name="acquisition_date"
                value={formData.acquisition_date}
                onChange={handleInputChange}
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>
          </div>
        </fieldset>

        {/* Section 3: Cost & Quantity */}
        <fieldset style={{ border: '1px solid #ddd', padding: '20px', borderRadius: '8px' }}>
          <legend style={{ fontSize: '16px', fontWeight: 'bold', color: '#0066cc' }}>3. Cost & Quantity</legend>
          
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
                placeholder="e.g., piece, set, unit"
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

        {/* Section 4: Technical Specifications */}
        <fieldset style={{ border: '1px solid #ddd', padding: '20px', borderRadius: '8px' }}>
          <legend style={{ fontSize: '16px', fontWeight: 'bold', color: '#0066cc' }}>4. Technical Specifications</legend>
          
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '15px' }}>
            <div>
              <label htmlFor="model_number" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Model/Version Number
              </label>
              <input
                id="model_number"
                type="text"
                name="model_number"
                value={formData.model_number}
                onChange={handleInputChange}
                placeholder="e.g., XPS 13-9305, ThinkPad X1"
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>

            <div>
              <label htmlFor="serial_number" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Serial Number/License Number
              </label>
              <input
                id="serial_number"
                type="text"
                name="serial_number"
                value={formData.serial_number}
                onChange={handleInputChange}
                placeholder="Equipment serial or license number"
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>

            <div>
              <label htmlFor="warranty_expiry" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Warranty Expiration Date
              </label>
              <input
                id="warranty_expiry"
                type="date"
                name="warranty_expiry"
                value={formData.warranty_expiry}
                onChange={handleInputChange}
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>
          </div>
        </fieldset>

        {/* Section 5: Depreciation & Lifecycle */}
        <fieldset style={{ border: '1px solid #ddd', padding: '20px', borderRadius: '8px' }}>
          <legend style={{ fontSize: '16px', fontWeight: 'bold', color: '#0066cc' }}>5. Depreciation & Lifecycle</legend>
          
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '15px' }}>
            <div>
              <label htmlFor="estimated_useful_life" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Estimated Useful Life (Years) *
              </label>
              <input
                id="estimated_useful_life"
                type="number"
                name="estimated_useful_life"
                value={formData.estimated_useful_life}
                onChange={handleInputChange}
                min="1"
                required
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
              <small style={{ color: '#666' }}>For depreciation calculation</small>
            </div>

            <div>
              <label htmlFor="depreciation_method" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Depreciation Method *
              </label>
              <select
                id="depreciation_method"
                value={formData.depreciation_method}
                onChange={handleDepreciationChange}
                required
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              >
                <option value="straight-line">Straight-line</option>
                <option value="declining-balance">Declining Balance</option>
                <option value="double-declining">Double Declining Balance</option>
                <option value="units-of-production">Units of Production</option>
              </select>
            </div>

            <div>
              <label htmlFor="condition" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Current Condition *
              </label>
              <select
                id="condition"
                value={formData.condition}
                onChange={handleConditionChange}
                required
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              >
                <option value="serviceable">Serviceable (Good)</option>
                <option value="serviceable-with-repairs">Serviceable (With Minor Repairs)</option>
                <option value="needs-repair">Needs Repair</option>
                <option value="obsolete">Obsolete</option>
                <option value="salvage">Salvage</option>
              </select>
            </div>
          </div>
        </fieldset>

        {/* Section 6: Location & Responsibility */}
        <fieldset style={{ border: '1px solid #ddd', padding: '20px', borderRadius: '8px' }}>
          <legend style={{ fontSize: '16px', fontWeight: 'bold', color: '#0066cc' }}>6. Location & Responsibility</legend>
          
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '15px' }}>
            <div>
              <label htmlFor="location_building" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Building/Location *
              </label>
              <input
                id="location_building"
                type="text"
                name="location_building"
                value={formData.location_building}
                onChange={handleInputChange}
                placeholder="e.g., Main Office, Building A, Warehouse"
                required
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>

            <div>
              <label htmlFor="location_room" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Room/Area/Department
              </label>
              <input
                id="location_room"
                type="text"
                name="location_room"
                value={formData.location_room}
                onChange={handleInputChange}
                placeholder="e.g., IT Department, Room 201, Server Room"
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>

            <div>
              <label htmlFor="responsible_person" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Responsible Officer/Custodian
              </label>
              <input
                id="responsible_person"
                type="text"
                name="responsible_person"
                value={formData.responsible_person}
                onChange={handleInputChange}
                placeholder="Name and designation of responsible person"
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>
          </div>
        </fieldset>

        {/* Section 7: Maintenance & Additional Notes */}
        <fieldset style={{ border: '1px solid #ddd', padding: '20px', borderRadius: '8px' }}>
          <legend style={{ fontSize: '16px', fontWeight: 'bold', color: '#0066cc' }}>7. Maintenance & Additional Information</legend>
          
          <div style={{ display: 'grid', gap: '15px' }}>
            <div>
              <label htmlFor="maintenance_schedule" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Maintenance Schedule
              </label>
              <textarea
                id="maintenance_schedule"
                name="maintenance_schedule"
                value={formData.maintenance_schedule}
                onChange={handleInputChange}
                placeholder="e.g., Quarterly servicing, Annual inspection, Monthly calibration"
                rows="3"
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>

            <div>
              <label htmlFor="notes" style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                Additional Notes/Remarks
              </label>
              <textarea
                id="notes"
                name="notes"
                value={formData.notes}
                onChange={handleInputChange}
                placeholder="Any additional information about this asset"
                rows="3"
                style={{ width: '100%', padding: '10px', border: '1px solid #ddd', borderRadius: '4px' }}
              />
            </div>
                {/* Items from particularItems — bound to prData */}
                {prData?.items?.length > 0 && (
                    <div style={{ border: '2px solid #ddd', borderRadius: '8px', padding: '20px', marginBottom: '20px' }}>
                        <h4 style={{ marginTop: 0 }}>Items (PPE)</h4>
                        <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '14px' }}>
                            <thead>
                                <tr style={{ borderBottom: '2px solid #2a83d6', backgroundColor: '#f8f9fa' }}>
                                    {['Description', 'Unit', 'Quantity', 'Unit Cost (₱)', 'Amount (₱)'].map(h => (
                                        <th key={h} style={{ padding: '10px', textAlign: h === 'Description' ? 'left' : 'center' }}>{h}</th>
                                    ))}
                                </tr>
                            </thead>
                            <tbody>
                                {prData.items.map((item, idx) => (
                                    <tr key={idx} style={{ borderBottom: '1px solid #e0e0e0' }}>
                                        <td style={{ padding: '10px' }}>{item.particular}</td>
                                        <td style={{ textAlign: 'center', padding: '10px' }}>{item.unit}</td>
                                        <td style={{ textAlign: 'center', padding: '10px' }}>{item.quantity}</td>
                                        <td style={{ textAlign: 'center', padding: '10px' }}>₱{parseFloat(item.unitCost).toFixed(2)}</td>
                                        <td style={{ textAlign: 'center', padding: '10px', color: '#28a745', fontWeight: '600' }}>
                                            ₱{(item.quantity * item.unitCost).toFixed(2)}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                            <tfoot>
                                <tr style={{ borderTop: '2px solid #2a83d6', backgroundColor: '#f0f8f5' }}>
                                    <td colSpan="4" style={{ textAlign: 'right', padding: '12px', fontWeight: 'bold' }}>TOTAL:</td>
                                    <td style={{ textAlign: 'center', padding: '12px', fontWeight: 'bold', color: '#d9534f' }}>
                                        ₱{parseFloat(prData.total_amount).toFixed(2)}
                                    </td>
                                </tr>
                            </tfoot>
                        </table>
                    </div>
                )}
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
            {isSubmitting ? 'Submitting...' : 'Submit PPE Form'}
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

export default PPEForm;
