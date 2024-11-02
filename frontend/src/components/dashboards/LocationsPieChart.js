import React from "react";
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip } from "recharts";
import styled from "styled-components";
import { useLanguage, translations } from "../../contexts/LanguageContext";

const COLORS = [
  "#0088FE",
  "#00C49F",
  "#FFBB28",
  "#FF8042",
  "#8884d8",
  "#82ca9d",
  "#ffc658",
  "#8dd1e1",
  "#a4de6c",
  "#d0ed57",
  "#ff9f7f",
  "#fb9a99",
  "#e31a1c",
  "#fdbf6f",
  "#ff7f00",
  "#cab2d6",
  "#6a3d9a",
  "#ffff99",
  "#b15928",
];

const ChartContainer = styled.div`
  width: 100%;
  height: 500px;
  display: flex;
  flex-direction: column;
`;

const ChartWrapper = styled.div`
  flex: 1;
  min-height: 0;
`;

const PieChartWrapper = styled.div`
  height: 100%;
`;

const LegendWrapper = styled.div`
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  max-height: 100px;
  overflow-y: auto;
  padding: 10px 0;
`;

const LegendItem = styled.div`
  display: flex;
  align-items: center;
  margin: 0 5px 5px 0;
`;

const LegendColor = styled.div`
  width: 10px;
  height: 10px;
  margin-right: 3px;
  flex-shrink: 0;
`;

const LegendText = styled.span`
  font-size: 10px;
  white-space: nowrap;
`;

const RADIAN = Math.PI / 180;
const renderCustomizedLabel = ({
  cx,
  cy,
  midAngle,
  innerRadius,
  outerRadius,
  percent,
  index,
}) => {
  const radius = innerRadius + (outerRadius - innerRadius) * 0.5;
  const x = cx + radius * Math.cos(-midAngle * RADIAN);
  const y = cy + radius * Math.sin(-midAngle * RADIAN);

  return (
    <text
      x={x}
      y={y}
      fill="white"
      textAnchor="middle"
      dominantBaseline="central"
    >
      {`${(percent * 100).toFixed(0)}%`}
    </text>
  );
};

const CustomTooltip = ({ active, payload }) => {
  if (active && payload && payload.length) {
    const data = payload[0].payload;
    return (
      <div
        className="custom-tooltip"
        style={{
          backgroundColor: "#fff",
          padding: "5px",
          border: "1px solid #ccc",
        }}
      >
        <p className="label">{data.tooltip.join(", ")}</p>
      </div>
    );
  }
  return null;
};

const LocationPieChart = ({ data }) => {
  const { language } = useLanguage();
  const t = translations[language].dashboard.location_pie_chart;
  const total = data.reduce((sum, entry) => sum + entry.value, 0);

  return (
    <ChartContainer>
      <h3 style={{ textAlign: "center", marginBottom: "10px" }}>{t.title}</h3>
      <ChartWrapper>
        <PieChartWrapper>
          <ResponsiveContainer>
            <PieChart>
              <Pie
                data={data}
                cx="50%"
                cy="50%"
                labelLine={false}
                label={renderCustomizedLabel}
                outerRadius="90%"
                fill="#8884d8"
                dataKey="value"
                innerRadius="50%"
              >
                {data.map((entry, index) => (
                  <Cell
                    key={`cell-${index}`}
                    fill={COLORS[index % COLORS.length]}
                  />
                ))}
              </Pie>
              <Tooltip content={<CustomTooltip />} />
              <text
                x="50%"
                y="50%"
                textAnchor="middle"
                dominantBaseline="middle"
                fontSize="16"
              >
                {t.total}: {total}
              </text>
            </PieChart>
          </ResponsiveContainer>
        </PieChartWrapper>
      </ChartWrapper>
      <LegendWrapper>
        {data.map((entry, index) => (
          <LegendItem key={index}>
            <LegendColor
              style={{ backgroundColor: COLORS[index % COLORS.length] }}
            />
            <LegendText>{`${entry.name}: ${((entry.value / total) * 100).toFixed(1)}%`}</LegendText>
          </LegendItem>
        ))}
      </LegendWrapper>
    </ChartContainer>
  );
};

export default LocationPieChart;
