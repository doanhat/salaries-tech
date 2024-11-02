from unittest.mock import patch

import pytest
from fastapi import Request
from fastapi.exceptions import HTTPException

from backend.api.services.auth import verify_api_key


@pytest.mark.parametrize(
    "api_key,expected_exception",
    [
        (
            Request(
                scope={
                    "type": "http",
                    "headers": [(b"x-api-key", b"test_api_key")],
                }
            ),
            None,
        ),
        (
            Request(
                scope={
                    "type": "http",
                    "headers": [(b"x-api-key", b"wrong_api_key")],
                }
            ),
            HTTPException,
        ),
    ],
    ids=["valid_api_key", "invalid_api_key"],
)
@pytest.mark.asyncio
async def test_verify_api_key(api_key, expected_exception):
    # Should not raise an exception
    if expected_exception:
        with pytest.raises(expected_exception):
            await verify_api_key(api_key)
    else:
        assert await verify_api_key(api_key) is None
