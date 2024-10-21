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


.PHONY: check
check: install-backend ## Run linters and static analysis
	poetry run isort $(PACKAGES)
	poetry run ruff format $(PACKAGES)
	poetry run ruff check $(PACKAGE) --fix
	poetry run mypy --show-error-codes --ignore-missing-imports --config-file pyproject.toml $(PACKAGE)

.PHONY: test
test: install-backend ## Run unit tests
	@if test -e $(FAILURES); then cd backend && poetry run pytest tests --last-failed --exitfirst; fi
	@rm -rf $(FAILURES)
	cd backend && poetry run pytest tests
	

.PHONY: sync
sync: install-backend ## Sync data from API
	python -m backend.sync.populate_db

.PHONY: install-frontend
install-frontend:
	cd frontend && npm install

.PHONY: lint-frontend
lint-frontend:
	cd frontend && npm run lint:fix

.PHONY: format-frontend 
format-frontend: lint-frontend
	cd frontend && npm run format



# Targets for local development
.PHONY: set-local-env
set-local-env:
	@echo "Setting local environment variables..."
	if [ ! -f backend/api/.env ]; then \
		echo "ALLOWED_ORIGINS=" > backend/api/.env; \
		echo "PROJECT_ID=" >> backend/api/.env; \
		echo "RECAPTCHA_KEY=" >> backend/api/.env; \
	fi
	if [ ! -f frontend/.env ]; then \
		echo "REACT_APP_API_BASE_URL=" > frontend/.env; \
		echo "REACT_APP_RECAPTCHA_SITE_KEY=" >> frontend/.env; \
	fi
	if [ "$$(uname)" = "Darwin" ]; then \
		sed -i '' 's|^ALLOWED_ORIGINS=.*|ALLOWED_ORIGINS='"$(LOCAL_FRONTEND_URL)"'|' backend/api/.env; \
		sed -i '' 's|^PROJECT_ID=.*|PROJECT_ID='"$(PROJECT_ID)"'|' backend/api/.env; \
		sed -i '' 's|^RECAPTCHA_KEY=.*|RECAPTCHA_KEY='"$(CAPTCHA_KEY)"'|' backend/api/.env; \
	else \
		sed -i 's|^ALLOWED_ORIGINS=.*|ALLOWED_ORIGINS='"$(LOCAL_FRONTEND_URL)"'|' backend/api/.env; \
		sed -i 's|^PROJECT_ID=.*|PROJECT_ID='"$(PROJECT_ID)"'|' backend/api/.env; \
		sed -i 's|^RECAPTCHA_KEY=.*|RECAPTCHA_KEY='"$(CAPTCHA_KEY)"'|' backend/api/.env; \
	fi
	if [ "$$(uname)" = "Darwin" ]; then \
		sed -i '' 's|^REACT_APP_API_BASE_URL=.*|REACT_APP_API_BASE_URL='"$(LOCAL_BACKEND_URL)"'|' frontend/.env; \
		sed -i '' 's|^REACT_APP_RECAPTCHA_SITE_KEY=.*|REACT_APP_RECAPTCHA_SITE_KEY='"$(CAPTCHA_KEY)"'|' frontend/.env; \
	else \
		sed -i 's|^REACT_APP_API_BASE_URL=.*|REACT_APP_API_BASE_URL='"$(LOCAL_BACKEND_URL)"'|' frontend/.env; \
		sed -i 's|^REACT_APP_RECAPTCHA_SITE_KEY=.*|REACT_APP_RECAPTCHA_SITE_KEY='"$(CAPTCHA_KEY)"'|' frontend/.env; \
	fi

.PHONY: run-local
run-local: set-local-env
	@echo "Starting backend and frontend..."
	@trap 'kill %1; kill %2' SIGINT; \
	(cd backend && poetry run uvicorn api.main:app --reload) & \
	(cd frontend && npm start) & \
	wait

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
		--set-env-vars RECAPTCHA_KEY=$(shell if [ -n "$(RECAPTCHA_KEY)" ]; then echo "$(RECAPTCHA_KEY)"; else awk -F "=" "/RECAPTCHA_KEY/ {print substr(\$$0, index(\$$0,\"=\")+1)}" backend/api/.env; fi) \
		--set-env-vars ALLOWED_ORIGINS=$(shell if [ -n "$(ALLOWED_ORIGINS)" ]; then echo "$(ALLOWED_ORIGINS)"; else awk -F "=" "/ALLOWED_ORIGINS/ {print substr(\$$0, index(\$$0,\"=\")+1)}" backend/api/.env; fi) \
		--set-env-vars SQLALCHEMY_DATABASE_URL=$(shell if [ -n "$(SQLALCHEMY_DATABASE_URL)" ]; then echo "$(SQLALCHEMY_DATABASE_URL)"; else awk -F "=" "/SQLALCHEMY_DATABASE_URL/ {print substr(\$$0, index(\$$0,\"=\")+1)}" backend/api/.env; fi)


set-frontend-env:
	@CLOUD_RUN_URL=$$(gcloud run services describe $(IMAGE_NAME) --region $(REGION) --format='value(status.url)') && \
	RECAPTCHA_KEY=$$(if [ -n "$(RECAPTCHA_KEY)" ]; then echo "$(RECAPTCHA_KEY)"; else awk -F "=" "/RECAPTCHA_KEY/ {print substr(\$$0, index(\$$0,\"=\")+1)}" backend/api/.env; fi) && \
	if [ ! -f frontend/.env ]; then \
		echo "REACT_APP_API_BASE_URL=" > frontend/.env; \
		echo "REACT_APP_RECAPTCHA_SITE_KEY=" >> frontend/.env; \
	fi && \
	if [ "$$(uname)" = "Darwin" ]; then \
		sed -i '' 's|^REACT_APP_API_BASE_URL=.*|REACT_APP_API_BASE_URL='"$$CLOUD_RUN_URL"'|' frontend/.env; \
		sed -i '' 's|^REACT_APP_RECAPTCHA_SITE_KEY=.*|REACT_APP_RECAPTCHA_SITE_KEY='"$$RECAPTCHA_KEY"'|' frontend/.env; \
	else \
		sed -i 's|^REACT_APP_API_BASE_URL=.*|REACT_APP_API_BASE_URL='"$$CLOUD_RUN_URL"'|' frontend/.env; \
		sed -i 's|^REACT_APP_RECAPTCHA_SITE_KEY=.*|REACT_APP_RECAPTCHA_SITE_KEY='"$$RECAPTCHA_KEY"'|' frontend/.env; \
	fi

FIREBASE_SITE_NAME := salaries-tech

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
	
set-backend-env:
	@if [ ! -f backend/api/.env ]; then \
		echo "ALLOWED_ORIGINS=" > backend/api/.env; \
		echo "PROJECT_ID=" >> backend/api/.env; \
		echo "RECAPTCHA_KEY=" >> backend/api/.env; \
	fi && \
	SITE_NAME=$${FIREBASE_SITE_NAME:-$(FIREBASE_SITE_NAME)} && \
	FIREBASE_URL="https://$$SITE_NAME.web.app" && \
	PROJECT_ID=$$(if [ -n "$(PROJECT_ID)" ]; then echo "$(PROJECT_ID)"; else awk -F "=" "/PROJECT_ID/ {print substr(\$$0, index(\$$0,\"=\")+1)}" backend/api/.env; fi) && \
	RECAPTCHA_KEY=$$(if [ -n "$(RECAPTCHA_KEY)" ]; then echo "$(RECAPTCHA_KEY)"; else awk -F "=" "/RECAPTCHA_KEY/ {print substr(\$$0, index(\$$0,\"=\")+1)}" backend/api/.env; fi) && \
	echo "Firebase URL: $$FIREBASE_URL" && \
	if [ "$$(uname)" = "Darwin" ]; then \
		sed -i '' 's|^ALLOWED_ORIGINS=.*|ALLOWED_ORIGINS='"$$FIREBASE_URL"'|' backend/api/.env; \
		sed -i '' 's|^PROJECT_ID=.*|PROJECT_ID='"$$PROJECT_ID"'|' backend/api/.env; \
		sed -i '' 's|^RECAPTCHA_KEY=.*|RECAPTCHA_KEY='"$$RECAPTCHA_KEY"'|' backend/api/.env; \
	else \
		sed -i 's|^ALLOWED_ORIGINS=.*|ALLOWED_ORIGINS='"$$FIREBASE_URL"'|' backend/api/.env; \
		sed -i 's|^PROJECT_ID=.*|PROJECT_ID='"$$PROJECT_ID"'|' backend/api/.env; \
		sed -i 's|^RECAPTCHA_KEY=.*|RECAPTCHA_KEY='"$$RECAPTCHA_KEY"'|' backend/api/.env; \
	fi

# Update Cloud Run with new ALLOWED_ORIGINS
update-backend-env: set-backend-env set-frontend-env
	gcloud run services update $(IMAGE_NAME) \
		--region $(REGION) \
		--set-env-vars ALLOWED_ORIGINS=$(shell if [ -n "$(ALLOWED_ORIGINS)" ]; then echo "$(ALLOWED_ORIGINS)"; else awk -F "=" "/ALLOWED_ORIGINS/ {print substr(\$$0, index(\$$0,\"=\")+1)}" backend/api/.env; fi) \
		--set-env-vars SQLALCHEMY_DATABASE_URL=$(shell if [ -n "$(SQLALCHEMY_DATABASE_URL)" ]; then echo "$(SQLALCHEMY_DATABASE_URL)"; else awk -F "=" "/SQLALCHEMY_DATABASE_URL/ {print substr(\$$0, index(\$$0,\"=\")+1)}" backend/api/.env; fi) \
		--set-env-vars PROJECT_ID=$(shell if [ -n "$(PROJECT_ID)" ]; then echo "$(PROJECT_ID)"; else awk -F "=" "/PROJECT_ID/ {print substr(\$$0, index(\$$0,\"=\")+1)}" backend/api/.env; fi) \
		--set-env-vars RECAPTCHA_KEY=$(shell if [ -n "$(RECAPTCHA_KEY)" ]; then echo "$(RECAPTCHA_KEY)"; else awk -F "=" "/RECAPTCHA_KEY/ {print substr(\$$0, index(\$$0,\"=\")+1)}" backend/api/.env; fi)


.PHONY: cleanup
cleanup:
	@echo "Cleaning up processes..."
	@pkill -f "uvicorn api.main:app" || true
	@pkill -f "react-scripts start" || true
	@lsof -ti:3000 | xargs kill -9 || true
	@lsof -ti:8000 | xargs kill -9 || true
