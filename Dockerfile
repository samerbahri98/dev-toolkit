ARG NODE_VERSION=22.4.1
ARG POCKETBASE_VERSION=0.28.3

FROM alpine:latest AS pocketbase

ARG VERSION=0.24.4
WORKDIR /app

RUN apk add --no-cache curl unzip \
  && curl -L -o pocketbase.zip https://github.com/pocketbase/pocketbase/releases/download/v${VERSION}/pocketbase_${VERSION}_linux_amd64.zip \
  && unzip pocketbase.zip

FROM node:${NODE_VERSION}-slim AS web
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN npm install -g pnpm
COPY . /app
WORKDIR /app
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
ENV NODE_ENV=production
RUN pnpm run -r build

FROM debian:bookworm
USER www-data
WORKDIR /app
COPY --from=pocketbase --chown=www-data:www-data /app/pocketbase .
COPY --chown=www-data:www-data ./pb/ /app/pb/
COPY --from=web --chown=www-data:www-data /app/web/build /app/pb/public
EXPOSE 8080
ENTRYPOINT [ "/app/pb/entrypoint.sh" ]