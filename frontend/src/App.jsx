import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import EntryForm from "./EntryForm";
import ViewEntries from "./ViewEntries";
import LoginForm from "./LoginForm"; // create this component
import "./App.css";
import Connect from "./Connect";

function App() {
  return (
    <>  
    <Connect /> {/* first thing react will read, to test connection */}
    <Router>
      <Routes>
        {/* Landing page */}
        <Route path="/" element={<LoginForm />} />

        {/* Entry page */}
        <Route
          path="/entry"
          element={
            <div>
              <center><h1>Simple ICS System</h1></center>
              <EntryForm />
              <hr />
              <ViewEntries />
            </div>
          }
        />
      </Routes>
    </Router>
    </>
  );
}

export default App;