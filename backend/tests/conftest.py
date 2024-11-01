import os
import sys
from datetime import date
from typing import Any, Dict, Optional

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import close_all_sessions, sessionmaker

from backend.api.database import Base, get_db_session
from backend.api.main import app
from backend.api.models import CompanyDB, JobDB, SalaryDB, TagDB, TechnicalStackDB

# Get the absolute path to the 'backend' directory
backend_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

# Add the backend directory to the Python path
sys.path.insert(0, backend_dir)

# Create the database URL
SQLALCHEMY_DATABASE_URL = f"sqlite:///{os.path.join(backend_dir, 'test.db')}"
# Set the environment to test
os.environ["ENV"] = "test"


# Database fixtures
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


# Client fixtures
class AuthenticatedTestClient(TestClient):
    """Custom TestClient that includes API key header in all requests"""

    def request(
        self,
        method: str,
        url: str,
        headers: Optional[Dict[str, str]] = None,
        **kwargs: Any,
    ) -> TestClient:
        """Override request method to include API key header"""
        headers = headers or {}
        headers.update({"X-API-Key": "test_api_key"})
        return super().request(method, url, headers=headers, **kwargs)


@pytest.fixture(scope="function")
def client(override_get_db, reset_db):
    app.dependency_overrides[get_db_session] = override_get_db
    with AuthenticatedTestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


@pytest.fixture(scope="function")
def unauthenticated_client(override_get_db, reset_db):
    app.dependency_overrides[get_db_session] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


# Data fixtures


@pytest.fixture(scope="function")
def sample_salary(test_db):
    # Create a tag
    tag = TagDB(name="tech")
    test_db.add(tag)
    test_db.flush()

    # Create a company
    company = CompanyDB(name="Test Company", type="startup")
    company.tags.append(tag)
    test_db.add(company)
    test_db.flush()

    # Create a job
    job = JobDB(title="Software Engineer")
    test_db.add(job)
    test_db.flush()

    # Create a technical stack
    technical_stack = TechnicalStackDB(name="Python")
    test_db.add(technical_stack)
    test_db.flush()

    # Create a salary
    salary = SalaryDB(
        gender="male",
        level="junior",
        gross_salary=50000,
        work_type="remote",
        net_salary=40000,
        added_date=date(2024, 10, 19),
        location="New York",
        bonus=5000,
        total_experience_years=2,
        leave_days=20,
        experience_years_company=1,
        company_id=company.id,
    )
    salary.jobs.append(job)
    test_db.add(salary)
    test_db.commit()

    return salary
