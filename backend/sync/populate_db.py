import json
from datetime import datetime

import requests
from backend.api.database import SessionLocal
from backend.api.models import CompanyDB, JobDB, SalaryDB, TagDB, TechnicalStackDB, WorkType
from sqlalchemy import func
from sqlalchemy.orm import Session


def load_data(db: Session):
    url = "https://salaires.dev/api/salaries"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()

        # Get the maximum added_date from the database
        max_date = db.query(func.max(SalaryDB.added_date)).scalar()

        # Filter data based on the max_date
        if max_date:
            filtered_data = [
                item
                for item in data
                if datetime.strptime(item["date"], "%Y-%m-%dT%H:%M:%S.%fZ").date()
                > max_date
            ]
        else:
            filtered_data = data
        print(json.dumps(filtered_data, indent=4))
        return filtered_data
    else:
        raise Exception(
            f"Failed to fetch data from API. Status code: {response.status_code}"
        )


def load_company_mapping():
    with open("backend/sync/mapping_20241012172351.txt", "r") as f:
        mapping = {}
        for line in f:
            line = line.strip()
            if line:
                parts = line.split(" - ", 1)
                if len(parts) == 2:
                    company, info = parts
                    company_type = info.split(" (")[0]
                    mapping[company.strip()] = company_type.strip()
        return mapping


def get_or_create_company(db: Session, name: str, company_type: str):
    company = db.query(CompanyDB).filter(CompanyDB.name == name).first()
    if not company:
        company = CompanyDB(name=name, type=company_type)
        db.add(company)
        db.flush()
    return company


def get_or_create_tag(db: Session, name: str):
    tag = db.query(TagDB).filter(TagDB.name == name.lower()).first()
    if not tag:
        tag = TagDB(name=name.lower())
        db.add(tag)
        db.flush()
    return tag


def get_or_create_job(db: Session, title: str):
    job = db.query(JobDB).filter(JobDB.title == title.lower()).first()
    if not job:
        job = JobDB(title=title.lower())
        db.add(job)
        db.flush()
    return job


def get_or_create_technical_stack(db: Session, name: str):
    stack = (
        db.query(TechnicalStackDB).filter(TechnicalStackDB.name == name.lower()).first()
    )
    if not stack:
        stack = TechnicalStackDB(name=name.lower())
        db.add(stack)
        db.flush()
    return stack


def populate_db():
    db = SessionLocal()
    company_mapping = load_company_mapping()

    try:
        data = load_data(db)

        for item in data:
            company_name = item["company"]
            company_type = company_mapping.get(company_name, None)
            company = get_or_create_company(db, company_name, company_type)

            jobs = [get_or_create_job(db, item["title"])] if item["title"] else []

            # Assuming technical stacks are not provided in the API data
            stacks = []

            salary = SalaryDB(
                company=company,
                location=item["location"].lower(),
                gross_salary=item["compensation"],
                gender=None,  # Not provided in the API data
                experience_years_company=item["company_xp"],
                total_experience_years=item["total_xp"],
                level=item["level"].lower() if item["level"] else None,
                work_type=WorkType.REMOTE.value
                if item["remote"] and item["remote"]["variant"] == "full"
                else WorkType.HYBRID.value
                if item["remote"]
                else None,
                added_date=datetime.strptime(
                    item["date"], "%Y-%m-%dT%H:%M:%S.%fZ"
                ).date(),
                leave_days=None,  # Not provided in the API data
            )

            salary.jobs.extend(jobs)
            salary.technical_stacks.extend(stacks)

            db.add(salary)

        db.commit()
        print("Database populated successfully!")
    except Exception as e:
        db.rollback()
        print(f"An error occurred: {e}")
    finally:
        db.close()


if __name__ == "__main__":
    populate_db()
