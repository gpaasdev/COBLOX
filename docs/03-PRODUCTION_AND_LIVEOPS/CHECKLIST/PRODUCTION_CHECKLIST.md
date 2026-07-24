> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# 16 — PRODUCTION CHECKLIST & RELEASE GOVERNANCE
**Version:** 3.0 (Living Operational Command Center & Dashboard)  
**Cross-References:** `docs/README.md`, `07-ENGINEERING_ARCHITECTURE_CONTRACT/ARCHITECTURE.md`, `15-ROADMAP/ROADMAP.md`

---

## 1. Living Operational Dashboard Overview

This checklist serves as the living operational release dashboard and control center for COBLOX. Every item maps directly to a target business KPI, owner, verification evidence, risk level, and review schedule.

---

## 2. Living Operational Audit Dashboard

| Category | Requirement Description | Priority | Status | Owner | Target KPI | Verification Method | Evidence & Last Verified | Blocking Issues | Risk Level | Next Review Date |
| :--- | :--- | :---: | :---: | :--- | :--- | :--- | :--- | :--- | :---: | :---: |
| **Gameplay** | FTUE / Onboarding complete ($<30\text{s}$ to first egg hatch) | CRITICAL | 🟢 READY | GDD Guild | FTUE $<30\text{s}$ | Simulated player playthrough | `PlayableMVPTest.luau` (2026-07-22) | None | LOW | 2026-07-29 |
| **Gameplay** | Rebirth progression loop & multiplier reset verified | HIGH | 🟢 READY | GDD Guild | Session $>15\text{m}$ | Unit test & manual playtest | `IntegrationTest.luau` (2026-07-22) | None | LOW | 2026-07-29 |
| **UX / UI** | Scalable HUD ScreenGui for Mobile, Tablet, Desktop, Gamepad | CRITICAL | 🟢 READY | UX Guild | FTUE $>80\%$ | Multi-device layout preview | `UIController.luau` (2026-07-22) | None | LOW | 2026-07-29 |
| **UX / UI** | Disconnect & error recovery states handling | HIGH | 🟢 READY | UX Guild | Crash $<0.5\%$ | Network interruption test | `ClosedAlphaValidation.luau` (2026-07-22) | None | LOW | 2026-07-29 |
| **Content** | 7 Pet Families & Rarities configured (Common to Secret) | HIGH | 🟢 READY | Content Guild | Content Velocity | Registry asset inspection | `PetData.luau` (2026-07-22) | None | LOW | 2026-07-29 |
| **Content** | Tycoon machines & Dropper Tier 1-2 models mapped | HIGH | 🟢 READY | Content Guild | Content Velocity | Workspace asset check | `TycoonService.luau` (2026-07-22) | None | LOW | 2026-07-29 |
| **Art & VFX** | Polycount budget $<2500$ polys/mesh & low-poly aesthetic | HIGH | 🟢 READY | Art Guild | Crash $<0.5\%$ | MeshPart polycount audit | `docs/05-ART_DIRECTION` (2026-07-22) | None | LOW | 2026-07-29 |
| **Art & VFX** | Active particles $\le 20$ per plot on MacBook Air 2019 baseline | CRITICAL | 🟢 READY | Art Guild | Crash $<0.5\%$ | ParticleEmitter count audit | Architecture Budget (2026-07-22) | None | LOW | 2026-07-29 |
| **Audio** | Master SoundGroup `COBLOX_MasterAudio` initialized | MEDIUM | 🟢 READY | Audio Guild | Session $>15\text{m}$ | SoundService hierarchy check | `AudioController.luau` (2026-07-22) | None | LOW | 2026-07-29 |
| **Economy** | Balance curves, starter coins (100) & gems (10) frozen | CRITICAL | 🟢 READY | Economy Guild | D1 $>40\%$ | `EconomyConfig.luau` audit | `EconomyConfig.luau` (2026-07-22) | None | LOW | 2026-07-29 |
| **Persistence**| Production `DataStoreService` GetAsync/SetAsync integration | CRITICAL | 🟢 READY | Arch Guild | D1 $>40\%$ | `ClosedAlphaValidation.luau` pass | DataStore Key Prefix (2026-07-22) | None | LOW | 2026-07-29 |
| **Security** | Zero-trust server authority for wallet & trade mutations | CRITICAL | 🟢 READY | Arch Guild | D1 $>40\%$ | Exploit rejection suite pass | Exploit Suite Pass (2026-07-22) | None | LOW | 2026-07-29 |
| **LiveOps** | Dynamic event scheduler & feature flag toggles enabled | MEDIUM | 🟢 READY | LiveOps Guild | ARPDAU $>\$0.08$| Config override verification | LiveOps Matrix (2026-07-22) | None | LOW | 2026-07-29 |
| **Analytics** | Telemetry events (`GameJoined`, `EggOpened`, `TradeCompleted`) | HIGH | 🟢 READY | Analytics Guild | Telemetry 100% | `AnalyticsService` event firing | Telemetry Taxonomy (2026-07-22) | None | LOW | 2026-07-29 |
| **Monetization**| Non-intrusive context prompts (+10 Inventory, Instant Coins) | HIGH | 🟢 READY | Economy Guild | ARPDAU $>\$0.08$| Purchase prompt trigger test | Context Triggers (2026-07-22) | None | LOW | 2026-07-29 |

---

## 3. Mandatory Gate Sign-Off Protocol
Global Launch (`Phase 8`) is unlocked only when all 15 audit gates report **🟢 READY** status with verified evidence.
