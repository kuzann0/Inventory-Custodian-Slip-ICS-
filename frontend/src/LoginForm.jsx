import { useState } from "react";
import { useNavigate } from "react-router-dom";
import styles from "./css/LoginForm.module.css";

function LoginForm() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const navigate = useNavigate();

  const handleLogin = (e) => {
    e.preventDefault();
    // For now, skip backend check
    if (username === "admin" && password === "password123") {
      navigate("/entry"); // redirect to EntryForm
    } else {
      alert("Invalid credentials");
    }
  };

  return (
    
   <center> 
    {/* <img src="./src/assets/imgOne.png" alt="Image" /> */}
    
    <div className={styles.mainContainer}>
      <div className={styles.imgContainer}></div>
      <div className={styles.loginPanel}>
        
          <form onSubmit={handleLogin} style={ { maxWidth: "300px" } }>
              
              <h2 className={styles.loginHeader}>Sign in</h2>

              <input 
                type="text"
                placeholder="Username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
              /><br />
              <input
                type="password"
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              /><br />
              <button type="submit" className={styles.submitBtn}>Login</button>
              
            </form>
      </div>
    </div>
    </center>
  );
}

export default LoginForm;