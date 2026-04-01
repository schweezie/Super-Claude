from contextlib import asynccontextmanager
from typing import Annotated

from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import health
from app.config import Settings, get_settings


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: add any initialization here (e.g., connection pool warm-up)
    yield
    # Shutdown: clean up resources here


def create_app() -> FastAPI:
    settings = get_settings()

    app = FastAPI(
        title="API Service",
        version="0.1.0",
        debug=settings.debug,
        lifespan=lifespan,
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.origins_list,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(health.router)
    # Add more routers here:
    # app.include_router(users.router, prefix="/api/v1")

    return app


app = create_app()
