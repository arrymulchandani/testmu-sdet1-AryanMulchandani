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
[![AI Powered](https://img.shields.io/badge/AI%20Powered-Gemini%202.5%20Flash-blueviolet?style=for-the-badge&logo=google&logoColor=white)]()
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

> **Why Option A over Option B?**  
> Failure explanation gives immediate, actionable value to any developer reading a test report — not just QA engineers. A flaky classifier is useful at scale, but a failure explainer is useful on every single run, immediately. When the team is moving fast, instant context wins.

#### How It Works — End to End

```
Test Fails
    │
    ▼
Cypress after() hook captures:
  • Test name
  • Raw Cypress error message
    │
    ▼
explainFailure() sends a structured prompt to
Gemini 2.5 Flash via REST API:
  • What likely broke?
  • Root cause?
  • Suggested fix?
  • Real bug / flaky test / test issue?
    │
    ▼
Gemini responds with a structured plain-English analysis
    │
    ▼
Result is written to cypress/reports/ai-failure-report.json
as a JSON array entry with three fields:
  {
    "test":       <test name>,
    "error":      <raw Cypress error>,
    "aiAnalysis": <full Gemini explanation>
  }
```

Every failed test appends its own entry to `ai-failure-report.json`, so a single report file captures the full AI triage for an entire test run. No manual log-diving — open one file, get the full picture.

#### Sample Report Output

```json
[
  {
    "test": "Intentional failure to trigger AI explanation",
    "error": "Timed out retrying after 4000ms: Expected to find element: '.this-element-does-not-exist', but never found it.",
    "aiAnalysis": "### Test Analysis\n\n**Error Message:** Timed out retrying...\n\n#### 1. What likely broke?\nThe test execution failed because Cypress attempted to locate a DOM element with the CSS selector `.this-element-does-not-exist` but it was absent within the 4000ms timeout.\n\n#### 2. Root Cause?\nThe element targeted by the selector was not present in the DOM — possibly a missing/removed feature, an incorrect selector, a timing/race condition, or an incorrect page state.\n\n#### 3. Suggested Fix?\n- Inspect the DOM manually to verify the element exists\n- If it should be there → report as an Application Bug\n- If the selector is wrong → update the test step\n- If it's a timing issue → increase timeout (last resort)\n\n#### 4. Verdict\n**Real Bug** — if the element is required by the spec and the app fails to render it."
  }
]
```

---

## 🚀 How to Run

### Prerequisites

- Node.js `v18+`
- npm `v9+`
- A valid **Gemini API key** (for the LLM Failure Explainer)

### Installation

```bash
# Clone the repo
git clone https://github.com/arrymulchandani/testmu-sdet1-AryanMulchandani.git
cd testmu-sdet1-AryanMulchandani

# Install dependencies
npm install
```

### Environment Setup

Create a `.env` file in the root of the project:

```bash
GEMINI_API_KEY=your_gemini_api_key_here
```

> Without this key, the AI analysis step is skipped gracefully and a message is logged instead.

### Running the LLM Failure Explainer

The AI integration lives in the `llm-failure-explainer` feature file. Run it with:

```bash
npx cypress run --spec "cypress/e2e/features/llm-failure-explainer.feature"
```

This will intentionally trigger a test failure, send the error to **Gemini 2.5 Flash**, and write the full AI analysis to:

```
cypress/reports/ai-failure-report.json
```

> **Note:** The other feature files (Login, Dashboard, API) contain the test cases from Task 2 and are not wired to the LLM. They are structured as BDD scenarios for framework demonstration purposes only.

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

> *A story set inside the TestMu AI platform — one sprint, one engineer, and an AI teammate that changes everything.*

---

It's Monday morning. The team just shipped a new release of the TestMu dashboard. The regression suite has 300 tests. Nobody wants to babysit them.

Here's how I'd evolve this framework — using the TestMu ecosystem itself — to make that problem disappear.

---

**🧠 Step 1 — Let KaneAI write the tests**

Instead of hand-authoring every Gherkin scenario, I'd feed KaneAI the TestMu product spec and have it generate regression test cases for Login, Dashboard, and API automatically. The prompt engineering work from Task 2 becomes a template KaneAI iterates on — human intent in, executable test cases out. First draft in minutes, not days.

---

**⚡ Step 2 — Pipe every failure through the AI Failure Explainer**

Right now, the Gemini integration runs on demand. Next, I'd hook it into the TestMu test run lifecycle — so every time a test fails inside a TestMu-managed suite, the AI analysis fires automatically and the explanation lands directly in the TestMu test report UI. No terminal. No log files. Just open your results and the AI has already told you what broke and why.

---

**🔁 Step 3 — Close the loop with HyperExecute**

I'd run the full suite on **HyperExecute** — TestMu's distributed cloud grid — so 300 tests finish in minutes in parallel. Each failed job triggers the Gemini explainer. Each explanation gets written back to the TestMu dashboard as a structured failure card: root cause, verdict (real bug / flaky / test issue), and suggested fix. The QA engineer's job shifts from *finding* failures to *triaging* the AI's findings.

---

**🛡️ Step 4 — Proactive coverage with TestMu's AI Test Manager**

Finally, I'd connect the framework to TestMu's test management layer so it can track which user flows have zero automated coverage. When a new feature ships, the system flags untested areas and KaneAI generates candidate tests for review. Coverage gaps become visible before they become production bugs.

---

The result: a QA loop where KaneAI writes, HyperExecute runs, Gemini explains, and the TestMu dashboard surfaces everything — with a human making decisions, not spending hours in logs.

---

## 👤 Candidate

**Aryan Mulchandani**  
TestMu AI · SDET-1 Hackathon Submission

<div align="center">

---

*Built with caffeine, curiosity, and a deep belief that the future of QA is AI-assisted — not AI-replaced.*

</div>
