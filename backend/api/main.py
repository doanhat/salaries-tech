import os

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Import routes explicitly
from .routes import commons, companies, jobs, salaries, technical_stacks

load_dotenv()

app = FastAPI()

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("ALLOWED_ORIGINS", "http://localhost:3000").split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(commons.router)
app.include_router(salaries.router)
app.include_router(companies.router)
app.include_router(jobs.router)
app.include_router(technical_stacks.router)
