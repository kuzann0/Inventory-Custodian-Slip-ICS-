import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import styles from './css/PurchaseRequest.module.css'
import API_BASE_URL from './config/api'

function NewEntryPR() {
    const navigate = useNavigate();
    const AMOUNT_THRESHOLD = 50000; // Base 50K threshold

    // --------------- State    Management ---------------
    const [currentStep, setCurrentStep] = useState('create'); // create, approval, delivery_note, inspection, form_selection
    const [quantity, setQuantity] = useState(0);
    const [unit, setUnit] = useState(''); // For dynamic unit selection in delivery and inspection steps    
    const [unitCost, setUnitCost] = useState(0); // uses the same value in ICS and PPE Forms (data bind)
    const [prNo, setPrNo] = useState(''); 
    const [office, setOffice] = useState('');
    const [divisionSection, setDivisionSection] = useState('');
    const [dateRequested, setDateRequested] = useState('');
    const [itemNo, setItemNo] = useState('');

    
    const [itemDescription, setItemDescription] = useState('');


         





    // --------------- Button States ---------------
    // use default unit to avoid confusion

    const [particular, setParticular] = useState('');
    const [particularItems, setParticularItems] = useState([]);

    const addItemHandler = () => {

        const particularValue = particular || "New item";


        // this is just a setter, but more simple
        const newItem = {
            id: Date.now(), // for unique identifer
            particular: particularValue,
            unit: unit,
            quantity: quantity,
            unitCost: unitCost,
            amount: quantity * unitCost
        };
        setParticularItems([...particularItems, newItem]);

        // Clear input fields after adding
        setParticular('');
        setQuantity(1);
        setUnitCost(0);

        }
    const removeItemHandler = (item_id) => {
        
        setParticularItems(particularItems.filter(item => 
        item.id !== item_id));

        console.log('Remove item with id:', item_id);
    }

    // ------------------- Calculations -------------------
    const product = quantity * unitCost;
    const grandTotal = particularItems.reduce((total, item) => 
         { return  total + (item.quantity * item.unitCost) }, 0);


    // particular --> unit --> quantity --> unit cost --> amount --> grand total (for multiple items)
    // each row gets the value of the amount then adds to the previous amount

    // for(int i=0 ; i < n; i++){
//     amount = quantity * unit cost
//     grand total += amount
// }
    // amount + iac amount row 2 = grand total 






    // --------------- Dynamic States ---------------

    // we're getting the value instead of the label
    // ;
    // const [unitDynamic, setUnitDynamic] = useState(unitValue); // For dynamic unit selection in delivery and inspection steps

    // Approval & Workflow states
    const [approvalDecision, setApprovalDecision] = useState(null); // 'approved' or 'disapproved'
    const [inspectionNotes, setInspectionNotes] = useState('');
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [submitMessage, setSubmitMessage] = useState('');
    const [messageType, setMessageType] = useState('');

    // Delivery Note states
    const [deliveryNotes, setDeliveryNotes] = useState('');

    // ------------ 1ST ROW ------------ 
    const [supplier, setSupplier] = useState('');
    const [siNo, setSiNo] = useState('');
    const [poDate, setPoDate] = useState('');
    const [drNo, setDrNo] = useState('');

    // ------------ 2ND ROW ------------
    // const [particular, setParticular] = useState('');
    // const [particularItems, setParticularItems] = useState([]); // this is for array 


    const [amount, setAmount] = useState('');

    // ------------ 3RD ROW ------------ 
    const [preparedBy, setPreparedBy] = useState('');
    const [notedBy, setNotedBy] = useState('');

    // PR ID for database persistence
    const [prId, setPrId] = useState(null);

    // IAC (Inspection Acceptance Certificate) - Table Row One
    const [iacSupplier, setIacSupplier] = useState('');
    const [iacPoNo, setIacPoNo] = useState('');
    const [iacPoDate, setIacPoDate] = useState('');
    const [iacRequisitioningOffice, setIacRequisitioningOffice] = useState('');
    const [iacRequisitioningCode, setIacRequisitioningCode] = useState('');
    const [iacIarNo, setIacIarNo] = useState('');
    const [iacDate, setIacDate] = useState('');
    const [iacInvoiceNo, setIacInvoiceNo] = useState('');
    const [iacInvoiceDate, setIacInvoiceDate] = useState('');

    // IAC (Inspection Acceptance Certificate) - Table Row Two
    const [iacParticular, setIacParticular] = useState('');
    const [iacUnitRow2, setIacUnitRow2] = useState('');
    const [iacQuantityRow2, setIacQuantityRow2] = useState(0);
    const [iacUnitCostRow2, setIacUnitCostRow2] = useState(0);
    const iacAmountRow2 = iacQuantityRow2 * iacUnitCostRow2;


    // Initialize PR Name from modal (if coming from NewPurchaseRequest)
    // Auto-populate IAC office from step 1
    useEffect(() => {
        const newPrName = sessionStorage.getItem('new_pr_name');
        if (newPrName) {
            setPrNo(newPrName);
            sessionStorage.removeItem('new_pr_name'); // Clear after use
        }
    }, []);

    // Dynamic binding: Auto-populate IAC office and delivery fields from step 1
    useEffect(() => {
        if (currentStep === 'inspection' && office && !iacRequisitioningOffice) {
            setIacRequisitioningOffice(office);
        }
    }, [currentStep, office, iacRequisitioningOffice]);

    // Step indicators
    const stepLabels = {
        create: '1. Create PR',
        approval: '2. Approval',
        delivery_note: '3. Notice of Delivery',
        inspection: '4. Inspection',
        form_selection: '5. Form Selection'
    };

    // Handle PR Creation - Insert into purchase_requests table
    const handleCreatePR = async (e) => {
        e.preventDefault();
        setSubmitMessage('');

        if (!prNo || !office || !itemDescription || quantity <= 0 || unitCost <= 0) {
            setSubmitMessage('Please fill in all required fields with valid values');
            setMessageType('error');
            return;
        }

        setIsSubmitting(true);

        try {
            const payload = {
                pr_no: prNo,
                item_name: itemNo,
                description: itemDescription,
                quantity: parseInt(quantity),
                unit: unit,
                unit_cost: parseFloat(unitCost),
                office: office,
                division_section: divisionSection,
                user_id: sessionStorage.getItem('user_id')  // Include user_id for auth fallback
            };

            const response = await fetch(`${API_BASE_URL}/submit_purchase_request.php`, {
                method: 'POST',
                headers: { 
                    'Content-Type': 'application/json',
                    'X-User-ID': sessionStorage.getItem('user_id') || ''  // Send as header too
                },
                credentials: 'include',
                body: JSON.stringify(payload)
            });

            const result = await response.json();

            if (result.success) {
                setPrId(result.pr_id);
                setSubmitMessage('✓ PR created successfully! Proceed to approval.');
                setMessageType('success');
                // Move to approval step after 1.5 seconds
                setTimeout(() => setCurrentStep('approval'), 1500);
            } else {
                setSubmitMessage('Error: ' + (result.error || 'Failed to create PR'));
                setMessageType('error');
            }
        } catch (error) {
            setSubmitMessage('Network error: ' + error.message);
            setMessageType('error');
        }

        setIsSubmitting(false);
    };

    // Handle Approval Decision - Update purchase_requests table
    const handleApprovalDecision = async (decision) => {
        setIsSubmitting(true);
        setSubmitMessage('');

        try {
            const payload = {
                pr_id: prId,
                action: decision === 'approved' ? 'approve' : 'reject',
                notes: decision === 'approved' ? 'Approved' : 'Request disapproved',
                user_id: sessionStorage.getItem('user_id')
            };

            const response = await fetch(`${API_BASE_URL}/approve_purchase_request.php`, {
                method: 'POST',
                headers: { 
                    'Content-Type': 'application/json',
                    'X-User-ID': sessionStorage.getItem('user_id') || ''
                },
                credentials: 'include',
                body: JSON.stringify(payload)
            });

            const result = await response.json();

            if (decision === 'disapproved') {
                if (result.success) {
                    setSubmitMessage('✗ Purchase Request has been disapproved. Process ended.');
                    setMessageType('error');
                    setTimeout(() => {
                        setPrId(null);
                        setPrNo('');
                        setOffice('');
                        setDivisionSection('');
                        setDateRequested('');
                        setItemNo('');
                        setUnit('');
                        setItemDescription('');
                        setQuantity(0);
                        setUnitCost(0);
                        setCurrentStep('create');
                        setApprovalDecision(null);
                    }, 2000);
                } else {
                    setSubmitMessage('Error updating status: ' + result.error);
                    setMessageType('error');
                }
            } else {
                if (result.success) {
                    setApprovalDecision('approved');
                    setSubmitMessage('✓ Purchase Request approved! Moving to delivery notes.');
                    setMessageType('success');
                    setTimeout(() => setCurrentStep('delivery_note'), 1500);
                } else {
                    setSubmitMessage('Error approving PR: ' + result.error);
                    setMessageType('error');
                }
            }
        } catch (error) {
            setSubmitMessage('Network error: ' + error.message);
            setMessageType('error');
        }

        setIsSubmitting(false);
    };

    // Handle Delivery Note - Update purchase_requests table
    const handleDeliveryNote = async (e) => {
        e.preventDefault();
        setSubmitMessage('');

        // if (!deliveryNotes.trim()) {
        //     setSubmitMessage('Please add delivery notes');
        //     setMessageType('error');
        //     return;
        // }

        setIsSubmitting(true);

        try {
            const payload = {
                pr_id: prId,
                delivery_notes: deliveryNotes || "No delivery notes provided",
                actual_delivery_date: poDate || null,   
                user_id: sessionStorage.getItem('user_id')
            };

            const response = await fetch(`${API_BASE_URL}/submit_delivery_notes.php`, {
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
                setSubmitMessage('✓ Delivery note recorded! Moving to inspection.');
                setMessageType('success');
                setTimeout(() => setCurrentStep('inspection'), 1500);
            } else {
                setSubmitMessage('Error: ' + (result.error || 'Failed to save delivery notes'));
                setMessageType('error');
            }
        } catch (error) {
            setSubmitMessage('Network error: ' + error.message);
            setMessageType('error');
        }

        setIsSubmitting(false);
    };

    // Handle Inspection & Acceptance - Update purchase_requests table
    const handleInspection = async (e) => {
        e.preventDefault();
        setSubmitMessage('');

        // Validate required fields
        if (!inspectionNotes.trim()) {
            setSubmitMessage('Please add inspection notes');
            setMessageType('error');
            return;
        }

        if (!iacParticular.trim() && !itemDescription.trim()) {
            setSubmitMessage('Please provide item particulars');
            setMessageType('error');
            return;
        }

        if (iacQuantityRow2 <= 0) {
            setSubmitMessage('Please enter a valid quantity');
            setMessageType('error');
            return;
        }

        if (iacUnitCostRow2 <= 0) {
            setSubmitMessage('Please enter a valid unit cost');
            setMessageType('error');
            return;
        }

        setIsSubmitting(true);

        try {
            // Get or create inspection assignment with all PR and ROW 2 data
            const payload = {
                pr_id: prId,
                assignment_id: prId,
                inspection_notes: inspectionNotes,
                condition_report: inspectionNotes,
                // Row 2 Item Details
                particular: iacParticular || itemDescription,
                unit_row2: iacUnitRow2 || unit,
                quantity_row2: iacQuantityRow2,
                unit_cost_row2: iacUnitCostRow2,
                amount_row2: iacAmountRow2,
                grand_total: iacGrandTotal,
                // Step 1 PR Details (for redundancy prevention)
                pr_no: prNo,
                item_description: itemDescription,
                quantity: quantity,
                unit_cost: unitCost,
                total_amount: product,
                office: office,
                division_section: divisionSection,
                user_id: sessionStorage.getItem('user_id')
            };

            const response = await fetch(`${API_BASE_URL}/submit_inspection.php`, {
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
                setSubmitMessage('✓ Inspection completed! Determining form type...');
                setMessageType('success');
                setTimeout(() => setCurrentStep('form_selection'), 1500);
            } else {
                setSubmitMessage('Error: ' + (result.error || 'Failed to save inspection'));
                setMessageType('error');
            }
        } catch (error) {
            setSubmitMessage('Network error: ' + error.message);
            setMessageType('error');
        }

        setIsSubmitting(false);
    };

    // Handle Form Selection based on Amount
    const handleFormSelection = async () => {
        const formType = product >= AMOUNT_THRESHOLD ? 'ppe' : 'ics';

        // Store all PR data collected from all steps for next forms (ICS/PPE)
        const prData = {
            pr_id: prId,
            pr_no: prNo,
            item_no: itemNo,
            item_description: itemDescription,
            quantity: quantity,
            unit: unit,
            unit_cost: unitCost,
            total_amount: product,
            office: office,
            division_section: divisionSection,
            date_requested: dateRequested,
            // Delivery information
            supplier: supplier,
            si_no: siNo,
            po_date: poDate,
            dr_no: drNo,
            // IAC information - Row One
            iac_supplier: iacSupplier,
            iac_po_date: iacPoDate,
            iac_requisitioning_office: iacRequisitioningOffice,
            iac_requisitioning_code: iacRequisitioningCode,
            iac_iar_no: iacIarNo,
            iac_date: iacDate,
            iac_invoice_no: iacInvoiceNo,
            iac_invoice_date: iacInvoiceDate,
            // Inspection Notes
            inspection_notes: inspectionNotes,
            // IAC information - Row Two
            iac_particular: iacParticular,
            iac_unit_row2: iacUnitRow2,
            iac_quantity_row2: iacQuantityRow2,
            iac_unit_cost_row2: iacUnitCostRow2,
            iac_amount_row2: iacAmountRow2,
            iac_grand_total: iacGrandTotal
        };

        sessionStorage.setItem('current_pr_id', prId);
        sessionStorage.setItem('current_pr_no', prNo);
        sessionStorage.setItem('current_pr_amount', product);
        sessionStorage.setItem('form_type', formType);
        sessionStorage.setItem('pr_complete_data', JSON.stringify(prData));

        if (formType === 'ppe') {
            // ABOVE PAR - Go to PPE Form then Property Tag
            navigate('/inventory-form-ppe');
        } else {
            // LESS: ICS - Go to ICS Form
            navigate('/inventory-form-ics');
        }
    };

    // Inline styles for workflow elements
    const inlineStyles = {
        decisionBox: {
            backgroundColor: '#f8f9fa',
            padding: '30px',
            borderRadius: '8px',
            textAlign: 'center',
            border: '2px solid #ddd'
        },
        decisionButtons: {
            display: 'flex',
            gap: '20px',
            justifyContent: 'center',
            marginTop: '20px'
        },
        decisionBtn: {
            padding: '12px 40px',
            fontSize: '16px',
            fontWeight: 'bold',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer',
            minWidth: '150px'
        },
        selectionBox: {
            backgroundColor: '#f8f9fa',
            padding: '30px',
            borderRadius: '8px',
            border: '2px solid #ddd'
        },
        selectionOptions: {
            display: 'flex',
            gap: '20px',
            justifyContent: 'center',
            marginBottom: '20px'
        },
        option: {
            padding: '20px',
            borderRadius: '8px',
            border: '2px solid',
            minWidth: '300px',
            textAlign: 'center'
        }
    };

    return (
    <>

    <div className={styles.mainContainer}>
                <div className={styles.foreGround}>
                <div className={styles.mainWrapper}>
                    <div className={styles.content}>

                        <center>
                        <div className={styles.progressContainer}>
                            <div className={styles.progressLine}>
                                {Object.keys(stepLabels).map((step, idx) => (
                                    <div key={step} className={styles.element} style={{
                                        opacity: Object.keys(stepLabels).indexOf(currentStep) >= idx ? 1 : 0.3,
                                        backgroundColor: Object.keys(stepLabels).indexOf(currentStep) >= idx ? '#007bff' : '#ccc'
                                    }}>
                                        {idx + 1}
                                    </div>
                                ))}
                            </div>
                        </div>
                        <p style={{ marginTop: '10px', fontSize: '14px', color: '#666' }}>
                            {stepLabels[currentStep]}
                        </p>
                        </center>

                        <div className={styles.header}>
                            {/* <h1>Purchase Request Workflow</h1> */}
                            {prNo && <span className={styles.statusContainer}>PR: {prNo}</span>}
                            {product > 0 && <span className={styles.statusContainer}>₱{product.toFixed(2)}</span>}
                        </div>

                        <div className={styles.formContainer}>

                            {/* STEP 1: Create PR */}
                            {currentStep === 'create' && (
                                <form onSubmit={handleCreatePR}>
                                    <span>PR No.: <input type="text" placeholder="PR No." value={prNo} onChange={(e) => setPrNo(e.target.value)} /></span>
                                    <span>Office:
                                    <select value={office} onChange={(e) => setOffice(e.target.value)}>
                                        <option value="">Select Office</option>
                                        <option value="General Supply Division">General Supply Division (GSD)</option>
                                        <option value="Enforcement Service">Enforcement Service (ES)</option>
                                        <option value="Shipyards Regulation Service">Shipyards Regulation Service (SRS)</option>
                                        <option value="Domestic Shipping Service">Domestic Shipping Service (DSS)</option>
                                        <option value="Overseas Shipping Service">Overseas Shipping Service (OSS)</option>
                                        <option value="Franchising Service">Franchising Service (FS)</option>
                                        <option value="Maritime Safety Service">Maritime Safety Service (MSS)</option>
                                        <option value="Manpower Development Service">Manpower Development Service (MDS)</option>
                                        <option value="Management Information Systems Service ">Management Information Systems Service (MISS)</option>
                                        <option value="Management, Financial and Administrative Service">Management, Financial and Administrative Service (MFAS)</option>
                                        <option value="Planning and Policy Service">Planning and Policy Service (PPS)</option>
                                        <option value="Legal Service">Legal Service (LS)</option>
                                    </select>
                                    </span>
                                    <span>Division/Section: <input type="text" placeholder="Division/Section" value={divisionSection} onChange={(e) => setDivisionSection(e.target.value)} /></span>
                                    <span>Date Requested: <input type="date" value={dateRequested} onChange={(e) => setDateRequested(e.target.value)} /></span>
                                    <span>Item No.: <input type="text" placeholder="Item No." value={itemNo} onChange={(e) => setItemNo(e.target.value)} /></span>
                                    {/* <span>Unit: <input type="text" placeholder="unit" value={unit} onChange={(e) => setUnit(e.target.value)} /></span> */}
                                    <div>
                                        <select value={unit} onChange={(e) => setUnit(e.target.value)}>
                                            <option value="">Select Unit</option>
                                            <option value="pc">pc</option>
                                            <option value="pcs">pcs</option>
                                            <option value="set">set</option>
                                            <option value="unit">unit</option>
                                        </select>
                                    </div>
                                    <span>Item Description: <input type="text" placeholder="Item Description" value={itemDescription} onChange={(e) => setItemDescription(e.target.value)} /></span>
                                    <span>Quantity: <input type="number" placeholder="Quantity" value={quantity || ''} onChange={(e) => setQuantity(e.target.value ? parseFloat(e.target.value) : 0)}/></span>
                                    <span>Unit Cost: <input type="number" placeholder="Unit Cost" value={unitCost || ''} onChange={(e) => setUnitCost(e.target.value ? parseFloat(e.target.value) : 0)} /></span>
                                    <span>Total: <input type="number" placeholder="Total" value={product || 0} disabled /></span>
                                    <button className={styles.nextBtn} type="submit" disabled={isSubmitting}>
                                        {isSubmitting ? 'Creating...' : 'Create PR'}
                                    </button>
                                </form>
                            )}

                            {/* STEP 2: Approval Decision */}
                            {currentStep === 'approval' && (
                                <div style={inlineStyles.decisionBox}>
                                    <h3>Approval Decision</h3>
                                    {/* Display PR Information from Step 1 */}
                                    <div style={{ backgroundColor: '#fff', padding: '15px', borderRadius: '8px', marginBottom: '20px', textAlign: 'left', border: '1px solid #ddd' }}>
                                        <p><strong>PR No:</strong> {prNo}</p>
                                        <p><strong>Item:</strong> {itemDescription}</p>
                                        <p><strong>Quantity:</strong> {quantity} {unit}</p>
                                        <p><strong>Unit Cost:</strong> ₱{unitCost.toFixed(2)}</p>
                                        <p><strong>Office:</strong> {office}</p>
                                        {divisionSection && <p><strong>Division/Section:</strong> {divisionSection}</p>}
                                        <p><strong>Total Amount:</strong> ₱{product.toFixed(2)}</p>
                                    </div>
                                    <div style={inlineStyles.decisionButtons}>
                                        <button 
                                            style={{...inlineStyles.decisionBtn, backgroundColor: '#28a745'}}
                                            onClick={() => handleApprovalDecision('approved')}
                                            disabled={isSubmitting}
                                        >
                                            {isSubmitting ? 'Processing...' : '✓ APPROVE'}
                                        </button>
                                        <button 
                                            style={{...inlineStyles.decisionBtn, backgroundColor: '#dc3545'}}
                                            onClick={() => handleApprovalDecision('disapproved')}
                                            disabled={isSubmitting}
                                        >
                                            {isSubmitting ? 'Processing...' : '✗ DISAPPROVE'}
                                        </button>
                                    </div>
                                </div>
                            )}

                            {/*  --------------  STEP 3: Delivery Notes & IAC  --------------   */}
                            {currentStep === 'delivery_note' && (
                                <form onSubmit={handleDeliveryNote}>
                                    {/* Display PR Information from Step 1 */}
                                    <div style={{ backgroundColor: '#f8f9fa', padding: '15px', borderRadius: '8px', marginBottom: '20px' }}>
                                        <p><strong>PR No:</strong> {prNo}</p>
                                        <p><strong>Item:</strong> {itemDescription}</p>
                                        <p><strong>Quantity:</strong> {quantity} {unit}</p>
                                        <p><strong>Office:</strong> {office}</p>
                                        <p><strong>Division/Section:</strong> {divisionSection}</p>
                                    </div>

                                    {/* Delivery Form Fields */}
                                     <input type="text" placeholder="Supplier" value={supplier} onChange={(e) => setSupplier(e.target.value)} />
                                      <input type="text" placeholder="PR No." value={prNo} disabled />
                                     <input type="text" placeholder="SI No." value={siNo} onChange={(e) => setSiNo(e.target.value)} />
                                     <input type="date" placeholder="PO Date" value={poDate} onChange={(e) => setPoDate(e.target.value)} />
                                     <input type="text" placeholder="DR No." value={drNo} onChange={(e) => setDrNo(e.target.value)} />
                                                    
                                            {/* Particular Field*/}
                                            <div>
                                                <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>
                                                    Particular <span style={{ color: 'red' }}>*</span>
                                                </label>
                                                <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                                                      <input 
                                                        type="text"
                                                        value={particular}
                                                        onChange={(e) => setParticular(e.target.value)}
                                                        placeholder="Item particulars"
                                                        style={{ flex: 1, padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }}
                                                    /> 
                                                    <button onClick={addItemHandler}>+</button>
                                                    
                                                </div>
                                             </div>

                                            {particularItems.length > 0 && (
                                                <div style={{ marginTop: '15px', marginBottom: '15px', border: '1px solid #ddd', borderRadius: '4px', padding: '10px' }}>
                                                    <label style={{ fontWeight: 'bold', marginBottom: '10px', display: 'block' }}>Added Items:</label>
                                                        {particularItems.map((item, idx) => (
                                                            <div key={item.id} style={{ 
                                                                display: 'flex', 
                                                                justifyContent: 'space-between', 
                                                                padding: '5px 0',
                                                                borderBottom: idx < particularItems.length - 1 ? '1px solid #eee' : 'none'
                                                            }}>
                                            <span>{item.particular}</span>
                                            <span>{item.quantity} {item.unit} × ${item.unitCost} = ${item.amount}</span>
                                            <button 
                                                type="button"
                                                onClick={() => removeItemHandler(item.id)}
                                                style={{ color: 'red', cursor: 'pointer' }}
                                            >
                                            -
                                            </button>
                                        </div>
                                    ))}
                                </div>
                                )}

                            <div>
                        </div>            
                                            <div>

                                                {/* Unit Field */}
                                                
                                                <span>Unit:</span>
                                                <input type="text" 
                                                    placeholder='pc,pcs,set,unit'
                                                    type="text"
                                                    value={unit}
                                                    disabled
                                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box', backgroundColor: '#f5f5f5' }}
                                                />

                                                {/* Quantity Field */}
                                                <span>Quantity:</span>
                                                <input type="number" 
                                                    type="number"
                                                    value={quantity}
                                                    disabled
                                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box', backgroundColor: '#f5f5f5' }}
                                                />

                                                {/* Unit Cost Field */}
                                                <span>Unit Cost:</span>
                                                <input type="number" 
                                                    type="number"
                                                    value={unitCost}
                                                    disabled
                                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box', backgroundColor: '#f5f5f5' }}
                                                />

                                                {/* Amount Field */}
                                                <span>Amount:</span>
                                                <input type="number" 
                                                    type="number"
                                                    value={product}
                                                    disabled
                                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box', backgroundColor: '#f5f5f5' }}
                                                />

                                                {/* Grand Total Field */}
                                                <span>Grand Total:</span>
                                                <input type="number" 
                                                    type="number"
                                                    value={grandTotal}
                                                    disabled
                                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box', backgroundColor: '#f5f5f5' }}
                                                />



                                                {/* <select value={unitDynamic} onChange={(e) => setUnitDynamic(e.target.value)}>
                                                    <option value="">Select Unit</option>
                                                    <option value="pc">pc</option>
                                                    <option value="pcs">pcs</option>
                                                    <option value="set">set</option>
                                                    <option value="unit">unit</option>
                                                    <disabled/>
                                                </select> */}
                                            </div>

                                            <button className={styles.nextBtn} type="submit" disabled={isSubmitting}>
                                            {isSubmitting ? 'Saving...' : 'Next: Inspection'}
                                            </button>
                                </form>
                            )}

                                    
                            {/*  --------------  STEP 4: Inspection & Acceptance  --------------   */}
                            
                            {currentStep === 'inspection' && (
                                <form onSubmit={handleInspection}>
                                    
                                    {/* Display PR Summary */}
                                    <div style={{ backgroundColor: '#f8f9fa', padding: '15px', borderRadius: '8px', marginBottom: '20px' }}>
                                        <p><strong>PR No:</strong> {prNo}</p>
                                        <p><strong>Item:</strong> {itemDescription}</p>
                                        <p><strong>Quantity:</strong> {quantity} {unit}</p>
                                        <p><strong>Total Amount:</strong> ₱{product.toFixed(2)}</p>
                                    </div>

                                    {/* Display Delivery Information from Step 3 */}
                                    {(supplier || siNo || poDate || drNo) && (
                                        <div style={{ backgroundColor: '#e8f4f8', padding: '15px', borderRadius: '8px', marginBottom: '20px', border: '2px solid #0066cc' }}>
                                            <h4 style={{ marginTop: 0, marginBottom: '10px', color: '#333' }}>Delivery Information (from Previous Step)</h4>
                                            {supplier && <p><strong>Supplier:</strong> {supplier}</p>}
                                            {siNo && <p><strong>SI No:</strong> {siNo}</p>}
                                            {poDate && <p><strong>PO Date:</strong> {poDate}</p>}
                                            {drNo && <p><strong>DR No:</strong> {drNo}</p>}
                                        </div>
                                    )}

                                    {/* TABLE ROW ONE - IAC Fields */}
                                    <div style={{ 
                                        backgroundColor: '#fff', 
                                        border: '2px solid #ddd', 
                                        borderRadius: '8px', 
                                        padding: '20px', 
                                        marginBottom: '20px' 
                                    }}>
                                        <h4 style={{ marginTop: 0, marginBottom: '15px', color: '#333' }}>TABLE ROW ONE - Inspection Details</h4>
                                        
                                        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '15px' }}>
                                            {/* Supplier */}
                                            <div>
                                                <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>
                                                    Supplier <span style={{ color: 'red' }}>*</span>
                                                </label>
                                                <input
                                                    type="text"
                                                    value={iacSupplier || supplier}
                                                    onChange={(e) => setIacSupplier(e.target.value)}
                                                    placeholder="Supplier Name (50 chars max)"
                                                    maxLength="50"
                                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }}
                                                />
                                            </div>

                                            {/* P.O No./Date */}
                                            <div>
                                                <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>
                                                    P.O No./Date <span style={{ color: 'red' }}>*</span>
                                                </label>
                                                <input
                                                    type="date"
                                                    value={iacPoDate || poDate}
                                                    onChange={(e) => setIacPoDate(e.target.value)}
                                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }}
                                                />
                                            </div>

                                            {/* Requisitioning Office/Dept */}
                                            <div>
                                                <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>
                                                    Requisitioning Office/Dept <span style={{ color: 'red' }}>*</span>
                                                </label>
                                                <select
                                                    value={iacRequisitioningOffice || office}
                                                    onChange={(e) => setIacRequisitioningOffice(e.target.value)}
                                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }}
                                                >
                                                    <option value="">Select Office/Department</option>
                                                    <option value="General Supply Division">General Supply Division (GSD)</option>
                                                    <option value="Enforcement Service">Enforcement Service (ES)</option>
                                                    <option value="Shipyards Regulation Service">Shipyards Regulation Service (SRS)</option>
                                                    <option value="Domestic Shipping Service">Domestic Shipping Service (DSS)</option>
                                                    <option value="Overseas Shipping Service">Overseas Shipping Service (OSS)</option>
                                                    <option value="Franchising Service">Franchising Service (FS)</option>
                                                    <option value="Maritime Safety Service">Maritime Safety Service (MSS)</option>
                                                    <option value="Manpower Development Service">Manpower Development Service (MDS)</option>
                                                    <option value="Management Information Systems Service">Management Information Systems Service (MISS)</option>
                                                    <option value="Management, Financial and Administrative Service">Management, Financial and Administrative Service (MFAS)</option>
                                                    <option value="Planning and Policy Service">Planning and Policy Service (PPS)</option>
                                                    <option value="Legal Service">Legal Service (LS)</option>
                                                </select>
                                            </div>

                                            {/* Requisitioning Center Code */}
                                            <div>
                                                <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>
                                                    Requisitioning Center Code
                                                </label>
                                                <input
                                                    type="text"
                                                    value={iacRequisitioningCode}
                                                    onChange={(e) => setIacRequisitioningCode(e.target.value)}
                                                    placeholder="Ask Supervisor"
                                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }}
                                                />
                                            </div>

                                            {/* IAR No. */}
                                            <div>
                                                <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>
                                                    IAR No. <span style={{ color: 'red' }}>*</span>
                                                </label>
                                                <input
                                                    type="text"
                                                    value={iacIarNo}
                                                    onChange={(e) => setIacIarNo(e.target.value)}
                                                    placeholder="YYYY-MM-ENTRY# (Short Date)"
                                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }}
                                                />
                                            </div>

                                            {/* IAC Date */}
                                            <div>
                                                <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>
                                                    Date <span style={{ color: 'red' }}>*</span>
                                                </label>
                                                <input
                                                    type="date"
                                                    value={iacDate}
                                                    onChange={(e) => setIacDate(e.target.value)}
                                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }}
                                                />
                                            </div>

                                            {/* Invoice No */}
                                            <div>
                                                <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>
                                                    Invoice No <span style={{ color: 'red' }}>*</span>
                                                </label>
                                                <input
                                                    type="text"
                                                    value={iacInvoiceNo}
                                                    onChange={(e) => setIacInvoiceNo(e.target.value)}
                                                    placeholder="e.g., SS410024947"
                                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }}
                                                />
                                            </div>

                                            {/* Invoice Date */}
                                            <div>
                                                <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>
                                                    Invoice Date <span style={{ color: 'red' }}>*</span>
                                                </label>
                                                <input
                                                    type="date"
                                                    value={iacInvoiceDate}
                                                    onChange={(e) => setIacInvoiceDate(e.target.value)}
                                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }}
                                                />
                                            </div>
                                        </div>
                                    </div>

                                    {/* Delivery Information Notes */}
                                    <div style={{ marginBottom: '20px' }}>
                                        <label style={{ display: 'block', marginBottom: '8px', fontWeight: '500', fontSize: '14px' }}>
                                            Inspection Notes & Remarks <span style={{ color: 'red' }}>*</span>
                                        </label>
                                        <textarea
                                            placeholder="Enter inspection findings: item condition, quantity verified, quality assessment, acceptance status, remarks, etc."
                                            value={inspectionNotes}
                                            onChange={(e) => setInspectionNotes(e.target.value)}
                                            rows="5"
                                            style={{ width: '100%', padding: '10px', marginBottom: '15px', boxSizing: 'border-box', border: '1px solid #ddd', borderRadius: '4px' }}
                                            required
                                        />
                                    </div>

                                    {/* TABLE ROW TWO - Item Details with Calculation */}
                                    <div style={{ 
                                        backgroundColor: '#fff', 
                                        border: '2px solid #ddd', 
                                        borderRadius: '8px', 
                                        padding: '20px', 
                                        marginBottom: '20px' 
                                    }}>
                                        <h4 style={{ marginTop: 0, marginBottom: '15px', color: '#333' }}></h4>
                                        
                                        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '15px', marginBottom: '15px' }}>
                                            {/* Particular */}
                                            <div>
                                                <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>
                                                    Particular <span style={{ color: 'red' }}>*</span>
                                                </label>
                                                <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                                                    <input 
                                                        type="text"
                                                        value={iacParticular || itemDescription}
                                                        onChange={(e) => setIacParticular(e.target.value)}
                                                        placeholder="Item particulars"
                                                        style={{ flex: 1, padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }}
                                                    /> 
                                                    <button 
                                                        type="button"
                                                        className='addItem'
                                                        onClick={() => console.log('Add item functionality')}
                                                        style={{ padding: '8px 12px', backgroundColor: '#085319', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer', fontWeight: 'bold' }}
                                                    >
                                                        +
                                                    </button>
                                          
                                                </div>
                                            </div>

                                            {/* Unit */}
                                            <div>
                                                <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>
                                                    Unit <span style={{ color: 'red' }}>*</span>
                                                </label>
                                                <input
                                                    type="text"
                                                    value={iacUnitRow2 || unit}
                                                    onChange={(e) => setIacUnitRow2(e.target.value)}
                                                    placeholder="e.g., pcs, set, box"
                                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }}
                                                />
                                            </div>

                                            {/* Quantity */}
                                            <div>
                                                <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>
                                                    Quantity <span style={{ color: 'red' }}>*</span>
                                                </label>
                                                <input
                                                    type="number"
                                                    value={iacQuantityRow2 || ''}
                                                    onChange={(e) => setIacQuantityRow2(e.target.value ? parseFloat(e.target.value) : 0)}
                                                    placeholder="0"
                                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }}
                                                />
                                            </div>

                                            {/* Unit Cost */}
                                            <div>
                                                <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>
                                                    Unit Cost <span style={{ color: 'red' }}>*</span>
                                                </label>
                                                <input
                                                    type="number"
                                                    value={iacUnitCostRow2 || ''}
                                                    onChange={(e) => setIacUnitCostRow2(e.target.value ? parseFloat(e.target.value) : 0)}
                                                    placeholder="0.00"
                                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box' }}
                                                />
                                            </div>

                                            {/* Amount (Auto-calculated) */}
                                            <div>
                                                <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px' }}>
                                                    Amount
                                                </label>
                                                <input
                                                    type="number"
                                                    value={iacAmountRow2.toFixed(2)}
                                                    disabled
                                                    style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px', boxSizing: 'border-box', backgroundColor: '#f5f5f5' }}
                                                />
                                            </div>

                                            {/* Grand Total (Auto-calculated) */}
                                            <div>
                                                <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500', fontSize: '14px', fontWeight: 'bold', color: '#d9534f' }}>
                                                    Grand Total
                                                </label>
                                                <input
                                                    type="number"
                                                    value={iacGrandTotal.toFixed(2)}
                                                    disabled
                                                    style={{ width: '100%', padding: '8px', border: '2px solid #d9534f', borderRadius: '4px', boxSizing: 'border-box', backgroundColor: '#fff3cd', fontWeight: 'bold' }}
                                                />
                                            </div>
                                        </div>
                                    </div>

                                    <button className={styles.nextBtn} type="submit" disabled={isSubmitting}>
                                        {isSubmitting ? 'Saving...' : 'Next: Inspection'}
                                    </button>
                                </form>
                            )}

                                   


                            {/* STEP 5: Form Selection */}
                            {currentStep === 'form_selection' && (
                                <div style={inlineStyles.selectionBox}>
                                    <h3>Inventory Form Selection</h3>
                                    
                                    {/* Display Complete PR Summary */}
                                    <div style={{ backgroundColor: '#f8f9fa', padding: '15px', borderRadius: '8px', marginBottom: '20px', textAlign: 'left', border: '1px solid #ddd' }}>
                                        <h4 style={{ marginTop: 0 }}>Purchase Request Summary</h4>
                                        <p><strong>PR No:</strong> {prNo}</p>
                                        <p><strong>Item:</strong> {itemDescription}</p>
                                        <p><strong>Quantity:</strong> {quantity} {unit}</p>
                                        <p><strong>Unit Cost:</strong> ₱{unitCost.toFixed(2)}</p>
                                        <p><strong>Office:</strong> {office}</p>
                                        {divisionSection && <p><strong>Division/Section:</strong> {divisionSection}</p>}
                                        <p><strong>Total Amount:</strong> ₱{product.toFixed(2)}</p>
                                    </div>

                                    {supplier && (
                                        <div style={{ backgroundColor: '#e8f4f8', padding: '15px', borderRadius: '8px', marginBottom: '20px', textAlign: 'left', border: '1px solid #0066cc' }}>
                                            <h4 style={{ marginTop: 0 }}>Delivery Information</h4>
                                            <p><strong>Supplier:</strong> {supplier}</p>
                                            {siNo && <p><strong>SI No:</strong> {siNo}</p>}
                                            {poDate && <p><strong>PO Date:</strong> {poDate}</p>}
                                            {drNo && <p><strong>DR No:</strong> {drNo}</p>}
                                        </div>
                                    )}

                                    <div style={{ marginBottom: '20px' }}>
                                        <p style={{ fontSize: '16px', marginBottom: '10px' }}>
                                            Amount: <strong>₱{product.toFixed(2)}</strong> (Threshold: ₱50,000)
                                        </p>
                                    </div>
                                    <div style={inlineStyles.selectionOptions}>
                                        {product < AMOUNT_THRESHOLD ? (
                                            <div style={{...inlineStyles.option, backgroundColor: '#e8f4f8', borderColor: '#0066cc'}}>
                                                <h4>LESS: ICS (₱ &lt; 50,000)</h4>
                                                <p>Inventory Form - ICS</p>
                                            </div>
                                        ) : (
                                            <div style={{...inlineStyles.option, backgroundColor: '#fff3cd', borderColor: '#ffc107'}}>
                                                <h4>ABOVE: PAR (₱ ≥ 50,000)</h4>
                                                <p>Inventory Form - PPE + Property Inventory Tag</p>
                                            </div>
                                        )}
                                    </div>
                                    <button className={styles.nextBtn} onClick={handleFormSelection} style={{ marginTop: '20px' }}>
                                        Proceed to {product < AMOUNT_THRESHOLD ? 'ICS Form' : 'PPE Form'}
                                    </button>
                                </div>
                            )}

                        </div>

                        {submitMessage && (
                            <div className={`${styles.message} ${messageType === 'success' ? styles.success : styles.error}`}>
                                {submitMessage}
                            </div>
                        )}

                        <div className={styles.buttonContainer}>
                            <div className={styles.buttonWrapper}>
                                {currentStep !== 'create' && (
                                    <button 
                                        type="button"
                                        className={styles.backBtn}
                                        onClick={() => {
                                            const steps = ['create', 'approval', 'delivery_note', 'inspection', 'form_selection'];
                                            const currentIdx = steps.indexOf(currentStep);
                                            if (currentIdx > 0) {
                                                const previousStep = steps[currentIdx - 1];
                                                setCurrentStep(previousStep);
                                                // Clear any error/success messages when navigating back
                                                setSubmitMessage('');
                                            }
                                        }}
                                        disabled={isSubmitting}
                                    >
                                        ← Back
                                    </button>
                                )}
                            </div>
                        </div>
                    </div>
                </div>
                </div>
            </div>
    </>
    );
}

export const PurchaseRequestData = {
    unitCost: 0,
    quantity: 1,
    unit: ''
};

export default NewEntryPR;