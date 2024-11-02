import random
from unittest.mock import MagicMock
from urllib.parse import urlencode

import pytest
from fastapi.testclient import TestClient

from backend.api.models import (
    CompanyType,
    EmailVerificationStatus,
    Gender,
    Level,
    WorkType,
)
from backend.api.models.salary import SalaryDB


@pytest.mark.parametrize(
    "salary_data,email_body,expected_status,expected_verification",
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
            EmailVerificationStatus.PENDING.value,
        ),
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
            None,
        ),
    ],
    ids=["valid_data", "valid_data_with_email", "invalid_gender", "missing_field"],
)
def test_create_salary(
    client: TestClient,
    monkeypatch,
    mock_recaptcha,
    mock_background_tasks,
    salary_data,
    email_body,
    expected_status,
    expected_verification,
):
    """Test salary creation with different scenarios"""

    def mock_create_assessment(*args, **kwargs):
        return mock_recaptcha

    # Mock the necessary functions
    monkeypatch.setattr(
        "backend.api.tools.gcp.recaptcha.create_assessment",
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
            assert response_data["verification"] == expected_verification
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


def test_get_salaries(client, sample_data):
    response = client.get("/salaries/")
    assert response.status_code == 200
    assert "results" in response.json()
    assert "total" in response.json()
    assert len(response.json()["results"]) > 0

    # Additional assertions to verify the added salary
    results = response.json()["results"]
    assert any(salary["id"] == sample_data["salary"].id for salary in results)
    added_salary = next(
        salary for salary in results if salary["id"] == sample_data["salary"].id
    )
    assert added_salary["gross_salary"] == 50000
    assert added_salary["location"] == "New York"
    assert added_salary["company"]["name"] == "Test Company"
    assert any(job["title"] == "Software Engineer" for job in added_salary["jobs"])


def test_delete_salaries(client, sample_data, test_db):
    salary_id = sample_data["salary"].id

    # Now test the delete operation
    delete_response = client.delete(
        f"/salaries/?salary_ids={salary_id}",
    )

    # Check if the deletion was successful
    assert delete_response.status_code == 200

    # Verify that the salary has been deleted from the database
    test_db.expire_all()
    deleted_salary = test_db.query(SalaryDB).filter(SalaryDB.id == salary_id).first()
    assert deleted_salary is None


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
                gross_salary=avg_salary + random.randint(-5000, 5000),
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
