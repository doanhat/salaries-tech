from typing import Dict, List

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func
from sqlalchemy.orm import Session

from ..database import get_db_session
from ..models.technical_stack import TechnicalStack, TechnicalStackDB

router = APIRouter(prefix="/technical-stacks", tags=["technical-stacks"])


@router.post("/", response_model=TechnicalStack)
async def create_technical_stack(
    stack: TechnicalStack, db: Session = Depends(get_db_session)
) -> TechnicalStack:
    db_stack = TechnicalStackDB(name=stack.name)
    db.add(db_stack)
    db.commit()
    db.refresh(db_stack)
    return TechnicalStack(
        **{t.name: getattr(db_stack, t.name) for t in db_stack.__table__.columns}
    )


@router.get("/", response_model=Dict[str, List[TechnicalStack] | int])
async def get_technical_stacks(
    db: Session = Depends(get_db_session),
) -> Dict[str, List[TechnicalStack] | int]:
    stacks = db.query(TechnicalStackDB).all()
    return {
        "results": [
            TechnicalStack(
                **{t.name: getattr(stack, t.name) for t in stack.__table__.columns}
            )
            for stack in stacks
        ],
        "total": len(stacks),
    }


@router.delete("/", response_model=None)
async def delete_technical_stacks(
    stack_ids: List[int] = Query(...), db: Session = Depends(get_db_session)
) -> Dict[str, str]:
    stacks = db.query(TechnicalStackDB).filter(TechnicalStackDB.id.in_(stack_ids)).all()

    # Check if any stacks were not found
    found_ids = {int(stack.id) for stack in stacks}  # Explicitly convert to int
    not_found_ids = set(stack_ids) - found_ids

    if not_found_ids:
        raise HTTPException(
            status_code=404,
            detail=f"Technical stacks with IDs {not_found_ids} not found",
        )

    for stack in stacks:
        db.delete(stack)
    db.commit()
    return {
        "message": f"Technical stacks with IDs {stack_ids} have been deleted successfully"
    }


@router.get("/check-name/")
async def check_technical_stack(
    name: str, db: Session = Depends(get_db_session)
) -> Dict[str, bool]:
    stack = (
        db.query(TechnicalStackDB)
        .filter(func.lower(TechnicalStackDB.name) == name.lower().strip())
        .first()
    )
    return {"exists": stack is not None}
