from datetime import date
from enum import Enum
from typing import List, Optional

from pydantic import BaseModel, ConfigDict, Field, field_validator
from sqlalchemy import Column, Date, Float, ForeignKey, Integer, String, Table
from sqlalchemy.orm import relationship

from .database import Base


# Define enums for choices
class CompanyType(str, Enum):
    STARTUP = "startup"
    SCALE_UP = "scale-up"
    SME = "sme"
    LARGE_ENTERPRISE = "large-enterprise"
    FREELANCE = "freelance"
    NPO = "npo"
    INSTITUTION = "institution"


class Level(str, Enum):
    JUNIOR = "junior"
    MID = "mid"
    SENIOR = "senior"
    STAFF = "staff"
    PRINCIPAL = "principal"
    LEAD = "lead"
    MANAGER = "manager"
    HEAD = "head"


class WorkType(str, Enum):
    REMOTE = "remote"
    HYBRID = "hybrid"
    ONSITE = "onsite"


class Gender(str, Enum):
    MALE = "male"
    FEMALE = "female"
    OTHER = "other"


class EmailVerificationStatus(str, Enum):
    NO = "no"
    PENDING = "pending"
    VERIFIED = "verified"


# Association table for many-to-many relationship between Salary and Technical Stack
salary_technical_stack = Table(
    "salary_technical_stack",
    Base.metadata,
    Column("salary_id", Integer, ForeignKey("salaries.id")),
    Column("technical_stack_id", Integer, ForeignKey("technical_stacks.id")),
)
# Association table for many-to-many relationship between Salary and Job
salary_job = Table(
    "salary_job",
    Base.metadata,
    Column("salary_id", Integer, ForeignKey("salaries.id")),
    Column("job_id", Integer, ForeignKey("jobs.id")),
)
# Association table for many-to-many relationship between Company and Tag
company_tag = Table(
    "company_tag",
    Base.metadata,
    Column("company_id", Integer, ForeignKey("companies.id")),
    Column("tag_id", Integer, ForeignKey("tags.id")),
)


class TagDB(Base):
    __tablename__ = "tags"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False)
    companies = relationship("CompanyDB", secondary=company_tag, back_populates="tags")


class CompanyDB(Base):
    __tablename__ = "companies"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=True)
    type = Column(String, nullable=True)
    tags = relationship("TagDB", secondary=company_tag, back_populates="companies")
    salaries = relationship("SalaryDB", back_populates="company")


class TechnicalStackDB(Base):
    __tablename__ = "technical_stacks"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False)
    salaries = relationship(
        "SalaryDB", secondary=salary_technical_stack, back_populates="technical_stacks"
    )


class JobDB(Base):
    __tablename__ = "jobs"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, unique=True, nullable=False)
    salaries = relationship("SalaryDB", secondary=salary_job, back_populates="jobs")


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
class Tag(BaseModel):
    id: Optional[int] = None
    name: str

    model_config = ConfigDict(from_attributes=True)


class Company(BaseModel):
    id: Optional[int] = None
    name: Optional[str] = None
    type: Optional[CompanyType] = None
    tags: Optional[List[Tag]] = []

    model_config = ConfigDict(from_attributes=True, use_enum_values=True)


class Job(BaseModel):
    id: Optional[int] = None
    title: str

    model_config = ConfigDict(from_attributes=True)


class TechnicalStack(BaseModel):
    id: Optional[int] = None
    name: str

    model_config = ConfigDict(from_attributes=True)


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
            "yahoo.com",
            "hotmail.com",
            "outlook.com",
            "aol.com",
            "bing.com",
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
