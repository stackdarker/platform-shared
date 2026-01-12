Pagination Convention

This document defines the standard pagination strategy used across platform APIs.
The platform uses cursor-based pagination by default to ensure performance,
stability, and compatibility with UUID-based schemas.


PAGINATION STRATEGY
-------------------

Default: Cursor-Based Pagination

Cursor-based pagination is preferred because it:
- scales better for large datasets
- avoids inconsistent results during concurrent updates
- works naturally with UUIDs and ordered timestamps


REQUEST PARAMETERS
------------------

limit
- Type: integer
- Required: No
- Default: 20
- Maximum: 100

Controls the maximum number of items returned.

Example:
GET /v1/users?limit=50


cursor
- Type: string
- Required: No
- Description: Opaque pagination cursor returned from a previous response

Clients MUST treat the cursor as an opaque value and MUST NOT attempt
to parse or modify it.

Example:
GET /v1/users?limit=20&cursor=eyJpZCI6IjAxRj...


RESPONSE FORMAT
---------------

All paginated responses MUST follow this structure:

{
  "data": [ ... ],
  "page": {
    "limit": 20,
    "nextCursor": "opaque-string",
    "hasNext": true
  }
}


PAGE OBJECT
-----------

page.limit
- Echoes the applied limit

page.nextCursor
- Cursor for the next page
- Null if there are no more results

page.hasNext
- True if another page exists
- False otherwise

Clients SHOULD rely on hasNext instead of checking nextCursor directly.


EMPTY RESULTS
-------------

If no results exist, the response MUST be:

{
  "data": [],
  "page": {
    "limit": 20,
    "nextCursor": null,
    "hasNext": false
  }
}


SORTING RULES
-------------

- Default sorting MUST be deterministic
- Cursor generation MUST be consistent with sorting
- Sorting order MUST be documented per endpoint if not implicit

Typical defaults:
- createdAt ascending
- id ascending as a tiebreaker


OFFSET PAGINATION (EXCEPTION)
-----------------------------

Offset-based pagination (offset, page) MAY be used only for:
- admin-only tooling
- low-volume datasets
- non-user-facing APIs

If used, it MUST be explicitly documented and MUST NOT replace
cursor-based pagination for public APIs.


SUMMARY RULES
-------------

- Cursor-based pagination is the default
- Cursor values are opaque
- Responses always include data and page
- Empty lists still return a valid page object
- Limit is capped at 100

This convention applies to all platform services unless explicitly
documented otherwise.