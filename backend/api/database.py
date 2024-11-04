from contextlib import contextmanager

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, declarative_base, sessionmaker
from tenacity import retry, stop_after_attempt, wait_fixed

from .config.env import SQLALCHEMY_DATABASE_URL

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


@contextmanager
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@retry(stop=stop_after_attempt(3), wait=wait_fixed(2))
def execute_query(db: Session, query):
    return db.execute(query).fetchall()


def get_db_session():
    with get_db() as session:
        yield session
