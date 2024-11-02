from typing import Dict, List

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import delete, func
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from ..database import get_db_session
from ..models import company_tag
from ..models.company import Company, CompanyDB, Tag, TagDB

router = APIRouter(prefix="/companies", tags=["companies"])


@router.post("/", response_model=Company)
async def create_company(
    company: Company, db: Session = Depends(get_db_session)
) -> Company:
    company_dict = company.model_dump(exclude={"tags"})
    db_company = CompanyDB(**company_dict)
    # Handle company tags
    if company.tags:
        for tag in company.tags:
            tag_name = tag.name if isinstance(tag, Tag) else tag
            db_tag = (
                db.query(TagDB)
                .filter(func.lower(TagDB.name) == func.lower(tag_name))
                .first()
            )
            if not db_tag:
                db_tag = TagDB(name=tag_name.lower())
                db.add(db_tag)
            db_company.tags.append(db_tag)
    db.add(db_company)
    try:
        db.commit()
        db.refresh(db_company)
        return Company(
            **{
                c.name: getattr(db_company, c.name)
                for c in db_company.__table__.columns
            },
            tags=[Tag(name=tag.name) for tag in db_company.tags],
        )
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=400, detail="A company with this name already exists"
        )


@router.get("/", response_model=Dict[str, List[Company] | int])
async def get_companies(
    db: Session = Depends(get_db_session), limit: int = 50, skip: int = 0
) -> Dict[str, List[Company] | int]:
    results = db.query(CompanyDB).offset(skip).limit(limit).all()
    total = db.query(CompanyDB).count()
    companies = []
    for company in results:
        company_dict = {
            c.name: getattr(company, c.name) for c in company.__table__.columns
        }
        company_dict["tags"] = [
            Tag(**{t.name: getattr(tag, t.name) for t in tag.__table__.columns})
            for tag in company.tags
        ]
        companies.append(Company(**company_dict))
    return {"results": companies, "total": total}


@router.delete("/", response_model=dict)
async def delete_companies(
    company_ids: List[int] = Query(...), db: Session = Depends(get_db_session)
) -> Dict[str, str]:
    companies = db.query(CompanyDB).filter(CompanyDB.id.in_(company_ids)).all()

    # Check if any companies were not found
    found_ids = {int(company.id) for company in companies}  # Explicitly convert to int
    not_found_ids = set(company_ids) - found_ids

    if not_found_ids:
        raise HTTPException(
            status_code=404, detail=f"Companies with IDs {not_found_ids} not found"
        )

    # Delete the associations in the junction table
    delete_stmt = delete(company_tag).where(company_tag.c.company_id.in_(company_ids))
    db.execute(delete_stmt)
    for company in companies:
        db.delete(company)
    db.commit()
    return {
        "message": f"Companies with IDs {company_ids} have been deleted successfully"
    }


@router.get("/check-name/")
async def check_company_name(
    name: str, db: Session = Depends(get_db_session)
) -> Dict[str, bool]:
    company = db.query(CompanyDB).filter(CompanyDB.name == name.strip()).first()
    return {"exists": company is not None}


@router.get("/check-tag/")
async def check_company_tag(
    name: str, db: Session = Depends(get_db_session)
) -> Dict[str, bool]:
    tag = db.query(TagDB).filter(TagDB.name == name.lower().strip()).first()
    return {"exists": tag is not None}
