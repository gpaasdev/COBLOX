> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# COBLOX SYSTEM EVALUATION & IMPLEMENTATION PLAN
> **Status:** Auto-Generated via AI IDE Agent (Phase 0 - Phase 5)
> **Mode:** Continuous Autonomous Development (Zero Reinvention, Evidence-Based)
> **Baseline:** ChatGPT Curated Research Pack

---

## 1. Repository Mapping & Dependency Graph (Phase 0)

### 1.1 Repository Structure
* `src/Server/Services` (65 files): Core backend logic (e.g., `CombatService`, `EconomyService`, `CovenService`).
* `src/Client/Controllers` (30+ files): Core frontend logic (e.g., `CombatController`, `TelemetryController`).
* `src/Shared`: Shared utilities, events, and network (`NetChannels`, `DomainEventBus`).
* `Packages` / `ServerPackages`: Wally-managed dependencies.

### 1.2 Identified Toolchain & Dependencies
* **Persistence:** ProfileStore v1.0.3 (Strictly Server)
* **Utilities:** Signal (sleitnick), Trove, Promise
* **DevTools:** Rojo, Aftman, Selene

---

## 2. Architecture Harmonization Report (Phase 1)

### 2.1 Comparison Against Curated Research
- **Networking:** Curated research suggests `ByteNet` or `Zap` for extreme optimization. COBLOX currently uses standard `RemoteEvent` and `RemoteFunction` wrappers (`NetChannels`).
  - *Decision:* Maintain `NetChannels` but implement `UnreliableRemoteEvent` for visual/VFX replication to meet Roblox Networking Guidelines.
- **Architecture:** COBLOX uses an MVC/Service-Controller architecture with a `DomainEventBus`. Curated research mentions `Matter ECS` and `Jecs`.
  - *Decision:* A full ECS rewrite is an anti-pattern (Overengineering) given the maturity of the Service architecture. Stick to Data-Driven OOP, but adopt ECS-like strict data separation in `MobService` and `WorldAssemblyService`.
- **UI:** Curated research suggests `Fusion` or `ReactRoblox`. 
  - *Decision:* Migrate complex state-heavy UIs to `Fusion` (Phase B) to prevent spaghetti Roact/Vanilla UI code.

### 2.2 Detected Anti-Patterns
- **Placeholders/Mocks:** Already purged from `CombatService` and `SessionService` during initial Autonomous execution.
- **Dead Code/Duplicate Code:** `RateLimitService` scope requires expansion to cover all 14+ remotes.
- **Tight Coupling:** `WorldAssemblyService` (15KB) violates Single Responsibility Principle.

---

## 3. Feature Matrix & Gap Analysis (Phases 2 & 3)

| Feature Domain | Current State | Target Benchmark | Identified Gap |
|---|---|---|---|
| **Networking** | Reliable Only | Roblox Standards (Unreliable) | VFX/Audio over Reliable channels causes queue exhaustion. |
| **UI / UX** | Functional | Factorio / Dyson Sphere (Readable) | Missing Spring animations, Glass surfaces, 8pt grid enforcement. |
| **Performance** | Single Thread | Parallel Luau / StreamingEnabled | Heavy Tycoon/World generation running on main thread. |
| **LiveOps** | Static | RemoteConfig / Feature Flags | Need dynamic weekend event toggles via Open Cloud. |
| **VFX/Audio** | Generic | Deep Rock Galactic (Identity) | Lack of distance culling and GPU particle budgeting. |

---

## 4. Comprehensive Debt Registers

### 4.1 Technical Debt
- Single-threaded `WorldAssemblyService` and `ReactionEngine`.
- Insufficient Rate Limiting coverage for all `RemoteEvents`.
- Need immutable snapshots in `registry/` instead of hardcoded Lua tables.

### 4.2 Creative & UX Debt
- UI lacks modern Roblox tactile feedback (Scale feedback, Spring transitions).
- Environment lacks unified "Industrial Alchemy" Biome Identity.
- Audio lacks dynamic layering for machines.

### 4.3 Security Debt
- Open Cloud API scope needs strict segregation.
- Payload validation exists, but strict type-checking on nested tables is missing in `TradeService` and `AuctionHouseService`.

### 4.4 Performance Debt
- `Instance.new` spam in rendering instead of Object Pooling.
- Lack of StreamingEnabled LOD integration for complex tycoons.

---

## 5. Execution Roadmap & Backlog (Phases 4 & 5)

### Priority 0: Security, Crash & Legacy API (Current Target)
1. **Task:** Implement `RateLimitService` globally across all `NetChannels` listeners.
2. **Task:** Audit `DataStore` calls against Open Cloud v2 limits.
3. **Task:** Refactor `WorldAssemblyService` into `Parallel Luau` Actors.

### Priority 1: Gameplay Core (FTUE, Crafting, Economy)
1. **Task:** Complete Event-Driven FTUE without cinematic placeholders.
2. **Task:** Convert Crafting (`ReactionEngine`) to use strict data-driven `registry/`.
3. **Task:** Implement `Fusion` for Inventory and Crafting UI.

### Priority 2: Experience Polish (UI, Animation, VFX)
1. **Task:** Implement Object Pooling for all VFX and Machine Animations.
2. **Task:** Enforce 8pt grid, Glassmorphism, and Spring animations globally.
3. **Task:** Setup Biome Ambience triggers based on zone.

### Priority 3: Product & LiveOps
1. **Task:** Open Cloud CI/CD pipeline verification.
2. **Task:** RemoteConfig integration for Weekend Events.

---

## 6. Execution Command
The AI IDE Agent has generated the requested Harmonization Report and mapped the backlog. Following the *Continuous Autonomous Development* directive, the agent will now immediately transition to **Phase 6: Code Refactoring**, starting with **Priority 0 (Global Rate Limiting & Parallel Luau setup)** without waiting for manual human approval.
