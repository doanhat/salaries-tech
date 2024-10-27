from fastapi import APIRouter, Response

router = APIRouter(tags=["root"])


@router.get("/", include_in_schema=False)
async def read_root():
    return {"message": "Salary Information API"}


@router.get("/favicon.ico", include_in_schema=False)
async def favicon():
    return Response(status_code=204)
