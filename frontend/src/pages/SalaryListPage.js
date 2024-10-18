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
} from "react-bootstrap";
import Select from "react-select";
import DatePicker from "react-datepicker";
import {
  getSalaries,
  getChoices,
  getSalaryStats,
  addSalary,
} from "../utils/api";
import AddSalaryForm from "../components/salary/AddSalaryForm";
import SalaryPieChart from "../components/dashboard/SalaryPieChart";
import TopCitiesBarChart from "../components/dashboard/TopCitiesBarChart";
import { debounce } from "lodash";
import { capitalizeWords } from "../utils/stringUtils";

import "react-datepicker/dist/react-datepicker.css";

const SalaryListPage = () => {
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
  const [stats, setStats] = useState(null);
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

  const fetchStats = useCallback(async () => {
    try {
      const data = await getSalaryStats();
      setStats(data);
    } catch (error) {
      console.error("Failed to fetch salary stats:", error);
    }
  }, []);

  useEffect(() => {
    fetchChoices();
    fetchStats();
    fetchSalaries();
  }, [fetchChoices, fetchStats, fetchSalaries]);

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

  const handleSalaryAdded = async (newSalary) => {
    try {
      const response = await addSalary(newSalary);
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
    fetchSalaries();
  };

  const genderOptions = [
    { value: "male", label: "Male" },
    { value: "female", label: "Female" },
    { value: "other", label: "Other" },
  ];

  const handleSort = (column) => {
    if (column === sortBy) {
      setSortOrder(sortOrder === "asc" ? "desc" : "asc");
    } else {
      setSortBy(column);
      setSortOrder("asc");
    }
  };

  const SortableHeader = ({ column, label }) => (
    <th onClick={() => handleSort(column)} style={{ cursor: "pointer" }}>
      {label}{" "}
      {sortBy === column ? (
        sortOrder === "asc" ? (
          "▲"
        ) : (
          "▼"
        )
      ) : (
        <span style={{ opacity: 0.3 }}>▲▼</span>
      )}
    </th>
  );

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

      {stats && (
        <Row className="mb-4">
          <Col md={6}>
            <SalaryPieChart data={stats.avg_salary_by_city} />
          </Col>
          <Col md={6}>
            <TopCitiesBarChart data={stats.top_10_cities} />
          </Col>
        </Row>
      )}

      <div className="mb-3 text-start ps-3 d-flex align-items-center">
        <Button
          variant="primary"
          onClick={handleOpenAddSalaryModal}
          className="me-2"
        >
          Add New Salary
        </Button>
        <Button
          variant="primary"
          onClick={() => setShowFilterModal(true)}
          className="me-2"
        >
          Open Filters
        </Button>
        <Dropdown as={ButtonGroup} className="me-2">
          <Button variant="secondary">Show Results: {itemsPerPage}</Button>
          <Dropdown.Toggle
            split
            variant="secondary"
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
        <ButtonGroup>
          <Button onClick={handlePrevPage} disabled={currentPage === 1}>
            &lt; Previous
          </Button>
          <Button
            onClick={handleNextPage}
            disabled={currentPage * itemsPerPage >= totalItems}
          >
            Next &gt;
          </Button>
        </ButtonGroup>
      </div>

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
          <Modal.Title>Salary Filters</Modal.Title>
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
                  placeholder="Companies"
                  title="Select Companies"
                  value={pendingFilters.company_names || []}
                  name="company_names"
                />
              </Col>
              <Col md={4}>
                <SelectWithTooltip
                  options={createOptions(choices.company_tags || [])}
                  onChange={handleMultiSelectChange}
                  placeholder="Tags"
                  title="Select Tags"
                  value={pendingFilters.company_tags || []}
                  name="company_tags"
                />
              </Col>
              <Col md={4}>
                <SelectWithTooltip
                  options={createOptions(choices.company_types || [])}
                  onChange={handleMultiSelectChange}
                  placeholder="Company Types"
                  title="Select Company Types"
                  value={pendingFilters.company_types || []}
                  name="company_types"
                />
              </Col>
              <Col md={4}>
                <SelectWithTooltip
                  options={createOptions(choices.job_titles || [])}
                  onChange={handleMultiSelectChange}
                  placeholder="Job Titles"
                  title="Select Job Titles"
                  value={pendingFilters.job_titles || []}
                  name="job_titles"
                />
              </Col>
              <Col md={4}>
                <SelectWithTooltip
                  options={createOptions(choices.technical_stacks || [])}
                  onChange={handleMultiSelectChange}
                  placeholder="Technical Stacks"
                  title="Select Technical Stacks"
                  value={pendingFilters.technical_stacks || []}
                  name="technical_stacks"
                  isMulti
                />
              </Col>
              <Col md={4}>
                <SelectWithTooltip
                  options={createOptions(choices.locations || [])}
                  onChange={handleMultiSelectChange}
                  placeholder="Locations"
                  title="Select Locations"
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
                  options={genderOptions}
                  onChange={handleMultiSelectChange}
                  placeholder="Gender"
                  title="Select Gender"
                  value={pendingFilters.genders}
                  name="genders"
                />
              </Col>
              <Col md={4}>
                <SelectWithTooltip
                  options={createOptions(choices.levels || [])}
                  onChange={handleMultiSelectChange}
                  placeholder="Levels"
                  title="Select Levels"
                  value={pendingFilters.levels || []}
                  name="levels"
                />
              </Col>
              <Col md={4}>
                <SelectWithTooltip
                  options={createOptions(choices.work_types || [])}
                  onChange={handleMultiSelectChange}
                  placeholder="Work Types"
                  title="Select Work Types"
                  value={pendingFilters.work_types || []}
                  name="work_types"
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder="Min Net Salary"
                  name="net_salary_min"
                  onChange={handleInputChangeImmediate}
                  title="Minimum Net Salary"
                  value={pendingFilters.net_salary_min}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder="Max Net Salary"
                  name="net_salary_max"
                  onChange={handleInputChangeImmediate}
                  title="Maximum Net Salary"
                  value={pendingFilters.net_salary_max}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder="Min Gross Salary"
                  name="gross_salary_min"
                  onChange={handleInputChangeImmediate}
                  title="Minimum Gross Salary"
                  value={pendingFilters.gross_salary_min}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder="Max Gross Salary"
                  name="gross_salary_max"
                  onChange={handleInputChangeImmediate}
                  title="Maximum Gross Salary"
                  value={pendingFilters.gross_salary_max}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder="Min Variables"
                  name="variables_min"
                  onChange={handleInputChangeImmediate}
                  title="Minimum Variables"
                  value={pendingFilters.variables_min}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder="Max Variables"
                  name="variables_max"
                  onChange={handleInputChangeImmediate}
                  title="Maximum Variables"
                  value={pendingFilters.variables_max}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder="Min Company Experience"
                  name="experience_years_company_min"
                  onChange={handleInputChangeImmediate}
                  title="Minimum Company Experience"
                  value={pendingFilters.experience_years_company_min}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder="Max Company Experience"
                  name="experience_years_company_max"
                  onChange={handleInputChangeImmediate}
                  title="Maximum Company Experience"
                  value={pendingFilters.experience_years_company_max}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder="Min Total Experience"
                  name="total_experience_years_min"
                  onChange={handleInputChangeImmediate}
                  title="Minimum Total Experience"
                  value={pendingFilters.total_experience_years_min}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder="Max Total Experience"
                  name="total_experience_years_max"
                  onChange={handleInputChangeImmediate}
                  title="Maximum Total Experience"
                  value={pendingFilters.total_experience_years_max}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder="Min Leave Days"
                  name="leave_days_min"
                  onChange={handleInputChangeImmediate}
                  title="Minimum Leave Days"
                  value={pendingFilters.leave_days_min}
                />
              </Col>
              <Col md={4}>
                <InputWithTooltip
                  type="number"
                  placeholder="Max Leave Days"
                  name="leave_days_max"
                  onChange={handleInputChangeImmediate}
                  title="Maximum Leave Days"
                  value={pendingFilters.leave_days_max}
                />
              </Col>
              <Col md={4}>
                <DatePickerWithTooltip
                  name="min_added_date"
                  selected={dateFilters.min_added_date}
                  onChange={(date) => handleDateChange(date, "min_added_date")}
                  title="Min Added Date"
                />
              </Col>
              <Col md={4}>
                <DatePickerWithTooltip
                  name="max_added_date"
                  selected={dateFilters.max_added_date}
                  onChange={(date) => handleDateChange(date, "max_added_date")}
                  title="Max Added Date"
                />
              </Col>
            </Row>
            <Row className="mt-4">
              <Col>
                <Button
                  variant="secondary"
                  onClick={() => setShowFilterModal(false)}
                >
                  Close
                </Button>
                <Button variant="primary" type="submit" className="ms-2">
                  Apply Filters
                </Button>
                <Button
                  variant="outline-secondary"
                  onClick={resetFilters}
                  className="ms-2"
                >
                  Reset Filters
                </Button>
              </Col>
            </Row>
          </Form>
        </Modal.Body>
      </Modal>

      <Table striped bordered hover>
        <thead>
          <tr>
            <SortableHeader column="company_name" label="Company" />
            <th>Tags</th>
            <th>Company Type</th>
            <th>Job Titles</th>
            <th>Technical Stacks</th>
            <SortableHeader column="location" label="Location" />
            <SortableHeader column="net_salary" label="Net Salary" />
            <SortableHeader column="gross_salary" label="Gross Salary" />
            <SortableHeader column="variables" label="Variables" />
            <th>Gender</th>
            <SortableHeader
              column="experience_years_company"
              label="Company Experience"
            />
            <SortableHeader
              column="total_experience_years"
              label="Total Experience"
            />
            <th>Level</th>
            <th>Work Type</th>
            <SortableHeader column="added_date" label="Added Date" />
            <SortableHeader column="leave_days" label="Leave Days" />
          </tr>
        </thead>
        <tbody>
          {isLoading ? (
            <tr>
              <td colSpan="16">
                <div className="d-flex justify-content-center">
                  <div className="spinner-border" role="status">
                    <span className="visually-hidden">Loading...</span>
                  </div>
                </div>
              </td>
            </tr>
          ) : error ? (
            <tr>
              <td colSpan="16">{error}</td>
            </tr>
          ) : salaries.length > 0 ? (
            salaries.map((salary) => (
              <tr key={salary.id}>
                <td>{salary.company?.name || "N/A"}</td>
                <td>
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
                          ?.slice(0, 2)
                          .map((tag) => capitalizeWords(tag.name))
                          .join(", ")}
                        {salary.company?.tags?.length > 2 && "..."}
                      </span>
                    </OverlayTrigger>
                  ) : (
                    "N/A"
                  )}
                </td>
                <td>{capitalizeWords(salary.company?.type) || "N/A"}</td>
                <td>
                  {salary.jobs?.length > 0 ? (
                    <OverlayTrigger
                      placement="right"
                      overlay={
                        <Tooltip id={`tooltip-jobs-${salary.id}`}>
                          {salary.jobs
                            .map((job) => capitalizeWords(job.title))
                            .join(", ")}
                        </Tooltip>
                      }
                    >
                      <span>
                        {salary.jobs
                          ?.slice(0, 2)
                          .map((job) => capitalizeWords(job.title))
                          .join(", ")}
                        {salary.jobs?.length > 2 && "..."}
                      </span>
                    </OverlayTrigger>
                  ) : (
                    "N/A"
                  )}
                </td>
                <td>
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
                          ?.slice(0, 3)
                          .map((stack) => capitalizeWords(stack.name))
                          .join(", ")}
                        {salary.technical_stacks?.length > 3 && "..."}
                      </span>
                    </OverlayTrigger>
                  ) : (
                    "N/A"
                  )}
                </td>
                <td>{capitalizeWords(salary.location) || "N/A"}</td>
                <td>
                  {salary.net_salary !== null ? salary.net_salary : "N/A"}
                </td>
                <td>
                  {salary.gross_salary !== null ? salary.gross_salary : "N/A"}
                </td>
                <td>{salary.variables !== null ? salary.variables : "N/A"}</td>
                <td>{capitalizeWords(salary.gender) || "N/A"}</td>
                <td>
                  {salary.experience_years_company !== null
                    ? salary.experience_years_company
                    : "N/A"}
                </td>
                <td>
                  {salary.total_experience_years !== null
                    ? salary.total_experience_years
                    : "N/A"}
                </td>
                <td>{capitalizeWords(salary.level) || "N/A"}</td>
                <td>{capitalizeWords(salary.work_type) || "N/A"}</td>
                <td>{salary.added_date || "N/A"}</td>
                <td>
                  {salary.leave_days !== null ? salary.leave_days : "N/A"}
                </td>
              </tr>
            ))
          ) : (
            <tr>
              <td colSpan="15">No salaries found</td>
            </tr>
          )}
        </tbody>
      </Table>
    </div>
  );
};

export default SalaryListPage;
