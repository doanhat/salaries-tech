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
import { useLanguage, translations } from "../../contexts/LanguageContext";

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

const CustomTooltip = ({ active, payload, label }) => {
  const { language } = useLanguage();
  const t = translations[language].dashboard.top_locations_bar_chart;

  if (active && payload && payload.length) {
    return (
      <div
        style={{
          backgroundColor: "#fff",
          padding: "10px",
          border: "1px solid #ccc",
        }}
      >
        <p>{label}</p>
        <p>{`${t.tooltip.salary}: ${payload[0].value.toLocaleString()}`}</p>
      </div>
    );
  }
  return null;
};

const TopLocationsSalaryBarChart = ({ data }) => {
  const { language } = useLanguage();
  const t = translations[language].dashboard.top_locations_bar_chart;

  return (
    <ChartContainer>
      <h3 style={{ textAlign: "center" }}>{t.title}</h3>
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
          <Tooltip content={<CustomTooltip />} />
          <Bar dataKey="average_salary" fill="#8884d8" />
        </BarChart>
      </StyledResponsiveContainer>
    </ChartContainer>
  );
};

export default TopLocationsSalaryBarChart;
