from fastapi import APIRouter

router = APIRouter(prefix="/health", tags=["api", "v1", "health"])


@router.get("/")
async def health():
    return "OK!!!!"
