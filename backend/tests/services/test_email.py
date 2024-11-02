from datetime import datetime, timezone
from unittest.mock import MagicMock, patch

import pytest
from jose import jwt

from backend.api.config.env import EMAIL_VERIFICATION_SECRET_NAME, SENDGRID_FROM_EMAIL
from backend.api.services.email import get_email_hash_key, send_verification_email


@pytest.fixture
def mock_sendgrid():
    with patch("backend.api.services.email.SendGridAPIClient") as mock:
        mock_client = MagicMock()
        mock_client.send.return_value.status_code = 202
        mock.return_value = mock_client
        yield mock


@pytest.fixture
def email_params():
    return {
        "email": "test@example.com",
        "salary_id": 123,
        "subject": "Test Subject",
        "greeting_text": "Hello",
        "verify_button_text": "Verify",
        "expiration_text": "Expires in 7 days",
    }


@pytest.mark.asyncio
async def test_send_verification_email_success(mock_sendgrid, email_params):
    result = await send_verification_email(**email_params)

    assert result is True
    mock_sendgrid.return_value.send.assert_called_once()

    # Verify the email content
    call_args = mock_sendgrid.return_value.send.call_args[0][0]
    assert call_args.from_email.email == SENDGRID_FROM_EMAIL
    assert call_args.personalizations[0].tos[0]["email"] == email_params["email"]
    assert str(call_args.subject.subject) == email_params["subject"]
    html_content = call_args._contents[0].content
    assert email_params["greeting_text"] in html_content
    assert email_params["verify_button_text"] in html_content
    assert email_params["expiration_text"] in html_content


@pytest.mark.asyncio
async def test_send_verification_email_sendgrid_error(mock_sendgrid, email_params):
    # Make SendGrid return an error status code
    mock_sendgrid.return_value.send.return_value.status_code = 400

    with patch(
        "backend.api.services.email.ENV", "prod"
    ):  # Set to prod to avoid warning log
        result = await send_verification_email(**email_params)
        assert result is False


@pytest.mark.asyncio
async def test_send_verification_email_missing_config(email_params):
    # Test with missing SendGrid API key
    with patch("backend.api.services.email.SENDGRID_API_KEY", None):
        with pytest.raises(ValueError, match="SendGrid API key is not configured"):
            await send_verification_email(**email_params)

    # Test with missing sender email
    with patch("backend.api.services.email.SENDGRID_FROM_EMAIL", None):
        with pytest.raises(ValueError, match="SendGrid sender email is not configured"):
            await send_verification_email(**email_params)

    # Test with missing frontend URL
    with patch("backend.api.services.email.ALLOWED_ORIGINS", []):
        with pytest.raises(ValueError, match="Frontend URL is not configured"):
            await send_verification_email(**email_params)


@pytest.mark.asyncio
async def test_send_verification_email_token_generation(mock_sendgrid, email_params):
    await send_verification_email(**email_params)

    # Extract the token from the verification URL in the email content
    call_args = mock_sendgrid.return_value.send.call_args[0][0]
    html_content = call_args._contents[0].content
    token_start = html_content.find("token=") + 6
    token_end = html_content.find('"', token_start)
    token = html_content[token_start:token_end]

    # Verify the token
    hash_key = get_email_hash_key()
    payload = jwt.decode(token, hash_key, algorithms=["HS256"])

    assert payload["salary_id"] == email_params["salary_id"]
    assert payload["email"] == email_params["email"]
    assert "exp" in payload


def test_get_email_hash_key_test_env():
    # Test environment should return the secret name directly
    assert get_email_hash_key() == EMAIL_VERIFICATION_SECRET_NAME


@pytest.mark.asyncio
async def test_send_verification_email_with_exception(mock_sendgrid, email_params):
    # Simulate an exception in SendGrid client
    mock_sendgrid.return_value.send.side_effect = Exception("SendGrid error")

    result = await send_verification_email(**email_params)
    assert result is False


@pytest.mark.asyncio
async def test_send_verification_email_headers(mock_sendgrid, email_params):
    await send_verification_email(**email_params)

    # Verify email headers
    call_args = mock_sendgrid.return_value.send.call_args[0][0]
    headers = call_args._headers

    expected_headers = {
        "X-Priority": "1",
        "X-MSMail-Priority": "High",
        "Importance": "High",
    }

    for header in headers:
        # Access header properties directly
        assert header.key in expected_headers
        assert header.value == expected_headers[header.key]


@pytest.mark.asyncio
async def test_send_verification_email_html_content(mock_sendgrid, email_params):
    await send_verification_email(**email_params)

    call_args = mock_sendgrid.return_value.send.call_args[0][0]
    html_content = call_args._contents[0].content

    # Verify HTML structure and styling
    assert '<div style="font-family: Arial, sans-serif;' in html_content
    assert '<a href="' in html_content
    assert 'style="background-color: #4CAF50;' in html_content
    assert email_params["greeting_text"] in html_content
    assert email_params["verify_button_text"] in html_content
    assert email_params["expiration_text"] in html_content
