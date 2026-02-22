<div align="center">

```
 ████████╗███████╗███████╗████████╗███╗   ███╗██╗   ██╗
    ██╔══╝██╔════╝██╔════╝╚══██╔══╝████╗ ████║██║   ██║
    ██║   █████╗  ███████╗   ██║   ██╔████╔██║██║   ██║
    ██║   ██╔══╝  ╚════██║   ██║   ██║╚██╔╝██║██║   ██║
    ██║   ███████╗███████║   ██║   ██║ ╚═╝ ██║╚██████╔╝
    ╚═╝   ╚══════╝╚══════╝   ╚═╝   ╚═╝     ╚═╝ ╚═════╝ 
```

# 🤖 AI-Native Quality Engineering Challenge
### **SDET-1 Hackathon** · **Aryan Mulchandani**

<br/>

[![Cypress](https://img.shields.io/badge/Cypress-17202C?style=for-the-badge&logo=cypress&logoColor=white)](https://www.cypress.io/)
[![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
[![Cucumber](https://img.shields.io/badge/Cucumber-23D96C?style=for-the-badge&logo=cucumber&logoColor=white)](https://cucumber.io/)
[![AI Powered](https://img.shields.io/badge/AI%20Powered-GPT%20%2B%20Claude-blueviolet?style=for-the-badge&logo=openai&logoColor=white)]()
[![Status](https://img.shields.io/badge/Status-Complete%20✓-success?style=for-the-badge)]()

<br/>

> *"Quality isn't just tested — it's engineered. And when AI joins the team, it's engineered at scale."*

</div>

---

## 📖 About This Project

This repository is my submission for the **TestMu AI SDET-1 Hackathon** — an AI-Native Quality Engineering Challenge. The goal: prove that AI isn't just a buzzword in QA, but a genuine force multiplier when properly integrated into a test framework.

Built from scratch. Designed for scale. Powered by LLMs at every layer.

---

## 🗺️ What's Inside

```
testmu-sdet1-AryanMulchandani/
│
├── 🗂️  cypress/
│   ├── e2e/
│   │   ├── features/           # Gherkin feature files (BDD)
│   │   ├── stepDefinitions/    # Step implementations
│   │   ├── tests/              # Test execution & grouping
│   │   └── validations/        # Reusable validation helpers
│   │
│   ├── fixtures/               # Test data & mock payloads
│   ├── pages/                  # Page Object Model (POM)
│   ├── support/                # Custom commands & lifecycle hooks
│   └── utils/                  # Shared utility functions
│
├── 📊  reports/                # Test results & AI analysis outputs
│
├── cypress.config.js           # Framework configuration
├── package.json
├── prompts.md                  # Every AI prompt used — raw & unedited
├── ai-usage-log.md             # Full AI tool audit trail
└── README.md
```

---

## ✅ Task Breakdown

### 🧩 Task 1 — Framework Scaffold

**Objective:** Design a clean, scalable automation foundation before writing a single test.

The framework is built on **Cypress + Cucumber (BDD)** with JavaScript, using a strict **Page Object Model** to separate concerns across:

- Feature files written in human-readable Gherkin
- Step definitions wired to real UI interactions
- Centralized fixtures and utilities for DRY, maintainable code
- Hooks and support layers pre-wired for future LLM integration

Architecture philosophy: **modular, readable, and AI-ready from day one.**

---

### 🧠 Task 2 — Prompt Engineering for Test Generation

**Objective:** Use an LLM to generate meaningful test cases — with prompts that are precise, not lucky.

Modules covered:

| Module | Scenarios |
|--------|-----------|
| 🔐 **Login** | Valid login, invalid credentials, forgot password, session expiry, brute-force lockout |
| 📊 **Dashboard** | Widget loading, data accuracy, filter/sort, responsive layout, permission-based visibility |
| 🌐 **REST API** | Auth token validation, CRUD ops, 4xx/5xx handling, rate limiting, schema validation |

All prompts are documented in [`prompts.md`](./prompts.md) — exactly as written, zero post-processing. Each module includes a brief note on what didn't work first time and how the prompt was refined.

---

### ⚡ Task 3 — LLM Integration in the Test Framework

**Objective:** Wire an LLM into the actual test code. Not a chatbot on the side — a real, live API call embedded in the framework.

**Chosen Option: 🔍 Failure Explainer (Option A)**

When a test fails, the framework automatically:
1. Captures the page state / API response at the point of failure
2. Sends it to an LLM with structured context
3. Gets back a **plain English explanation** of what broke + a **suggested fix**
4. Attaches this analysis directly to the test report

This means zero manual log-diving for first-level failure triage. The LLM does it.

> **Why Option A over Option B?**  
> Failure explanation gives immediate, actionable value to any developer reading a test report — not just QA engineers. A flaky classifier is useful at scale, but a failure explainer is useful on every single run, immediately. When the team is moving fast, instant context wins.

---

## 🚀 How to Run

### Prerequisites

- Node.js `v18+`
- npm `v9+`

### Installation

```bash
# Clone the repo
git clone https://github.com/arrymulchandani/testmu-sdet1-AryanMulchandani.git
cd testmu-sdet1-AryanMulchandani

# Install dependencies
npm install
```

### Run Tests

```bash
# Run all tests (headless)
npx cypress run

# Run tests with Cypress UI (headed)
npx cypress open

# Run a specific feature
npx cypress run --spec "cypress/e2e/features/login.feature"
```

### View Reports

After a run, find generated reports in the `/reports` directory. AI-generated failure explanations are embedded directly inside the report output.

---

## 🤖 AI Usage Philosophy

Every AI tool used in this project is logged in [`ai-usage-log.md`](./ai-usage-log.md). This isn't a checkbox — it's a record of *how* AI was used as a genuine collaborator, not a shortcut.

Tools used across this project:

| Tool | Purpose |
|------|---------|
| **Claude (Anthropic)** | Framework architecture advice, prompt iteration, failure explainer logic |
| **ChatGPT** | Test case generation drafts, step definition boilerplate |
| **Cursor** | In-editor AI assistance for code scaffolding |

---

## 🔮 What I'd Build Next

Given more time, here's what comes after this foundation:

- **Intelligent regression classification** — feed run history to an LLM and auto-tag tests as stable, flaky, or regression-prone
- **Self-healing locators** — when a selector breaks, use the LLM to suggest the closest matching replacement based on DOM snapshot
- **AI-generated test coverage reports** — not just pass/fail, but *semantic* coverage analysis: "these 3 edge cases are untested"
- **LangChain integration** — build a QA agent that reads product changelogs and auto-generates regression suites for impacted areas
- **CI/CD pipeline** — GitHub Actions with automatic LLM failure triage on every PR

---

## 👤 Candidate

**Aryan Mulchandani**  
TestMu AI · SDET-1 Hackathon Submission

<div align="center">

---

*Built with caffeine, curiosity, and a deep belief that the future of QA is AI-assisted — not AI-replaced.*

</div>
