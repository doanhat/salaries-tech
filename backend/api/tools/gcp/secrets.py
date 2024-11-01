from typing import Optional

from google.cloud import secretmanager


def get_secret(
    project_id: Optional[str], secret_id: Optional[str], version_id: str = "latest"
) -> str:
    """Retrieve a secret from Google Secret Manager."""
    if not project_id or not secret_id:
        raise ValueError("project_id and secret_id must be provided")

    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{project_id}/secrets/{secret_id}/versions/{version_id}"
    response = client.access_secret_version(request={"name": name})
    return response.payload.data.decode("UTF-8")
