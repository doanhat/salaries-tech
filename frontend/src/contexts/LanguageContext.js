import React, { createContext, useState, useContext } from "react";

const LanguageContext = createContext();

export const LanguageProvider = ({ children }) => {
  const [language, setLanguage] = useState("fr"); // Default to French

  const toggleLanguage = (newLanguage) => {
    setLanguage(newLanguage);
  };

  return (
    <LanguageContext.Provider value={{ language, toggleLanguage }}>
      {children}
    </LanguageContext.Provider>
  );
};

export const useLanguage = () => useContext(LanguageContext);

export const translations = {
  fr: {
    email_body: {
      subject: "Vérifier votre soumission de salaire",
      greeting_text:
        "Merci pour votre soumission de salaire. Veuillez vérifier votre adresse email en cliquant sur le bouton ci-dessous:",
      verify_button_text: "Vérifier mon email",
      expiration_text: "Ce lien de vérification expirera dans 7 jours.",
    },
  },
  en: {
    email_body: {
      subject: "Verify your salary submission",
      greeting_text:
        "Thank you for submitting your salary information. Please verify your email address by clicking the button below:",
      verify_button_text: "Verify my email",
      expiration_text: "This verification link will expire in 7 days.",
    },
  },
};
