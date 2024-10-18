import os
import sys

# Get the absolute path to the 'backend' directory
backend_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

# Add the backend directory to the Python path
sys.path.insert(0, backend_dir)

# Create the database URL
SQLALCHEMY_DATABASE_URL = f"sqlite:///{os.path.join(backend_dir, 'test.db')}"
