import React, { useState, useEffect } from 'react';
import API_BASE_URL from './config/api';

const ICSForm = () => {
    const [prData, setPrData] = useState(null);
    const [prId, setPrId] = useState(null);
    const [prNo, setPrNo] = useState('');
    const [loading, setLoading] = useState(true);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [message, setMessage] = useState('');
    const [messageType, setMessageType] = useState('');
    const [icsEntryNo, setIcsEntryNo] = useState('');
    const [addEntryNumberEditable, setAddEntryNumberEditable] = useState(false);
    const [locationCode, setLocationCode] = useState('');

    const [formData, setFormData] = useState({
        received_from: '',
        received_by: '',
        approved_by_position: '',
        property_no: '',
        estimated_useful_life: '',
        remarks: '',
        item_category: '',
        position: '',
    });

    const [spValue, setSpValue] = useState('SPLV');

    const positionOptions = [
        { value: '', label: '-- Select Position --' },
        { value: 'admin_officer', label: 'Administrative Officer' },
        { value: 'supply_officer', label: 'Supply Officer' },
        { value: 'property_custodian', label: 'Property Custodian' },
        { value: 'department_head', label: 'Department Head' },
        { value: 'division_chief', label: 'Division Chief' },
        { value: 'budget_officer', label: 'Budget Officer' },
        { value: 'accounting_head', label: 'Accounting Head' },
        { value: 'procurement_head', label: 'Procurement Head' },
    ];

    const approvedByOptions = [
        { value: '', label: '-- Select Approving Position --' },
        { value: 'director', label: 'Director' },
        { value: 'assistant_director', label: 'Assistant Director' },
        { value: 'division_chief', label: 'Division Chief' },
        { value: 'department_manager', label: 'Department Manager' },
        { value: 'executive_director', label: 'Executive Director' },
    ];

    useEffect(() => {
        const currentPrId = sessionStorage.getItem('current_pr_id');
        const currentPrNo = sessionStorage.getItem('current_pr_no');
        const currentPrAmount = parseFloat(sessionStorage.getItem('current_pr_amount')) || 0;
        const prCompleteData = sessionStorage.getItem('pr_complete_data');

        if (currentPrId) setPrId(currentPrId);
        if (currentPrNo) setPrNo(currentPrNo);

        if (prCompleteData) {
            const parsed = JSON.parse(prCompleteData);
            setPrData(parsed);

            const totalAmount = parseFloat(parsed.total_amount) || currentPrAmount;
            const newSpValue = totalAmount >= 5000 ? 'SPHV' : 'SPLV';
            setSpValue(newSpValue);

            const now = new Date();
            const yy = String(now.getFullYear()).slice(-2);
            const mm = String(now.getMonth() + 1).padStart(2, '0');
            setIcsEntryNo(`${newSpValue}-${yy}ICS-${mm}`);
        }

        setLoading(false);
    }, []);

    const handleFormChange = (e) => {
        setFormData(prev => ({ ...prev, [e.target.name]: e.target.value }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setIsSubmitting(true);
        setMessage('');

        const totalAmountValue = prData?.total_amount || 0;
        const totalQuantity = prData?.items?.reduce((sum, i) => sum + i.quantity, 0) || 0;
        const defaultUnit = prData?.items?.[0]?.unit || 'piece';
        const defaultUnitCost = prData?.items?.[0]?.unitCost || 0;
        const itemDescription = prData?.items?.map(i => i.particular).join(', ') || '';

        try {
            const payload = {
                pr_id: prId,
                pr_no: prNo,
                ics_entry_no: icsEntryNo,
                sp_value: spValue,
                items: prData?.items || [],
                total_amount: totalAmountValue,
                unit: defaultUnit,
                quantity: totalQuantity,
                unit_cost: defaultUnitCost,
                item_description: itemDescription,
                location_code: locationCode || '',
                office: prData?.office || '',
                division_section: prData?.division_section || '',
                supplier: prData?.iac_supplier || prData?.supplier || '',
                iac_iar_no: prData?.iac_iar_no || '',
                iac_date: prData?.iac_date || '',
                inspection_notes: prData?.inspection_notes || '',
                ...formData,
                user_id: sessionStorage.getItem('user_id'),
                item_category: formData.item_category || 'office_supplies',
                unit_of_measure: defaultUnit,
                total_cost: totalAmountValue,
                inventory_location: locationCode || 'storage',
            };

            const response = await fetch(`${API_BASE_URL}/submit_ics_form.php`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-User-ID': sessionStorage.getItem('user_id') || ''
                },
                credentials: 'include',
                body: JSON.stringify(payload)
            });

            const result = await response.json();

            if (result.success) {
                setMessage('✓ ICS Form submitted successfully!');
                setMessageType('success');
                sessionStorage.removeItem('pr_complete_data');
                setTimeout(() => { window.location.href = '/dashboard'; }, 1500);
            } else {
                setMessage('Error: ' + (result.error || 'Failed to submit ICS form'));
                setMessageType('error');
            }
        } catch (error) {
            setMessage('Network error: ' + error.message);
            setMessageType('error');
        }

        setIsSubmitting(false);
    };

    if (loading) return <div>Loading ICS Form...</div>;
    if (!prData) return <div>No PR data found. Please complete the Purchase Request workflow first.</div>;

    const totalAmount = parseFloat(prData.total_amount) || 0;
    const items = prData.items || [];

    return (
        <form onSubmit={handleSubmit}>
            {/* Header Info */}
            <div style={{ backgroundColor: '#f8f9fa', padding: '15px', borderRadius: '8px', marginBottom: '20px' }}>
                <h3>Inventory Custodianship Slip (ICS)</h3>
                <p><strong>PR No:</strong> {prNo}</p>
                <p><strong>Office:</strong> {prData.office}</p>
                <p><strong>SP Classification:</strong>{' '}
                    <span style={{ color: spValue === 'SPHV' ? '#d9534f' : '#28a745', fontWeight: 'bold' }}>
                        {spValue} ({totalAmount >= 5000 ? '≥ ₱5,000' : '< ₱5,000'})
                    </span>
                </p>
                <p><strong>ICS Entry No:</strong>{' '}
                    {addEntryNumberEditable
                        ? <input value={icsEntryNo} onChange={(e) => setIcsEntryNo(e.target.value)} style={{ padding: '4px', border: '1px solid #ddd', borderRadius: '4px' }} />
                        : <span>{icsEntryNo} <button type="button" onClick={() => setAddEntryNumberEditable(true)} style={{ fontSize: '12px', marginLeft: '8px', cursor: 'pointer' }}>Edit</button></span>
                    }
                </p>
                <p><strong>Location Code:</strong>{' '}
                    <select value={locationCode} onChange={(e) => setLocationCode(e.target.value)} style={{ padding: '4px', border: '1px solid #ddd', borderRadius: '4px' }}>
                        <option value=""> - Select Location Code -</option>
                        <option value="01">01 - Manpower Development Service (MDS)</option>
                        <option value="02">02 - Shipbuilding and Technology Center for Workforce Optimization (STCWO)</option>
                        <option value="03">03 - Domestic Shipping Service (DSS)</option>
                        <option value="04">04 - Franchising Service (FS)</option>
                        <option value="05">05 - Shipyards Regulation Service (SRS)</option>
                        <option value="06">06 - Overseas Shipping Service (OSS)</option>
                        <option value="07">07 - Maritime Safety Service (MSS)</option>
                        <option value="08">08 - Management Information Systems Service (MISS)</option>
                        <option value="09">09 - Legal Service (LS)</option>
                        <option value="10">10 - Planning and Policy Service (PSS)</option>
                        <option value="11">11 - Management, Financial and Administrative Service (MFAS)</option>
                        <option value="12">12 - Enforcement Service (ES)</option>
                        <option value="13">13 - Office of Deputy Administrator for Operations (ODAO)</option>
                        <option value="14">14 - Office of Deputy Administrator for Planning (ODAP)</option>
                        <option value="15">15 - Office of Deputy Administrator for Management (OADM)</option>
                        <option value="16">16 - Maritime Regional Office - NCR (MRO-NCR)</option>
                    </select>
                </p>
            </div>

            {/* Items Table */}
            <div style={{ border: '2px solid #ddd', borderRadius: '8px', padding: '20px', marginBottom: '20px' }}>
                <h4 style={{ marginTop: 0 }}>Items</h4>
                <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '14px' }}>
                    <thead>
                        <tr style={{ borderBottom: '2px solid #2a83d6', backgroundColor: '#f8f9fa' }}>
                            <th style={{ padding: '10px', textAlign: 'left' }}>Description</th>
                            <th style={{ padding: '10px', textAlign: 'center' }}>Unit</th>
                            <th style={{ padding: '10px', textAlign: 'center' }}>Quantity</th>
                            <th style={{ padding: '10px', textAlign: 'center' }}>Unit Cost (₱)</th>
                            <th style={{ padding: '10px', textAlign: 'center' }}>Amount (₱)</th>
                        </tr>
                    </thead>
                    <tbody>
                        {items.map((item, idx) => (
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
                                ₱{totalAmount.toFixed(2)}
                            </td>
                        </tr>
                    </tfoot>
                </table>
            </div>

            {/* ICS Form Fields */}
            <div style={{ border: '2px solid #ddd', borderRadius: '8px', padding: '20px', marginBottom: '20px' }}>
                <h4 style={{ marginTop: 0 }}>ICS Details</h4>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
                    <div>
                        <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>Property No.</label>
                        <input type="text" name="property_no" value={formData.property_no} onChange={handleFormChange} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }} />
                    </div>

                    <div>
                        <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>Received From</label>
                        <input type="text" name="received_from" value={formData.received_from} onChange={handleFormChange} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }} />
                    </div>

                    <div>
                        <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>Received By</label>
                        <input type="text" name="received_by" value={formData.received_by} onChange={handleFormChange} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }} />
                    </div>

                    <div>
                        <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>Position</label>
                        <select name="position" value={formData.position} onChange={handleFormChange} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }}>
                            {positionOptions.map(opt => (
                                <option key={opt.value} value={opt.value}>{opt.label}</option>
                            ))}
                        </select>
                    </div>

                    <div>
                        <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>Approved By</label>
                        <select name="approved_by_position" value={formData.approved_by_position} onChange={handleFormChange} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }}>
                            {approvedByOptions.map(opt => (
                                <option key={opt.value} value={opt.value}>{opt.label}</option>
                            ))}
                        </select>
                    </div>

                    <div>
                        <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>Estimated Useful Life</label>
                        <input type="text" name="estimated_useful_life" value={formData.estimated_useful_life} onChange={handleFormChange} placeholder="e.g., 5 years" style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }} />
                    </div>

                    <div>
                        <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>Date Acquired</label>
                        <input type="date" name="date_acquired" value={formData.date_acquired} onChange={handleFormChange} style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }} />
                    </div>

                    <div style={{ gridColumn: '1 / -1' }}>
                        <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>Remarks</label>
                        <textarea name="remarks" value={formData.remarks} onChange={handleFormChange} rows="3" style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }} />
                    </div>
                </div>
            </div>

            {message && (
                <div style={{ padding: '10px', marginBottom: '15px', borderRadius: '4px',
                    backgroundColor: messageType === 'success' ? '#d4edda' : '#f8d7da',
                    color: messageType === 'success' ? '#155724' : '#721c24' }}>
                    {message}
                </div>
            )}

            <button type="submit" disabled={isSubmitting} style={{ padding: '12px 30px', backgroundColor: '#0066cc', color: '#fff', border: 'none', borderRadius: '4px', cursor: 'pointer', fontSize: '15px' }}>
                {isSubmitting ? 'Submitting...' : 'Submit ICS Form'}
            </button>
        </form>
    );
};

export default ICSForm;