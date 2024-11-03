import React, { useState, useEffect, useCallback, useMemo } from "react";
import {
  Button,
  Row,
  Col,
  Modal,
  Alert,
  Dropdown,
  ButtonGroup,
  Container,
} from "react-bootstrap";
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
import styled from "styled-components";
import { useLanguage, translations } from "../contexts/LanguageContext";
import "react-datepicker/dist/react-datepicker.css";
import SalaryTable from "../components/tables/SalaryTable";
import SalaryModalFilters from "../components/filters/SalaryModalFilters";
import SalaryDetailsModal from "../components/modals/SalaryDetailsModal";

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

const StyledModal = styled(Modal)`
  .modal-dialog {
    max-width: 90%;
    margin: 1rem auto;

    @media (max-width: 767px) {
      max-width: 95%; // Increase width on mobile
      margin: 0.5rem auto;
    }
  }

  .modal-content {
    max-height: calc(100vh - 2rem);
    width: 100%; // Ensure content doesn't overflow

    @media (max-width: 767px) {
      max-height: calc(100vh - 1rem);
      margin: 0;
    }
  }

  .modal-body {
    padding: 0.5rem;
    overflow-x: hidden; // Prevent horizontal scroll
  }

  .modal-header {
    padding: 0.75rem 1rem;
  }
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
  const [showCharts, setShowCharts] = useState(false);

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
                {t.entities.buttons.pagination.show}: {itemsPerPage}
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

      {/* Add Salary Form */}
      <AddSalaryForm
        show={showAddSalaryModal}
        handleClose={handleCloseAddSalaryModal}
        onSalaryAdded={handleSalaryAdded}
        choices={choices}
      />

      {/* Filter Modal */}
      <StyledModal
        show={showFilterModal}
        onHide={() => setShowFilterModal(false)}
        size="xl"
      >
        <Modal.Header closeButton>
          <Modal.Title>{t.entities.title.filters}</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <SalaryModalFilters
            pendingFilters={pendingFilters}
            dateFilters={dateFilters}
            handleMultiSelectChange={handleMultiSelectChange}
            handleInputChangeImmediate={handleInputChangeImmediate}
            handleDateChange={handleDateChange}
            choices={choices}
            t={t}
            onSubmit={handleFilterSubmit}
            onClose={() => setShowFilterModal(false)}
            onReset={resetFilters}
          />
        </Modal.Body>
      </StyledModal>

      {/* Loading Overlay */}
      {isLoading && (
        <LoadingOverlay>
          <div className="spinner-border" role="status">
            <span className="visually-hidden">
              {t.entities.info.loading} ...
            </span>
          </div>
        </LoadingOverlay>
      )}

      {/* Salary Table */}
      <SalaryTable
        salaries={salaries}
        error={error}
        sortBy={sortBy}
        sortOrder={sortOrder}
        onSort={handleSort}
        handleShowDetails={handleShowDetails}
        t={t}
      />

      {/* Salary Details Modal */}
      <SalaryDetailsModal
        show={showDetailsModal}
        onClose={handleCloseDetails}
        salary={selectedSalary}
        t={t}
      />
    </div>
  );
};

export default SalaryListPage;
