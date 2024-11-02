import React from "react";
import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import Header from "./components/layouts/Header";
import Footer from "./components/layouts/Footer";
import SalaryListPage from "./pages/SalaryListPage";
import EmailVerificationPage from "./pages/EmailVerificationPage";
import "bootstrap/dist/css/bootstrap.min.css";
import "./App.css";
import { LanguageProvider } from "./contexts/LanguageContext";

function App() {
  return (
    <LanguageProvider>
      <Router>
        <div className="App">
          <Header />
          <main>
            <Routes>
              <Route path="/" element={<SalaryListPage />} />
              <Route
                path="/salaries/verify-email"
                element={<EmailVerificationPage />}
              />
            </Routes>
          </main>
          <Footer />
        </div>
      </Router>
    </LanguageProvider>
  );
}

export default App;
