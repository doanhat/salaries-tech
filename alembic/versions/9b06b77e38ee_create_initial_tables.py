"""Create initial tables

Revision ID: 9b06b77e38ee
Revises: b8fd849fb4ca
Create Date: 2024-10-15 19:24:50.321777

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '9b06b77e38ee'
down_revision: Union[str, None] = 'b8fd849fb4ca'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    pass
    # ### end Alembic commands ###


def downgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    pass
    # ### end Alembic commands ###
