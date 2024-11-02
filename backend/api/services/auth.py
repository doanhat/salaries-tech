from fastapi import HTTPException, Request

from ..config.env import API_KEY_SECRET_NAME, ENV, PROJECT_ID
from ..tools.gcp.secrets import get_secret


async def verify_api_key(request: Request) -> None:
    api_key = request.headers.get("X-API-Key")
    if not api_key:
        raise HTTPException(status_code=401, detail="API key is required")

    # Get the expected API key from Secret Manager
    project_id = PROJECT_ID
    api_key_secret_name = API_KEY_SECRET_NAME
    expected_api_key = (
        get_secret(project_id, api_key_secret_name)
        if ENV == "prod"
        else api_key_secret_name
    )

    if api_key != expected_api_key:
        raise HTTPException(status_code=401, detail="Invalid API key")
