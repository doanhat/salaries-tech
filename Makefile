PACKAGE := backend/api
PACKAGES := $(PACKAGE) backend/tests
FAILURES := .pytest_cache/v/cache/lastfailed
# Variables
PROJECT_ID := salaries-438922
IMAGE_NAME := salary-backend
GCR_IMAGE := gcr.io/$(PROJECT_ID)/$(IMAGE_NAME)
REGION := europe-west1  # Default region, can be overridden in .env
CAPTCHA_KEY := 6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI # Google public site key for testing
LOCAL_BACKEND_URL := http://localhost:8000
LOCAL_FRONTEND_URL := http://localhost:3000
LOCAL_SQLALCHEMY_DATABASE_URL := sqlite:///./salaries.db
FIREBASE_SITE_NAME := salaries-tech
API_KEY_SECRET_NAME := salaries-api-key
EMAIL_VERIFICATION_SECRET_NAME := salaries-email-verification
LOCAL_SENDGRID_FROM_EMAIL := hello@salaries.tech
LOCAL_SENDGRID_API_KEY := sg-api-key
LOCAL_FIREBASE_API_KEY := local-firebase-api-key
LOCAL_FIREBASE_AUTH_DOMAIN := ${PROJECT_ID}.firebaseapp.com
LOCAL_FIREBASE_STORAGE_BUCKET := ${PROJECT_ID}.firebasestorage.app
LOCAL_FIREBASE_MESSAGING_SENDER_ID := local-firebase-messaging-sender-id
LOCAL_FIREBASE_APP_ID := local-firebase-app-id
LOCAL_FIREBASE_MEASUREMENT_ID := local-firebase-measurement-id

# Backend
install-backend: .install-backend .cache ## Install project dependencies

.install-backend: poetry.lock
	poetry install
	poetry check
	@touch $@

poetry.lock: pyproject.toml
	poetry lock
	@touch $@

.cache:
	@mkdir -p .cache

.PHONY: requirements.txt
requirements.txt: install-backend ## Generate requirements.txt
	@mkdir -p dist
	@poetry export --without-hashes --without dev -f requirements.txt > dist/requirements.txt
	@if [ "$$(uname)" = "Darwin" ]; then \
		sed -i '' '1d' dist/requirements.txt; \
	else \
		sed -i '1d' dist/requirements.txt; \
	fi

.PHONY: check-backend
check-backend: install-backend ## Run linters and static analysis
	poetry run isort $(PACKAGES)
	poetry run ruff format $(PACKAGES)
	poetry run ruff check $(PACKAGE) --fix
	poetry run mypy --show-error-codes --ignore-missing-imports --config-file pyproject.toml $(PACKAGE)

.PHONY: test-backend
test-backend: install-backend ## Run unit tests
	@if test -e $(FAILURES); then cd backend && poetry run pytest tests --last-failed --exitfirst; fi
	@rm -rf $(FAILURES)
	cd backend && poetry run pytest tests

# Frontend
.PHONY: install-frontend
install-frontend:
	cd frontend && npm install

.PHONY: lint-frontend
lint-frontend:
	cd frontend && npm run lint:fix

.PHONY: format-frontend 
format-frontend: lint-frontend
	cd frontend && npm run format

.PHONY: test-frontend
test-frontend:
	cd frontend && npm run test

# Database
.PHONY: sync
sync: install-backend ## Sync data from API
	## delete the existing db
	rm -f backend/salaries_dev_data.db backend/salaries_dev_data.db-client_wal_index backend/salaries_dev_data.db-shm backend/salaries_dev_data.db-wal
	python -m backend.sync.populate_db

.PHONY: create-dev-data
create-dev-data:
	rm -f backend/salaries_dev_data.db backend/salaries_dev_data.db-* && \
	turso db shell salaries .dump > dump.sql && cat dump.sql | sqlite3 backend/salaries_dev_data.db 

.PHONY: replace-db
replace-db:
	@echo "Replacing salaries.db with salaries_dev_data.db..."
	@if [ -f backend/salaries_dev_data.db ]; then \
		pkill -f "salaries.db" 2>/dev/null || true && \
		rm -f backend/salaries.db* backend/salaries_dev_data.db-* && \
		sqlite3 backend/salaries_dev_data.db "PRAGMA wal_checkpoint(FULL);" && \
		sqlite3 backend/salaries_dev_data.db ".backup 'backend/salaries.db'" && \
		echo "Database replaced successfully."; \
	else \
		echo "Error: salaries_dev_data.db not found in backend/" && \
		exit 1; \
	fi

# Targets for local development
.PHONY: set-local-env
set-local-env:
	@echo "Setting local environment variables..."
	if [ ! -f backend/api/.env ]; then \
		echo "ALLOWED_ORIGINS=" > backend/api/.env; \
		echo "PROJECT_ID=" >> backend/api/.env; \
		echo "RECAPTCHA_KEY=" >> backend/api/.env; \
		echo "SQLALCHEMY_DATABASE_URL=" >> backend/api/.env; \
		echo "API_KEY_SECRET_NAME=" >> backend/api/.env; \
		echo "ENV=dev" >> backend/api/.env; \
		echo "EMAIL_VERIFICATION_SECRET_NAME=" >> backend/api/.env; \
		echo "SENDGRID_API_KEY=" >> backend/api/.env; \
		echo "SENDGRID_FROM_EMAIL=" >> backend/api/.env; \
	fi
	if [ ! -f frontend/.env ]; then \
		echo "REACT_APP_API_BASE_URL=" > frontend/.env; \
		echo "REACT_APP_RECAPTCHA_SITE_KEY=" >> frontend/.env; \
		echo "REACT_APP_API_KEY=" >> frontend/.env; \
		echo "REACT_APP_FIREBASE_API_KEY=" >> frontend/.env; \
		echo "REACT_APP_FIREBASE_AUTH_DOMAIN=" >> frontend/.env; \
		echo "REACT_APP_FIREBASE_PROJECT_ID=" >> frontend/.env; \
		echo "REACT_APP_FIREBASE_STORAGE_BUCKET=" >> frontend/.env; \
		echo "REACT_APP_FIREBASE_MESSAGING_SENDER_ID=" >> frontend/.env; \
		echo "REACT_APP_FIREBASE_APP_ID=" >> frontend/.env; \
		echo "REACT_APP_FIREBASE_MEASUREMENT_ID=" >> frontend/.env; \
	fi
	if [ "$$(uname)" = "Darwin" ]; then \
		sed -i '' 's|^ALLOWED_ORIGINS=.*|ALLOWED_ORIGINS='"$(LOCAL_FRONTEND_URL)"'|' backend/api/.env; \
		sed -i '' 's|^PROJECT_ID=.*|PROJECT_ID='"$(PROJECT_ID)"'|' backend/api/.env; \
		sed -i '' 's|^RECAPTCHA_KEY=.*|RECAPTCHA_KEY='"$(CAPTCHA_KEY)"'|' backend/api/.env; \
		sed -i '' 's|^SQLALCHEMY_DATABASE_URL=.*|SQLALCHEMY_DATABASE_URL='"$(LOCAL_SQLALCHEMY_DATABASE_URL)"'|' backend/api/.env; \
		sed -i '' 's|^ENV=.*|ENV=dev|' backend/api/.env; \
		sed -i '' 's|^API_KEY_SECRET_NAME=.*|API_KEY_SECRET_NAME='"$(API_KEY_SECRET_NAME)"'|' backend/api/.env; \
		sed -i '' 's|^EMAIL_VERIFICATION_SECRET_NAME=.*|EMAIL_VERIFICATION_SECRET_NAME='"$(EMAIL_VERIFICATION_SECRET_NAME)"'|' backend/api/.env; \
		sed -i '' 's|^SENDGRID_API_KEY=.*|SENDGRID_API_KEY='"$(LOCAL_SENDGRID_API_KEY)"'|' backend/api/.env; \
		sed -i '' 's|^SENDGRID_FROM_EMAIL=.*|SENDGRID_FROM_EMAIL='"$(LOCAL_SENDGRID_FROM_EMAIL)"'|' backend/api/.env; \
	else \
		sed -i 's|^ALLOWED_ORIGINS=.*|ALLOWED_ORIGINS='"$(LOCAL_FRONTEND_URL)"'|' backend/api/.env; \
		sed -i 's|^PROJECT_ID=.*|PROJECT_ID='"$(PROJECT_ID)"'|' backend/api/.env; \
		sed -i 's|^RECAPTCHA_KEY=.*|RECAPTCHA_KEY='"$(CAPTCHA_KEY)"'|' backend/api/.env; \
		sed -i 's|^SQLALCHEMY_DATABASE_URL=.*|SQLALCHEMY_DATABASE_URL='"$(LOCAL_SQLALCHEMY_DATABASE_URL)"'|' backend/api/.env; \
		sed -i 's|^ENV=.*|ENV=dev|' backend/api/.env; \
		sed -i 's|^API_KEY_SECRET_NAME=.*|API_KEY_SECRET_NAME='"$(API_KEY_SECRET_NAME)"'|' backend/api/.env; \
		sed -i 's|^EMAIL_VERIFICATION_SECRET_NAME=.*|EMAIL_VERIFICATION_SECRET_NAME='"$(EMAIL_VERIFICATION_SECRET_NAME)"'|' backend/api/.env; \
		sed -i 's|^SENDGRID_API_KEY=.*|SENDGRID_API_KEY='"$(LOCAL_SENDGRID_API_KEY)"'|' backend/api/.env; \
		sed -i 's|^SENDGRID_FROM_EMAIL=.*|SENDGRID_FROM_EMAIL='"$(LOCAL_SENDGRID_FROM_EMAIL)"'|' backend/api/.env; \
	fi
	if [ "$$(uname)" = "Darwin" ]; then \
		sed -i '' 's|^REACT_APP_API_BASE_URL=.*|REACT_APP_API_BASE_URL='"$(LOCAL_BACKEND_URL)"'|' frontend/.env; \
		sed -i '' 's|^REACT_APP_RECAPTCHA_SITE_KEY=.*|REACT_APP_RECAPTCHA_SITE_KEY='"$(CAPTCHA_KEY)"'|' frontend/.env; \
		sed -i '' 's|^REACT_APP_API_KEY=.*|REACT_APP_API_KEY='"$(API_KEY_SECRET_NAME)"'|' frontend/.env; \
		sed -i '' 's|^REACT_APP_FIREBASE_API_KEY=.*|REACT_APP_FIREBASE_API_KEY='"$(LOCAL_FIREBASE_API_KEY)"'|' frontend/.env; \
		sed -i '' 's|^REACT_APP_FIREBASE_AUTH_DOMAIN=.*|REACT_APP_FIREBASE_AUTH_DOMAIN='"$(LOCAL_FIREBASE_AUTH_DOMAIN)"'|' frontend/.env; \
		sed -i '' 's|^REACT_APP_FIREBASE_PROJECT_ID=.*|REACT_APP_FIREBASE_PROJECT_ID='"$(PROJECT_ID)"'|' frontend/.env; \
		sed -i '' 's|^REACT_APP_FIREBASE_STORAGE_BUCKET=.*|REACT_APP_FIREBASE_STORAGE_BUCKET='"$(LOCAL_FIREBASE_STORAGE_BUCKET)"'|' frontend/.env; \
		sed -i '' 's|^REACT_APP_FIREBASE_MESSAGING_SENDER_ID=.*|REACT_APP_FIREBASE_MESSAGING_SENDER_ID='"$(LOCAL_FIREBASE_MESSAGING_SENDER_ID)"'|' frontend/.env; \
		sed -i '' 's|^REACT_APP_FIREBASE_APP_ID=.*|REACT_APP_FIREBASE_APP_ID='"$(LOCAL_FIREBASE_APP_ID)"'|' frontend/.env; \
		sed -i '' 's|^REACT_APP_FIREBASE_MEASUREMENT_ID=.*|REACT_APP_FIREBASE_MEASUREMENT_ID='"$(LOCAL_FIREBASE_MEASUREMENT_ID)"'|' frontend/.env; \
	else \
		sed -i 's|^REACT_APP_API_BASE_URL=.*|REACT_APP_API_BASE_URL='"$(LOCAL_BACKEND_URL)"'|' frontend/.env; \
		sed -i 's|^REACT_APP_RECAPTCHA_SITE_KEY=.*|REACT_APP_RECAPTCHA_SITE_KEY='"$(CAPTCHA_KEY)"'|' frontend/.env; \
		sed -i 's|^REACT_APP_API_KEY=.*|REACT_APP_API_KEY='"$(API_KEY_SECRET_NAME)"'|' frontend/.env; \
		sed -i 's|^REACT_APP_FIREBASE_API_KEY=.*|REACT_APP_FIREBASE_API_KEY='"$(LOCAL_FIREBASE_API_KEY)"'|' frontend/.env; \
		sed -i 's|^REACT_APP_FIREBASE_AUTH_DOMAIN=.*|REACT_APP_FIREBASE_AUTH_DOMAIN='"$(LOCAL_FIREBASE_AUTH_DOMAIN)"'|' frontend/.env; \
		sed -i 's|^REACT_APP_FIREBASE_PROJECT_ID=.*|REACT_APP_FIREBASE_PROJECT_ID='"$(PROJECT_ID)"'|' frontend/.env; \
		sed -i 's|^REACT_APP_FIREBASE_STORAGE_BUCKET=.*|REACT_APP_FIREBASE_STORAGE_BUCKET='"$(LOCAL_FIREBASE_STORAGE_BUCKET)"'|' frontend/.env; \
		sed -i 's|^REACT_APP_FIREBASE_MESSAGING_SENDER_ID=.*|REACT_APP_FIREBASE_MESSAGING_SENDER_ID='"$(LOCAL_FIREBASE_MESSAGING_SENDER_ID)"'|' frontend/.env; \
		sed -i 's|^REACT_APP_FIREBASE_APP_ID=.*|REACT_APP_FIREBASE_APP_ID='"$(LOCAL_FIREBASE_APP_ID)"'|' frontend/.env; \
		sed -i 's|^REACT_APP_FIREBASE_MEASUREMENT_ID=.*|REACT_APP_FIREBASE_MEASUREMENT_ID='"$(LOCAL_FIREBASE_MEASUREMENT_ID)"'|' frontend/.env; \
	fi

.PHONY: run-local
run-local: set-local-env replace-db
	@echo "Starting backend and frontend..."
	@trap 'kill %1; kill %2' SIGINT; \
	(cd backend && poetry run uvicorn api.main:app --reload) & \
	(cd frontend && npm start) & \
	wait

.PHONY: cleanup
cleanup:
	@echo "Cleaning up processes..."
	@pkill -f "uvicorn api.main:app" || true
	@pkill -f "react-scripts start" || true
	@lsof -ti:3000 | xargs kill -9 || true
	@lsof -ti:8000 | xargs kill -9 || true

# Targets for deployment
.PHONY: deploy
deploy: deploy-backend get-backend-url deploy-frontend get-frontend-url update-backend-env

enable-apis:
	@echo "Enabling necessary APIs..."
	gcloud services enable cloudbuild.googleapis.com run.googleapis.com

build-and-push: enable-apis requirements.txt
	@echo "Building and pushing Docker image to GCR..."
	gcloud builds submit --tag $(GCR_IMAGE)

deploy-backend: build-and-push
	@echo "Deploying to Google Cloud Run..."
	gcloud run deploy $(IMAGE_NAME) \
		--image $(GCR_IMAGE) \
		--platform managed \
		--region $(REGION) \
		--allow-unauthenticated \
		--set-env-vars PROJECT_ID=$(PROJECT_ID) \
		--set-env-vars RECAPTCHA_KEY=$(RECAPTCHA_KEY) \
		--set-env-vars ALLOWED_ORIGINS=https://$(FIREBASE_SITE_NAME).web.app \
		--set-env-vars SQLALCHEMY_DATABASE_URL=$(SQLALCHEMY_DATABASE_URL) \
		--set-env-vars ENV=$(ENV) \
		--set-env-vars API_KEY_SECRET_NAME=$(API_KEY_SECRET_NAME) \
		--set-env-vars EMAIL_VERIFICATION_SECRET_NAME=$(EMAIL_VERIFICATION_SECRET_NAME) \
		--set-env-vars SENDGRID_API_KEY=$(SENDGRID_API_KEY) \
		--set-env-vars SENDGRID_FROM_EMAIL=$(SENDGRID_FROM_EMAIL)


set-frontend-env:
	@CLOUD_RUN_URL=$$(gcloud run services describe $(IMAGE_NAME) --region $(REGION) --format='value(status.url)') && \
	API_KEY=$$(gcloud secrets versions access latest --secret=$(API_KEY_SECRET_NAME)) && \
	if [ ! -f frontend/.env ]; then \
		echo "REACT_APP_API_BASE_URL=" > frontend/.env; \
		echo "REACT_APP_RECAPTCHA_SITE_KEY=" >> frontend/.env; \
		echo "REACT_APP_API_KEY=" >> frontend/.env; \
		echo "REACT_APP_FIREBASE_API_KEY=" >> frontend/.env; \
		echo "REACT_APP_FIREBASE_AUTH_DOMAIN=" >> frontend/.env; \
		echo "REACT_APP_FIREBASE_PROJECT_ID=" >> frontend/.env; \
		echo "REACT_APP_FIREBASE_STORAGE_BUCKET=" >> frontend/.env; \
		echo "REACT_APP_FIREBASE_MESSAGING_SENDER_ID=" >> frontend/.env; \
		echo "REACT_APP_FIREBASE_APP_ID=" >> frontend/.env; \
		echo "REACT_APP_FIREBASE_MEASUREMENT_ID=" >> frontend/.env; \
	fi && \
	if [ "$$(uname)" = "Darwin" ]; then \
		sed -i '' 's|^REACT_APP_API_BASE_URL=.*|REACT_APP_API_BASE_URL='"$$CLOUD_RUN_URL"'|' frontend/.env; \
		sed -i '' 's|^REACT_APP_RECAPTCHA_SITE_KEY=.*|REACT_APP_RECAPTCHA_SITE_KEY='"$(RECAPTCHA_KEY)"'|' frontend/.env; \
		sed -i '' 's|^REACT_APP_API_KEY=.*|REACT_APP_API_KEY='"$$API_KEY"'|' frontend/.env; \
		sed -i '' 's|^REACT_APP_FIREBASE_API_KEY=.*|REACT_APP_FIREBASE_API_KEY='"$(FIREBASE_API_KEY)"'|' frontend/.env; \
		sed -i '' 's|^REACT_APP_FIREBASE_AUTH_DOMAIN=.*|REACT_APP_FIREBASE_AUTH_DOMAIN='"$(FIREBASE_AUTH_DOMAIN)"'|' frontend/.env; \
		sed -i '' 's|^REACT_APP_FIREBASE_PROJECT_ID=.*|REACT_APP_FIREBASE_PROJECT_ID='"$(PROJECT_ID)"'|' frontend/.env; \
		sed -i '' 's|^REACT_APP_FIREBASE_STORAGE_BUCKET=.*|REACT_APP_FIREBASE_STORAGE_BUCKET='"$(FIREBASE_STORAGE_BUCKET)"'|' frontend/.env; \
		sed -i '' 's|^REACT_APP_FIREBASE_MESSAGING_SENDER_ID=.*|REACT_APP_FIREBASE_MESSAGING_SENDER_ID='"$(FIREBASE_MESSAGING_SENDER_ID)"'|' frontend/.env; \
		sed -i '' 's|^REACT_APP_FIREBASE_APP_ID=.*|REACT_APP_FIREBASE_APP_ID='"$(FIREBASE_APP_ID)"'|' frontend/.env; \
		sed -i '' 's|^REACT_APP_FIREBASE_MEASUREMENT_ID=.*|REACT_APP_FIREBASE_MEASUREMENT_ID='"$(FIREBASE_MEASUREMENT_ID)"'|' frontend/.env; \
	else \
		sed -i 's|^REACT_APP_API_BASE_URL=.*|REACT_APP_API_BASE_URL='"$$CLOUD_RUN_URL"'|' frontend/.env; \
		sed -i 's|^REACT_APP_RECAPTCHA_SITE_KEY=.*|REACT_APP_RECAPTCHA_SITE_KEY='"$(RECAPTCHA_KEY)"'|' frontend/.env; \
		sed -i 's|^REACT_APP_API_KEY=.*|REACT_APP_API_KEY='"$$API_KEY"'|' frontend/.env; \
		sed -i 's|^REACT_APP_FIREBASE_API_KEY=.*|REACT_APP_FIREBASE_API_KEY='"$(FIREBASE_API_KEY)"'|' frontend/.env; \
		sed -i 's|^REACT_APP_FIREBASE_AUTH_DOMAIN=.*|REACT_APP_FIREBASE_AUTH_DOMAIN='"$(FIREBASE_AUTH_DOMAIN)"'|' frontend/.env; \
		sed -i 's|^REACT_APP_FIREBASE_PROJECT_ID=.*|REACT_APP_FIREBASE_PROJECT_ID='"$(PROJECT_ID)"'|' frontend/.env; \
		sed -i 's|^REACT_APP_FIREBASE_STORAGE_BUCKET=.*|REACT_APP_FIREBASE_STORAGE_BUCKET='"$(FIREBASE_STORAGE_BUCKET)"'|' frontend/.env; \
		sed -i 's|^REACT_APP_FIREBASE_MESSAGING_SENDER_ID=.*|REACT_APP_FIREBASE_MESSAGING_SENDER_ID='"$(FIREBASE_MESSAGING_SENDER_ID)"'|' frontend/.env; \
		sed -i 's|^REACT_APP_FIREBASE_APP_ID=.*|REACT_APP_FIREBASE_APP_ID='"$(FIREBASE_APP_ID)"'|' frontend/.env; \
		sed -i 's|^REACT_APP_FIREBASE_MEASUREMENT_ID=.*|REACT_APP_FIREBASE_MEASUREMENT_ID='"$(FIREBASE_MEASUREMENT_ID)"'|' frontend/.env; \
	fi


deploy-frontend:
	@echo "Building and deploying frontend to Firebase..."
	@echo "Installing frontend dependencies..."
	cd frontend && npm ci
	@echo "Building React app..."
	cd frontend && npm run build
	@echo "Retrieving Firebase Hosting URL..."
	@FIREBASE_PROJECT_ID=$$(gcloud config get-value project) && \
	SITE_NAME=$${FIREBASE_SITE_NAME:-$(FIREBASE_SITE_NAME)} && \
	firebase use $$FIREBASE_PROJECT_ID --add && \
	firebase target:apply hosting $$SITE_NAME $$SITE_NAME && \
	firebase deploy --only hosting:$$SITE_NAME

.PHONY: create-secret
create-secret:
	@if [ -z "$(SECRET_NAME)" ]; then \
		SECRET_NAME=$(API_KEY_SECRET_NAME); \
	fi
	@echo "Creating/updating API key secret..."
	@API_KEY=$$(openssl rand -base64 32 | tr -d '\n' | tr -d "'" | tr -d " ") && \
	if gcloud secrets describe $(SECRET_NAME) >/dev/null 2>&1; then \
		printf "%s" "$$API_KEY" | gcloud secrets versions add $(SECRET_NAME) --data-file=-; \
		echo "Updated existing API key secret with new version"; \
	else \
		printf "%s" "$$API_KEY" | gcloud secrets create $(SECRET_NAME) \
			--data-file=- \
			--replication-policy="automatic"; \
		echo "Created new API key secret"; \
	fi

.PHONY: get-secret
get-secret:
	@gcloud secrets versions access latest --secret=$(SECRET_NAME)

