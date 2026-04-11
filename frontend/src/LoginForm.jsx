import { useState } from "react";
import { useNavigate } from "react-router-dom";
import styles from "./css/LoginForm.module.css";
import API_BASE_URL from "./config/api";

function LoginForm() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      // Authenticate with backend
      const loginResponse = await fetch(`${API_BASE_URL}/login.php`, {
        method: "POST",
        credentials: 'include',
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ 
          username: username, 
          password: password 
        })
      });

      const loginData = await loginResponse.json();

      if (loginData.status !== 'success') {
        setError(loginData.message || "Login failed");
        setLoading(false);
        return;
      }

      // Store authentication data
      sessionStorage.setItem('session_token', loginData.token);
      sessionStorage.setItem('verified_email', loginData.user.email);
      sessionStorage.setItem('user_id', loginData.user.id);
      sessionStorage.setItem('username', loginData.user.username);
      sessionStorage.setItem('role_id', loginData.user.role_id);
      sessionStorage.setItem('role_name', loginData.user.role_name);
      
      // Store permissions if available
      if (loginData.user.permissions) {
        sessionStorage.setItem('permissions', JSON.stringify(loginData.user.permissions));
      }

      // Smart redirection based on role_id
      // role_id = 1: SuperAdmin → /superadmin
      // role_id = 2 or 3: Admin/Employee → /dashboard
      setTimeout(() => {
        if (loginData.user.role_id === 1) {
          console.log("SuperAdmin detected - redirecting to /superadmin");
          navigate("/superadmin");
        } else {
          console.log(`${loginData.user.role_name} detected - redirecting to /dashboard`);
          navigate("/dashboard");
        }
      }, 300);
    } catch (err) {
      setError("Network error. Please try again.");
      console.error("Login error:", err);
    } finally {
      setLoading(false);
    }
  };

  const handleAdminBypass = async () => {
    const bypassKey = prompt("Enter admin bypass key:");
    if (!bypassKey) return;

    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/admin_bypass.php`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          admin_key: bypassKey,
          email: "admin@ics-system.local",
          reason: "Admin testing"
        })
      });

      const data = await response.json();

      if (data.success) {
        sessionStorage.setItem("session_token", data.session_token);
        sessionStorage.setItem("verified_email", data.email);
        navigate("/entry");
      } else {
        setError("Invalid admin key");
      }
    } catch (err) {
      setError("Error with admin bypass");
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={styles.loginWrapper}>
      <div className={styles.mainContainer}>
        <div className={styles.imgContainer}></div>
        <div className={styles.loginPanel}>
          <form onSubmit={handleLogin}>
              
              <h2 className={styles.loginHeader}>Sign in</h2>

              {error && (
                <div style={{
                  color: "#dc3545",
                  padding: "10px",
                  marginBottom: "10px",
                  border: "1px solid #f5c6cb",
                  borderRadius: "4px",
                  backgroundColor: "#f8d7da",
                  fontSize: "13px"
                }}>
                  {error}
                </div>
              )}

              <input 
                type="text"
                placeholder="Username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                disabled={loading}
                required
              /><br />
              <input
                type="password"
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                disabled={loading}
                required
              /><br />
              <button 
                type="submit" 
                className={styles.submitBtn}
                disabled={loading}
              >
                {loading ? "Logging in..." : "Login"}
              </button>

              {/* Admin Bypass (Hidden - only visible in console/dev mode) */}
              {import.meta.env.DEV && (
                <button
                  type="button"
                  onClick={handleAdminBypass}
                  style={{
                    marginTop: "10px",
                    padding: "8px 12px",
                    fontSize: "12px",
                    backgroundColor: "#f0f0f0",
                    border: "1px solid #ccc",
                    borderRadius: "4px",
                    cursor: "pointer",
                    width: "100%"
                  }}
                >
                  [DEV] Admin Bypass
                </button>
              )}
            </form>
        </div>
      </div>
    </div>
  );
}

export default LoginForm;