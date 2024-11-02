from datetime import date
from typing import List, Optional

from pydantic import BaseModel, ConfigDict, Field, field_validator
from sqlalchemy import Column, Date, Float, ForeignKey, Integer, String
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
    verified = Column(String, default=EmailVerificationStatus.NO.value)


# Pydantic model
class Salary(BaseModel):
    id: Optional[int] = None
    company: Optional[Company] = None
    jobs: Optional[List[Job]] = []
    location: str
    net_salary: Optional[float] = None
    gross_salary: float
    bonus: Optional[float] = None
    gender: Optional[Gender] = None
    experience_years_company: Optional[int] = None
    total_experience_years: Optional[int] = None
    level: Optional[Level] = None
    work_type: Optional[WorkType] = None
    added_date: Optional[date] = None
    leave_days: Optional[int] = None
    technical_stacks: Optional[List[TechnicalStack]] = []
    professional_email: Optional[str] = None
    verified: Optional[EmailVerificationStatus] = Field(
        default=EmailVerificationStatus.NO
    )

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
