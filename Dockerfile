FROM python:3.11.4
WORKDIR /backend/api
COPY dist/requirements.txt .
RUN pip install -r requirements.txt
COPY backend/api .
WORKDIR /backend
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8080"]