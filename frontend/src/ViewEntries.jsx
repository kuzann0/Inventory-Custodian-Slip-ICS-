import { useEffect, useState } from "react";
import styles from "./css/ViewEntries.module.css";
import API_BASE_URL from "./config/api";

function ViewEntries() {
  const [entries, setEntries] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [sortConfig, setSortConfig] = useState({ key: "order_id", direction: "asc" });
  const itemsPerPage = 10;

  const fetchEntries = () => {
    fetch(`${API_BASE_URL}/get_entries.php`, {
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' }
    })
      .then((res) => res.json())
      .then((data) => {
        const entriesArray = Array.isArray(data) ? data : [];
        setEntries(entriesArray);
      })
      .catch((err) => console.error("Error fetching entries:", err));
  };

  useEffect(() => {
    fetchEntries();
    const interval = setInterval(fetchEntries, 30000); // Refresh every 30s instead of 5s
    return () => clearInterval(interval);
  }, []);

  // Filter entries based on search term
  const filteredEntries = entries.filter((entry) => {
    const searchLower = searchTerm.toLowerCase();
    return (
      entry.Item?.toLowerCase().includes(searchLower) ||
      entry.SerialNo?.toLowerCase().includes(searchLower) ||
      entry.InventoryItemNo?.toLowerCase().includes(searchLower) ||
      entry.Location?.toLowerCase().includes(searchLower) ||
      entry.Description?.toLowerCase().includes(searchLower)
    );
  });

  // Sort entries
  const sortedEntries = [...filteredEntries].sort((a, b) => {
    const aVal = a[sortConfig.key];
    const bVal = b[sortConfig.key];

    if (aVal === null || aVal === undefined) return 1;
    if (bVal === null || bVal === undefined) return -1;

    if (typeof aVal === "number") {
      return sortConfig.direction === "asc" ? aVal - bVal : bVal - aVal;
    }

    const aStr = aVal.toString().toLowerCase();
    const bStr = bVal.toString().toLowerCase();
    return sortConfig.direction === "asc"
      ? aStr.localeCompare(bStr)
      : bStr.localeCompare(aStr);
  });

  // Paginate
  const totalPages = Math.ceil(sortedEntries.length / itemsPerPage);
  const startIdx = (currentPage - 1) * itemsPerPage;
  const paginatedEntries = sortedEntries.slice(startIdx, startIdx + itemsPerPage);

  const handleSort = (key) => {
    setSortConfig((prev) => ({
      key,
      direction: prev.key === key && prev.direction === "asc" ? "desc" : "asc",
    }));
  };

  const handleSearch = (e) => {
    setSearchTerm(e.target.value);
    setCurrentPage(1); // Reset to first page on new search
  };

  const handleExport = () => {
    // CSV export functionality
    const headers = [
      "ID",
      "Item",
      "Serial No",
      "Inventory Item No",
      "Quantity",
      "Unit",
      "Unit Cost",
      "Total Cost",
      "Description",
      "Location",
      "Date Acquired",
      "Estimated Useful Life"
    ];

    const csv = [
      headers.join(","),
      ...sortedEntries.map((entry) =>
        [
          entry.order_id,
          `"${entry.Item || ""}"`,
          entry.SerialNo || "",
          entry.InventoryItemNo || "",
          entry.Quantity || 0,
          entry.Unit || "",
          entry.UnitCost || 0,
          entry.TotalCost || 0,
          `"${entry.Description || ""}"`,
          entry.Location || "",
          entry.DateAcquired || "",
          entry.EstimatedUsefulLife || ""
        ].join(",")
      )
    ].join("\n");

    const blob = new Blob([csv], { type: "text/csv" });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `inventory_entries_${new Date().toISOString().split("T")[0]}.csv`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    window.URL.revokeObjectURL(url);
  };

  const SortIcon = ({ column }) => {
    if (sortConfig.key !== column) return null;
    return sortConfig.direction === "asc" ? <span></span> : <span></span>;
  };

  return (
    <div className={styles.mainContainer}>
      <div className={styles.wrapper}>
        {/* Header with search and export */}
        <div className={styles.header}>
          <div className={styles.headerLeft}>
            <h2>Inventory Entries</h2>
            <p>{sortedEntries.length} items total</p>
          </div>
          <button className={styles.exportBtn} onClick={handleExport} title="Export to CSV">
            Export Data
          </button>
        </div>

        {/* Search bar */}
        <div className={styles.searchContainer}>
          <input
            type="text"
            placeholder="Search by item name, serial no, inventory no, location..."
            value={searchTerm}
            onChange={handleSearch}
            className={styles.searchInput}
          />
          {searchTerm && (
            <p className={styles.searchResults}>
              Found {filteredEntries.length} result{filteredEntries.length !== 1 ? "s" : ""}
            </p>
          )}
        </div>

        {/* Table Container */}
        {paginatedEntries.length > 0 ? (
          <>
            <div className={styles.tableContainer}>
              <table className={styles.entryTable}>
                <thead>
                  <tr>
                    <th onClick={() => handleSort("order_id")}>
                      ID <SortIcon column="order_id" />
                    </th>
                    <th onClick={() => handleSort("Item")}>
                      Item <SortIcon column="Item" />
                    </th>
                    <th onClick={() => handleSort("SerialNo")}>
                      Serial No <SortIcon column="SerialNo" />
                    </th>
                    <th onClick={() => handleSort("InventoryItemNo")}>
                      Inv. Item No <SortIcon column="InventoryItemNo" />
                    </th>
                    <th onClick={() => handleSort("Quantity")}>
                      Qty <SortIcon column="Quantity" />
                    </th>
                    <th onClick={() => handleSort("Unit")}>
                      Unit <SortIcon column="Unit" />
                    </th>
                    <th onClick={() => handleSort("UnitCost")}>
                      Unit Cost <SortIcon column="UnitCost" />
                    </th>
                    <th onClick={() => handleSort("TotalCost")}>
                      Total Cost <SortIcon column="TotalCost" />
                    </th>
                    <th onClick={() => handleSort("Description")}>
                      Description <SortIcon column="Description" />
                    </th>
                    <th onClick={() => handleSort("Location")}>
                      Location <SortIcon column="Location" />
                    </th>
                    <th onClick={() => handleSort("DateAcquired")}>
                      Date Acquired <SortIcon column="DateAcquired" />
                    </th>
                    <th onClick={() => handleSort("EstimatedUsefulLife")}>
                      Est. Life <SortIcon column="EstimatedUsefulLife" />
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {paginatedEntries.map((entry) => (
                    <tr key={entry.order_id} className={styles.tableRow}>
                      <td>{entry.order_id}</td>
                      <td className={styles.itemName}>{entry.Item || "—"}</td>
                      <td>{entry.SerialNo || "—"}</td>
                      <td>{entry.InventoryItemNo || "—"}</td>
                      <td className={styles.numeric}>{entry.Quantity || 0}</td>
                      <td>{entry.Unit || "—"}</td>
                      <td className={styles.numeric}>
                        ₱ {parseFloat(entry.UnitCost || 0).toFixed(2)}
                      </td>
                      <td className={styles.numeric}>
                        ₱ {parseFloat(entry.TotalCost || 0).toFixed(2)}
                      </td>
                      <td className={styles.description}>{entry.Description || "—"}</td>
                      <td>{entry.Location || "—"}</td>
                      <td>{entry.DateAcquired || "—"}</td>
                      <td>{entry.EstimatedUsefulLife || "—"}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Pagination */}
            {totalPages > 1 && (
              <div className={styles.pagination}>
                <button
                  onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                  disabled={currentPage === 1}
                  className={styles.paginationBtn}
                >
                  Previous
                </button>

                <div className={styles.pageNumbers}>
                  {Array.from({ length: totalPages }, (_, i) => i + 1).map((page) => (
                    <button
                      key={page}
                      onClick={() => setCurrentPage(page)}
                      className={`${styles.paginationBtn} ${
                        currentPage === page ? styles.active : ""
                      }`}
                    >
                      {page}
                    </button>
                  ))}
                </div>

                <button
                  onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
                  disabled={currentPage === totalPages}
                  className={styles.paginationBtn}
                >
                  Next
                </button>

                <span className={styles.pageInfo}>
                  Page {currentPage} of {totalPages} • Showing {paginatedEntries.length} of{" "}
                  {sortedEntries.length}
                </span>
              </div>
            )}
          </>
        ) : (
          <div className={styles.noData}>
            <p>No entries found</p>
            <p className={styles.noDataSubtext}>
              {searchTerm ? "Try adjusting your search filters" : "Start adding inventory items"}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

export default ViewEntries;



    

