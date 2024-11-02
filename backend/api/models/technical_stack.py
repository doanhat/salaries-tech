from typing import Optional

from pydantic import BaseModel, ConfigDict
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship

from ..database import Base
from . import salary_technical_stack


class TechnicalStackDB(Base):
    __tablename__ = "technical_stacks"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False)
    salaries = relationship(
        "SalaryDB", secondary=salary_technical_stack, back_populates="technical_stacks"
    )


class TechnicalStack(BaseModel):
    id: Optional[int] = None
    name: str

    model_config = ConfigDict(from_attributes=True)
