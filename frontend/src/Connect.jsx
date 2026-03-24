import { useEffect } from "react";

function Connect() {
  useEffect(() => {
    const connectToDatabase = async () => {
      try {
        const response = await fetch("/api/connect.php");
        const data = await response.json();
        console.log("Database response:", data);
      } catch (error) {
        console.error("Error connecting to database:", error);
      }
    };

    connectToDatabase();
  }, []);

  return<></>;
}

export default Connect;
