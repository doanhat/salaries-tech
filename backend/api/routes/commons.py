from typing import Dict, List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from ..config.logger import logger
from ..database import get_db_session
from ..models import CompanyType, Level, WorkType
from ..models.company import CompanyDB, TagDB
from ..models.job import JobDB
from ..models.salary import SalaryDB
from ..models.technical_stack import TechnicalStackDB
from ..tools.text import capitalize_words

router = APIRouter(tags=["commons"])


@router.get("/choices/", response_model=Dict[str, List[str]])
async def get_choices(
    db: Session = Depends(lambda: next(get_db_session(is_cache=True))),
) -> Dict[str, List[str]]:
    try:
        company_names = db.query(CompanyDB.name).distinct().all()
        company_tags = db.query(TagDB.name).distinct().all()
        job_titles = db.query(JobDB.title).distinct().all()
        locations = db.query(SalaryDB.location).distinct().all()
        technical_stacks = db.query(TechnicalStackDB.name).distinct().all()

        return {
            "company_names": sorted([c[0] for c in company_names if c[0]]),
            "company_types": [capitalize_words(ct.value) for ct in CompanyType],
            "company_tags": sorted(
                [capitalize_words(d[0]) for d in company_tags if d[0]]
            ),
            "job_titles": sorted(
                [capitalize_words(job[0]) for job in job_titles if job[0]]
            ),
            "locations": sorted([capitalize_words(l[0]) for l in locations if l[0]]),
            "levels": [capitalize_words(l.value) for l in Level],
            "work_types": [capitalize_words(wt.value) for wt in WorkType],
            "technical_stacks": sorted(
                [capitalize_words(ts[0]) for ts in technical_stacks if ts[0]]
            ),
        }
    except SQLAlchemyError as e:
        logger.error(f"Database error when fetching choices: {str(e)}")
        raise HTTPException(status_code=500, detail="Database error occurred")
    except Exception as e:
        logger.error(f"Unexpected error when fetching choices: {str(e)}")
        raise HTTPException(status_code=500, detail="An unexpected error occurred")
