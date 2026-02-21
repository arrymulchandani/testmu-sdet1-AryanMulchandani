# TestMu AI --- SDET-1 Challenge

**Candidate:** Aryan Mulchandani

------------------------------------------------------------------------

## 🧩 Task 1 --- Framework Scaffold

This repository contains the initial scaffold of an automation framework
built for the TestMu AI SDET-1 Challenge.

The objective of Task 1 was to:

-   Set up a test framework from scratch
-   Design a clean and scalable folder structure
-   Establish a foundation for AI-assisted regression automation

No tests, AI integrations, or cloud configurations have been implemented
yet.\
This stage focuses purely on architecture and maintainability.

------------------------------------------------------------------------

## 🏗️ Architecture Overview

The framework is built using:

-   **Cypress** for end-to-end automation
-   **JavaScript**
-   **Cucumber (BDD approach)** for behavior-driven test design

The architecture is intentionally modular to support future enhancements
such as:

-   AI-driven test case generation
-   Hybrid LLM-based failure analysis
-   Intelligent regression classification
-   Integration with AI-native test management platforms

------------------------------------------------------------------------

## 📁 Project Structure

```bash
testmu-sdet1-AryanMulchandani/
│
├── cypress/
│   ├── e2e/
│   │   ├── features/          # Gherkin feature files
│   │   ├── stepDefinitions/   # BDD step implementations
│   │   ├── tests/             # Test grouping / execution logic
│   │   └── validations/       # Reusable validation helpers
│   │
│   ├── fixtures/              # Test data
│   ├── pages/                 # Page Object Model (POM)
│   ├── support/               # Custom commands & hooks
│   └── utils/                 # Shared utilities
│
├── reports/                   # Test & AI analysis outputs
├── cypress.config.js
├── package.json
└── README.md
```

### Design Philosophy

-   Separation of concerns --- Feature files, step definitions, and page
    objects are isolated.
-   Scalability-first --- Structure supports multi-module testing
    (Login, Dashboard, API).
-   AI-ready architecture --- Hooks and utility layers are prepared for
    future LLM integration.
-   BDD-driven clarity --- Business-readable test cases aligned with
    product behavior.

Empty directories are preserved using `.gitkeep` to maintain structural
consistency.
------------------------------------------------------------------------

## 🔜 Upcoming Tasks

-   Task 2: Prompt engineering for AI-generated test cases
-   Task 3: LLM integration inside the test framework
-   AI usage documentation and structured reporting

This repository will evolve incrementally as each task is completed.
