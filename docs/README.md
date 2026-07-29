> **[🏠 Master Index](MASTER_INDEX.md) | [⬅️ Back to Docs](README.md)**

# COBLOX PRODUCT BIBLE & MASTER SSOT HIERARCHY
**Version:** 11.0 (Live Game Business Operating System Edition — LGBOS)  
**Target Engine:** Roblox Luau (`--!strict`)  
**Hardware Baseline:** MacBook Air Retina 2019 (Intel i5, 16GB RAM)  
**Execution Platform:** Google Antigravity 2.0 AI Agent Workspace  

---

## 1. Executive Directive: Live Business Operating System (LGBOS)

COBLOX operates strictly as a **Live Roblox Business Product**. Every engineering decision, content update, LiveOps event, and monetization experiment MUST improve measurable production KPIs.

$$\text{Acquire} \longrightarrow \text{Activate} \longrightarrow \text{Retain} \longrightarrow \text{Monetize} \longrightarrow \text{Expand} \longrightarrow \text{Automate} \longrightarrow \text{Repeat}$$

---

## 2. Permanent Production Priority (P0 to Maintenance)

$$\text{P0 Production Bugs} \longrightarrow \text{Player Experience} \longrightarrow \text{Retention} \longrightarrow \text{Content Velocity} \longrightarrow \text{Monetization} \longrightarrow \text{LiveOps} \longrightarrow \text{Analytics} \longrightarrow \text{Docs Maintenance}$$

---

## 3. Weekly Production Cadence & Velocity Rules

- **Monday:** Production KPI & Telemetry Review
- **Tuesday:** Gameplay Experience & FTUE Improvements
- **Wednesday:** New Content Deployment (Pets, Eggs, Machines)
- **Thursday:** Balancing & Economy Tuning
- **Friday:** Multi-device QA & Security Verification
- **Saturday:** LiveOps Weekend Event Activation ($2\times$ Luck / Coins)
- **Sunday:** Analytics Review & Iteration Planning

Every release MUST deliver at least one visible content asset: *New Egg, New Pets, New Machine, New Area, New Quest, New Rebirth Layer, or Weekend Event*. "Empty updates" are forbidden.

---

## 4. Core Architecture Freeze & Configuration-Driven Growth

1. **Frozen Services:** `SaveService`, `EconomyService`, `EggService`, `PetService`, `TycoonService`, `TradeService`, `RuntimeServer`, `RuntimeClient`.
2. **Refactor Restriction:** Core services may ONLY be modified for critical production bugs, security vulnerabilities, performance regressions, or approved ADRs.
3. **Configuration-Driven Growth:** Gameplay additions MUST occur via configuration files:
   - New Pets $\to$ `src/Shared/Configuration/PetData.luau`
   - New Eggs $\to$ `src/Shared/Configuration/EggData.luau`
   - New Tycoon Machines $\to$ `src/Shared/Configuration/EconomyConfig.luau`
   - Weekend Events / Season Passes $\to$ `src/LiveOps/`

---

## 5. Repository Growth Governance

After v11.0, code repository growth is strictly restricted to content and config directories:
- ✅ `src/Shared/Configuration/`
- ✅ `src/Content/`
- ✅ `src/Assets/`
- ✅ `src/Shared/Localization/`
- ✅ `src/LiveOps/`

Documentation (`docs/`), architecture, and speculative research are frozen in maintenance mode.
