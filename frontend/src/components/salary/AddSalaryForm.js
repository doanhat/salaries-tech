import React, { useState, useEffect } from "react";
import { Modal, Form, Button, Row, Col, Alert } from "react-bootstrap";
import Select from "react-select";
import CreatableSelect from "react-select/creatable";
// import ReCAPTCHA from "react-google-recaptcha";
import {
  checkCompany as checkCompanyName,
  checkCompanyTag,
  checkLocation,
  checkJobTitle,
  checkTechnicalStack,
} from "../../utils/api";
import { capitalizeWords } from "../../utils/stringUtils";

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

const AddSalaryForm = ({ show, handleClose, onSalaryAdded, choices }) => {
  const [formData, setFormData] = useState(initialFormData);
  const [errors, setErrors] = useState({});
  const [isNewCompany, setIsNewCompany] = useState(false);
  // const [captchaValue, setCaptchaValue] = useState(null);

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

  const handleSubmit = async (e) => {
    e.preventDefault();
    // if (!captchaValue) {
    //   setErrors({ ...errors, submit: "Please complete the CAPTCHA" });
    //   return;
    // }
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
      await onSalaryAdded(formData);
      // Reset the form
      setFormData(initialFormData);
      handleClose();
    } catch (error) {
      console.error("Error adding salary:", error);
      setErrors({ submit: "Failed to add salary. Please try again." });
    }
  };

  // const handleCaptchaChange = (value) => {
  //   setCaptchaValue(value);
  //   if (value) {
  //     setErrors({ ...errors, submit: null });
  //   }
  // };

  const createOption = (label, preserveCase = false) => ({
    label: preserveCase ? label : capitalizeWords(label),
    value: preserveCase ? label : label.toLowerCase(),
  });

  return (
    <Modal show={show} onHide={handleClose} size="lg">
      <Modal.Header closeButton>
        <Modal.Title>Add New Salary</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <Form onSubmit={handleSubmit}>
          <Row>
            <Col md={12}>
              <Form.Group className="mb-3">
                <Form.Label>Company</Form.Label>
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
                  placeholder="Select or type to add a company"
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
                  <Form.Label>Company Type</Form.Label>
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
                  />
                </Form.Group>
              </Col>
              <Col md={6}>
                <Form.Group className="mb-3">
                  <Form.Label>Company Tags</Form.Label>
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
                    placeholder="Select or type to add a company tag"
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
                  Job Titles <span className="text-danger">*</span>
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
                  placeholder="Select or type to add a job title"
                />
                <Form.Text className="text-muted">
                  {formData.job_titles.length}/2 job titles selected
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
                  Location <span className="text-danger">*</span>
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
                  placeholder="Select or type to add a location"
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
                <Form.Label>Net Salary</Form.Label>
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
                  Gross Salary <span className="text-danger">*</span>
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
                <Form.Label>Variables</Form.Label>
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
                <Form.Label>Gender</Form.Label>
                <Select
                  isClearable
                  onChange={(option) => handleSelectChange("gender", option)}
                  options={[
                    { value: "male", label: "Male" },
                    { value: "female", label: "Female" },
                    { value: "other", label: "Other" },
                  ]}
                  value={formData.gender ? createOption(formData.gender) : null}
                />
              </Form.Group>
            </Col>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>Level</Form.Label>
                <Select
                  isClearable
                  onChange={(option) => handleSelectChange("level", option)}
                  options={
                    choices.levels ? choices.levels.map(createOption) : []
                  }
                  value={formData.level ? createOption(formData.level) : null}
                />
              </Form.Group>
            </Col>
          </Row>

          <Row>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>Years at Company</Form.Label>
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
                <Form.Label>Total Years of Experience</Form.Label>
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
                <Form.Label>Work Type</Form.Label>
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
                />
              </Form.Group>
            </Col>
            <Col md={6}>
              <Form.Group className="mb-3">
                <Form.Label>Leave Days</Form.Label>
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
                <Form.Label>Technical Stacks</Form.Label>
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
                  placeholder="Select or type to add a technical stack"
                />
                {errors.technical_stacks && (
                  <Form.Text className="text-danger">
                    {errors.technical_stacks}
                  </Form.Text>
                )}
              </Form.Group>
            </Col>
          </Row>

          {/* <Row className="mb-3">
            <Col>
              <ReCAPTCHA
                sitekey="YOUR_RECAPTCHA_SITE_KEY"
                onChange={handleCaptchaChange}
              />
            </Col>
          </Row> */}

          {errors.submit && <Alert variant="danger">{errors.submit}</Alert>}

          {/* <Button variant="primary" type="submit" disabled={Object.values(errors).some(error => error !== null) || !captchaValue}>   */}
          <Button
            variant="primary"
            type="submit"
            disabled={Object.values(errors).some((error) => error !== null)}
          >
            Submit
          </Button>
        </Form>
      </Modal.Body>
    </Modal>
  );
};

export default AddSalaryForm;
