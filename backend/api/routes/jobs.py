from typing import Dict, List

from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session

from ..database import get_db_session
from ..models import Job, JobDB

router = APIRouter(prefix="/jobs", tags=["jobs"])


@router.post("/", response_model=Job)
async def create_job(job: Job, db: Session = Depends(get_db_session)) -> Job:
    db_job = JobDB(title=job.title.lower())
    db.add(db_job)
    db.commit()
    db.refresh(db_job)
    return Job(**{j.name: getattr(db_job, j.name) for j in db_job.__table__.columns})


@router.get("/", response_model=Dict[str, List[Job] | int])
async def get_jobs(
    db: Session = Depends(get_db_session),
) -> Dict[str, List[Job] | int]:
    jobs = db.query(JobDB).all()
    return {
        "results": [
            Job(**{j.name: getattr(job, j.name) for j in job.__table__.columns})
            for job in jobs
        ],
        "total": len(jobs),
    }


@router.get("/check-title/")
async def check_job_title(
    title: str, db: Session = Depends(get_db_session)
) -> Dict[str, bool]:
    job = (
        db.query(JobDB).filter(func.lower(JobDB.title) == title.lower().strip()).first()
    )
    return {"exists": job is not None}
