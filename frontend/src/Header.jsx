import { useNavigate } from "react-router-dom";
import styles from "./css/Header.module.css";

function Header() {
  const navigate = useNavigate();
  const username = sessionStorage.getItem("username") || "User";
  const roleName = sessionStorage.getItem("role_name") || "Guest";

  const handleLogout = () => {
    sessionStorage.clear();
    navigate("/");
  };

  return (
    <header className={styles.headerContainer} role="banner">
      <div className={styles.headerContent}>
        {/* Brand Section */}
        <div className={styles.brandSection}>
          <span className={styles.brandIcon} aria-hidden="true">📦</span>
          <h1 className={styles.title}>Inventory Custodian System</h1>
        </div>

        {/* User Section with Profile & Logout */}
        <div className={styles.userSection} role="region" aria-label="User profile">
          <div className={styles.userInfo}>
            {/* User Avatar */}
            <div className={styles.avatarWrap} title={`User avatar - ${username}`}>
              <div className={styles.avatar} aria-label={`User ${username}`}>
                {username.charAt(0).toUpperCase()}
              </div>
            </div>
            
            {/* User Details */}
            <div className={styles.userDetails}>
              <p className={styles.userName}>{username}</p>
              <p className={styles.userRole}>{roleName}</p>
            </div>
          </div>

          {/* Logout Button */}
          <button 
            className={styles.logoutBtn} 
            onClick={handleLogout} 
            title="Sign out from your account"
            aria-label="Sign out"
          >
            <span className={styles.logoutLabel}>Logout</span>
            <span className={styles.logoutArrow} aria-hidden="true">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                stroke="currentColor" strokeWidth="2.2"
                strokeLinecap="round" strokeLinejoin="round">
                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
                <polyline points="16 17 21 12 16 7"/>
                <line x1="21" y1="12" x2="9" y2="12"/>
              </svg>
            </span>
          </button>
        </div>
      </div>
    </header>
  );
}

export default Header;
