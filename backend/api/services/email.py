from datetime import datetime, timedelta, timezone
from difflib import SequenceMatcher

from jose import jwt
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Email, Header, Mail

from ..config.env import (
    ALLOWED_ORIGINS,
    COMMON_DOMAINS,
    EMAIL_VERIFICATION_SECRET_NAME,
    ENV,
    PROJECT_ID,
    SENDGRID_API_KEY,
    SENDGRID_FROM_EMAIL,
    WELL_KNOWN_DOMAINS,
)
from ..config.logger import logger
from ..tools.gcp.secrets import get_secret


def get_email_hash_key() -> str | None:
    if ENV == "prod":
        return get_secret(PROJECT_ID, EMAIL_VERIFICATION_SECRET_NAME)
    return EMAIL_VERIFICATION_SECRET_NAME


async def send_verification_email(
    email: str,
    salary_id: int,
    subject: str,
    greeting_text: str,
    verify_button_text: str,
    expiration_text: str,
) -> bool:
    """Send verification email using SendGrid."""
    try:
        # Validate SendGrid configuration
        if not SENDGRID_API_KEY:
            raise ValueError("SendGrid API key is not configured")
        if not SENDGRID_FROM_EMAIL:
            raise ValueError("SendGrid sender email is not configured")

        # Create verification token
        hash_key = get_email_hash_key()
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

        # Create email message with explicit From name and email
        from_email = Email(
            email=SENDGRID_FROM_EMAIL,
            name="Salaries Tech",
        )

        message = Mail(
            from_email=from_email,
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

        # Add custom headers correctly
        message.header = Header(key="X-Priority", value="1")
        message.header = Header(key="X-MSMail-Priority", value="High")
        message.header = Header(key="Importance", value="High")

        # Send email
        sg = SendGridAPIClient(SENDGRID_API_KEY)
        response = sg.send(message)

        if response.status_code != 202:
            raise ValueError(
                f"SendGrid API returned status code {response.status_code}"
            )

        return True

    except Exception as e:
        if ENV == "dev" and "401" in str(e):
            logger.warning(f"Warning sending verification email: {str(e)}")
        else:
            logger.error(f"Error sending verification email: {str(e)}")
        if isinstance(e, ValueError):
            # Re-raise configuration errors
            raise
        return False


def check_domain_company_match(
    email: str, company_name: str | None, threshold: float = 0.9
) -> dict:
    domain = email.split("@")[1].lower()
    if domain in COMMON_DOMAINS:
        return {
            "is_valid": False,
            "similarity": 0.0,
            "message": "Please use a professional email address",
            "code": "invalid_common_domain",
        }
    if not company_name:
        return {
            "is_valid": False,
            "similarity": 0.0,
            "message": "Company name is required for domain check",
            "code": "invalid_company_name_required",
        }
    # Check for known company domains first
    company_name_clean = company_name.lower().strip()
    for known_company, valid_domains in WELL_KNOWN_DOMAINS.items():
        if known_company in company_name_clean or any(
            kc in company_name_clean for kc in known_company.split()
        ):
            if domain in valid_domains:
                return {
                    "is_valid": True,
                    "similarity": 1.0,
                    "message": "Valid company email for known company",
                    "code": "valid_company_email",
                }

    # If not a known company, do similarity check
    email_domain_parts = domain.split(".")
    email_domain_base = email_domain_parts[0]

    # Clean company name for comparison
    company_words = "".join(e for e in company_name_clean if e.isalnum()).lower()
    email_domain_clean = "".join(e for e in email_domain_base if e.isalnum()).lower()

    # Calculate similarity ratio
    similarity = SequenceMatcher(None, company_words, email_domain_clean).ratio()
    is_valid = similarity >= threshold
    return {
        "is_valid": is_valid,
        "similarity": similarity,
        "message": "Valid company email from similarity check"
        if is_valid
        else "Invalid company email from similarity check",
        "code": "valid_company_email_similarity"
        if is_valid
        else "invalid_company_email_similarity",
    }
