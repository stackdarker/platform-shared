platform-shared

This repository contains shared, cross-service artifacts for the platform.
Primary focus:
- OpenAPI contracts (service API specifications)
- Shared API conventions (errors, headers, pagination)
- Shared OpenAPI components reused across services (error schemas, standard responses, etc.)

Optional later:
- A shared Java module for common DTOs/filters (not required initially)


Repository Layout

docs/
  conventions/
    errors.md       - Standard error response envelope
    headers.md      - Standard headers (auth + request correlation)
    pagination.md   - Cursor pagination contract

openapi/
  _shared/
    components/
      headers/       - Shared OpenAPI header definitions
      parameters/    - Shared OpenAPI parameters (limit, cursor, etc.)
      schemas/       - Shared OpenAPI schemas (ErrorResponse, PageMeta, etc.)
      responses/     - Shared OpenAPI responses (Error401, Error422, etc.)

  auth/v1/openapi.yaml
  infra/v1/openapi.yaml
  media/v1/openapi.yaml
  notification/v1/openapi.yaml


Rules of the Road

1) Contracts are the source of truth
- Service implementations must match the OpenAPI contract.
- Conventions in docs/conventions apply to all services unless explicitly documented otherwise.

2) Consistency requirements (all services)
- Use /v1/... for all public endpoints (major version in the URL).
- Return X-Request-Id on all responses (success and error).
- Use the shared error envelope for all non-2xx responses.
- Use cursor pagination for list endpoints (limit + cursor; return { data, page }).

3) Shared components must be reused
- If a schema/response/header is used by multiple services, put it in openapi/_shared/components and reference it via $ref.


How to Add a New Service Contract

1) Create the service folder:
openapi/<service-name>/v1/openapi.yaml

2) Include at minimum:
- openapi: 3.0.3
- info.title, info.version, info.description
- servers (local dev URL is fine)
- at least one endpoint (recommended: GET /v1/health)
- standard error responses via shared $ref components

3) Keep endpoints under /v1
- New major versions go in a new folder: openapi/<service-name>/v2/openapi.yaml
- Never break /v1 once consumers exist; introduce /v2 instead.


Versioning Strategy

There are two versions to understand:

A) API Major Version (URL + folder)
- /v1/... and openapi/<service>/v1/ represent the major version boundary.
- Breaking changes require /v2/... and openapi/<service>/v2/.

B) Contract Version (OpenAPI info.version)
- info.version follows SemVer: MAJOR.MINOR.PATCH
- MAJOR must align with the URL major (v1 => 1.x.x, v2 => 2.x.x)

SemVer rules:
- PATCH (1.0.1): doc changes, examples, descriptions, non-behavioral metadata
- MINOR (1.1.0): additive, backward compatible changes (new endpoints, new optional fields)
- MAJOR (2.0.0): breaking changes (removals, renames, type changes, stricter validation that breaks clients)

Recommended release practice (when there are consumers):
- Tag the repo when a contract version changes, e.g.:
  auth-v1.0.0
  media-v1.0.0
  notification-v1.0.0


Definition of Done for a Contract Change

A contract PR is considered complete when:
- The OpenAPI spec is valid YAML and structurally correct.
- All endpoints include consistent error responses (401/403/422/500 as applicable).
- X-Request-Id is documented on responses.
- Pagination endpoints follow the { data, page } convention.
- Changes are reflected in info.version (patch/minor/major as appropriate).


Notes

- This repo is intended to evolve as services are added.
- Avoid duplicating shared schemas across service specs; factor them into openapi/_shared/components.
