import React from "react";
import { Form, Row, Col, Button } from "react-bootstrap";
import Select from "react-select";
import DatePicker from "react-datepicker";
import { OverlayTrigger, Tooltip } from "react-bootstrap";
import styled from "styled-components";

const filterStyles = {
  fontSize: "0.9rem",
  marginBottom: "10px",
};

const SelectWithTooltip = ({
  options,
  onChange,
  placeholder,
  title,
  value,
  name,
}) => (
  <OverlayTrigger placement="top" overlay={<Tooltip>{title}</Tooltip>}>
    <div style={filterStyles}>
      <Select
        options={options}
        onChange={(selectedOptions) => onChange(name, selectedOptions)}
        placeholder={placeholder}
        isMulti
        value={value}
        styles={{
          multiValue: (base) => ({
            ...base,
            backgroundColor: "#e9ecef",
            borderRadius: "4px",
          }),
          multiValueRemove: (base) => ({
            ...base,
            color: "#495057",
            ":hover": {
              backgroundColor: "#ced4da",
              color: "#212529",
            },
          }),
        }}
      />
    </div>
  </OverlayTrigger>
);

const InputWithTooltip = ({
  type,
  placeholder,
  name,
  onChange,
  title,
  value,
}) => (
  <OverlayTrigger placement="top" overlay={<Tooltip>{title}</Tooltip>}>
    <Form.Control
      type={type}
      placeholder={placeholder}
      name={name}
      onChange={(e) => onChange(e)}
      value={value}
      style={filterStyles}
    />
  </OverlayTrigger>
);

const DatePickerWithTooltip = ({ name, selected, onChange, title }) => (
  <OverlayTrigger placement="top" overlay={<Tooltip>{title}</Tooltip>}>
    <div style={filterStyles}>
      <DatePicker
        selected={selected ? new Date(selected) : null}
        onChange={(date) => onChange(date, name)}
        placeholderText={title}
        className="form-control"
        style={{ height: "30px", padding: "2px 8px" }}
        dateFormat="yyyy-MM-dd"
      />
    </div>
  </OverlayTrigger>
);

const ModalContainer = styled.div`
  max-width: 1200px;
  margin: 0 auto;
  padding: 0.5rem;
`;

const FilterForm = styled(Form)`
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
`;

const ButtonRow = styled(Row)`
  margin-top: 1rem;
  padding-bottom: 0.5rem;
`;

const SalaryModalFilters = ({
  pendingFilters,
  dateFilters,
  handleMultiSelectChange,
  handleInputChangeImmediate,
  handleDateChange,
  choices,
  t,
  onSubmit,
  onClose,
  onReset,
}) => {
  const createOptions = (items) =>
    items?.map((item) => ({ value: item, label: item })) || [];

  return (
    <ModalContainer>
      <FilterForm onSubmit={onSubmit}>
        <Row className="g-3">
          <Col md={4}>
            <SelectWithTooltip
              options={createOptions(choices.company_names)}
              onChange={handleMultiSelectChange}
              placeholder={t.entities.company.name.plural}
              title={t.entities.company.name.plural}
              value={pendingFilters.company_names || []}
              name="company_names"
            />
          </Col>
          <Col md={4}>
            <SelectWithTooltip
              options={createOptions(choices.company_tags || [])}
              onChange={handleMultiSelectChange}
              placeholder={t.entities.company.tags.plural}
              title={t.entities.company.tags.plural}
              value={pendingFilters.company_tags || []}
              name="company_tags"
            />
          </Col>
          <Col md={4}>
            <SelectWithTooltip
              options={createOptions(choices.company_types || [])}
              onChange={handleMultiSelectChange}
              placeholder={t.entities.company.type.plural}
              title={t.entities.company.type.plural}
              value={pendingFilters.company_types || []}
              name="company_types"
            />
          </Col>
          <Col md={4}>
            <SelectWithTooltip
              options={createOptions(choices.job_titles || [])}
              onChange={handleMultiSelectChange}
              placeholder={t.entities.job.titles.plural}
              title={t.entities.job.titles.plural}
              value={pendingFilters.job_titles || []}
              name="job_titles"
            />
          </Col>
          <Col md={4}>
            <SelectWithTooltip
              options={createOptions(choices.technical_stacks || [])}
              onChange={handleMultiSelectChange}
              placeholder={t.entities.technical_stacks.plural}
              title={t.entities.technical_stacks.plural}
              value={pendingFilters.technical_stacks || []}
              name="technical_stacks"
              isMulti
            />
          </Col>
          <Col md={4}>
            <SelectWithTooltip
              options={createOptions(choices.locations || [])}
              onChange={handleMultiSelectChange}
              placeholder={t.entities.location.plural}
              title={t.entities.location.plural}
              value={pendingFilters.locations || []}
              name="locations"
            />
          </Col>
          <Col md={4}>
            <SelectWithTooltip
              options={[
                { value: "n/a", label: "N/A" },
                ...Object.entries(t.entities.gender.value).map(
                  ([key, value]) => ({
                    value: key,
                    label: value,
                  }),
                ),
              ]}
              onChange={handleMultiSelectChange}
              placeholder={t.entities.gender.plural}
              title={t.entities.gender.plural}
              value={pendingFilters.genders}
              name="genders"
            />
          </Col>
          <Col md={4}>
            <SelectWithTooltip
              options={createOptions(choices.levels || [])}
              onChange={handleMultiSelectChange}
              placeholder={t.entities.level.plural}
              title={t.entities.level.plural}
              value={pendingFilters.levels || []}
              name="levels"
            />
          </Col>
          <Col md={4}>
            <SelectWithTooltip
              options={createOptions(choices.work_types || [])}
              onChange={handleMultiSelectChange}
              placeholder={t.entities.work_type.plural}
              title={t.entities.work_type.plural}
              value={pendingFilters.work_types || []}
              name="work_types"
            />
          </Col>
          <Col md={4}>
            <InputWithTooltip
              type="number"
              placeholder={t.entities.net_salary.min}
              name="net_salary_min"
              onChange={handleInputChangeImmediate}
              title={t.entities.net_salary.min}
              value={pendingFilters.net_salary_min}
            />
          </Col>
          <Col md={4}>
            <InputWithTooltip
              type="number"
              placeholder={t.entities.net_salary.max}
              name="net_salary_max"
              onChange={handleInputChangeImmediate}
              title={t.entities.net_salary.max}
              value={pendingFilters.net_salary_max}
            />
          </Col>
          <Col md={4}>
            <InputWithTooltip
              type="number"
              placeholder={t.entities.gross_salary.min}
              name="gross_salary_min"
              onChange={handleInputChangeImmediate}
              title={t.entities.gross_salary.min}
              value={pendingFilters.gross_salary_min}
            />
          </Col>
          <Col md={4}>
            <InputWithTooltip
              type="number"
              placeholder={t.entities.gross_salary.max}
              name="gross_salary_max"
              onChange={handleInputChangeImmediate}
              title={t.entities.gross_salary.max}
              value={pendingFilters.gross_salary_max}
            />
          </Col>
          <Col md={4}>
            <InputWithTooltip
              type="number"
              placeholder={t.entities.bonus.min}
              name="bonus_min"
              onChange={handleInputChangeImmediate}
              title={t.entities.bonus.min}
              value={pendingFilters.bonus_min}
            />
          </Col>
          <Col md={4}>
            <InputWithTooltip
              type="number"
              placeholder={t.entities.bonus.max}
              name="bonus_max"
              onChange={handleInputChangeImmediate}
              title={t.entities.bonus.max}
              value={pendingFilters.bonus_max}
            />
          </Col>
          <Col md={4}>
            <InputWithTooltip
              type="number"
              placeholder={t.entities.experience_years_company.min}
              name="experience_years_company_min"
              onChange={handleInputChangeImmediate}
              title={t.entities.experience_years_company.min}
              value={pendingFilters.experience_years_company_min}
            />
          </Col>
          <Col md={4}>
            <InputWithTooltip
              type="number"
              placeholder={t.entities.experience_years_company.max}
              name="experience_years_company_max"
              onChange={handleInputChangeImmediate}
              title={t.entities.experience_years_company.max}
              value={pendingFilters.experience_years_company_max}
            />
          </Col>
          <Col md={4}>
            <InputWithTooltip
              type="number"
              placeholder={t.entities.total_experience_years.min}
              name="total_experience_years_min"
              onChange={handleInputChangeImmediate}
              title={t.entities.total_experience_years.min}
              value={pendingFilters.total_experience_years_min}
            />
          </Col>
          <Col md={4}>
            <InputWithTooltip
              type="number"
              placeholder={t.entities.total_experience_years.max}
              name="total_experience_years_max"
              onChange={handleInputChangeImmediate}
              title={t.entities.total_experience_years.max}
              value={pendingFilters.total_experience_years_max}
            />
          </Col>
          <Col md={4}>
            <InputWithTooltip
              type="number"
              placeholder={t.entities.leave_days.min}
              name="leave_days_min"
              onChange={handleInputChangeImmediate}
              title={t.entities.leave_days.min}
              value={pendingFilters.leave_days_min}
            />
          </Col>
          <Col md={4}>
            <InputWithTooltip
              type="number"
              placeholder={t.entities.leave_days.max}
              name="leave_days_max"
              onChange={handleInputChangeImmediate}
              title={t.entities.leave_days.max}
              value={pendingFilters.leave_days_max}
            />
          </Col>
          <Col md={4}>
            <DatePickerWithTooltip
              name="min_added_date"
              selected={dateFilters.min_added_date}
              onChange={(date) => handleDateChange(date, "min_added_date")}
              title={t.entities.added_date.min}
            />
          </Col>
          <Col md={4}>
            <DatePickerWithTooltip
              name="max_added_date"
              selected={dateFilters.max_added_date}
              onChange={(date) => handleDateChange(date, "max_added_date")}
              title={t.entities.added_date.max}
            />
          </Col>
          <Col md={4}>
            <SelectWithTooltip
              options={[
                { value: "n/a", label: "N/A" },
                ...Object.entries(t.entities.verification.value).map(
                  ([key, value]) => ({
                    value: key,
                    label: value,
                  }),
                ),
              ]}
              onChange={handleMultiSelectChange}
              placeholder={t.entities.verification.plural}
              title={t.entities.verification.plural}
              value={pendingFilters.verifications || []}
              name="verifications"
            />
          </Col>
        </Row>
        <ButtonRow>
          <Col>
            <Button
              variant="secondary"
              onClick={onClose}
              data-testid="close-filter-modal"
            >
              {t.entities.buttons.close}
            </Button>
            <Button variant="primary" type="submit" className="ms-2">
              {t.entities.buttons.apply_filters}
            </Button>
            <Button
              variant="outline-secondary"
              onClick={onReset}
              className="ms-2"
            >
              {t.entities.buttons.reset_filters}
            </Button>
          </Col>
        </ButtonRow>
      </FilterForm>
    </ModalContainer>
  );
};

export default SalaryModalFilters;
