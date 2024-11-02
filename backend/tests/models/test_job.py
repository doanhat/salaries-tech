from backend.api.models.job import Job


def test_job_model():
    job = Job(title="Software Engineer")
    assert job.title == "Software Engineer"
