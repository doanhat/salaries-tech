import React from "react";
import { render, screen, waitFor, act } from "@testing-library/react";
import "@testing-library/jest-dom";
import SalaryListPage from "./SalaryListPage";
import { LanguageProvider } from "../contexts/LanguageContext";

// Mock the api module
jest.mock("../utils/api", () => ({
  getSalaries: jest.fn(),
  getChoices: jest.fn(),
  getLocationStats: jest.fn(),
  getTopLocationsByAverageSalary: jest.fn(),
}));

// Mock the LanguageContext
jest.mock("../contexts/LanguageContext", () => ({
  LanguageProvider: ({ children, initialLanguage }) => (
    <div data-testid="language-provider" data-language={initialLanguage}>
      {children}
    </div>
  ),
  useLanguage: () => ({
    language: "en",
    toggleLanguage: jest.fn(),
  }),
}));

const {
  getSalaries,
  getChoices,
  getLocationStats,
  getTopLocationsByAverageSalary,
} = require("../utils/api");

describe("SalaryListPage", () => {
  beforeEach(() => {
    jest.clearAllMocks();

    getSalaries.mockResolvedValue({
      results: [],
      total: 0,
    });
    getChoices.mockResolvedValue({
      company_names: [],
      company_tags: [],
      company_types: [],
      job_titles: [],
      technical_stacks: [],
      locations: [],
      levels: [],
      work_types: [],
    });
    getLocationStats.mockResolvedValue({ chart_data: [] });
    getTopLocationsByAverageSalary.mockResolvedValue([]);
  });

  test("renders SalaryListPage component in English", async () => {
    await act(async () => {
      render(
        <LanguageProvider initialLanguage="en">
          <SalaryListPage />
        </LanguageProvider>,
      );
    });

    // Wait for all initial data fetching to complete
    await act(async () => {
      await Promise.all([
        getSalaries.mock.results[0].value,
        getChoices.mock.results[0].value,
        getLocationStats.mock.results[0].value,
        getTopLocationsByAverageSalary.mock.results[0].value,
      ]);
    });

    // Verify UI elements
    await waitFor(() => {
      expect(
        screen.getByRole("button", { name: /add a salary/i }),
      ).toBeInTheDocument();
      expect(screen.getByText(/filters/i)).toBeInTheDocument();
    });

    // Verify API calls
    expect(getSalaries).toHaveBeenCalledTimes(1);
    expect(getChoices).toHaveBeenCalledTimes(1);
    expect(getLocationStats).toHaveBeenCalledTimes(1);
    expect(getTopLocationsByAverageSalary).toHaveBeenCalledTimes(1);
  });
});
