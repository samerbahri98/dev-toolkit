from fastapi import APIRouter
from .health import router as healthRouter

router = APIRouter(tags=["api", "v1"])

router.include_router(healthRouter)
