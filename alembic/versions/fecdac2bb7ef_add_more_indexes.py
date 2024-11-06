"""add_more_indexes

Revision ID: fecdac2bb7ef
Revises: 6ffdec72294a
Create Date: 2024-11-06 00:46:01.121360

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'fecdac2bb7ef'
down_revision: Union[str, None] = '6ffdec72294a'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("""
        CREATE INDEX idx_salaries_added_date_desc ON salaries (added_date DESC)
    """)
    
    op.execute("""
        CREATE INDEX idx_salaries_gross_salary_desc ON salaries (gross_salary DESC)
    """)
    
    op.execute("""
        CREATE INDEX idx_salaries_net_salary_desc ON salaries (net_salary DESC)
    """)

    op.create_index(
        'idx_salaries_location_salary',
        'salaries',
        ['location', 'gross_salary', 'net_salary']
    )
    
    op.create_index(
        'idx_salaries_experience_salary',
        'salaries',
        ['total_experience_years', 'gross_salary', 'net_salary']
    )


def downgrade() -> None:
    op.drop_index('idx_salaries_experience_salary')
    op.drop_index('idx_salaries_location_salary')
    op.execute('DROP INDEX IF EXISTS idx_salaries_net_salary_desc')
    op.execute('DROP INDEX IF EXISTS idx_salaries_gross_salary_desc')
    op.execute('DROP INDEX IF EXISTS idx_salaries_added_date_desc')
