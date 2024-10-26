import os
import urllib.parse
from sqlalchemy import util
from sqlalchemy.dialects.sqlite.pysqlite import SQLiteDialect_pysqlite
import libsql_experimental as libsql

class SQLiteDialect_libsql(SQLiteDialect_pysqlite):
    driver = "libsql"

    @classmethod
    def dbapi(cls):
        return libsql

    def create_connect_args(self, url):
        database = url.database or ":memory:"
        opts = url.query.copy()
        sync_url = opts.pop("sync_url", None)
        auth_token = opts.pop("auth_token", None)
        if sync_url:
            database = sync_url
        connect_args = {"database": database, "auth_token": auth_token}
        return [], connect_args

from sqlalchemy.dialects import registry
registry.register("sqlite.libsql", "backend.sync.libsql_dialect", "SQLiteDialect_libsql")
