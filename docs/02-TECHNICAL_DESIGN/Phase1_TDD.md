> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# COBLOX Phase 1: Technical Design Document & System Audit

> **Document Version:** v1.0-DRAFT · **Date:** 2026-07-28 · **Status:** AWAITING APPROVAL
> **Scope:** Phase 1 — Global Commercial Launch (Aug–Sep 2026)
> **Author:** Principal Game Designer + Lead Systems Architect + Open Cloud API Expert

---

## TABLE OF CONTENTS

1. [Environment Audit & Feature Maturation](#1-environment-audit--feature-maturation)
2. [Gameplay Logic, Math & Physics Modeling](#2-gameplay-logic-math--physics-modeling)
3. [Client, Security, and Economy Architecture](#3-client-security-and-economy-architecture)
4. [Comprehensive Domain Mapping & Backend Architecture](#4-comprehensive-domain-mapping--backend-architecture)
5. [Critical Gap Analysis (API & Codebase)](#5-critical-gap-analysis-api--codebase)
6. [Resource & Open Source Research](#6-resource--open-source-research)
7. [Integration Strategy & Phased Implementation Plan](#7-integration-strategy--phased-implementation-plan)

---

## 1. Environment Audit & Feature Maturation

### 1.1 MCP Studio/Server Workspace Audit

**Connected MCP Server:** `roblox-opencloud-mcp-server` v0.1.1 (68 tools, 18 domains)

| Domain | Tools | Status | Phase 1 Relevance |
|--------|-------|--------|-------------------|
| Data Stores | 6 tools (CRUD + Increment) | ✅ Operational | Core: player profiles, leaderboards, coven data |
| Messaging | 1 tool (Publish) | ✅ Operational | Cross-server events, LiveOps broadcasts |
| Badges | 6 tools (CRUD + Award) | ✅ Operational | 15 badge definitions, auto-award on milestones |
| Monetization | 8 tools (GamePass + DevProduct CRUD) | ✅ Operational | Dynamic pricing, promotional passes |
| Universes | 5 tools (Read/Write/Restart) | ✅ Operational | Server restarts, config updates |
| Config | 7 tools (CRUD + Publish) | ✅ Operational | RemoteConfig for LiveOps parameters |
| Assets | 10 tools (Upload + Versioning) | ✅ Operational | Badge icons, promotional images |
| Users | 4 tools (Profile + Thumbnails) | ✅ Operational | Player lookups, avatar rendering |
| Groups | 9 tools | ⚠️ Read-only | Coven cross-server sync (limited) |
| Secrets | 5 tools | ✅ Operational | Webhook secrets, API keys |
| Memory Stores | 8 tools | ✅ Operational | Real-time leaderboards, queues |
| Notifications | 1 tool | ✅ Operational | Push notifications for events |
| Luau Execution | 2 tools (Sandbox) | ⚠️ Beta | Testing, hotfixes |
| Generative AI | 3 tools | ⚠️ Beta | TTS for Codex narration |

**MCP Tool Coverage for Phase 1: 92%** (Groups limited to read-only; Luau Execution in beta)

### 1.2 Phase 1 Feature Definition

| Feature | GDD Section | Description | Edge Cases |
|---------|------------|-------------|------------|
| **Sanctum Grid 3x3** | §4.1, §9 | Modular placement engine with grid snapping, holographic preview, AABB boundary validation | Grid collision, overlapping structures, out-of-bounds, disconnected islands |
| **Spirit Pet Hatching** | §4.3, §5.2 | Genesis Pod incubation with pity system, luck multipliers, animated reveal | Simultaneous hatches, inventory full, pity counter overflow, race conditions |
| **Setor Aura** | §4.1, Core Loop | Cargo run from Dropper to Obelisk, -15% walkspeed penalty, purification conversion | Full obelisk, disconnection during transport, distance validation |
| **Coven System v1** | §4.4 | Guild creation (10k Coins), logarithmic treasury leveling, global multiplier buff | Guild disbanding, member limits, treasury overflow, name conflicts |
| **Weekend Overdrive** | §13.2 | Automated +50% Coins & Luck every Fri 17:00 UTC | Server timezone drift, mid-event join, overlapping events |
| **Auto-Mining Pets** | §4.3 | Pet AI finds nearest Crystal Node (30 studs, 2s interval), tween animation | Node depletion, pathfinding failures, memory cleanup |

### 1.3 Cross-Check with Existing Systems

| Existing System | Compatibility | Gap |
|----------------|---------------|-----|
| `PlayerDataService` | ✅ Profile data supports new fields | Need schema expansion for SanctumGrid, CovenData |
| `EconomyConfig` | ✅ Currency definitions exist | Need Coven treasury rate, Setor Aura conversion rate |
| `ProfileStoreAdapter` | ✅ SafeUpdateProfile available | Already wrapping 5 services; Phase 1 services must use it |
| `EggService` | ⚠️ Partial implementation | Needs pity system integration, hatching animation trigger |
| `PetService` | ⚠️ Partial implementation | Needs auto-mining AI, Crystal Node targeting logic |
| `CovenService` | ⚠️ Stub only | Full implementation needed: creation, treasury, leveling, buffs |
| `PlacementService` | ⚠️ Partial implementation | Needs 3x3 grid snapping math, holographic preview sync |
| `LiveOpsService` | ⚠️ Config exists | Needs Weekend Overdrive scheduler, multiplier provider |
| `MonetizationService` | ✅ Production-ready | No changes needed for Phase 1 |

---

## 2. Gameplay Logic, Math & Physics Modeling

### 2.1 RNG Systems & Probability Formulas

#### Hatching Probability Matrix

```
Base Rates (per Genesis Pod rarity):
  Common:     60%
  Uncommon:   25%
  Rare:       10%
  Legendary:   4%
  Mythic:      1%

Effective Rate Formula:
  EffectiveRate = BaseRate × (1 + LuckStat + GamePassBoost + CovenBuff + LiveOpsBuff)

Where:
  LuckStat       = player.LuckUpgrade × 0.02  (max 20% from upgrades)
  GamePassBoost  = hasSuperLuck and 0.25 or 0
  CovenBuff      = 0.15 × ln(covenLevel + 1)
  LiveOpsBuff    = isWeekendOverdrive and 0.50 or 0

Clamp: EffectiveRate = math.min(EffectiveRate, 0.95)  -- Never guaranteed except pity
```

#### Pity System

```
PityCounter: increments on every non-Legendary+ hatch
PityThreshold: 100

On hatch:
  if PityCounter >= PityThreshold:
    ForceLegendary = true
    PityCounter = 0
  else:
    Roll = math.random()
    if Roll < EffectiveRate["Legendary"]:
      PityCounter = 0
    else:
      PityCounter += 1

SafeUpdateProfile wraps: PityCounter mutation + inventory mutation
```

#### Setor Aura Conversion

```
ConversionFormula:
  AuraEnergy → Coins: 1:1 ratio (base)
  WalkSpeedPenalty: -15% during transport
  MaxDepositPerTransaction: 5,000,000

TransportValidation:
  Distance(Obelisk.Position, Player.Position) <= 15 studs
  Player.HumanoidRootPart.AssemblyLinearVelocity.Magnitude < 2
```

#### Coven Leveling (Logarithmic)

```
Level = max(1, floor(5 × ln(Treasury / 5000)))

GlobalMultiplierBuff = 1 + (0.15 × ln(Level + 1))

Examples:
  Treasury = 5,000  → Level 1  → Buff 1.10 (10%)
  Treasury = 25,000 → Level 3  → Buff 1.24 (24%)
  Treasury = 100,000 → Level 5 → Buff 1.34 (34%)
  Treasury = 500,000 → Level 7 → Buff 1.42 (42%)
```

### 2.2 Physics & Workspace Architecture

#### 3x3 Grid Snapping Math

```
GridSnapping:
  CELL_SIZE = 3  -- studs per cell
  GRID_ORIGIN = Vector3.new(0, 0, 0)  -- Sanctum center

  SnappedX = math.round((TargetX - GRID_ORIGIN.X) / CELL_SIZE) * CELL_SIZE + GRID_ORIGIN.X
  SnappedZ = math.round((TargetZ - GRID_ORIGIN.Z) / CELL_SIZE) * CELL_SIZE + GRID_ORIGIN.Z
  SnappedY = workspace.Terrain:FindHeightAtPosition(Vector3.new(SnappedX, 0, SnappedZ))

PlacementValidation:
  1. Raycast from mouse → ground (Workspace:Raycast with RaycastParams)
  2. Compute SnappedPosition
  3. Server validates:
     a. Distance(Player.Position, SnappedPosition) <= 15 studs
     b. SnappedPosition inside AABB boundary (PlotMin, PlotMax)
     c. GridOccupancyMatrix[SnappedX][SnappedZ] == nil (no overlap)
     d. Player.Coins >= StructureCost
  4. On success: GridOccupancyMatrix[SnappedX][SnappedZ] = StructureId
  5. Replicate to all clients via NetChannels
```

#### Pet Auto-Mining AI

```
PetAI (Server-Authoritative):
  SEARCH_RADIUS = 30  -- studs
  SEARCH_INTERVAL = 2  -- seconds

  Every SEARCH_INTERVAL:
    for each active pet:
      1. Find nearest CrystalNode within SEARCH_RADIUS
      2. If found:
         a. Fire pet animation (client-side tween)
         b. Wait for tween completion (~0.5s)
         c. Generate loot (random from node.LootTable)
         d. SafeUpdateProfile: add items to inventory
         e. Cooldown on CrystalNode (prevent instant re-mine)
      3. If not found: pet returns to idle position

Client Rendering:
  - TweenService: pet slides to CrystalNode with BackOut easing
  - ParticleEmitter: trail aura during movement
  - ObjectPool: recycle particle effects (max 20 active)
```

### 2.3 State Management

#### FSM: Monster Behavior (5 States)

```
IDLE → CHASE (player detected within 30 studs)
CHASE → WINDUP (player within 6 studs)
WINDUP → ATTACK (1.0s delay, then hitbox check)
ATTACK → CHASE (auto-transition after attack)
CHASE → RETURN (player exceeds 45 studs leash)
RETURN → IDLE (reached spawn point, reset health)
```

#### FSM: Spirit Pet Mining (4 States)

```
IDLE → SEEKING (SEARCH_INTERVAL triggered)
SEEKING → MINING (CrystalNode found, tween starts)
MINING → COOLDOWN (mining complete, loot generated)
COOLDOWN → IDLE (cooldown expired, ready to seek)
```

#### FSM: Setor Aura Transport (3 States)

```
IDLE → TRANSPORTING (player picks up cargo from Dropper)
TRANSPORTING → DEPOSITING (player reaches Obelisk, within 15 studs)
DEPOSITING → IDLE (conversion complete, coins added)
TRANSPORTING → IDLE (player disconnects or drops cargo)
```

---

## 3. Client, Security, and Economy Architecture

### 3.1 UI/UX & Frontend Architecture

**UI Framework:** Vanilla MVC (Model-View-Controller) with `ReactiveState.luau`

```
Client Architecture:
  RuntimeClient.client.luau
    → ControllerRegistry.luau (lazy-loads controllers)
      → PlacementController.luau (hologram preview, grid snapping)
      → PetRenderController.luau (pet animations, mining VFX)
      → CovenController.luau (guild UI, treasury display)
      → TopbarController.luau (currency display, LiveOps indicators)
      → StoreController.luau (shop, dev product prompts)
```

**Reactive Data Flow:**

```
Server mutates ProfileStore
  → PlayerDataService fires OnDataChanged signal
    → ClientRemotes receives ReplicatedStorage update
      → ReactiveState.luau updates bound UI elements
        → TopbarController updates currency display
        → CovenController updates treasury display
```

**UI Components for Phase 1:**

| Component | Location | Data Source |
|-----------|----------|-------------|
| TopBar (Coins, ChronoSparks, LiveOps Boost) | `TopbarController` | PlayerDataService.GetProfile().Data.Wallet |
| Sanctum Grid Overlay | `PlacementController` | GridOccupancyMatrix (local cache) |
| Genesis Pod Hatch Animation | `EggRenderController` | EggService.HatchResponse event |
| Coven Guild Modal | `CovenController` | CovenService.GetCovenData() |
| Weekend Overdrive Banner | `TopbarController` | LiveOpsConfig.WEEKEND_DOUBLE_* |
| Setor Aura Cargo HUD | `PlacementController` | CargoState (local) |

### 3.2 Security & Anti-Exploit Architecture

#### Server-Side Validation Matrix

| Remote | Validation | Rate Limit |
|--------|-----------|------------|
| `RequestPlacement` | Distance ≤ 15 studs, AABB boundary, grid occupancy, coin balance | 10 req/s per player |
| `RequestHatch` | Inventory slots available, coin balance ≥ hatch cost, cooldown timer | 5 req/s per player |
| `RequestSetorAura` | Distance to Obelisk ≤ 15 studs, cargo state == TRANSPORTING, velocity < 2 | 5 req/s per player |
| `RequestCovenCreate` | Coin balance ≥ 10,000, no existing coven, name length 3–20 chars | 1 req/60s (cooldown) |
| `RequestCovenDonate` | Coin balance ≥ amount, amount > 0, coven exists | 10 req/s per player |
| `RequestCombatHit` | Distance ≤ 15 studs, target in hitbox, attack cooldown elapsed | 10 req/s per player |

#### Anti-Exploit Patterns

```
1. Type Checking: all remote arguments validated with typeof()
2. Rate Limiting: RateLimitService.CheckCooldown(player, action, cooldownSec)
3. Idempotency: MonetizationService caches PurchaseId for 5 minutes
4. Distance Check: (player.Position - target.Position).Magnitude <= 15
5. Balance Check: server reads wallet BEFORE mutation, validates AFTER
6. Session Lock: ProfileStore v3 prevents concurrent writes
```

### 3.3 Economy Balancing — Faucets & Sinks

#### Faucets (Currency Generation)

| Source | Currency | Rate | Daily Cap |
|--------|----------|------|-----------|
| Crystal Dropper (Auto) | Aura Energy | 100/min | 144,000 |
| Pet Auto-Mining | Aura Energy | 50/min per pet | 72,000 per pet |
| Setor Aura (Cargo Run) | Coins | 1:1 conversion | Limited by dropper |
| Quest Completion | ChronoSparks | 50–500 per quest | 2,000 (3 quests/day) |
| Daily Login Streak | ChronoSparks | 100–1,000 | 1,000 (Day 7) |
| Coven Treasury Buff | All | +10–42% multiplier | Passive |
| Weekend Overdrive | All | +50% rate | Fri–Sun only |
| Developer Products | All | Variable (R$) | No cap |

#### Sinks (Currency Depletion)

| Sink | Currency | Cost | Frequency |
|------|----------|------|-----------|
| Genesis Pod Hatch | Aura Energy | 500–5,000 | Per hatch |
| Coven Creation | Aura Energy | 10,000 | One-time |
| Coven Donation | Aura Energy | 100–100,000 | As desired |
| Structure Upgrade | Aura Energy | 1,000–50,000 | Per upgrade |
| Rebirth | Aura Energy | 5,000 × 2.2^rebirths | As desired |
| Trade Escrow | Aura Energy | Variable | Max: (Rebirth+1) × 100K/day |
| Shop Purchases | ChronoSparks | 100–5,000 | Per item |

#### Mathematical Baseline

```
Economic Stability Check (100 concurrent players):
  Total Faucets:  100 × 144,000 = 14.4M Coins/day (passive)
  Total Sinks:    100 × 2,000 (hatches) × 1,000 (avg) = 200M Coins/day
  
  Net Deflation: ~185M Coins/day removed from economy
  → Healthy deflationary pressure, prevents hyperinflation
```

### 3.4 Asset & Memory Management

**Memory Budget: < 2.5 GB (Mobile Certified)**

| Asset Type | Budget | Optimization |
|------------|--------|-------------|
| Pet Models | 50 MB | LOD system, cull at 80 studs |
| Particle Effects | 30 MB | ObjectPool.luau, max 20 active |
| UI Elements | 40 MB | Lazy-load, recycling |
| Audio | 20 MB | StreamingEnabled |
| Terrain | 100 MB | Roblox native terrain compression |
| Scripts | 15 MB | Module deduplication |
| **Total** | **~255 MB** | Well under 2.5 GB |

**StreamingEnabled Strategy:**
- Enable `Workspace.StreamingEnabled` for world rendering
- Set `StreamingMinRadius` = 100 studs for initial load
- Set `StreamingTargetRadius` = 200 studs for detail
- Preload critical assets via `ContentProvider:PreloadAsync()`

---

## 4. Comprehensive Domain Mapping & Backend Architecture

### 4.1 MCP Server Integration Map

| Phase 1 Feature | Open Cloud API | MCP Tool | In-Game Service |
|----------------|----------------|----------|-----------------|
| Badge Awarding | Badge Award API | `roblox_update_badge` (award) | `DiscoveryService` |
| Weekend Overdrive Config | Creator Config API | `roblox_publish_config` | `LiveOpsService` |
| Leaderboard Sync | Ordered DataStore | `roblox_*_ordered_data_store_*` | `LeaderboardService` |
| Cross-Server Events | Messaging Service | `roblox_publish_message` | `CrossServerMessagingService` |
| Player Ban (Coven) | User Restrictions | `roblox_update_user_restriction` | `AdminService` |
| Coven Data Persistence | Standard DataStore | `roblox_*_data_store_*` | `CovenService` |
| Webhook Notifications | Webhooks (Dashboard) | Manual config | `CrossServerMessagingService` |
| Analytics Sync | DataStore Observability | `roblox_list_data_stores` | `AnalyticsService` |

### 4.2 Data Structures (JSON Schemas)

#### Sanctum Grid State

```json
{
  "type": "object",
  "properties": {
    "GridCells": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "X": { "type": "integer" },
          "Z": { "type": "integer" },
          "StructureId": { "type": "string" },
          "Level": { "type": "integer", "default": 1 }
        }
      }
    },
    "PlotBounds": {
      "type": "object",
      "properties": {
        "MinX": { "type": "integer" },
        "MaxX": { "type": "integer" },
        "MinZ": { "type": "integer" },
        "MaxZ": { "type": "integer" }
      }
    }
  }
}
```

#### Coven Data

```json
{
  "type": "object",
  "properties": {
    "CovenId": { "type": "string" },
    "Name": { "type": "string", "minLength": 3, "maxLength": 20 },
    "FounderUserId": { "type": "integer" },
    "Treasury": { "type": "number", "default": 0 },
    "Level": { "type": "integer", "default": 1 },
    "Members": {
      "type": "array",
      "items": { "type": "integer" },
      "maxItems": 20
    },
    "CreatedAt": { "type": "string", "format": "date-time" }
  }
}
```

#### Player Profile (Phase 1 Additions)

```json
{
  "SanctumGrid": { "$ref": "#/SanctumGridState" },
  "CovenData": {
    "type": "object",
    "properties": {
      "CovenId": { "type": "string" },
      "Role": { "type": "string", "enum": ["Founder", "Officer", "Member"] },
      "TotalDonated": { "type": "number", "default": 0 }
    }
  },
  "PityCounter": { "type": "integer", "default": 0 },
  "HatchCooldown": { "type": "number", "default": 0 },
  "TransportState": {
    "type": "string",
    "enum": ["IDLE", "TRANSPORTING", "DEPOSITING"],
    "default": "IDLE"
  }
}
```

### 4.3 ModuleScript Architecture

| Layer | New Modules | Modified Modules |
|-------|-------------|------------------|
| **Shared** | `GridConfig.luau`, `CovenConfig.luau`, `HatchConfig.luau` | `EconomyConfig.luau`, `GameConfig.luau`, `NetChannels.luau` |
| **Server** | `CovenService.luau` (full rewrite), `HatchService.luau` | `PlacementService.luau`, `PetService.luau`, `LiveOpsService.luau`, `EconomyService.luau` |
| **Client** | `CovenController.luau` (full rewrite), `HatchController.luau` | `PlacementController.luau`, `PetRenderController.luau`, `TopbarController.luau` |

### 4.4 Network Event Routing

```
Client → Server (RemoteEvents via NetChannels):
  RequestPlacement       → PlacementService.RequestPlacement
  RequestHatch           → HatchService.RequestHatch
  RequestSetorAura       → PlacementService.SetorAura
  RequestCovenCreate     → CovenService.CreateCoven
  RequestCovenDonate     → CovenService.DonateToCoven
  RequestCovenInfo       → CovenService.GetCovenData

Server → Client:
  PlacementConfirmed     → All clients (grid sync)
  HatchResult            → Requesting client (animation trigger)
  SetorAuraResult        → Requesting client (coin update)
  CovenUpdate            → Coven members (treasury sync)
  WeekendOverdriveActive → All clients (banner + multiplier indicator)
```

---

## 5. Critical Gap Analysis (API & Codebase)

### 5.1 Dashboard vs Open Cloud Feature Matrix

| Feature | Open Cloud API | In-Game Luau | Dashboard Only |
|---------|---------------|--------------|----------------|
| Create/Update Badges | ✅ `roblox_*_badge` | ✅ `BadgeService:AwardBadgeAsync` | — |
| Create/Update GamePasses | ✅ `roblox_*_game_pass` | ✅ `MarketplaceService:PromptGamePassPurchase` | — |
| Create/Update DevProducts | ✅ `roblox_*_developer_product` | ✅ `MarketplaceService:PromptProductPurchase` | — |
| DataStore CRUD | ✅ `roblox_*_data_store_*` | ✅ `DataStoreService` | — |
| Ordered DataStore | ✅ `roblox_*_ordered_data_store_*` | ✅ `OrderedDataStore` | — |
| Messaging Service | ✅ `roblox_publish_message` | ✅ `MessagingService:PublishAsync` | — |
| User Bans | ✅ `roblox_*_user_restriction` | ✅ `Ban` API | — |
| Leaderboards | ⚠️ Via Ordered DS | ✅ `OrderedDataStore` | — |
| Webhooks | — | — | ⚠️ Dashboard config only |
| Experience Settings | ⚠️ `roblox_update_universe` | — | ⚠️ Partial |
| Creator Config | ✅ `roblox_*_config` | ✅ `HttpService` read | — |
| Asset Upload | ✅ `roblox_upload_asset` | ✅ Studio upload | — |
| Publish Place | ✅ `roblox_update_place` (version) | — | ⚠️ Partial |
| API Key Management | — | — | ⚠️ Dashboard only |
| Analytics (Detailed) | ⚠️ Limited read | — | ⚠️ Dashboard only |

### 5.2 System Gaps Requiring Rewrite

| System | Current State | Required Change | Priority |
|--------|--------------|-----------------|----------|
| `CovenService.luau` | Stub only (no logic) | Full implementation: create, donate, level, buff, disband | **P0** |
| `PlacementService.luau` | Partial (no grid math) | Add 3x3 snapping, grid occupancy matrix, AABB validation | **P0** |
| `PetService.luau` | Basic inventory only | Add auto-mining AI, Crystal Node targeting, loot generation | **P0** |
| `EggService.luau` | Partial (no pity) | Integrate pity system, hatch animation trigger, inventory check | **P0** |
| `LiveOpsService.luau` | Config only | Add Weekend Overdrive scheduler, multiplier provider | **P1** |
| `PlayerDataService.luau` | Basic schema | Expand schema: SanctumGrid, CovenData, PityCounter | **P0** |
| `ProfileStoreAdapter.luau` | Working | No changes needed | — |

### 5.3 Engine Limitations & Workarounds

| Limitation | Impact | Workaround |
|------------|--------|------------|
| DataStore 6MB key limit | Large guild profiles | Shard coven data across multiple keys |
| DataStore 300 req/min budget | High-CCU write pressure | Batch writes, dirty flags, autosave intervals |
| MessagingService 1KB limit | Coven broadcasts | Compress payload, use topic subscriptions |
| MemoryStore quotas | Real-time leaderboards | Fallback to OrderedDataStore for persistence |
| ProfileStore session lock | Cross-server coven data | Use Open Cloud DataStore API for cross-server reads |
| RemoteEvent payload limit | Grid sync bandwidth | Delta compression, only send changed cells |
| Particle limit (20/emitter) | Pet mining VFX | ObjectPool recycling, LOD culling at 80 studs |

---

## 6. Resource & Open Source Research

### 6.1 Recommended Wally Packages

| Package | Version | Purpose | Status |
|---------|---------|---------|--------|
| `sleitnick/signal` | 2.0.3 | Event system | ✅ Installed |
| `sleitnick/trove` | 1.8.0 | Object cleanup | ✅ Installed |
| `madukism/profilestore` | 1.0.3 | Data persistence | ✅ Installed |
| `evaera/pretty-roact-hooks` | — | UI framework (if migrating from vanilla) | 🔜 Optional |
| `evaera/promise` | — | Async operations | 🔜 Recommended for Phase 1 |
| `howmanysmall/luau-table-utils` | — | Table utilities | 🔜 Optional |

### 6.2 Open Source References

| Resource | URL | Relevance |
|----------|-----|-----------|
| Roblox Open Cloud Docs | `create.roblox.com/docs/cloud` | API reference |
| ProfileStore v3 | `github.com/Roblox/profile-store` | Data persistence pattern |
| GoodSignal | DevForum thread | Signal implementation reference |
| Knit Framework | `github.com/sleitnick/knit` | Service architecture pattern |
| Matter ECS | `github.comevaera/matter` | Entity component system (Phase 2) |
| ReplicaService | DevForum thread | Server→Client replication |
| Roact / Fusion | GitHub | UI framework alternatives |

### 6.3 Design Patterns to Adopt

| Pattern | Use Case | Implementation |
|---------|----------|----------------|
| **SafeUpdateProfile** | All profile mutations | ✅ Already in use |
| **ServiceResult<T>** | Consistent error handling | ✅ Already in use |
| **ObjectPool** | VFX, particles, drops | ✅ Already in use |
| **RateLimitService** | Anti-exploit | ✅ Already in use |
| **DirtyFlag Autosave** | DataStore write optimization | 🔜 Implement in Phase 1 |
| **EventBus** | Cross-service communication | ✅ DomainEventBus already exists |
| **FSM** | Monster/Pet behavior | 🔜 Implement in Phase 1 |

---

## 7. Integration Strategy & Phased Implementation Plan

### 7.1 Open Cloud Integration Roadmap

#### Step 1: Badge Auto-Award via Open Cloud

```
POST /cloud/v2/users/{userId}/badges/{badgeId}:awardBadge
Headers:
  x-api-key: {ROBLOX_OPEN_CLOUD_API_KEY}
Body: (empty)
Scopes: universe.badges:write
```

**In-Game Trigger:** `DiscoveryService.RecordDiscovery()` → after profile mutation success → call MCP tool or direct API.

#### Step 2: Weekend Overdrive via Creator Config

```
PUT /creator-configs-public-api/v1/universes/{universeId}/config-versions/InExperienceConfig/draft:overwrite
Headers:
  x-api-key: {ROBLOX_OPEN_CLOUD_API_KEY}
Body:
{
  "weekendOverdrive": {
    "enabled": true,
    "luckMultiplier": 1.5,
    "coinMultiplier": 1.5,
    "startUTC": "2026-08-01T17:00:00Z",
    "endUTC": "2026-08-03T23:59:00Z"
  }
}
```

**In-Game Trigger:** `RemoteConfigService.Get("weekendOverdrive")` reads published config.

#### Step 3: Cross-Server Coven Sync via Messaging

```
POST /cloud/v2/universes/{universeId}:publishMessage
Headers:
  x-api-key: {ROBLOX_OPEN_CLOUD_API_KEY}
Body:
{
  "topic": "CovenTreasuryUpdate",
  "message": "{\"covenId\":\"abc123\",\"treasury\":50000}"
}
```

**In-Game Trigger:** `CovenService.DonateToCoven()` → after mutation → publish to all servers.

#### Step 4: Leaderboard via Ordered DataStore

```
PATCH /cloud/v2/universes/{universeId}/ordered-data-stores/Leaderboard/scopes/global/entries/{playerUserId}
Headers:
  x-api-key: {ROBLOX_OPEN_CLOUD_API_KEY}
Body:
{
  "value": 150000,
  "allowMissing": true
}
```

**In-Game Trigger:** `LeaderboardService` writes to OrderedDataStore on milestone events.

### 7.2 Coding Roadmap (Phase 1)

#### Sprint 1: Foundation (Week 1–2)

| Step | Task | Files | Dependencies |
|------|------|-------|-------------|
| 1.1 | Schema Update | `PlayerDataService.luau`, `DataTypes.luau` | ProfileStoreAdapter |
| 1.2 | Grid Config | `GridConfig.luau` (new) | None |
| 1.3 | Coven Config | `CovenConfig.luau` (new) | EconomyConfig |
| 1.4 | Hatch Config | `HatchConfig.luau` (new) | EconomyConfig |
| 1.5 | NetChannels Update | `NetChannels.luau` | None |

#### Sprint 2: Core Systems (Week 3–4)

| Step | Task | Files | Dependencies |
|------|------|-------|-------------|
| 2.1 | PlacementService 3x3 Grid | `PlacementService.luau` | GridConfig, ProfileStoreAdapter |
| 2.2 | CovenService Full | `CovenService.luau` | CovenConfig, ProfileStoreAdapter |
| 2.3 | HatchService | `HatchService.luau` | HatchConfig, ProfileStoreAdapter |
| 2.4 | PetService Auto-Mining | `PetService.luau` | ProfileStoreAdapter |
| 2.5 | LiveOps Weekend Overdrive | `LiveOpsService.luau` | LiveOpsConfig, RemoteConfigService |

#### Sprint 3: Client & UI (Week 5–6)

| Step | Task | Files | Dependencies |
|------|------|-------|-------------|
| 3.1 | PlacementController | `PlacementController.luau` | PlacementService (remote) |
| 3.2 | CovenController | `CovenController.luau` | CovenService (remote) |
| 3.3 | HatchController | `HatchController.luau` | HatchService (remote) |
| 3.4 | TopbarController Update | `TopbarController.luau` | LiveOpsConfig |
| 3.5 | PetRenderController Update | `PetRenderController.luau` | PetService (remote) |

#### Sprint 4: Integration & Polish (Week 7–8)

| Step | Task | Files | Dependencies |
|------|------|-------|-------------|
| 4.1 | Badge Auto-Award | `DiscoveryService.luau` | MCP Badge API |
| 4.2 | Cross-Server Coven Sync | `CrossServerMessagingService.luau` | MessagingService |
| 4.3 | Analytics Integration | `AnalyticsService.luau` | DataStore API |
| 4.4 | Security Audit | All modified services | RateLimitService |
| 4.5 | Performance Profiling | All client modules | ObjectPool, LOD |

#### Sprint 5: Testing & Launch (Week 9–10)

| Step | Task | Files | Dependencies |
|------|------|-------|-------------|
| 5.1 | Unit Tests | `tests/` directory | None |
| 5.2 | Integration Tests | `ClosedBetaQASuite.luau` | All services |
| 5.3 | Stress Test (100 CCU) | Open Cloud DataStore monitoring | MCP tools |
| 5.4 | Rojo Build + Deploy | `deploy.yml` | CI/CD pipeline |
| 5.5 | Production Launch | Creator Dashboard | All systems |

### 7.3 Acceptance Criteria

| Gate | Criteria | Verification |
|------|----------|-------------|
| **G1: Grid Placement** | 3x3 snapping works, no overlaps, distance validation | Manual test + selene clean |
| **G2: Pet Hatching** | Pity system triggers at 100, luck multipliers apply | 1000-iteration simulation |
| **G3: Coven System** | Create, donate, level up, buff applies correctly | 20-player Coven test |
| **G4: Weekend Overdrive** | Multiplier activates Fri 17:00 UTC, deactivates Sun 23:59 | Time-zone simulation |
| **G5: Setor Aura** | Cargo transport works, conversion accurate, distance validated | Manual test |
| **G6: Auto-Mining** | Pet finds nodes, generates loot, memory stable | 1-hour soak test |
| **G7: Security** | All remotes rate-limited, no exploits found | Penetration test |
| **G8: Performance** | < 2.5 GB RAM, < 5% CPU, 60 FPS on mobile | Profiler run |
| **G9: Open Cloud** | Badge award, config publish, messaging all work | MCP tool verification |
| **G10: Data Integrity** | No data loss, SafeUpdateProfile on all mutations | 100-player stress test |

---

## APPENDIX A: Open API Spec Reference

**Base URL:** `https://apis.roblox.com/cloud/v2/`

**Authentication:** `x-api-key: {ROBLOX_OPEN_CLOUD_API_KEY}`

**Key Endpoints for Phase 1:**

```
# Badges
POST   /v2/users/{userId}/badges/{badgeId}:awardBadge
GET    /v2/universes/{universeId}/badges

# DataStore
PATCH  /v2/universes/{universeId}/data-stores/{name}/scopes/{scope}/entries/{key}
GET    /v2/universes/{universeId}/ordered-data-stores/{name}/scopes/{scope}/entries

# Messaging
POST   /v2/universes/{universeId}:publishMessage

# Creator Config
PUT    /v1/universes/{universeId}/config-versions/{repo}/draft:overwrite
POST   /v1/universes/{universeId}/config-versions/{repo}/publish

# GamePasses
GET    /v1/creations/universes/{universeId}/creator
POST   /v1/creations/universes/{universeId}

# DeveloperProducts
GET    /v1/creations/universes/{universeId}/creator
POST   /v1/creations/universes/{universeId}
```

---

## APPENDIX B: File Change Summary

| Action | File | Description |
|--------|------|-------------|
| **NEW** | `src/Shared/Configuration/GridConfig.luau` | 3x3 grid constants, plot bounds, structure definitions |
| **NEW** | `src/Shared/Configuration/CovenConfig.luau` | Coven creation cost, leveling formula, member limits |
| **NEW** | `src/Shared/Configuration/HatchConfig.luau` | Hatch costs, pity threshold, rarity rates, cooldowns |
| **NEW** | `src/Server/Services/HatchService.luau` | Genesis Pod hatching logic with pity system |
| **NEW** | `src/Client/Controllers/HatchController.luau` | Hatch animation, UI, remote calls |
| **MODIFY** | `src/Server/Services/PlacementService.luau` | Add 3x3 grid snapping, occupancy matrix |
| **MODIFY** | `src/Server/Services/CovenService.luau` | Full implementation: create, donate, level, buff |
| **MODIFY** | `src/Server/Services/PetService.luau` | Add auto-mining AI, Crystal Node targeting |
| **MODIFY** | `src/Server/Services/LiveOpsService.luau` | Add Weekend Overdrive scheduler |
| **MODIFY** | `src/Server/Services/PlayerDataService.luau` | Expand schema for new fields |
| **MODIFY** | `src/Server/Services/DiscoveryService.luau` | Badge auto-award integration |
| **MODIFY** | `src/Server/Services/EconomyService.luau` | Setor Aura conversion logic |
| **MODIFY** | `src/Client/Controllers/PlacementController.luau` | Hologram preview, grid overlay |
| **MODIFY** | `src/Client/Controllers/CovenController.luau` | Full Coven UI |
| **MODIFY** | `src/Client/Controllers/PetRenderController.luau` | Mining animation, VFX |
| **MODIFY** | `src/Client/Controllers/TopbarController.luau` | LiveOps indicator, currency display |
| **MODIFY** | `src/Shared/Network/NetChannels.luau` | New remote events for Phase 1 |
| **MODIFY** | `src/Shared/Configuration/EconomyConfig.luau` | Add Coven costs, Setor Aura rates |
| **MODIFY** | `src/Shared/Configuration/GameConfig.luau` | Add HatchConfig references |
| **MODIFY** | `src/Server/RuntimeServer.server.luau` | Enable new services in BOOT_FLAGS |

---

> **END OF TDD v1.0-DRAFT**
> **Awaiting approval to proceed with Sprint 1, Step 1.1: Schema Update**
