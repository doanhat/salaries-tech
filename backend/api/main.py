import json
import logging
import os
from datetime import datetime
from typing import Dict, List, Optional, Tuple, Union

from dotenv import load_dotenv
from fastapi import Depends, FastAPI, Form, HTTPException, Query, Request
from fastapi.middleware.cors import CORSMiddleware
from google.cloud import recaptchaenterprise_v1
from google.cloud.recaptchaenterprise_v1 import Assessment
from pydantic import ValidationError
from sqlalchemy import asc, delete, desc, func
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from sqlalchemy.orm import Session

from .database import get_db_session
from .models import (
    Company,
    CompanyDB,
    CompanyType,
    Job,
    JobDB,
    Level,
    Salary,
    SalaryDB,
    Tag,
    TagDB,
    TechnicalStack,
    TechnicalStackDB,
    WorkType,
    company_tag,
    salary_job,
    salary_technical_stack,
)
from .tools import capitalize_words

load_dotenv()
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("ALLOWED_ORIGINS", "http://localhost:3000").split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def create_assessment(
    project_id: str,
    recaptcha_site_key: str,
    token: str,
    user_ip_address: Optional[str],
    user_agent: Optional[str],
) -> Assessment:
    """Create an assessment to analyze the risk of a UI action."""
    client = recaptchaenterprise_v1.RecaptchaEnterpriseServiceClient()

    event = recaptchaenterprise_v1.Event()
    event.site_key = recaptcha_site_key
    event.token = token
    if user_ip_address:
        event.user_ip_address = user_ip_address
    if user_agent:
        event.user_agent = user_agent

    assessment = recaptchaenterprise_v1.Assessment()
    assessment.event = event

    project_name = f"projects/{project_id}"

    request = recaptchaenterprise_v1.CreateAssessmentRequest()
    request.assessment = assessment
    request.parent = project_name

    response = client.create_assessment(request)

    return response


@app.post("/salaries/", response_model=Salary)
async def create_salary(
    request: Request,
    salary: str = Form(...),
    captcha_token: str = Form(...),
    user_agent: str = Form(...),
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

        salary_data = json.loads(salary)
        salary_model = Salary.model_validate(salary_data)

        salary_dict = salary_model.model_dump(
            exclude={"company", "jobs", "technical_stacks"}
        )

        if "added_date" not in salary_dict or not salary_dict["added_date"]:
            salary_dict["added_date"] = datetime.now().date()

        # Convert all fields to lowercase except for company
        for field in salary_dict:
            if field != "company_name" and isinstance(salary_dict[field], str):
                salary_dict[field] = salary_dict[field].lower()

        db_salary = SalaryDB(**salary_dict)
        db.add(db_salary)  # Add the salary to the session immediately

        # Handle company
        if salary_model.company and salary_model.company.name:
            db_company = (
                db.query(CompanyDB)
                .filter(
                    func.lower(CompanyDB.name) == func.lower(salary_model.company.name)
                )
                .first()
            )
            if not db_company:
                db_company = CompanyDB(
                    name=salary_model.company.name, type=salary_model.company.type
                )
                # Handle company tags
                if salary_model.company.tags:
                    for tag in salary_model.company.tags:
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
        if salary_model.jobs:
            for job in salary_model.jobs:
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
        if salary_model.technical_stacks:
            for stack in salary_model.technical_stacks:
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
        print(created_salary)
        return created_salary
    except ValidationError as e:
        raise HTTPException(status_code=422, detail=e.errors())
    except Exception as e:
        db.rollback()
        logger.error(f"Error creating salary: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/salaries/", response_model=Dict[str, Union[List[Salary], int]])
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
    variables_min: Optional[float] = None,
    variables_max: Optional[float] = None,
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
        if variables_min is not None:
            query = query.filter(func.coalesce(SalaryDB.variables, 0) >= variables_min)
        if variables_max is not None:
            query = query.filter(func.coalesce(SalaryDB.variables, 0) <= variables_max)
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


@app.delete("/salaries/", response_model=dict)
async def delete_salaries(
    salary_ids: List[int] = Query(...), db: Session = Depends(get_db_session)
) -> Dict[str, str]:
    try:
        print(f"Attempting to delete salaries with IDs: {salary_ids}")

        # Query the salaries by IDs
        salaries = db.query(SalaryDB).filter(SalaryDB.id.in_(salary_ids)).all()
        print(f"Found salaries to delete: {[s.id for s in salaries]}")

        # Check if all requested salaries were found
        found_ids = [salary.id for salary in salaries]
        not_found_ids = set(salary_ids) - set(int(id) for id in found_ids)

        if not_found_ids:
            print(f"Salaries not found: {not_found_ids}")
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
            print(f"Deleted salary with ID: {salary.id}")

        db.commit()
        print("Committed deletion transaction")

        return {
            "message": f"Salaries with IDs {salary_ids} have been deleted successfully"
        }
    except HTTPException as he:
        print(f"HTTP Exception: {str(he)}")
        raise he
    except Exception as e:
        db.rollback()
        print(f"Error deleting salaries: {str(e)}")
        logger.error(f"Error deleting salaries with IDs {salary_ids}: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"An error occurred while deleting the salaries: {str(e)}",
        )


@app.get("/salaries/stats/")
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


@app.get("/salaries/choices/")
async def get_choices(db: Session = Depends(get_db_session)):
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


@app.get("/technical-stacks/", response_model=List[TechnicalStack])
async def get_technical_stacks(
    db: Session = Depends(get_db_session),
) -> List[TechnicalStack]:
    stacks = db.query(TechnicalStackDB).all()
    return [
        TechnicalStack(
            **{t.name: getattr(stack, t.name) for t in stack.__table__.columns}
        )
        for stack in stacks
    ]


@app.post("/technical-stacks/", response_model=TechnicalStack)
async def create_technical_stack(
    stack: TechnicalStack, db: Session = Depends(get_db_session)
) -> TechnicalStack:
    db_stack = TechnicalStackDB(name=stack.name)
    db.add(db_stack)
    db.commit()
    db.refresh(db_stack)
    return TechnicalStack(
        **{t.name: getattr(db_stack, t.name) for t in db_stack.__table__.columns}
    )


@app.post("/jobs/", response_model=Job)
async def create_job(job: Job, db: Session = Depends(get_db_session)) -> Job:
    db_job = JobDB(title=job.title.lower())
    db.add(db_job)
    db.commit()
    db.refresh(db_job)
    return Job(**{j.name: getattr(db_job, j.name) for j in db_job.__table__.columns})


@app.get("/jobs/", response_model=Dict[str, Union[List[Job], int]])
async def get_jobs(
    db: Session = Depends(get_db_session),
) -> Dict[str, Union[List[Job], int]]:
    jobs = db.query(JobDB).all()
    return {
        "results": [
            Job(**{j.name: getattr(job, j.name) for j in job.__table__.columns})
            for job in jobs
        ],
        "total": len(jobs),
    }


@app.post("/companies/", response_model=Company)
async def create_company(
    company: Company, db: Session = Depends(get_db_session)
) -> Company:
    company_dict = company.model_dump(exclude={"tags"})
    db_company = CompanyDB(**company_dict)
    # Handle company tags
    if company.tags:
        for tag in company.tags:
            tag_name = tag.name if isinstance(tag, Tag) else tag
            db_tag = (
                db.query(TagDB)
                .filter(func.lower(TagDB.name) == func.lower(tag_name))
                .first()
            )
            if not db_tag:
                db_tag = TagDB(name=tag_name.lower())
                db.add(db_tag)
            db_company.tags.append(db_tag)
    db.add(db_company)
    try:
        db.commit()
        db.refresh(db_company)
        return Company(
            **{
                c.name: getattr(db_company, c.name)
                for c in db_company.__table__.columns
            },
            tags=[Tag(name=tag.name) for tag in db_company.tags],
        )
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=400, detail="A company with this name already exists"
        )


@app.get("/companies/", response_model=Dict[str, Union[List[Company], int]])
async def get_companies(
    db: Session = Depends(get_db_session), limit: int = 50, skip: int = 0
) -> Dict[str, Union[List[Company], int]]:
    results = db.query(CompanyDB).offset(skip).limit(limit).all()
    total = db.query(CompanyDB).count()
    companies = []
    for company in results:
        company_dict = {
            c.name: getattr(company, c.name) for c in company.__table__.columns
        }
        company_dict["tags"] = [
            Tag(**{t.name: getattr(tag, t.name) for t in tag.__table__.columns})
            for tag in company.tags
        ]
        companies.append(Company(**company_dict))
    return {"results": companies, "total": total}


@app.delete("/companies/", response_model=dict)
async def delete_companies(
    company_ids: List[int] = Query(...), db: Session = Depends(get_db_session)
) -> Dict[str, str]:
    companies = db.query(CompanyDB).filter(CompanyDB.id.in_(company_ids)).all()

    # Check if any companies were not found
    found_ids = {int(company.id) for company in companies}  # Explicitly convert to int
    not_found_ids = set(company_ids) - found_ids

    if not_found_ids:
        raise HTTPException(
            status_code=404, detail=f"Companies with IDs {not_found_ids} not found"
        )

    # Delete the associations in the junction table
    delete_stmt = delete(company_tag).where(company_tag.c.company_id.in_(company_ids))
    db.execute(delete_stmt)
    for company in companies:
        db.delete(company)
    db.commit()
    return {
        "message": f"Companies with IDs {company_ids} have been deleted successfully"
    }


@app.get("/check-company-name/")
async def check_company_name(
    name: str, db: Session = Depends(get_db_session)
) -> Dict[str, bool]:
    company = db.query(CompanyDB).filter(CompanyDB.name == name.strip()).first()
    return {"exists": company is not None}


@app.get("/check-company-tag/")
async def check_company_tag(
    name: str, db: Session = Depends(get_db_session)
) -> Dict[str, bool]:
    tag = db.query(TagDB).filter(TagDB.name == name.lower().strip()).first()
    return {"exists": tag is not None}


@app.get("/check-job-title/")
async def check_job_title(
    title: str, db: Session = Depends(get_db_session)
) -> Dict[str, bool]:
    job = (
        db.query(JobDB).filter(func.lower(JobDB.title) == title.lower().strip()).first()
    )
    return {"exists": job is not None}


@app.get("/check-location/")
async def check_location(
    name: str, db: Session = Depends(get_db_session)
) -> Dict[str, bool]:
    location = (
        db.query(SalaryDB).filter(SalaryDB.location == name.lower().strip()).first()
    )
    return {"exists": location is not None}


@app.get("/check-technical-stack/")
async def check_technical_stack(
    name: str, db: Session = Depends(get_db_session)
) -> Dict[str, bool]:
    stack = (
        db.query(TechnicalStackDB)
        .filter(func.lower(TechnicalStackDB.name) == name.lower().strip())
        .first()
    )
    return {"exists": stack is not None}


@app.get("/")
async def read_root():
    return {"message": "Salary Information API"}
