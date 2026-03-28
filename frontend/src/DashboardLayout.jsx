import Header from './Header';
import styles from './css/DashboardLayout.module.css';

function DashboardLayout({ children }) {
  return (
    <div className={styles.mainContent}>
      <Header />
      <main className={styles.contentArea}>
        {children}
      </main>
    </div>
  );
}

export default DashboardLayout;
