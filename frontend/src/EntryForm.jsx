import { useState } from "react";

function EntryForm({ onEntryAdded }) {

  const [formData, setFormData] = useState({
    Quantity: "",
    Unit: "",
    Amount: "",
    UnitCost: "",
    TotalCost: "",
    Description: "",
    Item: "",
    SerialNo: "",
    DateAcquired: "",
    Location: "",
    InventoryItemNo: "",
    EstimatedUsefulLife: ""
  });

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const response = await fetch("/api/submit.php", {


      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams(formData),
    });
    const result = await response.json();

    if (result.status === "success") {
      alert("Entry added successfully!");
      if (onEntryAdded) onEntryAdded();
    } else {
      if (result.message.includes("Duplicate entry")) {
        alert("This Serial No or Inventory Item No already exists. Please enter unique values.");
      } else {
        alert("Error: " + result.message);
      }
    }
  };

  return (
    <center>
      <form onSubmit={handleSubmit} className="entry-form">
        <input name="Quantity" type="number" placeholder="Quantity" value={formData.Quantity} onChange={handleChange} />
        <input name="Unit" placeholder="Unit" value={formData.Unit} onChange={handleChange} />
        <input name="Amount" type="number" step="0.01" placeholder="Amount" value={formData.Amount} onChange={handleChange} />
        <input name="UnitCost" type="number" step="0.01" placeholder="Unit Cost" value={formData.UnitCost} onChange={handleChange} />
        <input name="TotalCost" type="number" step="0.01" placeholder="Total Cost" value={formData.TotalCost} onChange={handleChange} />
        <input name="Description" placeholder="Description" value={formData.Description} onChange={handleChange} />
        <input name="Item" placeholder="Item" value={formData.Item} onChange={handleChange} />
        <input name="SerialNo" placeholder="Serial No." value={formData.SerialNo} onChange={handleChange} />
        <input name="DateAcquired" type="date" placeholder="Date Acquired" value={formData.DateAcquired} onChange={handleChange} />
        <input name="Location" placeholder="Location" value={formData.Location} onChange={handleChange} />
        <input name="InventoryItemNo" placeholder="Inventory Item No." value={formData.InventoryItemNo} onChange={handleChange} />
        <input name="EstimatedUsefulLife" placeholder="Estimated Useful Life" value={formData.EstimatedUsefulLife} onChange={handleChange} />
        <button type="submit" className="submit-btn">Submit</button>
      </form>
    </center>
    
  );
}

export default EntryForm;