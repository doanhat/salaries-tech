from contextlib import contextmanager
from typing import Type, Union

from sqlalchemy import StaticPool, create_engine
from sqlalchemy.orm import DeclarativeBase, Session, declarative_base, sessionmaker
from sqlalchemy.schema import Table
from tenacity import retry, stop_after_attempt, wait_fixed

from .config.env import SQLALCHEMY_CACHE_DATABASE_URL, SQLALCHEMY_DATABASE_URL
from .config.logger import logger

engine = create_engine(SQLALCHEMY_DATABASE_URL)
cache_engine = create_engine(
    SQLALCHEMY_CACHE_DATABASE_URL,
    poolclass=StaticPool,
    pool_pre_ping=True,
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
CacheSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=cache_engine)
Base = declarative_base()


@contextmanager
def get_db(is_cache: bool = False):
    if is_cache:
        logger.info("Using cache database")
        db = CacheSessionLocal()
    else:
        logger.info("Using source database")
        db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@retry(stop=stop_after_attempt(3), wait=wait_fixed(2))
def execute_query(db: Session, query):
    return db.execute(query).fetchall()


def get_db_session(is_cache: bool = False):
    with get_db(is_cache) as session:
        yield session


def init_cache_db():
    Base.metadata.create_all(bind=cache_engine)

    with get_db() as source_db, get_db(is_cache=True) as cache_db:
        for table in Base.metadata.sorted_tables:
            try:
                result = source_db.execute(table.select())
                data = [dict(row._mapping) for row in result]

                if data:
                    cache_db.execute(table.delete())
                    cache_db.execute(table.insert(), data)
                    cache_db.commit()
                    logger.info(f"Cached {len(data)} rows from {table.name}")
            except Exception as e:
                logger.error(f"Error caching table {table.name}: {str(e)}")
                cache_db.rollback()


def refresh_cache_table(table: Union[Type[DeclarativeBase], Table]):
    with get_db() as source_db, get_db(is_cache=True) as cache_db:
        try:
            table_obj: Table
            table_name: str

            if isinstance(table, type):
                model_table = getattr(table, "__table__", None)
                if not isinstance(model_table, Table):
                    raise ValueError(f"Invalid model: {table}")
                table_obj = model_table
                table_name = getattr(table, "__tablename__", table.__name__)
            else:
                table_obj = table
                table_name = table.name

            result = source_db.execute(table_obj.select())
            data = [dict(row._mapping) for row in result]

            if data:
                cache_db.execute(table_obj.delete())
                cache_db.execute(table_obj.insert(), data)
                cache_db.commit()
                logger.info(f"Refreshed {len(data)} rows in cache table {table_name}")
        except Exception as e:
            logger.error(f"Error refreshing cache table {table_name}: {str(e)}")
            cache_db.rollback()
