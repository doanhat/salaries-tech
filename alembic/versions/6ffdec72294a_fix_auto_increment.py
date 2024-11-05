"""fix_auto_increment

Revision ID: 6ffdec72294a
Revises: 61949985718c
Create Date: 2024-11-05 23:26:32.781179

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '6ffdec72294a'
down_revision: Union[str, None] = '61949985718c'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    tables = ['salaries', 'companies', 'jobs', 'technical_stacks', 'tags']
    
    for table in tables:
        op.execute(f'CREATE SEQUENCE IF NOT EXISTS {table}_id_seq')
        op.execute(f'''
            SELECT setval('{table}_id_seq', COALESCE((SELECT MAX(id) FROM {table}), 1))
        ''')
        
        op.execute(f'''
            ALTER TABLE {table} ALTER COLUMN id 
            SET DEFAULT nextval('{table}_id_seq')
        ''')

        op.execute(f'''
            ALTER SEQUENCE {table}_id_seq OWNED BY {table}.id
        ''')


def downgrade() -> None:
    tables = ['salaries', 'companies', 'jobs', 'technical_stacks', 'tags']
    
    for table in tables:
        op.execute(f'ALTER TABLE {table} ALTER COLUMN id DROP DEFAULT')
        op.execute(f'DROP SEQUENCE IF EXISTS {table}_id_seq')
