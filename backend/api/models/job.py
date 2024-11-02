from typing import Optional

from pydantic import BaseModel, ConfigDict
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship

from ..database import Base
from . import salary_job


class JobDB(Base):
    __tablename__ = "jobs"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, unique=True, nullable=False)
    salaries = relationship("SalaryDB", secondary=salary_job, back_populates="jobs")


class Job(BaseModel):
    id: Optional[int] = None
    title: str

    model_config = ConfigDict(from_attributes=True)
