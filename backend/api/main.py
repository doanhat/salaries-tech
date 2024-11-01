from typing import Annotated

from fastapi import Depends, FastAPI, Security
from fastapi.middleware.cors import CORSMiddleware
from fastapi.openapi.utils import get_openapi
from fastapi.security import APIKeyHeader

from .config.env import ALLOWED_ORIGINS
from .routes import commons, companies, jobs, root, salaries, technical_stacks
from .services.auth import verify_api_key

# Define the API key header scheme for Swagger UI
api_key_scheme = APIKeyHeader(name="X-API-Key", auto_error=True)

app = FastAPI(
    title="Salary Information API",
    description="API for salary information management",
    version="1.0.0",
    swagger_ui_parameters={"persistAuthorization": True},
)


def get_openapi_schema():
    if app.openapi_schema:
        return app.openapi_schema

    openapi_schema = get_openapi(
        title=app.title,
        version=app.version,
        description=app.description,
        routes=app.routes,
        tags=[
            {"name": "commons", "description": "Common operations"},
            {"name": "salaries", "description": "Salary operations"},
            {"name": "companies", "description": "Company operations"},
            {"name": "jobs", "description": "Job operations"},
            {"name": "technical-stacks", "description": "Technical stack operations"},
        ],
    )

    # Add OpenAPI version
    openapi_schema["openapi"] = "3.0.2"

    # Add security scheme
    openapi_schema.setdefault("components", {})["securitySchemes"] = {
        "ApiKeyAuth": {"type": "apiKey", "in": "header", "name": "X-API-Key"}
    }
    openapi_schema["security"] = [{"ApiKeyAuth": []}]

    app.openapi_schema = openapi_schema
    return app.openapi_schema


# Set the custom OpenAPI schema
app.__setattr__("openapi", get_openapi_schema)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Type for dependencies
APIKey = Annotated[str, Security(api_key_scheme)]

# Include routers with API key dependency
app.include_router(root.router)
app.include_router(commons.router, dependencies=[Depends(verify_api_key)])
app.include_router(salaries.router, dependencies=[Depends(verify_api_key)])
app.include_router(companies.router, dependencies=[Depends(verify_api_key)])
app.include_router(jobs.router, dependencies=[Depends(verify_api_key)])
app.include_router(technical_stacks.router, dependencies=[Depends(verify_api_key)])
