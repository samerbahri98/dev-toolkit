ARG PYTHON_VERSION=3.13
ARG NODE_VERSION=22.4.1

FROM ghcr.io/astral-sh/uv:latest AS uv

FROM python:${PYTHON_VERSION}-slim-bookworm AS api
COPY --from=uv /uv /uvx /bin/
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy
ENV UV_PYTHON_DOWNLOADS=0
WORKDIR /app
RUN --mount=type=cache,id=uv,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project --no-dev
COPY . /app
RUN --mount=type=cache,id=uv,target=/root/.cache/uv \
    uv sync --locked --no-dev
ENV PATH="/app/.venv/bin:$PATH"

FROM node:${NODE_VERSION}-slim AS web
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN npm install -g pnpm
COPY . /app
WORKDIR /app
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
ENV NODE_ENV=production
RUN pnpm run -r build

FROM python:${PYTHON_VERSION}-slim-bookworm
ENV NODE_ENV=production
COPY --from=api --chown=www-data:www-data /app/.venv /app/.venv
COPY --from=api --chown=www-data:www-data /app/api /app/api
COPY --from=web --chown=www-data:www-data /app/web/build/ /app/static/
USER www-data
WORKDIR /app
EXPOSE 8000
HEALTHCHECK CMD [ "/app/.venv/bin/httpx", "http://localhost:8000/api/v1/health"  ]
ENTRYPOINT [ "/app/.venv/bin/fastapi", "run", "api/main.py" ]
