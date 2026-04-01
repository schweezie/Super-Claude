from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/health", tags=["health"])


class HealthResponse(BaseModel):
    status: str
    version: str


@router.get("", response_model=HealthResponse)
async def health_check() -> HealthResponse:
    """Returns service health status. Called by frontend at /api/backend/health."""
    return HealthResponse(status="ok", version="0.1.0")
