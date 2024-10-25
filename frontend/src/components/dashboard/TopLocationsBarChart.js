import React from "react";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import styled from "styled-components";

const ChartContainer = styled.div`
  width: 100%;
  height: 500px;
  margin-bottom: 20px;

  @media (max-width: 767px) {
    height: 400px;
  }
`;

const StyledResponsiveContainer = styled(ResponsiveContainer)`
  .recharts-x-axis .recharts-cartesian-axis-tick-value {
    text-anchor: end;
  }
`;

const TopLocationsSalaryBarChart = ({ data }) => {
  return (
    <ChartContainer>
      <h3 style={{ textAlign: "center" }}>
        Top 10 Locations by Average Salary
      </h3>
      <StyledResponsiveContainer>
        <BarChart
          data={data}
          layout="vertical"
          margin={{
            top: 20,
            right: 30,
            left: 100,
            bottom: 5,
          }}
        >
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis type="number" />
          <YAxis
            dataKey="name"
            type="category"
            width={90}
            tick={{ fontSize: 12 }}
          />
          <Tooltip />
          <Bar dataKey="average_salary" fill="#8884d8" />
        </BarChart>
      </StyledResponsiveContainer>
    </ChartContainer>
  );
};

export default TopLocationsSalaryBarChart;
