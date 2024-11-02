from typing import List, Optional

from pydantic import BaseModel, ConfigDict
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship

from ..database import Base
from . import CompanyType, company_tag


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
