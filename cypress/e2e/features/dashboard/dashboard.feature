Feature: Dashboard Module - Regression Test Suite
  As a logged-in user of the multi-tenant SaaS platform
  I want to view and interact with my role-appropriate dashboard
  So that I can monitor analytics, track activity, and make informed decisions

  Background:
    Given the application is running and accessible
    And the database is seeded with the following tenants:
      | tenant_id | tenant_name | status   |
      | T001      | AlphaCorp   | active   |
      | T002      | BetaCorp    | active   |
      | T003      | GammaCorp   | inactive |
    And the following users exist:
      | email                  | password      | role    | tenant_id |
      | admin@alphacorp.com    | Admin@1234!   | Admin   | T001      |
      | manager@alphacorp.com  | Manager@1234! | Manager | T001      |
      | viewer@alphacorp.com   | Viewer@1234!  | Viewer  | T001      |
      | admin@betacorp.com     | Admin@5678!   | Admin   | T002      |
    And the following widgets are configured for tenant "T001":
      | widget_id | widget_name              | roles_allowed          | api_endpoint                        |
      | W001      | Total Test Runs          | Admin, Manager, Viewer | GET /api/analytics/test-runs        |
      | W002      | Pass/Fail Rate Chart     | Admin, Manager, Viewer | GET /api/analytics/pass-fail        |
      | W003      | Active Users             | Admin, Manager         | GET /api/analytics/active-users     |
      | W004      | Billing & Usage          | Admin                  | GET /api/analytics/billing          |
      | W005      | Recent Activity Feed     | Admin, Manager, Viewer | GET /api/activity/recent            |
      | W006      | Test Execution Table     | Admin, Manager, Viewer | GET /api/analytics/executions       |
      | W007      | Team Performance Chart   | Admin, Manager         | GET /api/analytics/team-performance |
      | W008      | System Health Monitor    | Admin                  | GET /api/analytics/system-health    |
    And all API endpoints are healthy and returning 200 responses by default
    And the API mock server is configured for scenario-level overrides

  # ─────────────────────────────────────────────
  # SMOKE SCENARIOS
  # ─────────────────────────────────────────────

  @smoke @regression
  Scenario: Admin dashboard loads successfully with all permitted widgets
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    When I navigate to "/admin/dashboard"
    Then the page should load within 3 seconds
    And the following widgets should be visible:
      | widget_name            |
      | Total Test Runs        |
      | Pass/Fail Rate Chart   |
      | Active Users           |
      | Billing & Usage        |
      | Recent Activity Feed   |
      | Test Execution Table   |
      | Team Performance Chart |
      | System Health Monitor  |
    And each widget should display a loading spinner while fetching data
    And each widget should render its content after data is fetched

  @smoke @regression
  Scenario: Manager dashboard loads successfully with permitted widgets only
    Given I am logged in as "manager@alphacorp.com" with password "Manager@1234!"
    When I navigate to "/manager/dashboard"
    Then the page should load within 3 seconds
    And the following widgets should be visible:
      | widget_name            |
      | Total Test Runs        |
      | Pass/Fail Rate Chart   |
      | Active Users           |
      | Recent Activity Feed   |
      | Test Execution Table   |
      | Team Performance Chart |
    And the following widgets should not be visible:
      | widget_name           |
      | Billing & Usage       |
      | System Health Monitor |

  @smoke @regression
  Scenario: Viewer dashboard loads successfully with permitted widgets only
    Given I am logged in as "viewer@alphacorp.com" with password "Viewer@1234!"
    When I navigate to "/viewer/dashboard"
    Then the page should load within 3 seconds
    And the following widgets should be visible:
      | widget_name          |
      | Total Test Runs      |
      | Pass/Fail Rate Chart |
      | Recent Activity Feed |
      | Test Execution Table |
    And the following widgets should not be visible:
      | widget_name            |
      | Active Users           |
      | Billing & Usage        |
      | Team Performance Chart |
      | System Health Monitor  |

  @smoke @regression
  Scenario: Dashboard page title and header are correctly displayed
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    When I navigate to "/admin/dashboard"
    Then the browser page title should be "Dashboard - AlphaCorp | TestMu"
    And the dashboard header should display "Welcome back, Admin"
    And the tenant name "AlphaCorp" should be visible in the navigation bar

  # ─────────────────────────────────────────────
  # WIDGET LOADING BEHAVIOR
  # ─────────────────────────────────────────────

  @regression
  Scenario: Each widget displays a skeleton loader while API data is being fetched
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API endpoint "GET /api/analytics/test-runs" has a simulated response delay of 3 seconds
    When I navigate to "/admin/dashboard"
    Then the "Total Test Runs" widget should display a skeleton loader immediately
    And after 3 seconds the skeleton loader should be replaced with the widget data

  @regression
  Scenario: Widgets load independently and do not block each other
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API endpoint "GET /api/analytics/billing" has a simulated response delay of 5 seconds
    When I navigate to "/admin/dashboard"
    Then the "Total Test Runs" widget should render its content within 2 seconds
    And the "Pass/Fail Rate Chart" widget should render its content within 2 seconds
    And the "Billing & Usage" widget should still show a skeleton loader after 2 seconds
    And the "Billing & Usage" widget should render its content after 5 seconds

  @regression
  Scenario: Dashboard displays the last refreshed timestamp for each widget
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    When I navigate to "/admin/dashboard"
    And all widgets have finished loading
    Then each widget should display a "Last updated: <timestamp>" label
    And the timestamp should match the time the API response was received within 5 seconds

  @regression
  Scenario: Widgets refresh data when the global refresh button is clicked
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And I am on the "/admin/dashboard" page with all widgets loaded
    When I click the "Refresh" button in the dashboard header
    Then all widgets should display skeleton loaders simultaneously
    And all widgets should re-fetch data from their respective API endpoints
    And the "Last updated" timestamp on each widget should be updated to the current time

  @regression
  Scenario: Individual widget can be refreshed without affecting other widgets
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And I am on the "/admin/dashboard" page with all widgets loaded
    When I click the refresh icon on the "Total Test Runs" widget
    Then only the "Total Test Runs" widget should display a skeleton loader
    And all other widgets should remain in their loaded state
    And the "Total Test Runs" widget should re-fetch from "GET /api/analytics/test-runs"

  @regression
  Scenario: Dashboard retains widget state after navigating away and returning
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And I am on the "/admin/dashboard" page with all widgets loaded
    When I navigate to "/admin/test-cases"
    And I click the browser back button
    Then the dashboard should be displayed
    And previously loaded widget data should be restored from cache without re-fetching

  # ─────────────────────────────────────────────
  # DATA ACCURACY VALIDATION
  # ─────────────────────────────────────────────

  @regression
  Scenario: Total Test Runs widget displays data matching the API response
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/analytics/test-runs" returns the following payload:
      """
      {
        "total": 1482,
        "passed": 1201,
        "failed": 198,
        "skipped": 83
      }
      """
    When I navigate to "/admin/dashboard"
    And the "Total Test Runs" widget finishes loading
    Then the widget should display total runs as "1,482"
    And the widget should display passed runs as "1,201"
    And the widget should display failed runs as "198"
    And the widget should display skipped runs as "83"

  @regression
  Scenario: Pass/Fail Rate Chart renders data points matching the API response
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/analytics/pass-fail" returns a dataset with 7 daily data points
    When I navigate to "/admin/dashboard"
    And the "Pass/Fail Rate Chart" widget finishes loading
    Then the chart should render exactly 7 data points on the X-axis
    And each data point's pass percentage should match the corresponding value in the API response
    And each data point's fail percentage should match the corresponding value in the API response

  @regression
  Scenario: Recent Activity Feed displays items in descending chronological order
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/activity/recent" returns 10 activity items with timestamps
    When I navigate to "/admin/dashboard"
    And the "Recent Activity Feed" widget finishes loading
    Then the activity items should be displayed from most recent to oldest
    And the first item's timestamp should be more recent than the second item's timestamp
    And each activity item should display a description, actor name, and formatted timestamp

  @regression
  Scenario: Test Execution Table displays all columns from the API response
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/analytics/executions" returns a list of 20 execution records
    When I navigate to "/admin/dashboard"
    And the "Test Execution Table" widget finishes loading
    Then the table should display the following columns:
      | column_name    |
      | Test Suite     |
      | Status         |
      | Duration       |
      | Executed By    |
      | Executed At    |
    And the table should display exactly 20 rows matching the API response

  @regression
  Scenario: Widget displays zero-state correctly when API returns an empty dataset
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/activity/recent" returns an empty array "[]"
    When I navigate to "/admin/dashboard"
    And the "Recent Activity Feed" widget finishes loading
    Then the widget should display the empty state message "No recent activity to display."
    And the widget should not display any activity items

  @regression
  Scenario: Numeric values in widgets are formatted correctly with locale separators
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/analytics/test-runs" returns total as 1000000
    When the "Total Test Runs" widget finishes loading
    Then the total should be displayed as "1,000,000" with comma separators

  @regression
  Scenario: Percentage values in charts are rounded to two decimal places
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/analytics/pass-fail" returns a pass rate of 81.3333333
    When the "Pass/Fail Rate Chart" widget finishes loading
    Then the displayed pass rate should be "81.33%"

  # ─────────────────────────────────────────────
  # FILTER BEHAVIOR
  # ─────────────────────────────────────────────

  @regression
  Scenario: Filtering dashboard by date range updates all widgets with filtered data
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And I am on the "/admin/dashboard" page with all widgets loaded
    When I set the global date range filter to "Last 7 Days"
    Then all widget API endpoints should be called with query parameter "date_range=7d"
    And all widgets should display a skeleton loader during re-fetch
    And all widgets should render data scoped to the last 7 days

  @regression
  Scenario: Filtering dashboard by date range - Last 30 Days
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And I am on the "/admin/dashboard" page with all widgets loaded
    When I set the global date range filter to "Last 30 Days"
    Then all widget API endpoints should be called with query parameter "date_range=30d"
    And the data displayed in each widget should reflect the 30-day period

  @regression
  Scenario: Filtering dashboard by custom date range sends correct parameters to API
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And I am on the "/admin/dashboard" page with all widgets loaded
    When I set the custom date range filter from "2025-01-01" to "2025-01-31"
    Then all widget API endpoints should be called with parameters "start_date=2025-01-01&end_date=2025-01-31"
    And widgets should render data scoped to January 2025

  @regression
  Scenario: Future end date in custom date range filter is rejected with validation error
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And I am on the "/admin/dashboard" page
    When I set the custom date range filter from "2025-01-01" to "2099-12-31"
    Then a validation error "End date cannot be in the future" should be displayed
    And no API calls should be made with the invalid date range
    And widgets should retain their previously loaded data

  @regression
  Scenario: Start date after end date in custom date range filter is rejected
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And I am on the "/admin/dashboard" page
    When I set the custom date range filter from "2025-06-30" to "2025-01-01"
    Then a validation error "Start date must be before end date" should be displayed
    And no API calls should be made with the invalid date range

  @regression
  Scenario: Filtering Test Execution Table by status "Failed" shows only failed records
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the "Test Execution Table" widget is loaded with 20 records of mixed statuses
    When I apply the status filter "Failed" on the "Test Execution Table" widget
    Then the table should only display rows where status is "Failed"
    And the API endpoint should be called with query parameter "status=failed"
    And the row count should reflect only the failed records returned by the API

  @regression
  Scenario: Filtering Test Execution Table by executed user shows only that user's records
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the "Test Execution Table" widget is loaded with records from multiple users
    When I apply the "Executed By" filter with value "manager@alphacorp.com"
    Then the table should only display rows where "Executed By" is "manager@alphacorp.com"
    And the API should be called with query parameter "executed_by=manager@alphacorp.com"

  @regression
  Scenario: Clearing all filters restores the dashboard to its default state
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the dashboard is filtered by "Last 7 Days" and status "Failed"
    When I click the "Clear All Filters" button
    Then the date range filter should reset to "Last 30 Days"
    And the status filter should reset to "All"
    And all widget API endpoints should be called without filter query parameters
    And all widgets should reload with unfiltered data

  @regression
  Scenario: Applied filters persist across page refresh
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And I have applied the date range filter "Last 7 Days" on the dashboard
    When I refresh the browser page
    Then the date range filter should still show "Last 7 Days"
    And the widget API endpoints should be called with "date_range=7d"

  # ─────────────────────────────────────────────
  # SORTING BEHAVIOR
  # ─────────────────────────────────────────────

  @regression
  Scenario: Test Execution Table sorts by "Executed At" column in descending order by default
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the "Test Execution Table" widget is loaded with 20 execution records
    Then the table should be sorted by "Executed At" in descending order by default
    And the API endpoint should have been called with "sort_by=executed_at&sort_order=desc"

  @regression
  Scenario: Clicking a sortable column header sorts the table in ascending order
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the "Test Execution Table" widget is loaded
    When I click the "Duration" column header
    Then the table should be sorted by "Duration" in ascending order
    And an ascending sort indicator should be visible on the "Duration" column header
    And the API endpoint should be called with "sort_by=duration&sort_order=asc"

  @regression
  Scenario: Clicking a sorted column header again toggles sort to descending order
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the "Test Execution Table" is sorted by "Duration" in ascending order
    When I click the "Duration" column header again
    Then the table should be sorted by "Duration" in descending order
    And a descending sort indicator should be visible on the "Duration" column header
    And the API endpoint should be called with "sort_by=duration&sort_order=desc"

  @regression
  Scenario: Clicking a third time on a sorted column resets to default sort
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the "Test Execution Table" is sorted by "Duration" in descending order
    When I click the "Duration" column header again
    Then the table should revert to the default sort "Executed At" in descending order
    And no sort indicator should be visible on the "Duration" column header

  @regression
  Scenario: Sorting and filtering applied together produce correctly scoped results
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the "Test Execution Table" widget is loaded
    When I apply the status filter "Failed"
    And I sort by "Duration" in descending order
    Then the API should be called with "status=failed&sort_by=duration&sort_order=desc"
    And the displayed rows should be only failed executions sorted by duration descending

  @regression
  Scenario: Non-sortable columns do not display sort indicators or trigger sort on click
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the "Test Execution Table" widget is loaded
    When I click the "Test Suite" column header which is marked non-sortable
    Then no sort indicator should appear on the "Test Suite" column
    And the table sort order should remain unchanged
    And no additional API call should be made

  # ─────────────────────────────────────────────
  # PAGINATION BEHAVIOR
  # ─────────────────────────────────────────────

  @regression
  Scenario: Test Execution Table displays pagination controls when records exceed page size
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/analytics/executions" returns a total of 150 records with page size 20
    When the "Test Execution Table" widget finishes loading
    Then the table should display 20 rows on the first page
    And pagination controls should be visible showing "Page 1 of 8"
    And "Next" and "Last" pagination buttons should be enabled
    And "Previous" and "First" pagination buttons should be disabled

  @regression
  Scenario: Navigating to the next page loads the correct data
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the "Test Execution Table" is on page 1 of 8
    When I click the "Next" pagination button
    Then the API should be called with query parameter "page=2&page_size=20"
    And the table should display the records for page 2
    And the pagination control should show "Page 2 of 8"
    And the "Previous" and "First" buttons should now be enabled

  @regression
  Scenario: Navigating to the last page disables the Next and Last buttons
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the "Test Execution Table" is displaying paginated data with 8 pages
    When I click the "Last" pagination button
    Then the table should display the records for page 8
    And the "Next" and "Last" pagination buttons should be disabled
    And the "Previous" and "First" pagination buttons should be enabled

  @regression
  Scenario: Changing page size re-fetches data with updated page size parameter
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the "Test Execution Table" is loaded with default page size of 20
    When I change the page size selector to "50"
    Then the API should be called with query parameter "page=1&page_size=50"
    And the table should display up to 50 rows
    And the pagination should reset to page 1

  # ─────────────────────────────────────────────
  # PERMISSION-BASED WIDGET VISIBILITY
  # ─────────────────────────────────────────────

  @regression @security
  Scenario: Viewer cannot see Admin-only widgets
    Given I am logged in as "viewer@alphacorp.com" with password "Viewer@1234!"
    When I navigate to "/viewer/dashboard"
    Then the "Billing & Usage" widget should not exist in the DOM
    And the "System Health Monitor" widget should not exist in the DOM
    And the "Active Users" widget should not exist in the DOM
    And the "Team Performance Chart" widget should not exist in the DOM

  @regression @security
  Scenario: Manager cannot see Admin-only widgets
    Given I am logged in as "manager@alphacorp.com" with password "Manager@1234!"
    When I navigate to "/manager/dashboard"
    Then the "Billing & Usage" widget should not exist in the DOM
    And the "System Health Monitor" widget should not exist in the DOM

  @regression @security
  Scenario: Viewer cannot access Admin-only widget API endpoints directly
    Given I am logged in as "viewer@alphacorp.com" with password "Viewer@1234!"
    When I make a direct API call to "GET /api/analytics/billing" with my JWT token
    Then the API response status should be 403
    And the response body should contain "Access denied: insufficient role permissions"

  @regression @security
  Scenario: Manager cannot access Admin-only widget API endpoints directly
    Given I am logged in as "manager@alphacorp.com" with password "Manager@1234!"
    When I make a direct API call to "GET /api/analytics/billing" with my JWT token
    Then the API response status should be 403
    And the response body should contain "Access denied: insufficient role permissions"

  @regression @security
  Scenario: Viewer cannot access Manager-only widget API endpoints directly
    Given I am logged in as "viewer@alphacorp.com" with password "Viewer@1234!"
    When I make a direct API call to "GET /api/analytics/active-users" with my JWT token
    Then the API response status should be 403
    And the response body should contain "Access denied: insufficient role permissions"

  @regression @security
  Scenario: Admin can access all widget API endpoints
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    When I make direct API calls to all widget endpoints with my JWT token
    Then all API calls should return status 200

  @regression
  Scenario: Widget visibility is re-evaluated after role change without re-login
    Given I am logged in as "manager@alphacorp.com" with password "Manager@1234!"
    And I am on the "/manager/dashboard" page
    And an Admin upgrades "manager@alphacorp.com" role to "Admin" via the admin panel
    When the manager's session JWT is refreshed with the updated role
    And I navigate to "/admin/dashboard"
    Then the "Billing & Usage" widget should now be visible
    And the "System Health Monitor" widget should now be visible

  # ─────────────────────────────────────────────
  # TENANT DATA ISOLATION
  # ─────────────────────────────────────────────

  @regression @security
  Scenario: Admin from Tenant A sees only Tenant A's data on the dashboard
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    When I navigate to "/admin/dashboard"
    And all widgets finish loading
    Then all widget data should correspond only to tenant_id "T001"
    And no data from tenant_id "T002" should appear in any widget

  @regression @security
  Scenario: Admin from Tenant B sees only Tenant B's data on the dashboard
    Given I am logged in as "admin@betacorp.com" with password "Admin@5678!"
    When I navigate to "/admin/dashboard"
    And all widgets finish loading
    Then all widget data should correspond only to tenant_id "T002"
    And no data from tenant_id "T001" should appear in any widget

  @regression @security
  Scenario: Widget API endpoints include tenant_id in request and are isolated server-side
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    When all widget API calls are made during dashboard load
    Then each API request should include the header "X-Tenant-ID: T001"
    And each API response payload should contain only records with tenant_id "T001"

  @regression @security
  Scenario: Tenant A admin cannot access Tenant B dashboard data via direct API call
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    When I make a direct API call to "GET /api/analytics/test-runs?tenant_id=T002" with my JWT token
    Then the API response status should be 403
    And the response body should contain "Access denied: cross-tenant access is not permitted"

  @regression @security
  Scenario: JWT tenant claim cannot be overridden by a query parameter to access cross-tenant data
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And my JWT token contains tenant_id "T001"
    When I inject "tenant_id=T002" as a query parameter in a widget API call
    Then the server should ignore the injected query parameter
    And the API response should return only T001 data
    And the response status should be 200 with T001-scoped data

  @regression @security
  Scenario: Recent Activity Feed shows only activities belonging to the logged-in user's tenant
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the activity feed API returns items exclusively for tenant_id "T001"
    When the "Recent Activity Feed" widget finishes loading
    Then all activity items should have actor emails ending in "@alphacorp.com"
    And no activity items from "@betacorp.com" users should appear

  # ─────────────────────────────────────────────
  # ERROR HANDLING - 4XX RESPONSES
  # ─────────────────────────────────────────────

  @regression
  Scenario: Widget displays an error state when its API returns 401 Unauthorized
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/analytics/test-runs" is configured to return 401
    When I navigate to "/admin/dashboard"
    And the "Total Test Runs" widget finishes its fetch attempt
    Then the "Total Test Runs" widget should display an error state
    And the error message "Unauthorized. Please log in again." should be shown within the widget
    And the user should be prompted to re-authenticate

  @regression
  Scenario: Widget displays an error state when its API returns 403 Forbidden
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/analytics/billing" is configured to return 403
    When I navigate to "/admin/dashboard"
    And the "Billing & Usage" widget finishes its fetch attempt
    Then the "Billing & Usage" widget should display an error state
    And the error message "You do not have permission to view this data." should be shown within the widget
    And other widgets should continue to load normally

  @regression
  Scenario: Widget displays an error state when its API returns 404 Not Found
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/analytics/team-performance" is configured to return 404
    When the "Team Performance Chart" widget finishes its fetch attempt
    Then the "Team Performance Chart" widget should display an error state
    And the error message "Data not found. The resource may have been removed." should be shown within the widget

  @regression
  Scenario: Widget displays an error state when its API returns 429 Too Many Requests
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/analytics/active-users" is configured to return 429 with header "Retry-After: 30"
    When the "Active Users" widget finishes its fetch attempt
    Then the "Active Users" widget should display an error state
    And the error message "Rate limit exceeded. Please try again in 30 seconds." should be shown within the widget
    And a countdown timer of 30 seconds should be visible before the auto-retry

  # ─────────────────────────────────────────────
  # ERROR HANDLING - 5XX RESPONSES
  # ─────────────────────────────────────────────

  @regression
  Scenario: Widget displays an error state when its API returns 500 Internal Server Error
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/analytics/test-runs" is configured to return 500
    When the "Total Test Runs" widget finishes its fetch attempt
    Then the "Total Test Runs" widget should display an error state
    And the error message "Something went wrong. Please try again later." should be shown within the widget
    And a "Retry" button should be visible within the widget

  @regression
  Scenario: Widget displays an error state when its API returns 503 Service Unavailable
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/analytics/executions" is configured to return 503
    When the "Test Execution Table" widget finishes its fetch attempt
    Then the "Test Execution Table" widget should display an error state
    And the error message "Service temporarily unavailable. Please try again later." should be shown within the widget

  @regression
  Scenario: Retrying a failed widget re-fetches data from its API endpoint
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/analytics/test-runs" initially returns 500 then recovers to return 200
    And the "Total Test Runs" widget is showing an error state with a "Retry" button
    When I click the "Retry" button on the "Total Test Runs" widget
    Then the widget should display a skeleton loader during the retry fetch
    And the widget should render its content successfully after the 200 response

  @regression
  Scenario: Multiple widgets failing simultaneously each display individual error states
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the APIs "GET /api/analytics/test-runs" and "GET /api/analytics/billing" are both returning 500
    When I navigate to "/admin/dashboard"
    Then the "Total Test Runs" widget should display its individual error state
    And the "Billing & Usage" widget should display its individual error state
    And all other widgets should load successfully

  @regression
  Scenario: Widget displays a timeout error when API does not respond within 10 seconds
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/analytics/system-health" has a simulated no-response timeout
    When I navigate to "/admin/dashboard"
    And 10 seconds have elapsed
    Then the "System Health Monitor" widget should display an error state
    And the error message "Request timed out. Please check your connection and retry." should be shown

  @regression
  Scenario: Dashboard displays a global error banner when all APIs fail simultaneously
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And all widget API endpoints are configured to return 503
    When I navigate to "/admin/dashboard"
    And all widget fetch attempts have completed
    Then a global error banner should be displayed at the top of the dashboard
    And the banner should contain "We're experiencing issues loading your dashboard. Our team has been notified."
    And all widgets should individually display their error states

  @regression
  Scenario: Error state message does not expose internal API error details to the user
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/analytics/test-runs" returns 500 with body containing a stack trace
    When the "Total Test Runs" widget displays its error state
    Then the error message displayed to the user should not contain any stack trace information
    And the error message should not contain any internal server path or technology identifier

  # ─────────────────────────────────────────────
  # RESPONSIVE LAYOUT BEHAVIOR
  # ─────────────────────────────────────────────

  @regression
  Scenario: Dashboard renders a multi-column grid layout on desktop viewport
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the browser viewport is set to "1440x900" (desktop)
    When I navigate to "/admin/dashboard"
    Then the dashboard should render a 3-column widget grid layout
    And no horizontal scrollbar should be visible
    And all widgets should be fully visible without truncation

  @regression
  Scenario: Dashboard renders a two-column grid layout on tablet viewport
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the browser viewport is set to "768x1024" (tablet)
    When I navigate to "/admin/dashboard"
    Then the dashboard should render a 2-column widget grid layout
    And no horizontal scrollbar should be visible
    And all widgets should be fully visible without truncation

  @regression
  Scenario: Dashboard renders a single-column stacked layout on mobile viewport
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the browser viewport is set to "375x812" (mobile)
    When I navigate to "/admin/dashboard"
    Then the dashboard should render a single-column stacked widget layout
    And no horizontal scrollbar should be visible
    And all widgets should be fully visible and vertically scrollable

  @regression
  Scenario: Navigation sidebar collapses into a hamburger menu on mobile viewport
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the browser viewport is set to "375x812" (mobile)
    When I navigate to "/admin/dashboard"
    Then the sidebar navigation should not be visible by default
    And a hamburger menu icon should be visible in the header
    When I click the hamburger menu icon
    Then the sidebar navigation should slide in and be visible

  @regression
  Scenario: Charts in widgets resize proportionally when the browser window is resized
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the browser viewport is set to "1440x900"
    And the "Pass/Fail Rate Chart" widget is fully loaded
    When I resize the browser viewport to "768x1024"
    Then the chart within the "Pass/Fail Rate Chart" widget should resize proportionally
    And the chart should remain fully visible without overflow or clipping

  @regression
  Scenario: Tables in widgets display a horizontal scroll on mobile when columns exceed viewport width
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the browser viewport is set to "375x812" (mobile)
    And the "Test Execution Table" widget is fully loaded with 5 columns
    When I view the "Test Execution Table" widget
    Then the table container should be horizontally scrollable
    And the table should not overflow beyond the widget container boundaries

  @regression
  Scenario: Dashboard filter panel collapses into a drawer on mobile viewport
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the browser viewport is set to "375x812" (mobile)
    When I navigate to "/admin/dashboard"
    Then the global filter bar should not be visible by default
    And a "Filters" button should be visible
    When I click the "Filters" button
    Then a filter drawer should slide up from the bottom of the screen

  @regression
  Scenario: Dashboard layout is consistent across supported browsers on desktop
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the browser viewport is set to "1440x900"
    When I navigate to "/admin/dashboard" in the following browsers:
      | browser         |
      | Chrome latest   |
      | Firefox latest  |
      | Safari latest   |
      | Edge latest     |
    Then the dashboard layout should be visually consistent across all browsers
    And all widgets should load and render correctly in each browser

  # ─────────────────────────────────────────────
  # EDGE SCENARIOS
  # ─────────────────────────────────────────────

  @regression
  Scenario: Dashboard handles extremely large datasets in the Test Execution Table without crashing
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/analytics/executions" returns a paginated response with total of 100,000 records
    When the "Test Execution Table" widget finishes loading the first page
    Then the widget should render page 1 with 20 rows without browser memory errors
    And the pagination should display "Page 1 of 5000"

  @regression
  Scenario: Dashboard handles API response with unexpected additional fields gracefully
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/analytics/test-runs" returns the payload with additional unexpected fields
    When the "Total Test Runs" widget finishes loading
    Then the widget should render only the expected fields
    And no JavaScript errors should be thrown in the browser console

  @regression
  Scenario: Dashboard handles API response with null values in optional fields gracefully
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/analytics/executions" returns records where "duration" field is null
    When the "Test Execution Table" widget finishes loading
    Then the "Duration" column for those records should display "N/A"
    And no JavaScript errors should be thrown in the browser console

  @regression
  Scenario: Dashboard renders correctly when user has no data in the selected date range
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And I set the global date range filter to a period with no activity
    And all widget APIs return empty datasets for the selected range
    When all widgets finish loading
    Then each widget should display its respective empty state message
    And no widget should display loading spinners or error states

  @regression
  Scenario: Dashboard widget tooltips display correct data on chart hover
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the "Pass/Fail Rate Chart" widget is fully loaded
    When I hover over a data point on the chart representing "2025-01-15"
    Then a tooltip should appear displaying the exact pass and fail counts for "2025-01-15"
    And the values in the tooltip should match the API response data for that date

  @regression
  Scenario: Rapid consecutive filter changes do not result in race conditions or stale data
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And I am on the "/admin/dashboard" page
    When I rapidly change the date range filter from "Last 7 Days" to "Last 30 Days" to "Last 90 Days" within 1 second
    Then only one API call should be made corresponding to the final filter "Last 90 Days"
    And widgets should render data for "Last 90 Days" and not for any intermediate filter value

  @regression
  Scenario: Dashboard search input filters the activity feed client-side without an API call
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the "Recent Activity Feed" widget is loaded with 10 items
    When I type "test suite" in the activity feed search input
    Then only activity items containing "test suite" in their description should be visible
    And no additional API call should be triggered

  @regression
  Scenario: Activity feed loads additional items when the "Load More" button is clicked
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the "Recent Activity Feed" widget is loaded with the first 10 of 50 activity items
    When I click the "Load More" button in the "Recent Activity Feed" widget
    Then the API should be called with "GET /api/activity/recent?page=2&page_size=10"
    And 10 more items should be appended below the existing 10 items
    And the widget should now display 20 total activity items

  @regression
  Scenario: Dashboard widget state is preserved when switching between dashboard tabs
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the dashboard has tabs "Overview" and "Performance"
    And I am on the "Overview" tab with all widgets loaded
    When I click the "Performance" tab
    And I click back to the "Overview" tab
    Then the widgets on the "Overview" tab should restore their cached data
    And no additional API calls should be made for the "Overview" tab

  # ─────────────────────────────────────────────
  # SECURITY SCENARIOS
  # ─────────────────────────────────────────────

  @security
  Scenario: Dashboard is not accessible to unauthenticated users
    Given I am not logged in
    When I navigate directly to "/admin/dashboard"
    Then I should be redirected to "/login"
    And no widget API calls should be made

  @security
  Scenario: Dashboard widget API calls include the JWT token in the Authorization header
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    When I navigate to "/admin/dashboard"
    Then all widget API requests should include the header "Authorization: Bearer <jwt_token>"
    And no API request should be made without the Authorization header

  @security
  Scenario: Widget API calls do not expose JWT token in URL query parameters
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    When all widget API calls are made during dashboard load
    Then no API request URL should contain the JWT token as a query parameter

  @security
  Scenario: Dashboard does not execute JavaScript injected via API response data
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And the API "GET /api/activity/recent" returns an activity item with description "<script>alert('xss')</script>"
    When the "Recent Activity Feed" widget finishes loading
    Then no JavaScript alert should be triggered
    And the description should be rendered as escaped plain text

  @security
  Scenario: Dashboard widget data is not cached in browser storage in plaintext
    Given I am logged in as "admin@alphacorp.com" with password "Admin@1234!"
    And I am on the "/admin/dashboard" page with all widgets loaded
    When I inspect localStorage and sessionStorage in the browser
    Then no raw widget API response data should be stored in plaintext in browser storage

  @security
  Scenario: Accessing the dashboard with an expired session redirects to login
    Given my session JWT token has expired
    When I navigate to "/admin/dashboard"
    Then I should be redirected to "/login"
    And no widget API calls should be made using the expired token
    And the message "Your session has expired. Please log in again." should be displayed
