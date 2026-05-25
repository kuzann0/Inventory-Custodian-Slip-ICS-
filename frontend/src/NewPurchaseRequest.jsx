import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import styles from './css/NewPurchaseRequest.module.css';
import API_BASE_URL from './config/api';

function NewPurchaseRequest() {
    const [prNumber, setPrNumber] = useState('');
    const [isEditing, setIsEditing] = useState(false);
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(true);
    const navigate = useNavigate();

    // Get current year-month prefix
    const getPrefix = () => {
        const now = new Date();
        return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
    };

    // Fetch next available PR number
    const fetchNextPrNumber = async () => {
        setLoading(true);
        try {
            const prefix = getPrefix();
            const response = await fetch(`${API_BASE_URL}/get_next_pr_number.php?prefix=${prefix}`, {
                credentials: 'include',
            });
            const data = await response.json();
            if (response.ok && data.pr_no) {
                setPrNumber(data.pr_no);
                setError('');
            } else {
                setError('Could not generate PR number');
            }
        } catch (err) {
            setError('Failed to connect to server');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchNextPrNumber();
        // Focus the input (if not loading, but we'll focus after load)
        const input = document.getElementById('prNameInput');
        if (input) input.focus();
    }, []);

    const handleCreate = () => {
        const trimmed = prNumber.trim();
        if (!trimmed) {
            setError('PR number cannot be empty');
            return;
        }
        // Basic format validation (YYYY-MM-NNN)
        if (!/^\d{4}-\d{2}-\d{3}$/.test(trimmed)) {
            setError('PR number must follow the format YYYY-MM-NNN (e.g., 2026-05-001)');
            return;
        }
        // Store the PR number in sessionStorage (same key as before)
        sessionStorage.setItem('new_pr_name', trimmed);
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
        <div className={styles.overlay}>
            <div className={styles.modalContainer}>
                <h2 className={styles.modalTitle}>Create Purchase Request</h2>
                <p className={styles.modalSubtitle}>Purchase Request Number</p>

                <div className={styles.inputGroup}>
                    <div className={styles.prNumberWrapper}>
                        <input
                            id="prNameInput"
                            type="text"
                            value={prNumber}
                            onChange={(e) => {
                                setPrNumber(e.target.value);
                                setError('');
                            }}
                            onKeyPress={handleKeyPress}
                            disabled={loading || (!isEditing && !loading)}
                            className={`${styles.input} ${!isEditing && !loading ? styles.readonly : ''}`}
                            autoComplete="off"
                            placeholder="YYYY-MM-NNN"
                        />
                        {!loading && (
                            <button
                                type="button"
                                className={styles.editButton}
                                id="pencilIcon"
                                onClick={() => setIsEditing(!isEditing)}
                                title={isEditing ? "Lock" : "Edit PR number"}
                            >
                                {isEditing ? '🔒' : '✏️'}
                            </button>
                        )}
                    </div>
                    {!isEditing && !loading && (
                        <div className={styles.hint}>Auto‑generated – click ✏️ to edit</div>
                    )}
                </div>

                {error && <div className={styles.error}>{error}</div>}

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
                        disabled={loading || !prNumber}
                    >
                        Create & Continue
                    </button>
                </div>

                <div className={styles.hint}>
                    💡 Tip: Press <kbd>Enter</kbd> to create, <kbd>Esc</kbd> to cancel
                </div>
            </div>
        </div>
    );
}

export default NewPurchaseRequest;