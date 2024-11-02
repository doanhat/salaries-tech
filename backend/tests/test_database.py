from backend.api.database import get_db
from backend.api.models.company import CompanyDB
from backend.api.models.job import JobDB
from backend.api.models.salary import SalaryDB
from backend.api.models.technical_stack import TechnicalStackDB


def test_create_db_session(test_db_session):
    assert test_db_session is not None


def test_get_db():
    with get_db() as db:
        assert db is not None


def test_create_and_query_company(test_db):
    company = CompanyDB(name="Test Company", type="startup")
    test_db.add(company)
    test_db.commit()

    queried_company = test_db.query(CompanyDB).filter_by(name="Test Company").first()
    assert queried_company is not None
    assert queried_company.name == "Test Company"
    assert queried_company.type == "startup"


def test_create_and_query_job(test_db):
    job = JobDB(title="Software Engineer")
    test_db.add(job)
    test_db.commit()

    queried_job = test_db.query(JobDB).filter_by(title="Software Engineer").first()
    assert queried_job is not None
    assert queried_job.title == "Software Engineer"


def test_create_and_query_salary(test_db):
    salary = SalaryDB(location="Test City", gross_salary=100000)
    test_db.add(salary)
    test_db.commit()

    queried_salary = test_db.query(SalaryDB).filter_by(location="Test City").first()
    assert queried_salary is not None
    assert queried_salary.location == "Test City"
    assert queried_salary.gross_salary == 100000


def test_create_and_query_technical_stack(test_db):
    stack = TechnicalStackDB(name="Python")
    test_db.add(stack)
    test_db.commit()

    queried_stack = test_db.query(TechnicalStackDB).filter_by(name="Python").first()
    assert queried_stack is not None
    assert queried_stack.name == "Python"
