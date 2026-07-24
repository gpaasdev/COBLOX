> **[🏠 Master Index](../MASTER_INDEX.md) | [⬅️ Back to Docs](../README.md)**

# 09 — AI AGENT CONTRACT & LIVE BUSINESS OPERATING SYSTEM (LGBOS)
**Version:** 4.0 (LGBOS Production Governance Edition)  
**Cross-References:** `docs/README.md`, `07-ENGINEERING_ARCHITECTURE_CONTRACT/ARCHITECTURE.md`, `08-ENGINEERING_STANDARDS/STANDARDS.md`, `16-PRODUCTION_CHECKLIST/PRODUCTION_CHECKLIST.md`

---

## 1. Executive Directive: Live Business Operating System

All AI IDE Agents (Google Antigravity, Gemini, Claude Code, Cursor, Codex) MUST operate under the **Live Roblox Business Operating System (LGBOS)** principles:

$$\text{Acquire} \longrightarrow \text{Activate} \longrightarrow \text{Retain} \longrightarrow \text{Monetize} \longrightarrow \text{Expand} \longrightarrow \text{Automate} \longrightarrow \text{Repeat}$$

The objective is no longer to build systems; the objective is to continuously grow player acquisition, activation, retention, lifetime value, revenue, and content velocity.

---

## 2. Permanent Production Priority Hierarchy

AI IDE Agents MUST always prioritize work using the following non-negotiable hierarchy:

$$\text{P0 Production Bugs} \longrightarrow \text{Player Experience} \longrightarrow \text{Retention} \longrightarrow \text{Content Velocity} \longrightarrow \text{Monetization} \longrightarrow \text{LiveOps} \longrightarrow \text{Analytics} \longrightarrow \text{Docs Maintenance}$$

---

## 3. Core Architecture Freeze & Configuration-Driven Rules

1. **Frozen Services:** `SaveService`, `EconomyService`, `EggService`, `PetService`, `TycoonService`, `TradeService`, `RuntimeServer`, `RuntimeClient`.
2. **Refactor Restriction:** Core services may ONLY be modified for critical production bugs, security vulnerabilities, performance regressions, or approved ADRs.
3. **Configuration-Driven Growth:** Gameplay additions MUST occur via configuration files:
   - New Pets $\to$ `src/Shared/Configuration/PetData.luau`
   - New Eggs $\to$ `src/Shared/Configuration/EggData.luau`
   - New Tycoon Machines $\to$ `src/Shared/Configuration/EconomyConfig.luau`
   - Weekend Events / Season Passes $\to$ `src/LiveOps/`

---

## 4. Standardized Task Output Handshake Contract (v4.0)

Every AI Agent task output MUST adhere to this envelope:

```markdown
### AGENT TASK OUTPUT CONTRACT
- **Summary:** Brief overview of implemented production changes.
- **Files Modified/Created:** Clickable `file://` links.
- **Targeted Business KPI:** Identified primary KPI (e.g., FTUE <30s, D1 >40%, ARPDAU >$0.08).
- **Configuration-Driven Check:** Verified addition via frozen config modules without core service refactor.
- **Production Checklist Audit Impact:** Status, Evidence, Last Verified, Risk Level updated in `16-PRODUCTION_CHECKLIST.md`.
- **Security & Exploit Check:** Zero-trust compliance verified.
- **Performance Budget Impact:** RAM (<6 GB), CPU (<5%), Particles (<=20) verified.
- **Verification Plan & Commands:** Step-by-step test procedures.
- **Suggested Next Prompt Envelope:** Immediate actionable next prompt.
```
