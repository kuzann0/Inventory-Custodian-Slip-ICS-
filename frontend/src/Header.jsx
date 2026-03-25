import styles from "./css/Header.module.css";

function Header() {
    return (
        <>
        <div className={styles.headerContainer}>
            <div className={styles.globalStyle}>
                <h1>Inventory Custodian Slip</h1>
            </div>
        </div>
        </>
    )
}

export default Header;