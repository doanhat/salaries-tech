from typing import Dict

from fastapi import APIRouter, Response

router = APIRouter(tags=["root"])


@router.get("/", include_in_schema=False)
async def read_root() -> Dict[str, str]:
    return {"message": "Salary Information API"}


@router.get("/favicon.ico", include_in_schema=False)
async def favicon() -> Response:
    return Response(status_code=204)
