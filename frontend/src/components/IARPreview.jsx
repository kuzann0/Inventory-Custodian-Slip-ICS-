import { useRef } from 'react';

function IARPreview({
  prNo, supplier, iacIarNo, iacDate, iacInvoiceNo, iacInvoiceDate,
  iacPoDate, iacRequisitioningOffice, iacRequisitioningCode,
  particularItems, totalAmount, inspectionNotes,
  onBack, onConfirm, isSubmitting
}) {
  const pageRef = useRef(null);
  const fmt = (n) => `₱${parseFloat(n || 0).toFixed(2)}`;

  const handleDownloadPDF = async () => {
    try {
      // Dynamically import html2pdf
      const html2pdf = (await import('html2pdf.js')).default;
      const element = pageRef.current;
      const opt = {
        margin: 10,
        filename: `IAR-${iacIarNo || 'preview'}.pdf`,
        image: { type: 'jpeg', quality: 0.98 },
        html2canvas: { scale: 2 },
        jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
      };
      html2pdf().set(opt).from(element).save();
    } catch (err) {
      console.error('PDF download failed:', err);
      alert('Unable to download PDF. Please try again.');
    }
  };

  return (
    <div style={{ paddingBottom: '2rem' }}>
      <div ref={pageRef} style={{
        background: '#fff',
        maxWidth: '794px',
        margin: '0 auto',
        padding: '36px 40px',
        fontSize: '13px',
        fontFamily: "'Times New Roman', Times, serif",
        lineHeight: 1.4
      }}>
        {/* HEADER */}
        <div style={{ textAlign: 'center', marginBottom: '8px' }}>
          <div style={{ fontSize: '13.5px', fontWeight: 'bold', letterSpacing: '0.03em' }}>
            REPUBLIC OF THE PHILIPPINES
          </div>
          <div style={{ fontSize: '13.5px', fontWeight: 'bold', letterSpacing: '0.03em' }}>
            DEPARTMENT OF TRANSPORTATION
          </div>
          <div style={{ fontSize: '13.5px', fontWeight: 'bold', letterSpacing: '0.03em' }}>
            MARITIME INDUSTRY AUTHORITY
          </div>
        </div>

        <div style={{
          textAlign: 'center',
          fontSize: '15px',
          fontWeight: 'bold',
          textDecoration: 'underline',
          margin: '10px 0 12px 0',
          letterSpacing: '0.04em'
        }}>
          INSPECTION AND ACCEPTANCE REPORT
        </div>

        {/* TOP INFO FIELDS */}
        <table style={{
          width: '100%',
          borderCollapse: 'collapse',
          border: '1.5px solid #000',
          fontSize: '11.5px',
          marginBottom: '12px'
        }}>
          <tbody>
            <tr>
              <td style={{ fontWeight: 'bold', padding: '3px 6px', border: '1px solid #000', width: '155px' }}>Supplier</td>
              <td style={{ padding: '3px 6px', border: '1px solid #000', width: '8px', fontWeight: 'bold' }}>:</td>
              <td style={{ padding: '3px 6px', border: '1px solid #000', borderRight: '1px solid #000', flex: 1 }}>{supplier}</td>
              <td style={{ fontWeight: 'bold', padding: '3px 6px', border: '1px solid #000', width: '90px' }}>IAR No.</td>
              <td style={{ padding: '3px 6px', border: '1px solid #000', fontWeight: 'bold', width: '8px' }}>:</td>
              <td style={{ padding: '3px 6px', border: '1px solid #000' }}>{iacIarNo}</td>
            </tr>
            <tr>
              <td style={{ fontWeight: 'bold', padding: '3px 6px', border: '1px solid #000' }}>PR No./Date</td>
              <td style={{ padding: '3px 6px', border: '1px solid #000', fontWeight: 'bold' }}>:</td>
              <td style={{ padding: '3px 6px', border: '1px solid #000', borderRight: '1px solid #000' }}>{prNo}</td>
              <td style={{ fontWeight: 'bold', padding: '3px 6px', border: '1px solid #000' }}>Date</td>
              <td style={{ padding: '3px 6px', border: '1px solid #000', fontWeight: 'bold' }}>:</td>
              <td style={{ padding: '3px 6px', border: '1px solid #000' }}>{iacDate}</td>
            </tr>
            <tr>
              <td style={{ fontWeight: 'bold', padding: '3px 6px', border: '1px solid #000' }}>Requisitioning Office/Dept.</td>
              <td style={{ padding: '3px 6px', border: '1px solid #000', fontWeight: 'bold' }}>:</td>
              <td style={{ padding: '3px 6px', border: '1px solid #000', borderRight: '1px solid #000' }}>{iacRequisitioningOffice}</td>
              <td style={{ fontWeight: 'bold', padding: '3px 6px', border: '1px solid #000' }}>Invoice No.</td>
              <td style={{ padding: '3px 6px', border: '1px solid #000', fontWeight: 'bold' }}>:</td>
              <td style={{ padding: '3px 6px', border: '1px solid #000' }}>{iacInvoiceNo}</td>
            </tr>
            <tr>
              <td style={{ fontWeight: 'bold', padding: '3px 6px', border: '1px solid #000' }}>Responsibility Center Code</td>
              <td style={{ padding: '3px 6px', border: '1px solid #000', fontWeight: 'bold' }}>:</td>
              <td style={{ padding: '3px 6px', border: '1px solid #000', borderRight: '1px solid #000' }}>{iacRequisitioningCode}</td>
              <td style={{ fontWeight: 'bold', padding: '3px 6px', border: '1px solid #000' }}>Date</td>
              <td style={{ padding: '3px 6px', border: '1px solid #000', fontWeight: 'bold' }}>:</td>
              <td style={{ padding: '3px 6px', border: '1px solid #000' }}>{iacInvoiceDate}</td>
            </tr>
          </tbody>
        </table>

        {/* ITEMS TABLE */}
        <table style={{
          width: '100%',
          borderCollapse: 'collapse',
          border: '1.5px solid #000',
          marginBottom: '12px',
          fontSize: '11px'
        }}>
          <thead>
            <tr style={{ background: '#f8fafc' }}>
              <th style={{ border: '1.5px solid #000', padding: '3px 4px', textAlign: 'center', fontStyle: 'italic', fontWeight: 'bold', width: '90px' }}>Stock/Property No.</th>
              <th style={{ border: '1.5px solid #000', padding: '3px 4px', textAlign: 'center', fontStyle: 'italic', fontWeight: 'bold', flex: 1 }}>Description</th>
              <th style={{ border: '1.5px solid #000', padding: '3px 4px', textAlign: 'center', fontStyle: 'italic', fontWeight: 'bold', width: '70px' }}>Unit</th>
              <th style={{ border: '1.5px solid #000', padding: '3px 4px', textAlign: 'center', fontStyle: 'italic', fontWeight: 'bold', width: '70px' }}>Quantity</th>
            </tr>
          </thead>
          <tbody>
            {particularItems.length > 0 ? (
              particularItems.map((item, idx) => (
                <tr key={item.id}>
                  <td style={{ border: '1px solid #000', padding: '0 4px', height: '22px' }}>&nbsp;</td>
                  <td style={{ border: '1px solid #000', padding: '2px 4px', fontSize: '10.5px', height: '22px' }}>{item.particular}</td>
                  <td style={{ border: '1px solid #000', padding: '0 4px', textAlign: 'center', fontSize: '10.5px', height: '22px' }}>{item.unit}</td>
                  <td style={{ border: '1px solid #000', padding: '0 4px', textAlign: 'center', fontSize: '10.5px', height: '22px' }}>{item.quantity}</td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan="4" style={{ border: '1px solid #000', padding: '8px', textAlign: 'center', fontSize: '11px' }}>No items added</td>
              </tr>
            )}
          </tbody>
        </table>

        {/* INSPECTION / ACCEPTANCE SECTION */}
        <table style={{
          width: '100%',
          borderCollapse: 'collapse',
          border: '1.5px solid #000',
          fontSize: '11.5px'
        }}>
          <thead>
            <tr>
              <td style={{ fontWeight: 'bold', fontStyle: 'italic', textAlign: 'center', padding: '5px 0', borderRight: '1px solid #000', width: '50%', border: '1.5px solid #000' }}>INSPECTION</td>
              <td style={{ fontWeight: 'bold', fontStyle: 'italic', textAlign: 'center', padding: '5px 0', width: '50%', border: '1.5px solid #000' }}>ACCEPTANCE</td>
            </tr>
          </thead>
          <tbody>
            <tr>
              {/* LEFT: INSPECTION */}
              <td style={{ borderRight: '1px solid #000', padding: '10px 16px', verticalAlign: 'top', borderBottom: '1.5px solid #000' }}>
                <div style={{ marginBottom: '16px' }}>
                  <span style={{ fontWeight: 'bold' }}>Date Inspected :</span>
                  <div style={{ borderBottom: '1px solid #000', width: '180px', marginTop: '4px', display: 'inline-block', marginLeft: '8px' }}>&nbsp;</div>
                </div>
                <div style={{ marginBottom: '12px', display: 'flex', gap: '8px' }}>
                  <div style={{ width: '30px', height: '30px', border: '1.5px solid #000', flexShrink: 0 }}>&nbsp;</div>
                  <div style={{ fontSize: '11.5px', lineHeight: 1.4 }}>
                    Inspected, verified and found in order as to quantity and specifications
                  </div>
                </div>
                <div style={{ marginTop: '28px' }}>
                  <div style={{ borderBottom: '1.5px solid #000', width: '220px', marginBottom: '2px' }}>&nbsp;</div>
                  <div style={{ fontSize: '11px' }}>Inspection Officer/Committee</div>
                </div>
              </td>

              {/* RIGHT: ACCEPTANCE */}
              <td style={{ padding: '10px 16px', verticalAlign: 'top', borderBottom: '1.5px solid #000' }}>
                <div style={{ marginBottom: '16px' }}>
                  <span style={{ fontWeight: 'bold' }}>Date Accepted :</span>
                  <div style={{ borderBottom: '1px solid #000', width: '160px', marginTop: '4px', display: 'inline-block', marginLeft: '8px' }}>&nbsp;</div>
                </div>
                <div style={{ marginBottom: '10px', display: 'flex', gap: '8px' }}>
                  <div style={{ width: '30px', height: '30px', border: '1.5px solid #000', flexShrink: 0 }}>&nbsp;</div>
                  <div style={{ fontSize: '11.5px' }}>Complete</div>
                </div>
                <div style={{ marginBottom: '16px', display: 'flex', gap: '8px' }}>
                  <div style={{ width: '30px', height: '30px', border: '1.5px solid #000', flexShrink: 0 }}>&nbsp;</div>
                  <div style={{ fontSize: '11.5px' }}>Partial (pls. specify quantity)</div>
                </div>
                <div style={{ textAlign: 'center', marginTop: '10px' }}>
                  <div style={{ fontSize: '12px', fontWeight: 'bold', textDecoration: 'underline' }}>IMELDA Q. RAMOS</div>
                  <div style={{ fontSize: '11px' }}>Administrative Officer V</div>
                </div>
              </td>
            </tr>
          </tbody>
        </table>

        {/* INSPECTION NOTES */}
        <div style={{ marginTop: '16px', padding: '12px', background: '#f8fafc', border: '0.5px solid rgba(3,32,99,0.2)', borderRadius: '6px' }}>
          <div style={{ fontSize: '12px', fontWeight: 'bold', color: '#032063', marginBottom: '8px' }}>INSPECTION NOTES:</div>
          <div style={{ fontSize: '12px', lineHeight: 1.6, whiteSpace: 'pre-wrap', color: '#475569' }}>
            {inspectionNotes || '(No notes provided)'}
          </div>
        </div>
      </div>

      {/* ACTION BUTTONS */}
      <div style={{
        marginTop: '24px',
        display: 'flex',
        gap: '12px',
        justifyContent: 'center',
        maxWidth: '794px',
        margin: '24px auto 0'
      }}>
        <button
          onClick={handleDownloadPDF}
          style={{
            background: '#032063',
            color: '#fff',
            border: 'none',
            borderRadius: '6px',
            padding: '9px 20px',
            fontSize: '13.5px',
            fontWeight: '600',
            cursor: 'pointer',
            transition: 'background 0.15s'
          }}
          onMouseOver={(e) => e.target.style.background = '#0a2d7a'}
          onMouseOut={(e) => e.target.style.background = '#032063'}
        >
          ⬇ Download PDF
        </button>
        <button
          onClick={onBack}
          disabled={isSubmitting}
          style={{
            background: 'transparent',
            color: '#475569',
            border: '0.75px solid rgba(3,32,99,0.2)',
            borderRadius: '6px',
            padding: '9px 20px',
            fontSize: '13.5px',
            fontWeight: '600',
            cursor: isSubmitting ? 'not-allowed' : 'pointer',
            transition: 'background 0.15s',
            opacity: isSubmitting ? 0.55 : 1
          }}
          onMouseOver={(e) => !isSubmitting && (e.target.style.background = '#f8fafc')}
          onMouseOut={(e) => (e.target.style.background = 'transparent')}
        >
          ← Edit
        </button>
        <button
          onClick={onConfirm}
          disabled={isSubmitting}
          style={{
            background: '#1a8c5b',
            color: '#fff',
            border: 'none',
            borderRadius: '6px',
            padding: '9px 20px',
            fontSize: '13.5px',
            fontWeight: '600',
            cursor: isSubmitting ? 'not-allowed' : 'pointer',
            transition: 'background 0.15s',
            opacity: isSubmitting ? 0.55 : 1,
            display: 'flex',
            alignItems: 'center',
            gap: '6px'
          }}
          onMouseOver={(e) => !isSubmitting && (e.target.style.background = '#156e49')}
          onMouseOut={(e) => (e.target.style.background = '#1a8c5b')}
        >
          {isSubmitting ? (
            <>
              <span style={{
                width: '14px',
                height: '14px',
                border: '2px solid rgba(255,255,255,0.35)',
                borderTopColor: '#fff',
                borderRadius: '50%',
                animation: 'spin 0.65s linear infinite'
              }} />
              Proceeding…
            </>
          ) : (
            '✓ Confirm & Proceed →'
          )}
        </button>
      </div>

      <style>{`
        @keyframes spin {
          to { transform: rotate(360deg); }
        }
      `}</style>
    </div>
  );
}

export default IARPreview;
