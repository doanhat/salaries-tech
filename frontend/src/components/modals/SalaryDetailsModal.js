import React from "react";
import { Modal, Button } from "react-bootstrap";
import { capitalizeWords } from "../../utils/stringUtils";

const SalaryDetailsModal = ({ show, onClose, salary, t }) => {
  return (
    <Modal show={show} onHide={onClose}>
      <Modal.Header closeButton>
        <Modal.Title>{t.entities.actions.title}</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        {salary && (
          <div>
            <p>
              <strong>{t.entities.company.name.singular}:</strong>{" "}
              {salary.company?.name || "N/A"}
            </p>
            <p>
              <strong>{t.entities.company.tags.singular}:</strong>{" "}
              {salary.company?.tags
                ?.map((tag) => capitalizeWords(tag.name))
                .join(", ") || "N/A"}
            </p>
            <p>
              <strong>{t.entities.company.type.singular}:</strong>{" "}
              {capitalizeWords(salary.company?.type) || "N/A"}
            </p>
            <p>
              <strong>{t.entities.job.titles.singular}:</strong>{" "}
              {salary.jobs
                ?.map((job) => capitalizeWords(job.title))
                .join(", ") || "N/A"}
            </p>
            <p>
              <strong>{t.entities.technical_stacks.singular}:</strong>{" "}
              {salary.technical_stacks
                ?.map((stack) => capitalizeWords(stack.name))
                .join(", ") || "N/A"}
            </p>
            <p>
              <strong>{t.entities.location.singular}:</strong>{" "}
              {capitalizeWords(salary.location) || "N/A"}
            </p>
            <p>
              <strong>{t.entities.net_salary.singular}:</strong>{" "}
              {salary.net_salary !== null ? salary.net_salary : "N/A"}
            </p>
            <p>
              <strong>{t.entities.gross_salary.singular}:</strong>{" "}
              {salary.gross_salary !== null ? salary.gross_salary : "N/A"}
            </p>
            <p>
              <strong>{t.entities.bonus.singular}:</strong>{" "}
              {salary.bonus !== null ? salary.bonus : "N/A"}
            </p>
            <p>
              <strong>{t.entities.gender.singular}:</strong>{" "}
              {capitalizeWords(salary.gender) || "N/A"}
            </p>
            <p>
              <strong>{t.entities.experience_years_company.singular}:</strong>{" "}
              {salary.experience_years_company !== null
                ? salary.experience_years_company
                : "N/A"}
            </p>
            <p>
              <strong>{t.entities.total_experience_years.singular}:</strong>{" "}
              {salary.total_experience_years !== null
                ? salary.total_experience_years
                : "N/A"}
            </p>
            <p>
              <strong>{t.entities.level.singular}:</strong>{" "}
              {capitalizeWords(salary.level) || "N/A"}
            </p>
            <p>
              <strong>{t.entities.work_type.singular}:</strong>{" "}
              {capitalizeWords(salary.work_type) || "N/A"}
            </p>
            <p>
              <strong>{t.entities.added_date.singular}:</strong>{" "}
              {salary.added_date || "N/A"}
            </p>
            <p>
              <strong>{t.entities.leave_days.singular}:</strong>{" "}
              {salary.leave_days !== null ? salary.leave_days : "N/A"}
            </p>
          </div>
        )}
      </Modal.Body>
      <Modal.Footer>
        <Button variant="secondary" onClick={onClose}>
          {t.entities.buttons.close}
        </Button>
      </Modal.Footer>
    </Modal>
  );
};

export default SalaryDetailsModal;
