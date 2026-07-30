[🏠 Master Index](../README.md)

# COBLOX Development Roadmap 2026
## Dari MVP ke Production-Ready — Fairytale Realm Expansion

Berdasarkan: Fairytale Realm Master Blueprint, riset tren Roblox 2026, open-source resources, dan community best practices.

---

## Current State Assessment

| Area | Status | Gap |
|---|---|---|
| World | Placeholder/mock geometry, basic WorldAssembly | No proper 3D assets, lighting mismatch, empty biomes |
| Combat | MVP: basic hit detection (FIXED), 3 weapons | No skills, no enemy variety, no progression |
| Economy | Config-driven, 2 currencies, vault interest | No item market, no crafting economy loop |
| Monetization | 5 GamePasses, 8 DevProducts | No subscription live, no weapon/product tiers |
| Social | CovenService exists, no trading, no co-op | Basic shell, no real social loops |
| UI | Fusion-based, glassmorphism | Cluttered, missing mobile optimization |
| Performance | Unknown | No profiling data |
| Content | 500+ configs (mostly placeholders) | Fairytale content not populated |

---

## Phase A: Foundation & Production Hardening (Sekarang — 2 minggu)

### A1: World Visual Overhaul
```yaml
Priority: P0
Blueprint Ref: Section 2 — World Design
Reference: low-poly fantasy asset packs, Creator Store
```

- [ ] **Replace procedural primitives with mesh assets**
  - Trees: replace `_SpawnStylizedTree` sphere-stacks with Creator Store tree meshes
  - Mobs: replace CreatureBuilder primitives with rigged meshes (FBX → Roblox)
  - Crystals: mesh ManaCrystal models instead of glass parts
  - Hub: add portal arch, sanctum buildings, cosmetic boutique structure
- [ ] **Lighting calibration** — After Voxel migration, recalibrate all presets
- [ ] **Terrain** — Use Roblox Terrain for biome areas instead of flat baseplate
- [ ] **Floating islands** — Replace box parts with actual island meshes + waterfall particles
- [ ] **Asset pipeline** — Upload all assets via `insert_asset` MCP or Open Cloud Assets API

**Open-source resources:**
- Creator Store free models (CC0/CC-BY)
- PolyHaven PBR materials (already referenced in AssetManifest)
- `generate_mesh` MCP tool for AI-generated 3D models

### A2: Combat System Complete
```yaml
Priority: P0
Blueprint Ref: Section 6 — Core Engines
Reference: CCL (Character Controller Library), RateLimitService patterns
```

- [x] **Hit detection fix** — Client searches by MobId attribute (DONE)
- [x] **Weapon system** — Fist/Sword/Staff with range + damage (DONE)
- [ ] **Weapon tiers** — Tier 1-5 scaling (see Economy)
- [ ] **Enemy variety** — 5+ mob types with unique attacks:
  - ShadowWraith: fast, melee
  - CrystalGolem: tank, AoE slam
  - PyroBeast: ranged fireballs
  - AstralSpectre: teleporting, debuff
  - VoidTitan: boss, multi-phase
- [ ] **Skill system** — Per-weapon abilities (Sword: charge slash, Staff: fireball, Fist: combo)
- [ ] **Damage indicators** — Floating damage numbers via BillboardGui pooling
- [ ] **Co-op combat** — Shared aggro, party damage credit
- [ ] **Combat achievements** — Badge triggers for kills, parries, combos

### A3: Economy & Progression Loop
```yaml
Priority: P0
Blueprint Ref: Section 4 + Section 6
Reference: gamedev-economy-crafting skill, compound vault math
```

- [ ] **5-tier weapon progression:**
  | Tier | Weapon | Damage | Price (Coins) | Price (Robux) |
  |---|---|---|---|---|
  | T1 | Fist | 10 | Free | — |
  | T2 | Iron Sword | 25 | 5,000 | — |
  | T3 | Flame Saber | 45 | 25,000 | 79 R$ |
  | T4 | Aether Blade | 75 | 100,000 | 199 R$ |
  | T5 | Void Greatsword | 120 | 500,000 | 499 R$ |
- [ ] **Crafting economy** — Enable AlchemyService + ReactionEngine:
  - Mine crystals → refine materials → craft weapons/potions
  - Recipe discovery system (combine materials to unlock recipes)
- [ ] **Passive income** — Vault compound interest (exists), SetorAura cargo runs
- [ ] **Daily quests** — Enable DailyLoginService rewards (exists)
- [ ] **Battlepass** — SanctumPassService (exists, needs tuning)

---

## Phase B: Monetization & Business (2-4 minggu)

### B1: Product Matrix Live
```yaml
Priority: P1
Blueprint Ref: Section 4A — Commercial Product Matrix
```

| Product | Type | Price | Status |
|---|---|---|---|
| Super Luck | GamePass | 399 R$ | ✅ Existing (reskin) |
| VIP Alchemist | GamePass | 799 R$ | ✅ Existing |
| Auto-Hatch | GamePass | 299 R$ | ✅ Existing |
| +50 Storage | GamePass | 199 R$ | ✅ Existing |
| Celestial Wings | GamePass | 499 R$ | Need Dashboard |
| Coven Guildmaster | GamePass | 999 R$ | Need Dashboard |
| Fairytale Realm Pass | GamePass | 299 R$ | Need Dashboard |
| Monthly Alchemist | Subscription | $4.99/mo | Need Dashboard |
| Weapon Pack T3 | DevProduct | 79 R$ | Need creation |
| Weapon Pack T4 | DevProduct | 199 R$ | Need creation |
| Weapon Pack T5 | DevProduct | 499 R$ | Need creation |

### B2: UGC & Avatar Economy
```yaml
Priority: P2
Blueprint Ref: Section 4B — Avatar Creation Tokens
```

- [ ] AvatarEditorService integration for in-game outfit fitting
- [ ] Creation Token economy (ChronoSparks → mint UGC items)
- [ ] Cosmetic shop (wings, auras, outfits, trails)
- [ ] Seasonal limited cosmetics (FOMO-driven engagement)

### B3: Ad Revenue
```yaml
Priority: P2
Blueprint Ref: Section 4C
```

- [ ] RewardedAdService (DONE — needs client trigger UI)
- [ ] Integrate AdPortal in Central Hub + Fairytale Hub
- [ ] Sponsored campaign management via Open Cloud Ads API

---

## Phase C: Content & Social (4-8 minggu)

### C1: Fairytale Realm Content
```yaml
Priority: P1
Blueprint Ref: Section 2 — Biomes
```

- [ ] 6 biomes fully implemented (not just configs):
  1. Enchanted Forest — trees, mushrooms, fireflies
  2. Aether Sky Citadel — floating islands, waterfalls
  3. Glacial Cavern — ice crystals, caves
  4. Volcanic Forge — lava, gold veins
  5. Void Caves — dark, rare nodes
  6. Central Hub — Sanctum Citadel
- [ ] 30 fairytale spirits (10 in config, need 20 more + models)
- [ ] Fairytale creatures for each biome
- [ ] Fairytale-exclusive recipes and materials

### C2: Social Features
```yaml
Priority: P1
Blueprint Ref: Section 5 — Growth & Virality
Reference: Roblox Groups API, TextChatService
```

- [ ] **Coven/guild system enhancement:**
  - Coven treasury (exists) → shared vault with withdrawal voting
  - Coven hideout (exists) → decorative upgrades
  - Coven raids (exists) → co-op boss fights
  - Coven chat channel via TextChatService
- [ ] **Player trading** — TradeService (exists) needs atomic validation fix
- [ ] **Leaderboard** — LeaderboardService (exists) needs UI
- [ ] **Social virality:**
  - `SocialService:PromptGameInvite` (DONE)
  - Referral rewards (LaunchDataService — exists)
  - ShareLink campaigns
  - Experience notifications for events

### C3: Progression Systems
```yaml
Priority: P2
```

- [ ] Player leveling (XP from kills, mining, crafting)
- [ ] Skill tree (combat, crafting, gathering)
- [ ] Rebirth/prestige system (exists — add cosmetic rewards)
- [ ] Achievements (BadgeService — DONE, need trigger wiring)

---

## Phase D: Technical Excellence (Ongoing)

### D1: Performance
- [ ] Mobile profiling (< 2.5GB RAM target)
- [ ] LOD system for mobs and props
- [ ] Object pooling for VFX (exists)
- [ ] StreamingEnabled tuning
- [ ] Particle budget enforcement

### D2: Security
- [ ] Server-authoritative combat validation
- [ ] Rate limiting on all remote events
- [ ] Anti-exploit teleport validation
- [ ] DataStore atomic operations audit

### D3: CI/CD & DevOps
- [ ] Fix deploy.yml selene issues
- [ ] Add Fairytale place to CI/CD
- [ ] Automated testing (rbx-unit-test skill)
- [ ] Registry generation automation

---

## Phase E: LiveOps & Growth (Post-Launch)

### E1: Live Operations
- [ ] Weekend events (WeekendProvider — exists)
- [ ] Holiday events
- [ ] Double XP/currency weekends
- [ ] Limited-time cosmetics
- [ ] Community challenges

### E2: Analytics & Metrics
- [ ] DAU/MAU tracking via Open Cloud Analytics API
- [ ] Funnel analysis (FTUE completion, D1/D7/D30 retention)
- [ ] Economy balance monitoring
- [ ] Crash rate tracking

### E3: Community & Marketing
- [ ] Discord bot integration (Guilded webhook — exists)
- [ ] Social media campaigns (ShareLinks)
- [ ] Influencer collaboration program
- [ ] UGC creator spotlight

---

## Open-Source Resources & References

### Asset & Content
| Resource | Use |
|---|---|
| Creator Store | Free CC0/CC-BY models for world building |
| PolyHaven (CC0) | PBR materials referenced in AssetManifest |
| MCP `generate_mesh` | AI-generated 3D meshes from text prompts |
| MCP `generate_material` | AI-generated material variants |

### Code & Framework
| Resource | Use |
|---|---|
| react-luau (Roblox/react-luau) | UI framework replacing manual Fusion instances |
| ZonePlus (1ForeverHD/ZonePlus) | Spatial region detection for biomes |
| ProfileStore (MadStudioRoblox/ProfileStore) | Session-locked DataStore (already used) |
| WindShake (boatbomber/WindShake) | Foliage wind physics |
| SimplePath | NPC pathfinding |

### Community & Trends
| Source | Purpose |
|---|---|
| DevForum (devforum.roblox.com) | Engine updates, scripting patterns |
| Roblox Creator Hub | Monetization guidelines, API reference |
| Roblox Status (status.roblox.com) | Service availability monitoring |
| r/robloxgamedev (Reddit) | Community trends, feedback |
| YouTube (Roblox dev channels) | Visual tutorials, case studies |

---

## Success Metrics

| Metric | Current | Target | Method |
|---|---|---|---|
| FTUE completion | UNKNOWN | >65% D1 | AnalyticsService |
| Session length | UNKNOWN | >15min avg | Roblox Dashboard |
| D7 retention | UNKNOWN | >30% | Open Cloud Analytics |
| Crash rate | UNKNOWN | <3% | Studio + Telemetry |
| Economy stability | UNKNOWN | <5% inflation/mo | Economy simulator |
| Mobile RAM | UNKNOWN | <2.5GB | MicroProfiler |
| Concurrent players | 0 | >100 avg | Roblox Dashboard |
| Revenue/player | $0 | >$0.50 ARPU | MonetizationService |
