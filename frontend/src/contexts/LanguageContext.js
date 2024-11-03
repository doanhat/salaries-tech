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
    header: {
      brand: "Salary Tech",
      inspiredBy: "Inspiré par",
      languages: {
        current: "Français",
        options: {
          en: "English",
          fr: "Français",
        },
      },
      github: "GitHub",
    },
    dashboard: {
      location_pie_chart: {
        title: "Distribution des Salaires par Localisation",
        total: "Total",
      },
      top_locations_bar_chart: {
        title: "Top 10 des Localisations par Salaire Moyen",
        tooltip: {
          salary: "Salaire moyen",
        },
      },
    },
    entities: {
      title: {
        add_salary: "Ajouter une salaire",
        filters: "Filtres",
      },
      company: {
        name: {
          singular: "Entreprise",
          plural: "Entreprises",
          placeholder: "Sélectionner ou taper pour ajouter une entreprise",
        },
        type: {
          singular: "Type d'entreprise",
          plural: "Types d'entreprises",
        },
        tags: {
          singular: "Tag d'entreprise",
          plural: "Tags d'entreprise",
          placeholder: "Sélectionner ou taper pour ajouter un tag d'entreprise",
        },
      },
      job: {
        titles: {
          singular: "Poste",
          plural: "Postes",
          placeholder: "Sélectionner ou taper pour ajouter un poste",
          selected: "Postes sélectionnés",
        },
      },
      location: {
        singular: "Localisation",
        plural: "Localisations",
        placeholder: "Sélectionner ou taper pour ajouter une localisation",
      },
      net_salary: {
        singular: "Salaire Net",
        min: "Salaire Net Min",
        max: "Salaire Net Max",
      },
      gross_salary: {
        singular: "Salaire Brut",
        min: "Salaire Brut Min",
        max: "Salaire Brut Max",
      },
      bonus: {
        singular: "Prime",
        min: "Prime Min",
        max: "Prime Max",
      },
      gender: {
        singular: "Genre",
        plural: "Genres",
        value: {
          male: "Homme",
          female: "Femme",
          other: "Autre",
        },
      },
      level: {
        singular: "Niveau",
        plural: "Niveaux",
      },
      experience_years_company: {
        singular: "Exp Entreprise",
        min: "Exp Entreprise Min",
        max: "Exp Entreprise Max",
      },
      total_experience_years: {
        singular: "Exp Totale",
        min: "Exp Totale Min",
        max: "Exp Totale Max",
      },
      work_type: {
        singular: "Type de contrat",
        plural: "Types de contrat",
      },
      leave_days: {
        singular: "Jours de congé",
        min: "Jours de congé Min",
        max: "Jours de congé Max",
      },
      technical_stacks: {
        singular: "Stack technique",
        plural: "Stacks techniques",
        placeholder: "Sélectionner ou taper pour ajouter un stack technique",
      },
      professional_email: {
        singular: "Email Professionnel",
        help: "Veuillez entrer un email professionnel si vous souhaitez que votre salaire soit vérifié",
      },
      added_date: {
        singular: "Date d'ajout",
        min: "Date d'ajout Min",
        max: "Date d'ajout Max",
      },
      actions: {
        name: "Actions",
        title: "Détails",
      },
      verification: {
        singular: "Vérification",
        plural: "Vérifications",
        value: {
          no: "Non vérifié",
          pending: "En attente",
          verified: "Vérifié",
        },
      },
      email_body: {
        subject: "Vérifier votre soumission de salaire",
        greeting_text:
          "Merci pour votre soumission de salaire. Veuillez vérifier votre adresse email en cliquant sur le bouton ci-dessous:",
        verify_button_text: "Vérifier mon email",
        expiration_text: "Ce lien de vérification expirera dans 7 jours.",
      },
      buttons: {
        submit: "Ajouter",
        add_salary: "Ajouter un salaire",
        filters: "Filtres",
        apply_filters: "Appliquer les filtres",
        reset_filters: "Réinitialiser les filtres",
        show_charts: {
          on: "Afficher les graphiques",
          off: "Masquer les graphiques",
        },
        close: "Fermer",
        pagination: {
          show: "Afficher",
        },
      },
      errors: {
        captcha: "Veuillez compléter le reCAPTCHA",
        location: "Localisation est requis",
        gross_salary: "Salaire brut est requis",
        job_titles: "Au moins un poste est requis",
        job_titles_max: "Vous pouvez sélectionner jusqu'à 2 postes",
        company_type:
          "Type d'entreprise est requis pour les nouvelles entreprises",
        invalid_common_domain:
          "Veuillez utiliser un email professionnel. Les emails personnels ne sont pas acceptés.",
        invalid_company_name_required:
          "Veuillez renseigner une entreprise pour vérifier votre email",
        invalid_company_email_similarity:
          "Email professionnel invalide de la vérification de similarité",
        exists: "Cette {field} existe déjà",
        submit: "Erreur lors de l'ajout du salaire. Veuillez réessayer.",
        no_salaries: "Aucun salaire trouvé.",
        negative_value: "La valeur ne peut pas être négative",
        net_salary_exceeds_gross:
          "Le salaire net doit être inférieur au salaire brut",
        company_experience_exceeds_total:
          "L'expérience dans l'entreprise ne peut pas dépasser l'expérience totale",
        leave_days_exceed_year:
          "Les jours de congé ne peuvent pas dépasser 365 jours",
      },
      info: {
        select: "Sélectionner",
        add: "Ajouter",
        no_filters_applied: "Aucun filtre appliqué.",
        loading: "Chargement des données...",
        add_salary_success: "Salaire ajouté avec succès !",
        add_salary_success_email:
          "Salaire ajouté avec succès ! Veuillez vérifier votre email pour la vérification. Il peut prendre quelques heures pour arriver. (J'utilise un plan gratuit donc ça peut être lent :( )",
      },
    },
    email_verification_page: {
      success: "Votre email a été vérifié avec succès !",
      verifying: "Vérification de votre email...",
      error:
        "Erreur lors de la vérification de l'email. Le lien peut être expiré ou invalide.",
    },
  },
  en: {
    header: {
      brand: "Salary Tech",
      inspiredBy: "Inspiré par",
      languages: {
        current: "English",
        options: {
          en: "English",
          fr: "Français",
        },
      },
      github: "GitHub",
    },
    dashboard: {
      location_pie_chart: {
        title: "Salary Distribution by Location",
        total: "Total",
      },
      top_locations_bar_chart: {
        title: "Top 10 Locations by Average Salary",
        tooltip: {
          salary: "Average Salary",
        },
      },
    },
    entities: {
      title: {
        add_salary: "Add a salary",
        filters: "Filters",
      },
      company: {
        name: {
          singular: "Company",
          plural: "Companies",
          placeholder: "Select or type to add a company",
        },
        type: {
          singular: "Company Type",
          plural: "Company Types",
        },
        tags: {
          singular: "Company Tag",
          plural: "Company Tags",
          placeholder: "Select or type to add a company tag",
        },
      },
      job: {
        titles: {
          singular: "Job Title",
          plural: "Job Titles",
          placeholder: "Select or type to add a job title",
          selected: "Selected Job Titles",
        },
      },
      location: {
        singular: "Location",
        plural: "Locations",
        placeholder: "Select or type to add a location",
      },
      net_salary: {
        singular: "Net Salary",
        min: "Net Salary Min",
        max: "Net Salary Max",
      },
      gross_salary: {
        singular: "Gross Salary",
        min: "Gross Salary Min",
        max: "Gross Salary Max",
      },
      bonus: {
        singular: "Bonus",
        min: "Bonus Min",
        max: "Bonus Max",
      },
      gender: {
        singular: "Gender",
        plural: "Genders",
        value: {
          male: "Male",
          female: "Female",
          other: "Other",
        },
      },
      level: {
        singular: "Level",
        plural: "Levels",
      },
      experience_years_company: {
        singular: "Company Exp",
        min: "Company Exp Min",
        max: "Company Exp Max",
      },
      total_experience_years: {
        singular: "Total Exp",
        min: "Total Exp Min",
        max: "Total Exp Max",
      },
      work_type: {
        singular: "Work Type",
        plural: "Work Types",
      },
      leave_days: {
        singular: "Leave Days",
        min: "Leave Days Min",
        max: "Leave Days Max",
      },
      technical_stacks: {
        singular: "Technical Stack",
        plural: "Technical Stacks",
        placeholder: "Select or type to add a technical stack",
      },
      professional_email: {
        singular: "Professional Email",
        help: "Please enter a professional email if you want your salary to be verified",
      },
      added_date: {
        singular: "Added Date",
        min: "Added Date Min",
        max: "Added Date Max",
      },
      actions: {
        name: "Actions",
        title: "Details",
      },
      verification: {
        singular: "Verification",
        plural: "Verifications",
        value: {
          no: "Not Verified",
          pending: "Pending",
          verified: "Verified",
        },
      },
      email_body: {
        subject: "Verify your salary submission",
        greeting_text:
          "Thank you for submitting your salary. Please verify your email by clicking the button below:",
        verify_button_text: "Verify my email",
        expiration_text: "This verification link will expire in 7 days.",
      },
      buttons: {
        submit: "Add",
        add_salary: "Add a salary",
        filters: "Filters",
        apply_filters: "Apply filters",
        reset_filters: "Reset filters",
        show_charts: {
          on: "Show charts",
          off: "Hide charts",
        },
        close: "Close",
        pagination: {
          show: "Show",
        },
      },
      errors: {
        captcha: "Please complete the reCAPTCHA",
        location: "Location is required",
        gross_salary: "Gross salary is required",
        job_titles: "At least one job title is required",
        job_titles_max: "You can select up to 2 job titles",
        company_type: "Company type is required for new companies",
        invalid_common_domain:
          "Please use a professional email. Personal emails are not accepted.",
        invalid_company_name_required:
          "Please enter a company to verify your email",
        invalid_company_email_similarity:
          "Invalid company email from similarity check",
        exists: "{field} already exists",
        submit: "Error adding salary. Please try again.",
        no_salaries: "No salaries found.",
        negative_value: "Value cannot be negative",
        net_salary_exceeds_gross: "Net salary must be less than gross salary",
        company_experience_exceeds_total:
          "Company experience cannot exceed total experience",
        leave_days_exceed_year: "Leave days cannot exceed 365 days",
      },
      info: {
        select: "Select",
        add: "Add",
        no_filters_applied: "No filters applied.",
        loading: "Loading data...",
        add_salary_success: "Salary added successfully!",
        add_salary_success_email:
          "Salary added successfully! Please verify your email for verification. It may take a few hours to arrive. (I'm using a free plan so it might be slow :( )",
      },
      pagination: {
        of: "of",
        entries: "entries",
        per_page: "per page",
        previous: "Previous",
        next: "Next",
      },
    },
    email_verification_page: {
      success: "Your email has been verified successfully!",
      verifying: "Verifying your email...",
      error:
        "Error verifying your email. The link may have expired or been invalidated.",
    },
  },
};
