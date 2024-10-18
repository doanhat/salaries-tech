"""update company name nullable

Revision ID: f739c08376b6
Revises: 155b5bc13fa8
Create Date: 2024-10-16 19:19:09.484973

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'f739c08376b6'
down_revision: Union[str, None] = '155b5bc13fa8'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Create a new table with the desired schema
    op.create_table('companies_new',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('name', sa.String(), nullable=True),  # Changed to nullable
        sa.Column('type', sa.String(), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('name')
    )

    # Copy data from the old table to the new one
    op.execute('INSERT INTO companies_new SELECT id, name, type FROM companies')

    # Update foreign key references in the salaries table
    op.execute('UPDATE salaries SET company_id = (SELECT id FROM companies_new WHERE companies_new.id = salaries.company_id)')

    # Update foreign key references in the company_tag table
    op.execute('UPDATE company_tag SET company_id = (SELECT id FROM companies_new WHERE companies_new.id = company_tag.company_id)')

    # Drop the old table
    op.drop_table('companies')

    # Rename the new table to the original name
    op.rename_table('companies_new', 'companies')

    # Recreate the index on id
    op.create_index('ix_companies_id', 'companies', ['id'], unique=False)

    # The unique index on name will be automatically created due to the UniqueConstraint


def downgrade() -> None:
    # To revert, we'll recreate the original table structure
    op.create_table('companies_old',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('name', sa.String(), nullable=False),  # Back to not nullable
        sa.Column('type', sa.String(), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('name')
    )

    # Copy data back
    op.execute('INSERT INTO companies_old SELECT id, name, type FROM companies')

    # Update foreign key references in the salaries table
    op.execute('UPDATE salaries SET company_id = (SELECT id FROM companies_old WHERE companies_old.id = salaries.company_id)')

    # Update foreign key references in the company_tag table
    op.execute('UPDATE company_tag SET company_id = (SELECT id FROM companies_old WHERE companies_old.id = company_tag.company_id)')

    op.drop_table('companies')
    op.rename_table('companies_old', 'companies')

    # Recreate the index on id
    op.create_index('ix_companies_id', 'companies', ['id'], unique=False)

    # The unique index on name will be automatically created due to the UniqueConstraint
