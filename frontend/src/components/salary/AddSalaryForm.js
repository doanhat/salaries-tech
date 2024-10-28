import React, { useState, useEffect, useCallback } from "react";
import { Modal, Form, Button, Row, Col, Alert } from "react-bootstrap";
import Select from "react-select";
import CreatableSelect from "react-select/creatable";
import ReCAPTCHA from "react-google-recaptcha";
import {
  checkCompany as checkCompanyName,
  checkCompanyTag,
  checkLocation,
  checkJobTitle,
  checkTechnicalStack,
  RECAPTCHA_SITE_KEY,
} from "../../utils/api";
import { capitalizeWords } from "../../utils/stringUtils";
import { useLanguage } from "../../contexts/LanguageContext";

const initialFormData = {
  company_name: null,
  company_type: null,
  company_tags: [],
  job_titles: [],
  location: null,
  net_salary: null,
  gross_salary: null,
  variables: null,
  gender: null,
  experience_years_company: null,
  total_experience_years: null,
  level: null,
  work_type: null,
  leave_days: null,
  technical_stacks: [],
};

const translations = {
  fr: {
    title: "Ajouter un Salaire",
    company_name: "Entreprise",
    company_type: "Type d'entreprise",
    company_tags: "Tags d'entreprise",
    job_titles: "Postes",
    location: "Localisation",
    net_salary: "Salaire Net",
    gross_salary: "Salaire Brut",
    variables: "Primes",
    gender: "Genre",
    gender_value: {
      male: "Homme",
      female: "Femme",
      other: "Autre",
    },
    level: "Niveau",
    experience_years_company: "Exp Entreprise",
    total_experience_years: "Exp Totale",
    work_type: "Type de contrat",
    leave_days: "Jours de congé",
    technical_stacks: "Stacks techniques",
    button: {
      submit: "Ajouter",
    },
    placeholder: {
      select: "Sélectionner",
      company_name: "Sélectionner ou taper pour ajouter une entreprise",
      company_tags: "Sélectionner ou taper pour ajouter un tag d'entreprise",
      job_titles: "Sélectionner ou taper pour ajouter un poste",
      job_title_selected: "Postes sélectionnés",
      location: "Sélectionner ou taper pour ajouter une localisation",
      technical_stacks: "Sélectionner ou taper pour ajouter un stack technique",
    },
  },
  en: {
    title: "Add Salary",
    company_name: "Company",
    company_type: "Company Type",
    company_tags: "Company Tags",
    job_titles: "Job Titles",
    location: "Location",
    net_salary: "Net Salary",
    gross_salary: "Gross Salary",
    variables: "Variables",
    gender: "Gender",
    gender_value: {
      male: "Male",
      female: "Female",
      other: "Other",
    },
    level: "Level",
    experience_years_company: "Company Experience",
    total_experience_years: "Total Experience",
    work_type: "Work Type",
    leave_days: "Leave Days",
    technical_stacks: "Technical Stacks",
    button: {
      submit: "Add",
    },
    placeholder: {
      select: "Select",
      selected: "Selected",
      company_name: "Select or type to add a company",
      company_tags: "Select or type to add a company tag",
      job_titles: "Select or type to add a job title",
      job_title_selected: "Job titles selected",
      location: "Select or type to add a location",
      technical_stacks: "Select or type to add a technical stack",
    },
  },
};

const AddSalaryForm = ({ show, handleClose, onSalaryAdded, choices }) => {
  const { language } = useLanguage();
  const t = translations[language];
  const [formData, setFormData] = useState(initialFormData);
  const [errors, setErrors] = useState({});
  const [isNewCompany, setIsNewCompany] = useState(false);
  const [captchaToken, setCaptchaToken] = useState(null);

  useEffect(() => {
    if (show) {
      setFormData(initialFormData);
      setErrors({});
    }
  }, [show, choices.technical_stacks]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSelectChange = async (name, selectedOption) => {
    let value = selectedOption ? selectedOption.value : "";
    if (name !== "company_name") {
      value = value.toLowerCase();
    }

    if (name === "company_name") {
      setIsNewCompany(selectedOption && selectedOption.__isNew__);
    }

    if (selectedOption && selectedOption.__isNew__) {
      let exists = false;
      switch (name) {
        case "company_name":
          exists = (await checkCompanyName(value)).exists;
          break;
        case "location":
          exists = (await checkLocation(value)).exists;
          break;
        case "company_tags":
          exists = (await checkCompanyTag(value)).exists;
          break;
        default:
          console.warn(`Unexpected field name: ${name}`);
          break;
      }
      if (exists) {
        setErrors((prev) => ({
          ...prev,
          [name]: `This ${name} already exists`,
        }));
        return;
      }
    }

    setFormData((prev) => ({ ...prev, [name]: value }));
    setErrors((prev) => ({ ...prev, [name]: null }));
  };

  const handleMultiSelectChange = async (name, selectedOptions) => {
    if (name === "job_titles" && selectedOptions.length > 2) {
      setErrors((prev) => ({
        ...prev,
        [name]: "You can select up to 2 job titles",
      }));
      return;
    }

    const values = selectedOptions.map((option) => option.value);
    const lowercaseValues =
      name === "job_titles" || name === "technical_stacks"
        ? values.map((v) => v.toLowerCase())
        : values;

    const newValues = selectedOptions
      .filter((option) => option.__isNew__)
      .map((option) => option.value.toLowerCase());

    for (let value of newValues) {
      let exists = false;
      switch (name) {
        case "job_titles":
          exists = (await checkJobTitle(value)).exists;
          break;
        case "technical_stacks":
          exists = (await checkTechnicalStack(value)).exists;
          break;
        default:
          console.warn(`Unexpected field name: ${name}`);
          break;
      }
      if (exists) {
        setErrors((prev) => ({
          ...prev,
          [name]: `One or more new ${name} already exist`,
        }));
        return;
      }
    }

    setFormData((prev) => ({ ...prev, [name]: lowercaseValues }));
    setErrors((prev) => ({ ...prev, [name]: null }));
  };

  const handleReCaptchaChange = (token) => {
    setCaptchaToken(token);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!captchaToken) {
      setErrors({ ...errors, submit: "Please complete the reCAPTCHA" });
      return;
    }

    const newErrors = {};
    if (!formData.location) newErrors.location = "Location is required";
    if (!formData.gross_salary)
      newErrors.gross_salary = "Gross salary is required";
    if (!formData.job_titles || formData.job_titles.length === 0)
      newErrors.job_titles = "At least one job title is required";
    if (isNewCompany && !formData.company_type)
      newErrors.company_type = "Company type is required for new companies";
    if (
      Object.keys(newErrors).length > 0 ||
      Object.values(errors).some((error) => error !== null)
    ) {
      setErrors((prev) => ({ ...prev, ...newErrors }));
      return;
    }

    try {
      await onSalaryAdded(formData, captchaToken, navigator.userAgent);
      setFormData(initialFormData);
      setCaptchaToken(null);
      handleClose();
    } catch (error) {
      console.error("Error adding salary:", error);
      setErrors({ submit: "Failed to add salary. Please try again." });
    }
  };

  const createOption = (label, preserveCase = false) => ({
    label: preserveCase ? label : capitalizeWords(label),
    value: preserveCase ? label : label.toLowerCase(),
  });

  return (
    <Modal show={show} onHide={handleClose} size="lg">
      <Modal.Header closeButton>
        <Modal.Title>{t.title}</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <Form onSubmit={handleSubmit}>
          <Row>
            <Col md={12}>
              <Form.Group className="mb-3">
                <Form.Label>{t.company_name}</Form.Label>
                <CreatableSelect
                  isClearable
                  onChange={(option) =>
                    handleSelectChange("company_name", option)
                  }
                  options={
                    choices.company_names
                      ? choices.company_names.map((company) =>
                          createOption(company, true),
                        )
                      : []
                  }
                  value={
                    formData.company_name
                      ? createOption(formData.company_name, true)
                      : null
                  }
                  formatCreateLabel={(inputValue) => `Add "${inputValue}"`}
                  backspaceRemovesValue={true}
                  placeholder={t.placeholder.company_name}
                />
                {errors.company_name && (
                  <Form.Text className="text-danger">
                    {errors.company_name}
                  </Form.Text>
                )}
              </Form.Group>
            </Col>
          </Row>

          {isNewCompany && (
            <Row>
              <Col md={6}>
                <Form.Group className="mb-3">
                  <Form.Label>{t.company_type}</Form.Label>
                  <Select
                    isClearable
                    onChange={(option) =>
                      handleSelectChange("company_type", option)
                    }
                    options={
                      choices.company_types
                        ? choices.company_types.map(createOption)
                        : []
                    }
                    value={
                      formData.company_type
                        ? createOption(formData.company_type)
                        : null
                    }
                    placeholder={t.placeholder.select}
                  />
                </Form.Group>
              </Col>
              <Col md={6}>
                <Form.Group className="mb-3">
                  <Form.Label>{t.company_tags}</Form.Label>
                  <CreatableSelect
                    isMulti
                    isClearable
                    onChange={(selectedOptions) =>
                      handleMultiSelectChange("company_tags", selectedOptions)
                    }
                    options={
                      choices.company_tags
                        ? choices.company_tags.map((tag) => createOption(tag))
                        : []
                    }
                    value={formData.company_tags.map((tag) =>
                      createOption(tag),
                    )}
                    formatCreateLabel={(inputValue) => `Add "${inputValue}"`}
                    backspaceRemovesValue={true}
                    placeholder={t.placeholder.company_tags}
                  />
                  {errors.company_tags && (
                    <Form.Text className="text-danger">
                      {errors.company_tags}
                    </Form.Text>
                  )}
                </Form.Group>
              </Col>
            </Row>
          )}

          <Row>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>
                  {t.job_titles} <span className="text-danger">*</span>
                </Form.Label>
                <CreatableSelect
                  isMulti
                  onChange={(selectedOptions) =>
                    handleMultiSelectChange("job_titles", selectedOptions)
                  }
                  options={
                    choices.job_titles
                      ? choices.job_titles.map(createOption)
                      : []
                  }
                  value={formData.job_titles.map(createOption)}
                  isOptionDisabled={() => formData.job_titles.length >= 2}
                  placeholder={t.placeholder.job_titles}
                />
                <Form.Text className="text-muted">
                  {formData.job_titles.length}/2{" "}
                  {t.placeholder.job_title_selected}
                </Form.Text>
                {errors.job_titles && (
                  <Form.Text className="text-danger">
                    {errors.job_titles}
                  </Form.Text>
                )}
              </Form.Group>
            </Col>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>
                  {t.location} <span className="text-danger">*</span>
                </Form.Label>
                <CreatableSelect
                  isClearable
                  onChange={(option) => handleSelectChange("location", option)}
                  options={
                    choices.locations ? choices.locations.map(createOption) : []
                  }
                  value={
                    formData.location ? createOption(formData.location) : null
                  }
                  placeholder={t.placeholder.location}
                />
                {errors.location && (
                  <Form.Text className="text-danger">
                    {errors.location}
                  </Form.Text>
                )}
              </Form.Group>
            </Col>
          </Row>

          <Row>
            <Col md={4}>
              <Form.Group className="mb-3">
                <Form.Label>{t.net_salary}</Form.Label>
                <Form.Control
                  type="number"
                  name="net_salary"
                  value={formData.net_salary}
                  onChange={handleInputChange}
                />
              </Form.Group>
            </Col>
            <Col md={4}>
              <Form.Group className="mb-3">
                <Form.Label>
                  {t.gross_salary} <span className="text-danger">*</span>
                </Form.Label>
                <Form.Control
                  type="number"
                  name="gross_salary"
                  value={formData.gross_salary}
                  onChange={handleInputChange}
                  required
                />
                {errors.gross_salary && (
                  <Form.Text className="text-danger">
                    {errors.gross_salary}
                  </Form.Text>
                )}
              </Form.Group>
            </Col>
            <Col md={4}>
              <Form.Group className="mb-3">
                <Form.Label>{t.variables}</Form.Label>
                <Form.Control
                  type="number"
                  name="variables"
                  value={formData.variables}
                  onChange={handleInputChange}
                />
              </Form.Group>
            </Col>
          </Row>

          <Row>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>{t.gender}</Form.Label>
                <Select
                  isClearable
                  onChange={(option) => handleSelectChange("gender", option)}
                  options={[
                    { value: "male", label: t.gender_value.male },
                    { value: "female", label: t.gender_value.female },
                    { value: "other", label: t.gender_value.other },
                  ]}
                  value={formData.gender ? createOption(formData.gender) : null}
                  placeholder={t.placeholder.select}
                />
              </Form.Group>
            </Col>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>{t.level}</Form.Label>
                <Select
                  isClearable
                  onChange={(option) => handleSelectChange("level", option)}
                  options={
                    choices.levels ? choices.levels.map(createOption) : []
                  }
                  value={formData.level ? createOption(formData.level) : null}
                  placeholder={t.placeholder.select}
                />
              </Form.Group>
            </Col>
          </Row>

          <Row>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>{t.experience_years_company}</Form.Label>
                <Form.Control
                  type="number"
                  name="experience_years_company"
                  value={formData.experience_years_company}
                  onChange={handleInputChange}
                />
              </Form.Group>
            </Col>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>{t.total_experience_years}</Form.Label>
                <Form.Control
                  type="number"
                  name="total_experience_years"
                  value={formData.total_experience_years}
                  onChange={handleInputChange}
                />
              </Form.Group>
            </Col>
          </Row>

          <Row>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>{t.work_type}</Form.Label>
                <Select
                  isClearable
                  onChange={(option) => handleSelectChange("work_type", option)}
                  options={
                    choices.work_types
                      ? choices.work_types.map(createOption)
                      : []
                  }
                  value={
                    formData.work_type ? createOption(formData.work_type) : null
                  }
                  placeholder={t.placeholder.select}
                />
              </Form.Group>
            </Col>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>{t.leave_days}</Form.Label>
                <Form.Control
                  type="number"
                  name="leave_days"
                  value={formData.leave_days}
                  onChange={handleInputChange}
                />
              </Form.Group>
            </Col>
          </Row>

          <Row>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>{t.technical_stacks}</Form.Label>
                <CreatableSelect
                  isMulti
                  isClearable
                  onChange={(selectedOptions) =>
                    handleMultiSelectChange("technical_stacks", selectedOptions)
                  }
                  options={
                    choices.technical_stacks
                      ? choices.technical_stacks.map((stack) =>
                          createOption(stack),
                        )
                      : []
                  }
                  value={formData.technical_stacks.map((stack) =>
                    createOption(stack),
                  )}
                  formatCreateLabel={(inputValue) => `Add "${inputValue}"`}
                  backspaceRemovesValue={true}
                  placeholder={t.placeholder.technical_stacks}
                />
                {errors.technical_stacks && (
                  <Form.Text className="text-danger">
                    {errors.technical_stacks}
                  </Form.Text>
                )}
              </Form.Group>
            </Col>
          </Row>

          <Form.Group className="mb-3">
            <ReCAPTCHA
              sitekey={RECAPTCHA_SITE_KEY}
              onChange={handleReCaptchaChange}
            />
          </Form.Group>

          {errors.submit && <Alert variant="danger">{errors.submit}</Alert>}

          <Button
            variant="primary"
            type="submit"
            disabled={
              !captchaToken ||
              Object.values(errors).some((error) => error !== null)
            }
          >
            {t.button.submit}
          </Button>
        </Form>
      </Modal.Body>
    </Modal>
  );
};

export default AddSalaryForm;
