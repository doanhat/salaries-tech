import React, { useState, useEffect, useCallback, useMemo } from "react";
import {
  Table,
  Form,
  Button,
  Row,
  Col,
  OverlayTrigger,
  Tooltip,
  Modal,
  Alert,
  Dropdown,
  ButtonGroup,
  Container,
} from "react-bootstrap";
import Select from "react-select";
import DatePicker from "react-datepicker";
import {
  getSalaries,
  getChoices,
  addSalary,
  getLocationStats,
  getTopLocationsByAverageSalary,
} from "../utils/api";
import AddSalaryForm from "../components/forms/AddSalaryForm";
import LocationPieChart from "../components/dashboards/LocationsPieChart";
import TopLocationsSalaryBarChart from "../components/dashboards/TopLocationsBarChart";
import { debounce } from "lodash";
import { capitalizeWords } from "../utils/stringUtils";
import { useMediaQuery } from "react-responsive";
import styled from "styled-components";
import { useLanguage, translations } from "../contexts/LanguageContext";
import "react-datepicker/dist/react-datepicker.css";

// Add these styled components
const StyledTable = styled(Table)`
  width: 100%;
  min-width: max-content;
`;

const TableCell = styled.td`
  white-space: nowrap;
  padding: 8px;
`;

const NarrowCell = styled(TableCell)`
  min-width: 100px; // Even narrower for certain columns
`;

const StickyCell = styled(TableCell)`
  position: sticky;
  background-color: #f8f9fa;
  z-index: 2;
  ${(props) => props.left && `left: ${props.left};`}
  ${(props) => props.right && `right: ${props.right};`}
`;

const ScrollableWrapper = styled.div`
  overflow-x: auto;
  position: relative;
  width: 100%;
  -webkit-overflow-scrolling: touch;
`;

const LoadingOverlay = styled.div`
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(255, 255, 255, 0.7);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
`;

const ChartRow = styled(Row)`
  margin-bottom: 20px;
`;

const ChartCol = styled(Col)`
  @media (max-width: 767px) {
    margin-bottom: 20px;
  }
`;

const ToggleButton = styled(Button)`
  margin-bottom: 15px;
`;

const ButtonContainer = styled(Container)`
  margin-top: 20px;
  margin-bottom: 20px;
`;

const SalaryListPage = () => {
  const { language } = useLanguage();
  const t = translations[language];
  const [salaries, setSalaries] = useState([]);
  const [choices, setChoices] = useState({});
  const [filters, setFilters] = useState({
    company_names: [],
    company_tags: [],
    company_types: [],
    job_titles: [],
    locations: [],
    genders: [],
    levels: [],
    work_types: [],
    net_salary_min: "",
    net_salary_max: "",
    gross_salary_min: "",
    gross_salary_max: "",
    bonus_min: "",
    bonus_max: "",
    experience_years_company_min: "",
    experience_years_company_max: "",
    total_experience_years_min: "",
    total_experience_years_max: "",
    leave_days_min: "",
    leave_days_max: "",
    min_added_date: null,
    max_added_date: null,
    technical_stacks: [],
  });
  const [pendingFilters, setPendingFilters] = useState({});
  const [showAddSalaryModal, setShowAddSalaryModal] = useState(false);
  const [showFilterModal, setShowFilterModal] = useState(false);
  const [dateFilters, setDateFilters] = useState({
    min_added_date: null,
    max_added_date: null,
  });
  const [sortBy, setSortBy] = useState("added_date");
  const [sortOrder, setSortOrder] = useState("desc");
  const [itemsPerPage, setItemsPerPage] = useState(50);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalItems, setTotalItems] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [successMessage, setSuccessMessage] = useState("");
  const [locationStats, setLocationStats] = useState([]);
  const [topLocationsSalary, setTopLocationsSalary] = useState([]);
  const [showCharts, setShowCharts] = useState(false); // Set to true by default

  const fetchSalaries = useCallback(
    async (activeFilters = filters) => {
      try {
        setIsLoading(true);
        const formattedFilters = Object.entries(activeFilters).reduce(
          (acc, [key, value]) => {
            if (Array.isArray(value) && value.length > 0) {
              acc[key] = value.map((item) => item.value || item).join(",");
            } else if (value !== null && value !== undefined && value !== "") {
              if (key === "min_added_date" || key === "max_added_date") {
                acc[key] = value.toISOString().split("T")[0]; // Format date as YYYY-MM-DD
              } else {
                acc[key] = value;
              }
            }
            return acc;
          },
          {},
        );

        const data = await getSalaries(
          formattedFilters,
          sortBy,
          sortOrder,
          (currentPage - 1) * itemsPerPage,
          itemsPerPage,
        );
        setSalaries(data.results);
        setTotalItems(data.total);
        setError(null);
      } catch (error) {
        console.error("Error fetching salaries:", error);
        setError("Failed to fetch salaries. Please try again.");
      } finally {
        setIsLoading(false);
      }
    },
    [sortBy, sortOrder, currentPage, itemsPerPage, filters],
  );

  const fetchChoices = useCallback(async () => {
    try {
      const data = await getChoices();
      setChoices(data);
    } catch (error) {
      console.error("Failed to fetch choices:", error);
    }
  }, []);

  useEffect(() => {
    fetchChoices();
    fetchSalaries();
  }, [fetchChoices, fetchSalaries]);

  useEffect(() => {
    const fetchLocationStats = async () => {
      try {
        const data = await getLocationStats();
        setLocationStats(data.chart_data);
      } catch (error) {
        console.error("Error fetching location stats:", error);
      }
    };

    const fetchTopLocationsSalary = async () => {
      try {
        const data = await getTopLocationsByAverageSalary();
        setTopLocationsSalary(data);
      } catch (error) {
        console.error("Error fetching top locations by salary:", error);
      }
    };

    fetchLocationStats();
    fetchTopLocationsSalary();
  }, []);

  const handleMultiSelectChange = (name, selectedOptions) => {
    setPendingFilters((prev) => ({ ...prev, [name]: selectedOptions }));
    if (!showFilterModal) {
      setFilters((prev) => ({ ...prev, [name]: selectedOptions }));
      fetchSalaries();
    }
  };

  const handleInputChangeImmediate = (e) => {
    const { name, value } = e.target;
    setPendingFilters((prev) => ({ ...prev, [name]: value }));
    if (!showFilterModal) {
      setFilters((prev) => ({ ...prev, [name]: value }));
      fetchSalaries();
    }
  };

  const handleDateChange = (date, name) => {
    setDateFilters((prev) => ({
      ...prev,
      [name]: date,
    }));
    setPendingFilters((prev) => ({
      ...prev,
      [name]: date,
    }));
  };

  const handleFilterSubmit = (e) => {
    e.preventDefault();
    setFilters(pendingFilters);
    setShowFilterModal(false);
    setIsLoading(true); // Set loading state immediately
    setCurrentPage(1); // Reset to first page when applying filters
    fetchSalaries(pendingFilters); // Pass pendingFilters directly to fetchSalaries
  };

  const createOptions = (items) =>
    items?.map((item) => ({ value: item, label: item })) || [];

  const handleOpenAddSalaryModal = () => {
    setShowAddSalaryModal(true);
  };

  const handleCloseAddSalaryModal = () => {
    setShowAddSalaryModal(false);
  };

  const handleSalaryAdded = async (newSalary, captchaToken) => {
    try {
      const userAgent = navigator.userAgent;
      const emailBody = {
        subject: t.entities.email_body.subject,
        greeting_text: t.entities.email_body.greeting_text,
        verify_button_text: t.entities.email_body.verify_button_text,
        expiration_text: t.entities.email_body.expiration_text,
      };
      const response = await addSalary(
        newSalary,
        captchaToken,
        userAgent,
        emailBody,
      );
      console.log("Salary added successfully:", response);
      setSuccessMessage(
        newSalary.professional_email
          ? t.entities.info.add_salary_success_email
          : t.entities.info.add_salary_success,
      );
      setShowAddSalaryModal(false);
      fetchSalaries(); // Refresh the salary list
    } catch (error) {
      console.error("Error adding salary:", error);
      let errorMessage = t.entities.errors.submit;
      if (error.message) {
        try {
          const parsedError = JSON.parse(error.message);
          if (parsedError.detail && Array.isArray(parsedError.detail)) {
            errorMessage = parsedError.detail.map((err) => err.msg).join(", ");
          } else if (parsedError.detail) {
            errorMessage = parsedError.detail;
          }
        } catch (e) {
          errorMessage = error.message;
        }
      }
      setError(errorMessage);
    }
  };

  // Helper function to check if a salary meets the filter criteria
  const checkSalaryAgainstFilters = (salary, filters) => {
    for (const [key, value] of Object.entries(filters)) {
      if (Array.isArray(value) && value.length > 0) {
        if (!value.includes(salary[key])) return false;
      } else if (value !== null && value !== undefined && value !== "") {
        switch (key) {
          case "net_salary_min":
            if (salary.net_salary < parseFloat(value)) return false;
            break;
          case "net_salary_max":
            if (salary.net_salary > parseFloat(value)) return false;
            break;
          case "gross_salary_min":
            if (salary.gross_salary < parseFloat(value)) return false;
            break;
          case "gross_salary_max":
            if (salary.gross_salary > parseFloat(value)) return false;
            break;
          // Add similar cases for other numeric filters
          case "min_added_date":
            if (new Date(salary.added_date) < new Date(value)) return false;
            break;
          case "max_added_date":
            if (new Date(salary.added_date) > new Date(value)) return false;
            break;
          default:
            if (salary[key] !== value) return false;
        }
      }
    }
    return true;
  };

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
  }) => {
    const [localValue, setLocalValue] = useState(value);

    useEffect(() => {
      setLocalValue(value);
    }, [value]);

    const debouncedOnChange = useMemo(
      () =>
        debounce((name, value) => {
          onChange({ target: { name, value } });
        }, 500),
      [onChange],
    );

    const handleChange = (e) => {
      const newValue = e.target.value;
      setLocalValue(newValue);
      debouncedOnChange(name, newValue);
    };

    return (
      <OverlayTrigger placement="top" overlay={<Tooltip>{title}</Tooltip>}>
        <Form.Control
          type={type}
          placeholder={placeholder}
          name={name}
          onChange={handleChange}
          value={localValue}
          style={filterStyles}
        />
      </OverlayTrigger>
    );
  };

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

  const fullScreenModalStyle = {
    modal: {
      width: "100%",
      maxWidth: "100%",
      margin: "0",
      padding: "0",
    },
    modalContent: {
      height: "calc(100vh - 56px)", // Subtract the height of the Modal.Header
      borderRadius: "0",
      display: "flex",
      flexDirection: "column",
    },
  };

  const resetFilters = () => {
    const initialFilters = {
      company_names: [],
      company_tags: [],
      company_types: [],
      job_titles: [],
      locations: [],
      genders: [],
      levels: [],
      work_types: [],
      net_salary_min: "",
      net_salary_max: "",
      gross_salary_min: "",
      gross_salary_max: "",
      bonus_min: "",
      bonus_max: "",
      experience_years_company_min: "",
      experience_years_company_max: "",
      total_experience_years_min: "",
      total_experience_years_max: "",
      leave_days_min: "",
      leave_days_max: "",
      min_added_date: null,
      max_added_date: null,
      technical_stacks: [],
    };
    setFilters(initialFilters);
    setPendingFilters(initialFilters);
    setDateFilters({
      min_added_date: null,
      max_added_date: null,
    });
    setCurrentPage(1); // Reset to first page when resetting filters
    fetchSalaries(initialFilters);
  };

  const handleSort = (column) => {
    if (sortBy === column) {
      setSortOrder(sortOrder === "asc" ? "desc" : "asc");
    } else {
      setSortBy(column);
      setSortOrder("asc");
    }
  };

  const SortableHeader = ({ column, label }) => {
    const isSortedBy = sortBy === column;
    const icon = isSortedBy ? (sortOrder === "asc" ? "▲" : "▼") : "⇅";

    return (
      <th style={{ cursor: "pointer" }} onClick={() => handleSort(column)}>
        {label} {icon}
      </th>
    );
  };

  const handleItemsPerPageChange = (newItemsPerPage) => {
    setItemsPerPage(newItemsPerPage);
    setCurrentPage(1); // Reset to first page when changing items per page
  };

  const handleNextPage = () => {
    if (currentPage * itemsPerPage < totalItems) {
      setCurrentPage((prev) => prev + 1);
    }
  };

  const handlePrevPage = () => {
    if (currentPage > 1) {
      setCurrentPage((prev) => prev - 1);
    }
  };

  const renderSalaryRow = (salary) => {
    return (
      <tr key={salary.id}>
        <StickyCell left="0">{salary.company?.name || "N/A"}</StickyCell>
        <TableCell>{capitalizeWords(salary.location) || "N/A"}</TableCell>
        <TableCell>
          {salary.jobs?.length > 0 ? (
            <OverlayTrigger
              placement="right"
              overlay={
                <Tooltip id={`tooltip-job-title-${salary.id}`}>
                  {salary.jobs
                    .map((job) => capitalizeWords(job.title))
                    .join(", ")}
                </Tooltip>
              }
            >
              <span>
                {salary.jobs
                  .map((job) => capitalizeWords(job.title))
                  .join(", ")}
              </span>
            </OverlayTrigger>
          ) : (
            "N/A"
          )}
        </TableCell>
        <TableCell>
          {salary.gross_salary !== null ? salary.gross_salary : "N/A"}
        </TableCell>
        <TableCell>
          {salary.net_salary !== null ? salary.net_salary : "N/A"}
        </TableCell>
        <TableCell>{salary.bonus !== null ? salary.bonus : "N/A"}</TableCell>
        <TableCell>{capitalizeWords(salary.level) || "N/A"}</TableCell>
        <TableCell>{capitalizeWords(salary.work_type) || "N/A"}</TableCell>
        <TableCell>
          {salary.experience_years_company !== null
            ? salary.experience_years_company
            : "N/A"}
        </TableCell>
        <TableCell>
          {salary.total_experience_years !== null
            ? salary.total_experience_years
            : "N/A"}
        </TableCell>
        <TableCell>{capitalizeWords(salary.company?.type) || "N/A"}</TableCell>
        <TableCell>
          {salary.technical_stacks?.length > 0 ? (
            <OverlayTrigger
              placement="right"
              overlay={
                <Tooltip id={`tooltip-technical-stacks-${salary.id}`}>
                  {salary.technical_stacks
                    ?.map((stack) => capitalizeWords(stack.name))
                    .join(", ")}
                </Tooltip>
              }
            >
              <span>
                {salary.technical_stacks
                  ?.slice(0, 2)
                  .map((stack) => capitalizeWords(stack.name))
                  .join(", ")}
                {salary.technical_stacks?.length > 2 && "..."}
              </span>
            </OverlayTrigger>
          ) : (
            "N/A"
          )}
        </TableCell>
        <TableCell>
          {salary.company?.tags && salary.company.tags.length > 0 ? (
            <OverlayTrigger
              placement="right"
              overlay={
                <Tooltip id={`tooltip-tags-${salary.id}`}>
                  {salary.company.tags
                    .map((tag) => capitalizeWords(tag.name))
                    .join(", ")}
                </Tooltip>
              }
            >
              <span>
                {salary.company?.tags
                  ?.slice(0, 1)
                  .map((tag) => capitalizeWords(tag.name))
                  .join(", ")}
                {salary.company?.tags?.length > 1 && "..."}
              </span>
            </OverlayTrigger>
          ) : (
            "N/A"
          )}
        </TableCell>
        <TableCell>{capitalizeWords(salary.gender) || "N/A"}</TableCell>
        <TableCell>{salary.added_date || "N/A"}</TableCell>
        <TableCell>
          {salary.leave_days !== null ? salary.leave_days : "N/A"}
        </TableCell>
        <td>
          {salary.verified === "no" && (
            <span className="text-muted">{t.entities.verified.value.no}</span>
          )}
          {salary.verified === "pending" && (
            <span className="text-warning">
              <i className="bi bi-clock"></i>{" "}
              {t.entities.verified.value.pending}
            </span>
          )}
          {salary.verified === "verified" && (
            <span className="text-success">
              <i className="bi bi-check-circle"></i>{" "}
              {t.entities.verified.value.verified}
            </span>
          )}
        </td>
        <StickyCell right="0">
          <Button
            variant="info"
            size="sm"
            onClick={() => handleShowDetails(salary)}
          >
            {t.entities.actions.title}
          </Button>
        </StickyCell>
      </tr>
    );
  };

  const [selectedSalary, setSelectedSalary] = useState(null);
  const [showDetailsModal, setShowDetailsModal] = useState(false);

  const handleShowDetails = (salary) => {
    setSelectedSalary(salary);
    setShowDetailsModal(true);
  };

  const handleCloseDetails = () => {
    setShowDetailsModal(false);
  };

  return (
    <div className="mt-4">
      {successMessage && (
        <Alert
          variant="success"
          onClose={() => setSuccessMessage("")}
          dismissible
        >
          {successMessage}
        </Alert>
      )}

      {/* Toggle button for charts */}
      <ToggleButton
        variant="outline-primary"
        onClick={() => setShowCharts(!showCharts)}
      >
        {showCharts
          ? t.entities.buttons.show_charts.off
          : t.entities.buttons.show_charts.on}
      </ToggleButton>

      {/* Charts */}
      {showCharts &&
        locationStats.length > 0 &&
        topLocationsSalary.length > 0 && (
          <ChartRow>
            <ChartCol md={6}>
              <LocationPieChart data={locationStats} />
            </ChartCol>
            <ChartCol md={6}>
              <TopLocationsSalaryBarChart data={topLocationsSalary} />
            </ChartCol>
          </ChartRow>
        )}

      {/* Buttons */}
      <ButtonContainer fluid className="px-3">
        <Row className="gy-2 justify-content-start align-items-center">
          <Col xs="auto" className="mb-2 mb-sm-0 ms-sm-0">
            <Button variant="primary" onClick={handleOpenAddSalaryModal}>
              {t.entities.buttons.add_salary}
            </Button>
          </Col>
          <Col xs="auto" className="mb-2 mb-sm-0 ms-sm-0">
            <Button variant="primary" onClick={() => setShowFilterModal(true)}>
              {t.entities.buttons.filters}
            </Button>
          </Col>
          <Col xs="auto" className="mb-2 mb-sm-0 ms-sm-0">
            <Dropdown as={ButtonGroup}>
              <Button variant="primary">
                {t.entities.buttons.show_results}: {itemsPerPage}
              </Button>
              <Dropdown.Toggle
                split
                variant="primary"
                id="dropdown-split-basic"
              />
              <Dropdown.Menu>
                {[10, 25, 50, 100].map((num) => (
                  <Dropdown.Item
                    key={num}
                    onClick={() => handleItemsPerPageChange(num)}
                  >
                    {num}
                  </Dropdown.Item>
                ))}
              </Dropdown.Menu>
            </Dropdown>
          </Col>
          <Col xs="auto" className="mb-2 mb-sm-0 ms-sm-0">
            <ButtonGroup>
              <Button onClick={handlePrevPage} disabled={currentPage === 1}>
                &lt;
              </Button>
              <Button
                onClick={handleNextPage}
                disabled={currentPage * itemsPerPage >= totalItems}
              >
                &gt;
              </Button>
            </ButtonGroup>
          </Col>
        </Row>
      </ButtonContainer>

      <AddSalaryForm
        show={showAddSalaryModal}
        handleClose={handleCloseAddSalaryModal}
        onSalaryAdded={handleSalaryAdded}
        choices={choices}
      />

      <Modal
        show={showFilterModal}
        onHide={() => setShowFilterModal(false)}
        dialogClassName="modal-100w"
        contentClassName="h-100"
      >
        <Modal.Header closeButton>
          <Modal.Title>{t.entities.title.filters}</Modal.Title>
        </Modal.Header>
        <Modal.Body
          style={{ ...fullScreenModalStyle.modalContent, overflowY: "auto" }}
        >
          <Form onSubmit={handleFilterSubmit}>
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
                  isCreatable={true} // Allow creating new options
                  onCreateOption={(inputValue) => {
                    const newLocation = capitalizeWords(inputValue);
                    setChoices((prev) => ({
                      ...prev,
                      locations: [...prev.locations, newLocation],
                    }));
                    return { value: newLocation, label: newLocation };
                  }}
                />
              </Col>
              <Col md={4}>
                <SelectWithTooltip
                  options={[
                    { value: "male", label: t.entities.gender.value.male },
                    { value: "female", label: t.entities.gender.value.female },
                    { value: "other", label: t.entities.gender.value.other },
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
                    { value: "no", label: t.entities.verified.value.no },
                    {
                      value: "pending",
                      label: t.entities.verified.value.pending,
                    },
                    {
                      value: "verified",
                      label: t.entities.verified.value.verified,
                    },
                  ]}
                  onChange={handleMultiSelectChange}
                  placeholder={t.entities.verified.plural}
                  title={t.entities.verified.plural}
                  value={pendingFilters.verifications || []}
                  name="verifications"
                />
              </Col>
            </Row>
            <Row className="mt-4">
              <Col>
                <Button
                  variant="secondary"
                  onClick={() => setShowFilterModal(false)}
                  data-testid="close-filter-modal"
                >
                  {t.entities.buttons.close}
                </Button>
                <Button variant="primary" type="submit" className="ms-2">
                  {t.entities.buttons.apply_filters}
                </Button>
                <Button
                  variant="outline-secondary"
                  onClick={resetFilters}
                  className="ms-2"
                >
                  {t.entities.buttons.reset_filters}
                </Button>
              </Col>
            </Row>
          </Form>
        </Modal.Body>
      </Modal>

      {isLoading && (
        <LoadingOverlay>
          <div className="spinner-border" role="status">
            <span className="visually-hidden">
              {t.entities.info.loading} ...
            </span>
          </div>
        </LoadingOverlay>
      )}

      <ScrollableWrapper>
        <StyledTable striped bordered hover>
          <thead>
            <tr>
              <StickyCell as="th" left="0">
                {t.entities.company.name.singular}
              </StickyCell>
              <SortableHeader
                column="location"
                label={t.entities.location.singular}
              />
              <th>{t.entities.job.titles.singular}</th>
              <SortableHeader
                column="gross_salary"
                label={t.entities.gross_salary.singular}
              />
              <SortableHeader
                column="net_salary"
                label={t.entities.net_salary.singular}
              />
              <SortableHeader
                column="bonus"
                label={t.entities.bonus.singular}
              />
              <th>{t.entities.level.singular}</th>
              <th>{t.entities.work_type.singular}</th>
              <SortableHeader
                column="experience_years_company"
                label={t.entities.experience_years_company.singular}
              />
              <SortableHeader
                column="total_experience_years"
                label={t.entities.total_experience_years.singular}
              />
              <th>{t.entities.company.type.singular}</th>
              <th>{t.entities.technical_stacks.singular}</th>
              <th>{t.entities.company.tags.singular}</th>
              <th>{t.entities.gender.singular}</th>
              <SortableHeader
                column="added_date"
                label={t.entities.added_date.singular}
              />
              <SortableHeader
                column="leave_days"
                label={t.entities.leave_days.singular}
              />
              <th>{t.entities.verified.singular}</th>
              <StickyCell as="th" right="0">
                {t.entities.actions.name}
              </StickyCell>
            </tr>
          </thead>
          <tbody>
            {error ? (
              <tr>
                <td colSpan="17">{error}</td>
              </tr>
            ) : salaries.length > 0 ? (
              salaries.map(renderSalaryRow)
            ) : (
              <tr>
                <td colSpan="17">{t.entities.errors.no_salaries}</td>
              </tr>
            )}
          </tbody>
        </StyledTable>
      </ScrollableWrapper>

      <Modal show={showDetailsModal} onHide={handleCloseDetails}>
        <Modal.Header closeButton>
          <Modal.Title>{t.entities.actions.title}</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          {selectedSalary && (
            <div>
              <p>
                <strong>{t.entities.company.name.singular}:</strong>{" "}
                {selectedSalary.company?.name || "N/A"}
              </p>
              <p>
                <strong>{t.entities.company.tags.singular}:</strong>{" "}
                {selectedSalary.company?.tags
                  ?.map((tag) => capitalizeWords(tag.name))
                  .join(", ") || "N/A"}
              </p>
              <p>
                <strong>{t.entities.company.type.singular}:</strong>{" "}
                {capitalizeWords(selectedSalary.company?.type) || "N/A"}
              </p>
              <p>
                <strong>{t.entities.job.titles.singular}:</strong>{" "}
                {selectedSalary.jobs
                  ?.map((job) => capitalizeWords(job.title))
                  .join(", ") || "N/A"}
              </p>
              <p>
                <strong>{t.entities.technical_stacks.singular}:</strong>{" "}
                {selectedSalary.technical_stacks
                  ?.map((stack) => capitalizeWords(stack.name))
                  .join(", ") || "N/A"}
              </p>
              <p>
                <strong>{t.entities.location.singular}:</strong>{" "}
                {capitalizeWords(selectedSalary.location) || "N/A"}
              </p>
              <p>
                <strong>{t.entities.net_salary.singular}:</strong>{" "}
                {selectedSalary.net_salary !== null
                  ? selectedSalary.net_salary
                  : "N/A"}
              </p>
              <p>
                <strong>{t.entities.gross_salary.singular}:</strong>{" "}
                {selectedSalary.gross_salary !== null
                  ? selectedSalary.gross_salary
                  : "N/A"}
              </p>
              <p>
                <strong>{t.entities.bonus.singular}:</strong>{" "}
                {selectedSalary.bonus !== null ? selectedSalary.bonus : "N/A"}
              </p>
              <p>
                <strong>{t.entities.gender.singular}:</strong>{" "}
                {capitalizeWords(selectedSalary.gender) || "N/A"}
              </p>
              <p>
                <strong>{t.entities.experience_years_company.singular}:</strong>{" "}
                {selectedSalary.experience_years_company !== null
                  ? selectedSalary.experience_years_company
                  : "N/A"}
              </p>
              <p>
                <strong>{t.entities.total_experience_years.singular}:</strong>{" "}
                {selectedSalary.total_experience_years !== null
                  ? selectedSalary.total_experience_years
                  : "N/A"}
              </p>
              <p>
                <strong>{t.entities.level.singular}:</strong>{" "}
                {capitalizeWords(selectedSalary.level) || "N/A"}
              </p>
              <p>
                <strong>{t.entities.work_type.singular}:</strong>{" "}
                {capitalizeWords(selectedSalary.work_type) || "N/A"}
              </p>
              <p>
                <strong>{t.entities.added_date.singular}:</strong>{" "}
                {selectedSalary.added_date || "N/A"}
              </p>
              <p>
                <strong>{t.entities.leave_days.singular}:</strong>{" "}
                {selectedSalary.leave_days !== null
                  ? selectedSalary.leave_days
                  : "N/A"}
              </p>
            </div>
          )}
        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={handleCloseDetails}>
            {t.entities.buttons.close}
          </Button>
        </Modal.Footer>
      </Modal>
    </div>
  );
};

export default SalaryListPage;
