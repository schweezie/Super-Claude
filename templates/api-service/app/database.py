from collections.abc import AsyncGenerator
from typing import Annotated

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.config import Settings, get_settings


def _make_engine(settings: Settings):
    return create_async_engine(
        settings.database_url,
        echo=settings.debug,
        pool_pre_ping=True,
    )


def _make_session_factory(settings: Settings) -> async_sessionmaker[AsyncSession]:
    engine = _make_engine(settings)
    return async_sessionmaker(engine, expire_on_commit=False)


async def get_db(
    settings: Annotated[Settings, Depends(get_settings)],
) -> AsyncGenerator[AsyncSession, None]:
    session_factory = _make_session_factory(settings)
    async with session_factory() as session:
        yield session
