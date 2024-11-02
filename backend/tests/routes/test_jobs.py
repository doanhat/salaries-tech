from backend.api.models import JobDB


def test_create_job(client):
    create_response = client.post(
        "/jobs/",
        json={"title": "Data Scientist"},
    )
    assert create_response.status_code == 200
    assert create_response.json()["title"] == "data scientist"


def test_get_jobs(client, sample_data):
    get_response = client.get("/jobs/")
    assert get_response.status_code == 200
    retrieved_job = get_response.json()["results"][0]
    assert retrieved_job["title"] == sample_data["job"].title


def test_delete_jobs(client, sample_data, test_db):
    # Delete the job
    response = client.delete(
        f"/jobs/?job_ids={sample_data['job'].id}",
    )
    assert response.status_code == 200
    assert "deleted successfully" in response.json()["message"]

    # Verify the job is deleted
    deleted_job = test_db.query(JobDB).filter(JobDB.id == sample_data["job"].id).first()
    assert deleted_job is None
