import { useState } from "react";
import styles from "./css/EntryForm.module.css";
import API_BASE_URL from "./config/api";

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

  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setSuccess("");

    // Basic validation
    if (!formData.Item || !formData.SerialNo || !formData.InventoryItemNo) {
      setError("Please fill in all required fields (Item, Serial No., Inventory Item No.)");
      return;
    }

    try {
      const response = await fetch(`${API_BASE_URL}/submit.php`, {
        method: "POST",
        credentials: 'include',
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: new URLSearchParams(formData),
      });
      const result = await response.json();

      if (result.status === "success") {
        setSuccess("✓ Entry added successfully!");
        setSubmitted(true);
        // Reset form
        setFormData({
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
        if (onEntryAdded) onEntryAdded();
        setTimeout(() => setSuccess(""), 3000);
      } else {
        if (result.message.includes("Duplicate entry")) {
          setError("⚠ This Serial No or Inventory Item No already exists. Please enter unique values.");
        } else {
          setError("Error: " + result.message);
        }
      }
    } catch (err) {
      setError("Network error: " + err.message);
    }
  };

  return (
    <div className={styles.mainContainer}>
      <div className={styles.formWrapper}>
        <div className={styles.formHeader}>
          <h2>Add New Inventory Item</h2>
          <p>Complete all required fields to add a new item to inventory</p>
        </div>

        {error && <div className={styles.alertError}>{error}</div>}
        {success && <div className={styles.alertSuccess}>{success}</div>}

        <form onSubmit={handleSubmit} className={styles.form}>
          {/* Item Details Section */}
          <div className={styles.formSection}>
            <h3 className={styles.sectionTitle}>Item Details</h3>
            <div className={styles.formGrid}>
              <div className={styles.formGroup}>
                <label htmlFor="Item">Item Name *</label>
                <input
                  id="Item"
                  name="Item"
                  type="text"
                  placeholder="e.g., Office Chair"
                  value={formData.Item}
                  onChange={handleChange}
                  required
                />
              </div>
              <div className={styles.formGroup}>
                <label htmlFor="SerialNo">Serial Number *</label>
                <input
                  id="SerialNo"
                  name="SerialNo"
                  type="text"
                  placeholder="e.g., SN-2026-001"
                  value={formData.SerialNo}
                  onChange={handleChange}
                  required
                />
              </div>
              <div className={styles.formGroup}>
                <label htmlFor="InventoryItemNo">Inventory Item No. *</label>
                <input
                  id="InventoryItemNo"
                  name="InventoryItemNo"
                  type="text"
                  placeholder="e.g., INV-2026-001"
                  value={formData.InventoryItemNo}
                  onChange={handleChange}
                  required
                />
              </div>
              <div className={styles.formGroup}>
                <label htmlFor="Description">Description</label>
                <textarea
                  id="Description"
                  name="Description"
                  placeholder="Additional details about the item"
                  value={formData.Description}
                  onChange={handleChange}
                  rows="2"
                />
              </div>
            </div>
          </div>

          {/* Quantity & Unit Section */}
          <div className={styles.formSection}>
            <h3 className={styles.sectionTitle}>Quantity Information</h3>
            <div className={styles.formGrid}>
              <div className={styles.formGroup}>
                <label htmlFor="Quantity">Quantity</label>
                <input
                  id="Quantity"
                  name="Quantity"
                  type="number"
                  placeholder="0"
                  value={formData.Quantity}
                  onChange={handleChange}
                />
              </div>
              <div className={styles.formGroup}>
                <label htmlFor="Unit">Unit</label>
                <select
                  id="Unit"
                  name="Unit"
                  value={formData.Unit}
                  onChange={handleChange}
                >
                  <option value="">Select unit</option>
                  <option value="piece">Piece</option>
                  <option value="box">Box</option>
                  <option value="kg">Kilogram</option>
                  <option value="liter">Liter</option>
                  <option value="meter">Meter</option>
                  <option value="set">Set</option>
                </select>
              </div>
              <div className={styles.formGroup}>
                <label htmlFor="Amount">Amount</label>
                <input
                  id="Amount"
                  name="Amount"
                  type="number"
                  step="0.01"
                  placeholder="0.00"
                  value={formData.Amount}
                  onChange={handleChange}
                />
              </div>
            </div>
          </div>

          {/* Cost Section */}
          <div className={styles.formSection}>
            <h3 className={styles.sectionTitle}>Cost Information</h3>
            <div className={styles.formGrid}>
              <div className={styles.formGroup}>
                <label htmlFor="UnitCost">Unit Cost (₱)</label>
                <input
                  id="UnitCost"
                  name="UnitCost"
                  type="number"
                  step="0.01"
                  placeholder="0.00"
                  value={formData.UnitCost}
                  onChange={handleChange}
                />
              </div>
              <div className={styles.formGroup}>
                <label htmlFor="TotalCost">Total Cost (₱)</label>
                <input
                  id="TotalCost"
                  name="TotalCost"
                  type="number"
                  step="0.01"
                  placeholder="0.00"
                  value={formData.TotalCost}
                  onChange={handleChange}
                />
              </div>
            </div>
          </div>

          {/* Date & Location Section */}
          <div className={styles.formSection}>
            <h3 className={styles.sectionTitle}>Timeline & Location</h3>
            <div className={styles.formGrid}>
              <div className={styles.formGroup}>
                <label htmlFor="DateAcquired">Date Acquired</label>
                <input
                  id="DateAcquired"
                  name="DateAcquired"
                  type="date"
                  value={formData.DateAcquired}
                  onChange={handleChange}
                />
              </div>
              <div className={styles.formGroup}>
                <label htmlFor="Location">Location</label>
                <input
                  id="Location"
                  name="Location"
                  type="text"
                  placeholder="e.g., Office Building 2, Room 305"
                  value={formData.Location}
                  onChange={handleChange}
                />
              </div>
              <div className={styles.formGroup}>
                <label htmlFor="EstimatedUsefulLife">Estimated Useful Life (years)</label>
                <input
                  id="EstimatedUsefulLife"
                  name="EstimatedUsefulLife"
                  type="number"
                  placeholder="e.g., 5"
                  value={formData.EstimatedUsefulLife}
                  onChange={handleChange}
                />
              </div>
            </div>
          </div>

          {/* Action Buttons */}
          <div className={styles.formActions}>
            <button type="submit" className={styles.submitBtn}>
              ✓ Add to Inventory
            </button>
            <button
              type="reset"
              className={styles.resetBtn}
              onClick={() => {
                setFormData({
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
                setError("");
                setSuccess("");
              }}
            >
              ↻ Clear Form
            </button>
          </div>

          <p className={styles.requiredNote}>* = Required fields</p>
        </form>
      </div>
    </div>
  );
}

export default EntryForm;