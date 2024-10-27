from typing import Optional

import google.cloud.recaptchaenterprise_v1 as recaptcha_v1


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
