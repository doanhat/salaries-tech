import axios from "axios";
export const API_BASE_URL =
  process.env.REACT_APP_API_BASE_URL || "http://localhost:8000";

export const RECAPTCHA_SITE_KEY =
  process.env.REACT_APP_RECAPTCHA_SITE_KEY || "";

export const API_KEY = process.env.REACT_APP_API_KEY || "";

const getHeaders = async () => {
  return {
    "X-API-Key": API_KEY,
  };
};

export const getSalaryStats = async () => {
  const headers = await getHeaders();
  const response = await fetch(`${API_BASE_URL}/salaries/stats/`, {
    credentials: "include",
    headers,
  });
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  return await response.json();
};

export const getChoices = async () => {
  try {
    const headers = await getHeaders();
    const response = await fetch(`${API_BASE_URL}/choices/`, {
      credentials: "include",
      headers,
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
  const headers = await getHeaders();
  const queryParams = new URLSearchParams();
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

  const response = await fetch(
    `${API_BASE_URL}/salaries/?${queryParams.toString()}`,
    {
      credentials: "include",
      headers,
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

export const addSalary = async (
  salaryData,
  captchaToken,
  userAgent,
  emailBody,
) => {
  try {
    // Format the data
    const formattedData = {
      gender: salaryData.gender,
      level: salaryData.level,
      gross_salary: parseFloat(salaryData.gross_salary),
      work_type: salaryData.work_type,
      net_salary: salaryData.net_salary
        ? parseFloat(salaryData.net_salary)
        : null,
      technical_stacks: salaryData.technical_stacks.map((stack) => ({
        name: stack,
      })),
      added_date:
        salaryData.added_date || new Date().toISOString().split("T")[0],
      location: salaryData.location,
      jobs: salaryData.job_titles.map((title) => ({ title })),
      bonus: salaryData.bonus ? parseFloat(salaryData.bonus) : null,
      total_experience_years: salaryData.total_experience_years
        ? parseInt(salaryData.total_experience_years)
        : null,
      company: salaryData.company_name
        ? {
            name: salaryData.company_name,
            type: salaryData.company_type,
            tags: salaryData.company_tags.map((tag) => ({ name: tag })),
          }
        : null,
      leave_days: salaryData.leave_days
        ? parseInt(salaryData.leave_days)
        : null,
      experience_years_company: salaryData.experience_years_company
        ? parseInt(salaryData.experience_years_company)
        : null,
      professional_email: salaryData.professional_email || null,
    };

    // Add query parameters for captcha and user agent
    const queryParams = new URLSearchParams({
      captcha_token: captchaToken,
      user_agent: userAgent,
    });

    const emailData = {
      subject: emailBody.subject,
      greeting_text: emailBody.greeting_text,
      verify_button_text: emailBody.verify_button_text,
      expiration_text: emailBody.expiration_text,
    };

    const response = await fetch(`${API_BASE_URL}/salaries/?${queryParams}`, {
      method: "POST",
      headers: {
        ...(await getHeaders()),
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ salary: formattedData, email_body: emailData }),
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
    const headers = await getHeaders();
    const response = await fetch(
      `${API_BASE_URL}/companies/check-name/?name=${encodeURIComponent(name)}`,
      {
        credentials: "include",
        headers,
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
    const headers = await getHeaders();
    const response = await fetch(
      `${API_BASE_URL}/companies/check-tag/?name=${encodeURIComponent(name)}`,
      {
        credentials: "include",
        headers,
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
    const headers = await getHeaders();
    const response = await fetch(
      `${API_BASE_URL}/salaries/check-location/?name=${encodeURIComponent(name)}`,
      {
        credentials: "include",
        headers,
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
  const headers = await getHeaders();
  return await axios.get(`${API_BASE_URL}/technical-stacks`, { headers });
};

export const checkTechnicalStack = async (name) => {
  try {
    const headers = await getHeaders();
    const response = await fetch(
      `${API_BASE_URL}/technical-stacks/check-name/?name=${encodeURIComponent(name)}`,
      {
        credentials: "include",
        headers,
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
    const headers = await getHeaders();
    const response = await fetch(
      `${API_BASE_URL}/jobs/check-title/?title=${encodeURIComponent(title)}`,
      {
        credentials: "include",
        headers,
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
  const headers = await getHeaders();
  const response = await fetch(`${API_BASE_URL}/salaries/location-stats/`, {
    credentials: "include",
    headers,
  });
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  return await response.json();
};

export const getTopLocationsByAverageSalary = async () => {
  const headers = await getHeaders();
  const response = await fetch(
    `${API_BASE_URL}/salaries/top-locations-by-salary/`,
    {
      credentials: "include",
      headers,
    },
  );
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  return await response.json();
};

export const verifyEmail = async (token) => {
  const headers = await getHeaders();
  return await axios.get(
    `${API_BASE_URL}/salaries/verify-email/?token=${token}`,
    { headers },
  );
};
