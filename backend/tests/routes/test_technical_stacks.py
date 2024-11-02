from tests.conftest import sample_data

from backend.api.models import TechnicalStackDB


def test_create_technical_stack(client):
    create_response = client.post(
        "/technical-stacks/",
        json={"name": "Python"},
    )
    assert create_response.status_code == 200
    assert create_response.json()["name"] == "Python"


def test_get_technical_stacks(client, sample_data):
    get_response = client.get("/technical-stacks/")
    assert get_response.status_code == 200
    retrieved_stack = get_response.json()["results"][0]
    assert retrieved_stack["name"] == sample_data["technical_stack"].name


def test_delete_technical_stack(client, sample_data, test_db):
    # Delete the technical stack
    response = client.delete(
        f"/technical-stacks/?stack_ids={sample_data['technical_stack'].id}",
    )
    assert response.status_code == 200
    assert "deleted successfully" in response.json()["message"]

    # Verify the technical stack is deleted
    deleted_stack = (
        test_db.query(TechnicalStackDB)
        .filter(TechnicalStackDB.id == sample_data["technical_stack"].id)
        .first()
    )
    assert deleted_stack is None
