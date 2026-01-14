# Local Ports (Development)

This document defines the canonical port assignments for local development across the
platform microservices. These ports should be treated as the source of truth for:
- OpenAPI `servers.url`
- Docker Compose mappings (platform-infra)
- Local `.env` / config defaults
- Postman/Insomnia collections

> Note: Many Windows environments already have a local PostgreSQL instance listening on 5432.
> To avoid conflicts, platform databases use 5433+ for host mappings.

---

## HTTP Services

| Service | Purpose | Base URL | Host Port |
|--------|---------|----------|----------|
| auth-service | Authentication + RBAC | http://localhost:8081 | 8081 |
| notification-service | Templates + email delivery | http://localhost:8082 | 8082 |
| media-service | Assets + upload/download URLs | http://localhost:8083 | 8083 |
| api-gateway (optional) | Unified entrypoint / routing (future) | http://localhost:8080 | 8080 |

All service APIs are versioned under `/v1/...`.

Examples:
- `GET http://localhost:8081/actuator/health`
- `POST http://localhost:8081/v1/auth/login`

---

## Databases (PostgreSQL)

Each service owns its own database to avoid cross-service coupling.

| Database | Used By | Container Port | Host Port | Default DB Name |
|---------|---------|----------------|----------|-----------------|
| auth-db | auth-service | 5432 | 5433 | auth_db |
| notification-db | notification-service | 5432 | 5434 | notification_db |
| media-db | media-service | 5432 | 5435 | media_db |

Recommended default credentials for local dev:
- Username: `*_user`
- Password: `*_pass`

Example (auth-service):
- `auth_user` / `auth_pass`

---

## Caching / Token Support

| Component | Purpose | Container Port | Host Port |
|----------|---------|----------------|----------|
| redis | caching, rate limits, token blacklist, queues | 6379 | 6379 |

---

## Object Storage (S3-compatible)

Used by `media-service` for pre-signed upload/download URLs.

| Component | Purpose | Container Port | Host Port |
|----------|---------|----------------|----------|
| minio | S3-compatible object storage API | 9000 | 9000 |
| minio-console | MinIO web console | 9001 | 9001 |

---

## Port Rules

- Do not use host port **5432** for platform DBs (commonly taken by local PostgreSQL on Windows).
- Each microservice must expose a single HTTP port (8081–8083).
- Supporting services should keep standard defaults unless conflicts exist (Redis 6379, MinIO 9000/9001).
- If a conflict occurs, update this doc first, then update Compose + OpenAPI `servers.url`.

---

## Related Conventions

- API headers: `conventions/headers.md`
- Pagination: `conventions/pagination.md`
- Error format: `conventions/errors.md`