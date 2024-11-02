from typing import Optional

import google.cloud.recaptchaenterprise_v1 as recaptcha_v1

from ..config.env import PROJECT_ID, RECAPTCHA_KEY
from ..tools.gcp.recaptcha import create_assessment


def verify_recaptcha(
    token: str, user_ip: Optional[str], user_agent: Optional[str]
) -> recaptcha_v1.Assessment:
    """Verify reCAPTCHA token."""
    if not PROJECT_ID or not RECAPTCHA_KEY:
        raise ValueError(
            "reCAPTCHA configuration error : PROJECT_ID or RECAPTCHA_KEY is not set"
        )
    return create_assessment(PROJECT_ID, RECAPTCHA_KEY, token, user_ip, user_agent)
