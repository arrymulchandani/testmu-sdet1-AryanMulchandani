Feature: Login Module - Regression Test Suite
  As a user of the multi-tenant SaaS platform
  I want to securely authenticate and access role-appropriate resources
  So that I can perform my authorized actions within my tenant context

  Background:
    Given the application is running and accessible
    And the database is seeded with the following tenants:
      | tenant_id | tenant_name  | status   |
      | T001      | AlphaCorp    | active   |
      | T002      | BetaCorp     | active   |
      | T003      | GammaCorp    | inactive |
    And the following users exist:
      | email                   | password       | role    | tenant_id | status   |
      | admin@alphacorp.com     | Admin@1234!    | Admin   | T001      | active   |
      | manager@alphacorp.com   | Manager@1234!  | Manager | T001      | active   |
      | viewer@alphacorp.com    | Viewer@1234!   | Viewer  | T001      | active   |
      | admin@betacorp.com      | Admin@5678!    | Admin   | T002      | active   |
      | locked@alphacorp.com    | Locked@1234!   | Viewer  | T001      | locked   |
      | inactive@alphacorp.com  | Inactive@1234! | Viewer  | T001      | inactive |
    And the login page is displayed at "/login"

  # ─────────────────────────────────────────────
  # SMOKE SCENARIOS
  # ─────────────────────────────────────────────

  @smoke @regression
  Scenario: Successful login as Admin user
    Given I am on the login page
    When I enter email "admin@alphacorp.com" and password "Admin@1234!"
    And I click the "Login" button
    Then I should be redirected to "/admin/dashboard"
    And the page title should be "Admin Dashboard"
    And a valid JWT token should be present in the session storage
    And the JWT payload should contain role "Admin" and tenant_id "T001"

  @smoke @regression
  Scenario: Successful login as Manager user
    Given I am on the login page
    When I enter email "manager@alphacorp.com" and password "Manager@1234!"
    And I click the "Login" button
    Then I should be redirected to "/manager/dashboard"
    And the page title should be "Manager Dashboard"
    And a valid JWT token should be present in the session storage
    And the JWT payload should contain role "Manager" and tenant_id "T001"

  @smoke @regression
  Scenario: Successful login as Viewer user
    Given I am on the login page
    When I enter email "viewer@alphacorp.com" and password "Viewer@1234!"
    And I click the "Login" button
    Then I should be redirected to "/viewer/dashboard"
    And the page title should be "Viewer Dashboard"
    And a valid JWT token should be present in the session storage
    And the JWT payload should contain role "Viewer" and tenant_id "T001"

  @smoke @regression
  Scenario: Successful logout clears session
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    When I click the "Logout" button
    Then I should be redirected to "/login"
    And the JWT token should be absent from session storage
    And accessing "/admin/dashboard" directly should redirect me to "/login"

  # ─────────────────────────────────────────────
  # NEGATIVE SCENARIOS
  # ─────────────────────────────────────────────

  @regression
  Scenario: Login fails with incorrect password
    Given I am on the login page
    When I enter email "admin@alphacorp.com" and password "WrongPass@999"
    And I click the "Login" button
    Then I should remain on the login page
    And an error message "Invalid email or password" should be displayed
    And no JWT token should be present in session storage

  @regression
  Scenario: Login fails with non-existent email
    Given I am on the login page
    When I enter email "nobody@alphacorp.com" and password "SomePass@123"
    And I click the "Login" button
    Then I should remain on the login page
    And an error message "Invalid email or password" should be displayed

  @regression
  Scenario: Login fails with empty email field
    Given I am on the login page
    When I enter email "" and password "Admin@1234!"
    And I click the "Login" button
    Then I should remain on the login page
    And a field validation error "Email is required" should be displayed on the email field

  @regression
  Scenario: Login fails with empty password field
    Given I am on the login page
    When I enter email "admin@alphacorp.com" and password ""
    And I click the "Login" button
    Then I should remain on the login page
    And a field validation error "Password is required" should be displayed on the password field

  @regression
  Scenario: Login fails with both fields empty
    Given I am on the login page
    When I enter email "" and password ""
    And I click the "Login" button
    Then I should remain on the login page
    And a field validation error "Email is required" should be displayed on the email field
    And a field validation error "Password is required" should be displayed on the password field

  @regression
  Scenario: Login fails with invalid email format
    Given I am on the login page
    When I enter email "not-an-email" and password "Admin@1234!"
    And I click the "Login" button
    Then I should remain on the login page
    And a field validation error "Enter a valid email address" should be displayed on the email field

  @regression
  Scenario: Login fails for inactive user account
    Given I am on the login page
    When I enter email "inactive@alphacorp.com" and password "Inactive@1234!"
    And I click the "Login" button
    Then I should remain on the login page
    And an error message "Your account has been deactivated. Please contact your administrator." should be displayed

  @regression
  Scenario: Login fails for a user in an inactive tenant
    Given I am on the login page
    When I enter email "admin@gammacorp.com" and password "Admin@9999!"
    And I click the "Login" button
    Then I should remain on the login page
    And an error message "Your organization's account is inactive. Please contact support." should be displayed

  # ─────────────────────────────────────────────
  # EDGE SCENARIOS
  # ─────────────────────────────────────────────

  @regression
  Scenario: Email field is case-insensitive during login
    Given I am on the login page
    When I enter email "ADMIN@ALPHACORP.COM" and password "Admin@1234!"
    And I click the "Login" button
    Then I should be redirected to "/admin/dashboard"
    And a valid JWT token should be present in the session storage

  @regression
  Scenario: Password field is case-sensitive during login
    Given I am on the login page
    When I enter email "admin@alphacorp.com" and password "admin@1234!"
    And I click the "Login" button
    Then I should remain on the login page
    And an error message "Invalid email or password" should be displayed

  @regression
  Scenario: Login succeeds when email has leading or trailing whitespace
    Given I am on the login page
    When I enter email "  admin@alphacorp.com  " and password "Admin@1234!"
    And I click the "Login" button
    Then I should be redirected to "/admin/dashboard"

  @regression
  Scenario: Password field masks input characters
    Given I am on the login page
    When I type in the password field "Admin@1234!"
    Then each character in the password field should be displayed as a masked character "•"

  @regression
  Scenario: Toggle password visibility reveals and hides password
    Given I am on the login page
    When I type in the password field "Admin@1234!"
    And I click the "Show Password" toggle icon
    Then the password field type should be "text" and display "Admin@1234!"
    When I click the "Hide Password" toggle icon
    Then the password field type should be "password"

  @regression
  Scenario: Login page fields reset after a failed login attempt
    Given I am on the login page
    When I enter email "admin@alphacorp.com" and password "WrongPass@999"
    And I click the "Login" button
    Then the password field should be cleared
    And the email field should retain the value "admin@alphacorp.com"

  @regression
  Scenario: Login with maximum allowed email length
    Given I am on the login page
    When I enter email with exactly 254 characters as the email and password "Admin@1234!"
    And I click the "Login" button
    Then the system should process the request without a 500 error

  @regression
  Scenario: Login with password at maximum allowed length boundary
    Given I am on the login page
    When I enter email "admin@alphacorp.com" and a password string of 128 characters
    And I click the "Login" button
    Then the system should process the request without a 500 error

  @regression
  Scenario: Concurrent login sessions are allowed for the same user
    Given user "admin@alphacorp.com" is logged in on Browser A
    When the same user "admin@alphacorp.com" logs in on Browser B with password "Admin@1234!"
    Then Browser B should be redirected to "/admin/dashboard" with a new valid JWT token
    And Browser A session should remain active

  # ─────────────────────────────────────────────
  # SESSION EXPIRATION SCENARIOS
  # ─────────────────────────────────────────────

  @regression @security
  Scenario: Session expires after inactivity timeout
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And I am on the "/admin/dashboard" page
    When no user activity occurs for the configured inactivity timeout period of 30 minutes
    Then the session should be invalidated server-side
    And I should be redirected to "/login"
    And an informational message "Your session has expired due to inactivity. Please log in again." should be displayed
    And the JWT token should be absent from session storage

  @regression @security
  Scenario: Accessing a protected route with an expired JWT token is rejected
    Given I have an expired JWT token for "admin@alphacorp.com" in session storage
    When I navigate directly to "/admin/dashboard"
    Then I should be redirected to "/login"
    And an error message "Session expired. Please log in again." should be displayed

  @regression @security
  Scenario: Accessing a protected route with a tampered JWT token is rejected
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    When I tamper with the JWT token signature in session storage
    And I navigate to "/admin/dashboard"
    Then I should be redirected to "/login"
    And an error message "Invalid session. Please log in again." should be displayed

  @regression @security
  Scenario: JWT token is not accessible via JavaScript on the page
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    When I execute "document.cookie" in the browser console
    Then the JWT token value should not be exposed in the result

  @regression @security
  Scenario: Session is fully invalidated server-side after logout
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And I capture the current JWT token
    When I click the "Logout" button
    And I make a direct API call to "GET /api/admin/dashboard" with the captured JWT token
    Then the API response status should be 401
    And the response body should contain "Token has been invalidated"

  # ─────────────────────────────────────────────
  # BRUTE-FORCE LOCKOUT SCENARIOS
  # ─────────────────────────────────────────────

  @regression @security
  Scenario: Account is locked after 5 consecutive failed login attempts
    Given I am on the login page
    And the failed login attempt count for "admin@alphacorp.com" is 0
    When I enter email "admin@alphacorp.com" and password "WrongPass@1" and click "Login"
    And I enter email "admin@alphacorp.com" and password "WrongPass@2" and click "Login"
    And I enter email "admin@alphacorp.com" and password "WrongPass@3" and click "Login"
    And I enter email "admin@alphacorp.com" and password "WrongPass@4" and click "Login"
    And I enter email "admin@alphacorp.com" and password "WrongPass@5" and click "Login"
    Then the account for "admin@alphacorp.com" should be locked
    And an error message "Your account has been locked due to too many failed login attempts. Please contact your administrator or try again after 15 minutes." should be displayed

  @regression @security
  Scenario: Correct password does not unlock a locked account
    Given the account "locked@alphacorp.com" is in a locked state
    When I am on the login page
    And I enter email "locked@alphacorp.com" and password "Locked@1234!"
    And I click the "Login" button
    Then I should remain on the login page
    And an error message "Your account has been locked due to too many failed login attempts. Please contact your administrator or try again after 15 minutes." should be displayed

  @regression @security
  Scenario: Failed login attempt counter resets after a successful login
    Given I am on the login page
    And the failed login attempt count for "admin@alphacorp.com" is 4
    When I enter email "admin@alphacorp.com" and password "Admin@1234!"
    And I click the "Login" button
    Then I should be redirected to "/admin/dashboard"
    And the failed login attempt count for "admin@alphacorp.com" should be reset to 0

  @regression @security
  Scenario: Account lockout is time-based and auto-unlocks after timeout
    Given the account "admin@alphacorp.com" was locked 15 minutes ago due to failed attempts
    When I am on the login page
    And I enter email "admin@alphacorp.com" and password "Admin@1234!"
    And I click the "Login" button
    Then I should be redirected to "/admin/dashboard"

  @regression @security
  Scenario: Admin can manually unlock a locked account from admin panel
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the account "locked@alphacorp.com" is in a locked state
    When I navigate to "/admin/users"
    And I select user "locked@alphacorp.com"
    And I click "Unlock Account"
    Then the account status for "locked@alphacorp.com" should change to "active"
    When "locked@alphacorp.com" attempts to log in with password "Locked@1234!"
    Then the login should succeed and redirect to "/viewer/dashboard"

  @regression @security
  Scenario: Lockout is per-account and does not affect other accounts on the same tenant
    Given I am on the login page
    And the account "admin@alphacorp.com" is locked
    When I enter email "manager@alphacorp.com" and password "Manager@1234!"
    And I click the "Login" button
    Then I should be redirected to "/manager/dashboard"

  # ─────────────────────────────────────────────
  # TENANT ISOLATION SCENARIOS
  # ─────────────────────────────────────────────

  @regression @security
  Scenario: A user from Tenant A cannot access Tenant B's resources after login
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the JWT payload contains tenant_id "T001"
    When I make a direct API call to "GET /api/tenants/T002/projects" with my JWT token
    Then the API response status should be 403
    And the response body should contain "Access denied: insufficient tenant permissions"

  @regression @security
  Scenario: JWT token is scoped to the user's tenant
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    When I decode the JWT token from session storage
    Then the JWT payload field "tenant_id" should equal "T001"
    And the JWT payload field "tenant_id" should not equal "T002"

  @regression @security
  Scenario: User credentials from Tenant A do not authenticate on Tenant B's subdomain
    Given I am on the Tenant B login page at "https://betacorp.testmu.io/login"
    When I enter email "admin@alphacorp.com" and password "Admin@1234!"
    And I click the "Login" button
    Then I should remain on the login page
    And an error message "Invalid email or password" should be displayed

  @regression @security
  Scenario: Tenant-specific subdomain resolves correct branding on the login page
    Given I navigate to the Tenant A login page at "https://alphacorp.testmu.io/login"
    Then the login page should display the AlphaCorp tenant logo
    And the page title should contain "AlphaCorp"

  @regression @security
  Scenario: A user cannot log in to an inactive tenant even with valid credentials
    Given I am on the login page for Tenant GammaCorp
    When I enter valid credentials for a GammaCorp user
    And I click the "Login" button
    Then I should remain on the login page
    And an error message "Your organization's account is inactive. Please contact support." should be displayed

  # ─────────────────────────────────────────────
  # ROLE-BASED REDIRECTION SCENARIOS
  # ─────────────────────────────────────────────

  @regression
  Scenario Outline: Role-based dashboard redirection after successful login
    Given I am on the login page
    When I enter email "<email>" and password "<password>"
    And I click the "Login" button
    Then I should be redirected to "<expected_path>"
    And the JWT payload should contain role "<role>"

    Examples:
      | email                  | password       | role    | expected_path      |
      | admin@alphacorp.com    | Admin@1234!    | Admin   | /admin/dashboard   |
      | manager@alphacorp.com  | Manager@1234!  | Manager | /manager/dashboard |
      | viewer@alphacorp.com   | Viewer@1234!   | Viewer  | /viewer/dashboard  |

  @regression @security
  Scenario: Viewer cannot access Admin routes directly after login
    Given I am logged in as "viewer@alphacorp.com" with password "Viewer@1234!"
    When I navigate directly to "/admin/dashboard"
    Then I should be redirected to "/viewer/dashboard"
    And an error message "You do not have permission to access this page." should be displayed

  @regression @security
  Scenario: Viewer cannot access Manager routes directly after login
    Given I am logged in as "viewer@alphacorp.com" with password "Viewer@1234!"
    When I navigate directly to "/manager/dashboard"
    Then I should be redirected to "/viewer/dashboard"
    And an error message "You do not have permission to access this page." should be displayed

  @regression @security
  Scenario: Manager cannot access Admin routes directly after login
    Given I am logged in as "manager@alphacorp.com" with password "Manager@1234!"
    When I navigate directly to "/admin/dashboard"
    Then I should be redirected to "/manager/dashboard"
    And an error message "You do not have permission to access this page." should be displayed

  @regression
  Scenario: Admin can access Manager and Viewer routes after login
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    When I navigate directly to "/manager/dashboard"
    Then I should see the Manager Dashboard without an error
    When I navigate directly to "/viewer/dashboard"
    Then I should see the Viewer Dashboard without an error

  @regression
  Scenario: Unauthenticated user is redirected to login when accessing a protected route
    Given I am not logged in
    When I navigate directly to "/admin/dashboard"
    Then I should be redirected to "/login"
    And the redirect URL parameter should preserve the originally requested path "/admin/dashboard"

  @regression
  Scenario: User is redirected to their original destination after login
    Given I am not logged in
    And I attempt to navigate directly to "/manager/reports"
    And I am redirected to "/login?redirect=/manager/reports"
    When I enter email "manager@alphacorp.com" and password "Manager@1234!"
    And I click the "Login" button
    Then I should be redirected to "/manager/reports"

  # ─────────────────────────────────────────────
  # SECURITY SCENARIOS
  # ─────────────────────────────────────────────

  @security
  Scenario: Login form is protected against SQL injection in email field
    Given I am on the login page
    When I enter email "' OR '1'='1'; --" and password "anything"
    And I click the "Login" button
    Then I should remain on the login page
    And an error message "Invalid email or password" should be displayed
    And no unauthorized access should be granted

  @security
  Scenario: Login form is protected against SQL injection in password field
    Given I am on the login page
    When I enter email "admin@alphacorp.com" and password "' OR '1'='1'; --"
    And I click the "Login" button
    Then I should remain on the login page
    And an error message "Invalid email or password" should be displayed
    And no unauthorized access should be granted

  @security
  Scenario: Login form is protected against XSS in email field
    Given I am on the login page
    When I enter email "<script>alert('xss')</script>@test.com" and password "Admin@1234!"
    And I click the "Login" button
    Then no JavaScript alert should be triggered
    And the input should be treated as plain text and sanitized

  @security
  Scenario: Login API endpoint rejects requests without CSRF token
    Given the application enforces CSRF protection
    When I send a POST request to "/api/auth/login" without a CSRF token
    Then the API response status should be 403
    And the response body should contain "CSRF validation failed"

  @security
  Scenario: Login page is served over HTTPS only
    Given I navigate to the login page using HTTP at "http://alphacorp.testmu.io/login"
    Then I should be automatically redirected to "https://alphacorp.testmu.io/login"
    And the response status for the HTTP request should be 301

  @security
  Scenario: API brute-force protection triggers rate limiting by IP
    Given I am sending login requests from IP "192.168.1.100"
    When I send more than 20 failed login requests within 60 seconds from that IP
    Then the API response status should be 429
    And the response body should contain "Too many requests. Please try again later."
    And the response headers should contain "Retry-After"

  @security
  Scenario: Sensitive authentication error messages do not reveal whether email exists
    Given I am on the login page
    When I enter email "nonexistent@alphacorp.com" and password "SomePass@123"
    And I click the "Login" button
    Then the error message displayed should be "Invalid email or password"
    When I enter email "admin@alphacorp.com" and password "WrongPass@999"
    And I click the "Login" button
    Then the error message displayed should be "Invalid email or password"

  @security
  Scenario: Login response does not expose internal server details on error
    Given I submit a malformed login request to the API
    Then the response body should not contain any stack trace information
    And the response body should not contain any database error messages
    And the response body should not contain server technology identifiers

  # ─────────────────────────────────────────────
  # FORGOT PASSWORD SCENARIOS
  # ─────────────────────────────────────────────

  @smoke @regression
  Scenario: Forgot Password link is visible on the login page
    Given I am on the login page
    Then a "Forgot Password?" link should be visible on the page
    And the link should be clickable

  @smoke @regression
  Scenario: Navigating to Forgot Password page via link
    Given I am on the login page
    When I click the "Forgot Password?" link
    Then I should be redirected to "/forgot-password"
    And the page should contain an email input field
    And a "Send Reset Link" button should be visible

  @smoke @regression
  Scenario: Successful password reset email sent for a valid registered email
    Given I am on the "/forgot-password" page
    When I enter email "admin@alphacorp.com" in the reset email field
    And I click the "Send Reset Link" button
    Then a success message "If this email is registered, you will receive a password reset link shortly." should be displayed
    And a password reset email should be sent to "admin@alphacorp.com"
    And the reset email should contain a password reset link with a unique token

  @regression
  Scenario: Forgot Password does not reveal whether an email is registered (anti-enumeration)
    Given I am on the "/forgot-password" page
    When I enter email "nonexistent@alphacorp.com" in the reset email field
    And I click the "Send Reset Link" button
    Then the success message "If this email is registered, you will receive a password reset link shortly." should be displayed
    And no password reset email should be sent
    And the response time should be consistent with a valid email submission

  @regression
  Scenario: Forgot Password fails with empty email field
    Given I am on the "/forgot-password" page
    When I leave the email field empty
    And I click the "Send Reset Link" button
    Then a field validation error "Email is required" should be displayed
    And no reset email should be sent

  @regression
  Scenario: Forgot Password fails with an invalid email format
    Given I am on the "/forgot-password" page
    When I enter email "invalid-format" in the reset email field
    And I click the "Send Reset Link" button
    Then a field validation error "Enter a valid email address" should be displayed
    And no reset email should be sent

  @regression
  Scenario: Password reset link navigates to the reset password page
    Given a valid password reset token has been issued for "admin@alphacorp.com"
    When I navigate to the password reset link "/reset-password?token=<valid_token>"
    Then I should see the Reset Password page
    And the page should contain a "New Password" field
    And the page should contain a "Confirm New Password" field
    And a "Reset Password" button should be visible

  @regression
  Scenario: Successful password reset with a valid token
    Given a valid password reset token has been issued for "admin@alphacorp.com"
    And I am on the Reset Password page with the valid token
    When I enter "NewAdmin@5678!" in the "New Password" field
    And I enter "NewAdmin@5678!" in the "Confirm New Password" field
    And I click the "Reset Password" button
    Then a success message "Your password has been reset successfully. Please log in with your new password." should be displayed
    And I should be redirected to "/login"
    And I should be able to log in with email "admin@alphacorp.com" and password "NewAdmin@5678!"

  @regression
  Scenario: Password reset fails when new password does not meet complexity requirements
    Given a valid password reset token has been issued for "admin@alphacorp.com"
    And I am on the Reset Password page with the valid token
    When I enter "simple" in the "New Password" field
    And I enter "simple" in the "Confirm New Password" field
    And I click the "Reset Password" button
    Then a validation error should be displayed stating "Password must be at least 8 characters and include uppercase, lowercase, a number, and a special character"
    And the password should not be reset

  @regression
  Scenario: Password reset fails when new password and confirm password do not match
    Given a valid password reset token has been issued for "admin@alphacorp.com"
    And I am on the Reset Password page with the valid token
    When I enter "NewAdmin@5678!" in the "New Password" field
    And I enter "DifferentPass@999!" in the "Confirm New Password" field
    And I click the "Reset Password" button
    Then a validation error "Passwords do not match" should be displayed
    And the password should not be reset

  @regression @security
  Scenario: Password reset fails with an expired token
    Given a password reset token for "admin@alphacorp.com" that expired 2 hours ago
    When I navigate to the password reset link with the expired token
    Then I should see an error message "This password reset link has expired. Please request a new one."
    And a link to "/forgot-password" should be provided

  @regression @security
  Scenario: Password reset fails with an already used token
    Given a password reset token for "admin@alphacorp.com" that has already been used
    When I navigate to the password reset link with the used token
    Then I should see an error message "This password reset link has already been used. Please request a new one."
    And the page should contain a link to "/forgot-password"

  @regression @security
  Scenario: Password reset fails with a tampered or invalid token
    Given I am on the Reset Password page with a tampered token "abc123invalidtoken"
    When I enter "NewAdmin@5678!" in the "New Password" field
    And I enter "NewAdmin@5678!" in the "Confirm New Password" field
    And I click the "Reset Password" button
    Then I should see an error message "Invalid or malformed reset link. Please request a new one."

  @regression @security
  Scenario: Previous password reset tokens are invalidated when a new reset is requested
    Given a valid password reset token T1 has been issued for "admin@alphacorp.com"
    When "admin@alphacorp.com" requests another password reset
    Then a new password reset token T2 should be issued
    And attempting to use token T1 on the reset page should return "This password reset link has expired. Please request a new one."

  @regression @security
  Scenario: Old password no longer works after a successful password reset
    Given a valid password reset token has been issued for "admin@alphacorp.com"
    And I successfully reset the password to "NewAdmin@5678!"
    When I attempt to log in with email "admin@alphacorp.com" and old password "Admin@1234!"
    Then I should remain on the login page
    And an error message "Invalid email or password" should be displayed

  @regression @security
  Scenario: All active sessions are invalidated after a successful password reset
    Given "admin@alphacorp.com" is actively logged in on Browser A with a valid JWT token
    And a password reset is completed for "admin@alphacorp.com" from a separate session
    When Browser A makes an authenticated API request using the old JWT token
    Then the API response status should be 401
    And the response body should contain "Session invalidated due to password change. Please log in again."

  @security
  Scenario: Forgot Password API endpoint is rate-limited to prevent email flooding
    Given I am sending requests to "POST /api/auth/forgot-password" from IP "192.168.1.101"
    When I send more than 10 requests within 60 seconds from that IP
    Then the API response status should be 429
    And the response body should contain "Too many requests. Please try again later."
    And the response headers should contain "Retry-After"

  @regression
  Scenario: Forgot Password page has a back link to the Login page
    Given I am on the "/forgot-password" page
    When I click the "Back to Login" link
    Then I should be redirected to "/login"

  @regression
  Scenario: Password reset request is scoped to the user's tenant
    Given I am on the "/forgot-password" page for Tenant AlphaCorp
    When I enter email "admin@betacorp.com" in the reset email field
    And I click the "Send Reset Link" button
    Then the success message "If this email is registered, you will receive a password reset link shortly." should be displayed
    And no password reset email should be sent to "admin@betacorp.com"

  @regression
  Scenario: Forgot Password is not accessible to already authenticated users
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    When I navigate directly to "/forgot-password"
    Then I should be redirected to "/admin/dashboard"