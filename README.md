# Tech Salary Information 

This project consists of a backend API and a frontend application for managing and displaying salary information. Link: https://salaries-tech.web.app/

## Prerequisites

- Python 3.11+
- Poetry
- Node.js and npm
- Google Cloud SDK (gcloud CLI)
- Firebase CLI
- Supabase CLI
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
   - Setup the database with development data:
     ```bash
     make set-up-database-with-init
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

3. To stop all services:
   ```bash
   make cleanup
   ```

## Testing and Code Quality

### Backend
```bash
make check-backend    # Run linters and static analysis
make test-backend    # Run unit tests
```

### Frontend
```bash
make lint-frontend    # Run ESLint
make format-frontend  # Format code with Prettier
make test-frontend   # Run tests
```

## Database Management (need Supabase database credentials)

- CLI program to sync data from API:
  ```bash
  make sync
  ```

- Create development Postgres database with development data:
  ```bash
  make set-up-database-with-init
  ```

## Project Structure

- `alembic/`: Contains Alembic migrations
- `backend/`: Contains the FastAPI backend application
- `frontend/`: Contains the React frontend application
- `Makefile`: Contains various commands for development and deployment

## Environment Variables

### Backend Variables
- `PROJECT_ID`: Google Cloud Project ID
- `REGION`: Google Cloud region (default: europe-west1)
- `CAPTCHA_KEY`: Google reCAPTCHA site key
- `LOCAL_FRONTEND_URL`: Frontend URL (default: http://localhost:3000)
- `LOCAL_SQLALCHEMY_DATABASE_URL`: Postgres database URL
- `LOCAL_CACHE_DATABASE_URL`: SQLite database URL for Cache
- `API_KEY_SECRET_NAME`: Secret name for API key
- `EMAIL_VERIFICATION_SECRET_NAME`: Secret name for email verification
- `SENDGRID_FROM_EMAIL`: SendGrid sender email
- `SENDGRID_API_KEY`: SendGrid API key

### Frontend Variables
- `LOCAL_BACKEND_URL`: Backend URL (default: http://localhost:8000)
- `FIREBASE_SITE_NAME`: Firebase hosting site name
- `FIREBASE_API_KEY`: Firebase API key
- `FIREBASE_AUTH_DOMAIN`: Firebase auth domain
- `FIREBASE_STORAGE_BUCKET`: Firebase storage bucket
- `FIREBASE_MESSAGING_SENDER_ID`: Firebase messaging sender ID
- `FIREBASE_APP_ID`: Firebase app ID
- `FIREBASE_MEASUREMENT_ID`: Firebase measurement ID

## Project Structure

```
.
├── alembic/           # Alembic migrations
├── backend/           # FastAPI backend application
├── frontend/          # React frontend application
├── docker-compose.yml # Docker compose file for Postgres
├── Dockerfile         # Dockerfile for backend
├── dump.sql           # Database dump file
├── firebase.json      # Firebase configuration
├── Makefile           # Build and deployment commands
├── poetry.lock        # Poetry dependencies lock file
├── pyproject.toml     # Python project configuration
```

