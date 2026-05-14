import { useEffect } from "react";
import API_BASE_URL from "./config/api";

function Connect() {
  useEffect(() => {
    const connectToDatabase = async () => {
      try {
        const response = await fetch(`${API_BASE_URL}/connect.php`, {
          credentials: 'include',
          headers: { 'Content-Type': 'application/json' }
        });
        const data = await response.json();
        console.log("Database response:", data);
      } catch (error) {
        console.error("Error connecting to database:", error);
      }
    };

    connectToDatabase();
  }, []);

  return <></>;
}

export default Connect;
