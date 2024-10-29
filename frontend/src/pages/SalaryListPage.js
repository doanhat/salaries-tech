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
import AddSalaryForm from "../components/salary/AddSalaryForm";
import LocationPieChart from "../components/dashboard/LocationsPieChart";
import TopLocationsSalaryBarChart from "../components/dashboard/TopLocationsBarChart";
import { debounce } from "lodash";
import { capitalizeWords } from "../utils/stringUtils";
import { useMediaQuery } from "react-responsive";
import styled from "styled-components";
import { useLanguage } from "../contexts/LanguageContext";
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

const translations = {
  fr: {
    table: {
      company: "Entreprise",
      location: "Localisation",
      job_title: "Poste",
      gross_salary: "Salaire Brut",
      net_salary: "Salaire Net",
      variables: "Primes",
      level: "Niveau",
      work_type: "Type de contrat",
      experience_years_company: "Exp Entreprise",
      total_experience_years: "Exp Totale",
      company_type: "Type d'entreprise",
      technical_stacks: "Stacks techniques",
      tags: "Tags",
      gender: "Genre",
      gender_value: {
        male: "Homme",
        female: "Femme",
        other: "Autre",
      },
      added_date: "Date d'ajout",
      leave_days: "Jours de congé",
      actions: {
        name: "Actions",
        title: "Détails",
      },
    },
    filters: {
      title: "Filtres",
      companies: "Entreprises",
      tags: "Tags",
      company_types: "Types d'entreprises",
      job_titles: "Postes",
      locations: "Localisations",
      genders: "Genres",
      gender_value: {
        male: "Homme",
        female: "Femme",
        other: "Autre",
      },
      levels: "Niveaux",
      work_types: "Types de contrat",
      net_salary_min: "Salaire Net Min",
      net_salary_max: "Salaire Net Max",
      gross_salary_min: "Salaire Brut Min",
      gross_salary_max: "Salaire Brut Max",
      variables_min: "Primes Min",
      variables_max: "Primes Max",
      experience_years_company_min: "Exp Entreprise Min",
      experience_years_company_max: "Exp Entreprise Max",
      total_experience_years_min: "Exp Totale Min",
      total_experience_years_max: "Exp Totale Max",
      leave_days_min: "Jours de congé Min",
      leave_days_max: "Jours de congé Max",
      added_date_min: "Date d'ajout Min",
      added_date_max: "Date d'ajout Max",
      technical_stacks: "Stacks techniques",
    },
    buttons: {
      add_salary: "Ajouter un salaire",
      filters: "Filtres",
      apply_filters: "Appliquer les filtres",
      reset_filters: "Réinitialiser les filtres",
      show_charts: {
        on: "Afficher les graphiques",
        off: "Masquer les graphiques",
      },
      show_results: "Afficher",
      close: "Fermer",
    },
    errors: {
      no_salaries: "Aucun salaire trouvé.",
      add: "Erreur lors de l'ajout du salaire. Veuillez réessayer.",
    },
    info: {
      no_filters_applied: "Aucun filtre appliqué.",
      loading: "Chargement des données...",
    },
  },
  en: {
    table: {
      company: "Company",
      location: "Location",
      job_title: "Job Title",
      gross_salary: "Gross Salary",
      net_salary: "Net Salary",
      variables: "Variables",
      level: "Level",
      work_type: "Work Type",
      experience_years_company: "Company Exp",
      total_experience_years: "Total Exp",
      company_type: "Company Type",
      technical_stacks: "Technical Stacks",
      tags: "Tags",
      gender: "Gender",
      gender_value: {
        male: "Male",
        female: "Female",
        other: "Other",
      },
      added_date: "Added Date",
      leave_days: "Leave Days",
      actions: {
        name: "Actions",
        title: "Details",
      },
    },
    filters: {
      title: "Filters",
      companies: "Companies",
      tags: "Tags",
      company_types: "Company Types",
      job_titles: "Job Titles",
      locations: "Locations",
      genders: "Genders",
      gender_value: {
        male: "Male",
        female: "Female",
        other: "Other",
      },
      levels: "Levels",
      work_types: "Work Types",
      net_salary_min: "Net Salary Min",
      net_salary_max: "Net Salary Max",
      gross_salary_min: "Gross Salary Min",
      gross_salary_max: "Gross Salary Max",
      variables_min: "Variables Min",
      variables_max: "Variables Max",
      experience_years_company_min: "Company Exp Min",
      experience_years_company_max: "Company Exp Max",
      total_experience_years_min: "Total Exp Min",
      total_experience_years_max: "Total Exp Max",
      leave_days_min: "Leave Days Min",
      leave_days_max: "Leave Days Max",
      added_date_min: "Added Date Min",
      added_date_max: "Added Date Max",
      technical_stacks: "Technical Stacks",
    },
    buttons: {
      add_salary: "Add a Salary",
      filters: "Filters",
      apply_filters: "Apply Filters",
      reset_filters: "Reset Filters",
      show_charts: {
        on: "Show Charts",
        off: "Hide Charts",
      },
      show_results: "Show",
      close: "Close",
    },
    errors: {
      no_salaries: "No salaries found.",
      add: "Error adding salary. Please try again.",
    },
    info: {
      no_filters_applied: "No filters applied.",
      loading: "Loading data...",
    },
  },
};

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
    variables_min: "",
    variables_max: "",
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
      const response = await addSalary(newSalary, captchaToken);
      console.log("Salary added successfully:", response);
      setSuccessMessage("Salary added successfully!");
      setShowAddSalaryModal(false);
      fetchSalaries(); // Refresh the salary list
    } catch (error) {
      console.error("Error adding salary:", error);
      let errorMessage = "Failed to add salary. Please try again.";
      if (error.message) {
        try {
          const parsedError = JSON.parse(error.message);
          if (parsedError.detail && Array.isArray(parsedError.detail)) {
            errorMessage = parsedError.detail.map((err) => err.msg).join(", ");
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
      variables_min: "",
      variables_max: "",
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

  const genderOptions = [
    { value: "male", label: "Male" },
    { value: "female", label: "Female" },
    { value: "other", label: "Other" },
  ];

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
        <TableCell>
          {salary.variables !== null ? salary.variables : "N/A"}
        </TableCell>
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
        <StickyCell right="0">
          <Button
            variant="info"
            size="sm"
            onClick={() => handleShowDetails(salary)}
          >
            {t.table.actions.title}
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
        {showCharts ? t.buttons.show_charts.off : t.buttons.show_charts.on}
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
              {t.buttons.add_salary}
            </Button>
          </Col>
          <Col xs="auto" className="mb-2 mb-sm-0 ms-sm-0">
            <Button variant="primary" onClick={() => setShowFilterModal(true)}>
              {t.buttons.filters}
            </Button>
          </Col>
          <Col xs="auto" className="mb-2 mb-sm-0 ms-sm-0">
            <Dropdown as={ButtonGroup}>
              <Button variant="primary">
                {t.buttons.show_results}: {itemsPerPage}
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
          <Modal.Title>{t.filters.title}</Modal.Title>
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
                  placeholder={t.filters.companies}
                  title={t.filters.companies}
                  value={pendingFilters.company_names || []}
                  name="company_names"
                />
              </Col>
              <Col md={4}>
                <SelectWithTooltip
                  options={createOptions(choices.company_tags || [])}
                  onChange={handleMultiSelectChange}
                  placeholder={t.filters.tags}
                  title={t.filters.tags}
                  value={pendingFilters.company_tags || []}
                  name="company_tags"
                />
              </Col>
              <Col md={4}>
                <SelectWithTooltip
                  options={createOptions(choices.company_types || [])}
                  onChange={handleMultiSelectChange}
                  placeholder={t.filters.company_types}
                  title={t.filters.company_types}
                  value={pendingFilters.company_types || []}
                  name="company_types"
                />
              </Col>
              <Col md={4}>
                <SelectWithTooltip
                  options={createOptions(choices.job_titles || [])}
                  onChange={handleMultiSelectChange}
                  placeholder={t.filters.job_titles}
                  title={t.filters.job_titles}
                  value={pendingFilters.job_titles || []}
                  name="job_titles"
                />
              </Col>
              <Col md={4}>
                <SelectWithTooltip
                  options={createOptions(choices.technical_stacks || [])}
                  onChange={handleMultiSelectChange}
                  placeholder={t.filters.technical_stacks}
                  title={t.filters.technical_stacks}
                  value={pendingFilters.technical_stacks || []}
                  name="technical_stacks"
                  isMulti
                />
              </Col>
              <Col md={4}>
                <SelectWithTooltip
                  options={createOptions(choices.locations || [])}
                  onChange={handleMultiSelectChange}
                  placeholder={t.filters.locations}
                  title={t.filters.locations}
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
                    { value: "male", label: t.filters.gender_value.male },
                    { value: "female", label: t.filters.gender_value.female },
                    { value: "other", label: t.filters.gender_value.other },
                  ]}
                  onChange={handleMultiSelectChange}
                  placeholder={t.filters.genders}
                  title={t.filters.genders}
                  value={pendingFilters.genders}
                  name="genders"
                />
              </Col>
              <Col md={4}>
                <SelectWithTooltip
                  options={createOptions(choices.levels || [])}
                  onChange={handleMultiSelectChange}
                  placeholder={t.filters.levels}
                  title={t.filters.levels}
                  value={pendingFilters.levels || []}
                  name="levels"
                />
              </Col>
              <Col md={4}>
                <SelectWithTooltip
                  options={createOptions(choices.work_types || [])}
                  onChange={handleMultiSelectChange}
                  placeholder={t.filters.work_types}
                  title={t.filters.work_types}
                  value={pendingFilters.work_types || []}
                  name="work_types"
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder={t.filters.net_salary_min}
                  name="net_salary_min"
                  onChange={handleInputChangeImmediate}
                  title={t.filters.net_salary_min}
                  value={pendingFilters.net_salary_min}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder={t.filters.net_salary_max}
                  name="net_salary_max"
                  onChange={handleInputChangeImmediate}
                  title={t.filters.net_salary_max}
                  value={pendingFilters.net_salary_max}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder={t.filters.gross_salary_min}
                  name="gross_salary_min"
                  onChange={handleInputChangeImmediate}
                  title={t.filters.gross_salary_min}
                  value={pendingFilters.gross_salary_min}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder={t.filters.gross_salary_max}
                  name="gross_salary_max"
                  onChange={handleInputChangeImmediate}
                  title={t.filters.gross_salary_max}
                  value={pendingFilters.gross_salary_max}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder={t.filters.variables_min}
                  name="variables_min"
                  onChange={handleInputChangeImmediate}
                  title={t.filters.variables_min}
                  value={pendingFilters.variables_min}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder={t.filters.variables_max}
                  name="variables_max"
                  onChange={handleInputChangeImmediate}
                  title={t.filters.variables_max}
                  value={pendingFilters.variables_max}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder={t.filters.experience_years_company_min}
                  name="experience_years_company_min"
                  onChange={handleInputChangeImmediate}
                  title={t.filters.experience_years_company_min}
                  value={pendingFilters.experience_years_company_min}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder={t.filters.experience_years_company_max}
                  name="experience_years_company_max"
                  onChange={handleInputChangeImmediate}
                  title={t.filters.experience_years_company_max}
                  value={pendingFilters.experience_years_company_max}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder={t.filters.total_experience_years_min}
                  name="total_experience_years_min"
                  onChange={handleInputChangeImmediate}
                  title={t.filters.total_experience_years_min}
                  value={pendingFilters.total_experience_years_min}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder={t.filters.total_experience_years_max}
                  name="total_experience_years_max"
                  onChange={handleInputChangeImmediate}
                  title={t.filters.total_experience_years_max}
                  value={pendingFilters.total_experience_years_max}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder={t.filters.leave_days_min}
                  name="leave_days_min"
                  onChange={handleInputChangeImmediate}
                  title={t.filters.leave_days_min}
                  value={pendingFilters.leave_days_min}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder={t.filters.leave_days_max}
                  name="leave_days_max"
                  onChange={handleInputChangeImmediate}
                  title={t.filters.leave_days_max}
                  value={pendingFilters.leave_days_max}
                />
              </Col>
              <Col md={4}>
                <DatePickerWithTooltip
                  name="min_added_date"
                  selected={dateFilters.min_added_date}
                  onChange={(date) => handleDateChange(date, "min_added_date")}
                  title={t.filters.added_date_min}
                />
              </Col>
              <Col md={4}>
                <DatePickerWithTooltip
                  name="max_added_date"
                  selected={dateFilters.max_added_date}
                  onChange={(date) => handleDateChange(date, "max_added_date")}
                  title={t.filters.added_date_max}
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
                  {t.buttons.close}
                </Button>
                <Button variant="primary" type="submit" className="ms-2">
                  {t.buttons.apply_filters}
                </Button>
                <Button
                  variant="outline-secondary"
                  onClick={resetFilters}
                  className="ms-2"
                >
                  {t.buttons.reset_filters}
                </Button>
              </Col>
            </Row>
          </Form>
        </Modal.Body>
      </Modal>

      {isLoading && (
        <LoadingOverlay>
          <div className="spinner-border" role="status">
            <span className="visually-hidden">{t.info.loading} ...</span>
          </div>
        </LoadingOverlay>
      )}

      <ScrollableWrapper>
        <StyledTable striped bordered hover>
          <thead>
            <tr>
              <StickyCell as="th" left="0">
                {t.table.company}
              </StickyCell>
              <SortableHeader column="location" label={t.table.location} />
              <th>{t.table.job_title}</th>
              <SortableHeader
                column="gross_salary"
                label={t.table.gross_salary}
              />
              <SortableHeader column="net_salary" label={t.table.net_salary} />
              <SortableHeader column="variables" label={t.table.variables} />
              <th>{t.table.level}</th>
              <th>{t.table.work_type}</th>
              <SortableHeader
                column="experience_years_company"
                label={t.table.experience_years_company}
              />
              <SortableHeader
                column="total_experience_years"
                label={t.table.total_experience_years}
              />
              <th>{t.table.company_type}</th>
              <th>{t.table.technical_stacks}</th>
              <th>{t.table.tags}</th>
              <th>{t.table.gender}</th>
              <SortableHeader column="added_date" label={t.table.added_date} />
              <SortableHeader column="leave_days" label={t.table.leave_days} />
              <StickyCell as="th" right="0">
                {t.table.actions.name}
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
                <td colSpan="17">{t.errors.no_salaries}</td>
              </tr>
            )}
          </tbody>
        </StyledTable>
      </ScrollableWrapper>

      <Modal show={showDetailsModal} onHide={handleCloseDetails}>
        <Modal.Header closeButton>
          <Modal.Title>{t.table.actions.title}</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          {selectedSalary && (
            <div>
              <p>
                <strong>{t.table.company}:</strong>{" "}
                {selectedSalary.company?.name || "N/A"}
              </p>
              <p>
                <strong>{t.table.tags}:</strong>{" "}
                {selectedSalary.company?.tags
                  ?.map((tag) => capitalizeWords(tag.name))
                  .join(", ") || "N/A"}
              </p>
              <p>
                <strong>{t.table.company_type}:</strong>{" "}
                {capitalizeWords(selectedSalary.company?.type) || "N/A"}
              </p>
              <p>
                <strong>{t.table.job_title}:</strong>{" "}
                {selectedSalary.jobs
                  ?.map((job) => capitalizeWords(job.title))
                  .join(", ") || "N/A"}
              </p>
              <p>
                <strong>{t.table.technical_stacks}:</strong>{" "}
                {selectedSalary.technical_stacks
                  ?.map((stack) => capitalizeWords(stack.name))
                  .join(", ") || "N/A"}
              </p>
              <p>
                <strong>{t.table.location}:</strong>{" "}
                {capitalizeWords(selectedSalary.location) || "N/A"}
              </p>
              <p>
                <strong>{t.table.net_salary}:</strong>{" "}
                {selectedSalary.net_salary !== null
                  ? selectedSalary.net_salary
                  : "N/A"}
              </p>
              <p>
                <strong>{t.table.gross_salary}:</strong>{" "}
                {selectedSalary.gross_salary !== null
                  ? selectedSalary.gross_salary
                  : "N/A"}
              </p>
              <p>
                <strong>{t.table.variables}:</strong>{" "}
                {selectedSalary.variables !== null
                  ? selectedSalary.variables
                  : "N/A"}
              </p>
              <p>
                <strong>{t.table.gender}:</strong>{" "}
                {capitalizeWords(selectedSalary.gender) || "N/A"}
              </p>
              <p>
                <strong>{t.table.experience_years_company}:</strong>{" "}
                {selectedSalary.experience_years_company !== null
                  ? selectedSalary.experience_years_company
                  : "N/A"}
              </p>
              <p>
                <strong>{t.table.total_experience_years}:</strong>{" "}
                {selectedSalary.total_experience_years !== null
                  ? selectedSalary.total_experience_years
                  : "N/A"}
              </p>
              <p>
                <strong>{t.table.level}:</strong>{" "}
                {capitalizeWords(selectedSalary.level) || "N/A"}
              </p>
              <p>
                <strong>{t.table.work_type}:</strong>{" "}
                {capitalizeWords(selectedSalary.work_type) || "N/A"}
              </p>
              <p>
                <strong>{t.table.added_date}:</strong>{" "}
                {selectedSalary.added_date || "N/A"}
              </p>
              <p>
                <strong>{t.table.leave_days}:</strong>{" "}
                {selectedSalary.leave_days !== null
                  ? selectedSalary.leave_days
                  : "N/A"}
              </p>
            </div>
          )}
        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={handleCloseDetails}>
            {t.buttons.close}
          </Button>
        </Modal.Footer>
      </Modal>
    </div>
  );
};

export default SalaryListPage;
