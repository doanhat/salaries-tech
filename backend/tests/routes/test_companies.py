import uuid

from backend.api.models import CompanyDB, CompanyType


def test_create_company(client):
    unique_name = f"New Company {uuid.uuid4()}"
    create_data = {
        "name": unique_name,
        "type": CompanyType.STARTUP.value,
        "tags": [{"name": "tech"}, {"name": "AI"}],
    }
    create_response = client.post(
        "/companies/",
        json=create_data,
    )
    assert create_response.status_code == 200

    created_company = create_response.json()
    assert created_company["name"] == unique_name
    assert created_company["type"] == CompanyType.STARTUP.value
    assert len(created_company["tags"]) == 2


def test_get_companies(client, sample_data):
    # Test getting the created company
    get_response = client.get(
        f"/companies/",
    )
    assert get_response.status_code == 200

    retrieved_company = get_response.json()["results"][0]
    assert retrieved_company["id"] == sample_data["company"].id
    assert retrieved_company["name"] == sample_data["company"].name
    assert retrieved_company["type"] == sample_data["company"].type
    assert len(retrieved_company["tags"]) == len(sample_data["company"].tags)


def test_delete_companies(client, sample_data, test_db):
    # Delete the company
    response = client.delete(
        f"/companies/?company_ids={sample_data['company'].id}",
    )
    assert response.status_code == 200
    assert "deleted successfully" in response.json()["message"]

    # Verify the company is deleted
    deleted_company = (
        test_db.query(CompanyDB)
        .filter(CompanyDB.id == sample_data["company"].id)
        .first()
    )
    assert deleted_company is None
