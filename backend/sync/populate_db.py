import json
from datetime import datetime
import os
import sys
import requests
from backend.api.models import WorkType
from sqlalchemy import create_engine, func, text
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import libsql_experimental as libsql

load_dotenv()

def load_data(session):
    url = "https://salaires.dev/api/salaries"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()

        result = session.execute(text("SELECT MAX(added_date) FROM salaries"))
        max_date = result.scalar()

        if max_date:
            filtered_data = [
                item
                for item in data
                if datetime.strptime(item["date"], "%Y-%m-%dT%H:%M:%S.%fZ").date().isoformat() > max_date
            ]
        else:
            filtered_data = data
        return filtered_data
    else:
        raise Exception(f"Failed to fetch data from API. Status code: {response.status_code}")

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
                    mapping[company.strip()] = company_type.strip().lower()
        return mapping

def prompt_for_verification(item, default):
    user_input = input(f"Verify {item} (current: {default}): ").strip()
    return user_input if user_input else default

def populate_db():
    url = os.getenv("TURSO_DATABASE_URL")
    auth_token = os.getenv("TURSO_AUTH_TOKEN")
    engine = create_engine(
        f"sqlite+{url}/?authToken={auth_token}&secure=true",
        echo=True
    )
    
    Session = sessionmaker(bind=engine)
    session = Session()

    try:
        company_mapping = load_company_mapping()
        data = load_data(session)

        for item in data:
            print("\nNew salary entry:")
            print(json.dumps(item, indent=2))
            
            company_name = prompt_for_verification("company", item["company"])
            company_type = prompt_for_verification("company type", company_mapping.get(company_name, "Unknown"))
            
            result = session.execute(text("SELECT id FROM companies WHERE name = :name"), {"name": company_name})
            company_id = result.scalar()
            if not company_id:
                result = session.execute(text("INSERT INTO companies (name, type) VALUES (:name, :type) RETURNING id"),
                                         {"name": company_name, "type": company_type})
                company_id = result.scalar()

            job_title = prompt_for_verification("job title", item["title"])
            job_id = None
            if job_title:
                result = session.execute(text("SELECT id FROM jobs WHERE title = :title"), {"title": job_title.lower()})
                job_id = result.scalar()
                if not job_id:
                    result = session.execute(text("INSERT INTO jobs (title) VALUES (:title) RETURNING id"),
                                             {"title": job_title.lower()})
                    job_id = result.scalar()

            salary_data = {
                "company_id": company_id,
                "location": prompt_for_verification("location", item["location"].lower()),
                "gross_salary": float(prompt_for_verification("gross salary", item["compensation"])),
                "experience_years_company": int(prompt_for_verification("years at company", item["company_xp"])),
                "total_experience_years": int(prompt_for_verification("total years of experience", item["total_xp"])),
                "level": prompt_for_verification("level", item["level"].lower() if item["level"] else None),
                "work_type": prompt_for_verification("work type", 
                    WorkType.REMOTE.value if item["remote"] and item["remote"]["variant"] == "full"
                    else WorkType.HYBRID.value if item["remote"] else None),
                "added_date": prompt_for_verification("added date", 
                    datetime.strptime(item["date"], "%Y-%m-%dT%H:%M:%S.%fZ").date().isoformat())
            }

            print("\nVerified salary data:")
            print(json.dumps(salary_data, indent=2))
            
            if input("Do you want to insert this data? (y/n): ").lower() != 'y':
                print("Skipping this entry.")
                continue

            result = session.execute(text("""
                INSERT INTO salaries (company_id, location, gross_salary, experience_years_company, 
                                      total_experience_years, level, work_type, added_date)
                VALUES (:company_id, :location, :gross_salary, :experience_years_company, 
                        :total_experience_years, :level, :work_type, :added_date)
                RETURNING id
            """), salary_data)
            salary_id = result.scalar()

            if job_id:
                session.execute(text("INSERT INTO salary_job (salary_id, job_id) VALUES (:salary_id, :job_id)"),
                                {"salary_id": salary_id, "job_id": job_id})

            print("Entry inserted successfully!")

        session.commit()
        print("Database populated successfully!")
    except Exception as e:
        session.rollback()
        print(f"An error occurred: {e}")
    finally:
        conn = libsql.connect("backend/salaries_dev_data.db", sync_url=url, auth_token=auth_token)
        conn.sync()
        session.close()

if __name__ == "__main__":
    populate_db()
