import axios from "axios";

export const API_BASE_URL =
  process.env.REACT_APP_API_BASE_URL || "http://localhost:8000";

export const RECAPTCHA_SITE_KEY = process.env.REACT_APP_RECAPTCHA_SITE_KEY;

export const getSalaryStats = async () => {
  const response = await fetch(`${API_BASE_URL}/salaries/stats/`, {
    credentials: "include",
  });
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  return await response.json();
};

export const getChoices = async () => {
  try {
    const response = await fetch(`${API_BASE_URL}/salaries/choices/`, {
      credentials: "include",
    });
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const data = await response.json();
    return data;
  } catch (error) {
    console.error("Error fetching choices:", error);
    throw error;
  }
};

export const getSalaries = async (
  filters,
  sortBy = "added_date",
  sortOrder = "desc",
  skip = 0,
  limit = 50,
) => {
  const queryParams = new URLSearchParams();
  console.log("Filters:", filters);
  Object.entries(filters).forEach(([key, value]) => {
    if (
      value !== null &&
      value !== undefined &&
      value !== "" &&
      value.length > 0
    ) {
      queryParams.append(key, value);
    }
  });

  queryParams.append("sort_by", sortBy);
  queryParams.append("sort_order", sortOrder);
  queryParams.append("skip", skip);
  queryParams.append("limit", limit);

  console.log("Query params being sent to backend:", queryParams.toString());

  const response = await fetch(
    `${API_BASE_URL}/salaries/?${queryParams.toString()}`,
    {
      credentials: "include",
    },
  );

  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }

  const data = await response.json();
  return {
    results: data.results || [],
    total: data.total || 0,
  };
};

export const addSalary = async (salaryData, captchaToken, userAgent) => {
  try {
    // Format the data
    const formattedData = {
      ...salaryData,
      net_salary: salaryData.net_salary
        ? parseFloat(salaryData.net_salary)
        : null,
      gross_salary: parseFloat(salaryData.gross_salary),
      variables: salaryData.variables ? parseFloat(salaryData.variables) : null,
      experience_years_company: salaryData.experience_years_company
        ? parseInt(salaryData.experience_years_company)
        : null,
      total_experience_years: salaryData.total_experience_years
        ? parseInt(salaryData.total_experience_years)
        : null,
      level: salaryData.level || null,
      work_type: salaryData.work_type || null,
      leave_days: salaryData.leave_days
        ? parseInt(salaryData.leave_days)
        : null,
      technical_stacks: salaryData.technical_stacks
        ? salaryData.technical_stacks.map((stack) => ({ name: stack }))
        : [],
      jobs: salaryData.job_titles
        ? salaryData.job_titles.map((title) => ({ title }))
        : [],
      company: {
        name: salaryData.company_name,
        type: salaryData.company_type,
        tags: salaryData.company_tags
          ? salaryData.company_tags.map((tag) => ({ name: tag }))
          : [],
      },
    };

    // Remove any fields with null values
    Object.keys(formattedData).forEach(
      (key) => formattedData[key] === null && delete formattedData[key],
    );

    const formData = new FormData();
    formData.append("salary", JSON.stringify(formattedData));
    formData.append("captcha_token", captchaToken);
    formData.append("user_agent", userAgent);

    console.log("Data being sent to backend:", formattedData);
    const response = await fetch(`${API_BASE_URL}/salaries/`, {
      method: "POST",
      body: formData,
      credentials: "include",
    });

    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(JSON.stringify(errorData));
    }

    return await response.json();
  } catch (error) {
    console.error("Error in addSalary:", error);
    throw error;
  }
};

export const checkCompany = async (name) => {
  try {
    const response = await fetch(
      `${API_BASE_URL}/check-company-name/?name=${encodeURIComponent(name)}`,
      {
        credentials: "include",
      },
    );
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return await response.json();
  } catch (error) {
    console.error("Error checking company:", error);
    return { exists: false };
  }
};

export const checkCompanyTag = async (name) => {
  try {
    const response = await fetch(
      `${API_BASE_URL}/check-company-tag/?name=${encodeURIComponent(name)}`,
      {
        credentials: "include",
      },
    );
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return await response.json();
  } catch (error) {
    console.error("Error checking tag:", error);
    return { exists: false };
  }
};

export const checkLocation = async (name) => {
  try {
    const response = await fetch(
      `${API_BASE_URL}/check-location/?name=${encodeURIComponent(name)}`,
      {
        credentials: "include",
      },
    );
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return await response.json();
  } catch (error) {
    console.error("Error checking location:", error);
    return { exists: false };
  }
};

export const getTechnicalStacks = async () => {
  return await axios.get(`${API_BASE_URL}/technical-stacks`);
};

export const checkTechnicalStack = async (name) => {
  try {
    const response = await fetch(
      `${API_BASE_URL}/check-technical-stack/?name=${encodeURIComponent(name)}`,
      {
        credentials: "include",
      },
    );
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return await response.json();
  } catch (error) {
    console.error("Error checking technical stack:", error);
    return { exists: false };
  }
};

export const checkJobTitle = async (title) => {
  try {
    const response = await fetch(
      `${API_BASE_URL}/check-job-title/?title=${encodeURIComponent(title)}`,
      {
        credentials: "include",
      },
    );
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return await response.json();
  } catch (error) {
    console.error("Error checking job:", error);
    return { exists: false };
  }
};

export const getLocationStats = async () => {
  const response = await fetch(`${API_BASE_URL}/salaries/location-stats/`, {
    credentials: "include",
  });
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  return await response.json();
};

export const getTopLocationsByAverageSalary = async () => {
  const response = await fetch(
    `${API_BASE_URL}/salaries/top-locations-by-salary/`,
    {
      credentials: "include",
    },
  );
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  return await response.json();
};
