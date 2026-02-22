Feature: LLM Failure Explainer Integration

  As a QA engineer
  I want AI to analyze failed test cases
  So that debugging effort is reduced

  Scenario: Intentional failure to trigger AI explanation
    Given I visit a simple page
    When I look for a non-existing element
    Then the test should fail and AI should analyze it