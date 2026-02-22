import { Given, When, Then } from "@badeball/cypress-cucumber-preprocessor";

Given("I visit a simple page", () => {
  cy.visit("https://example.cypress.io");
});

When("I look for a non-existing element", () => {
  cy.get(".this-element-does-not-exist").should("be.visible");
});

Then("the test should fail and AI should analyze it", () => {
  // This step will never run because previous step fails
});