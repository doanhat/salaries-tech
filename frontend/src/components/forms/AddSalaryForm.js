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
  checkEmailCompanyMatch,
} from "../../utils/api";
import { capitalizeWords } from "../../utils/stringUtils";
import { useLanguage, translations } from "../../contexts/LanguageContext";

const COMMON_EMAIL_DOMAINS = [
  "gmail.com",
  "yahoo.com",
  "hotmail.com",
  "outlook.com",
  "aol.com",
  "protonmail.com",
  "icloud.com",
  "mail.com",
  "live.com",
  "me.com",
  "msn.com",
];

const initialFormData = {
  company_name: null,
  company_type: null,
  company_tags: [],
  job_titles: [],
  location: null,
  net_salary: null,
  gross_salary: null,
  bonus: null,
  gender: null,
  experience_years_company: null,
  total_experience_years: null,
  level: null,
  work_type: null,
  leave_days: null,
  technical_stacks: [],
  professional_email: null,
};

const AddSalaryForm = ({ show, handleClose, onSalaryAdded, choices }) => {
  const { language } = useLanguage();
  const t = translations[language];
  const [formData, setFormData] = useState(initialFormData);
  const [errors, setErrors] = useState({});
  const [isNewCompany, setIsNewCompany] = useState(false);
  const [captchaToken, setCaptchaToken] = useState(null);

  const validateEmailCompanyMatch = useCallback(
    async (email, companyName) => {
      if (!email) return true;
      try {
        const result = await checkEmailCompanyMatch(email, companyName);
        if (!result.is_valid) {
          setErrors((prev) => ({
            ...prev,
            professional_email: t.entities.errors[result.code],
          }));
          return false;
        }
        return true;
      } catch (error) {
        console.error("Error validating email-company match:", error);
        return false;
      }
    },
    [setErrors, t.entities.errors],
  );

  const validateEmail = (email) => {
    if (!email) return true; // Optional field
    if (email && !formData.company_name) return false;
    const domain = email.split("@")[1]?.toLowerCase();
    return domain && !COMMON_EMAIL_DOMAINS.includes(domain);
  };

  useEffect(() => {
    if (show) {
      setFormData(initialFormData);
      setErrors({});
    }
  }, [show, choices.technical_stacks]);

  // Add real-time validation when email or company changes
  useEffect(() => {
    const validateEmailCompany = async () => {
      if (formData.professional_email && formData.company_name) {
        await validateEmailCompanyMatch(
          formData.professional_email,
          formData.company_name,
        );
      }
    };
    validateEmailCompany();
  }, [
    formData.professional_email,
    formData.company_name,
    validateEmailCompanyMatch,
  ]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    const numValue = value === "" ? null : parseFloat(value);

    // Update form data
    setFormData((prev) => ({ ...prev, [name]: value }));

    // Clear previous error for this field
    setErrors((prev) => {
      const newErrors = { ...prev };
      delete newErrors[name]; // Remove the error for this field
      return newErrors;
    });

    // Skip other validations if value is empty
    if (value === "" || value === null) return;

    // Validate negative values
    if (numValue !== null && numValue < 0) {
      setErrors((prev) => ({
        ...prev,
        [name]: t.entities.errors.negative_value,
      }));
      return;
    }

    // Specific validations based on field
    switch (name) {
      case "net_salary":
        if (numValue !== null && formData.gross_salary) {
          const grossValue = parseFloat(formData.gross_salary);
          if (numValue >= grossValue) {
            setErrors((prev) => ({
              ...prev,
              net_salary: t.entities.errors.net_salary_exceeds_gross,
            }));
          }
        }
        break;

      case "gross_salary":
        if (numValue !== null && formData.net_salary) {
          const netValue = parseFloat(formData.net_salary);
          if (netValue >= numValue) {
            setErrors((prev) => ({
              ...prev,
              net_salary: t.entities.errors.net_salary_exceeds_gross,
            }));
          } else {
            // Clear net salary error if validation passes
            setErrors((prev) => {
              const newErrors = { ...prev };
              delete newErrors.net_salary;
              return newErrors;
            });
          }
        }
        break;

      case "experience_years_company":
        if (numValue !== null && formData.total_experience_years) {
          const totalExp = parseFloat(formData.total_experience_years);
          if (numValue > totalExp) {
            setErrors((prev) => ({
              ...prev,
              experience_years_company:
                t.entities.errors.company_experience_exceeds_total,
            }));
          }
        }
        break;

      case "total_experience_years":
        if (numValue !== null && formData.experience_years_company) {
          const companyExp = parseFloat(formData.experience_years_company);
          if (companyExp > numValue) {
            setErrors((prev) => ({
              ...prev,
              experience_years_company:
                t.entities.errors.company_experience_exceeds_total,
            }));
          } else {
            // Clear company experience error if validation passes
            setErrors((prev) => {
              const newErrors = { ...prev };
              delete newErrors.experience_years_company;
              return newErrors;
            });
          }
        }
        break;

      case "leave_days":
        if (numValue !== null && numValue >= 365) {
          setErrors((prev) => ({
            ...prev,
            leave_days: t.entities.errors.leave_days_exceed_year,
          }));
        }
        break;
      default:
        break;
    }
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
          [name]: t.entities.errors.exists.replace("{field}", name),
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
        [name]: t.entities.errors.job_titles_limit,
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
          [name]: t.entities.errors.exists.replace("{field}", name),
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
      setErrors({ ...errors, submit: t.entities.errors.captcha });
      return;
    }

    // Validate email-company match before submission
    if (formData.professional_email && formData.company_name) {
      const isValidMatch = await validateEmailCompanyMatch(
        formData.professional_email,
        formData.company_name,
      );
      if (!isValidMatch) return;
    }

    const newErrors = {};

    // Required fields validation
    if (!formData.location) newErrors.location = t.entities.errors.location;
    if (!formData.gross_salary)
      newErrors.gross_salary = t.entities.errors.gross_salary;
    if (!formData.job_titles || formData.job_titles.length === 0)
      newErrors.job_titles = t.entities.errors.job_titles;
    if (isNewCompany && !formData.company_type)
      newErrors.company_type = t.entities.errors.company_type;

    // Email validation
    if (
      formData.professional_email &&
      !validateEmail(formData.professional_email)
    ) {
      if (formData.company_name) {
        newErrors.professional_email = t.entities.errors.invalid_common_domain;
      } else {
        newErrors.professional_email =
          t.entities.errors.invalid_company_name_required;
      }
    }

    // Numeric fields validation
    const numericFields = [
      "net_salary",
      "gross_salary",
      "bonus",
      "experience_years_company",
      "total_experience_years",
      "leave_days",
    ];
    numericFields.forEach((field) => {
      if (formData[field] && formData[field] < 0) {
        newErrors[field] = t.entities.errors.negative_value;
      }
    });

    // Salary comparison validation
    if (
      formData.net_salary &&
      formData.gross_salary &&
      parseFloat(formData.net_salary) >= parseFloat(formData.gross_salary)
    ) {
      newErrors.net_salary = t.entities.errors.net_salary_exceeds_gross;
    }

    // Experience years validation
    if (
      formData.experience_years_company &&
      formData.total_experience_years &&
      parseFloat(formData.experience_years_company) >
        parseFloat(formData.total_experience_years)
    ) {
      newErrors.experience_years_company =
        t.entities.errors.company_experience_exceeds_total;
    }

    // Leave days validation
    if (formData.leave_days && parseFloat(formData.leave_days) >= 365) {
      newErrors.leave_days = t.entities.errors.leave_days_exceed_year;
    }

    if (
      Object.keys(newErrors).length > 0 ||
      Object.values(errors).some((error) => error !== null)
    ) {
      setErrors((prev) => ({ ...prev, ...newErrors }));
      return;
    }

    try {
      await onSalaryAdded(
        formData,
        captchaToken,
        navigator.userAgent,
        t.entities.email_body,
      );
      setFormData(initialFormData);
      setCaptchaToken(null);
      handleClose();
    } catch (error) {
      console.error("Error adding salary:", error);
      setErrors({ submit: t.entities.errors.submit });
    }
  };

  const createOption = (label, preserveCase = false) => ({
    label: preserveCase ? label : capitalizeWords(label),
    value: preserveCase ? label : label.toLowerCase(),
  });

  return (
    <Modal show={show} onHide={handleClose} size="lg">
      <Modal.Header closeButton>
        <Modal.Title>{t.entities.title.add_salary}</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <Form onSubmit={handleSubmit}>
          <Row>
            <Col md={12}>
              <Form.Group className="mb-3">
                <Form.Label>{t.entities.company.name.singular}</Form.Label>
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
                  formatCreateLabel={(inputValue) =>
                    `${t.entities.info.add} "${inputValue}"`
                  }
                  backspaceRemovesValue={true}
                  placeholder={t.entities.company.name.placeholder}
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
                  <Form.Label>{t.entities.company.type.singular}</Form.Label>
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
                    placeholder={t.entities.info.select}
                  />
                </Form.Group>
              </Col>
              <Col md={6}>
                <Form.Group className="mb-3">
                  <Form.Label>{t.entities.company.tags.singular}</Form.Label>
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
                    placeholder={t.entities.company.tags.placeholder}
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
                  {t.entities.job.titles.singular}{" "}
                  <span className="text-danger">*</span>
                </Form.Label>
                <CreatableSelect
                  isMulti
                  isClearable
                  onChange={(selectedOptions) =>
                    handleMultiSelectChange("job_titles", selectedOptions)
                  }
                  options={
                    choices.job_titles
                      ? choices.job_titles.map((job_title) =>
                          createOption(job_title),
                        )
                      : []
                  }
                  value={formData.job_titles.map((job_title) =>
                    createOption(job_title),
                  )}
                  isOptionDisabled={() => formData.job_titles.length >= 2}
                  placeholder={t.entities.job.titles.placeholder}
                  isInvalid={!!errors.job_titles}
                />
                <Form.Text className="text-muted">
                  {formData.job_titles.length}/2{" "}
                  {t.entities.job.titles.selected}
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
                  {t.entities.location.singular}{" "}
                  <span className="text-danger">*</span>
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
                  placeholder={t.entities.location.placeholder}
                  isInvalid={!!errors.location}
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
                <Form.Label>{t.entities.net_salary.singular}</Form.Label>
                <Form.Control
                  type="number"
                  name="net_salary"
                  value={formData.net_salary}
                  onChange={handleInputChange}
                  isInvalid={!!errors.net_salary}
                />
                {errors.net_salary && (
                  <Form.Control.Feedback type="invalid">
                    {errors.net_salary}
                  </Form.Control.Feedback>
                )}
              </Form.Group>
            </Col>
            <Col md={4}>
              <Form.Group className="mb-3">
                <Form.Label>
                  {t.entities.gross_salary.singular}{" "}
                  <span className="text-danger">*</span>
                </Form.Label>
                <Form.Control
                  type="number"
                  name="gross_salary"
                  value={formData.gross_salary}
                  onChange={handleInputChange}
                  required
                  isInvalid={!!errors.gross_salary}
                />
                {errors.gross_salary && (
                  <Form.Control.Feedback type="invalid">
                    {errors.gross_salary}
                  </Form.Control.Feedback>
                )}
              </Form.Group>
            </Col>
            <Col md={4}>
              <Form.Group className="mb-3">
                <Form.Label>{t.entities.bonus.singular}</Form.Label>
                <Form.Control
                  type="number"
                  name="bonus"
                  value={formData.bonus}
                  onChange={handleInputChange}
                />
              </Form.Group>
            </Col>
          </Row>

          <Row>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>{t.entities.gender.singular}</Form.Label>
                <Select
                  isClearable
                  onChange={(option) => handleSelectChange("gender", option)}
                  options={Object.entries(t.entities.gender.value).map(
                    ([key, value]) => ({
                      value: key,
                      label: value,
                    }),
                  )}
                  value={formData.gender ? createOption(formData.gender) : null}
                  placeholder={t.entities.info.select}
                />
              </Form.Group>
            </Col>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>{t.entities.level.singular}</Form.Label>
                <Select
                  isClearable
                  onChange={(option) => handleSelectChange("level", option)}
                  options={
                    choices.levels ? choices.levels.map(createOption) : []
                  }
                  value={formData.level ? createOption(formData.level) : null}
                  placeholder={t.entities.info.select}
                />
              </Form.Group>
            </Col>
          </Row>

          <Row>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>
                  {t.entities.experience_years_company.singular}
                </Form.Label>
                <Form.Control
                  type="number"
                  name="experience_years_company"
                  value={formData.experience_years_company}
                  onChange={handleInputChange}
                  isInvalid={!!errors.experience_years_company}
                />
                {errors.experience_years_company && (
                  <Form.Control.Feedback type="invalid">
                    {errors.experience_years_company}
                  </Form.Control.Feedback>
                )}
              </Form.Group>
            </Col>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>
                  {t.entities.total_experience_years.singular}
                </Form.Label>
                <Form.Control
                  type="number"
                  name="total_experience_years"
                  value={formData.total_experience_years}
                  onChange={handleInputChange}
                  isInvalid={!!errors.total_experience_years}
                />
                {errors.total_experience_years && (
                  <Form.Control.Feedback type="invalid">
                    {errors.total_experience_years}
                  </Form.Control.Feedback>
                )}
              </Form.Group>
            </Col>
          </Row>

          <Row>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>{t.entities.work_type.singular}</Form.Label>
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
                  placeholder={t.entities.info.select}
                />
              </Form.Group>
            </Col>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>{t.entities.leave_days.singular}</Form.Label>
                <Form.Control
                  type="number"
                  name="leave_days"
                  value={formData.leave_days}
                  onChange={handleInputChange}
                  isInvalid={!!errors.leave_days}
                />
                {errors.leave_days && (
                  <Form.Control.Feedback type="invalid">
                    {errors.leave_days}
                  </Form.Control.Feedback>
                )}
              </Form.Group>
            </Col>
          </Row>

          <Row>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>{t.entities.technical_stacks.singular}</Form.Label>
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
                  placeholder={t.entities.technical_stacks.placeholder}
                  isInvalid={!!errors.technical_stacks}
                />
                {errors.technical_stacks && (
                  <Form.Control.Feedback type="invalid">
                    {errors.technical_stacks}
                  </Form.Control.Feedback>
                )}
              </Form.Group>
            </Col>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>
                  {t.entities.professional_email.singular}
                </Form.Label>
                <Form.Control
                  type="email"
                  name="professional_email"
                  value={formData.professional_email || ""}
                  onChange={handleInputChange}
                  isInvalid={!!errors.professional_email}
                />
                <Form.Control.Feedback type="invalid">
                  {errors.professional_email}
                </Form.Control.Feedback>
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
            {t.entities.buttons.submit}
          </Button>
        </Form>
      </Modal.Body>
    </Modal>
  );
};

export default AddSalaryForm;
