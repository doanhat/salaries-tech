from datetime import date

import pytest

from backend.api.models import (
    Company,
    CompanyType,
    Gender,
    Job,
    Level,
    Salary,
    Tag,
    TechnicalStack,
    WorkType,
)


def test_company_model():
    company = Company(name="Test Company", type=CompanyType.STARTUP)
    assert company.name == "Test Company"
    assert company.type == CompanyType.STARTUP


def test_company_with_tags():
    tags = [Tag(name="tech"), Tag(name="startup")]
    company = Company(name="Test Company", type=CompanyType.STARTUP, tags=tags)
    assert len(company.tags) == 2
    assert company.tags[0].name == "tech"
    assert company.tags[1].name == "startup"


def test_job_model():
    job = Job(title="Software Engineer")
    assert job.title == "Software Engineer"


def test_technical_stack_model():
    stack = TechnicalStack(name="Python")
    assert stack.name == "Python"


def test_salary_model():
    company = Company(name="Test Company", type=CompanyType.STARTUP)
    jobs = [Job(title="Software Engineer")]
    technical_stacks = [TechnicalStack(name="Python")]

    salary = Salary(
        company=company,
        jobs=jobs,
        location="Test City",
        gross_salary=100000,
        net_salary=75000,
        bonus=10000,
        gender=Gender.MALE,
        experience_years_company=2,
        total_experience_years=5,
        level=Level.MID,
        work_type=WorkType.REMOTE,
        added_date=date.today(),
        leave_days=25,
        technical_stacks=technical_stacks,
    )

    assert salary.company.name == "Test Company"
    assert salary.jobs[0].title == "Software Engineer"
    assert salary.location == "Test City"
    assert salary.gross_salary == 100000
    assert salary.net_salary == 75000
    assert salary.bonus == 10000
    assert salary.gender == Gender.MALE
    assert salary.experience_years_company == 2
    assert salary.total_experience_years == 5
    assert salary.level == Level.MID
    assert salary.work_type == WorkType.REMOTE
    assert salary.added_date == date.today()
    assert salary.leave_days == 25
    assert salary.technical_stacks[0].name == "Python"


@pytest.mark.parametrize("company_type", list(CompanyType))
def test_company_types(company_type):
    company = Company(name="Test Company", type=company_type)
    assert company.type == company_type


@pytest.mark.parametrize("level", list(Level))
def test_salary_levels(level):
    salary = Salary(location="Test City", gross_salary=100000, level=level)
    assert salary.level == level


@pytest.mark.parametrize("work_type", list(WorkType))
def test_salary_work_types(work_type):
    salary = Salary(location="Test City", gross_salary=100000, work_type=work_type)
    assert salary.work_type == work_type


@pytest.mark.parametrize("gender", list(Gender))
def test_salary_genders(gender):
    salary = Salary(location="Test City", gross_salary=100000, gender=gender)
    assert salary.gender == gender
