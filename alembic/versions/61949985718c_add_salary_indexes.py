"""add_salary_indexes

Revision ID: 61949985718c
Revises: 9146e9ec5f02
Create Date: 2024-11-05 20:26:22.318467

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '61949985718c'
down_revision: Union[str, None] = '9146e9ec5f02'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade():
    op.execute('CREATE EXTENSION IF NOT EXISTS pg_trgm;')
    op.create_index(
        'idx_salaries_composite_1',
        'salaries',
        ['location', 'gross_salary', 'added_date'],
        postgresql_where="verification = 'verified'"
    )
    
    op.create_index(
        'idx_salaries_composite_2',
        'salaries',
        ['work_type', 'level', 'gross_salary']
    )
    
    op.create_index(
        'idx_salaries_experience',
        'salaries',
        ['total_experience_years', 'experience_years_company']
    )
    op.create_index(
        'idx_salaries_covering',
        'salaries',
        ['id', 'location', 'gross_salary', 'net_salary', 'added_date', 'level', 'work_type']
    )
    
    op.create_index(
        'idx_salary_job_composite',
        'salary_job',
        ['salary_id', 'job_id']
    )
    
    op.create_index(
        'idx_salary_technical_stack_composite',
        'salary_technical_stack',
        ['salary_id', 'technical_stack_id']
    )
    
    op.create_index(
        'idx_company_tag_composite',
        'company_tag',
        ['company_id', 'tag_id']
    )
    
    op.execute("""
        CREATE INDEX idx_companies_name_gin ON companies 
        USING gin(name gin_trgm_ops);
    """)
    
    op.execute("""
        CREATE INDEX idx_jobs_title_gin ON jobs 
        USING gin(title gin_trgm_ops);
    """)


def downgrade():
    op.drop_index('idx_jobs_title_gin')
    op.drop_index('idx_companies_name_gin')
    op.drop_index('idx_company_tag_composite')
    op.drop_index('idx_salary_technical_stack_composite')
    op.drop_index('idx_salary_job_composite')
    op.drop_index('idx_salaries_covering')
    op.drop_index('idx_salaries_experience')
    op.drop_index('idx_salaries_composite_2')
    op.drop_index('idx_salaries_composite_1')
    op.execute('DROP EXTENSION pg_trgm;')
