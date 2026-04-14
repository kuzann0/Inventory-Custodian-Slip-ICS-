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
    <div className={styles.headerContainer}>
      <div className={styles.headerContent}>
        <div className={styles.brandSection}>
          <h1 className={styles.title}> Inventory Custodian System</h1>
        </div>

        <div className={styles.userSection}>
          <div className={styles.userInfo}>
            <div className={styles.avatar}>{username.charAt(0).toUpperCase()}</div>
            <div className={styles.userDetails}>
              <p className={styles.userName}>{username}</p>
              <p className={styles.userRole}>{roleName}</p>
            </div>
          </div>

          <button className={styles.logoutBtn} onClick={handleLogout} title="Logout">
            Logout
          </button>
        </div>
      </div>
    </div>
  );
}

export default Header;