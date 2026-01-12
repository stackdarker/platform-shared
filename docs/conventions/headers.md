API Headers Convention

This document defines the standard HTTP headers used across all platform services.
These headers ensure consistency, traceability, and interoperability between services,
gateways, and clients.


REQUIRED / STANDARD HEADERS
---------------------------

Content-Type
- Usage: Request
- Value: application/json
- Required: Yes (for requests with a body)

All APIs accept and return JSON unless explicitly stated otherwise.


Accept
- Usage: Request
- Value: application/json
- Required: Recommended

Clients should explicitly state the expected response format.


AUTHENTICATION
--------------

Authorization
- Usage: Request
- Format: Bearer <JWT>
- Required: Yes (for protected endpoints)

JWT-based authentication is used across the platform.

Example:
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

Rules:
- Access tokens MUST be short-lived
- Refresh tokens MUST NOT be sent in this header
- Services MUST return 401 Unauthorized for missing or invalid tokens
- Services MUST return 403 Forbidden when authenticated but lacking permission


REQUEST TRACING & CORRELATION
-----------------------------

X-Request-Id
- Usage: Request and Response
- Required: Yes (generated if missing)
- Format: Opaque string (UUID, ULID, etc.)

Used to correlate logs across services.

Rules:
- Clients MAY provide this header
- Services MUST propagate it to downstream calls
- Services MUST include it in all responses
- Services MUST include it in error responses
- If missing, the service MUST generate one

Example:
X-Request-Id: 01J2Q7K9RZ7M8A9R6V3G7P1D2E


IDEMPOTENCY (OPTIONAL / RESERVED)
---------------------------------

Idempotency-Key
- Usage: Request
- Required: No (but reserved for POST endpoints)
- Format: Opaque string (UUID recommended)

Used to safely retry requests that create resources (e.g. sessions, payments).

Rules:
- If supported, servers MUST return the same result for identical keys
- Duplicate keys with different payloads MUST return 409 Conflict

This header is reserved for future use even if not implemented yet.


SECURITY NOTES
--------------

- Sensitive data MUST NOT be passed via headers other than Authorization
- Internal headers (e.g. tracing, gateway metadata) must be stripped before public exposure
- Headers MUST be treated as case-insensitive per HTTP specification


SUMMARY
-------

Header             Required   Purpose
----------------------------------------------
Content-Type       Yes*       Request body format
Accept             No         Response format
Authorization      Yes**      JWT authentication
X-Request-Id       Yes        Request correlation
Idempotency-Key    No         Safe retries (reserved)

* Required when request has a body  
** Required for protected endpoints
