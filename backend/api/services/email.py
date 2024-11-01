from datetime import datetime, timedelta, timezone

from jose import jwt
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail

from ..config.env import (
    ALLOWED_ORIGINS,
    EMAIL_VERIFICATION_SECRET_NAME,
    ENV,
    SENDGRID_API_KEY,
    SENDGRID_FROM_EMAIL,
)
from .auth import get_hash_key


async def send_verification_email(
    email: str,
    salary_id: int,
    subject: str,
    greeting_text: str,
    verify_button_text: str,
    expiration_text: str,
):
    """Send verification email using SendGrid."""
    try:
        # Validate SendGrid configuration
        if not SENDGRID_API_KEY:
            raise ValueError("SendGrid API key is not configured")
        if not SENDGRID_FROM_EMAIL:
            raise ValueError("SendGrid sender email is not configured")

        # Create verification token
        hash_key = get_hash_key(EMAIL_VERIFICATION_SECRET_NAME)
        if not hash_key:
            raise ValueError("Email verification secret is not configured")

        token = jwt.encode(
            {
                "salary_id": salary_id,
                "email": email,
                "exp": datetime.now(timezone.utc) + timedelta(days=7),
            },
            hash_key,
            algorithm="HS256",
        )

        # Ensure we have a valid frontend URL
        if not ALLOWED_ORIGINS or not ALLOWED_ORIGINS[0]:
            raise ValueError("Frontend URL is not configured")

        verification_url = f"{ALLOWED_ORIGINS[0]}/salaries/verify-email?token={token}"

        # Create email message
        message = Mail(
            from_email=SENDGRID_FROM_EMAIL,
            to_emails=email,
            subject=subject,
            html_content=f"""
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                    <p style="font-size: 16px; color: #333;">{greeting_text}</p>
                    <p style="margin: 20px 0;">
                        <a href="{verification_url}" 
                           style="background-color: #4CAF50; 
                                  color: white; 
                                  padding: 10px 20px; 
                                  text-decoration: none; 
                                  border-radius: 5px;">
                            {verify_button_text}
                        </a>
                    </p>
                    <p style="font-size: 14px; color: #666;">{expiration_text}</p>
                </div>
            """,
        )

        # Send email
        sg = SendGridAPIClient(SENDGRID_API_KEY)
        response = sg.send(message)

        if response.status_code != 202:
            raise ValueError(
                f"SendGrid API returned status code {response.status_code}"
            )

        return True

    except Exception as e:
        from ..config.logger import logger

        if ENV == "dev" and "401" in str(e):
            logger.warning(f"Warning sending verification email: {str(e)}")
        else:
            logger.error(f"Error sending verification email: {str(e)}")
        if isinstance(e, ValueError):
            # Re-raise configuration errors
            raise
        return False
