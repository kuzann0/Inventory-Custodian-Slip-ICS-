import React, { useEffect, useState } from "react";
import styles from "./css/ViewEntries.module.css";
import API_BASE_URL from "./config/api";

function ViewEntries() {
  const [entries, setEntries] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [sortConfig, setSortConfig] = useState({ key: "order_id", direction: "desc" });
  const [expandedRows, setExpandedRows] = useState(new Set());
  const itemsPerPage = 8;

  // ─── Utilities ─────────────────────────────────────────────────────────────
  const formatCurrency = (value) => {
    if (!value && value !== 0) return "—";
    return `₱ ${parseFloat(value).toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  };

  const formatDate = (dateStr) => {
    if (!dateStr) return "—";
    try {
      return new Date(dateStr).toLocaleDateString('en-PH', { year: 'numeric', month: 'short', day: 'numeric' });
    } catch {
      return dateStr;
    }
  };

  const getStatusBadge = (status, category = 'approval') => {
    if (!status) return { color: '#94a3b8', label: '—' };
    const statusMap = {
      approval: { 'approved': '#059669', 'pending': '#f59e0b', 'rejected': '#dc2626' },
      delivery: { 'delivered': '#059669', 'in_delivery': '#3b82f6', 'pending': '#f59e0b' },
      inspection: { 'inspected': '#059669', 'in_progress': '#3b82f6', 'pending': '#f59e0b' },
    };
    return { color: statusMap[category]?.[status] || '#94a3b8', label: status };
  };

  // ─── Data fetching ────────────────────────────────────────────────────────
  const fetchEntries = () => {
    setLoading(true);
    setError(null);
    fetch(`${API_BASE_URL}/get_entries.php`, {
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' }
    })
      .then(res => {
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        return res.json();
      })
      .then(data => {
        if (data.status === "success" && Array.isArray(data.data)) {
          setEntries(data.data);
        } else {
          throw new Error(data.message || 'Invalid response format');
        }
      })
      .catch(err => {
        console.error("Error fetching entries:", err);
        setError(err.message);
      })
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    fetchEntries();
    const interval = setInterval(fetchEntries, 60000); // refresh every 60s
    return () => clearInterval(interval);
  }, []);

  // ─── Filtering ───────────────────────────────────────────────────────────
  const filteredEntries = entries.filter(entry => {
    const term = searchTerm.toLowerCase();
    return (
      String(entry.order_id).includes(term) ||
      entry.Item?.toLowerCase().includes(term) ||
      entry.SerialNo?.toLowerCase().includes(term) ||
      entry.InventoryItemNo?.toLowerCase().includes(term) ||
      entry.Location?.toLowerCase().includes(term) ||
      entry.Description?.toLowerCase().includes(term) ||
      entry.pr_number?.toLowerCase().includes(term) ||
      entry.approved_by_name?.toLowerCase().includes(term)
    );
  });

  // ─── Sorting ─────────────────────────────────────────────────────────────
  const sortedEntries = [...filteredEntries].sort((a, b) => {
    const aVal = a[sortConfig.key];
    const bVal = b[sortConfig.key];
    if (aVal === null || aVal === undefined) return sortConfig.direction === "asc" ? 1 : -1;
    if (bVal === null || bVal === undefined) return sortConfig.direction === "asc" ? -1 : 1;
    if (typeof aVal === "number" && typeof bVal === "number") {
      return sortConfig.direction === "asc" ? aVal - bVal : bVal - aVal;
    }
    const aStr = String(aVal).toLowerCase();
    const bStr = String(bVal).toLowerCase();
    return sortConfig.direction === "asc" ? aStr.localeCompare(bStr) : bStr.localeCompare(aStr);
  });

  // ─── Pagination ──────────────────────────────────────────────────────────
  const totalPages = Math.ceil(sortedEntries.length / itemsPerPage);
  const startIdx = (currentPage - 1) * itemsPerPage;
  const paginatedEntries = sortedEntries.slice(startIdx, startIdx + itemsPerPage);

  // ─── Handlers ────────────────────────────────────────────────────────────
  const handleSort = (key) => {
    setSortConfig(prev => ({
      key,
      direction: prev.key === key && prev.direction === "asc" ? "desc" : "asc",
    }));
    setCurrentPage(1);
  };

  const handleSearch = (e) => {
    setSearchTerm(e.target.value);
    setCurrentPage(1);
  };

  const toggleRowExpanded = (orderId) => {
    const newSet = new Set(expandedRows);
    if (newSet.has(orderId)) newSet.delete(orderId);
    else newSet.add(orderId);
    setExpandedRows(newSet);
  };

  const handlecsv = () => {
  const columns = [
    'order_id', 'Item', 'Quantity', 'Unit', 'UnitCost', 'TotalCost',
    'SerialNo', 'InventoryItemNo', 'DateAcquired', 'Location', 'EstimatedUsefulLife',
    'Description', 'ApprovalStatus', 'approved_by_name', 'ApprovedDate',
    'DeliveryStatus', 'DeliveryDate', 'InspectionStatus', 'inspected_by_name',
    'FormType', 'pr_number', 'WorkflowStep'
  ];

  const csvRows = [];
  // Add UTF-8 BOM (EF BB BF)
  csvRows.push('\uFEFF' + columns.join(','));

  sortedEntries.forEach(entry => {
    const row = columns.map(col => {
      let val = entry[col];
      if (val === null || val === undefined) return '';
      if (val === '—') return '';

      // Convert objects (like FormData) to JSON string
      if (typeof val === 'object' && val !== null) {
        val = JSON.stringify(val);
      }

      // Convert date strings to US format
      const dateColumns = ['DateAcquired', 'ApprovedDate', 'DeliveryDate', 'InspectionDate', 'FormSubmitDate'];
      if (dateColumns.includes(col) && typeof val === 'string' && val.match(/^\d{4}-\d{2}-\d{2}/)) {
        val = new Date(val).toLocaleDateString('en-US');
      }

      // CSV escaping
      if (typeof val === 'string' && (val.includes(',') || val.includes('"') || val.includes('\n'))) {
        return `"${val.replace(/"/g, '""')}"`;
      }
      return val;
    }).join(',');
    csvRows.push(row);
  });

  const blob = new Blob([csvRows.join('\n')], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = `entries_${new Date().toISOString().split('T')[0]}.csv`;
  link.click();
  URL.revokeObjectURL(link.href);  
};

// Sort icon component
  const SortIcon = ({ column }) => {
  if (sortConfig.key !== column) return <span className={styles.sortIcon}>↕</span>;
  return sortConfig.direction === "asc" 
    ? <span className={styles.sortIcon}>↑</span> 
    : <span className={styles.sortIcon}>↓</span>;
  };

  // ─── Render ──────────────────────────────────────────────────────────────
  return (
    <div className={styles.mainContainer}>
      <div className={styles.wrapper}>
        {/* Header */}
        <div className={styles.headerSection}>
          <div className={styles.headerContent}>
            <div>
              <h1 className={styles.pageTitle}>Inventory Entries</h1>
              <p className={styles.pageSubtitle}>{sortedEntries.length} items • {paginatedEntries.length} showing</p>
            </div>
            <div className={styles.headerActions}>
              <button className={styles.actionBtn} onClick={fetchEntries} title="Refresh" style={{padding: '10px 16px', fontSize: '13px', fontWeight: 500}}>
                <span className={styles.btnIcon}>↻</span> Refresh
              </button>
              <button className={styles.actionBtn} onClick={handlecsv} title="Export CSV" style={{padding: '10px 16px', fontSize: '13px', fontWeight: 500}}>
                <span className={styles.btnIcon}>⬇</span> Export
              </button>
            </div>
          </div>
        </div>

        {/* Search */}
        <div className={styles.searchSection}>
          <div className={styles.searchWrapper}>
            <span className={styles.searchIcon}></span>
            <input
              type="text"
              placeholder="Search entries..."
              value={searchTerm}
              onChange={handleSearch}
              className={styles.searchInput}
            />
            {searchTerm && (
              <span className={styles.searchCount}>
                {filteredEntries.length} result{filteredEntries.length !== 1 ? 's' : ''}
              </span>
            )}
          </div>
        </div>

        {/* Error */}
        {error && (
          <div className={styles.alertContainer} style={{ borderLeftColor: '#dc2626' }}>
            <div className={styles.alertContent}>
              <span className={styles.alertIcon}>⚠</span>
              <div>
                <p className={styles.alertTitle}>Error loading entries</p>
                <p className={styles.alertMessage}>{error}</p>
              </div>
            </div>
            <button onClick={fetchEntries} className={styles.alertBtn}>Try Again</button>
          </div>
        )}

        {/* Loading */}
        {loading && (
          <div className={styles.emptyStateContainer}>
            <div className={styles.loadingSpinner}></div>
            <p className={styles.emptyStateText}>Loading entries...</p>
          </div>
        )}

        {/* Data Table */}
        {!loading && !error && paginatedEntries.length > 0 && (
          <>
            <div className={styles.tableWrapper}>
              <table className={styles.table}>
                <thead>
                  <tr>
                    <th style={{ width: '40px' }}></th>
                    <th onClick={() => handleSort('order_id')} className={styles.headerCell}>
                      <div className={styles.headerCellContent}><span>ID</span><SortIcon column="order_id" /></div>
                    </th>
                    <th onClick={() => handleSort('Item')} className={styles.headerCell}>
                      <div className={styles.headerCellContent}><span>Item</span><SortIcon column="Item" /></div>
                    </th>
                    <th onClick={() => handleSort('Quantity')} className={styles.headerCell}>
                      <div className={styles.headerCellContent}><span>Qty</span><SortIcon column="Quantity" /></div>
                    </th>
                    <th onClick={() => handleSort('UnitCost')} className={styles.headerCell}>
                      <div className={styles.headerCellContent}><span>Unit Cost</span><SortIcon column="UnitCost" /></div>
                    </th>
                    <th onClick={() => handleSort('TotalCost')} className={styles.headerCell}>
                      <div className={styles.headerCellContent}><span>Total</span><SortIcon column="TotalCost" /></div>
                    </th>
                    <th onClick={() => handleSort('SerialNo')} className={styles.headerCell}>
                      <div className={styles.headerCellContent}><span>Serial</span><SortIcon column="SerialNo" /></div>
                    </th>
                    <th onClick={() => handleSort('ApprovalStatus')} className={styles.headerCell}>
                      <div className={styles.headerCellContent}><span>Approval</span><SortIcon column="ApprovalStatus" /></div>
                    </th>
                    <th onClick={() => handleSort('DeliveryStatus')} className={styles.headerCell}>
                      <div className={styles.headerCellContent}><span>Delivery</span><SortIcon column="DeliveryStatus" /></div>
                    </th>
                    <th onClick={() => handleSort('InspectionStatus')} className={styles.headerCell}>
                      <div className={styles.headerCellContent}><span>Inspection</span><SortIcon column="InspectionStatus" /></div>
                    </th>
                    <th onClick={() => handleSort('Location')} className={styles.headerCell}>
                      <div className={styles.headerCellContent}><span>Location</span><SortIcon column="Location" /></div>
                    </th>
                    <th onClick={() => handleSort('approved_by_name')} className={styles.headerCell}>
                      <div className={styles.headerCellContent}><span>Approved By</span><SortIcon column="approved_by_name" /></div>
                    </th>
                    <th onClick={() => handleSort('FormType')} className={styles.headerCell}>
                      <div className={styles.headerCellContent}><span>Form</span><SortIcon column="FormType" /></div>
                    </th>
                    <th onClick={() => handleSort('pr_number')} className={styles.headerCell}>
                      <div className={styles.headerCellContent}><span>PR #</span><SortIcon column="pr_number" /></div>
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {paginatedEntries.map(entry => {
                    const isExpanded = expandedRows.has(entry.order_id);
                    const approvalBadge = getStatusBadge(entry.ApprovalStatus, 'approval');
                    const deliveryBadge = getStatusBadge(entry.DeliveryStatus, 'delivery');
                    const inspectionBadge = getStatusBadge(entry.InspectionStatus, 'inspection');

                    return (
                      <React.Fragment key={entry.order_id}>
                        <tr className={styles.tableRow}>
                          <td className={styles.expandCell} onClick={() => toggleRowExpanded(entry.order_id)}>
                            <span className={styles.expandIcon} style={{ transform: isExpanded ? 'rotate(180deg)' : 'rotate(0deg)' }}>▼</span>
                          </td>
                          <td className={styles.idCell}>{entry.order_id}</td>
                          <td className={styles.itemCell}>{entry.Item || '—'}</td>
                          <td className={styles.numberCell}>{entry.Quantity || 0}</td>
                          <td className={styles.currencyCell}>{formatCurrency(entry.UnitCost)}</td>
                          <td className={styles.currencyCell}>{formatCurrency(entry.TotalCost)}</td>
                          <td className={styles.serialCell}>{entry.SerialNo || '—'}</td>
                          <td className={styles.statusCell}>
                            <span className={styles.badge} style={{ backgroundColor: approvalBadge.color }}>{approvalBadge.label}</span>
                          </td>
                          <td className={styles.statusCell}>
                            <span className={styles.badge} style={{ backgroundColor: deliveryBadge.color }}>{deliveryBadge.label}</span>
                          </td>
                          <td className={styles.statusCell}>
                            <span className={styles.badge} style={{ backgroundColor: inspectionBadge.color }}>{inspectionBadge.label}</span>
                          </td>
                          <td className={styles.serialCell}>{entry.Location || '—'}</td>
                          <td className={styles.serialCell}>{entry.approved_by_name || '—'}</td>
                          <td className={styles.serialCell}>{entry.FormType || '—'}</td>
                          <td className={styles.codeCell}>{entry.pr_number}</td>
                        </tr>

                        {/* Expanded detail row – nested table */}
                        {isExpanded && (
                          <tr className={styles.detailRow}>
                            <td colSpan="15">
                              <table className={styles.detailTable}>
                                <tbody>
                                  <tr>
                                    <th className={styles.detailTh}>Order ID</th>
                                    <td className={styles.detailTd}>{entry.order_id}</td>
                                    <th className={styles.detailTh}>Item</th>
                                    <td className={styles.detailTd}>{entry.Item || '—'}</td>
                                  </tr>
                                  <tr>
                                    <th className={styles.detailTh}>Description</th>
                                    <td colSpan="3" className={styles.detailTd}>{entry.Description || '—'}</td>
                                  </tr>
                                  <tr>
                                    <th className={styles.detailTh}>Quantity / Unit</th>
                                    <td className={styles.detailTd}>{entry.Quantity || 0} {entry.Unit || ''}</td>
                                    <th className={styles.detailTh}>Unit Cost</th>
                                    <td className={styles.detailTd}>{formatCurrency(entry.UnitCost)}</td>
                                  </tr>
                                  <tr>
                                    <th className={styles.detailTh}>Total Cost</th>
                                    <td className={styles.detailTd}>{formatCurrency(entry.TotalCost)}</td>
                                    <th className={styles.detailTh}>Amount</th>
                                    <td className={styles.detailTd}>{formatCurrency(entry.Amount)}</td>
                                  </tr>
                                  <tr>
                                    <th className={styles.detailTh}>Serial No</th>
                                    <td className={styles.detailTd}>{entry.SerialNo || '—'}</td>
                                    <th className={styles.detailTh}>Inventory No</th>
                                    <td className={styles.detailTd}>{entry.InventoryItemNo || '—'}</td>
                                  </tr>
                                  <tr>
                                    <th className={styles.detailTh}>Date Acquired</th>
                                    <td className={styles.detailTd}>{formatDate(entry.DateAcquired)}</td>
                                    <th className={styles.detailTh}>Est. Useful Life</th>
                                    <td className={styles.detailTd}>{entry.EstimatedUsefulLife || '—'}</td>
                                  </tr>
                                  <tr>
                                    <th className={styles.detailTh}>Location</th>
                                    <td className={styles.detailTd}>{entry.Location || '—'}</td>
                                    <th className={styles.detailTh}>PR Number</th>
                                    <td className={styles.detailTd}>{entry.pr_number}</td>
                                  </tr>
                                  <tr>
                                    <th className={styles.detailTh}>Approval Status</th>
                                    <td className={styles.detailTd}>
                                      <span className={styles.badge} style={{ backgroundColor: approvalBadge.color }}>{approvalBadge.label}</span>
                                    </td>
                                    <th className={styles.detailTh}>Approved By</th>
                                    <td className={styles.detailTd}>{entry.approved_by_name || '—'}</td>
                                  </tr>
                                  <tr>
                                    <th className={styles.detailTh}>Approved Date</th>
                                    <td className={styles.detailTd}>{formatDate(entry.ApprovedDate)}</td>
                                    <th className={styles.detailTh}>Delivery Status</th>
                                    <td className={styles.detailTd}>
                                      <span className={styles.badge} style={{ backgroundColor: deliveryBadge.color }}>{deliveryBadge.label}</span>
                                    </td>
                                  </tr>
                                  <tr>
                                    <th className={styles.detailTh}>Delivery Date</th>
                                    <td className={styles.detailTd}>{formatDate(entry.DeliveryDate)}</td>
                                    <th className={styles.detailTh}>Delivery Notes</th>
                                    <td className={styles.detailTd}>{entry.DeliveryNotes || '—'}</td>
                                  </tr>
                                  <tr>
                                    <th className={styles.detailTh}>Inspection Status</th>
                                    <td className={styles.detailTd}>
                                      <span className={styles.badge} style={{ backgroundColor: inspectionBadge.color }}>{inspectionBadge.label}</span>
                                    </td>
                                    <th className={styles.detailTh}>Inspected By</th>
                                    <td className={styles.detailTd}>{entry.inspected_by_name || '—'}</td>
                                  </tr>
                                  <tr>
                                    <th className={styles.detailTh}>Inspection Date</th>
                                    <td className={styles.detailTd}>{formatDate(entry.InspectionDate)}</td>
                                    <th className={styles.detailTh}>Inspection Notes</th>
                                    <td className={styles.detailTd}>{entry.InspectionNotes || '—'}</td>
                                  </tr>
                                  <tr>
                                    <th className={styles.detailTh}>Form Type</th>
                                    <td className={styles.detailTd}>{entry.FormType || '—'}</td>
                                    <th className={styles.detailTh}>Form Status</th>
                                    <td className={styles.detailTd}>{entry.FormStatus || '—'}</td>
                                  </tr>
                                  <tr>
                                    <th className={styles.detailTh}>Form Submit Date</th>
                                    <td className={styles.detailTd}>{formatDate(entry.FormSubmitDate)}</td>
                                    <th className={styles.detailTh}>Current Step</th>
                                    <td className={styles.detailTd}>{entry.WorkflowStep || 1} / 5</td>
                                  </tr>
                                  {entry.FormData && (
                                    <tr>
                                      <th className={styles.detailTh}>Form Data</th>
                                      <td colSpan="3" className={styles.detailTd}>
                                        <details>
                                          <summary>View JSON</summary>
                                          <pre className={styles.jsonPre}>{JSON.stringify(entry.FormData, null, 2)}</pre>
                                        </details>
                                      </td>
                                    </tr>
                                  )}
                                </tbody>
                              </table>
                            </td>
                          </tr>
                        )}
                      </React.Fragment>
                    );
                  })}
                </tbody>
              </table>
            </div>

            {/* Pagination */}
            <div className={styles.paginationSection}>
              <button className={`${styles.paginationBtn} ${currentPage === 1 ? styles.disabled : ''}`}
                onClick={() => setCurrentPage(1)} disabled={currentPage === 1}>⟨⟨</button>
              <button className={`${styles.paginationBtn} ${currentPage === 1 ? styles.disabled : ''}`}
                onClick={() => setCurrentPage(Math.max(1, currentPage - 1))} disabled={currentPage === 1}>⟨</button>
              <div className={styles.pageNumbers}>
                {Array.from({ length: totalPages }, (_, i) => i + 1)
                  .filter(page => Math.abs(page - currentPage) <= 2 || page === 1 || page === totalPages)
                  .map((page, idx, arr) => (
                    <div key={page}>
                      {idx > 0 && arr[idx - 1] !== page - 1 && <span className={styles.ellipsis}>...</span>}
                      <button className={`${styles.paginationBtn} ${currentPage === page ? styles.active : ''}`}
                        onClick={() => setCurrentPage(page)}>{page}</button>
                    </div>
                  ))}
              </div>
              <button className={`${styles.paginationBtn} ${currentPage === totalPages ? styles.disabled : ''}`}
                onClick={() => setCurrentPage(Math.min(totalPages, currentPage + 1))} disabled={currentPage === totalPages}>⟩</button>
              <button className={`${styles.paginationBtn} ${currentPage === totalPages ? styles.disabled : ''}`}
                onClick={() => setCurrentPage(totalPages)} disabled={currentPage === totalPages}>⟩⟩</button>
              <div className={styles.pageInfo}>Page <strong>{currentPage}</strong> of <strong>{totalPages}</strong></div>
            </div>
          </>
        )}

        {/* Empty State */}
        {!loading && !error && filteredEntries.length === 0 && (
          <div className={styles.emptyStateContainer}>
            <p className={styles.emptyIcon}>📭</p>
            <p className={styles.emptyStateText}>No entries found</p>
            <p className={styles.emptyStateSubtext}>Try adjusting your search criteria</p>
          </div>
        )}
      </div>
    </div>
  );
}

export default ViewEntries;