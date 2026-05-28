import { useRef } from 'react';
import html2canvas from 'html2canvas';
import jsPDF from 'jspdf';
import marinaLogo from '../assets/NOD_LOGO_HEADER_NO_BG.png';

const fmt = (n) =>
  parseFloat(n || 0).toLocaleString('en-PH', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

const fmtDate = (iso) => {
  if (!iso) return '';
  const d = new Date(iso + 'T00:00:00');
  return d.toLocaleDateString('en-PH', { year: 'numeric', month: 'long', day: 'numeric' });
};

function NoticeOfDeliveryPreview({
  supplier,
  prNo,
  prDate,
  siNo,
  drNo,
  deliveryDate,
  particularItems,
  name,
  designation,
  notes,
  preparedBy,
  notedBy,
  onBack,
  onConfirm,
}) {
  const formRef = useRef(null);

  const grandTotal = particularItems.reduce(
    (sum, item) => sum + (item.quantity || 0) * (item.unitCost || 0),
    0
  );

  const MIN_ROWS = 12;
  const displayRows = [...particularItems];
  while (displayRows.length < MIN_ROWS) {
    displayRows.push(null);
  }

  const handleDownloadPDF = async () => {
    const element = formRef.current;
    if (!element) return;
    try {
      const canvas = await html2canvas(element, {
        scale: 3,
        backgroundColor: '#ffffff',
        logging: false,
      });
      const pdf = new jsPDF('p', 'mm', 'a4');
      const imgData = canvas.toDataURL('image/png');
      const pdfWidth = pdf.internal.pageSize.getWidth();
      const pdfHeight = pdf.internal.pageSize.getHeight();
      pdf.addImage(imgData, 'PNG', 0, 0, pdfWidth, pdfHeight);
      pdf.save(`NOD_${prNo}.pdf`);
    } catch (error) {
      console.error('PDF generation failed:', error);
    }
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
        <h3 style={{ flex: 1, margin: 0 }}>Notice of Delivery Preview</h3>
        <button
          type="button"
          style={{
            padding: '8px 16px',
            fontSize: '12px',
            backgroundColor: '#1a52d4',
            color: '#fff',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer',
          }}
          onClick={handleDownloadPDF}
        >
          ⬇ Download PDF
        </button>
      </div>

      {/* A4 NOD Form Preview */}
      <div
        ref={formRef}
        style={{
          width: '816px',
          minHeight: '1056px',
          margin: '0 auto',
          padding: '40px 50px',
          backgroundColor: '#fff',
          boxShadow: '0 2px 12px rgba(0,0,0,0.08)',
          borderRadius: '4px',
          fontFamily: 'Arial, sans-serif',
          fontSize: '12px',
          color: '#000',
        }}
      >
        {/* HEADER */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px', marginBottom: '18px' }}>
          <img
            src={marinaLogo}
            alt="MARINA Logo"
            style={{ height: '80px', width: 'auto', objectFit: 'contain' }}
          />
          <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
            <p style={{ fontSize: '13px', fontWeight: 'bold', lineHeight: 1.55, margin: '0 0 4px 0' }}>
              REPUBLIC OF THE PHILIPPINES
            </p>
            <p style={{ fontSize: '13px', fontWeight: 'bold', lineHeight: 1.55, margin: '0 0 4px 0' }}>
              DEPARTMENT OF TRANSPORTATION
            </p>
            <p style={{ fontSize: '13px', fontWeight: 'bold', lineHeight: 1.55, margin: 0 }}>
              MARITIME INDUSTRY AUTHORITY
            </p>
          </div>
        </div>

        {/* TITLE */}
        <div
          style={{
            textAlign: 'center',
            fontSize: '14px',
            fontWeight: 'bold',
            marginBottom: '14px',
            textDecoration: 'underline',
            letterSpacing: '0.02em',
          }}
        >
          NOTICE OF DELIVERY
        </div>

        {/* META FIELDS */}
        <div style={{ border: '1px solid #000', marginBottom: '16px' }}>
          {/* Row 1: Supplier */}
          <div style={{ display: 'flex', borderBottom: '1px solid #000' }}>
            <div style={{ padding: '3px 6px', fontWeight: 'bold', minWidth: '70px' }}>Supplier</div>
            <div style={{ padding: '3px 2px', minWidth: '10px' }}>:</div>
            <div style={{ flex: 1, padding: '3px 6px', borderLeft: '1px solid #000', minHeight: '22px' }}>
              {supplier}
            </div>
          </div>
          {/* Row 2: PR No. | PR Date */}
          <div style={{ display: 'flex', borderBottom: '1px solid #000' }}>
            <div style={{ padding: '3px 6px', fontWeight: 'bold', minWidth: '70px' }}>PR No.</div>
            <div style={{ padding: '3px 2px', minWidth: '10px' }}>:</div>
            <div style={{ flex: 1, padding: '3px 6px', borderLeft: '1px solid #000', minHeight: '22px' }}>
              {prNo}
            </div>
            <div style={{ padding: '3px 6px', fontWeight: 'bold', borderLeft: '1px solid #000', minWidth: '70px' }}>
              PR Date
            </div>
            <div style={{ padding: '3px 2px', minWidth: '10px' }}>:</div>
            <div
              style={{
                padding: '3px 6px',
                borderLeft: '1px solid #000',
                minHeight: '22px',
                minWidth: '140px',
              }}
            >
              {fmtDate(prDate)}
            </div>
          </div>
          {/* Row 3: SI No. | DR No. */}
          <div style={{ display: 'flex' }}>
            <div style={{ padding: '3px 6px', fontWeight: 'bold', minWidth: '70px' }}>SI No.</div>
            <div style={{ padding: '3px 2px', minWidth: '10px' }}>:</div>
            <div style={{ flex: 1, padding: '3px 6px', borderLeft: '1px solid #000', minHeight: '22px' }}>
              {siNo}
            </div>
            <div style={{ padding: '3px 6px', fontWeight: 'bold', borderLeft: '1px solid #000', minWidth: '70px' }}>
              DR No.
            </div>
            <div style={{ padding: '3px 2px', minWidth: '10px' }}>:</div>
            <div
              style={{
                padding: '3px 6px',
                borderLeft: '1px solid #000',
                minHeight: '22px',
                minWidth: '140px',
              }}
            >
              {drNo}
            </div>
          </div>
        </div>

        {/* TABLE */}
        <table
          style={{
            width: '100%',
            borderCollapse: 'collapse',
            border: '1px solid #000',
            marginBottom: '28px',
          }}
        >
          <thead>
            <tr>
              <th style={{ border: '1px solid #000', padding: '4px 6px', textAlign: 'center', width: '13%' }}>
                Date
              </th>
              <th style={{ border: '1px solid #000', padding: '4px 6px', textAlign: 'center', width: '37%' }}>
                Particular
              </th>
              <th style={{ border: '1px solid #000', padding: '4px 6px', textAlign: 'center', width: '10%' }}>
                Unit
              </th>
              <th style={{ border: '1px solid #000', padding: '4px 6px', textAlign: 'center', width: '10%' }}>
                Qty
              </th>
              <th style={{ border: '1px solid #000', padding: '4px 6px', textAlign: 'center', width: '15%' }}>
                Unit Cost
              </th>
              <th style={{ border: '1px solid #000', padding: '4px 6px', textAlign: 'center', width: '15%' }}>
                Amount
              </th>
            </tr>
          </thead>
          <tbody>
            {displayRows.map((item, idx) => (
              <tr key={idx} style={{ height: '22px' }}>
                <td style={{ border: '1px solid #000', padding: '1px 3px', fontSize: '11px' }}>
                  {item ? fmtDate(deliveryDate) : ''}
                </td>
                <td style={{ border: '1px solid #000', padding: '1px 3px', fontSize: '11px' }}>
                  {item ? item.particular : ''}
                </td>
                <td style={{ border: '1px solid #000', padding: '1px 3px', fontSize: '11px', textAlign: 'center' }}>
                  {item ? item.unit : ''}
                </td>
                <td style={{ border: '1px solid #000', padding: '1px 3px', fontSize: '11px', textAlign: 'center' }}>
                  {item ? item.quantity : ''}
                </td>
                <td style={{ border: '1px solid #000', padding: '1px 3px', fontSize: '11px', textAlign: 'right' }}>
                  {item ? fmt(item.unitCost) : ''}
                </td>
                <td style={{ border: '1px solid #000', padding: '1px 3px', fontSize: '11px', textAlign: 'right' }}>
                  {item ? fmt(item.quantity * item.unitCost) : ''}
                </td>
              </tr>
            ))}
            {/* Grand Total Row */}
            <tr style={{ fontWeight: 'bold' }}>
              <td colSpan="4" style={{ border: '1px solid #000', padding: '1px 3px', textAlign: 'right' }}>
                GRAND TOTAL =
              </td>
              <td style={{ border: '1px solid #000', padding: '1px 3px', textAlign: 'right' }}>
                {fmt(grandTotal)}
              </td>
            </tr>
          </tbody>
        </table>

        {/* SIGNATURES */}
        <div style={{ display: 'flex', justifyContent: 'space-between', gap: '40px', paddingTop: '20px' }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '2px' }}>
            <p style={{ fontSize: '12px', marginBottom: '36px', margin: 0 }}>Prepared by:</p>
            <p style={{ fontSize: '12px', fontWeight: 'bold', margin: 0 }}>{preparedBy || '_'.repeat(30)}</p>
            <p style={{ fontSize: '12px', margin: 0 }}>{name}</p>
            <p style={{ fontSize: '12px', margin: 0 }}>{designation}</p>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '2px' }}>
            <p style={{ fontSize: '12px', marginBottom: '36px', margin: 0 }}>Noted by:</p>
            <p style={{ fontSize: '12px', fontWeight: 'bold', margin: 0 }}>{notedBy || '_'.repeat(30)}</p>
            <p style={{ fontSize: '12px', margin: 0 }}>Chief Admin Officer</p>
            <p style={{ fontSize: '12px', margin: 0 }}>General Services Division</p>
          </div>
        </div>
      </div>

      {/* Action Buttons */}
      <div style={{ display: 'flex', justifyContent: 'space-between', gap: '8px', marginTop: '20px' }}>
        <button
          type="button"
          style={{
            padding: '8px 16px',
            fontSize: '12px',
            backgroundColor: '#f0f0f0',
            border: '1px solid #ccc',
            borderRadius: '4px',
            cursor: 'pointer',
          }}
          onClick={onBack}
        >
          ← Back
        </button>
        <button
          type="button"
          style={{
            padding: '8px 16px',
            fontSize: '12px',
            backgroundColor: '#1a52d4',
            color: '#fff',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer',
          }}
          onClick={onConfirm}
        >
          Confirm & Continue →
        </button>
      </div>
    </div>
  );
}

export default NoticeOfDeliveryPreview;
