# Tech Salary Information 

This project consists of a backend API and a frontend application for managing and displaying salary information.

## Prerequisites

- Python 3.11+
- Poetry
- Node.js and npm
- Google Cloud SDK (gcloud CLI)
- Firebase CLI
- Turso CLI
- Make

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/doanhat/salaries-tech.git
   cd salaries-tech
   ```

2. Install backend and frontend environments:
   ```bash
   make install-backend
   make install-frontend
   ```

## Local Development

To run the project locally:

1. To run separately backend and frontend:
   - Copy the dev database to the main database:
     ```bash
     make replace-db
     ```
   - Initialize the backend and frontend environments:
     ```bash
     make set-local-env
     ```
   - In a second terminal:
     ```bash
     cd backend
     uvicorn api.main:app --reload
     ```

   - In a third terminal:
     ```bash
     cd frontend
     npm start
     ```
2. To run all-in-one:
   ```bash
   make run-local
   ```

This will start the backend at `http://localhost:8000` and the frontend at `http://localhost:3000`.

3. To cleanup:
   ```bash
   make cleanup
   ```

## Local Testing

- Backend:
  ```bash
  make check-backend
  make test-backend
  ```

- Frontend:
  ```bash
  make lint-frontend
  make format-frontend
  make test-frontend
  ```

## Database Management (need Turso database token)

- Sync data from API:
  ```bash
  make sync
  ```

- Create development data:
  ```bash
  make create-dev-data
  ```

- Replace the main database with development data:
  ```bash   
  make replace-db
  ```

## Project Structure

- `backend/`: Contains the FastAPI backend application
- `frontend/`: Contains the React frontend application
- `Makefile`: Contains various commands for development and deployment

## Environment Variables

- `PROJECT_ID`: Google Cloud Project ID
- `REGION`: Google Cloud region (default: europe-west1)
- `CAPTCHA_KEY`: Google reCAPTCHA site key
- `LOCAL_BACKEND_URL`: URL for local backend (default: http://localhost:8000)
- `LOCAL_FRONTEND_URL`: URL for local frontend (default: http://localhost:3000)
- `LOCAL_SQLALCHEMY_DATABASE_URL`: SQLite database URL for local development
- `FIREBASE_SITE_NAME`: Firebase hosting site name

