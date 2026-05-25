import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import API_BASE_URL from './config/api';

// ─── Design tokens ────────────────────────────────────────────────────────────
const css = `
  @import url('https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;0,9..40,600&family=DM+Mono:wght@400;500&display=swap');

  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  :root {
    --navy:       #032063;
    --navy-deep:  #051b50;
    --navy-mid:   #0a2d7a;
    --navy-light: #e8edf8;
    --navy-pale:  #f2f5fb;
    --accent:     #051b50;
    --accent-lt:  #dbe6fb;
    --green:      #1a8c5b;
    --green-lt:   #e0f5ec;
    --red:        #c53030;
    --red-lt:     #fde8e8;
    --amber:      #b45309;
    --amber-lt:   #fef3c7;
    --border:     rgba(3,32,99,0.12);
    --border-md:  rgba(3,32,99,0.2);
    --text:       #0f172a;
    --text-2:     #475569;
    --text-3:     #94a3b8;
    --surface:    #ffffff;
    --surface-2:  #f8fafc;
    --surface-3:  #f1f5f9;
    --radius:     6px;
    --radius-lg:  10px;
    --shadow-sm:  0 1px 3px rgba(3,32,99,0.08), 0 1px 2px rgba(3,32,99,0.04);
    --shadow-md:  0 4px 16px rgba(3,32,99,0.10), 0 2px 4px rgba(3,32,99,0.06);
    --font:       'DM Sans', 'SF Pro Text', system-ui, sans-serif;
    --mono:       'DM Mono', 'SF Mono', monospace;
  }

  .pr-shell {
    font-family: var(--font);
    color: var(--text);
    background: var(--surface-3);
    min-height: 100vh;
    padding: 2rem 1rem;
  }
  .pr-card {
    max-width: 780px;
    margin: 0 auto;
    background: var(--surface);
    border: 0.5px solid var(--border);
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-md);
    overflow: hidden;
  }
  .pr-header {
    background: linear-gradient(135deg, var(--navy-deep) 0%, var(--navy-mid) 100%);
    padding: 1.5rem 2rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
  }
  .pr-header-title {
    font-size: 17px;
    font-weight: 600;
    color: #fff;
    letter-spacing: -0.01em;
  }
  .pr-header-sub {
    font-size: 12px;
    color: rgba(255,255,255,0.55);
    margin-top: 2px;
    font-family: var(--mono);
  }
  .pr-badges {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
    justify-content: flex-end;
  }
  .pr-badge {
    background: rgba(255,255,255,0.13);
    border: 0.5px solid rgba(255,255,255,0.2);
    color: rgba(255,255,255,0.9);
    font-size: 12px;
    font-weight: 500;
    padding: 4px 10px;
    border-radius: 20px;
    font-family: var(--mono);
  }
  .pr-badge.amount { background: rgba(26,82,212,0.35); }
  .pr-stepper {
    padding: 1.5rem 2rem 0;
  }
  .stepper-track {
    display: flex;
    align-items: center;
    gap: 0;
    position: relative;
  }
  .stepper-item {
    display: flex;
    align-items: center;
    flex: 1;
    position: relative;
  }
  .stepper-item:last-child { flex: 0; }
  .stepper-dot {
    width: 28px;
    height: 28px;
    border-radius: 50%;
    border: 2px solid var(--border-md);
    background: var(--surface);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 11px;
    font-weight: 600;
    color: var(--text-3);
    flex-shrink: 0;
    transition: all 0.25s ease;
    position: relative;
    z-index: 1;
  }
  .stepper-dot.done {
    background: var(--navy);
    border-color: var(--navy);
    color: #fff;
  }
  .stepper-dot.active {
    background: var(--accent);
    border-color: var(--accent);
    color: #fff;
    box-shadow: 0 0 0 3px var(--accent-lt);
  }
  .stepper-line {
    flex: 1;
    height: 1.5px;
    background: var(--border);
    transition: background 0.3s;
    margin: 0 2px;
  }
  .stepper-line.done { background: var(--navy); }
  .stepper-labels {
    display: flex;
    justify-content: space-between;
    margin-top: 6px;
    padding: 0 2px;
  }
  .stepper-label {
    font-size: 10px;
    color: var(--text-3);
    text-align: center;
    max-width: 80px;
    line-height: 1.3;
    font-weight: 500;
  }
  .stepper-label.active { color: var(--accent); font-weight: 600; }
  .stepper-label.done { color: var(--navy); }
  .pr-body {
    padding: 1.75rem 2rem 2rem;
  }
  .section-head {
    font-size: 13px;
    font-weight: 600;
    color: var(--navy);
    text-transform: uppercase;
    letter-spacing: 0.07em;
    margin-bottom: 1rem;
    padding-bottom: 0.5rem;
    border-bottom: 0.5px solid var(--border);
  }
  .field-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px 20px;
  }
  .field-grid.three { grid-template-columns: 1fr 1fr 1fr; }
  .field-grid.full  { grid-template-columns: 1fr; }
  .field {
    display: flex;
    flex-direction: column;
    gap: 5px;
  }
  .field.span2 { grid-column: span 2; }
  .field label {
    font-size: 12px;
    font-weight: 500;
    color: var(--text-2);
    letter-spacing: 0.01em;
  }
  .field label .req { color: var(--red); margin-left: 2px; }
  .field-error {
    font-size: 11px;
    color: var(--red);
    margin-top: 2px;
    display: flex;
    align-items: center;
    gap: 3px;
  }
  input[type=text], input[type=number], input[type=date], select, textarea {
    font-family: var(--font);
    font-size: 13.5px;
    color: var(--text);
    background: var(--surface);
    border: 0.75px solid var(--border-md);
    border-radius: var(--radius);
    padding: 8px 10px;
    width: 100%;
    transition: border-color 0.15s, box-shadow 0.15s;
    outline: none;
    -webkit-appearance: none;
  }
  input:focus, select:focus, textarea:focus {
    border-color: var(--accent);
    box-shadow: 0 0 0 3px var(--accent-lt);
  }
  input.has-error, select.has-error, textarea.has-error {
    border-color: var(--red);
    box-shadow: 0 0 0 3px var(--red-lt);
  }
  input:disabled, input[disabled] {
    background: var(--surface-2);
    color: var(--text-3);
    border-color: var(--border);
    cursor: not-allowed;
  }
  select { cursor: pointer; }
  textarea { resize: vertical; min-height: 90px; line-height: 1.5; }
  .add-row {
    display: flex;
    gap: 8px;
    align-items: center;
    width: 100%;
  }
  .add-row input {
    flex: 1 1 0%;
    min-width: 0;
    width: 0;
  }
  .btn-add {
    background: var(--navy);
    color: #fff;
    border: none;
    border-radius: var(--radius);
    padding: 0;
    font-size: 20px;
    font-weight: 300;
    cursor: pointer;
    line-height: 1;
    transition: background 0.15s, transform 0.1s;
    flex-shrink: 0;
    flex-grow: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 38px;
    height: 38px;
  }
  .btn-add:hover { background: var(--navy-mid); }
  .btn-add:active { transform: scale(0.96); }
  .items-box {
    margin-top: 14px;
    border: 0.75px solid var(--border-md);
    border-radius: var(--radius-lg);
    overflow: hidden;
    background: var(--surface);
  }
  .items-box-head {
    background: var(--navy-pale);
    padding: 8px 14px;
    font-size: 11.5px;
    font-weight: 600;
    color: var(--navy);
    letter-spacing: 0.03em;
  }
  .items-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 13px;
  }
  .items-table th {
    font-size: 11px;
    font-weight: 600;
    color: var(--text-2);
    text-align: center;
    padding: 8px 10px;
    border-bottom: 0.5px solid var(--border);
    background: var(--surface-2);
    letter-spacing: 0.04em;
    text-transform: uppercase;
  }
  .items-table th:first-child { text-align: left; }
  .items-table td {
    padding: 9px 10px;
    border-bottom: 0.5px solid var(--border);
    text-align: center;
    color: var(--text);
    vertical-align: middle;
  }
  .items-table td:first-child { text-align: left; font-weight: 500; }
  .items-table tr:last-child td { border-bottom: none; }
  .items-table .amount-cell { color: var(--green); font-weight: 600; font-family: var(--mono); }
  .items-table .mono { font-family: var(--mono); }
  .btn-remove {
    background: none;
    border: none;
    color: var(--text-3);
    cursor: pointer;
    font-size: 15px;
    padding: 2px 6px;
    border-radius: 4px;
    transition: color 0.15s, background 0.15s;
    line-height: 1;
  }
  .btn-remove:hover { color: var(--red); background: var(--red-lt); }
  .items-footer {
    display: flex;
    justify-content: flex-end;
    align-items: center;
    gap: 8px;
    padding: 10px 14px;
    background: var(--surface-2);
    border-top: 0.5px solid var(--border);
    font-size: 13px;
    font-weight: 600;
    color: var(--navy);
  }
  .items-footer .total-val {
    font-family: var(--mono);
    font-size: 15px;
    color: var(--green);
  }
  .info-card {
    background: var(--surface-2);
    border: 0.5px solid var(--border);
    border-radius: var(--radius-lg);
    padding: 14px 18px;
    margin-bottom: 16px;
  }
  .info-card.blue {
    background: var(--accent-lt);
    border-color: rgba(26,82,212,0.2);
  }
  .info-card p {
    font-size: 13px;
    color: var(--text-2);
    margin-bottom: 6px;
    display: flex;
    gap: 6px;
  }
  .info-card p:last-child { margin-bottom: 0; }
  .info-card p strong {
    color: var(--text);
    font-weight: 600;
    min-width: 120px;
    flex-shrink: 0;
  }
  .info-card h4 {
    font-size: 12px;
    font-weight: 700;
    color: var(--navy);
    text-transform: uppercase;
    letter-spacing: 0.06em;
    margin-bottom: 10px;
  }
  .gap    { margin-bottom: 16px; }
  .gap-sm { margin-bottom: 10px; }
  .gap-lg { margin-bottom: 24px; }
  .btn {
    font-family: var(--font);
    font-size: 13.5px;
    font-weight: 600;
    border-radius: var(--radius);
    padding: 9px 20px;
    cursor: pointer;
    transition: all 0.15s;
    border: none;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    position: relative;
  }
  .btn:disabled { opacity: 0.55; cursor: not-allowed; }
  .btn-primary { background: var(--navy); color: #fff; }
  .btn-primary:hover:not(:disabled) { background: var(--navy-mid); }
  .btn-primary:active:not(:disabled) { transform: scale(0.98); }
  .btn-success { background: var(--green); color: #fff; }
  .btn-success:hover:not(:disabled) { background: #156e49; }
  .btn-danger { background: var(--red); color: #fff; }
  .btn-danger:hover:not(:disabled) { background: #9b2020; }
  .btn-ghost {
    background: transparent;
    color: var(--text-2);
    border: 0.75px solid var(--border-md);
  }
  .btn-ghost:hover:not(:disabled) { background: var(--surface-2); color: var(--text); }
  .btn-spinner {
    width: 14px;
    height: 14px;
    border: 2px solid rgba(255,255,255,0.35);
    border-top-color: #fff;
    border-radius: 50%;
    animation: spin 0.65s linear infinite;
    flex-shrink: 0;
  }
  @keyframes spin { to { transform: rotate(360deg); } }
  .cert-group {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
  }
  .cert-btn {
    font-family: var(--font);
    font-size: 12.5px;
    font-weight: 500;
    padding: 7px 14px;
    border-radius: 20px;
    cursor: pointer;
    border: 0.75px solid var(--border-md);
    background: var(--surface);
    color: var(--text-2);
    transition: all 0.15s;
  }
  .cert-btn:hover { border-color: var(--navy); color: var(--navy); }
  .cert-btn.active {
    background: var(--navy);
    color: #fff;
    border-color: var(--navy);
  }
  .decision-area {
    text-align: center;
    padding: 2rem 0 1rem;
  }
  .decision-btns {
    display: flex;
    gap: 16px;
    justify-content: center;
    margin-top: 1.5rem;
  }
  .decision-btns .btn { min-width: 140px; font-size: 14px; padding: 11px 24px; }
  .form-select-options {
    display: flex;
    gap: 16px;
    justify-content: center;
    margin: 1.5rem 0;
    flex-wrap: wrap;
  }
  .form-opt {
    border: 1.5px solid var(--border-md);
    border-radius: var(--radius-lg);
    padding: 20px 28px;
    min-width: 220px;
    text-align: center;
    background: var(--surface);
  }
  .form-opt.active-ics { border-color: var(--accent); background: var(--accent-lt); }
  .form-opt.active-ppe { border-color: var(--amber);  background: var(--amber-lt); }
  .form-opt h4 { font-size: 14px; font-weight: 700; margin-bottom: 4px; }
  .form-opt p  { font-size: 12px; color: var(--text-2); }
  .toast {
    margin: 14px 2rem 0;
    padding: 10px 16px;
    border-radius: var(--radius);
    font-size: 13px;
    font-weight: 500;
    display: flex;
    align-items: flex-start;
    gap: 8px;
    line-height: 1.45;
  }
  .toast.success { background: var(--green-lt); color: var(--green); border: 0.5px solid rgba(26,140,91,0.3); }
  .toast.error   { background: var(--red-lt);   color: var(--red);   border: 0.5px solid rgba(197,48,48,0.3); }
  .pr-footer {
    padding: 1rem 2rem 1.5rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-top: 0.5px solid var(--border);
    margin-top: 1.5rem;
  }
  .remarks-input {
    font-size: 12px;
    padding: 5px 8px;
    border: 0.5px solid var(--border-md);
    border-radius: 4px;
    width: 100%;
  }
  .divider {
    border: none;
    border-top: 0.5px solid var(--border);
    margin: 20px 0;
  }
  @media (max-width: 600px) {
    .pr-shell { padding: 0.75rem 0.5rem; }
    .pr-header, .pr-body, .pr-footer { padding-left: 1rem; padding-right: 1rem; }
    .field-grid, .field-grid.three { grid-template-columns: 1fr; }
    .field.span2 { grid-column: span 1; }
    .decision-btns { flex-direction: column; align-items: stretch; }
    .form-select-options { flex-direction: column; align-items: center; }
  }
`;

// ─── Constants ────────────────────────────────────────────────────────────────
const UNIT_OPTIONS = ['pc','pcs','set','unit','bottle','box','carton','kg','liter','meter','tube'];

const DIVISION_OPTIONS = [
  ['General Supply Division','General Supply Division (GSD)'],
  ['Management, Financial and Administrative Service','Management, Financial and Administrative Service (MFAS)'],
  ['Director Management, Financial and Administrative Service','Director Management, Financial and Administrative Service (MFAS)'],
  ['Office of the Deputy Administrator for Operations','Office of the Deputy Administrator for Operations (ODAO)'],
  ['Office of the Administrator','Office of the Administrator (OADM)'],
  ['Office of the Deputy Administrator for Planning','Office of the Deputy Administrator for Planning (ODAP)'],
  ['Human Resource Management and Development Division (HRMDD)','Human Resource Management and Development Division (HRMDD)'],
  ['Budget Division (BD)','Budget Division (BD)'],
  ['Maritime Technical Division - Safety Management Section','Maritime Technical Division - Safety Management Section'],
  ['Maritime Transport Environment & Energy Development Division','Maritime Transport Environment & Energy Development Division'],
  ['Administrative and Finance Division - Administrative Management Section','Administrative and Finance Division - Administrative Management Section'],
  ['Maritime Technical Division - Shipyard Regulation Section','Maritime Technical Division - Shipyard Regulation Section'],
  ['Shipping and Franchising Division','Shipping and Franchising Division'],
  ["Seafarers' Documentation Division","Seafarers' Documentation Division"],
  ['Enforcement Service','Enforcement Service (ES)'],
  ['Shipyards Regulation Service','Shipyards Regulation Service (SRS)'],
  ['Domestic Shipping Service','Domestic Shipping Service (DSS)'],
  ['Overseas Shipping Service','Overseas Shipping Service (OSS)'],
  ['Maritime Safety Service','Maritime Safety Service (MSS)'],
  ['Manpower Development Service','Manpower Development Service (MDS)'],
  ['Planning and Policy Service','Planning and Policy Service (PPS)'],
  ['Legal Service','Legal Service (LS)'],
];

const OFFICE_OPTIONS = [
  ['MARINA','MARINA'],
  // ['MDS / POEA Satellite Office','MDS / POEA Satellite Office'],
  // ['Budget Division','Budget Division (BD)'],
  // ['Enforcement Service','Enforcement Service (ES)'],
  // ['Shipyards Regulation Service','Shipyards Regulation Service (SRS)'],
  // ['Domestic Shipping Service','Domestic Shipping Service (DSS)'],
  // ['Overseas Shipping Service','Overseas Shipping Service (OSS)'],
  // ['Franchising Service','Franchising Service (FS)'],
  // ['Maritime Safety Service','Maritime Safety Service (MSS)'],
];

const DESIGNATION_OPTIONS = [
  'Administrator',
  'Administrative Aide lV',
  'Administrative Aide Vl',
  'Administrative Assistant l',
  'Administrative Assistant ll',
  'Administrative Assistant lll',
  'Administrative Assistant V',
  'Administrative Officer l',
];

const IAC_OFFICES = [
  'MDS / POEA Satellite Office','Budget Division (BD)','Enforcement Service (ES)',
  'Shipyards Regulation Service (SRS)','Domestic Shipping Service (DSS)',
  'Overseas Shipping Service (OSS)','Franchising Service (FS)','Maritime Safety Service (MSS)',
];

const AMOUNT_THRESHOLD = 50000;
const fmt = (n) => `₱${parseFloat(n || 0).toFixed(2)}`;

// ─── Reusable Field ───────────────────────────────────────────────────────────
function Field({ label, req, span2, error, children }) {
  return (
    <div className={`field${span2 ? ' span2' : ''}`}>
      <label>{label}{req && <span className="req">*</span>}</label>
      {children}
      {error && <span className="field-error">⚠ {error}</span>}
    </div>
  );
}

// ─── Spinner ─────────────────────────────────────────────────────────────────
function Spinner() {
  return <span className="btn-spinner" aria-hidden="true" />;
}

// ─── Items Table ──────────────────────────────────────────────────────────────
function ItemsTable({ items, grandTotal, onRemove, showRemarks, onRemarkChange }) {
  if (!items.length) return null;
  return (
    <div className="items-box">
      <div className="items-box-head">✓ Added items ({items.length})</div>
      <table className="items-table">
        <thead>
          <tr>
            <th style={{width:'40%'}}>Description</th>
            <th>Qty / Unit</th>
            <th>Unit cost</th>
            <th>Amount</th>
            {showRemarks && <th>Remarks</th>}
            {!showRemarks && onRemove && <th></th>}
          </tr>
        </thead>
        <tbody>
          {items.map((item, idx) => (
            <tr key={item.id}>
              <td>{item.particular}</td>
              <td className="mono">{item.quantity} {item.unit}</td>
              <td className="mono">{fmt(item.unitCost)}</td>
              <td className="amount-cell">{fmt(item.quantity * item.unitCost)}</td>
              {showRemarks && (
                <td>
                  <input
                    type="text"
                    className="remarks-input"
                    placeholder="Remarks..."
                    onChange={(e) => {
                      const updated = [...items];
                      updated[idx].inspectionRemarks = e.target.value;
                      onRemarkChange(updated);
                    }}
                  />
                </td>
              )}
              {!showRemarks && onRemove && (
                <td>
                  <button
                    className="btn-remove"
                    type="button"
                    onClick={() => onRemove(item.id)}
                    title="Remove"
                  >✕</button>
                </td>
              )}
            </tr>
          ))}
        </tbody>
      </table>
      <div className="items-footer">
        <span style={{color:'var(--text-2)', fontSize:12}}>Grand total</span>
        <span className="total-val">{fmt(grandTotal)}</span>
      </div>
    </div>
  );
}

// ─── Step indicator ───────────────────────────────────────────────────────────
const STEPS = [
  { key:'create',        label:'Create PR'  },
  { key:'approval',      label:'Approval'   },
  { key:'delivery_note', label:'Delivery'   },
  { key:'inspection',    label:'Inspection' },
  { key:'form_selection',label:'Form'       },
];

function Stepper({ currentStep }) {
  const currentIdx = STEPS.findIndex(s => s.key === currentStep);
  return (
    <div className="pr-stepper">
      <div className="stepper-track">
        {STEPS.map((s, idx) => {
          const done   = idx < currentIdx;
          const active = idx === currentIdx;
          return (
            <div key={s.key} className="stepper-item">
              <div className={`stepper-dot${done ? ' done' : active ? ' active' : ''}`}>
                {done ? '✓' : idx + 1}
              </div>
              {idx < STEPS.length - 1 && (
                <div className={`stepper-line${done ? ' done' : ''}`} />
              )}
            </div>
          );
        })}
      </div>
      <div className="stepper-labels">
        {STEPS.map((s, idx) => {
          const done   = idx < currentIdx;
          const active = idx === currentIdx;
          return (
            <span
              key={s.key}
              className={`stepper-label${done ? ' done' : active ? ' active' : ''}`}
            >{s.label}</span>
          );
        })}
      </div>
      <div style={{height:20}} />
    </div>
  );
}

// ─── Main component ───────────────────────────────────────────────────────────
function NewEntryPR() {
  const navigate = useNavigate();

  // safePost utility (unchanged)
  const safePost = async (endpoint, payload, attempt = 1) => {
    const url = `${API_BASE_URL.replace(/\/$/, '')}/${endpoint.replace(/^\//, '')}`;
    let response;
    try {
      response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': sessionStorage.getItem('user_id') || '',
        },
        credentials: 'include',
        body: JSON.stringify(payload),
      });
    } catch (networkErr) {
      if (attempt === 1) {
        console.warn(`[safePost] network error on ${url}, retrying once…`, networkErr);
        return safePost(endpoint, payload, 2);
      }
      throw new Error(`Network error – could not reach ${endpoint}. (${networkErr.message})`);
    }
    const rawText = await response.text();
    if (response.status === 404) {
      throw new Error(`Endpoint not found (404): ${endpoint}. Ensure the PHP file exists.`);
    }
    if (!response.ok) {
      throw new Error(`Server error (HTTP ${response.status}). Please try again.`);
    }
    if (!rawText.trim()) {
      throw new Error(`The server returned an empty response. Check PHP error logs.`);
    }
    let result;
    try {
      result = JSON.parse(rawText);
    } catch (parseErr) {
      throw new Error(`Invalid response from the server. Preview: ${rawText.slice(0, 100)}`);
    }
    return result;
  };

  // ─── State (unchanged) ─────────────────────────────────────────────────────
  const [currentStep, setCurrentStep] = useState('create');

  const [prNo, setPrNo] = useState('');
  const [office, setOffice] = useState('');
  const [divisionSection, setDivisionSection] = useState('');
  const [dateRequested, setDateRequested] = useState('');
  const [certification, setCertification] = useState('');
  const [itemDescription, setItemDescription] = useState('');
  const [itemNo, setItemNo] = useState('');
  const [name, setName] = useState('');
  const [designation, setDesignation] = useState('');
  const [purpose, setPurpose] = useState('');
  const [quantity, setQuantity] = useState('');
  const [unit, setUnit] = useState('');
  const [unitCost, setUnitCost] = useState('');
  const [inputParticular, setInputParticular] = useState('');
  const [inputUnit, setInputUnit] = useState('');
  const [inputQuantity, setInputQuantity] = useState(0);
  const [inputUnitCost, setInputUnitCost] = useState(0);
  const [particularItems, setParticularItems] = useState([]);
  const [rowErrors, setRowErrors] = useState({});
  const [supplier, setSupplier] = useState('');
  const [siNo, setSiNo] = useState('');
  const [poDate, setPoDate] = useState('');
  const [drNo, setDrNo] = useState('');
  const [amount, setAmount] = useState('');
  const [preparedBy, setPreparedBy] = useState('');
  const [notedBy, setNotedBy] = useState('');
  const [deliveryNotes, setDeliveryNotes] = useState('');
  const [inspectionNotes, setInspectionNotes] = useState('');
  const [iacSupplier, setIacSupplier] = useState('');
  const [iacPoNo, setIacPoNo] = useState('');
  const [iacPoDate, setIacPoDate] = useState('');
  const [iacRequisitioningOffice, setIacRequisitioningOffice] = useState('');
  const [iacRequisitioningCode, setIacRequisitioningCode] = useState('');
  const [iacIarNo, setIacIarNo] = useState('');
  const [iacDate, setIacDate] = useState('');
  const [iacInvoiceNo, setIacInvoiceNo] = useState('');
  const [iacInvoiceDate, setIacInvoiceDate] = useState('');
  const [approvalDecision, setApprovalDecision] = useState(null);
  const [prId, setPrId] = useState(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitMessage, setSubmitMessage] = useState('');
  const [messageType, setMessageType] = useState('');
  
  // ─── NEW: Approver information ─────────────────────────────────────────────
  const [approverName, setApproverName] = useState('');
  const [approverPosition, setApproverPosition] = useState('');
  const [approverOffice, setApproverOffice] = useState('');

  // Derived values
  const grandTotal  = particularItems.reduce((t, i) => t + i.quantity * i.unitCost, 0);
  const totalAmount = grandTotal;
  const isICS       = totalAmount < AMOUNT_THRESHOLD;

  // ─── NEW: state for download button validation ─────────────────────────────
  const [isFormComplete, setIsFormComplete] = useState(false);

  // Restore PR No. from session
  useEffect(() => {
    const saved = sessionStorage.getItem('new_pr_name');
    if (saved) { setPrNo(saved); sessionStorage.removeItem('new_pr_name'); }
  }, []);

  // Pre-fill IAC fields from delivery data
  useEffect(() => {
    if (currentStep === 'inspection') {
      if (office && !iacRequisitioningOffice) setIacRequisitioningOffice(office);
      if (supplier && !iacSupplier) setIacSupplier(supplier);
      if (poDate && !iacPoDate) setIacPoDate(poDate);
    }
  }, [currentStep]);

  // ─── NEW: Pre-fill approver information from session ────────────────────────
  useEffect(() => {
    if (currentStep === 'approval' && !approverName) {
      const userName = sessionStorage.getItem('username') || '';
      const roleName = sessionStorage.getItem('role_name') || '';
      const userOffice = sessionStorage.getItem('user_office') || office || 'MARINA';
      
      setApproverName(userName);
      setApproverPosition(roleName);
      setApproverOffice(userOffice);
    }
  }, [currentStep]);

  // ─── NEW: validate required fields for download button ─────────────────────
  useEffect(() => {
    const required = [
      prNo.trim() !== '',
      office.trim() !== '',
      divisionSection.trim() !== '',
      dateRequested.trim() !== '',
      name.trim() !== '',
      designation.trim() !== '',
      purpose.trim() !== '',
      particularItems.length > 0
    ];
    setIsFormComplete(required.every(Boolean));
  }, [prNo, office, divisionSection, dateRequested, name, designation, purpose, particularItems]);

  // ─── Add-item handler (unchanged) ─────────────────────────────────────────
  const addItemHandler = () => {
    const errs = {};
    if (!inputParticular.trim()) errs.particular = 'Please enter item particulars.';
    if (!inputUnit) errs.unit = 'Please select a unit.';
    if (inputQuantity <= 0) errs.quantity = 'Quantity must be greater than 0.';
    if (inputUnitCost <= 0) errs.unitCost = 'Unit cost must be greater than 0.';
    const isDuplicate = particularItems.some(
      (i) => i.particular.toLowerCase() === inputParticular.trim().toLowerCase()
    );
    if (isDuplicate && !errs.particular) errs.particular = 'This item description already exists.';
    setRowErrors(errs);
    if (Object.keys(errs).length > 0) return;
    const newItem = {
      id: Date.now(),
      particular: inputParticular.trim(),
      unit: inputUnit,
      quantity: inputQuantity,
      unitCost: inputUnitCost,
      amount: inputQuantity * inputUnitCost,
    };
    setParticularItems([...particularItems, newItem]);
    setInputParticular('');
    setInputUnit('');
    setInputQuantity(0);
    setInputUnitCost(0);
    setRowErrors({});
  };

  const removeItemHandler = (item_id) => {
    setParticularItems(particularItems.filter(i => i.id !== item_id));
  };

  // ─── Cancel handler ───────────────────────────────────────────────────────
  const handleCancelCreate = () => {
    if (!window.confirm('Clear all fields and cancel? This cannot be undone.')) return;
    setPrNo('');
    setOffice('');
    setDivisionSection('');
    setDateRequested('');
    setCertification('');
    setItemDescription('');
    setItemNo('');
    setName('');
    setDesignation('');
    setPurpose('');
    setParticularItems([]);
    setInputParticular('');
    setInputUnit('');
    setInputQuantity(0);
    setInputUnitCost(0);
    setRowErrors({});
    sessionStorage.removeItem('new_pr_name');
    setSubmitMessage('');
    setMessageType('');
    navigate('/dashboard');
  };

  // ─── NEW: CSV download handler (frontend only) ────────────────────────────
  const handleDownloadCSV = () => {
    const columns = [
      'PR No.', 'Office', 'Division/Section', 'Date Requested',
      'Name', 'Designation', 'Purpose', 'Total Amount (₱)',
      'Item Description', 'Quantity', 'Unit', 'Unit Cost (₱)', 'Amount (₱)'
    ];

    const csvRows = [];
    csvRows.push(columns.join(','));

    particularItems.forEach(item => {
      const row = [
        `"${prNo}"`,
        `"${office}"`,
        `"${divisionSection}"`,
        `"${dateRequested}"`,
        `"${name}"`,
        `"${designation}"`,
        `"${purpose}"`,
        totalAmount.toFixed(2),
        `"${item.particular}"`,
        item.quantity,
        `"${item.unit}"`,
        item.unitCost.toFixed(2),
        (item.quantity * item.unitCost).toFixed(2)
      ];
      csvRows.push(row.join(','));
    });

    const blob = new Blob(['\uFEFF' + csvRows.join('\n')], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `PR_Form_${prNo}.csv`;
    link.click();
    URL.revokeObjectURL(link.href);
  };

  // ─── Step 1: Create PR (removed nested download handler) ──────────────────
  const handleCreatePR = async (e) => {
    e.preventDefault();
    setSubmitMessage('');
    if (particularItems.length === 0) {
      setSubmitMessage('Please add at least one item before submitting.');
      setMessageType('error');
      return;
    }
    setIsSubmitting(true);
    try {
      const totalQty = particularItems.reduce((s, i) => s + i.quantity, 0);
      const payload = {
        pr_no: prNo,
        item_name: particularItems,
        description: particularItems.map(i => i.particular).join(', '),
        quantity: totalQty,
        unit: 'items',
        unit_cost: totalAmount / Math.max(totalQty, 1),
        total_amount: totalAmount,
        office,
        division_section: divisionSection,
        date_requested: dateRequested,
        name,
        designation,
        purpose,
        certification,
        items: particularItems,
        user_id: sessionStorage.getItem('user_id'),
      };
      const result = await safePost('/submit_purchase_request.php', payload);
      if (result.success) {
        setPrId(result.pr_id);
        setPrNo(result.pr_no);
        const finalPrNo = result.pr_no !== prNo ? `${prNo} → ${result.pr_no}` : result.pr_no;
        setSubmitMessage(`✓ PR ${finalPrNo} created successfully! Proceeding to approval…`);
        setMessageType('success');
        setTimeout(() => { setSubmitMessage(''); setCurrentStep('approval'); }, 1500);
      } else {
        setSubmitMessage('Error: ' + (result.error || 'Failed to create PR'));
        setMessageType('error');
      }
    } catch (error) {
      setSubmitMessage(error.message);
      setMessageType('error');
    }
    setIsSubmitting(false);
  };

  // ─── Step 2: Approval (unchanged) ────────────────────────────────────────
  const handleApprovalDecision = async (decision) => {
    setIsSubmitting(true);
    setSubmitMessage('');
    try {
      const payload = {
        pr_id: prId,
        action: decision === 'approved' ? 'approve' : 'reject',
        notes: decision === 'approved' ? 'Approved' : 'Request disapproved',
        user_id: sessionStorage.getItem('user_id'),
        approver_name: approverName,
        approver_position: approverPosition,
        approver_office: approverOffice,
      };
      const result = await safePost('/approve_purchase_request.php', payload);
      if (decision === 'disapproved') {
        if (result.success) {
          setSubmitMessage('✗ Purchase Request disapproved. Process ended.');
          setMessageType('error');
          setTimeout(() => {
            setPrId(null); setPrNo(''); setOffice(''); setDivisionSection('');
            setDateRequested(''); setItemNo(''); setUnit(''); setItemDescription('');
            setQuantity(0); setUnitCost(0); setParticularItems([]);
            setCurrentStep('create'); setApprovalDecision(null); setSubmitMessage('');
          }, 2000);
        } else {
          setSubmitMessage('Error updating status: ' + (result.error || 'Unknown error'));
          setMessageType('error');
        }
      } else {
        if (result.success) {
          setApprovalDecision('approved');
          setSubmitMessage('✓ Purchase Request approved! Proceeding to delivery…');
          setMessageType('success');
          setTimeout(() => { setSubmitMessage(''); setCurrentStep('delivery_note'); }, 1500);
        } else {
          setSubmitMessage('Error approving PR: ' + (result.error || 'Unknown error'));
          setMessageType('error');
        }
      }
    } catch (error) {
      setSubmitMessage(error.message);
      setMessageType('error');
    }
    setIsSubmitting(false);
  };

  // ─── Step 3: Delivery Note (unchanged) ───────────────────────────────────
  const handleDeliveryNote = async (e) => {
    e.preventDefault();
    setSubmitMessage('');
    setIsSubmitting(true);
    try {
      const payload = {
        pr_id: prId,
        delivery_notes: deliveryNotes || 'No delivery notes provided',
        actual_delivery_date: poDate || null,
        supplier,
        si_no: siNo,
        dr_no: drNo,
        prepared_by: preparedBy,
        noted_by: notedBy,
        user_id: sessionStorage.getItem('user_id'),
      };
      const result = await safePost('/submit_delivery_notes.php', payload);
      if (result.success) {
        setSubmitMessage('✓ Delivery note recorded. Proceeding to inspection…');
        setMessageType('success');
        setTimeout(() => { setSubmitMessage(''); setCurrentStep('inspection'); }, 1500);
      } else {
        setSubmitMessage('Error: ' + (result.error || 'Failed to save delivery notes'));
        setMessageType('error');
      }
    } catch (error) {
      setSubmitMessage(error.message);
      setMessageType('error');
    }
    setIsSubmitting(false);
  };

  // ─── Step 4: Inspection (unchanged) ──────────────────────────────────────
  const handleInspection = async (e) => {
    e.preventDefault();
    setSubmitMessage('');
    if (!inspectionNotes.trim()) {
      setSubmitMessage('Please add inspection notes before continuing.');
      setMessageType('error');
      return;
    }
    if (particularItems.length === 0) {
      setSubmitMessage('No items found. Please go back to Step 1 to add items.');
      setMessageType('error');
      return;
    }
    setIsSubmitting(true);
    try {
      const payload = {
        pr_id: prId,
        assignment_id: prId,
        inspection_notes: inspectionNotes,
        condition_report: inspectionNotes,
        items: particularItems,
        total_amount: totalAmount,
        pr_no: prNo,
        office,
        division_section: divisionSection,
        user_id: sessionStorage.getItem('user_id'),
        iac_supplier: iacSupplier,
        iac_po_date: iacPoDate,
        iac_requisitioning_office: iacRequisitioningOffice,
        iac_iar_no: iacIarNo,
        iac_date: iacDate,
        iac_invoice_no: iacInvoiceNo,
        iac_invoice_date: iacInvoiceDate,
      };
      const result = await safePost('/submit_inspection.php', payload);
      if (result.success) {
        setSubmitMessage('✓ Inspection completed. Determining form type…');
        setMessageType('success');
        setTimeout(() => { setSubmitMessage(''); setCurrentStep('form_selection'); }, 1500);
      } else {
        setSubmitMessage('Error: ' + (result.error || 'Failed to save inspection'));
        setMessageType('error');
      }
    } catch (error) {
      setSubmitMessage(error.message);
      setMessageType('error');
    }
    setIsSubmitting(false);
  };

  // ─── Step 5: Form Selection (unchanged) ──────────────────────────────────
  const handleFormSelection = () => {
    const formType = totalAmount >= AMOUNT_THRESHOLD ? 'ppe' : 'ics';
    const prData = {
      pr_id: prId, pr_no: prNo, item_no: itemNo, item_description: itemDescription,
      total_amount: totalAmount, grand_total: totalAmount,
      office, division_section: divisionSection, date_requested: dateRequested,
      name, designation, purpose, certification, items: particularItems,
      supplier, si_no: siNo, po_date: poDate, dr_no: drNo,
      prepared_by: preparedBy, noted_by: notedBy,
      iac_supplier: iacSupplier || supplier,
      iac_po_date: iacPoDate || poDate,
      iac_requisitioning_office: iacRequisitioningOffice || office,
      iac_requisitioning_code: iacRequisitioningCode,
      iac_iar_no: iacIarNo,
      iac_date: iacDate,
      iac_invoice_no: iacInvoiceNo,
      iac_invoice_date: iacInvoiceDate,
      inspection_notes: inspectionNotes,
    };
    sessionStorage.setItem('current_pr_id', prId);
    sessionStorage.setItem('current_pr_no', prNo);
    sessionStorage.setItem('current_pr_amount', totalAmount);
    sessionStorage.setItem('form_type', formType);
    sessionStorage.setItem('pr_complete_data', JSON.stringify(prData));
    try {
      if (formType === 'ics') navigate('/inventory-form-ics');
      else navigate('/inventory-form-ppe');
    } catch (err) {
      console.error('Navigation error:', err);
      setSubmitMessage('Failed to open form. Please try again.');
      setMessageType('error');
    }
  };

  // ─── Navigation back ──────────────────────────────────────────────────────
  const goBack = () => {
    const steps = ['create','approval','delivery_note','inspection','form_selection'];
    const idx = steps.indexOf(currentStep);
    if (idx > 0) { setCurrentStep(steps[idx - 1]); setSubmitMessage(''); }
  };

  // ─── Render ───────────────────────────────────────────────────────────────
  return (
    <>
      <style>{css}</style>
      <div className="pr-shell">
        <div className="pr-card">
          <div className="pr-header">
            <div>
              <div className="pr-header-title">Purchase Request Workflow</div>
              <div className="pr-header-sub">MARINA · Procurement System</div>
            </div>
            <div className="pr-badges">
              {prNo ? <span className="pr-badge">PR #{prNo}</span> : null}
              {totalAmount > 0 ? <span className="pr-badge amount">{fmt(totalAmount)}</span> : null}
            </div>
          </div>
          <Stepper currentStep={currentStep} />
          {submitMessage && (
            <div className={`toast ${messageType}`} role="alert">
              {submitMessage}
            </div>
          )}
          <div className="pr-body">

            {/* STEP 1 – Create PR */}
            {currentStep === 'create' && (
              <form onSubmit={handleCreatePR}>
                <div className="section-head">Request information</div>
                <div className="field-grid gap">
                  <Field label="PR No." req>
                    <input type="text" placeholder="e.g. 2024-001" value={prNo} onChange={(e) => setPrNo(e.target.value)} />
                  </Field>
                  <Field label="Date requested" req>
                    <input type="date" value={dateRequested} onChange={(e) => setDateRequested(e.target.value)} />
                  </Field>
                  <Field label="Division / Section" req span2>
                    <select value={divisionSection} onChange={(e) => setDivisionSection(e.target.value)}>
                      <option value="">Select division</option>
                      {DIVISION_OPTIONS.map(([val, label]) => (
                        <option key={val} value={val}>{label}</option>
                      ))}
                    </select>
                  </Field>
                  <Field label="Office" req span2>
                    <select value={office} onChange={(e) => setOffice(e.target.value)}>
                      <option value="">Select office</option>
                      {OFFICE_OPTIONS.map(([val, label]) => (
                        <option key={val} value={val}>{label}</option>
                      ))}
                    </select>
                  </Field>
                </div>
                <hr className="divider" />
                <div className="section-head">Item details</div>
                <div className="gap-sm">
                  <Field label="Item description" req error={rowErrors.particular}>
                    <div className="add-row">
                      <input
                        type="text"
                        className={rowErrors.particular ? 'has-error' : ''}
                        value={inputParticular}
                        onChange={(e) => setInputParticular(e.target.value)}
                        onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addItemHandler())}
                        placeholder="e.g. Office Chair, Desk Lamp"
                      />
                      <button type="button" className="btn-add" onClick={addItemHandler} title="Add item">+</button>
                    </div>
                  </Field>
                </div>
                <div className="field-grid three gap">
                  <Field label="Unit" req error={rowErrors.unit}>
                    <select
                      className={rowErrors.unit ? 'has-error' : ''}
                      value={inputUnit}
                      onChange={(e) => setInputUnit(e.target.value)}
                    >
                      <option value="">Select unit</option>
                      {UNIT_OPTIONS.map(u => <option key={u} value={u}>{u}</option>)}
                    </select>
                  </Field>
                  <Field label="Quantity" req error={rowErrors.quantity}>
                    <input
                      type="number"
                      className={rowErrors.quantity ? 'has-error' : ''}
                      placeholder="0"
                      value={inputQuantity || ''}
                      onChange={(e) => setInputQuantity(e.target.value ? parseFloat(e.target.value) : 0)}
                    />
                  </Field>
                  <Field label="Unit cost (₱)" req error={rowErrors.unitCost}>
                    <input
                      type="number"
                      className={rowErrors.unitCost ? 'has-error' : ''}
                      placeholder="0.00"
                      value={inputUnitCost || ''}
                      onChange={(e) => setInputUnitCost(e.target.value ? parseFloat(e.target.value) : 0)}
                    />
                  </Field>
                </div>
                <div className="field-grid gap">
                  <Field label="Item No.">
                    <input type="number" placeholder="Item No." value={itemNo} onChange={(e) => setItemNo(e.target.value)} />
                  </Field>
                  <Field label="Line total (₱)">
                    <input type="number" value={inputQuantity * inputUnitCost || 0} disabled />
                  </Field>
                </div>
                <ItemsTable items={particularItems} grandTotal={grandTotal} onRemove={removeItemHandler} />
                <hr className="divider" />
                <div className="section-head">Requestor</div>
                <div className="field-grid gap">
                  <Field label="Name" req>
                    <input type="text" placeholder="Full name" value={name} onChange={(e) => setName(e.target.value)} />
                  </Field>
                  <Field label="Designation" req>
                    <select value={designation} onChange={(e) => setDesignation(e.target.value)}>
                      <option value="">Select designation</option>
                      {DESIGNATION_OPTIONS.map(d => (
                        <option key={d} value={d}>{d}</option>
                      ))}
                    </select>
                  </Field>
                  <Field label="Purpose" req span2>
                    <textarea
                      placeholder="Enter the purpose for this purchase request…"
                      value={purpose}
                      onChange={(e) => setPurpose(e.target.value)}
                      rows={4}
                      required
                    />
                  </Field>
                </div>
                <Field label="Certification">
                  <div className="cert-group" style={{marginTop:4}}>
                    <button type="button" className={`cert-btn${certification === 'certified' ? ' active' : ''}`} onClick={() => setCertification('certified')}>✓ Funds available</button>
                    <button type="button" className={`cert-btn${certification === 'not-certified' ? ' active' : ''}`} onClick={() => setCertification('not-certified')}>✗ No funds available</button>
                  </div>
                </Field>

                <div className="pr-footer">
                  <button type="button" className="btn btn-ghost" onClick={handleDownloadCSV} disabled={!isFormComplete}>
                    📄 Download PR Form (CSV)
                  </button>
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <button className="btn btn-ghost" type="button" onClick={handleCancelCreate}>✕ Cancel</button>
                    <button className="btn btn-primary" type="submit" disabled={isSubmitting}>
                      {isSubmitting ? <><Spinner /> Creating…</> : 'Create PR →'}
                    </button>
                  </div>
                </div>
              </form>
            )}

            {/* STEP 2 – Approval (unchanged) */}
            {currentStep === 'approval' && (
              <div>
                <div className="section-head">Review &amp; approval</div>
                <div className="info-card gap">
                  <p><strong>PR No.</strong>{prNo}</p>
                  <p><strong>Office</strong>{office}</p>
                  {divisionSection && <p><strong>Division/Section</strong>{divisionSection}</p>}
                </div>
                <div className="section-head">PR Approver</div>
                <div className="field-grid gap">
                  <Field label="Name">
                    <input type="text" value={approverName} onChange={(e) => setApproverName(e.target.value)} />
                  </Field>
                  <Field label="Position">
                    <select value={approverPosition} onChange={(e) => setApproverPosition(e.target.value)}>
                      <option value="">Select position</option>
                      {DESIGNATION_OPTIONS.map(d => <option key={d} value={d}>{d}</option>)}
                    </select>
                  </Field>
                  <Field label="Office">
                    <input type="text" value={approverOffice} disabled />
                  </Field>
                </div>
                {particularItems.length > 0 && <ItemsTable items={particularItems} grandTotal={grandTotal} />}
                <div className="decision-area">
                  <div className="decision-btns">
                    <button className="btn btn-success" onClick={() => handleApprovalDecision('approved')} disabled={isSubmitting}>
                      {isSubmitting ? <><Spinner /> Processing…</> : '✓ Approve'}
                    </button>
                    <button className="btn btn-danger" onClick={() => handleApprovalDecision('disapproved')} disabled={isSubmitting}>
                      {isSubmitting ? <><Spinner /> Processing…</> : '✗ Disapprove'}
                    </button>
                  </div>
                </div>
                <div className="pr-footer">
                  <button type="button" className="btn btn-ghost" onClick={goBack} disabled={isSubmitting}>← Back</button>
                  <div />
                </div>
              </div>
            )}

            {/* STEP 3 – Delivery Note (unchanged) */}
            {currentStep === 'delivery_note' && (
              <form onSubmit={handleDeliveryNote}>
                <div className="section-head">Delivery information</div>
                <div className="info-card gap">
                  <p><strong>PR No.</strong>{prNo}</p>
                  <p><strong>Office</strong>{office}</p>
                  <p><strong>Division/Section</strong>{divisionSection}</p>
                </div>
                <div className="field-grid gap">
                  <Field label="Supplier" req><input type="text" placeholder="Supplier name" value={supplier} onChange={(e) => setSupplier(e.target.value)} /></Field>
                  <Field label="PR No."><input type="text" value={prNo} disabled /></Field>
                  <Field label="SI No."><input type="text" placeholder="SI No." value={siNo} onChange={(e) => setSiNo(e.target.value)} /></Field>
                  <Field label="PO Date"><input type="date" value={poDate} onChange={(e) => setPoDate(e.target.value)} /></Field>
                  <Field label="DR No."><input type="text" placeholder="DR No." value={drNo} onChange={(e) => setDrNo(e.target.value)} /></Field>
                </div>
                <hr className="divider" />
                <div className="section-head">Particulars</div>
                <p style={{fontSize: '12px', color: 'var(--text-3)', marginBottom: '10px'}}>Note: Add items here. If you need to add more items in Delivery Information, you can do so after completing this step.</p>
                <div className="gap-sm">
                  <Field label="Item particular" req error={rowErrors.particular}>
                    <div className="add-row">
                      <input type="text" className={rowErrors.particular ? 'has-error' : ''} value={inputParticular} onChange={(e) => setInputParticular(e.target.value)} onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addItemHandler())} placeholder="Item particulars (e.g., Office Chair)" />
                      <button type="button" className="btn-add" onClick={addItemHandler} title="Add item">+</button>
                    </div>
                  </Field>
                </div>
                <div className="field-grid three gap">
                  <Field label="Unit" error={rowErrors.unit}><select className={rowErrors.unit ? 'has-error' : ''} value={inputUnit} onChange={(e) => setInputUnit(e.target.value)}><option value="">Select unit</option>{UNIT_OPTIONS.map(u => <option key={u} value={u}>{u}</option>)}</select></Field>
                  <Field label="Quantity" error={rowErrors.quantity}><input type="number" className={rowErrors.quantity ? 'has-error' : ''} value={inputQuantity || ''} onChange={(e) => setInputQuantity(e.target.value ? parseFloat(e.target.value) : 0)} placeholder="0" /></Field>
                  <Field label="Unit cost (₱)" error={rowErrors.unitCost}><input type="number" className={rowErrors.unitCost ? 'has-error' : ''} value={inputUnitCost || ''} onChange={(e) => setInputUnitCost(e.target.value ? parseFloat(e.target.value) : 0)} placeholder="0.00" step="0.01" /></Field>
                  <Field label="Amount (₱)"><input type="number" value={inputQuantity * inputUnitCost || 0} disabled /></Field>
                  <Field label="Grand total (₱)" span2><input type="number" value={grandTotal} disabled /></Field>
                </div>
                <ItemsTable items={particularItems} grandTotal={grandTotal} onRemove={removeItemHandler} />
                <hr className="divider" />
                <div className="field-grid gap">
                  <Field label="Prepared by"><input type="text" value={preparedBy} onChange={(e) => setPreparedBy(e.target.value)} /></Field>
                  <Field label="Noted by"><input type="text" value={notedBy} onChange={(e) => setNotedBy(e.target.value)} /></Field>
                </div>
                <div className="pr-footer">
                  <button type="button" className="btn btn-ghost" onClick={goBack} disabled={isSubmitting}>← Back</button>
                  <button className="btn btn-primary" type="submit" disabled={isSubmitting}>{isSubmitting ? <><Spinner /> Saving…</> : 'Next: Inspection →'}</button>
                </div>
              </form>
            )}

            {/* STEP 4 – Inspection (unchanged) */}
            {currentStep === 'inspection' && (
              <form onSubmit={handleInspection}>
                <div className="section-head">PR summary</div>
                <div className="info-card gap">
                  <p><strong>PR No.</strong>{prNo}</p>
                  <p><strong>Office</strong>{office}</p>
                  <p><strong>Division/Section</strong>{divisionSection}</p>
                  <p><strong>Total amount</strong><strong style={{color:'var(--green)'}}>{fmt(totalAmount)}</strong></p>
                </div>
                {(supplier || siNo || poDate || drNo) && (
                  <div className="info-card blue gap">
                    <h4>Delivery information</h4>
                    {supplier && <p><strong>Supplier</strong>{supplier}</p>}
                    {siNo && <p><strong>SI No.</strong>{siNo}</p>}
                    {poDate && <p><strong>PO Date</strong>{poDate}</p>}
                    {drNo && <p><strong>DR No.</strong>{drNo}</p>}
                  </div>
                )}
                <div className="section-head">Inspection document details</div>
                <div className="field-grid gap">
                  {[
                    { label:'Supplier', req:true, type:'text', value:iacSupplier, setter:setIacSupplier, placeholder:'Supplier name' },
                    { label:'P.O. date', req:true, type:'date', value:iacPoDate, setter:setIacPoDate },
                    { label:'IAR No.', req:true, type:'text', value:iacIarNo, setter:setIacIarNo, placeholder:'YYYY-MM-ENTRY#' },
                    { label:'Date', req:true, type:'date', value:iacDate, setter:setIacDate },
                    { label:'Invoice No.', req:true, type:'text', value:iacInvoiceNo, setter:setIacInvoiceNo },
                    { label:'Invoice date', req:true, type:'date', value:iacInvoiceDate, setter:setIacInvoiceDate },
                  ].map(({ label, req, type, value, setter, placeholder }) => (
                    <Field key={label} label={label} req={req}>
                      <input type={type} value={value} onChange={(e) => setter(e.target.value)} placeholder={placeholder || ''} />
                    </Field>
                  ))}
                  <Field label="Requisitioning office" req span2>
                    <select value={iacRequisitioningOffice} onChange={(e) => setIacRequisitioningOffice(e.target.value)}>
                      <option value="">Select office</option>
                      {IAC_OFFICES.map(o => <option key={o} value={o}>{o}</option>)}
                    </select>
                  </Field>
                </div>
                <div className="section-head">Inspection notes</div>
                <div className="gap"><textarea value={inspectionNotes} onChange={(e) => setInspectionNotes(e.target.value)} rows={4} required placeholder="Item condition, quantity verified, quality assessment…" /></div>
                <div className="section-head">Items for inspection</div>
                {particularItems.length > 0 ? (
                  <ItemsTable items={particularItems} grandTotal={totalAmount} showRemarks onRemarkChange={setParticularItems} />
                ) : (
                  <div className="info-card" style={{textAlign:'center',color:'var(--text-3)',padding:'2rem'}}>No items found. Go back to Step 1 to add items.</div>
                )}
                <div className="pr-footer">
                  <button type="button" className="btn btn-ghost" onClick={goBack} disabled={isSubmitting}>← Back</button>
                  <button className="btn btn-primary" type="submit" disabled={isSubmitting}>{isSubmitting ? <><Spinner /> Saving…</> : 'Complete inspection →'}</button>
                </div>
              </form>
            )}

            {/* STEP 5 – Form Selection (unchanged) */}
            {currentStep === 'form_selection' && (
              <div>
                <div className="section-head">Inventory form selection</div>
                <div className="info-card gap">
                  <h4>Purchase request summary</h4>
                  <p><strong>PR No.</strong>{prNo}</p>
                  <p><strong>Office</strong>{office}</p>
                  {divisionSection && <p><strong>Division/Section</strong>{divisionSection}</p>}
                </div>
                {particularItems.length > 0 && <ItemsTable items={particularItems} grandTotal={grandTotal} />}
                {supplier && (
                  <div className="info-card blue gap" style={{marginTop:14}}>
                    <h4>Delivery information</h4>
                    <p><strong>Supplier</strong>{supplier}</p>
                    {siNo && <p><strong>SI No.</strong>{siNo}</p>}
                    {poDate && <p><strong>PO Date</strong>{poDate}</p>}
                    {drNo && <p><strong>DR No.</strong>{drNo}</p>}
                  </div>
                )}
                <div style={{margin:'18px 0 8px',fontSize:13,color:'var(--text-2)'}}>
                  Amount: <strong style={{fontFamily:'var(--mono)'}}>{fmt(totalAmount)}</strong>
                  <span style={{margin:'0 6px',color:'var(--text-3)'}}>·</span>
                  Threshold: <strong style={{fontFamily:'var(--mono)'}}>₱50,000.00</strong>
                </div>
                <div className="form-select-options">
                  <div className={`form-opt${isICS ? ' active-ics' : ''}`}>
                    <h4 style={{color: isICS ? 'var(--accent)' : 'var(--text-3)'}}>ICS</h4>
                    <p>For amounts below ₱50,000</p>
                    {isICS && <p style={{marginTop:6,fontWeight:600,color:'var(--accent)'}}>← Selected</p>}
                  </div>
                  <div className={`form-opt${!isICS ? ' active-ppe' : ''}`}>
                    <h4 style={{color: !isICS ? 'var(--amber)' : 'var(--text-3)'}}>PPE + PAR</h4>
                    <p>For amounts ₱50,000 and above</p>
                    {!isICS && <p style={{marginTop:6,fontWeight:600,color:'var(--amber)'}}>← Selected</p>}
                  </div>
                </div>
                <div className="pr-footer">
                  <button type="button" className="btn btn-ghost" onClick={goBack}>← Back</button>
                  <button className="btn btn-primary" onClick={handleFormSelection}>Proceed to {isICS ? 'ICS Form' : 'PPE Form'} →</button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </>
  );
}

export const PurchaseRequestData = {
  unitCost: 0,
  quantity: 1,
  unit: '',
};

export default NewEntryPR;