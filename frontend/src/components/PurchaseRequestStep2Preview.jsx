import { useRef } from 'react';
import marinaLogo from './marinalogo.png';

// ─── Formatters ───────────────────────────────────────────────────────────────
const fmtCurrency = (n) =>
  parseFloat(n || 0).toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

const fmtDate = (iso) => {
  if (!iso) return '';
  const d = new Date(iso + 'T00:00:00');
  return d.toLocaleDateString('en-PH', { year: 'numeric', month: 'long', day: 'numeric' });
};

// ─── Styles ───────────────────────────────────────────────────────────────────
const previewCss = `
  .s2-shell {
    font-family: var(--font);
    color: var(--text);
  }
  .s2-action-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 18px;
    gap: 10px;
    flex-wrap: wrap;
  }
  .s2-action-bar-title {
    font-size: 13px;
    font-weight: 600;
    color: var(--navy);
    text-transform: uppercase;
    letter-spacing: 0.07em;
  }
  .s2-action-bar-btns {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
  }
  .s2-notice {
    background: var(--accent-lt);
    border: 0.5px solid rgba(26,82,212,0.2);
    border-radius: var(--radius);
    padding: 9px 14px;
    font-size: 12px;
    color: var(--navy);
    margin-bottom: 18px;
    display: flex;
    align-items: center;
    gap: 7px;
  }

  /* ── The actual A4-like form ── */
  .pr-form-wrap {
    background: #fff;
    border: 1px solid #ccc;
    border-radius: 4px;
    padding: 16px 18px 14px 18px;
    margin-bottom: 20px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.08);
    font-family: Arial, Helvetica, sans-serif;
    font-size: 10px;
    color: #000;
    max-width: 720px;
  }
  .pr-form-meta {
    text-align: right;
    font-size: 9px;
    margin-bottom: 5px;
    line-height: 1.5;
  }
  .pr-form-header {
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 6px;
    gap: 12px;
  }
  .pr-form-header img {
    width: 52px;
    height: auto;
  }
  .pr-form-header-text {
    text-align: center;
    font-size: 10px;
    line-height: 1.5;
  }
  .pr-form-header-text .agency {
    font-weight: bold;
    font-size: 10.5px;
  }
  .pr-form-title {
    text-align: center;
    font-weight: bold;
    font-size: 11px;
    text-decoration: underline;
    margin-bottom: 6px;
  }
  .pr-outer {
    width: 100%;
    border-collapse: collapse;
    border: 1.5px solid #000;
  }
  .pr-outer td { border: 0; padding: 0; }
  .pr-items-table {
    width: 100%;
    border-collapse: collapse;
  }
  .pr-items-table thead tr {
    border-bottom: 1px solid #000;
  }
  .pr-items-table th {
    border-right: 1px solid #000;
    text-align: center;
    font-weight: bold;
    font-size: 9.5px;
    padding: 3px 2px;
    vertical-align: middle;
  }
  .pr-items-table th:last-child { border-right: 0; }
  .pr-items-table tbody tr {
    height: 17px;
    border-bottom: 1px solid #000;
  }
  .pr-items-table tbody tr:last-child { border-bottom: 0; }
  .pr-items-table td {
    border-right: 1px solid #000;
    font-size: 9.5px;
    padding: 1px 3px;
  }
  .pr-items-table td:last-child { border-right: 0; }
  .pr-items-table td.tc { text-align: center; }
  .pr-items-table td.tr { text-align: right; }
  .pr-sig-row td { border-right: 1px solid #000; }
  .pr-sig-row td:last-child { border-right: 0; }
  .cb-box {
    display: inline-block;
    width: 9px;
    height: 9px;
    border: 1px solid #000;
    vertical-align: middle;
    margin-right: 4px;
    position: relative;
  }
  .cb-box.checked::after {
    content: '✓';
    position: absolute;
    top: -3px;
    left: 0px;
    font-size: 9px;
    color: #000;
    font-weight: bold;
  }
  .pr-footer-btns {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 1rem 0 0;
    border-top: 0.5px solid var(--border);
    margin-top: 4px;
    gap: 8px;
  }
`;

// ─── Main component ───────────────────────────────────────────────────────────
function PurchaseRequestStep2Preview({
  office,
  division,
  prNo,
  dateRequested,
  purpose,
  particularItems,
  name,
  designation,
  certification,
  itemNo,
  onBack,
  onConfirm,
}) {
  const formRef = useRef(null);

  // ── Totals ─────────────────────────────────────────────────────────────────
  const grandTotal = particularItems.reduce(
    (sum, item) => sum + item.quantity * item.unitCost,
    0
  );

  // ── Pad rows to at least 10 for the blank lines on the form ───────────────
  const MIN_ROWS = 10;
  const displayRows = [...particularItems];
  while (displayRows.length < MIN_ROWS) {
    displayRows.push(null); // null = blank row
  }

  // ── PDF download via html2canvas + jsPDF ──────────────────────────────────
  const handleDownloadPDF = async () => {
    const btn = document.querySelector('[data-pdf-dl-btn]');
    if (btn) { btn.disabled = true; btn.textContent = 'Generating PDF…'; }

    try {
      const [{ default: html2canvas }, { jsPDF }] = await Promise.all([
        import('html2canvas'),
        import('jspdf'),
      ]);

      const el = formRef.current;
      if (!el) throw new Error('Form element not found.');

      const canvas = await html2canvas(el, {
        scale: 3,
        useCORS: true,
        allowTaint: true,
        backgroundColor: '#ffffff',
        logging: false,
        windowWidth: el.scrollWidth,
        windowHeight: el.scrollHeight,
        onclone: (clonedDoc) => {
          // Make sure all images in the clone are loaded
          const imgs = clonedDoc.querySelectorAll('img');
          return Promise.all(Array.from(imgs).map(img =>
            img.complete ? Promise.resolve() : new Promise(res => { img.onload = res; img.onerror = res; })
          ));
        },
      });

      const pdf = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' });
      const pageW = pdf.internal.pageSize.getWidth();
      const pageH = pdf.internal.pageSize.getHeight();

      // Always fit the entire form on exactly one page with margins
      const marginX = 15;
      const marginY = 15;
      const printW  = pageW - marginX * 2;
      const printH  = pageH - marginY * 2;

      // Scale to fit within printable area, preserving aspect ratio
      const canvasAspect = canvas.height / canvas.width;
      let imgW = printW;
      let imgH = printW * canvasAspect;

      // If still too tall, scale down to fit height
      if (imgH > printH) {
        imgH = printH;
        imgW = printH / canvasAspect;
      }

      // Center horizontally
      const offsetX = marginX + (printW - imgW) / 2;

      pdf.addImage(canvas.toDataURL('image/png'), 'PNG', offsetX, marginY, imgW, imgH);
      pdf.save(`MARINA_Purchase_Request_${prNo || 'form'}.pdf`);

    } catch (err) {
      alert('PDF generation failed: ' + err.message);
    } finally {
      if (btn) { btn.disabled = false; btn.textContent = '⬇ Download as PDF'; }
    }
  };

  // ── Certification state ────────────────────────────────────────────────────
  const fundsAvailable   = certification === 'certified';
  const noFunds          = certification === 'not-certified';

  return (
    <>
      <style>{previewCss}</style>
      <div className="s2-shell">

        {/* ── Action bar ─────────────────────────────────────────────────── */}
        <div className="s2-action-bar">
          <span className="s2-action-bar-title">Preview Purchase Request</span>
          <div className="s2-action-bar-btns">

          </div>
        </div>

        <div className="s2-notice">
          ℹ Review the form below. All data was carried over from Step 1. Download a PDF copy before confirming.
        </div>

        {/* ══════════════════════════════════════════════════════════════════
            THE MARINA PURCHASE REQUEST FORM
        ════════════════════════════════════════════════════════════════════ */}
        <div className="pr-form-wrap" ref={formRef}>

          {/* Form meta */}
          <div className="pr-form-meta">
            Form No. QMS-10/2-1<br />
            Revision No./Date: 0/15 Nov 2010
          </div>

          {/* Header */}
          <div className="pr-form-header">
            <img src={marinaLogo} alt="MARINA Logo" />
            <div className="pr-form-header-text">
              Republic of the Philippines<br />
              Department of Transportation<br />
              <span className="agency">MARITIME INDUSTRY AUTHORITY</span>
            </div>
          </div>

          {/* Title */}
          <div className="pr-form-title">PURCHASE REQUEST</div>

          {/* ── MAIN OUTER TABLE ── */}
          <table className="pr-outer">
            <tbody>

              {/* ROW: Office / PR No */}
              <tr>
                <td style={{ borderBottom: '1px solid #000' }}>
                  <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                    <tbody>
                      <tr>
                        {/* Office / Division */}
                        <td style={{
                          width: '60%',
                          borderRight: '1px solid #000',
                          padding: '3px 5px',
                          verticalAlign: 'top',
                        }}>
                          <div style={{ display: 'flex', gap: 3, alignItems: 'flex-end', marginBottom: 3, fontSize: 10 }}>
                            <span>Office:</span>
                            <span style={{ flex: 1, borderBottom: '1px solid #000', paddingLeft: 3, fontWeight: 'bold' }}>
                              {office || '\u00A0'}
                            </span>
                          </div>
                          <div style={{ display: 'flex', gap: 3, alignItems: 'flex-end', fontSize: 10 }}>
                            <span>Division/Section:</span>
                            <span style={{ flex: 1, borderBottom: '1px solid #000', paddingLeft: 3, fontWeight: 'bold' }}>
                              {division || '\u00A0'}
                            </span>
                          </div>
                        </td>
                        {/* PR No / SAI No */}
                        <td style={{ padding: '3px 5px', verticalAlign: 'top' }}>
                          <div style={{ display: 'flex', gap: 3, alignItems: 'flex-end', marginBottom: 3, fontSize: 10 }}>
                            <span>PR No. :</span>
                            <span style={{ flex: 1, borderBottom: '1px solid #000', paddingLeft: 3, fontWeight: 'bold' }}>
                              {prNo || '\u00A0'}
                            </span>
                          </div>
                          <div style={{ display: 'flex', gap: 3, alignItems: 'flex-end', fontSize: 10 }}>
                            <span>Date:</span>
                            <span style={{ flex: 1, borderBottom: '1px solid #000', paddingLeft: 3 }}>
                              {fmtDate(dateRequested) || '\u00A0'}
                            </span>
                          </div>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </td>
              </tr>

              {/* ROW: Items table */}
              <tr>
                <td style={{ borderBottom: '1px solid #000' }}>
                  <table className="pr-items-table">
                    <colgroup>
                      <col style={{ width: '7%' }} />
                      <col style={{ width: '8%' }} />
                      <col style={{ width: '47%' }} />
                      <col style={{ width: '10%' }} />
                      <col style={{ width: '14%' }} />
                      <col style={{ width: '14%' }} />
                    </colgroup>
                    <thead>
                      <tr>
                        <th>Item<br />No.</th>
                        <th>Unit</th>
                        <th>Item Description</th>
                        <th>Qty</th>
                        <th>Unit Cost</th>
                        <th>Total Cost</th>
                      </tr>
                    </thead>
                    <tbody>
                      {displayRows.map((item, idx) =>
                        item ? (
                          <tr key={item.id || idx}>
                            <td className="tc">{idx + 1}</td>
                            <td className="tc">{item.unit}</td>
                            <td style={{ paddingLeft: 5 }}>{item.particular}</td>
                            <td className="tc">{item.quantity}</td>
                            <td className="tr" style={{ paddingRight: 5 }}>
                              {fmtCurrency(item.unitCost)}
                            </td>
                            <td className="tr" style={{ paddingRight: 5 }}>
                              {fmtCurrency(item.quantity * item.unitCost)}
                            </td>
                          </tr>
                        ) : (
                          <tr key={`blank-${idx}`}>
                            <td className="tc">&nbsp;</td>
                            <td>&nbsp;</td>
                            <td>&nbsp;</td>
                            <td>&nbsp;</td>
                            <td>&nbsp;</td>
                            <td>&nbsp;</td>
                          </tr>
                        )
                      )}
                      {/* Grand Total row */}
                      <tr style={{ borderTop: '1px solid #000' }}>
                        <td colSpan={5}>&nbsp;</td>
                        <td style={{
                          borderRight: '1px solid #000',
                          textAlign: 'right',
                          paddingRight: 5,
                          fontWeight: 'bold',
                          fontSize: 10,
                        }}>
                          TOTAL
                        </td>
                        <td style={{
                          textAlign: 'right',
                          paddingRight: 5,
                          fontWeight: 'bold',
                          fontSize: 10,
                        }}>
                          {fmtCurrency(grandTotal)}
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </td>
              </tr>

              {/* ROW: Requisitioning Officer label */}
              <tr>
                <td style={{
                  textAlign: 'center',
                  fontSize: 10,
                  padding: '3px',
                  borderBottom: '1px solid #000',
                }}>
                  Requisitioning Officer
                </td>
              </tr>

              {/* ROW: Signature */}
              <tr>
                <td style={{ borderBottom: '1px solid #000' }}>
                  <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                    <tbody>
                      <tr>
                        <td style={{
                          fontSize: 10, padding: '2px 5px',
                          whiteSpace: 'nowrap',
                          borderRight: '1px solid #000',
                          width: 100,
                        }}>
                          Signature:
                        </td>
                        <td style={{ padding: '2px 5px', height: 18 }}>&nbsp;</td>
                      </tr>
                    </tbody>
                  </table>
                </td>
              </tr>

              {/* ROW: Printed Name */}
              <tr>
                <td style={{ borderBottom: '1px solid #000' }}>
                  <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                    <tbody>
                      <tr>
                        <td style={{
                          fontSize: 10, padding: '2px 5px',
                          whiteSpace: 'nowrap',
                          borderRight: '1px solid #000',
                          width: 100,
                        }}>
                          Printed Name:
                        </td>
                        <td style={{
                          fontWeight: 'bold',
                          fontSize: 10.5,
                          textAlign: 'center',
                          padding: '2px 5px',
                        }}>
                          {name ? name.toUpperCase() : 'ATTY. MARIVIC S. RAMOS'}
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </td>
              </tr>

              {/* ROW: Designation */}
              <tr>
                <td style={{ borderBottom: '1px solid #000' }}>
                  <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                    <tbody>
                      <tr>
                        <td style={{
                          fontSize: 10, padding: '2px 5px',
                          whiteSpace: 'nowrap',
                          borderRight: '1px solid #000',
                          width: 100,
                        }}>
                          Designation
                        </td>
                        <td style={{ fontSize: 10, textAlign: 'center', padding: '2px 5px' }}>
                          {designation || 'Director II, MFAS'}
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </td>
              </tr>

              {/* ROW: Purpose label */}
              <tr>
                <td style={{ fontSize: 10, fontWeight: 'bold', padding: '2px 5px', borderBottom: '1px solid #000' }}>
                  Purpose
                </td>
              </tr>

              {/* ROW: Purpose value */}
              <tr>
                <td style={{ fontSize: 10, padding: '3px 5px 4px 5px', borderBottom: '1px solid #000', minHeight: 20 }}>
                  {purpose || '\u00A0'}
                </td>
              </tr>

              {/* ROW: CERTIFICATION header */}
              <tr>
                <td style={{
                  textAlign: 'center',
                  fontWeight: 'bold',
                  fontSize: 10.5,
                  padding: '3px 4px',
                  borderBottom: '1px solid #000',
                }}>
                  CERTIFICATION
                </td>
              </tr>

              {/* ROW: Funds Available + Budget Chief */}
              <tr>
                <td style={{ borderBottom: '1px solid #000' }}>
                  <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                    <tbody>
                      <tr>
                        <td style={{ padding: '5px 12px 7px 18px', verticalAlign: 'top', width: '55%' }}>
                          <div style={{ display: 'flex', alignItems: 'center', marginBottom: 3, fontSize: 10 }}>
                            <span
                              className={`cb-box${fundsAvailable ? ' checked' : ''}`}
                            />
                            FUNDS AVAILABLE
                          </div>
                          <div style={{ display: 'flex', alignItems: 'center', fontSize: 10 }}>
                            <span
                              className={`cb-box${noFunds ? ' checked' : ''}`}
                            />
                            NO FUNDS AVAILABLE
                          </div>
                        </td>
                        <td style={{
                          textAlign: 'right',
                          padding: '6px 8px 4px 6px',
                          verticalAlign: 'bottom',
                          width: '45%',
                        }}>
                          <div style={{ fontWeight: 'bold', fontSize: 10.5 }}>DAN HENRY V. RAMIREZ</div>
                          <div style={{ fontSize: 10 }}>Chief, Budget Division</div>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </td>
              </tr>

              {/* ROW: Approved / Disapproved */}
              <tr>
                <td style={{ borderBottom: '1px solid #000' }}>
                  <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                    <tbody>
                      <tr>
                        <td style={{
                          width: '38%',
                          borderRight: '1px solid #000',
                          padding: '3px 5px',
                          height: 18,
                        }}>&nbsp;</td>
                        <td style={{ padding: '3px 10px' }}>
                          <div style={{
                            display: 'flex',
                            justifyContent: 'space-around',
                            alignItems: 'center',
                            fontSize: 10,
                          }}>
                            <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
                              <span style={{
                                display: 'inline-block', width: 11, height: 11,
                                border: '1px solid #000',
                              }} />
                              <strong>Approved</strong>
                            </div>
                            <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
                              <span style={{
                                display: 'inline-block', width: 11, height: 11,
                                border: '1px solid #000',
                              }} />
                              <strong>Disapproved</strong>
                            </div>
                          </div>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </td>
              </tr>

              {/* ROW: Admin Signature + Name */}
              <tr>
                <td style={{ borderBottom: '1px solid #000' }}>
                  <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                    <tbody>
                      <tr>
                        <td style={{
                          fontSize: 10, padding: '2px 5px',
                          borderRight: '1px solid #000',
                          width: '38%',
                          verticalAlign: 'top',
                        }}>
                          Signature:<br />Printed Name:
                        </td>
                        <td style={{
                          fontWeight: 'bold',
                          fontSize: 10.5,
                          textAlign: 'center',
                          padding: '3px 5px',
                          verticalAlign: 'bottom',
                        }}>
                          SONIA B. MALALUAN
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </td>
              </tr>

              {/* ROW: Admin Designation */}
              <tr>
                <td style={{ borderBottom: '1px solid #000' }}>
                  <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                    <tbody>
                      <tr>
                        <td style={{
                          fontSize: 10, padding: '2px 5px',
                          borderRight: '1px solid #000',
                          width: '38%',
                        }}>
                          Designation
                        </td>
                        <td style={{ fontSize: 10, textAlign: 'center', padding: '2px 5px' }}>
                          Administrator
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </td>
              </tr>

              {/* ROW: Note */}
              <tr>
                <td style={{ fontSize: 9.5, padding: '3px 5px', fontStyle: 'italic' }}>
                  &nbsp;&nbsp;&nbsp;
                  <em>
                    <strong>Note:</strong>&nbsp;&nbsp;
                    Please indicate a specific purpose other than &quot;for official use of the Office.&quot;
                    (e.g. monthly regular supplies, as per APP. special projects, etc.)
                  </em>
                </td>
              </tr>

            </tbody>
          </table>
        </div>
        {/* end pr-form-wrap */}

        {/* ── Footer navigation ─────────────────────────────────────────── */}
        <div className="pr-footer-btns">
          <button
            type="button"
            className="btn btn-ghost"
            onClick={onBack}
          >
            ← Back
          </button>
          <div style={{ display: 'flex', gap: 8 }}>
            <button
              type="button"
              className="btn btn-ghost"
              data-pdf-dl-btn
              onClick={handleDownloadPDF}
            >
              ⬇ Download as PDF
            </button>
            <button
              type="button"
              className="btn btn-primary"
              onClick={onConfirm}
            >
              Confirm &amp; Proceed to Approval →
            </button>
          </div>
        </div>

      </div>
    </>
  );
}

export default PurchaseRequestStep2Preview;