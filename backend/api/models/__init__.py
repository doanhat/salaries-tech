from enum import Enum

from sqlalchemy import Column, ForeignKey, Integer, Table

from ..database import Base


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


salary_technical_stack = Table(
    "salary_technical_stack",
    Base.metadata,
    Column(
        "salary_id",
        Integer,
        ForeignKey("salaries.id", ondelete="CASCADE"),
        primary_key=True,
    ),
    Column(
        "technical_stack_id",
        Integer,
        ForeignKey("technical_stacks.id", ondelete="CASCADE"),
        primary_key=True,
    ),
)
# Association table for many-to-many relationship between Salary and Job
salary_job = Table(
    "salary_job",
    Base.metadata,
    Column(
        "salary_id",
        Integer,
        ForeignKey("salaries.id", ondelete="CASCADE"),
        primary_key=True,
    ),
    Column(
        "job_id", Integer, ForeignKey("jobs.id", ondelete="CASCADE"), primary_key=True
    ),
)
# Association table for many-to-many relationship between Company and Tag
company_tag = Table(
    "company_tag",
    Base.metadata,
    Column(
        "company_id",
        Integer,
        ForeignKey("companies.id", ondelete="CASCADE"),
        primary_key=True,
    ),
    Column(
        "tag_id", Integer, ForeignKey("tags.id", ondelete="CASCADE"), primary_key=True
    ),
)
