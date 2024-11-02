import React from "react";
import { Table, Button, OverlayTrigger, Tooltip } from "react-bootstrap";
import styled from "styled-components";
import { capitalizeWords } from "../../utils/stringUtils";

// Styled components from the original file
const StyledTable = styled(Table)`
  width: 100%;
  min-width: max-content;
`;

const TableCell = styled.td`
  white-space: nowrap;
  padding: 8px;
`;

const NarrowCell = styled(TableCell)`
  min-width: 100px;
`;

const StickyCell = styled(TableCell)`
  position: sticky;
  background-color: #f8f9fa;
  z-index: 2;
  ${(props) => props.left && `left: ${props.left};`}
  ${(props) => props.right && `right: ${props.right};`}
`;

const ScrollableWrapper = styled.div`
  overflow-x: auto;
  position: relative;
  width: 100%;
  -webkit-overflow-scrolling: touch;
`;

const SortableHeader = ({ column, label, sortBy, sortOrder, onSort }) => {
  const isSortedBy = sortBy === column;
  const icon = isSortedBy ? (sortOrder === "asc" ? "▲" : "▼") : "⇅";

  return (
    <th style={{ cursor: "pointer" }} onClick={() => onSort(column)}>
      {label} {icon}
    </th>
  );
};

const SalaryTable = ({
  salaries,
  error,
  sortBy,
  sortOrder,
  onSort,
  handleShowDetails,
  t,
}) => {
  const renderSalaryRow = (salary) => {
    return (
      <tr key={salary.id}>
        <StickyCell left="0">{salary.company?.name || "N/A"}</StickyCell>
        <TableCell>{capitalizeWords(salary.location) || "N/A"}</TableCell>
        <TableCell>
          {salary.jobs?.length > 0 ? (
            <OverlayTrigger
              placement="right"
              overlay={
                <Tooltip id={`tooltip-job-title-${salary.id}`}>
                  {salary.jobs
                    .map((job) => capitalizeWords(job.title))
                    .join(", ")}
                </Tooltip>
              }
            >
              <span>
                {salary.jobs
                  .map((job) => capitalizeWords(job.title))
                  .join(", ")}
              </span>
            </OverlayTrigger>
          ) : (
            "N/A"
          )}
        </TableCell>
        <TableCell>
          {salary.gross_salary !== null ? salary.gross_salary : "N/A"}
        </TableCell>
        <TableCell>
          {salary.net_salary !== null ? salary.net_salary : "N/A"}
        </TableCell>
        <TableCell>{salary.bonus !== null ? salary.bonus : "N/A"}</TableCell>
        <TableCell>{capitalizeWords(salary.level) || "N/A"}</TableCell>
        <TableCell>{capitalizeWords(salary.work_type) || "N/A"}</TableCell>
        <TableCell>
          {salary.experience_years_company !== null
            ? salary.experience_years_company
            : "N/A"}
        </TableCell>
        <TableCell>
          {salary.total_experience_years !== null
            ? salary.total_experience_years
            : "N/A"}
        </TableCell>
        <TableCell>{capitalizeWords(salary.company?.type) || "N/A"}</TableCell>
        <TableCell>
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
                  ?.slice(0, 2)
                  .map((stack) => capitalizeWords(stack.name))
                  .join(", ")}
                {salary.technical_stacks?.length > 2 && "..."}
              </span>
            </OverlayTrigger>
          ) : (
            "N/A"
          )}
        </TableCell>
        <TableCell>
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
                  ?.slice(0, 1)
                  .map((tag) => capitalizeWords(tag.name))
                  .join(", ")}
                {salary.company?.tags?.length > 1 && "..."}
              </span>
            </OverlayTrigger>
          ) : (
            "N/A"
          )}
        </TableCell>
        <TableCell>{capitalizeWords(salary.gender) || "N/A"}</TableCell>
        <TableCell>{salary.added_date || "N/A"}</TableCell>
        <TableCell>
          {salary.leave_days !== null ? salary.leave_days : "N/A"}
        </TableCell>
        <td>
          {salary.verified === "no" && (
            <span className="text-muted">{t.entities.verified.value.no}</span>
          )}
          {salary.verified === "pending" && (
            <span className="text-warning">
              <i className="bi bi-clock"></i>{" "}
              {t.entities.verified.value.pending}
            </span>
          )}
          {salary.verified === "verified" && (
            <span className="text-success">
              <i className="bi bi-check-circle"></i>{" "}
              {t.entities.verified.value.verified}
            </span>
          )}
        </td>
        <StickyCell right="0">
          <Button
            variant="info"
            size="sm"
            onClick={() => handleShowDetails(salary)}
          >
            {t.entities.actions.title}
          </Button>
        </StickyCell>
      </tr>
    );
  };

  return (
    <ScrollableWrapper>
      <StyledTable striped bordered hover>
        <thead>
          <tr>
            <StickyCell as="th" left="0">
              {t.entities.company.name.singular}
            </StickyCell>
            <SortableHeader
              column="location"
              label={t.entities.location.singular}
              sortBy={sortBy}
              sortOrder={sortOrder}
              onSort={onSort}
            />
            <th>{t.entities.job.titles.singular}</th>
            <SortableHeader
              column="gross_salary"
              label={t.entities.gross_salary.singular}
              sortBy={sortBy}
              sortOrder={sortOrder}
              onSort={onSort}
            />
            <SortableHeader
              column="net_salary"
              label={t.entities.net_salary.singular}
              sortBy={sortBy}
              sortOrder={sortOrder}
              onSort={onSort}
            />
            <SortableHeader
              column="bonus"
              label={t.entities.bonus.singular}
              sortBy={sortBy}
              sortOrder={sortOrder}
              onSort={onSort}
            />
            <th>{t.entities.level.singular}</th>
            <th>{t.entities.work_type.singular}</th>
            <SortableHeader
              column="experience_years_company"
              label={t.entities.experience_years_company.singular}
              sortBy={sortBy}
              sortOrder={sortOrder}
              onSort={onSort}
            />
            <SortableHeader
              column="total_experience_years"
              label={t.entities.total_experience_years.singular}
              sortBy={sortBy}
              sortOrder={sortOrder}
              onSort={onSort}
            />
            <th>{t.entities.company.type.singular}</th>
            <th>{t.entities.technical_stacks.singular}</th>
            <th>{t.entities.company.tags.singular}</th>
            <th>{t.entities.gender.singular}</th>
            <SortableHeader
              column="added_date"
              label={t.entities.added_date.singular}
              sortBy={sortBy}
              sortOrder={sortOrder}
              onSort={onSort}
            />
            <SortableHeader
              column="leave_days"
              label={t.entities.leave_days.singular}
              sortBy={sortBy}
              sortOrder={sortOrder}
              onSort={onSort}
            />
            <th>{t.entities.verified.singular}</th>
            <StickyCell as="th" right="0">
              {t.entities.actions.name}
            </StickyCell>
          </tr>
        </thead>
        <tbody>
          {error ? (
            <tr>
              <td colSpan="17">{error}</td>
            </tr>
          ) : salaries.length > 0 ? (
            salaries.map(renderSalaryRow)
          ) : (
            <tr>
              <td colSpan="17">{t.entities.errors.no_salaries}</td>
            </tr>
          )}
        </tbody>
      </StyledTable>
    </ScrollableWrapper>
  );
};

export default SalaryTable;
