import { BrowserRouter as Router, Routes, Route, Navigate } from "react-router-dom";
import { useState, useEffect } from "react";
import EntryForm from "./EntryForm";
import ViewEntries from "./ViewEntries";
import LoginForm from "./LoginForm";
import SuperAdminPage from "./SuperAdminPage";
import EmployeeCapabilities from "./EmployeeCapabilities";
import Connect from "./Connect";
import Navbar from "./Navbar";
import PanelContent from "./PanelContent";
import DashboardLayout from "./DashboardLayout";
import PurchaseRequest from "./PurchaseRequest";
import NewPurchaseRequest from "./NewPurchaseRequest";
import InspectionAssignment from "./InspectionAssignment";
import DocumentManagement from "./DocumentManagement";
import ProcessStatus from "./ProcessStatus";
import PropertyInventoryTag from "./PropertyInventoryTag";

// Protected Route Component
function ProtectedRoute({ children }) {
  const [isAuthorized, setIsAuthorized] = useState(null);

  useEffect(() => {
    // Check if user has valid session token
    const sessionToken = sessionStorage.getItem('session_token');
    const verifiedEmail = sessionStorage.getItem('verified_email');

    if (sessionToken && verifiedEmail) {
      setIsAuthorized(true);
    } else {
      setIsAuthorized(false);
    }
  }, []);

  if (isAuthorized === null) {
    return <div>Loading...</div>;
  }

  return isAuthorized ? children : <Navigate to="/" replace />;
}

// SuperAdmin Protected Route Component (role_id = 1)
function SuperAdminRoute({ children }) {
  const [isSuperAdmin, setIsSuperAdmin] = useState(null);

  useEffect(() => {
    // Check if user has SuperAdmin role (role_id = 1)
    const roleId = parseInt(sessionStorage.getItem('role_id'), 10);
    const sessionToken = sessionStorage.getItem('session_token');

    if (sessionToken && roleId === 1) {
      setIsSuperAdmin(true);
    } else {
      setIsSuperAdmin(false);
    }
  }, []);

  if (isSuperAdmin === null) {
    return <div>Loading...</div>;
  }

  if (!isSuperAdmin) {
    console.warn('Access denied: User role_id is not 1 (SuperAdmin only)');
    return <Navigate to="/dashboard" replace />;
  }

  return children;
}

// Admin Protected Route Component (role_id = 2)
function AdminRoute({ children }) {
  const [isAdmin, setIsAdmin] = useState(null);

  useEffect(() => {
    // Check if user is Admin (role_id = 2)
    const roleId = parseInt(sessionStorage.getItem('role_id'), 10);
    const sessionToken = sessionStorage.getItem('session_token');

    if (sessionToken && roleId === 2) {
      setIsAdmin(true);
    } else {
      setIsAdmin(false);
    }
  }, []);

  if (isAdmin === null) {
    return <div>Loading...</div>;
  }

  if (!isAdmin) {
    console.warn('Access denied: Admin role required (role_id 2)');
    return <Navigate to="/dashboard" replace />;
  }

  return children;
}

// Employee Protected Route Component (role_id = 3)
function EmployeeRoute({ children }) {
  const [isEmployee, setIsEmployee] = useState(null);

  useEffect(() => {
    // Check if user is Employee (role_id = 3)
    const roleId = parseInt(sessionStorage.getItem('role_id'), 10);
    const sessionToken = sessionStorage.getItem('session_token');

    if (sessionToken && roleId === 3) {
      setIsEmployee(true);
    } else {
      setIsEmployee(false);
    }
  }, []);

  if (isEmployee === null) {
    return <div>Loading...</div>;
  }

  if (!isEmployee) {
    console.warn('Access denied: Employee role required (role_id 3)');
    return <Navigate to="/dashboard" replace />;
  }

  return children;
}

function App() {
  const [activePanel, setActivePanel] = useState("dashboard");
  const [navbarCollapsed, setNavbarCollapsed] = useState(false);

  return (
    <>
      <Connect /> {/* first thing react will read, to test connection */}
      <Router>
        <Routes>
          {/* Login page */}
          <Route path="/" element={<LoginForm />} />

          {/* Protected dashboard - requires valid session */}
          <Route
            path="/dashboard"
            element={
              <ProtectedRoute>
                <div style={{ display: 'flex', minHeight: '100vh', backgroundColor: '#f5f7fa' }}>
                  <Navbar activePanel={activePanel} setActivePanel={setActivePanel} collapsed={navbarCollapsed} setCollapsed={setNavbarCollapsed} />
                  <PanelContent activePanel={activePanel} setActivePanel={setActivePanel} navbarCollapsed={navbarCollapsed} />
                </div>
              </ProtectedRoute>
            }
          />

          {/* New Purchase Request Modal - shows modal on dedicated page */}
          <Route
            path="/new-purchase-request"
            element={
              <ProtectedRoute>
                <NewPurchaseRequest />
              </ProtectedRoute>
            }
          />

          {/* Purchase Request page - Dedicated standalone page */}
          <Route
            path="/purchase-request"
            element={
              <ProtectedRoute>
                <PurchaseRequest />
              </ProtectedRoute>
            }
          />

          {/* SuperAdmin page - only for SuperAdmin users */}
          <Route
            path="/superadmin"
            element={
              <ProtectedRoute>
                <SuperAdminRoute>
                  <SuperAdminPage />
                </SuperAdminRoute>
              </ProtectedRoute>
            }
          />

          {/* Employee View Capabilities - Employee only */}
          <Route
            path="/my-capabilities"
            element={
              <ProtectedRoute>
                <EmployeeRoute>
                  <div style={{ display: 'flex', minHeight: '100vh', backgroundColor: '#f5f7fa' }}>
                    <Navbar collapsed={navbarCollapsed} setCollapsed={setNavbarCollapsed} />
                    <DashboardLayout navbarCollapsed={navbarCollapsed}>
                      <EmployeeCapabilities />
                    </DashboardLayout>
                  </div>
                </EmployeeRoute>
              </ProtectedRoute>
            }
          />

          {/* Inventory Form - ICS (Amount < 50,000) */}
          <Route
            path="/inventory-form-ics"
            element={
              <ProtectedRoute>
                <div style={{ display: 'flex', minHeight: '100vh', backgroundColor: '#f5f7fa' }}>
                  <Navbar collapsed={navbarCollapsed} setCollapsed={setNavbarCollapsed} />
                  <DashboardLayout navbarCollapsed={navbarCollapsed}>
                    <div style={{ padding: '20px' }}>
                      <h2>Inventory Form - ICS (LESS: ₱ &lt; 50,000)</h2>
                      <p>LESS: ICS Inventory form for items under ₱50,000</p>
                      <p style={{ color: '#666', fontSize: '14px' }}>Coming soon: Complete ICS form implementation</p>
                    </div>
                  </DashboardLayout>
                </div>
              </ProtectedRoute>
            }
          />

          {/* Inventory Form - PPE (Amount ≥ 50,000) */}
          <Route
            path="/inventory-form-ppe"
            element={
              <ProtectedRoute>
                <div style={{ display: 'flex', minHeight: '100vh', backgroundColor: '#f5f7fa' }}>
                  <Navbar collapsed={navbarCollapsed} setCollapsed={setNavbarCollapsed} />
                  <DashboardLayout navbarCollapsed={navbarCollapsed}>
                    <div style={{ padding: '20px' }}>
                      <h2>Inventory Form - PPE (ABOVE: PAR ₱ ≥ 50,000)</h2>
                      <p>PPE Inventory form for fixed assets (₱50,000 and above)</p>
                      <p style={{ color: '#666', fontSize: '14px' }}>Coming soon: Complete PPE form implementation</p>
                    </div>
                  </DashboardLayout>
                </div>
              </ProtectedRoute>
            }
          />

          {/* Property Inventory Tag */}
          <Route
            path="/property-inventory-tag"
            element={
              <ProtectedRoute>
                <div style={{ display: 'flex', minHeight: '100vh', backgroundColor: '#f5f7fa' }}>
                  <Navbar collapsed={navbarCollapsed} setCollapsed={setNavbarCollapsed} />
                  <DashboardLayout navbarCollapsed={navbarCollapsed}>
                    <PropertyInventoryTag />
                  </DashboardLayout>
                </div>
              </ProtectedRoute>
            }
          />

          {/* Inspection & Assignment */}
          <Route
            path="/inspection-assignment"
            element={
              <ProtectedRoute>
                <div style={{ display: 'flex', minHeight: '100vh', backgroundColor: '#f5f7fa' }}>
                  <Navbar collapsed={navbarCollapsed} setCollapsed={setNavbarCollapsed} />
                  <DashboardLayout navbarCollapsed={navbarCollapsed}>
                    <InspectionAssignment />
                  </DashboardLayout>
                </div>
              </ProtectedRoute>
            }
          />

          {/* Document Management */}
          <Route
            path="/documents"
            element={
              <ProtectedRoute>
                <div style={{ display: 'flex', minHeight: '100vh', backgroundColor: '#f5f7fa' }}>
                  <Navbar collapsed={navbarCollapsed} setCollapsed={setNavbarCollapsed} />
                  <DashboardLayout navbarCollapsed={navbarCollapsed}>
                    <DocumentManagement />
                  </DashboardLayout>
                </div>
              </ProtectedRoute>
            }
          />

          {/* Process Status Tracking */}
          <Route
            path="/process-status"
            element={
              <ProtectedRoute>
                <div style={{ display: 'flex', minHeight: '100vh', backgroundColor: '#f5f7fa' }}>
                  <Navbar collapsed={navbarCollapsed} setCollapsed={setNavbarCollapsed} />
                  <DashboardLayout navbarCollapsed={navbarCollapsed}>
                    <ProcessStatus />
                  </DashboardLayout>
                </div>
              </ProtectedRoute>
            }
          />

          {/* Catch all - redirect to login */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </Router>
    </>
  );
}

export default App;