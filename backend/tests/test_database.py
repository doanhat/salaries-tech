import pytest
from conftest import SQLALCHEMY_DATABASE_URL
from sqlalchemy import create_engine
from sqlalchemy.orm import close_all_sessions, sessionmaker

from backend.api.database import Base, get_db, get_db_session
from backend.api.models import CompanyDB, JobDB, SalaryDB, TechnicalStackDB


@pytest.fixture(scope="module")
def test_engine():
    engine = create_engine(
        SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
    )
    Base.metadata.create_all(bind=engine)
    yield engine
    Base.metadata.drop_all(bind=engine)


@pytest.fixture(scope="function")
def test_db_session(test_engine):
    TestingSessionLocal = sessionmaker(
        autocommit=False, autoflush=False, bind=test_engine
    )
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


@pytest.fixture(scope="function")
def test_db(test_db_session):
    yield test_db_session
    test_db_session.rollback()


@pytest.fixture(scope="function")
def override_get_db(test_db_session):
    def _override_get_db():
        try:
            yield test_db_session
        finally:
            test_db_session.close()

    return _override_get_db


@pytest.fixture(autouse=True, scope="function")
def reset_db(test_db, test_engine):
    yield
    # This code runs after each test function
    close_all_sessions()
    Base.metadata.drop_all(bind=test_engine)
    Base.metadata.create_all(bind=test_engine)


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
