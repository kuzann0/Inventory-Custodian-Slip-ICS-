import Header from './Header';
import styles from './css/DashboardLayout.module.css';

function DashboardLayout({ children, navbarCollapsed = false }) {
  return (
    <div className={`${styles.mainContent} ${navbarCollapsed ? styles.collapsed : ''}`}>
      <Header />
      <main className={styles.contentArea}>
        {children}
      </main>
    </div>
  );
}

export default DashboardLayout;
