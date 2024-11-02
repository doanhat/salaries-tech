import pytest

from backend.api.models import CompanyType
from backend.api.models.company import Company, Tag


def test_company_model():
    company = Company(name="Test Company", type=CompanyType.STARTUP)
    assert company.name == "Test Company"
    assert company.type == CompanyType.STARTUP


def test_company_with_tags():
    tags = [Tag(name="tech"), Tag(name="startup")]
    company = Company(name="Test Company", type=CompanyType.STARTUP, tags=tags)
    assert len(company.tags) == 2
    assert company.tags[0].name == "tech"
    assert company.tags[1].name == "startup"


@pytest.mark.parametrize("company_type", list(CompanyType))
def test_company_types(company_type):
    company = Company(name="Test Company", type=company_type)
    assert company.type == company_type
