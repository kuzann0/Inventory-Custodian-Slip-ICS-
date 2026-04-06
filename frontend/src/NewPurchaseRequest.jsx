import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import styles from './css/NewPurchaseRequest.module.css';

function NewPurchaseRequest() {
    const [prName, setPrName] = useState('');
    const [error, setError] = useState('');
    const navigate = useNavigate();

    useEffect(() => {
        // Auto-focus the input when component mounts
        const input = document.getElementById('prNameInput');
        if (input) input.focus();
    }, []);

    const handleCreate = () => {
        const trimmedName = prName.trim();

        if (!trimmedName) {
            setError('Please enter a Purchase Request name');
            return;
        }

        if (trimmedName.length < 3) {
            setError('Name must be at least 3 characters');
            return;
        }

        if (trimmedName.length > 100) {
            setError('Name must be less than 100 characters');
            return;
        }

        // Store the PR name in sessionStorage
        sessionStorage.setItem('new_pr_name', trimmedName);

        // Navigate to the full PR form
        navigate('/purchase-request');
    };

    const handleKeyPress = (e) => {
        if (e.key === 'Enter') {
            handleCreate();
        } else if (e.key === 'Escape') {
            navigate(-1);
        }
    };

    return (
        <div style={{ minHeight: '100vh', backgroundColor: '#f5f7fa' }}>
            <div className={styles.overlay}>
                <div className={styles.modalContainer}>
                    <h2 className={styles.modalTitle}>Create Purchase Request</h2>
                
                <p className={styles.modalSubtitle}>
                    Enter a name for your new Purchase Request
                </p>

                <div className={styles.inputGroup}>
                    <input
                        id="prNameInput"
                        type="text"
                        placeholder="e.g. 2026-01-001"
                        value={prName}
                        onChange={(e) => {
                            setPrName(e.target.value);
                            setError('');
                        }}
                        onKeyPress={handleKeyPress}
                        maxLength="100"
                        className={styles.input}
                        autoComplete="off"
                    />
                    <div className={styles.charCount}>
                        {prName.length}/100
                    </div>
                </div>

                {error && (
                    <div className={styles.error}>
                        {error}
                    </div>
                )}

                <div className={styles.buttonGroup}>
                    <button
                        className={`${styles.btn} ${styles.cancel}`}
                        onClick={() => navigate(-1)}
                    >
                        Cancel
                    </button>
                    <button
                        className={`${styles.btn} ${styles.create}`}
                        onClick={handleCreate}
                        disabled={!prName.trim()}
                    >
                        Create & Continue
                    </button>
                </div>

                <div className={styles.hint}>
                    💡 Tip: Press <kbd>Enter</kbd> to create, <kbd>Esc</kbd> to cancel
                </div>
            </div>
            </div>
        </div>
    );
}

export default NewPurchaseRequest;
