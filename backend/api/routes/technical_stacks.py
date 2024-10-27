from typing import Dict, List

from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session

from ..database import get_db_session
from ..models import TechnicalStack, TechnicalStackDB

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


@router.get("/", response_model=List[TechnicalStack])
async def get_technical_stacks(
    db: Session = Depends(get_db_session),
) -> List[TechnicalStack]:
    stacks = db.query(TechnicalStackDB).all()
    return [
        TechnicalStack(
            **{t.name: getattr(stack, t.name) for t in stack.__table__.columns}
        )
        for stack in stacks
    ]


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
