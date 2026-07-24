> **[🏠 Master Index](../MASTER_INDEX.md) | [⬅️ Back to Docs](../README.md)**

# 08 — ENGINEERING STANDARDS & CODE CONVENTIONS

## 1. Static Typing & Linting Rules
- All files must include `--!strict` header.
- `Selene` static analysis must pass with 0 warnings.
- `StyLua` formatting must be applied pre-commit.

## 2. Code Bounds
- Max 300 lines per module.
- Max 40 lines per function.
- Cyclomatic complexity $< 10$.

## 3. Definition of Done (DoD)
A task is DONE only when Rojo builds cleanly, tests pass, Selene passes, and memory/particle budgets are verified.

---
*Cross-Reference:* See `09-AI_AGENT_CONTRACT/AGENT_CONTRACT.md` for AI validation enforcement and `14-ADR/ADR.md` for design decisions.
