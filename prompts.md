# 🚀 TestMu AI -- SDET-1 Hackathon

## 📦 Task 2 -- `prompts.md`

This document contains **every prompt used exactly as written** during
test generation.

🧠 **Primary Model:** Claude Sonnet 4.6\
🔎 **Secondary Model:** GPT-4o (comparative audit only)

------------------------------------------------------------------------

# 🔐 MODULE 1 -- LOGIN

**Model Used:** Claude Sonnet 4.6

## 📝 Prompt Used

``` text
You are a Senior SDET working on an AI-native enterprise SaaS test management platform similar to TestMu.
Generate production-grade regression test cases for the Login module.
System Context:
- Multi-tenant SaaS platform
- Role-based access control (Admin, Manager, Viewer)
- JWT-based authentication
- Session timeout after inactivity
- Account lockout after repeated failed attempts
Requirements:
- Output strictly in Gherkin format.
- Include tags: @smoke, @regression, @security where applicable.
- Cover positive, negative, edge, and security scenarios.
- Include brute-force lockout behavior.
- Include session expiration handling.
- Include tenant isolation validation.
- Include role-based redirection validation after login.
- Do not include step definitions.
- Keep scenarios deterministic and reproducible.
Output structure:
Feature:
  Background:
  Scenario:
Do not include explanations. Only output Gherkin.
```

## 📌 Model Comparison & Evaluation

Initial comparative audit was performed using **GPT-4o**. GPT validated
RBAC and JWT coverage but did not identify the absence of a secure
**Forgot Password lifecycle** in early output review.

During structured validation using **Claude Sonnet 4.6**, it was flagged
that the authentication lifecycle was incomplete without: - Reset token
expiry validation - Token reuse invalidation - Anti-enumeration
protection modeling

Claude Sonnet 4.6 surfaced this gap explicitly.\
Decision: Login suite was expanded based on Claude validation. Claude
prevented a critical authentication coverage gap.

------------------------------------------------------------------------

# 📊 MODULE 2 -- DASHBOARD

**Model Used:** Claude Sonnet 4.6

## 📝 Prompt Used

``` text
You are a Senior SDET working on an AI-native enterprise SaaS platform similar to TestMu.Generate production-grade regression test cases for the Dashboard module.System Context:- Multi-tenant SaaS platform- Role-based access control (Admin, Manager, Viewer)- Dashboard contains analytics widgets, charts, tables, and activity feeds- Data is fetched via REST APIs- Filters and sorting are applied client-side and server-side- Responsive layout must support desktop, tablet, and mobileRequirements:- Output strictly in Gherkin format.- Include tags: @smoke, @regression, @security where applicable.- Cover: - Widget loading behavior - Data accuracy validation against API response - Filter and sorting behavior - Responsive layout behavior - Permission-based widget visibility - Tenant data isolation - Error handling when APIs fail (4xx/5xx)- Include positive, negative, and edge scenarios.- Keep scenarios deterministic and reproducible.- Do not include explanations or step definitions.Output structure:Feature: Background: Scenario:
```

## 📌 Model Comparison & Evaluation

Comparative audit using **GPT-4o** confirmed general widget and role
coverage but did not detect the lack of deterministic backend-to-UI
payload validation depth.

Structured review with **Claude Sonnet 4.6** highlighted: - Missing
strict API response comparison against rendered widget data - Lack of
deterministic sorting validation logic - Absence of partial API failure
behavior modeling

Claude Sonnet 4.6 surfaced integration-level validation gaps that GPT-4o
did not identify.\
Decision: Dashboard suite strengthened based on Claude structural
analysis.

------------------------------------------------------------------------

# 🔗 MODULE 3 -- REST API

**Model Used:** Claude Sonnet 4.6

## 📝 Prompt Used

``` text
You are a Senior SDET designing API regression tests for an enterprise SaaS platform similar to TestMu.
Generate production-grade REST API test cases in Gherkin format.
System Context:
- Multi-tenant SaaS architecture
- JWT-based authentication using Authorization: Bearer <token>
- Role-based access control (Admin, Manager, Viewer)
- CRUD endpoints for Projects and Users
- Strict request and response schema validation
- Rate limiting enforced at API gateway
- JSON request/response format
Core Endpoints:
- POST   /api/projects
- GET    /api/projects/{id}
- PUT    /api/projects/{id}
- DELETE /api/projects/{id}
- POST   /api/users
- GET    /api/users/{id}
Requirements:
- Output strictly in Gherkin format.
- Include tags: @api, @regression, @security.
- Cover the following areas:
1) Auth Token Validation
   - Valid token
   - Expired token
   - Tampered token
   - Missing token
   - Token from different tenant
   - Insufficient role permissions
2) CRUD Operations
   - Successful create, read, update, delete
   - Validation errors (400)
   - Resource not found (404)
   - Idempotency behavior (where applicable)
   - Data persistence validation after update
   - Soft delete vs hard delete validation (if assumed)
3) Error Handling
   - 400 Bad Request (schema validation errors)
   - 401 Unauthorized
   - 403 Forbidden
   - 404 Not Found
   - 500 Internal Server Error
   - Clear differentiation between 401 and 403
4) Rate Limiting
   - 429 Too Many Requests
   - Retry-After header validation
   - Rate limiting per user
   - Rate limiting per IP
5) Schema Validation
   - Request payload schema validation
   - Response body schema validation
   - Required fields enforcement
   - Data type validation
   - Unexpected field rejection
   - Null value handling
6) Multi-Tenant Isolation
   - Tenant A cannot access Tenant B’s resources
   - Cross-tenant access attempt returns 403
   - Token tenant_id must match resource tenant_id
Constraints:
- Include positive, negative, and edge scenarios.
- Keep scenarios deterministic and reproducible.
- Assume:
  - 401 = invalid or expired token
  - 403 = insufficient role permission
  - 404 = resource does not exist
  - 429 = rate limit exceeded
- Include example JSON payloads where relevant.
- Do not include explanations.
- Do not include step definitions.
Output structure:
Feature:
  Background:
  Scenario:
```

## 📌 Model Comparison & Evaluation

Comparative audit using **GPT-4o** suggested adding additional patches
for: - 401 / 403 differentiation - 429 rate limiting - 500 error
containment

Structured validation using **Claude Sonnet 4.6** confirmed the existing
feature file already included: - 401, 403, 404, and 500 modeling - 429
rate limiting with header validation - Full schema validation - Complete
CRUD lifecycle - Strict tenant isolation

Claude Sonnet 4.6 correctly identified that no additional patch was
required.\
Decision: No modifications applied. Claude validation prevented
unnecessary duplication.

------------------------------------------------------------------------

