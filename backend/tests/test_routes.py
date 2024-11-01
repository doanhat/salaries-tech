import json
import random
import uuid
from datetime import datetime, timedelta, timezone
from unittest.mock import MagicMock, patch
from urllib.parse import urlencode

import pytest
from fastapi.testclient import TestClient

from backend.api.models import (
    CompanyDB,
    CompanyType,
    EmailVerificationStatus,
    Gender,
    JobDB,
    Level,
    SalaryDB,
    WorkType,
)


@pytest.fixture
def mock_recaptcha():
    """Fixture to create mock reCAPTCHA response"""

    class MockAssessment:
        class TokenProperties:
            valid = True

        class RiskAnalysis:
            score = 0.9

        token_properties = TokenProperties()
        risk_analysis = RiskAnalysis()

    return MockAssessment()


@pytest.fixture
def mock_send_verification_email():
    with patch("backend.api.services.email.send_verification_email") as mock:
        mock.return_value = True
        yield mock


@pytest.fixture
def mock_background_tasks():
    with patch("fastapi.BackgroundTasks.add_task") as mock:
        yield mock


@pytest.mark.parametrize(
    "salary_data,email_body,expected_status,expected_error,expected_verification",
    [
        # Existing happy path - without email
        (
            {
                "gender": Gender.MALE.value,
                "level": Level.JUNIOR.value,
                "gross_salary": 50000,
                "work_type": WorkType.REMOTE.value,
                "net_salary": 40000,
                "technical_stacks": [{"name": "python"}, {"name": "fastapi"}],
                "added_date": "2024-10-19",
                "location": "New York",
                "jobs": [{"title": "Software Engineer"}],
                "bonus": 5000,
                "total_experience_years": 2,
                "company": {
                    "name": "Tech Corp",
                    "type": CompanyType.STARTUP.value,
                    "tags": [{"name": "tech"}],
                },
                "leave_days": 20,
                "experience_years_company": 1,
            },
            None,
            200,
            None,
            EmailVerificationStatus.NO.value,
        ),
        # New case - with email verification
        (
            {
                "gender": Gender.MALE.value,
                "level": Level.JUNIOR.value,
                "gross_salary": 50000,
                "work_type": WorkType.REMOTE.value,
                "location": "New York",
                "professional_email": "test@example.com",
            },
            {
                "subject": "Verify Your Email",
                "greeting_text": "Please verify your email",
                "verify_button_text": "Verify Email",
                "expiration_text": "Link expires in 7 days",
            },
            200,
            None,
            EmailVerificationStatus.PENDING.value,
        ),
        # Existing error cases
        (
            {
                "gender": "invalid",
                "level": Level.JUNIOR.value,
                "gross_salary": 50000,
                "work_type": WorkType.REMOTE.value,
                "net_salary": 40000,
                "location": "New York",
            },
            None,
            422,
            "input should be 'male', 'female' or 'other'",
            None,
        ),
        (
            {
                "gender": Gender.MALE.value,
                "level": Level.JUNIOR.value,
                # missing gross_salary
                "work_type": WorkType.REMOTE.value,
                "location": "New York",
            },
            None,
            422,
            "field required",
            None,
        ),
    ],
    ids=["valid_data", "valid_data_with_email", "invalid_gender", "missing_field"],
)
def test_create_salary(
    client: TestClient,
    monkeypatch,
    mock_recaptcha,
    mock_send_verification_email,
    mock_background_tasks,
    salary_data,
    email_body,
    expected_status,
    expected_error,
    expected_verification,
):
    """Test salary creation with different scenarios"""

    def mock_create_assessment(*args, **kwargs):
        return mock_recaptcha

    # Mock the necessary functions
    monkeypatch.setattr(
        "backend.api.services.auth.create_assessment",
        mock_create_assessment,
    )

    monkeypatch.setattr(
        "google.cloud.recaptchaenterprise_v1.RecaptchaEnterpriseServiceClient",
        lambda: MagicMock(create_assessment=mock_create_assessment),
    )

    # Prepare request
    query_params = {"captcha_token": "test_token", "user_agent": "test_user_agent"}
    request_body = {"salary": salary_data}
    if email_body:
        request_body["email_body"] = email_body

    # Make the request
    response = client.post(
        f"/salaries/?{urlencode(query_params)}",
        json=request_body,
        headers={"Content-Type": "application/json"},
    )

    assert response.status_code == expected_status

    if expected_status == 200:
        response_data = response.json()
        assert "id" in response_data

        # Verify basic fields
        for key in ["gender", "level", "gross_salary", "work_type", "location"]:
            if key in salary_data:
                if isinstance(salary_data[key], str):
                    assert response_data[key].lower() == salary_data[key].lower()
                else:
                    assert response_data[key] == salary_data[key]

        # Verify email verification
        if "professional_email" in salary_data:
            assert response_data["verified"] == expected_verification
            assert (
                response_data["professional_email"]
                == f"***@{salary_data['professional_email'].split('@')[1].lower()}"
            )

            # Verify background task was added
            mock_background_tasks.assert_called_once()

            # Get the arguments from the mock call
            args, kwargs = mock_background_tasks.call_args

            # First argument should be the function
            func = args[0]
            assert func.__name__ == "send_verification_email"

            # The rest of the arguments should be passed as kwargs
            assert kwargs["email"] == salary_data["professional_email"]
            assert kwargs["salary_id"] == response_data["id"]
            assert kwargs["subject"] == email_body["subject"]
            assert kwargs["greeting_text"] == email_body["greeting_text"]
            assert kwargs["verify_button_text"] == email_body["verify_button_text"]
            assert kwargs["expiration_text"] == email_body["expiration_text"]


def test_get_salaries(client, sample_salary):
    response = client.get("/salaries/")
    assert response.status_code == 200
    assert "results" in response.json()
    assert "total" in response.json()
    assert len(response.json()["results"]) > 0

    # Additional assertions to verify the added salary
    results = response.json()["results"]
    assert any(salary["id"] == sample_salary.id for salary in results)
    added_salary = next(
        salary for salary in results if salary["id"] == sample_salary.id
    )
    assert added_salary["gross_salary"] == 50000
    assert added_salary["location"] == "New York"
    assert added_salary["company"]["name"] == "Test Company"
    assert any(job["title"] == "Software Engineer" for job in added_salary["jobs"])


def test_delete_salaries(client, test_db):
    # Create test data
    test_company = CompanyDB(name="Test Company", type="startup")
    test_db.add(test_company)
    test_db.flush()

    test_job = JobDB(title="Test Job")
    test_db.add(test_job)
    test_db.flush()

    test_salary = SalaryDB(
        company_id=test_company.id,
        location="Test City",
        gross_salary=100000,
        level=Level.MID.value,
        work_type=WorkType.REMOTE.value,
    )
    test_salary.jobs.append(test_job)
    test_db.add(test_salary)
    test_db.commit()

    salary_id = test_salary.id

    # Verify that the salary was added
    test_db.refresh(test_salary)
    added_salary = test_db.query(SalaryDB).filter(SalaryDB.id == salary_id).first()
    assert (
        added_salary is not None
    ), f"Salary with id {salary_id} was not added to the database"

    print(f"Added salary with ID: {salary_id}")

    # Now test the delete operation
    delete_response = client.delete(f"/salaries/?salary_ids={salary_id}")

    # Check if the deletion was successful
    assert (
        delete_response.status_code == 200
    ), f"Failed to delete salary: {delete_response.content}"

    # Verify that the salary has been deleted from the database
    test_db.expire_all()
    deleted_salary = test_db.query(SalaryDB).filter(SalaryDB.id == salary_id).first()
    assert deleted_salary is None, f"Salary still exists in the database after deletion"

    print("Delete salary test passed successfully")


def test_get_salary_stats(client):
    response = client.get("/salaries/stats/")
    assert response.status_code == 200
    assert "avg_salary_by_city" in response.json()
    assert "top_10_cities" in response.json()


def test_get_choices(client):
    response = client.get("/choices/")
    assert response.status_code == 200
    assert "company_names" in response.json()
    assert "company_types" in response.json()
    assert "job_titles" in response.json()
    assert "locations" in response.json()
    assert "levels" in response.json()
    assert "work_types" in response.json()
    assert "technical_stacks" in response.json()


def test_create_and_get_technical_stack(client):
    create_response = client.post("/technical-stacks/", json={"name": "Python"})
    assert create_response.status_code == 200
    assert create_response.json()["name"] == "Python"

    get_response = client.get("/technical-stacks/")
    assert get_response.status_code == 200
    assert any(stack["name"] == "Python" for stack in get_response.json())


def test_create_and_get_job(client):
    create_response = client.post("/jobs/", json={"title": "Data Scientist"})
    assert create_response.status_code == 200
    assert create_response.json()["title"] == "data scientist"

    get_response = client.get("/jobs/")
    assert get_response.status_code == 200
    assert any(
        job["title"] == "data scientist" for job in get_response.json()["results"]
    )


def test_create_and_get_company(client, test_db):
    unique_name = f"New Company {uuid.uuid4()}"
    create_data = {
        "name": unique_name,
        "type": CompanyType.STARTUP.value,
        "tags": [{"name": "tech"}, {"name": "AI"}],
    }
    create_response = client.post("/companies/", json=create_data)
    assert (
        create_response.status_code == 200
    ), f"Failed to create company: {create_response.content}"

    created_company = create_response.json()
    assert created_company["name"] == unique_name
    assert created_company["type"] == CompanyType.STARTUP.value
    assert len(created_company["tags"]) == 2

    # Test getting the created company
    get_response = client.get(f"/companies/")
    assert get_response.status_code == 200

    retrieved_company = get_response.json()["results"][0]
    assert retrieved_company["id"] == created_company["id"]
    assert retrieved_company["name"] == created_company["name"]
    assert retrieved_company["type"] == created_company["type"]
    assert len(retrieved_company["tags"]) == len(created_company["tags"])


def test_delete_companies(client, test_db):
    # Create a test company
    company = CompanyDB(name="Test Company to Delete", type="startup")
    test_db.add(company)
    test_db.commit()

    # Delete the company
    response = client.delete(f"/companies/?company_ids={company.id}")
    assert response.status_code == 200
    assert "deleted successfully" in response.json()["message"]

    # Verify the company is deleted
    deleted_company = (
        test_db.query(CompanyDB).filter(CompanyDB.id == company.id).first()
    )
    assert deleted_company is None


def test_check_endpoints(client):
    endpoints = [
        ("/companies/check-name/", {"name": "Test Company"}),
        ("/companies/check-tag/", {"name": "tech"}),
        ("/jobs/check-title/", {"title": "Software Engineer"}),
        ("/salaries/check-location/", {"name": "Test City"}),
        ("/technical-stacks/check-name/", {"name": "Python"}),
    ]

    for endpoint, params in endpoints:
        response = client.get(endpoint, params=params)
        assert response.status_code == 200
        assert "exists" in response.json()


def test_get_salaries_pagination_and_sorting(client):
    # Test pagination
    response = client.get("/salaries/?skip=0&limit=10")
    assert response.status_code == 200
    assert len(response.json()["results"]) <= 10

    # Test sorting
    response = client.get("/salaries/?sort_by=gross_salary&sort_order=desc")
    assert response.status_code == 200
    salaries = response.json()["results"]
    assert all(
        salaries[i]["gross_salary"] >= salaries[i + 1]["gross_salary"]
        for i in range(len(salaries) - 1)
    )


def test_get_salaries_filtering(client):
    # Test filtering by company name
    response = client.get("/salaries/?company_names=Tech%20Corp")
    assert response.status_code == 200
    assert all(
        salary["company"]["name"] == "Tech Corp"
        for salary in response.json()["results"]
    )

    # Test filtering by job title
    response = client.get("/salaries/?job_titles=Software%20Engineer")
    assert response.status_code == 200
    assert all(
        any(job["title"] == "software engineer" for job in salary["jobs"])
        for salary in response.json()["results"]
    )

    # Test filtering by salary range
    response = client.get("/salaries/?gross_salary_min=50000&gross_salary_max=100000")
    assert response.status_code == 200
    assert all(
        50000 <= salary["gross_salary"] <= 100000
        for salary in response.json()["results"]
    )


def test_error_handling(client):
    # Test invalid salary data
    invalid_salary_data = {
        "gender": "invalid",
        "level": "invalid",
        "gross_salary": "not a number",
        "work_type": "invalid",
    }
    response = client.post(
        "/salaries/", data={"salary": json.dumps(invalid_salary_data)}
    )
    assert response.status_code == 422

    # Test invalid company data
    invalid_company_data = {
        "name": "",
        "type": "invalid",
    }
    response = client.post("/companies/", json=invalid_company_data)
    assert response.status_code == 422

    # Test deleting non-existent salary
    response = client.delete("/salaries/?salary_ids=99999")
    assert response.status_code == 404

    # Test deleting non-existent company
    response = client.delete("/companies/?company_ids=99999")
    assert response.status_code == 404


def test_get_location_stats(client, test_db):
    # Create some test data
    locations = ["New York", "San Francisco", "London", "Berlin", "Tokyo"]
    for i, location in enumerate(locations):
        for _ in range(i + 1):  # Create i+1 salaries for each location
            salary = SalaryDB(
                location=location,
                gross_salary=50000,
                net_salary=40000,
                gender="male",
                level=Level.JUNIOR.value,
                work_type=WorkType.REMOTE.value,
            )
            test_db.add(salary)
    test_db.commit()

    response = client.get("/salaries/location-stats/")
    assert response.status_code == 200
    data = response.json()

    assert "chart_data" in data
    chart_data = data["chart_data"]

    # Check if the data is sorted correctly
    assert len(chart_data) <= 11  # 10 top locations + possibly "Others"
    if len(chart_data) == 11:
        assert chart_data[-1]["name"] == "Others"

    # Check if percentages sum up to approximately 100%
    total_percentage = sum(item["percentage"] for item in chart_data)
    assert 99.9 <= total_percentage <= 100.1

    # Check if the order is correct (descending by value)
    values = [item["value"] for item in chart_data]
    assert values == sorted(values, reverse=True)


def test_get_top_locations_by_salary(client, test_db):
    # Create some test data
    locations = ["New York", "San Francisco", "London", "Berlin", "Tokyo"]
    salaries = [80000, 90000, 70000, 75000, 85000]
    for location, avg_salary in zip(locations, salaries):
        for _ in range(5):  # Create 5 salaries for each location
            salary = SalaryDB(
                location=location,
                gross_salary=avg_salary
                + random.randint(-5000, 5000),  # Add some variation
                net_salary=avg_salary * 0.8,
                gender="male",
                level="junior",
                work_type="remote",
            )
            test_db.add(salary)
    test_db.commit()

    response = client.get("/salaries/top-locations-by-salary/")
    assert response.status_code == 200
    data = response.json()

    assert isinstance(data, list)
    assert len(data) <= 10  # Should return at most 10 locations
    assert all(isinstance(item, dict) for item in data)
    assert all(
        {"name", "average_salary", "count"}.issubset(item.keys()) for item in data
    )

    # Check if the order is correct (descending by average_salary)
    avg_salaries = [item["average_salary"] for item in data]
    assert avg_salaries == sorted(avg_salaries, reverse=True)

    # Check if all returned locations have at least 5 entries
    assert all(item["count"] >= 5 for item in data)

    # Verify the top location
    top_location = data[0]
    assert top_location["name"] == "San Francisco"
    assert 85000 <= top_location["average_salary"] <= 95000
