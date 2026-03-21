import { useState } from "react";
import { useNavigate } from "react-router-dom";

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
      <form onSubmit={handleLogin} style={{ maxWidth: "300px" }}>
        <h2>Login</h2>
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
        <button type="submit">Login</button>
      </form>
    </center>
  );
}

export default LoginForm;