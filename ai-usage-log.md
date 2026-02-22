# 🤖 AI Usage Log
### TestMu AI · SDET-1 Hackathon · Aryan Mulchandani

> This document is a full audit trail of every AI tool used across this project — what was asked, what it produced, and how it was applied. Logged honestly, exactly as it happened.

---

## Task 1 — Framework Scaffold

| Field | Detail |
|-------|--------|
| **Tool** | Claude Sonnet 4.5 (Anthropic) |
| **Used For** | Designing the folder structure and overall framework architecture |
| **Prompt Intent** | Asked Claude to recommend a clean, scalable Cypress + Cucumber project structure that follows separation of concerns and is ready for future LLM integration |
| **What It Produced** | The full directory layout — `e2e/features`, `stepDefinitions`, `validations`, `pages`, `fixtures`, `support`, `utils`, and `reports` — along with reasoning for each folder's role |
| **How It Was Applied** | Adopted the structure as-is. Empty directories were preserved with `.gitkeep` to maintain structural intent before any tests were written |

---

## Task 2 — Prompt Engineering for Test Generation

### Stage 1 — Initial Test Case Generation

| Field | Detail |
|-------|--------|
| **Tool** | ChatGPT (OpenAI) |
| **Used For** | Generating the first draft of test cases for Login, Dashboard, and REST API modules |
| **Prompt Intent** | Provided module names and scenario types (e.g. brute-force lockout, schema validation, permission-based visibility) and asked for Gherkin-format test cases |
| **What It Produced** | A broad set of BDD scenarios in Gherkin covering the core happy paths and some edge cases across all three modules |
| **Limitation Noticed** | First-pass prompts were too open-ended — the output was generic and missed nuance around session expiry logic, rate limiting behaviour, and filter/sort combinations on the Dashboard |

### Stage 2 — Refinement & Quality Pass

| Field | Detail |
|-------|--------|
| **Tool** | Claude Sonnet 4.5 (Anthropic) |
| **Used For** | Refining the ChatGPT-generated test cases and tightening the prompts |
| **Prompt Intent** | Fed Claude the initial output and asked it to identify gaps, improve Gherkin structure, add missing edge cases, and ensure scenarios were specific enough to be directly implementable |
| **What It Produced** | Cleaner, more precise Gherkin scenarios with proper Given/When/Then structure, realistic test data references, and coverage of edge cases the first pass missed |
| **How It Was Applied** | The refined output was used as the final test case set documented in `prompts.md` |

---

## Task 3 — LLM Integration in the Test Framework

### Code Architecture & Integration Logic

| Field | Detail |
|-------|--------|
| **Tool** | Claude Sonnet 4.5 (Anthropic) |
| **Used For** | Designing the `explainFailure()` function, structuring the Gemini API call, and crafting the prompt sent to the LLM on test failure |
| **Prompt Intent** | Asked Claude how to hook into Cypress's `after()` lifecycle to capture failure context, how to structure the API call, and how to write a prompt that gets a structured, actionable response from an LLM |
| **What It Produced** | The full `explainFailure()` utility — including error handling, graceful fallback when the API key is missing, and the structured 4-question prompt (what broke, root cause, fix, verdict) |
| **Note** | Claude was the architectural brain here — it designed the integration. Gemini was the runtime model that executed inside it |

### AI Model for Live Failure Analysis

| Field | Detail |
|-------|--------|
| **Tool** | Gemini 2.5 Flash (Google) |
| **Used For** | Providing the live AI analysis when a test fails — answering the structured prompt and generating the explanation written to `ai-failure-report.json` |
| **Why Gemini** | Chosen purely for cost — Gemini 2.5 Flash has a free tier that allowed real API calls without billing. Given the choice, Claude would have been the preferred model here given its stronger reasoning on structured prompts |
| **What It Produced** | Plain-English failure explanations with root cause analysis, suggested fixes, and a verdict (real bug / flaky test / test issue) — all written directly into the JSON report |

---

## Summary

| Task | Tool | Role |
|------|------|------|
| Task 1 | Claude Sonnet 4.5 | Framework architecture & folder structure design |
| Task 2 | ChatGPT | First-draft test case generation in Gherkin |
| Task 2 | Claude Sonnet 4.5 | Test case refinement, gap analysis, prompt improvement |
| Task 3 | Claude Sonnet 4.5 | Integration design, API call structure, prompt engineering |
| Task 3 | Gemini 2.5 Flash | Live LLM runtime — failure analysis & report generation |

---

*AI was used as a collaborator throughout — to think faster, structure better, and go deeper. Every output was reviewed, adapted, and owned by the engineer.*
