import { useEffect, useState } from "react";

function ViewEntries() {
  const [entries, setEntries] = useState([]);

  const fetchEntries = () => {
    fetch("http://localhost:8080/get_entries.php")
      .then((res) => res.json())
      .then((data) => {
        console.log("Fetched entries:", data);
        setEntries(data);
      })
      .catch((err) => console.error("Error fetching entries:", err));
  };

  useEffect(() => {
    fetchEntries(); // initial load
    const interval = setInterval(fetchEntries, 5000); // auto-refresh every 5s
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="table-wrapper">
    <table className="entries-table">
        <thead>
        <tr>
            <th>ID</th>
            <th>Quantity</th>
            <th>Unit</th>
            <th>Amount</th>
            <th>Unit Cost</th>
            <th>Total Cost</th>
            <th>Description</th>
            <th>Item</th>
            <th>Serial No.</th>
            <th>Date Acquired</th>
            <th>Location</th>
            <th>Inventory Item No.</th>
            <th>Estimated Useful Life</th>
        </tr>
        </thead>
        <tbody>
        {entries.length > 0 ? (
            entries.map((entry) => (
            <tr key={entry.order_id}>
                <td>{entry.order_id}</td>
                <td>{entry.Quantity}</td>
                <td>{entry.Unit}</td>
                <td>{entry.Amount}</td>
                <td>{entry.UnitCost}</td>
                <td>{entry.TotalCost}</td>
                <td>{entry.Description}</td>
                <td>{entry.Item}</td>
                <td>{entry.SerialNo}</td>
                <td>{entry.DateAcquired}</td>
                <td>{entry.Location}</td>
                <td>{entry.InventoryItemNo}</td>
                <td>{entry.EstimatedUsefulLife}</td>
            </tr>
            ))
        ) : (
            <tr>
            <td colSpan="13">No entries found</td>
            </tr>
        )}
        </tbody>
    </table>
    </div>
  );
}

export default ViewEntries;