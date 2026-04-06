import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import styles from './css/PurchaseRequest.module.css'
import API_BASE_URL from './config/api'

function NewEntryPR() {
    const navigate = useNavigate();
    const AMOUNT_THRESHOLD = 50000; // Base 50K threshold

    // --------------- State Management ---------------
    const [currentStep, setCurrentStep] = useState('create'); // create, approval, delivery_note, inspection, form_selection
    const [quantity, setQuantity] = useState(0);
    const [unitCost, setUnitCost] = useState(0);
    const [prNo, setPrNo] = useState('');
    const [office, setOffice] = useState('');
    const [divisionSection, setDivisionSection] = useState('');
    const [dateRequested, setDateRequested] = useState('');
    const [itemNo, setItemNo] = useState('');
    const [unit, setUnit] = useState('');
    const [itemDescription, setItemDescription] = useState('');
    const product = quantity * unitCost;
    
    // Approval & Workflow states
    const [approvalDecision, setApprovalDecision] = useState(null); // 'approved' or 'disapproved'
    const [deliveryNotes, setDeliveryNotes] = useState('');
    const [inspectionNotes, setInspectionNotes] = useState('');
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [submitMessage, setSubmitMessage] = useState('');
    const [messageType, setMessageType] = useState('');

    // PR ID for database persistence
    const [prId, setPrId] = useState(null);

    // Initialize PR Name from modal (if coming from NewPurchaseRequest)
    useEffect(() => {
        const newPrName = sessionStorage.getItem('new_pr_name');
        if (newPrName) {
            setPrNo(newPrName);
            sessionStorage.removeItem('new_pr_name'); // Clear after use
        }
    }, []);

    // Step indicators
    const stepLabels = {
        create: '1. Create PR',
        approval: '2. Approval',
        delivery_note: '3. Delivery Note',
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
                division_section: divisionSection
            };

            const response = await fetch(`${API_BASE_URL}/submit_purchase_request.php`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
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
                notes: decision === 'approved' ? 'Approved' : 'Request disapproved'
            };

            const response = await fetch(`${API_BASE_URL}/approve_purchase_request.php`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
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

        if (!deliveryNotes.trim()) {
            setSubmitMessage('Please add delivery notes');
            setMessageType('error');
            return;
        }

        setIsSubmitting(true);

        try {
            const payload = {
                pr_id: prId,
                delivery_notes: deliveryNotes,
                actual_delivery_date: null
            };

            const response = await fetch(`${API_BASE_URL}/submit_delivery_notes.php`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
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

        if (!inspectionNotes.trim()) {
            setSubmitMessage('Please add inspection notes');
            setMessageType('error');
            return;
        }

        setIsSubmitting(true);

        try {
            // Get or create inspection assignment
            const payload = {
                pr_id: prId,
                assignment_id: prId, // Using pr_id as fallback if no explicit assignment
                inspection_notes: inspectionNotes,
                condition_report: inspectionNotes
            };

            const response = await fetch(`${API_BASE_URL}/submit_inspection.php`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
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

        // Store PR info for next steps
        sessionStorage.setItem('current_pr_id', prId);
        sessionStorage.setItem('current_pr_no', prNo);
        sessionStorage.setItem('current_pr_amount', product);
        sessionStorage.setItem('form_type', formType);

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
                            <h1>Purchase Request Workflow</h1>
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
                                    <span>Unit: <input type="text" placeholder="unit" value={unit} onChange={(e) => setUnit(e.target.value)} /></span>
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
                                    <p>PR No: <strong>{prNo}</strong></p>
                                    <p>Total Amount: <strong>₱{product.toFixed(2)}</strong></p>
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

                            {/* STEP 3: Delivery Notes */}
                            {currentStep === 'delivery_note' && (
                                <form onSubmit={handleDeliveryNote}>
                                    <h3>Note for Delivery</h3>
                                    <textarea
                                        placeholder="Enter delivery instructions, expected delivery date, contact person, etc."
                                        value={deliveryNotes}
                                        onChange={(e) => setDeliveryNotes(e.target.value)}
                                        rows="5"
                                        style={{ width: '100%', padding: '10px', marginBottom: '15px', boxSizing: 'border-box' }}
                                    />
                                    <button className={styles.nextBtn} type="submit" disabled={isSubmitting}>
                                        {isSubmitting ? 'Saving...' : 'Next: Inspection'}
                                    </button>
                                </form>
                            )}

                            {/* STEP 4: Inspection & Acceptance */}
                            {currentStep === 'inspection' && (
                                <form onSubmit={handleInspection}>
                                    <h3>Inspection & Acceptance Certificate</h3>
                                    <textarea
                                        placeholder="Condition report, findings, acceptance status, Inspector name, etc."
                                        value={inspectionNotes}
                                        onChange={(e) => setInspectionNotes(e.target.value)}
                                        rows="5"
                                        style={{ width: '100%', padding: '10px', marginBottom: '15px', boxSizing: 'border-box' }}
                                    />
                                    <button className={styles.nextBtn} type="submit" disabled={isSubmitting}>
                                        {isSubmitting ? 'Saving...' : 'Next: Form Selection'}
                                    </button>
                                </form>
                            )}

                            {/* STEP 5: Form Selection */}
                            {currentStep === 'form_selection' && (
                                <div style={inlineStyles.selectionBox}>
                                    <h3>Inventory Form Selection</h3>
                                    <p style={{ marginBottom: '20px' }}>
                                        Amount: <strong>₱{product.toFixed(2)}</strong> (Threshold: ₱50,000)
                                    </p>
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
                                        className={styles.backBtn}
                                        onClick={() => {
                                            const steps = ['create', 'approval', 'delivery_note', 'inspection', 'form_selection'];
                                            const currentIdx = steps.indexOf(currentStep);
                                            if (currentIdx > 0) setCurrentStep(steps[currentIdx - 1]);
                                        }}
                                    >
                                        Back
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

export default NewEntryPR;