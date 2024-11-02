from unittest.mock import MagicMock, patch

import pytest
from google.cloud.recaptchaenterprise_v1 import Assessment, Event

from backend.api.services.recaptcha import verify_recaptcha
from backend.api.tools.gcp.recaptcha import create_assessment


@pytest.fixture
def mock_recaptcha_client():
    with patch(
        "google.cloud.recaptchaenterprise_v1.RecaptchaEnterpriseServiceClient"
    ) as mock:
        mock_client = MagicMock()

        # Create a mock assessment response
        mock_response = MagicMock()
        mock_response.token_properties.valid = True
        mock_response.risk_analysis.score = 0.9

        mock_client.create_assessment.return_value = mock_response
        mock.return_value = mock_client
        yield mock


@pytest.fixture
def recaptcha_params():
    return {
        "token": "test_token",
        "user_ip": "127.0.0.1",
        "user_agent": "test_user_agent",
    }


def test_verify_recaptcha_success(mock_recaptcha_client, recaptcha_params):
    with patch("backend.api.services.recaptcha.PROJECT_ID", "test-project"), patch(
        "backend.api.services.recaptcha.RECAPTCHA_KEY", "test-key"
    ):
        response = verify_recaptcha(**recaptcha_params)

        assert response.token_properties.valid
        assert abs(response.risk_analysis.score - 0.9) < 0.0001

        # Verify the client was called with correct parameters
        create_assessment_call = (
            mock_recaptcha_client.return_value.create_assessment.call_args[0][0]
        )
        assert create_assessment_call.parent == "projects/test-project"
        assert (
            create_assessment_call.assessment.event.token == recaptcha_params["token"]
        )
        assert (
            create_assessment_call.assessment.event.user_ip_address
            == recaptcha_params["user_ip"]
        )
        assert (
            create_assessment_call.assessment.event.user_agent
            == recaptcha_params["user_agent"]
        )


def test_verify_recaptcha_missing_config():
    with patch("backend.api.services.recaptcha.PROJECT_ID", None), patch(
        "backend.api.services.recaptcha.RECAPTCHA_KEY", "test-key"
    ):
        with pytest.raises(ValueError, match="reCAPTCHA configuration error"):
            verify_recaptcha("test_token", "127.0.0.1", "test_user_agent")

    with patch("backend.api.services.recaptcha.PROJECT_ID", "test-project"), patch(
        "backend.api.services.recaptcha.RECAPTCHA_KEY", None
    ):
        with pytest.raises(ValueError, match="reCAPTCHA configuration error"):
            verify_recaptcha("test_token", "127.0.0.1", "test_user_agent")


def test_create_assessment_with_optional_params(mock_recaptcha_client):
    # Test with all parameters
    response = create_assessment(
        project_id="test-project",
        recaptcha_site_key="test-key",
        token="test_token",
        user_ip_address="127.0.0.1",
        user_agent="test_user_agent",
    )

    create_assessment_call = (
        mock_recaptcha_client.return_value.create_assessment.call_args[0][0]
    )
    event = create_assessment_call.assessment.event
    assert event.user_ip_address == "127.0.0.1"
    assert event.user_agent == "test_user_agent"


def test_create_assessment_without_optional_params(mock_recaptcha_client):
    # Test without optional parameters
    response = create_assessment(
        project_id="test-project",
        recaptcha_site_key="test-key",
        token="test_token",
        user_ip_address=None,
        user_agent=None,
    )

    create_assessment_call = (
        mock_recaptcha_client.return_value.create_assessment.call_args[0][0]
    )
    event = create_assessment_call.assessment.event
    # Check if the values are empty or None
    assert getattr(event, "user_ip_address", "") in (None, "")
    assert getattr(event, "user_agent", "") in (None, "")


@pytest.mark.parametrize(
    "user_ip,user_agent",
    [
        ("192.168.1.1", None),
        (None, "Mozilla/5.0"),
        (None, None),
    ],
)
def test_create_assessment_parameter_combinations(
    mock_recaptcha_client, user_ip, user_agent
):
    response = create_assessment(
        project_id="test-project",
        recaptcha_site_key="test-key",
        token="test_token",
        user_ip_address=user_ip,
        user_agent=user_agent,
    )

    create_assessment_call = (
        mock_recaptcha_client.return_value.create_assessment.call_args[0][0]
    )
    event = create_assessment_call.assessment.event

    if user_ip:
        assert event.user_ip_address == user_ip
    else:
        assert getattr(event, "user_ip_address", "") in (None, "")

    if user_agent:
        assert event.user_agent == user_agent
    else:
        assert getattr(event, "user_agent", "") in (None, "")
