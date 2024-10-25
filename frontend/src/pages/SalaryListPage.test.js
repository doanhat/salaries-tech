const React = require("react");
const {
  render,
  screen,
  fireEvent,
  waitFor,
} = require("@testing-library/react");
require("@testing-library/jest-dom");
const SalaryListPage = require("./SalaryListPage").default;

// Mock the entire api module
jest.mock("../utils/api", () => ({
  getSalaries: jest.fn(),
  getChoices: jest.fn(),
  getLocationStats: jest.fn(),
  getTopLocationsByAverageSalary: jest.fn(),
}));

const {
  getSalaries,
  getChoices,
  getLocationStats,
  getTopLocationsByAverageSalary,
} = require("../utils/api");

describe("SalaryListPage", () => {
  beforeEach(() => {
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
    getLocationStats.mockResolvedValue({});
    getTopLocationsByAverageSalary.mockResolvedValue({});
  });

  test("renders SalaryListPage component", async () => {
    render(<SalaryListPage />);

    // Check if the main elements are rendered
    expect(
      screen.getByRole("button", { name: "Add Salary" }),
    ).toBeInTheDocument();
    expect(screen.getByText("Filters")).toBeInTheDocument();

    // Wait for the initial data to load
    await waitFor(() => {
      expect(getSalaries).toHaveBeenCalledTimes(1);
      expect(getChoices).toHaveBeenCalledTimes(1);
      expect(getLocationStats).toHaveBeenCalledTimes(1);
      expect(getTopLocationsByAverageSalary).toHaveBeenCalledTimes(1);
    });
  });
});
