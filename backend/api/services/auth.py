import os
from typing import Optional

import google.cloud.recaptchaenterprise_v1 as recaptcha_v1
from fastapi import HTTPException, Request

from ..config.secrets import get_secret


def create_assessment(
    project_id: str,
    recaptcha_site_key: str,
    token: str,
    user_ip_address: Optional[str],
    user_agent: Optional[str],
) -> recaptcha_v1.Assessment:
    """Create an assessment to analyze the risk of a UI action."""
    client = recaptcha_v1.RecaptchaEnterpriseServiceClient()

    event = recaptcha_v1.Event()
    event.site_key = recaptcha_site_key
    event.token = token
    if user_ip_address:
        event.user_ip_address = user_ip_address
    if user_agent:
        event.user_agent = user_agent

    assessment = recaptcha_v1.Assessment()
    assessment.event = event

    project_name = f"projects/{project_id}"

    request = recaptcha_v1.CreateAssessmentRequest()
    request.assessment = assessment
    request.parent = project_name

    response = client.create_assessment(request)

    return response


async def verify_api_key(request: Request):
    if os.getenv("ENV", "dev") == "prod":
        api_key = request.headers.get("X-API-Key")
        if not api_key:
            raise HTTPException(status_code=401, detail="API key is required")

        # Get the expected API key from Secret Manager
        project_id = os.getenv("PROJECT_ID")
        api_key_secret_name = os.getenv("API_KEY_SECRET_NAME")
        expected_api_key = get_secret(project_id, api_key_secret_name)

        if api_key != expected_api_key:
            raise HTTPException(status_code=401, detail="Invalid API key")
