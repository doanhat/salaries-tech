import React from "react";
import { render, screen, waitFor, act } from "@testing-library/react";
import "@testing-library/jest-dom";
import SalaryListPage from "./SalaryListPage";
import { translations } from "../contexts/LanguageContext";

// Mock the api module
jest.mock("../utils/api", () => ({
  getSalaries: jest.fn(),
  getChoices: jest.fn(),
  getLocationStats: jest.fn(),
  getTopLocationsByAverageSalary: jest.fn(),
}));

// Mock the LanguageContext
jest.mock("../contexts/LanguageContext", () => {
  const actual = jest.requireActual("../contexts/LanguageContext");
  return {
    ...actual,
    useLanguage: () => ({
      language: "en",
      toggleLanguage: jest.fn(),
      translations: actual.translations,
    }),
  };
});

const {
  getSalaries,
  getChoices,
  getLocationStats,
  getTopLocationsByAverageSalary,
} = require("../utils/api");

describe("SalaryListPage", () => {
  beforeEach(() => {
    jest.clearAllMocks();

    // Mock API responses
    getSalaries.mockResolvedValue({
      results: [
        {
          id: 1,
          company: { name: "Test Company", type: "startup" },
          location: "Test Location",
          jobs: [{ title: "Software Engineer" }],
          gross_salary: 100000,
          net_salary: 75000,
          bonus: 10000,
          level: "senior",
          work_type: "remote",
          experience_years_company: 2,
          total_experience_years: 5,
          technical_stacks: [{ name: "React" }],
          added_date: "2024-01-01",
          verified: "no",
        },
      ],
      total: 1,
    });

    getChoices.mockResolvedValue({
      company_names: ["Test Company"],
      company_tags: ["Tech"],
      company_types: ["startup"],
      job_titles: ["Software Engineer"],
      technical_stacks: ["React"],
      locations: ["Test Location"],
      levels: ["senior"],
      work_types: ["remote"],
    });

    getLocationStats.mockResolvedValue({
      chart_data: [{ location: "Test Location", count: 1 }],
    });

    getTopLocationsByAverageSalary.mockResolvedValue([
      { location: "Test Location", average_salary: 100000 },
    ]);
  });

  test("renders SalaryListPage component with data", async () => {
    await act(async () => {
      render(<SalaryListPage />);
    });

    // Wait for loading to complete
    await waitFor(() => {
      expect(
        screen.queryByText(translations.en.entities.info.loading),
      ).not.toBeInTheDocument();
    });

    // Verify buttons are rendered
    expect(
      screen.getByRole("button", {
        name: translations.en.entities.buttons.add_salary,
      }),
    ).toBeInTheDocument();
    expect(
      screen.getByRole("button", {
        name: translations.en.entities.buttons.filters,
      }),
    ).toBeInTheDocument();

    // Verify table data is rendered
    expect(screen.getByText("Test Company")).toBeInTheDocument();
    expect(screen.getByText("Test Location")).toBeInTheDocument();
    expect(screen.getByText("Software Engineer")).toBeInTheDocument();
    expect(screen.getByText("100000")).toBeInTheDocument();

    // Verify API calls
    expect(getSalaries).toHaveBeenCalledTimes(1);
    expect(getChoices).toHaveBeenCalledTimes(1);
    expect(getLocationStats).toHaveBeenCalledTimes(1);
    expect(getTopLocationsByAverageSalary).toHaveBeenCalledTimes(1);
  });

  test("shows loading state", async () => {
    // Initialize mock responses but don't resolve them immediately
    const mockResponses = {
      salaries: new Promise((resolve) =>
        setTimeout(
          () =>
            resolve({
              results: [],
              total: 0,
            }),
          100,
        ),
      ),
      choices: new Promise((resolve) =>
        setTimeout(
          () =>
            resolve({
              company_names: [],
              company_tags: [],
              company_types: [],
              job_titles: [],
              technical_stacks: [],
              locations: [],
              levels: [],
              work_types: [],
            }),
          100,
        ),
      ),
      locationStats: new Promise((resolve) =>
        setTimeout(
          () =>
            resolve({
              chart_data: [],
            }),
          100,
        ),
      ),
      topLocations: new Promise((resolve) =>
        setTimeout(() => resolve([]), 100),
      ),
    };

    // Set up the mocks
    getSalaries.mockImplementation(() => mockResponses.salaries);
    getChoices.mockImplementation(() => mockResponses.choices);
    getLocationStats.mockImplementation(() => mockResponses.locationStats);
    getTopLocationsByAverageSalary.mockImplementation(
      () => mockResponses.topLocations,
    );

    render(<SalaryListPage />);

    // Verify loading spinner is shown initially
    expect(screen.getByRole("status")).toBeInTheDocument();
    expect(screen.getByRole("status")).toHaveClass("spinner-border");

    // Wait for all promises to resolve
    await act(async () => {
      await Promise.all([
        mockResponses.salaries,
        mockResponses.choices,
        mockResponses.locationStats,
        mockResponses.topLocations,
      ]);
    });

    // Give React time to process the state updates
    await waitFor(() => {
      expect(screen.queryByRole("status")).not.toBeInTheDocument();
    });
  });

  test("shows no salaries message when no data", async () => {
    getSalaries.mockResolvedValue({ results: [], total: 0 });

    await act(async () => {
      render(<SalaryListPage />);
    });

    await waitFor(() => {
      expect(
        screen.getByText(translations.en.entities.errors.no_salaries),
      ).toBeInTheDocument();
    });
  });
});
