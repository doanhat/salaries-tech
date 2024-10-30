import os
from datetime import datetime
from typing import Dict, List, Optional, Tuple, Union

from fastapi import APIRouter, Body, Depends, HTTPException, Query, Request
from pydantic import ValidationError
from sqlalchemy import asc, delete, desc, func
from sqlalchemy.orm import Session

from ..config.logger import logger
from ..database import get_db_session
from ..models import (
    Company,
    CompanyDB,
    Job,
    JobDB,
    Salary,
    SalaryDB,
    Tag,
    TagDB,
    TechnicalStack,
    TechnicalStackDB,
    salary_job,
    salary_technical_stack,
)
from ..services.auth import create_assessment

router = APIRouter(prefix="/salaries", tags=["salaries"])


@router.post("/", response_model=Salary)
async def create_salary(
    request: Request,
    captcha_token: str = Query(...),
    user_agent: str = Query(...),
    salary: Salary = Body(...),
    db: Session = Depends(get_db_session),
) -> Salary:
    try:
        # Verify reCAPTCHA
        project_id = os.getenv("PROJECT_ID")
        recaptcha_key = os.getenv("RECAPTCHA_KEY")
        user_ip = request.client.host if request.client else None

        if not project_id or not recaptcha_key:
            raise HTTPException(status_code=500, detail="reCAPTCHA configuration error")

        assessment = create_assessment(
            project_id, recaptcha_key, captcha_token, user_ip, user_agent
        )

        if not assessment.token_properties.valid:
            raise HTTPException(status_code=400, detail="Invalid reCAPTCHA")

        if assessment.risk_analysis.score < 0.5:  # Adjust this threshold as needed
            raise HTTPException(status_code=400, detail="reCAPTCHA verification failed")

        salary_dict = salary.model_dump(exclude={"company", "jobs", "technical_stacks"})

        if "added_date" not in salary_dict or not salary_dict["added_date"]:
            salary_dict["added_date"] = datetime.now().date()

        # Convert all fields to lowercase except for company
        for field in salary_dict:
            if field != "company_name" and isinstance(salary_dict[field], str):
                salary_dict[field] = salary_dict[field].lower()

        db_salary = SalaryDB(**salary_dict)
        db.add(db_salary)

        # Handle company
        if salary.company and salary.company.name:
            db_company = (
                db.query(CompanyDB)
                .filter(func.lower(CompanyDB.name) == func.lower(salary.company.name))
                .first()
            )
            if not db_company:
                db_company = CompanyDB(
                    name=salary.company.name, type=salary.company.type
                )
                # Handle company tags
                if salary.company.tags:
                    for tag in salary.company.tags:
                        db_tag = (
                            db.query(TagDB)
                            .filter(func.lower(TagDB.name) == tag.name.lower())
                            .first()
                        )
                        if not db_tag:
                            db_tag = TagDB(name=tag.name.lower())
                            db.add(db_tag)
                        db_company.tags.append(db_tag)
                db.add(db_company)
            db_salary.company = db_company

        # Handle jobs
        if salary.jobs:
            for job in salary.jobs:
                db_job = (
                    db.query(JobDB)
                    .filter(func.lower(JobDB.title) == job.title.lower())
                    .first()
                )
                if not db_job:
                    db_job = JobDB(title=job.title.lower())
                    db.add(db_job)
                db_salary.jobs.append(db_job)

        # Handle technical stacks
        if salary.technical_stacks:
            for stack in salary.technical_stacks:
                db_stack = (
                    db.query(TechnicalStackDB)
                    .filter(func.lower(TechnicalStackDB.name) == stack.name.lower())
                    .first()
                )
                if not db_stack:
                    db_stack = TechnicalStackDB(name=stack.name.lower())
                    db.add(db_stack)
                db_salary.technical_stacks.append(db_stack)

        db.commit()
        db.refresh(db_salary)
        created_salary = Salary(
            **{c.name: getattr(db_salary, c.name) for c in db_salary.__table__.columns}
        )
        if db_salary.company:
            created_salary.company = Company(
                **{
                    c.name: getattr(db_salary.company, c.name)
                    for c in db_salary.company.__table__.columns
                }
            )
            if db_salary.company.tags:
                created_salary.company.tags = [
                    Tag(**{t.name: getattr(tag, t.name) for t in tag.__table__.columns})
                    for tag in db_salary.company.tags
                ]
        if db_salary.jobs:
            created_salary.jobs = [
                Job(**{j.name: getattr(job, j.name) for j in job.__table__.columns})
                for job in db_salary.jobs
            ]
        if db_salary.technical_stacks:
            created_salary.technical_stacks = [
                TechnicalStack(
                    **{t.name: getattr(stack, t.name) for t in stack.__table__.columns}
                )
                for stack in db_salary.technical_stacks
            ]
        return created_salary
    except ValidationError as e:
        raise HTTPException(status_code=422, detail=e.errors())
    except Exception as e:
        db.rollback()
        logger.error(f"Error creating salary: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/", response_model=Dict[str, Union[List[Salary], int]])
async def get_salaries(
    db: Session = Depends(get_db_session),
    skip: int = 0,
    limit: int = 50,
    sort_by: str = "added_date",
    sort_order: str = "desc",
    company_names: Optional[str] = Query(
        None, description="Comma-separated list of companies"
    ),
    company_tags: Optional[str] = Query(
        None, description="Comma-separated list of tags"
    ),
    company_types: Optional[str] = Query(
        None, description="Comma-separated list of company types"
    ),
    job_titles: Optional[str] = Query(
        None, description="Comma-separated list of job titles"
    ),
    locations: Optional[str] = Query(
        None, description="Comma-separated list of locations"
    ),
    genders: Optional[str] = Query(None, description="Comma-separated list of genders"),
    levels: Optional[str] = Query(None, description="Comma-separated list of levels"),
    work_types: Optional[str] = Query(
        None, description="Comma-separated list of work types"
    ),
    gross_salary_min: Optional[float] = None,
    gross_salary_max: Optional[float] = None,
    experience_years_company_min: Optional[int] = None,
    experience_years_company_max: Optional[int] = None,
    total_experience_years_min: Optional[int] = None,
    total_experience_years_max: Optional[int] = None,
    leave_days_min: Optional[int] = None,
    leave_days_max: Optional[int] = None,
    min_added_date: Optional[str] = None,
    max_added_date: Optional[str] = None,
    net_salary_min: Optional[float] = None,
    net_salary_max: Optional[float] = None,
    bonus_min: Optional[float] = None,
    bonus_max: Optional[float] = None,
    technical_stacks: Optional[str] = Query(
        None, description="Comma-separated list of technical stacks"
    ),
):
    try:
        sort_field_mapping = {
            "company_name": CompanyDB.name,
            "company_tags": CompanyDB.tags,
            "company_type": CompanyDB.type,
            "job_titles": JobDB.title,
        }
        query = db.query(SalaryDB).outerjoin(CompanyDB)
        if company_names:
            companies_list = [c.strip() for c in company_names.split(",")]
            query = query.filter(CompanyDB.name.in_(companies_list))
        if company_tags:
            tags_list = [t.strip().lower() for t in company_tags.split(",")]
            query = query.filter(CompanyDB.tags.any(TagDB.name.in_(tags_list)))
        if company_types:
            company_types_list = [ct.strip().lower() for ct in company_types.split(",")]
            query = query.filter(CompanyDB.type.in_(company_types_list))
        if job_titles:
            job_titles_list = [jt.strip().lower() for jt in job_titles.split(",")]
            query = query.filter(SalaryDB.jobs.any(JobDB.title.in_(job_titles_list)))
        if locations:
            locations_list = [l.strip().lower() for l in locations.split(",")]
            query = query.filter(SalaryDB.location.in_(locations_list))
        if genders:
            genders_list = [g.strip().lower() for g in genders.split(",")]
            query = query.filter(SalaryDB.gender.in_(genders_list))
        if levels:
            levels_list = [l.strip().lower() for l in levels.split(",")]
            query = query.filter(SalaryDB.level.in_(levels_list))
        if work_types:
            work_types_list = [wt.strip().lower() for wt in work_types.split(",")]
            query = query.filter(SalaryDB.work_type.in_(work_types_list))

        if gross_salary_min is not None:
            query = query.filter(
                func.coalesce(SalaryDB.gross_salary, 0) >= gross_salary_min
            )
        if gross_salary_max is not None:
            query = query.filter(
                func.coalesce(SalaryDB.gross_salary, 0) <= gross_salary_max
            )
        if experience_years_company_min is not None:
            query = query.filter(
                func.coalesce(SalaryDB.experience_years_company, 0)
                >= experience_years_company_min
            )
        if experience_years_company_max is not None:
            query = query.filter(
                func.coalesce(SalaryDB.experience_years_company, 0)
                <= experience_years_company_max
            )
        if total_experience_years_min is not None:
            query = query.filter(
                func.coalesce(SalaryDB.total_experience_years, 0)
                >= total_experience_years_min
            )
        if total_experience_years_max is not None:
            query = query.filter(
                func.coalesce(SalaryDB.total_experience_years, 0)
                <= total_experience_years_max
            )
        if leave_days_min is not None:
            query = query.filter(
                func.coalesce(SalaryDB.leave_days, 0) >= leave_days_min
            )
        if leave_days_max is not None:
            query = query.filter(
                func.coalesce(SalaryDB.leave_days, 0) <= leave_days_max
            )
        if min_added_date:
            try:
                min_date = datetime.strptime(min_added_date, "%Y-%m-%d").date()
                query = query.filter(SalaryDB.added_date >= min_date)
            except ValueError:
                logger.error(f"Invalid min_added_date format: {min_added_date}")
                raise HTTPException(
                    status_code=400,
                    detail="Invalid min_added_date format. Use YYYY-MM-DD.",
                )
        if max_added_date:
            try:
                max_date = datetime.strptime(max_added_date, "%Y-%m-%d").date()
                query = query.filter(SalaryDB.added_date <= max_date)
            except ValueError:
                logger.error(f"Invalid max_added_date format: {max_added_date}")
                raise HTTPException(
                    status_code=400,
                    detail="Invalid max_added_date format. Use YYYY-MM-DD.",
                )
        if net_salary_min is not None:
            query = query.filter(
                func.coalesce(SalaryDB.net_salary, 0) >= net_salary_min
            )
        if net_salary_max is not None:
            query = query.filter(
                func.coalesce(SalaryDB.net_salary, 0) <= net_salary_max
            )
        if bonus_min is not None:
            query = query.filter(func.coalesce(SalaryDB.bonus, 0) >= bonus_min)
        if bonus_max is not None:
            query = query.filter(func.coalesce(SalaryDB.bonus, 0) <= bonus_max)
        if technical_stacks:
            tech_stacks_list = [
                stack.strip().lower() for stack in technical_stacks.split(",")
            ]
            query = query.filter(
                SalaryDB.technical_stacks.any(
                    TechnicalStackDB.name.in_(tech_stacks_list)
                )
            )

        # Apply sorting
        if sort_by in sort_field_mapping:
            sort_attr = sort_field_mapping[sort_by]
        else:
            sort_attr = getattr(SalaryDB, sort_by)
        if sort_order.lower() == "asc":
            query = query.order_by(asc(sort_attr))
        else:
            query = query.order_by(desc(sort_attr))

        total = query.count()
        results = query.offset(skip).limit(limit).all()
        salaries = []
        for salary in results:
            salary_dict = {
                c.name: getattr(salary, c.name) for c in salary.__table__.columns
            }

            if salary.company:
                company_dict = {
                    c.name: getattr(salary.company, c.name)
                    for c in salary.company.__table__.columns
                }
                company_dict["tags"] = (
                    [
                        Tag(
                            **{
                                t.name: getattr(tag, t.name)
                                for t in tag.__table__.columns
                            }
                        )
                        for tag in salary.company.tags
                    ]
                    if salary.company.tags
                    else []
                )
                salary_dict["company"] = Company(**company_dict)
            else:
                salary_dict["company"] = None

            salary_dict["jobs"] = [
                Job(**{j.name: getattr(job, j.name) for j in job.__table__.columns})
                for job in salary.jobs
            ]
            salary_dict["technical_stacks"] = [
                TechnicalStack(
                    **{t.name: getattr(stack, t.name) for t in stack.__table__.columns}
                )
                for stack in salary.technical_stacks
            ]
            salaries.append(Salary(**salary_dict))
        return {"results": salaries, "total": total}

    except Exception as e:
        logger.error(f"Error in get_salaries: {str(e)}")
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")


@router.delete("/", response_model=dict)
async def delete_salaries(
    salary_ids: List[int] = Query(...), db: Session = Depends(get_db_session)
) -> Dict[str, str]:
    try:
        # Query the salaries by IDs
        salaries = db.query(SalaryDB).filter(SalaryDB.id.in_(salary_ids)).all()

        # Check if all requested salaries were found
        found_ids = [salary.id for salary in salaries]
        not_found_ids = set(salary_ids) - set(int(id) for id in found_ids)

        if not_found_ids:
            raise HTTPException(
                status_code=404,
                detail=f"Salaries with IDs {list(not_found_ids)} not found",
            )

        # Delete the associations in the junction table
        delete_stmt = delete(salary_technical_stack).where(
            salary_technical_stack.c.salary_id.in_(salary_ids)
        )
        db.execute(delete_stmt)

        delete_stmt = delete(salary_job).where(salary_job.c.salary_id.in_(salary_ids))
        db.execute(delete_stmt)

        # Delete the salaries
        for salary in salaries:
            db.delete(salary)

        db.commit()

        return {
            "message": f"Salaries with IDs {salary_ids} have been deleted successfully"
        }
    except HTTPException as he:
        raise he
    except Exception as e:
        db.rollback()
        logger.error(f"Error deleting salaries with IDs {salary_ids}: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"An error occurred while deleting the salaries: {str(e)}",
        )


@router.get("/stats/")
async def get_salary_stats(
    db: Session = Depends(get_db_session),
) -> Dict[str, Union[Dict[str, float], List[Tuple[str, float]]]]:
    try:
        from sqlalchemy import func

        avg_salary_by_city = (
            db.query(
                SalaryDB.location, func.avg(SalaryDB.gross_salary).label("avg_salary")
            )
            .group_by(SalaryDB.location)
            .all()
        )

        avg_salary_dict = {
            city: float(avg_salary) for city, avg_salary in avg_salary_by_city if city
        }
        top_10_cities = sorted(
            avg_salary_dict.items(), key=lambda x: x[1], reverse=True
        )[:10]

        return {"avg_salary_by_city": avg_salary_dict, "top_10_cities": top_10_cities}
    except Exception as e:
        logger.error(f"Error in get_salary_stats: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/check-location/")
async def check_location(
    name: str, db: Session = Depends(get_db_session)
) -> Dict[str, bool]:
    location = (
        db.query(SalaryDB).filter(SalaryDB.location == name.lower().strip()).first()
    )
    return {"exists": location is not None}


@router.get("/location-stats/")
async def get_location_stats(db: Session = Depends(get_db_session)):
    try:
        total_salaries = db.query(SalaryDB).count()
        # Get all locations and their counts
        location_counts = (
            db.query(SalaryDB.location, func.count(SalaryDB.id))
            .group_by(SalaryDB.location)
            .all()
        )

        # Sort locations by count, descending
        sorted_locations = sorted(location_counts, key=lambda x: x[1], reverse=True)

        # Get top 10 locations
        top_10 = sorted_locations[:10]

        # Calculate the sum of all other locations
        others_sum = sum(count for _, count in sorted_locations[10:])
        others_locations = sorted_locations[
            10:15
        ]  # Get next 5 locations for "Others" tooltip

        # Prepare the final data
        chart_data = [
            {
                "name": location,
                "value": count,
                "percentage": count / total_salaries * 100,
                "tooltip": [f"{location}: {count}"],
            }
            for location, count in top_10
        ]
        if others_sum > 0:
            chart_data.append(
                {
                    "name": "Others",
                    "value": others_sum,
                    "percentage": others_sum / total_salaries * 100,
                    "tooltip": [f"{loc}: {count}" for loc, count in others_locations]
                    + ["..."],
                }
            )

        return {"chart_data": chart_data}
    except Exception as e:
        logger.error(f"Error in get_location_stats: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/top-locations-by-salary/")
async def get_top_locations_by_salary(db: Session = Depends(get_db_session)):
    try:
        # Query to get top 10 locations by average salary
        top_locations = (
            db.query(
                SalaryDB.location,
                func.avg(SalaryDB.gross_salary).label("average_salary"),
                func.count(SalaryDB.id).label("count"),
            )
            .group_by(SalaryDB.location)
            .having(
                func.count(SalaryDB.id) >= 5
            )  # Only include locations with at least 5 entries
            .order_by(func.avg(SalaryDB.gross_salary).desc())
            .limit(10)
            .all()
        )

        # Prepare the data for the frontend
        result = [
            {
                "name": location,
                "average_salary": round(average_salary, 2),
                "count": count,
            }
            for location, average_salary, count in top_locations
        ]

        return result
    except Exception as e:
        logger.error(f"Error in get_top_locations_by_salary: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
