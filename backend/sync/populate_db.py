import json
from datetime import datetime
import os
import sys
import requests
from backend.api.models import EmailVerificationStatus, WorkType
from sqlalchemy import create_engine, func, text
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import libsql_experimental as libsql

load_dotenv()

def load_data():
    url = "https://salaires.dev/api/salaries"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        print(f"Loaded {len(data)} salaries from API")
        return data
    else:
        raise Exception(f"Failed to fetch data from API. Status code: {response.status_code}")

def load_company_mapping(session):
    result = session.execute(text("""SELECT name, type FROM companies"""))
    mapping = {}
    for row in result:
        company_name, company_type = row
        mapping[company_name] = company_type
    return mapping

def prompt_for_verification(item, default="<none>"):
    user_input = input(f"Verify {item} (current: {default}): ").strip()
    return user_input if user_input else default

def populate_db():
    url = os.getenv("SQLALCHEMY_DATABASE_URL")
    engine = create_engine(url)
    Session = sessionmaker(bind=engine)
    session = Session()

    try:
        company_mapping = load_company_mapping(session)
        data = load_data()
        with open("backend/sync/skipped_salaries.json", "r+") as f:
            skipped_data = json.load(f)
            for item in data:
                print("\nNew salary entry:")
                print(json.dumps(item, indent=2))
                if item in skipped_data:
                    print("Entry already exists in the JSON file. Skipping this entry.")
                    continue
                else:
                    if input("Do you want to process this entry? (y/n): ").lower() != 'y':
                        print("Skipping this entry.")
                        if item not in skipped_data:
                            skipped_data.append(item)
                        continue
                    else:
                        company_name = prompt_for_verification("company", item["company"])
                        company_id = None
                        if company_name != "<none>":
                            company_type = prompt_for_verification("company type", company_mapping.get(company_name, "Unknown"))
                            result = session.execute(text("SELECT id FROM companies WHERE name = :name"), {"name": company_name})
                            company_id = result.scalar()
                            if not company_id:
                                result = session.execute(text("INSERT INTO companies (name, type) VALUES (:name, :type) RETURNING id"),
                                                    {"name": company_name, "type": company_type})
                                company_id = result.scalar()


                        job_title = prompt_for_verification("job title", item["title"].lower())
                        job_id = None
                        if job_title:
                            result = session.execute(text("SELECT id FROM jobs WHERE title = :title"), {"title": job_title.lower()})
                            job_id = result.scalar()
                            if not job_id:
                                result = session.execute(text("INSERT INTO jobs (title) VALUES (:title) RETURNING id"),
                                                        {"title": job_title.lower()})
                                job_id = result.scalar()
                        # prompt for technical stack, if y, prompt for name, check if exists, if not, insert, if n, continue, if e end the process
                        technical_stack_id_list = []
                        technical_stack_input = input("Do you want to add a technical stack? (y/n): ").lower()
                        while technical_stack_input == 'y':
                            technical_stack_name = prompt_for_verification("technical stack name")
                            result = session.execute(text("SELECT id FROM technical_stacks WHERE name = :name"), {"name": technical_stack_name})
                            technical_stack_id = result.scalar()
                            if not technical_stack_id:
                                result = session.execute(text("INSERT INTO technical_stacks (name) VALUES (:name) RETURNING id"),
                                                        {"name": technical_stack_name})
                                technical_stack_id = result.scalar()
                            technical_stack_id_list.append(technical_stack_id)
                            technical_stack_input = input("Do you want to add another technical stack? (y/n): ").lower()
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
                                datetime.strptime(item["date"], "%Y-%m-%dT%H:%M:%S.%fZ").date().isoformat()),
                            "verification": EmailVerificationStatus.VERIFIED.value
                        }
                        if technical_stack_id_list:
                            salary_data["technical_stack_id"] = technical_stack_id_list
                        # check if a salary with the same data already exists
                        result = session.execute(text("SELECT id FROM salaries WHERE company_id = :company_id AND location = :location AND gross_salary = :gross_salary AND experience_years_company = :experience_years_company AND total_experience_years = :total_experience_years AND level = :level AND work_type = :work_type AND added_date = :added_date"), salary_data)
                        if result.scalar():
                            print("Salary with the same data already exists. Skipping this entry.")
                            continue

                        print("\nVerified salary data:")
                        print(json.dumps(salary_data, indent=2))
                        
                        if input("Do you want to insert this data? (y/n): ").lower() != 'y':
                            print("Skipping this entry.")
                            continue
                        
                        result = session.execute(text("""
                            INSERT INTO salaries (company_id, location, gross_salary, experience_years_company, 
                                                total_experience_years, level, work_type, added_date, verification)
                            VALUES (:company_id, :location, :gross_salary, :experience_years_company, 
                                    :total_experience_years, :level, :work_type, :added_date, :verification)
                            RETURNING id
                        """), salary_data)
                        salary_id = result.scalar()

                        if job_id:
                            session.execute(text("INSERT INTO salary_job (salary_id, job_id) VALUES (:salary_id, :job_id)"),
                                            {"salary_id": salary_id, "job_id": job_id})

                        for id in technical_stack_id_list:
                            session.execute(text("INSERT INTO salary_technical_stack (salary_id, technical_stack_id) VALUES (:salary_id, :technical_stack_id)"),
                                            {"salary_id": salary_id, "technical_stack_id": id})

                        print("Entry inserted successfully!")

                        session.commit()
                        skipped_data.append(item)
                        print("Database populated successfully!")

            with open('backend/sync/skipped_salaries.json', 'w') as f:
                json.dump(skipped_data, f, indent=2)
    except Exception as e:
        session.rollback()
        print(f"An error occurred: {e}")
    finally:
        session.close()

if __name__ == "__main__":
    populate_db()
