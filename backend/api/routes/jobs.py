from typing import Dict, List

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import delete, func
from sqlalchemy.orm import Session

from ..database import get_db_session, refresh_cache_table
from ..models import salary_job
from ..models.job import Job, JobDB

router = APIRouter(prefix="/jobs", tags=["jobs"])


@router.post("/", response_model=Job)
async def create_job(job: Job, db: Session = Depends(get_db_session)) -> Job:
    db_job = JobDB(title=job.title.lower())
    db.add(db_job)
    db.commit()
    refresh_cache_table(JobDB)
    db.refresh(db_job)
    return Job(**{j.name: getattr(db_job, j.name) for j in db_job.__table__.columns})


@router.get("/", response_model=Dict[str, List[Job] | int])
async def get_jobs(
    db: Session = Depends(lambda: next(get_db_session(is_cache=True))),
) -> Dict[str, List[Job] | int]:
    jobs = db.query(JobDB).all()
    return {
        "results": [
            Job(**{j.name: getattr(job, j.name) for j in job.__table__.columns})
            for job in jobs
        ],
        "total": len(jobs),
    }


@router.delete("/", response_model=Dict[str, str])
async def delete_jobs(
    job_ids: List[int] = Query(...), db: Session = Depends(get_db_session)
) -> Dict[str, str]:
    jobs = db.query(JobDB).filter(JobDB.id.in_(job_ids)).all()

    # Check if any jobs were not found
    found_ids = {int(job.id) for job in jobs}  # Explicitly convert to int
    not_found_ids = set(job_ids) - found_ids

    if not_found_ids:
        raise HTTPException(
            status_code=404, detail=f"Jobs with IDs {not_found_ids} not found"
        )

    # Delete the associations in the junction table
    delete_stmt = delete(salary_job).where(salary_job.c.job_id.in_(job_ids))
    db.execute(delete_stmt)
    for job in jobs:
        db.delete(job)
    db.commit()
    refresh_cache_table(JobDB)
    refresh_cache_table(salary_job)
    return {"message": f"Jobs with IDs {job_ids} have been deleted successfully"}


@router.get("/check-title/", response_model=Dict[str, bool])
async def check_job_title(
    title: str, db: Session = Depends(lambda: next(get_db_session(is_cache=True)))
) -> Dict[str, bool]:
    job = (
        db.query(JobDB).filter(func.lower(JobDB.title) == title.lower().strip()).first()
    )
    return {"exists": job is not None}
