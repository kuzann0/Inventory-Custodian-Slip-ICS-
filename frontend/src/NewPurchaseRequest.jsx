import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import API_BASE_URL from './config/api';
import styles from './css/NewPurchaseRequest.module.css';

function NewPurchaseRequest() {
    const [prNo, setPrNo] = useState('');
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState('');
    const navigate = useNavigate();

    useEffect(() => {
        // Auto-focus the input when component mounts
        const input = document.getElementById('prNoInput');
        if (input) input.focus();
    }, []);

    useEffect(() => {
        const storedPrNo = sessionStorage.getItem('current_pr_no') || sessionStorage.getItem('new_pr_name');
        if (storedPrNo) {
            setPrNo(storedPrNo);
            setIsLoading(false);
            return;
        }

        const fetchNextPrNumber = async () => {
            try {
                const response = await fetch(`${API_BASE_URL}/get_next_pr_number.php`, {
                    credentials: 'include',
                });

                const result = await response.json();
                if (!response.ok || !result.success) {
                    throw new Error(result.error || 'Failed to fetch next PR number');
                }

                setPrNo(result.pr_no);
                setError('');
            } catch (fetchErr) {
                console.error('[NewPurchaseRequest] fetch next PR number failed:', fetchErr);
                setError('Unable to generate Purchase Request Number. Please refresh the page.');
            } finally {
                setIsLoading(false);
            }
        };

        fetchNextPrNumber();
    }, []);

    const handleCreate = () => {
        if (!prNo) {
            setError('Purchase Request Number is not ready yet. Please wait and try again.');
            return;
        }

        sessionStorage.setItem('current_pr_no', prNo);
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
            
            <p className={styles.modalSubtitle}>
               Create Purchase Request Number
            </p>

            <div className={styles.inputGroup}>
                <input
                    id="prNoInput"
                    type="text"
                    placeholder={isLoading ? 'Generating PR number...' : 'Auto-generated PR number'}
                    value={prNo}
                    readOnly
                    onKeyPress={handleKeyPress}
                    className={styles.input}
                    autoComplete="off"
                />
                <div className={styles.charCount}>
                    {prNo ? prNo.length : 0}/100
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
                    disabled={isLoading || !prNo}
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
