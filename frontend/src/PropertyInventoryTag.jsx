import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import API_BASE_URL from './config/api';

const ACCOUNT_CODE_OPTIONS = [
    { value: '405-10', label: 'Semi-Expendable Machinery' },
    { value: '405-02', label: 'Semi-Expendable Office Equipment' },
    { value: '405-03', label: 'Semi-Expendable ICT Equipment' },
    { value: '405-70', label: 'Semi-Expendable Communication Equipment' },
    { value: '405-12', label: 'Semi-Expendable Sports Equipment' },
    { value: '405-99', label: 'Semi-Expendable Other Equipment' },
    { value: '406-10', label: 'Semi-Expendable Furniture & Fixture' },
    { value: '406-20', label: 'Semi-Expendable Books' },
    { value: 'other',  label: 'Other (Manual Entry)' },
];

const LOCATION_OPTIONS = [
    { value: '01', label: '01 - Select Office' },
    { value: '02', label: '02 - Franchising Service (FS)' },
    { value: '03', label: '03 - Shipyards Regulation Service (SRS)' },
    { value: '04', label: '04 - Overseas Shipping Service (OSS)' },
    { value: '05', label: '05 - Maritime Safety Service (MSS)' },
    { value: '06', label: '06 - Management Information Systems Service (MISS)' },
    { value: '07', label: '07 - Legal Service (LS)' },
    { value: '08', label: '08 - Planning and Policy Service (PPS)' },
    { value: '09', label: '09 - Management, Financial and Administrative Service (MFAS)' },
    { value: '10', label: '10 - Enforcement Service (ES)' },
    { value: '11', label: '11 - Office of Deputy Administrator for Operations (ODAO)' },
    { value: '12', label: '12 - Office of Deputy Administrator for Planning (ODAP)' },
    { value: '13', label: '13 - Office of Deputy Administrator for Management (OADM)' },
    { value: '14', label: '14 - Maritime Regional Office - NCR (MRO-NCR)' },
    { value: '15', label: '15 - Domestic Shipping Service (DSS)' },
    { value: '16', label: '16 - General Supply Division (GSD)' },
];

const PropertyInventoryTag = () => {
    const navigate = useNavigate();

    // Core state
    const [prData, setPrData] = useState(null);
    const [prId, setPrId] = useState(null);
    const [loading, setLoading] = useState(true);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [message, setMessage] = useState('');
    const [messageType, setMessageType] = useState('');

    // ✅ FIX: Added inventory_date to initial formData
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
        inspected_by: '',       // ✅ FIX: was 'inspected' in JSX
        status: 'serviceable',
        inventory_date: '',     // ✅ FIX: was missing
    });

    // Property number parts
    const [selectedYear, setSelectedYear] = useState(new Date().getFullYear().toString());
    const [selectedAccountCode, setSelectedAccountCode] = useState('');
    const [manualAccountCode, setManualAccountCode] = useState('');
    const [entryNumber, setEntryNumber] = useState('0001');
    const [selectedLocationCode, setSelectedLocationCode] = useState('');
    const [fullPropertyNumber, setFullPropertyNumber] = useState('');

    // ✅ Read from sessionStorage — no API call
    useEffect(() => {
        const currentPrId = sessionStorage.getItem('current_pr_id');
        const prCompleteData = sessionStorage.getItem('pr_complete_data');

        if (currentPrId) setPrId(parseInt(currentPrId));

        if (prCompleteData) {
            try {
                const parsed = JSON.parse(prCompleteData);
                setPrData(parsed);

                setFormData(prev => ({
                    ...prev,
                    description: parsed.item_description || parsed.items?.[0]?.particular || '',
                    unit_cost: parsed.items?.[0]?.unitCost || parsed.unit_cost || '',
                    acquisition_date: parsed.iac_po_date || parsed.po_date || parsed.date_requested || '',
                    estimated_cost: parsed.total_amount || '',
                    assignee: parsed.name || '',
                    inspected_by: parsed.inspected_by || '',
                    location: parsed.division_section || parsed.office || '',
                }));
            } catch (error) {
                console.error('Error parsing PR data:', error);
            }
        }

        setLoading(false);
    }, []);

    // ✅ Auto-generate fullPropertyNumber when parts change
    // Sanitize account code by removing hyphens to avoid LIKE pattern matching issues
    useEffect(() => {
        const accountCode = selectedAccountCode === 'other' ? manualAccountCode : selectedAccountCode;
        // Remove hyphens from account code for internal storage
        const cleanAccountCode = accountCode.replace(/-/g, '');
        if (selectedYear && cleanAccountCode && entryNumber && selectedLocationCode) {
            const generated = `${selectedYear}-${cleanAccountCode}-${entryNumber}-${selectedLocationCode}`;
            setFullPropertyNumber(generated);
            setFormData(prev => ({ ...prev, property_number: generated }));
        } else {
            setFullPropertyNumber('');
            setFormData(prev => ({ ...prev, property_number: '' }));
        }
    }, [selectedYear, selectedAccountCode, manualAccountCode, entryNumber, selectedLocationCode]);

    // ✅ Fetch last entry number when account code + location selected
    useEffect(() => {
        const accountCode = selectedAccountCode === 'other' ? manualAccountCode : selectedAccountCode;
        // Sanitize account code for backend query
        const cleanAccountCode = accountCode.replace(/-/g, '');
        if (!cleanAccountCode || !selectedLocationCode) return;

        const fetchLastEntry = async () => {
            try {
                const res = await fetch(
                    `${API_BASE_URL}/get_last_entry_number.php?account_code=${cleanAccountCode}&location_code=${selectedLocationCode}&year=${selectedYear}`,
                    { credentials: 'include' }
                );
                const data = await res.json();
                const last = data.last_entry_number || '0000';
                setEntryNumber(String(parseInt(last) + 1).padStart(4, '0'));
            } catch {
                setEntryNumber('0001');
            }
        };

        fetchLastEntry();
    }, [selectedAccountCode, manualAccountCode, selectedLocationCode, selectedYear]);

    const handleFormChange = (e) => {
        setFormData(prev => ({ ...prev, [e.target.name]: e.target.value }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        if (!fullPropertyNumber) {
            setMessage('Please complete all property number fields');
            setMessageType('error');
            return;
        }
        if (!formData.description) {
            setMessage('Description is required');
            setMessageType('error');
            return;
        }

        setIsSubmitting(true);

        try {
            const response = await fetch(`${API_BASE_URL}/submit_property_tag.php`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-User-ID': sessionStorage.getItem('user_id') || ''
                },
                credentials: 'include',
                body: JSON.stringify({
                    pr_id: prId,
                    pr_no: sessionStorage.getItem('current_pr_no'),
                    property_id: sessionStorage.getItem('current_property_id') || null,
                    items: prData?.items || [],
                    total_amount: prData?.total_amount,
                    office: prData?.office || '',
                    division_section: prData?.division_section || '',
                    // Property number parts
                    property_year: selectedYear,
                    property_account_code: selectedAccountCode === 'other' ? manualAccountCode : selectedAccountCode,
                    property_entry_number: entryNumber,
                    property_location_code: selectedLocationCode,
                    property_number: fullPropertyNumber,
                    ...formData,
                    user_id: sessionStorage.getItem('user_id'),
                })
            });

            const result = await response.json();

            if (result.success) {
                setMessage('✓ Property Inventory Tag created successfully!');
                setMessageType('success');

                const completeResponse = await fetch(`${API_BASE_URL}/complete_process.php`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    credentials: 'include',
                    body: JSON.stringify({ pr_id: prId })
                });

                const completeResult = await completeResponse.json();

                if (completeResult.success) {
                    sessionStorage.setItem('process_completed', 'true');
                    sessionStorage.removeItem('pr_complete_data');
                    sessionStorage.removeItem('current_property_id');

                    setTimeout(() => {
                        window.dispatchEvent(new CustomEvent('processCompleted', {
                            detail: { pr_no: sessionStorage.getItem('current_pr_no') }
                        }));
                        setTimeout(() => navigate('/dashboard'), 3000);
                    }, 1500);
                }
            } else {
                setMessage(result.error || 'Failed to submit property tag');
                setMessageType('error');
            }
        } catch (error) {
            setMessage('Error submitting property tag: ' + error.message);
            setMessageType('error');
        }

        setIsSubmitting(false);
    };

    if (loading) return <div>Loading Property Inventory Tag...</div>;
    if (!prData) return <div>No PR data found. Please complete the PPE form first.</div>;

    const items = prData?.items || [];
    const totalAmount = parseFloat(prData?.total_amount) || 0;

    return (
        <form onSubmit={handleSubmit}>

            {/* PR Summary */}
            <div style={{ backgroundColor: '#f8f9fa', padding: '15px', borderRadius: '8px', marginBottom: '20px' }}>
                <h3>Property Inventory Tag</h3>
                <p><strong>PR No:</strong> {sessionStorage.getItem('current_pr_no')}</p>
                <p><strong>Office:</strong> {prData?.office}</p>
                <p><strong>Division/Section:</strong> {prData?.division_section}</p>
                <p><strong>Total Amount:</strong> ₱{totalAmount.toFixed(2)}</p>
            </div>

            {/* Items Table */}
            {items.length > 0 && (
                <div style={{ border: '2px solid #ddd', borderRadius: '8px', padding: '20px', marginBottom: '20px' }}>
                    <h4 style={{ marginTop: 0 }}>Items</h4>
                    <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '14px' }}>
                        <thead>
                            <tr style={{ borderBottom: '2px solid #2a83d6', backgroundColor: '#f8f9fa' }}>
                                {['Description', 'Unit', 'Quantity', 'Unit Cost (₱)', 'Amount (₱)'].map(h => (
                                    <th key={h} style={{ padding: '10px', textAlign: h === 'Description' ? 'left' : 'center' }}>{h}</th>
                                ))}
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
            )}

            {/* Property Number Builder */}
            <div style={{ border: '2px solid #ddd', borderRadius: '8px', padding: '20px', marginBottom: '20px' }}>
                <h4 style={{ marginTop: 0 }}>Property Number</h4>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '15px' }}>

                    <div>
                        <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>Year</label>
                        <input type="text" value={selectedYear} disabled
                            style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', backgroundColor: '#f5f5f5', boxSizing: 'border-box' }} />
                    </div>

                    <div>
                        <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>Account Code *</label>
                        <select value={selectedAccountCode} onChange={(e) => setSelectedAccountCode(e.target.value)}
                            style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }}>
                            <option value="">Select Account Code</option>
                            {ACCOUNT_CODE_OPTIONS.map(opt => (
                                <option key={opt.value} value={opt.value}>{opt.label}</option>
                            ))}
                        </select>
                        {/* ✅ Manual entry if 'Other' selected */}
                        {selectedAccountCode === 'other' && (
                            <input type="text" placeholder="Enter account code manually"
                                value={manualAccountCode}
                                onChange={(e) => setManualAccountCode(e.target.value)}
                                style={{ width: '100%', marginTop: '8px', padding: '8px', border: '1px solid #051b50', borderRadius: '4px', boxSizing: 'border-box' }} />
                        )}
                    </div>

                    <div>
                        <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>Entry Number</label>
                        <input type="text" value={entryNumber} disabled
                            style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', backgroundColor: '#f5f5f5', boxSizing: 'border-box' }} />
                        <small style={{ color: '#666' }}>Auto-incremented</small>
                    </div>

                    <div>
                        <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>Location Code *</label>
                        <select value={selectedLocationCode} onChange={(e) => setSelectedLocationCode(e.target.value)}
                            style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }}>
                            <option value="">Select Location</option>
                            {LOCATION_OPTIONS.map(opt => (
                                <option key={opt.value} value={opt.value}>{opt.label}</option>
                            ))}
                        </select>
                    </div>
                </div>

                <div>
                    <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>Property Number (Auto-generated)</label>
                    <input type="text" value={fullPropertyNumber} disabled
                        placeholder="Select Account Code and Location to generate"
                        style={{ width: '100%', padding: '10px', border: '2px solid #051b50', borderRadius: '4px',
                            backgroundColor: '#f0f8ff', fontWeight: 'bold', fontSize: '16px',
                            color: fullPropertyNumber ? '#051b50' : '#999', boxSizing: 'border-box' }} />
                </div>
            </div>

            {/* Tag Details */}
            <div style={{ border: '2px solid #ddd', borderRadius: '8px', padding: '20px', marginBottom: '20px' }}>
                <h4 style={{ marginTop: 0 }}>Tag Details</h4>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
                    {[
                        { label: 'Description *', name: 'description' },
                        { label: 'Model Number', name: 'model_number' },
                        { label: 'Serial Number', name: 'serial_number' },
                        { label: 'Assignee', name: 'assignee' },
                        { label: 'Location', name: 'location' },
                        { label: 'Inspected By', name: 'inspected_by' },  // ✅ FIX: correct name
                    ].map(({ label, name }) => (
                        <div key={name}>
                            <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>{label}</label>
                            <input type="text" name={name} value={formData[name]} onChange={handleFormChange}
                                style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }} />
                        </div>
                    ))}

                    <div>
                        <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>Unit Cost (₱)</label>
                        <input type="number" name="unit_cost" value={formData.unit_cost} onChange={handleFormChange}
                            style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }} />
                    </div>

                    <div>
                        <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>Estimated Cost (₱)</label>
                        <input type="number" name="estimated_cost" value={formData.estimated_cost} onChange={handleFormChange}
                            style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }} />
                    </div>

                    <div>
                        <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>Acquisition Date</label>
                        <input type="date" name="acquisition_date" value={formData.acquisition_date} onChange={handleFormChange}
                            style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }} />
                    </div>

                    <div>
                        <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>Inventory Date</label>
                        <input type="date" name="inventory_date" value={formData.inventory_date} onChange={handleFormChange}
                            style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }} />
                    </div>

                    <div style={{ gridColumn: '1 / -1' }}>
                        <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>Status</label>
                        <select name="status" value={formData.status} onChange={handleFormChange}
                            style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }}>
                            <option value="serviceable">Serviceable</option>
                            <option value="unserviceable">Unserviceable</option>
                            <option value="for_repair">For Repair</option>
                            <option value="for_disposal">For Disposal</option>
                        </select>
                    </div>
                </div>
            </div>

            {/* Message */}
            {message && (
                <div style={{ padding: '10px', marginBottom: '15px', borderRadius: '4px',
                    backgroundColor: messageType === 'success' ? '#d4edda' : '#f8d7da',
                    color: messageType === 'success' ? '#155724' : '#721c24' }}>
                    {message}
                </div>
            )}

            <button type="submit" disabled={isSubmitting || !fullPropertyNumber}
                style={{ padding: '12px 30px', backgroundColor: !fullPropertyNumber ? '#aaa' : '#051b50',
                    color: '#fff', border: 'none', borderRadius: '4px',
                    cursor: !fullPropertyNumber ? 'not-allowed' : 'pointer', fontSize: '15px' }}>
                {isSubmitting ? 'Submitting...' : 'Submit Property Inventory Tag'}
            </button>
        </form>
    );
};

export default PropertyInventoryTag;