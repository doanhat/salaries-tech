import os
from pathlib import Path

from dotenv import load_dotenv

# Get the absolute path to the backend directory
BACKEND_DIR = Path(__file__).resolve().parent.parent
ENV_PATH = BACKEND_DIR / ".env"
# Load environment variables
load_dotenv(ENV_PATH)

ENV = os.getenv("ENV", "dev")
ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "http://localhost:3000").split(",")
SQLALCHEMY_DATABASE_URL = os.getenv(
    "SQLALCHEMY_DATABASE_URL", "sqlite:///././salaries.db"
)
API_KEY_SECRET_NAME = os.getenv("API_KEY_SECRET_NAME")
PROJECT_ID = os.getenv("PROJECT_ID")
RECAPTCHA_KEY = os.getenv("RECAPTCHA_KEY")
SENDGRID_FROM_EMAIL = os.getenv("SENDGRID_FROM_EMAIL")
SENDGRID_API_KEY = os.getenv("SENDGRID_API_KEY")
EMAIL_VERIFICATION_SECRET_NAME = os.getenv("EMAIL_VERIFICATION_SECRET_NAME")
WELL_KNOWN_DOMAINS = {
    "amazon": ["amazon.com", "aws.com", "amazonwebservices.com"],
    "aws": ["aws.com", "amazonwebservices.com"],
    "google": ["google.com", "alphabet.com"],
    "microsoft": ["microsoft.com", "msft.com", "azure.com"],
    "msft": ["microsoft.com", "msft.com", "azure.com"],
    "azure": ["azure.com"],
    "meta": ["meta.com", "facebook.com", "fb.com", "instagram.com"],
    "facebook": ["facebook.com"],
    "instagram": ["instagram.com"],
    "apple": ["apple.com", "icloud.com"],
    "netflix": ["netflix.com"],
    "salesforce": ["salesforce.com"],
    "oracle": ["oracle.com"],
    "ibm": ["ibm.com"],
    "intel": ["intel.com"],
    "adobe": ["adobe.com"],
    "twitter": ["twitter.com", "x.com"],
    "x": ["x.com"],
    "linkedin": ["linkedin.com"],
    "uber": ["uber.com"],
    "airbnb": ["airbnb.com"],
}
COMMON_DOMAINS = [
    "gmail.com",
    "yahoo.com",
    "hotmail.com",
    "outlook.com",
    "aol.com",
    "protonmail.com",
    "icloud.com",
    "mail.com",
    "live.com",
    "me.com",
    "msn.com",
]
