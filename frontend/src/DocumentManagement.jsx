import React, { useState, useEffect } from 'react';
import API_BASE_URL from './config/api';

const DocumentManagement = () => {
  const [documents, setDocuments] = useState([]);
  const [loading, setLoading] = useState(false);
  const [uploadModal, setUploadModal] = useState(false);
  const [formData, setFormData] = useState({
    pr_no: '',
    document_type: 'invoice',
    file: null
  });
  const [message, setMessage] = useState('');
  const [messageType, setMessageType] = useState('');

  useEffect(() => {
    fetchDocuments();
  }, []);

  const fetchDocuments = async () => {
    setLoading(true);
    try {
      const response = await fetch(`${API_BASE_URL}/get_documents.php`, {
        credentials: 'include'
      });
      if (response.ok) {
        const data = await response.json();
        setDocuments(data.documents || []);
      }
    } catch (error) {
      console.error('Error fetching documents:', error);
      setMessage('Failed to load documents');
      setMessageType('error');
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e) => {
    const { name, value, files } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: files ? files[0] : value
    }));
  };

  const handleUploadDocument = async (e) => {
    e.preventDefault();

    if (!formData.pr_no || !formData.file) {
      setMessage('Please fill all fields and select a file');
      setMessageType('error');
      return;
    }

    const uploadData = new FormData();
    uploadData.append('pr_no', formData.pr_no);
    uploadData.append('document_type', formData.document_type);
    uploadData.append('file', formData.file);

    try {
      const response = await fetch(`${API_BASE_URL}/upload_document.php`, {
        method: 'POST',
        credentials: 'include',
        body: uploadData
      });

      const result = await response.json();

      if (result.success) {
        setMessage('✓ Document uploaded successfully');
        setMessageType('success');
        setFormData({ pr_no: '', document_type: 'invoice', file: null });
        setUploadModal(false);
        fetchDocuments();
        setTimeout(() => setMessage(''), 3000);
      } else {
        setMessage(result.error || 'Failed to upload document');
        setMessageType('error');
      }
    } catch (error) {
      console.error('Error uploading document:', error);
      setMessage('Error uploading document');
      setMessageType('error');
    }
  };

  const handleDownloadDocument = async (documentId) => {
    try {
      const response = await fetch(`${API_BASE_URL}/download_document.php?document_id=${documentId}`, {
        credentials: 'include'
      });
      if (response.ok) {
        const blob = await response.blob();
        const url = window.URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = `document_${documentId}.pdf`;
        link.click();
      }
    } catch (error) {
      console.error('Error downloading document:', error);
      setMessage('Failed to download document');
      setMessageType('error');
    }
  };

  return (
    <div style={styles.container}>
      <div style={styles.header}>
        <h2>Document Management</h2>
        <button
          style={styles.uploadButton}
          onClick={() => setUploadModal(true)}
        >
          + Upload Document
        </button>
      </div>

      {message && (
        <div style={{
          ...styles.message,
          backgroundColor: messageType === 'success' ? '#d4edda' : '#f8d7da',
          color: messageType === 'success' ? '#155724' : '#721c24',
          borderColor: messageType === 'success' ? '#c3e6cb' : '#f5c6cb'
        }}>
          {message}
        </div>
      )}

      {loading ? (
        <div style={styles.loading}>Loading documents...</div>
      ) : documents.length === 0 ? (
        <div style={styles.empty}>No documents uploaded yet</div>
      ) : (
        <div style={styles.table}>
          <table style={styles.tableElement}>
            <thead>
              <tr>
                <th>PR No.</th>
                <th>Document Type</th>
                <th>Uploaded By</th>
                <th>Upload Date</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {documents.map((doc) => (
                <tr key={doc.id}>
                  <td>{doc.pr_no}</td>
                  <td>
                    <span style={styles.docBadge}>{doc.document_type}</span>
                  </td>
                  <td>{doc.uploaded_by}</td>
                  <td>{new Date(doc.upload_date).toLocaleDateString()}</td>
                  <td>
                    <span style={{
                      ...styles.badge,
                      backgroundColor: doc.verified ? '#28a745' : '#ffc107'
                    }}>
                      {doc.verified ? 'Verified' : 'Pending'}
                    </span>
                  </td>
                  <td>
                    <button
                      style={styles.button}
                      onClick={() => handleDownloadDocument(doc.id)}
                    >
                      Download
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {uploadModal && (
        <div style={styles.modal}>
          <div style={styles.modalContent}>
            <h3>Upload Document</h3>
            <form onSubmit={handleUploadDocument}>
              <div style={styles.formGroup}>
                <label>PR Number:</label>
                <input
                  type="text"
                  name="pr_no"
                  placeholder="Enter PR number"
                  value={formData.pr_no}
                  onChange={handleInputChange}
                  style={styles.input}
                />
              </div>

              <div style={styles.formGroup}>
                <label>Document Type:</label>
                <select
                  name="document_type"
                  value={formData.document_type}
                  onChange={handleInputChange}
                  style={styles.input}
                >
                  <option value="invoice">Invoice</option>
                  <option value="receipt">Receipt</option>
                  <option value="delivery_note">Delivery Note</option>
                  <option value="inspection_report">Inspection Report</option>
                  <option value="other">Other</option>
                </select>
              </div>

              <div style={styles.formGroup}>
                <label>Select File:</label>
                <input
                  type="file"
                  name="file"
                  onChange={handleInputChange}
                  style={styles.input}
                  accept=".pdf,.doc,.docx,.xlsx"
                />
              </div>

              <div style={styles.modalButtons}>
                <button type="submit" style={{...styles.primaryButton, backgroundColor: '#007bff'}}>
                  Upload
                </button>
                <button
                  type="button"
                  style={{...styles.primaryButton, backgroundColor: '#6c757d'}}
                  onClick={() => {
                    setUploadModal(false);
                    setFormData({ pr_no: '', document_type: 'invoice', file: null });
                  }}
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

const styles = {
  container: {
    padding: '20px',
    flex: 1,
    overflowY: 'auto'
  },
  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: '30px'
  },
  uploadButton: {
    padding: '10px 20px',
    backgroundColor: '#28a745',
    color: 'white',
    border: 'none',
    borderRadius: '4px',
    cursor: 'pointer',
    fontSize: '14px'
  },
  message: {
    padding: '12px 16px',
    borderRadius: '4px',
    marginBottom: '20px',
    border: '1px solid'
  },
  loading: {
    textAlign: 'center',
    padding: '40px',
    color: '#666'
  },
  empty: {
    textAlign: 'center',
    padding: '40px',
    color: '#999'
  },
  table: {
    overflowX: 'auto'
  },
  tableElement: {
    width: '100%',
    borderCollapse: 'collapse',
    backgroundColor: 'white',
    borderRadius: '8px',
    boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
  },
  badge: {
    padding: '4px 8px',
    borderRadius: '4px',
    color: 'white',
    fontSize: '12px'
  },
  docBadge: {
    padding: '4px 8px',
    borderRadius: '4px',
    backgroundColor: '#e7f3ff',
    color: '#0066cc',
    fontSize: '12px'
  },
  button: {
    padding: '6px 12px',
    backgroundColor: '#007bff',
    color: 'white',
    border: 'none',
    borderRadius: '4px',
    cursor: 'pointer',
    fontSize: '12px'
  },
  modal: {
    position: 'fixed',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0,0,0,0.5)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 1000
  },
  modalContent: {
    backgroundColor: 'white',
    padding: '30px',
    borderRadius: '8px',
    width: '90%',
    maxWidth: '500px'
  },
  formGroup: {
    marginBottom: '20px'
  },
  input: {
    width: '100%',
    padding: '10px',
    border: '1px solid #ddd',
    borderRadius: '4px',
    fontSize: '14px',
    boxSizing: 'border-box'
  },
  primaryButton: {
    padding: '10px 20px',
    color: 'white',
    border: 'none',
    borderRadius: '4px',
    cursor: 'pointer',
    fontSize: '14px'
  },
  modalButtons: {
    display: 'flex',
    gap: '10px',
    justifyContent: 'flex-end'
  }
};

export default DocumentManagement;
