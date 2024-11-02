from datetime import date
from typing import List, Optional

from pydantic import BaseModel, ConfigDict, Field, field_validator
from sqlalchemy import CheckConstraint, Column, Date, Float, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from ..database import Base
from . import (
    EmailVerificationStatus,
    Gender,
    Level,
    WorkType,
    salary_job,
    salary_technical_stack,
)
from .company import Company
from .job import Job
from .technical_stack import TechnicalStack


class SalaryDB(Base):
    __tablename__ = "salaries"

    id = Column(Integer, primary_key=True, index=True)
    company_id = Column(Integer, ForeignKey("companies.id"), nullable=True)
    location = Column(String, nullable=False)
    net_salary = Column(Float, nullable=True)
    gross_salary = Column(Float, nullable=False)
    bonus = Column(Float, nullable=True)
    gender = Column(String, nullable=True)
    experience_years_company = Column(Integer, nullable=True)
    total_experience_years = Column(Integer, nullable=True)
    level = Column(String, nullable=True)
    work_type = Column(String, nullable=True)
    added_date = Column(Date)
    leave_days = Column(Integer, nullable=True)
    company = relationship("CompanyDB", back_populates="salaries")
    technical_stacks = relationship(
        "TechnicalStackDB", secondary=salary_technical_stack, back_populates="salaries"
    )
    jobs = relationship("JobDB", secondary=salary_job, back_populates="salaries")
    email_domain = Column(String, nullable=True)
    verification = Column(String, default=EmailVerificationStatus.NO.value)

    __table_args__ = (
        CheckConstraint("net_salary >= 0", name="check_net_salary_non_negative"),
        CheckConstraint(
            "experience_years_company >= 0",
            name="check_experience_years_company_non_negative",
        ),
        CheckConstraint(
            "total_experience_years >= 0",
            name="check_total_experience_years_non_negative",
        ),
        CheckConstraint("leave_days >= 0", name="check_leave_days_non_negative"),
        CheckConstraint("leave_days < 365", name="check_leave_days_max"),
    )


# Pydantic model
class Salary(BaseModel):
    id: Optional[int] = None
    company: Optional[Company] = None
    jobs: Optional[List[Job]] = []
    location: str
    net_salary: Optional[float] = Field(None, ge=0)
    gross_salary: float = Field(..., ge=0)
    bonus: Optional[float] = Field(None, ge=0)
    gender: Optional[Gender] = None
    experience_years_company: Optional[int] = Field(None, ge=0)
    total_experience_years: Optional[int] = Field(None, ge=0)
    level: Optional[Level] = None
    work_type: Optional[WorkType] = None
    added_date: Optional[date] = None
    leave_days: Optional[int] = Field(None, ge=0, lt=365)
    technical_stacks: Optional[List[TechnicalStack]] = []
    professional_email: Optional[str] = None
    verification: Optional[EmailVerificationStatus] = Field(
        default=EmailVerificationStatus.NO
    )

    @field_validator("net_salary")
    def validate_net_salary(cls, v, info):
        if v is not None:
            gross_salary = info.data.get("gross_salary")
            if gross_salary is not None and v >= gross_salary:
                raise ValueError("Net salary must be less than gross salary")
        return v

    @field_validator("experience_years_company")
    def validate_experience_years(cls, v, info):
        if v is not None:
            total_exp = info.data.get("total_experience_years")
            if total_exp is not None and v > total_exp:
                raise ValueError(
                    "Company experience years cannot exceed total experience years"
                )
        return v

    @field_validator("professional_email")
    def validate_professional_email(cls, v):
        if v is None:
            return v
        common_domains = [
            "gmail.com",
            "yahoo.com",
            "hotmail.com",
            "outlook.com",
            "aol.com",
            "protonmail.com",
            "icloud.com",
            "mail.com",
            "live.com",
            "me.com",
            "msn.com",
        ]
        try:
            domain = v.split("@")[1].lower()
            if domain in common_domains:
                raise ValueError("Please use a professional email address")
        except IndexError:
            raise ValueError("Invalid email format")
        return v

    model_config = ConfigDict(from_attributes=True, use_enum_values=True)


class EmailBody(BaseModel):
    subject: str
    greeting_text: str
    verify_button_text: str
    expiration_text: str
