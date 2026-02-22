Feature: API Regression Test Suite - Projects and Users Endpoints
  As a consumer of the TestMu REST API
  I want all CRUD endpoints to behave correctly under all conditions
  So that data integrity, security, and reliability are guaranteed across all tenants

  Background:
    Given the API base URL is "https://api.testmu.io"
    And the following tenants exist:
      | tenant_id | tenant_name | status   |
      | T001      | AlphaCorp   | active   |
      | T002      | BetaCorp    | active   |
      | T003      | GammaCorp   | inactive |
    And the following users exist with valid JWT tokens:
      | email                  | role    | tenant_id | token_alias          |
      | admin@alphacorp.com    | Admin   | T001      | ADMIN_T001_TOKEN     |
      | manager@alphacorp.com  | Manager | T001      | MANAGER_T001_TOKEN   |
      | viewer@alphacorp.com   | Viewer  | T001      | VIEWER_T001_TOKEN    |
      | admin@betacorp.com     | Admin   | T002      | ADMIN_T002_TOKEN     |
      | manager@betacorp.com   | Manager | T002      | MANAGER_T002_TOKEN   |
    And the following projects exist:
      | project_id | name             | status | tenant_id |
      | P001       | Alpha Project 1  | active | T001      |
      | P002       | Alpha Project 2  | active | T001      |
      | P003       | Beta Project 1   | active | T002      |
    And the following system tokens are pre-configured:
      | token_alias            | description                                 |
      | EXPIRED_TOKEN          | JWT token with exp claim set in the past    |
      | TAMPERED_TOKEN         | JWT token with modified payload signature   |
      | MISSING_TENANT_TOKEN   | JWT token with no tenant_id claim           |
      | CROSS_TENANT_TOKEN     | ADMIN_T002_TOKEN used against T001 resources|
    And all requests use header "Content-Type: application/json"
    And all requests use header "Accept: application/json"

  # ═══════════════════════════════════════════════════════
  # SECTION 1: AUTH TOKEN VALIDATION
  # ═══════════════════════════════════════════════════════

  # ─────────────────────────────────────────────
  # 1.1 Valid Token
  # ─────────────────────────────────────────────

  @api @regression
  Scenario: Valid Admin token grants access to GET /api/projects/{id}
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a GET request to "/api/projects/P001" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 200
    And the response body should contain "project_id" with value "P001"

  @api @regression
  Scenario: Valid Manager token grants access to GET /api/projects/{id}
    Given I have a valid JWT token "MANAGER_T001_TOKEN"
    When I send a GET request to "/api/projects/P001" with header "Authorization: Bearer MANAGER_T001_TOKEN"
    Then the response status should be 200
    And the response body should contain "project_id" with value "P001"

  @api @regression
  Scenario: Valid Viewer token grants read access to GET /api/projects/{id}
    Given I have a valid JWT token "VIEWER_T001_TOKEN"
    When I send a GET request to "/api/projects/P001" with header "Authorization: Bearer VIEWER_T001_TOKEN"
    Then the response status should be 200
    And the response body should contain "project_id" with value "P001"

  # ─────────────────────────────────────────────
  # 1.2 Expired Token
  # ─────────────────────────────────────────────

  @api @regression @security
  Scenario: Expired JWT token returns 401 on GET /api/projects/{id}
    Given I have an expired JWT token "EXPIRED_TOKEN"
    When I send a GET request to "/api/projects/P001" with header "Authorization: Bearer EXPIRED_TOKEN"
    Then the response status should be 401
    And the response body should match the schema:
      """
      {
        "error": "string",
        "message": "string",
        "status": 401
      }
      """
    And the response body field "error" should equal "Unauthorized"
    And the response body field "message" should equal "Token has expired. Please authenticate again."

  @api @regression @security
  Scenario: Expired JWT token returns 401 on POST /api/projects
    Given I have an expired JWT token "EXPIRED_TOKEN"
    When I send a POST request to "/api/projects" with header "Authorization: Bearer EXPIRED_TOKEN" and body:
      """
      {
        "name": "New Project",
        "description": "A test project",
        "status": "active"
      }
      """
    Then the response status should be 401
    And the response body field "error" should equal "Unauthorized"

  # ─────────────────────────────────────────────
  # 1.3 Tampered Token
  # ─────────────────────────────────────────────

  @api @regression @security
  Scenario: Tampered JWT token returns 401 on GET /api/projects/{id}
    Given I have a tampered JWT token "TAMPERED_TOKEN" with a modified signature
    When I send a GET request to "/api/projects/P001" with header "Authorization: Bearer TAMPERED_TOKEN"
    Then the response status should be 401
    And the response body field "error" should equal "Unauthorized"
    And the response body field "message" should equal "Token signature verification failed."

  @api @regression @security
  Scenario: Tampered JWT token with modified role claim returns 401
    Given I have a JWT token for "viewer@alphacorp.com" with the role claim manually changed to "Admin"
    When I send a DELETE request to "/api/projects/P001" with the tampered token
    Then the response status should be 401
    And the response body field "message" should equal "Token signature verification failed."

  @api @regression @security
  Scenario: Tampered JWT token with modified tenant_id claim returns 401
    Given I have a JWT token for "admin@alphacorp.com" with the tenant_id claim changed to "T002"
    When I send a GET request to "/api/projects/P003" with the tampered token
    Then the response status should be 401
    And the response body field "message" should equal "Token signature verification failed."

  # ─────────────────────────────────────────────
  # 1.4 Missing Token
  # ─────────────────────────────────────────────

  @api @regression @security
  Scenario: Missing Authorization header returns 401 on GET /api/projects/{id}
    Given I do not include an Authorization header
    When I send a GET request to "/api/projects/P001"
    Then the response status should be 401
    And the response body field "error" should equal "Unauthorized"
    And the response body field "message" should equal "Authorization token is missing."

  @api @regression @security
  Scenario: Missing Authorization header returns 401 on POST /api/projects
    Given I do not include an Authorization header
    When I send a POST request to "/api/projects" with body:
      """
      {
        "name": "New Project",
        "description": "A test project",
        "status": "active"
      }
      """
    Then the response status should be 401
    And the response body field "error" should equal "Unauthorized"

  @api @regression @security
  Scenario: Empty Authorization header value returns 401
    Given I include the header "Authorization: " with an empty value
    When I send a GET request to "/api/projects/P001"
    Then the response status should be 401
    And the response body field "message" should equal "Authorization token is missing."

  @api @regression @security
  Scenario: Malformed Authorization header scheme returns 401
    Given I include the header "Authorization: Basic ADMIN_T001_TOKEN"
    When I send a GET request to "/api/projects/P001"
    Then the response status should be 401
    And the response body field "message" should equal "Invalid token scheme. Use Bearer authentication."

  # ─────────────────────────────────────────────
  # 1.5 Token From Different Tenant
  # ─────────────────────────────────────────────

  @api @regression @security
  Scenario: Admin from Tenant B cannot read Tenant A's project - returns 403
    Given I have a valid JWT token "ADMIN_T002_TOKEN" for tenant "T002"
    When I send a GET request to "/api/projects/P001" with header "Authorization: Bearer ADMIN_T002_TOKEN"
    Then the response status should be 403
    And the response body field "error" should equal "Forbidden"
    And the response body field "message" should equal "Access denied: cross-tenant access is not permitted."

  @api @regression @security
  Scenario: Admin from Tenant B cannot update Tenant A's project - returns 403
    Given I have a valid JWT token "ADMIN_T002_TOKEN" for tenant "T002"
    When I send a PUT request to "/api/projects/P001" with header "Authorization: Bearer ADMIN_T002_TOKEN" and body:
      """
      {
        "name": "Hijacked Project",
        "status": "active"
      }
      """
    Then the response status should be 403
    And the response body field "error" should equal "Forbidden"

  @api @regression @security
  Scenario: Admin from Tenant B cannot delete Tenant A's project - returns 403
    Given I have a valid JWT token "ADMIN_T002_TOKEN" for tenant "T002"
    When I send a DELETE request to "/api/projects/P001" with header "Authorization: Bearer ADMIN_T002_TOKEN"
    Then the response status should be 403
    And the response body field "error" should equal "Forbidden"

  @api @regression @security
  Scenario: Cross-tenant project access does not reveal resource existence via 404
    Given I have a valid JWT token "ADMIN_T002_TOKEN" for tenant "T002"
    When I send a GET request to "/api/projects/P001" with header "Authorization: Bearer ADMIN_T002_TOKEN"
    Then the response status should be 403
    And the response body should not contain any information about the existence of project "P001"

  # ─────────────────────────────────────────────
  # 1.6 Insufficient Role Permissions
  # ─────────────────────────────────────────────

  @api @regression @security
  Scenario: Viewer token cannot create a project - returns 403
    Given I have a valid JWT token "VIEWER_T001_TOKEN"
    When I send a POST request to "/api/projects" with header "Authorization: Bearer VIEWER_T001_TOKEN" and body:
      """
      {
        "name": "Viewer Project",
        "description": "Should be rejected",
        "status": "active"
      }
      """
    Then the response status should be 403
    And the response body field "error" should equal "Forbidden"
    And the response body field "message" should equal "Access denied: insufficient role permissions."

  @api @regression @security
  Scenario: Viewer token cannot update a project - returns 403
    Given I have a valid JWT token "VIEWER_T001_TOKEN"
    When I send a PUT request to "/api/projects/P001" with header "Authorization: Bearer VIEWER_T001_TOKEN" and body:
      """
      {
        "name": "Updated by Viewer",
        "status": "active"
      }
      """
    Then the response status should be 403
    And the response body field "error" should equal "Forbidden"

  @api @regression @security
  Scenario: Viewer token cannot delete a project - returns 403
    Given I have a valid JWT token "VIEWER_T001_TOKEN"
    When I send a DELETE request to "/api/projects/P001" with header "Authorization: Bearer VIEWER_T001_TOKEN"
    Then the response status should be 403
    And the response body field "error" should equal "Forbidden"

  @api @regression @security
  Scenario: Manager token cannot create a user - returns 403
    Given I have a valid JWT token "MANAGER_T001_TOKEN"
    When I send a POST request to "/api/users" with header "Authorization: Bearer MANAGER_T001_TOKEN" and body:
      """
      {
        "email": "newuser@alphacorp.com",
        "role": "Viewer",
        "tenant_id": "T001"
      }
      """
    Then the response status should be 403
    And the response body field "error" should equal "Forbidden"

  @api @regression @security
  Scenario: Viewer token cannot retrieve another user's profile - returns 403
    Given I have a valid JWT token "VIEWER_T001_TOKEN"
    When I send a GET request to "/api/users/U002" with header "Authorization: Bearer VIEWER_T001_TOKEN"
    Then the response status should be 403
    And the response body field "error" should equal "Forbidden"

  @api @regression @security
  Scenario: 401 and 403 responses are clearly differentiated
    Given I have an expired JWT token "EXPIRED_TOKEN"
    When I send a GET request to "/api/projects/P001" with header "Authorization: Bearer EXPIRED_TOKEN"
    Then the response status should be 401
    And the response body field "status" should equal 401
    Given I have a valid JWT token "VIEWER_T001_TOKEN"
    When I send a DELETE request to "/api/projects/P001" with header "Authorization: Bearer VIEWER_T001_TOKEN"
    Then the response status should be 403
    And the response body field "status" should equal 403

  # ═══════════════════════════════════════════════════════
  # SECTION 2: CRUD OPERATIONS - PROJECTS
  # ═══════════════════════════════════════════════════════

  # ─────────────────────────────────────────────
  # 2.1 POST /api/projects - Create
  # ─────────────────────────────────────────────

  @api @regression
  Scenario: Admin successfully creates a new project
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/projects" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "name": "Regression Suite Alpha",
        "description": "End-to-end regression suite for Alpha module",
        "status": "active",
        "tags": ["regression", "alpha"]
      }
      """
    Then the response status should be 201
    And the response body should match the schema:
      """
      {
        "project_id": "string",
        "name": "string",
        "description": "string",
        "status": "string",
        "tags": "array",
        "tenant_id": "string",
        "created_by": "string",
        "created_at": "string",
        "updated_at": "string"
      }
      """
    And the response body field "name" should equal "Regression Suite Alpha"
    And the response body field "status" should equal "active"
    And the response body field "tenant_id" should equal "T001"
    And the response body field "created_by" should equal "admin@alphacorp.com"
    And the response body field "project_id" should not be null
    And the response header "Location" should equal "/api/projects/{newly_created_project_id}"

  @api @regression
  Scenario: Creating a project assigns a unique project_id
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send two consecutive POST requests to "/api/projects" with identical payloads:
      """
      {
        "name": "Duplicate Name Project",
        "description": "Testing unique ID generation",
        "status": "active"
      }
      """
    Then both responses should have status 201
    And the "project_id" in the first response should differ from the "project_id" in the second response

  @api @regression
  Scenario: Creating a project automatically scopes it to the authenticated user's tenant
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/projects" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "name": "Auto-Tenant Project",
        "description": "Should be scoped to T001",
        "status": "active"
      }
      """
    Then the response status should be 201
    And the response body field "tenant_id" should equal "T001"

  @api @regression
  Scenario: Admin from Tenant A cannot create a project with tenant_id set to Tenant B
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/projects" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "name": "Cross-Tenant Injection",
        "description": "Attempting tenant injection",
        "status": "active",
        "tenant_id": "T002"
      }
      """
    Then the response status should be 201
    And the response body field "tenant_id" should equal "T001"
    And the provided tenant_id "T002" should be silently ignored

  # ─────────────────────────────────────────────
  # 2.2 GET /api/projects/{id} - Read
  # ─────────────────────────────────────────────

  @api @regression
  Scenario: Admin successfully retrieves an existing project by ID
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a GET request to "/api/projects/P001" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 200
    And the response body should match the schema:
      """
      {
        "project_id": "string",
        "name": "string",
        "description": "string",
        "status": "string",
        "tenant_id": "string",
        "created_by": "string",
        "created_at": "string",
        "updated_at": "string"
      }
      """
    And the response body field "project_id" should equal "P001"
    And the response body field "tenant_id" should equal "T001"

  @api @regression
  Scenario: GET /api/projects/{id} returns 404 for a non-existent project ID
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a GET request to "/api/projects/NON_EXISTENT_ID" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 404
    And the response body should match the schema:
      """
      {
        "error": "string",
        "message": "string",
        "status": 404
      }
      """
    And the response body field "error" should equal "Not Found"
    And the response body field "message" should equal "Project with ID 'NON_EXISTENT_ID' was not found."

  @api @regression
  Scenario: GET /api/projects/{id} returns 404 for a project belonging to a different tenant
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a GET request to "/api/projects/P003" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 403
    And the response body field "error" should equal "Forbidden"

  @api @regression
  Scenario: GET response includes ETag header for cache validation
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a GET request to "/api/projects/P001" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 200
    And the response headers should include an "ETag" header with a non-empty value

  # ─────────────────────────────────────────────
  # 2.3 PUT /api/projects/{id} - Update
  # ─────────────────────────────────────────────

  @api @regression
  Scenario: Admin successfully updates an existing project
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a PUT request to "/api/projects/P001" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "name": "Alpha Project 1 - Updated",
        "description": "Updated description for regression",
        "status": "inactive"
      }
      """
    Then the response status should be 200
    And the response body field "name" should equal "Alpha Project 1 - Updated"
    And the response body field "description" should equal "Updated description for regression"
    And the response body field "status" should equal "inactive"
    And the response body field "project_id" should equal "P001"
    And the response body field "updated_at" should be a timestamp later than "created_at"

  @api @regression
  Scenario: Data persists correctly after a PUT update is applied
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    And I successfully update project "P001" with name "Persisted Name" via PUT
    When I send a GET request to "/api/projects/P001" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 200
    And the response body field "name" should equal "Persisted Name"

  @api @regression
  Scenario: PUT /api/projects/{id} returns 404 for a non-existent project
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a PUT request to "/api/projects/NON_EXISTENT_ID" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "name": "Ghost Project",
        "status": "active"
      }
      """
    Then the response status should be 404
    And the response body field "error" should equal "Not Found"

  @api @regression
  Scenario: PUT request cannot change the project's tenant_id
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a PUT request to "/api/projects/P001" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "name": "Alpha Project 1",
        "status": "active",
        "tenant_id": "T002"
      }
      """
    Then the response status should be 200
    And the response body field "tenant_id" should equal "T001"
    And the attempt to change "tenant_id" should be silently ignored

  @api @regression
  Scenario: PUT request cannot change the project_id field
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a PUT request to "/api/projects/P001" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "project_id": "P999",
        "name": "Alpha Project 1",
        "status": "active"
      }
      """
    Then the response status should be 200
    And the response body field "project_id" should equal "P001"

  @api @regression
  Scenario: Idempotent PUT request with same payload returns 200 and unchanged data
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    And project "P001" currently has name "Alpha Project 1"
    When I send a PUT request to "/api/projects/P001" twice with identical payload:
      """
      {
        "name": "Alpha Project 1",
        "status": "active"
      }
      """
    Then both responses should have status 200
    And the response body field "name" should equal "Alpha Project 1" in both responses

  # ─────────────────────────────────────────────
  # 2.4 DELETE /api/projects/{id} - Delete
  # ─────────────────────────────────────────────

  @api @regression
  Scenario: Admin successfully soft-deletes a project
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a DELETE request to "/api/projects/P002" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 200
    And the response body should contain:
      """
      {
        "message": "Project successfully deleted.",
        "project_id": "P002",
        "deleted_at": "<timestamp>"
      }
      """

  @api @regression
  Scenario: Soft-deleted project is no longer accessible via GET
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    And project "P002" has been soft-deleted
    When I send a GET request to "/api/projects/P002" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 404
    And the response body field "message" should equal "Project with ID 'P002' was not found."

  @api @regression
  Scenario: Soft-deleted project cannot be updated via PUT
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    And project "P002" has been soft-deleted
    When I send a PUT request to "/api/projects/P002" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "name": "Attempting update on deleted project",
        "status": "active"
      }
      """
    Then the response status should be 404

  @api @regression
  Scenario: DELETE /api/projects/{id} returns 404 for a non-existent project
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a DELETE request to "/api/projects/NON_EXISTENT_ID" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 404
    And the response body field "error" should equal "Not Found"

  @api @regression
  Scenario: Deleting the same project twice returns 404 on the second attempt
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    And I successfully delete project "P002" via DELETE
    When I send a DELETE request to "/api/projects/P002" again with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 404
    And the response body field "message" should equal "Project with ID 'P002' was not found."

  # ═══════════════════════════════════════════════════════
  # SECTION 2B: CRUD OPERATIONS - USERS
  # ═══════════════════════════════════════════════════════

  # ─────────────────────────────────────────────
  # POST /api/users - Create
  # ─────────────────────────────────────────────

  @api @regression
  Scenario: Admin successfully creates a new user
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/users" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "email": "newviewer@alphacorp.com",
        "first_name": "Jane",
        "last_name": "Doe",
        "role": "Viewer",
        "tenant_id": "T001"
      }
      """
    Then the response status should be 201
    And the response body should match the schema:
      """
      {
        "user_id": "string",
        "email": "string",
        "first_name": "string",
        "last_name": "string",
        "role": "string",
        "tenant_id": "string",
        "status": "string",
        "created_at": "string"
      }
      """
    And the response body field "email" should equal "newviewer@alphacorp.com"
    And the response body field "role" should equal "Viewer"
    And the response body field "tenant_id" should equal "T001"
    And the response body should not contain field "password"
    And the response body should not contain field "password_hash"

  @api @regression
  Scenario: Creating a user with a duplicate email within the same tenant returns 409
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    And user "viewer@alphacorp.com" already exists in tenant "T001"
    When I send a POST request to "/api/users" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "email": "viewer@alphacorp.com",
        "first_name": "Duplicate",
        "last_name": "User",
        "role": "Viewer"
      }
      """
    Then the response status should be 409
    And the response body field "error" should equal "Conflict"
    And the response body field "message" should equal "A user with email 'viewer@alphacorp.com' already exists in this tenant."

  @api @regression
  Scenario: Admin cannot assign an invalid role when creating a user
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/users" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "email": "badrole@alphacorp.com",
        "first_name": "Bad",
        "last_name": "Role",
        "role": "SuperAdmin"
      }
      """
    Then the response status should be 400
    And the response body field "error" should equal "Bad Request"
    And the response body field "details" should contain "role must be one of: Admin, Manager, Viewer"

  # ─────────────────────────────────────────────
  # GET /api/users/{id} - Read
  # ─────────────────────────────────────────────

  @api @regression
  Scenario: Admin successfully retrieves a user by ID
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    And user "U001" exists with email "viewer@alphacorp.com" in tenant "T001"
    When I send a GET request to "/api/users/U001" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 200
    And the response body field "user_id" should equal "U001"
    And the response body field "email" should equal "viewer@alphacorp.com"
    And the response body field "tenant_id" should equal "T001"
    And the response body should not contain field "password"
    And the response body should not contain field "password_hash"

  @api @regression
  Scenario: GET /api/users/{id} returns 404 for a non-existent user ID
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a GET request to "/api/users/NON_EXISTENT_USER" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 404
    And the response body field "error" should equal "Not Found"
    And the response body field "message" should equal "User with ID 'NON_EXISTENT_USER' was not found."

  @api @regression @security
  Scenario: Admin from Tenant B cannot retrieve a user belonging to Tenant A
    Given I have a valid JWT token "ADMIN_T002_TOKEN"
    And user "U001" exists in tenant "T001"
    When I send a GET request to "/api/users/U001" with header "Authorization: Bearer ADMIN_T002_TOKEN"
    Then the response status should be 403
    And the response body field "error" should equal "Forbidden"

  # ═══════════════════════════════════════════════════════
  # SECTION 3: ERROR HANDLING
  # ═══════════════════════════════════════════════════════

  @api @regression
  Scenario: 400 Bad Request - POST /api/projects with missing required field "name"
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/projects" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "description": "No name provided",
        "status": "active"
      }
      """
    Then the response status should be 400
    And the response body should match the schema:
      """
      {
        "error": "string",
        "message": "string",
        "status": 400,
        "details": "array"
      }
      """
    And the response body field "error" should equal "Bad Request"
    And the response body field "details" should contain an entry with field "name" and message "name is required"

  @api @regression
  Scenario: 400 Bad Request - POST /api/projects with invalid status value
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/projects" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "name": "Invalid Status Project",
        "description": "Testing invalid status",
        "status": "pending_approval"
      }
      """
    Then the response status should be 400
    And the response body field "details" should contain "status must be one of: active, inactive, archived"

  @api @regression
  Scenario: 400 Bad Request - POST /api/users with invalid email format
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/users" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "email": "not-a-valid-email",
        "first_name": "Test",
        "last_name": "User",
        "role": "Viewer"
      }
      """
    Then the response status should be 400
    And the response body field "details" should contain "email must be a valid email address"

  @api @regression
  Scenario: 400 Bad Request - PUT /api/projects/{id} with empty request body
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a PUT request to "/api/projects/P001" with header "Authorization: Bearer ADMIN_T001_TOKEN" and an empty body "{}"
    Then the response status should be 400
    And the response body field "message" should equal "Request body must contain at least one updatable field."

  @api @regression
  Scenario: 500 Internal Server Error response does not expose stack trace or internal details
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    And the server is configured to simulate an internal error on "GET /api/projects/TRIGGER_500"
    When I send a GET request to "/api/projects/TRIGGER_500" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 500
    And the response body should match the schema:
      """
      {
        "error": "string",
        "message": "string",
        "status": 500,
        "trace_id": "string"
      }
      """
    And the response body field "error" should equal "Internal Server Error"
    And the response body field "message" should equal "An unexpected error occurred. Please contact support with trace_id."
    And the response body should not contain any stack trace information
    And the response body should not contain any file system paths
    And the response body should not contain any database query strings

  @api @regression
  Scenario: Error response body is always valid JSON even on 500 errors
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    And the server is configured to simulate an internal error on "GET /api/projects/TRIGGER_500"
    When I send a GET request to "/api/projects/TRIGGER_500"
    Then the response status should be 500
    And the response body should be parseable as valid JSON
    And the response header "Content-Type" should equal "application/json"

  # ═══════════════════════════════════════════════════════
  # SECTION 4: RATE LIMITING
  # ═══════════════════════════════════════════════════════

  @api @regression @security
  Scenario: 429 Too Many Requests is returned when per-user rate limit is exceeded
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    And the per-user rate limit is configured to 100 requests per minute
    When I send 101 consecutive GET requests to "/api/projects/P001" with "ADMIN_T001_TOKEN"
    Then the 101st response status should be 429
    And the response body should match the schema:
      """
      {
        "error": "string",
        "message": "string",
        "status": 429,
        "retry_after": "integer"
      }
      """
    And the response body field "error" should equal "Too Many Requests"
    And the response header "Retry-After" should be present
    And the response header "Retry-After" should contain an integer value greater than 0
    And the response header "X-RateLimit-Limit" should equal "100"
    And the response header "X-RateLimit-Remaining" should equal "0"

  @api @regression @security
  Scenario: Retry-After header value matches the body retry_after field on 429
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    And the rate limit has been exceeded for "ADMIN_T001_TOKEN"
    When I send a GET request to "/api/projects/P001"
    Then the response status should be 429
    And the "Retry-After" header value should equal the response body field "retry_after"

  @api @regression @security
  Scenario: Rate limit is enforced per-user and does not affect other users
    Given user "admin@alphacorp.com" with token "ADMIN_T001_TOKEN" has exceeded the rate limit
    When I send a GET request to "/api/projects/P001" with token "MANAGER_T001_TOKEN"
    Then the response status should be 200
    And the manager's request should not be rate-limited due to the admin's usage

  @api @regression @security
  Scenario: Rate limit is enforced per-IP and applies across different user tokens from the same IP
    Given I am sending requests from IP "192.168.1.100"
    And the per-IP rate limit is configured to 200 requests per minute
    When I send 201 consecutive requests from IP "192.168.1.100" alternating between "ADMIN_T001_TOKEN" and "MANAGER_T001_TOKEN"
    Then the 201st response status should be 429
    And the response header "X-RateLimit-Policy" should equal "ip"

  @api @regression @security
  Scenario: Requests succeed again after the rate limit window resets
    Given the rate limit has been exceeded for "ADMIN_T001_TOKEN"
    And I wait for the rate limit window to reset as specified in the "Retry-After" header
    When I send a GET request to "/api/projects/P001" with token "ADMIN_T001_TOKEN"
    Then the response status should be 200
    And the response header "X-RateLimit-Remaining" should be greater than 0

  @api @regression
  Scenario: Rate limit headers are present on every successful response
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a GET request to "/api/projects/P001" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 200
    And the response headers should include "X-RateLimit-Limit"
    And the response headers should include "X-RateLimit-Remaining"
    And the response headers should include "X-RateLimit-Reset"

  # ═══════════════════════════════════════════════════════
  # SECTION 5: SCHEMA VALIDATION
  # ═══════════════════════════════════════════════════════

  # ─────────────────────────────────────────────
  # 5.1 Request Payload Schema Validation
  # ─────────────────────────────────────────────

  @api @regression
  Scenario: POST /api/projects rejects request with wrong data type for "name" field
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/projects" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "name": 12345,
        "description": "Name is a number",
        "status": "active"
      }
      """
    Then the response status should be 400
    And the response body field "details" should contain "name must be of type string"

  @api @regression
  Scenario: POST /api/projects rejects request with wrong data type for "tags" field
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/projects" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "name": "Type Test Project",
        "description": "Tags is a string instead of array",
        "status": "active",
        "tags": "regression"
      }
      """
    Then the response status should be 400
    And the response body field "details" should contain "tags must be of type array"

  @api @regression
  Scenario: POST /api/projects rejects request with unexpected additional fields
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/projects" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "name": "Extra Field Project",
        "description": "Testing additionalProperties",
        "status": "active",
        "internal_score": 99,
        "is_premium": true
      }
      """
    Then the response status should be 400
    And the response body field "details" should contain "Additional properties are not allowed: internal_score, is_premium"

  @api @regression
  Scenario: POST /api/projects handles null value for required field "name"
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/projects" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "name": null,
        "description": "Name is null",
        "status": "active"
      }
      """
    Then the response status should be 400
    And the response body field "details" should contain "name must not be null"

  @api @regression
  Scenario: POST /api/projects handles null value for optional field "description" gracefully
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/projects" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "name": "Null Description Project",
        "description": null,
        "status": "active"
      }
      """
    Then the response status should be 201
    And the response body field "description" should be null or absent

  @api @regression
  Scenario: POST /api/projects rejects request with "name" field exceeding maximum length
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/projects" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body containing "name" as a string of 256 characters
    Then the response status should be 400
    And the response body field "details" should contain "name must not exceed 255 characters"

  @api @regression
  Scenario: POST /api/projects rejects request with "name" field as an empty string
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/projects" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "name": "",
        "description": "Empty name",
        "status": "active"
      }
      """
    Then the response status should be 400
    And the response body field "details" should contain "name must not be empty"

  @api @regression
  Scenario: POST /api/projects rejects a non-JSON content type
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/projects" with header "Content-Type: text/plain" and plain text body "name=TestProject"
    Then the response status should be 415
    And the response body field "error" should equal "Unsupported Media Type"
    And the response body field "message" should equal "Content-Type must be application/json."

  # ─────────────────────────────────────────────
  # 5.2 Response Body Schema Validation
  # ─────────────────────────────────────────────

  @api @regression
  Scenario: POST /api/projects response schema contains all expected fields
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/projects" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "name": "Schema Validation Project",
        "description": "Verifying response schema",
        "status": "active"
      }
      """
    Then the response status should be 201
    And the response body must contain all of the following fields:
      | field_name  | type    | nullable |
      | project_id  | string  | false    |
      | name        | string  | false    |
      | description | string  | true     |
      | status      | string  | false    |
      | tenant_id   | string  | false    |
      | created_by  | string  | false    |
      | created_at  | string  | false    |
      | updated_at  | string  | false    |
    And the response body should not contain fields:
      | field_name     |
      | password       |
      | password_hash  |
      | internal_score |
      | __v            |

  @api @regression
  Scenario: GET /api/projects/{id} response body "created_at" and "updated_at" are valid ISO 8601 timestamps
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a GET request to "/api/projects/P001" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 200
    And the response body field "created_at" should match the ISO 8601 format "YYYY-MM-DDTHH:mm:ss.sssZ"
    And the response body field "updated_at" should match the ISO 8601 format "YYYY-MM-DDTHH:mm:ss.sssZ"

  @api @regression
  Scenario: Error responses always include "error", "message", and "status" fields
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a GET request to "/api/projects/NON_EXISTENT_ID"
    Then the response status should be 404
    And the response body field "error" should be of type string and not empty
    And the response body field "message" should be of type string and not empty
    And the response body field "status" should be of type integer and equal 404

  @api @regression
  Scenario: POST /api/projects response Content-Type header is application/json
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/projects" with a valid payload
    Then the response header "Content-Type" should equal "application/json; charset=utf-8"

  @api @regression
  Scenario: GET /api/users/{id} response does not include sensitive fields
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    And user "U001" exists in tenant "T001"
    When I send a GET request to "/api/users/U001" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 200
    And the response body should not contain field "password"
    And the response body should not contain field "password_hash"
    And the response body should not contain field "salt"
    And the response body should not contain field "secret_token"

  # ═══════════════════════════════════════════════════════
  # SECTION 6: MULTI-TENANT ISOLATION
  # ═══════════════════════════════════════════════════════

  @api @regression @security
  Scenario: Tenant A Admin cannot list projects belonging to Tenant B
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a GET request to "/api/projects?tenant_id=T002" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 200
    And the response body "projects" array should contain only projects with tenant_id "T001"
    And the response body "projects" array should not contain any project with tenant_id "T002"

  @api @regression @security
  Scenario: Tenant A Admin cannot access Tenant B's project by injecting tenant_id as query parameter
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a GET request to "/api/projects/P003?tenant_id=T002" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 403
    And the response body field "error" should equal "Forbidden"

  @api @regression @security
  Scenario: Tenant A Admin cannot access Tenant B's project by injecting tenant_id in request header
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a GET request to "/api/projects/P003" with headers:
      | header-name    | header-value |
      | Authorization  | Bearer ADMIN_T001_TOKEN |
      | X-Tenant-ID    | T002         |
    Then the response status should be 403
    And the injected "X-Tenant-ID" header should be ignored

  @api @regression @security
  Scenario: Tenant A Admin cannot update a project belonging to Tenant B
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a PUT request to "/api/projects/P003" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "name": "Cross-Tenant Update Attempt"
      }
      """
    Then the response status should be 403
    And the response body field "error" should equal "Forbidden"

  @api @regression @security
  Scenario: Tenant A Admin cannot delete a project belonging to Tenant B
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a DELETE request to "/api/projects/P003" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 403
    And the response body field "error" should equal "Forbidden"

  @api @regression @security
  Scenario: JWT token tenant_id claim is always authoritative over request body tenant_id
    Given I have a valid JWT token "ADMIN_T001_TOKEN" with tenant_id "T001"
    When I send a POST request to "/api/projects" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "name": "Tenant Injection Project",
        "description": "Attempting to create in T002",
        "status": "active",
        "tenant_id": "T002"
      }
      """
    Then the response status should be 201
    And the response body field "tenant_id" should equal "T001"
    And the resource should be stored in the database with tenant_id "T001"
    And no resource should be created in the database with tenant_id "T002"

  @api @regression @security
  Scenario: Cross-tenant access attempt is logged as a security event
    Given I have a valid JWT token "ADMIN_T002_TOKEN" for tenant "T002"
    When I send a GET request to "/api/projects/P001" with header "Authorization: Bearer ADMIN_T002_TOKEN"
    Then the response status should be 403
    And a security audit log entry should be created with:
      | field         | value                                |
      | event_type    | CROSS_TENANT_ACCESS_ATTEMPT          |
      | actor_email   | admin@betacorp.com                   |
      | actor_tenant  | T002                                 |
      | resource_id   | P001                                 |
      | resource_tenant | T001                               |
      | outcome       | DENIED                               |

  @api @regression @security
  Scenario: User from Tenant A cannot create a user in Tenant B via the users endpoint
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/users" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "email": "injecteduser@betacorp.com",
        "first_name": "Injected",
        "last_name": "User",
        "role": "Viewer",
        "tenant_id": "T002"
      }
      """
    Then the response status should be 201
    And the response body field "tenant_id" should equal "T001"
    And no user should be created in the database with tenant_id "T002"

  # ═══════════════════════════════════════════════════════
  # SECTION 7: EDGE SCENARIOS
  # ═══════════════════════════════════════════════════════

  @api @regression
  Scenario: GET /api/projects/{id} with a valid UUID format but non-existent ID returns 404
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a GET request to "/api/projects/00000000-0000-0000-0000-000000000000" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 404
    And the response body field "error" should equal "Not Found"

  @api @regression
  Scenario: GET /api/projects/{id} with a SQL injection string in the path returns 400
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a GET request to "/api/projects/' OR '1'='1" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 400
    And the response body field "details" should contain "project_id contains invalid characters"
    And the response should not return any project data

  @api @regression
  Scenario: GET /api/projects/{id} with an excessively long project ID returns 400
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a GET request to "/api/projects/{id_of_1000_characters}" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 400
    And the response body field "details" should contain "project_id must not exceed the maximum allowed length"

  @api @regression
  Scenario: POST /api/projects with an extremely large payload returns 413
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/projects" with a payload exceeding 10MB in size
    Then the response status should be 413
    And the response body field "error" should equal "Payload Too Large"
    And the response body field "message" should equal "Request payload must not exceed 1MB."

  @api @regression
  Scenario: POST /api/projects with special characters in "name" field is handled correctly
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/projects" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "name": "Project <Alpha> & \"Beta\" / 'Gamma'",
        "description": "Testing special characters",
        "status": "active"
      }
      """
    Then the response status should be 201
    And the response body field "name" should equal "Project <Alpha> & \"Beta\" / 'Gamma'" with proper encoding

  @api @regression
  Scenario: POST /api/projects with Unicode characters in "name" field is handled correctly
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a POST request to "/api/projects" with header "Authorization: Bearer ADMIN_T001_TOKEN" and body:
      """
      {
        "name": "プロジェクト Alpha 🚀",
        "description": "Unicode name test",
        "status": "active"
      }
      """
    Then the response status should be 201
    And the response body field "name" should equal "プロジェクト Alpha 🚀"

  @api @regression
  Scenario: Concurrent PUT requests to the same project do not result in data corruption
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send 10 simultaneous PUT requests to "/api/projects/P001" each with a different "name" value
    Then all responses should return status 200
    And a subsequent GET request to "/api/projects/P001" should return exactly one of the submitted "name" values
    And no partial or corrupted data should be present in the response

  @api @regression
  Scenario: API responses include a unique trace_id header for every request
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send two consecutive GET requests to "/api/projects/P001"
    Then each response should include an "X-Trace-ID" header
    And the "X-Trace-ID" header value should be unique for each request

  @api @regression
  Scenario: Unsupported HTTP method on /api/projects/{id} returns 405 Method Not Allowed
    Given I have a valid JWT token "ADMIN_T001_TOKEN"
    When I send a PATCH request to "/api/projects/P001" with header "Authorization: Bearer ADMIN_T001_TOKEN"
    Then the response status should be 405
    And the response body field "error" should equal "Method Not Allowed"
    And the response header "Allow" should contain "GET, PUT, DELETE"

  @api @regression
  Scenario: OPTIONS preflight request on /api/projects returns correct CORS headers
    When I send an OPTIONS request to "/api/projects" with header "Origin: https://app.testmu.io"
    Then the response status should be 204
    And the response header "Access-Control-Allow-Origin" should equal "https://app.testmu.io"
    And the response header "Access-Control-Allow-Methods" should contain "GET, POST, PUT, DELETE"
    And the response header "Access-Control-Allow-Headers" should contain "Authorization, Content-Type"
