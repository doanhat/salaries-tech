import React, { useEffect, useState } from "react";
import { useSearchParams } from "react-router-dom";
import { Alert, Container, Spinner } from "react-bootstrap";
import { verifyEmail } from "../utils/api";
import { useLanguage } from "../contexts/LanguageContext";

const translations = {
  fr: {
    success: "Votre email a été vérifié avec succès !",
    verifying: "Vérification de votre email...",
    error:
      "La vérification de l'email a échoué. Le lien peut être expiré ou invalide.",
  },
  en: {
    success: "Your email has been verified successfully!",
    verifying: "Verifying your email...",
    error: "Failed to verify email. The link may be expired or invalid.",
  },
};
const EmailVerificationPage = () => {
  const [searchParams] = useSearchParams();
  const token = searchParams.get("token");
  const [status, setStatus] = useState("verifying");
  const { language } = useLanguage();
  const t = translations[language];

  useEffect(() => {
    const verify = async () => {
      try {
        if (!token) {
          setStatus("error");
          return;
        }
        await verifyEmail(token);
        setStatus("success");
      } catch (error) {
        console.error("Verification error:", error);
        setStatus("error");
      }
    };
    verify();
  }, [token]);

  return (
    <Container className="mt-5">
      {status === "verifying" && (
        <div className="text-center">
          <Spinner animation="border" />
          <p>{t.verifying}</p>
        </div>
      )}
      {status === "success" && <Alert variant="success">{t.success}</Alert>}
      {status === "error" && <Alert variant="danger">{t.error}</Alert>}
    </Container>
  );
};

export default EmailVerificationPage;