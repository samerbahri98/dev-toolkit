from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
from .routes.v1.router import router as v1Router
from fastapi.routing import APIRoute
from pathlib import Path
from fastapi.responses import FileResponse
import os


def custom_generate_unique_id(route: APIRoute):
    return f"{route.tags[0]}-{route.name}"


app = FastAPI(docs_url="/api/docs", openapi_url="/api/openapi.json")

app.include_router(
    prefix="/api/v1",
    router=v1Router,
    generate_unique_id_function=custom_generate_unique_id,
)

if os.getenv("NODE_ENV") == "production":
    app.mount("/_app", StaticFiles(directory="static/_app"), name="_app")
    app.mount("/favicon.png", StaticFiles(directory="static"), name="favicon")

    @app.get("/{full_path:path}", include_in_schema=False)
    async def spa_fallback(full_path: str, request: Request):
        index_path = Path("static/index.html")
        if index_path.exists():
            return FileResponse(index_path)
        return {"error": "index.html not found"}
