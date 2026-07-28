# COBLOX Project Reference
# Dokumen SSOT (Single Source of Truth) untuk semua AI agent yang bekerja di repo ini.
# Dibaca bersama AGENTS.md dan roblox_architect.md.
# Jika ada pertentangan: AGENTS.md (root) > COBLOX_PROJECT_REFERENCE.md > dokumen lain.

---

## §0. Identitas Proyek (Konfirmasi Wajib Sebelum Operasi)

| Parameter | Nilai | Status |
|---|---|---|
| Repo | `github.com/gpaasdev/COBLOX` | ✅ Confirmed |
| Pemilik | `hycoblox` (ID: 11329819428) | ✅ Confirmed |
| Universe ID | **10545905192** | ⚠️ Konfirmasi ke Creator Dashboard — ada 2 kandidat berbeda antar dokumen lama |
| Place ID | Lihat Creator Dashboard | ⚠️ Konfirmasi sebelum dipakai di script |
| Engine | Roblox Luau `--!strict` | ✅ Confirmed |
| Genre | Pet Tycoon & Social Action Alkimia | ✅ Confirmed (README menang) |
| Status | Production Validation Phase | ✅ Confirmed |
| Web portal | `web/` → Next.js → Vercel/GitHub Pages | ✅ Confirmed |

> **LARANGAN:** Jangan hardcode Universe ID / Place ID ke source code atau script sebelum ketidakcocokan angka di atas diklarifikasi langsung ke Creator Dashboard.

## §0b. Multi-Place Architecture

| Parameter | Nilai | Status |
|---|---|---|
| Universe ID | 10545905192 | ✅ Confirmed |
| Place 1 — Main Realm | `ROBLOX_PLACE_ID` | Lihat `.env` |
| Place 2 — Fairytale Realm | `ROBLOX_FAIRYTALE_PLACE_ID` | ⚠️ Buat via Studio → Publish to Roblox As... → "Add as new place" |
| Realm auto-detect | `RuntimeServer.server.luau` → `RealmRegistry` | ✅ Implemented |
| Cross-realm teleport | `RealmTeleportService` via `TeleportService:TeleportAsync` | ✅ Implemented |
| Realm config | `RealmConfig.luau` (theme + lighting presets) | ✅ Implemented |

**Deployment:**
- `default.project.json` → Main Place (existing)
- `fairytale/default.project.json` → Fairytale Place (build via `rojo build fairytale/`)
- CI/CD: `.github/workflows/deploy.yml` dual-place jobs (Fairytale disabled via `FAIRYTALE_DEPLOY_ENABLED` var)

**Realm auto-detection at boot:**
```luau
-- RuntimeServer.server.luau
for key, entry in pairs(RealmRegistry) do
    if entry.PlaceId == game.PlaceId then
        RealmConfig.CurrentTheme = entry.Theme
    end
end
```

---

## §1. Stack & Toolchain (Terverifikasi)

| Tool | Versi | Perintah | Catatan |
|---|---|---|---|
| Rojo | 7.4.1 | `rojo serve default.project.json` | Sync `.luau` ↔ Studio |
| Aftman | — | `aftman install` | Toolchain manager |
| Selene | 0.27.1 | `selene src/` | Linter wajib sebelum commit |
| Compliance audit | — | `python scripts/validate_rgs_compliance.py` | Bukan Ez-Test |
| Deploy | — | `python scripts/deploy_opencloud.py` | Butuh konfirmasi pemilik repo |
| ProfileStore | v1.0.3 | via `lm-loleris/profilestore` | Server-only via Wally |
| Signal | 2.0.1 | `sleitnick/signal` | Custom typed events |
| Trove | 1.1.0 | `sleitnick/trove` | Lifecycle/cleanup wajib |

---

## §2. Peta Rojo (dari `default.project.json`)

| Path Lokal | Roblox Instance | Konteks |
|---|---|---|
| `src/Shared` | `ReplicatedStorage.Shared` | Server + Client |
| `Packages` | `ReplicatedStorage.Packages` | Server + Client |
| `src/Server` | `ServerScriptService.Server` | Server only |
| `ServerPackages` | `ServerScriptService.ServerPackages` | Server only |
| `src/Content` | `ServerScriptService.Content` | Server only |
| `src/LiveOps` | `ServerScriptService.LiveOps` | Server only |
| `src/Client` | `StarterPlayer.StarterPlayerScripts.Client` | Client only |

---

## §3. Arsitektur & Boot Order

### Server Bootstrap (`RuntimeServer.server.luau`)
Urutan `Init()` → `Start()` (urutan ini kritis, jangan diubah tanpa alasan):

```
1.  RateLimitService           ← Anti-exploit gate, WAJIB pertama
2.  RemoteConfigService        ← Feature flags
3.  ExperimentService          ← A/B testing
4.  LiveOpsService             ← LiveOps dispatch
5.  PolicyComplianceService    ← ToS enforcement
6.  LaunchDataService          ← Telemetry launch
7.  PlayerDataService          ← Player profile (kritis)
8.  ProfileStoreAdapter        ← DataStore session lock
9.  RetentionService           ← D1/D7 hooks
10. StoryService / SanctumPassService / AdminService
11. CombatService / MobService / CovenService / ExpeditionService / QuestManager / OnboardingService / StoreService
12. WorldAssemblyService / AnalyticsService / MonetizationService
13. EconomyService / RecipeService / PlacementService / PetService / EggService / TycoonService / TradeService
14. PotionVaultService / OfflineEarningsService / GlobalBroadcastService / ShadowRaidService
15. CrystalPurificationService / ConsumableMutationService / KarmaContractService / FlexZoneService
```

### Client Bootstrap (`RuntimeClient.client.luau`)
Locked startup order (diinisialisasi dulu, baru yang lain):
```
1. TelemetryController
2. AccessibilityController
3. LightingController
4. ActionMenuController
5. ARLensController
+ UIController, TopbarController, AudioController, CombatController (tidak terikat urutan)
```

---

## §4. Daftar RemoteEvents Terdaftar
> **Audit Riil**: 2026-07-27 — cross-checked dengan `grep` across `src/Server/Services` & `src/Client/Controllers`.

| Remote Name | Server Listener | Client Receiver | Tipe Aktual | Status |
|---|---|---|---|---|
| `SyncKarmaContract` | KarmaContractService | KarmaContractController | Reliable | ✅ OK |
| `PetMiningEvent` | PetService | PetRenderController | **Reliable** | ⚠️ Kandidat Unreliable (VFX only) |
| `SyncShieldStatus` | ShadowRaidService | ShadowRaidController | **Reliable** | ⚠️ Kandidat Unreliable (VFX only) |
| `SubmitFeedback` | FeedbackService | — | Reliable | ✅ OK |
| `SyncQuest` | QuestManager | QuestController | Reliable | ✅ OK |
| `CovenEvent` | CovenService | CovenController | Reliable | ✅ OK |
| `CombatEvent` | CombatService | CombatController | Reliable | ✅ OK (MobWindup juga dikirim via ini) |
| `SyncEconomy` | EconomyService/MonetizationService | UIController | Reliable | ✅ OK |
| `RequestPlacement` | PlacementService | PlacementController | Reliable | ✅ OK |
| `ExpeditionEvent` | ExpeditionService | — | Reliable | ✅ OK |
| `TriggerScreenShake` | ConsumableMutationService | MutationController | Reliable | ⚠️ Kandidat Unreliable (haptic/screen only) |
| `EggHatchedVisual` | EggService | EggRenderController | **✅ UnreliableRemoteEvent** | ✅ SUDAH DIIMPLEMENTASI — `EggService.luau:59,214` |
| `BroadcastServerMessage` | GlobalBroadcastService | BroadcastBannerController | Reliable | ✅ OK |
| `RetentionEvent` | RetentionService | — | Reliable | ✅ OK |
| `RequestGrab` | InteractionService | InteractionController | RemoteFunction | ✅ OK |
| `RequestDrop` | InteractionService | InteractionController | RemoteFunction | ✅ OK |
| `RequestThrow` | InteractionService | InteractionController | RemoteFunction | ✅ OK |
| `RequestCrystalPurification` | CrystalPurificationService | — | RemoteFunction | ✅ OK |
| `RequestCraft` | RecipeService | SynthesisController | RemoteFunction | ✅ OK |
| `CraftRecipe` | AlchemyService | AlchemyController | RemoteFunction | ✅ OK |
| `RequestEquipPet` | PetService | PetRenderController | RemoteFunction | ✅ OK |
| `RequestBuyUpgrade` | TycoonService | TycoonRenderController | RemoteFunction | ✅ OK |

> **Catatan Audit**: `EggHatchedVisual` sudah pakai `UnreliableRemoteEvent` (terverifikasi `EggService.luau:59`). 3 kandidat tersisa: `PetMiningEvent`, `SyncShieldStatus`, `TriggerScreenShake`.

---

## §5. Domain Boundaries (11 Bounded Context)

| Domain | Services Utama | Controllers Terkait |
|---|---|---|
| ⚗️ Alchemy & Crafting | AlchemyService, RecipeService, ReactionEngine, CrystalPurificationService, ConsumableMutationService, PotionVaultService | AlchemyController, SynthesisController, MutationController |
| ⚔️ Combat & PvP | CombatService, MobService, ShadowRaidService, KarmaContractService | CombatController, ShadowRaidController, KarmaContractController |
| 🐾 Pet & Egg | PetService, EggService | PetRenderController, EggRenderController |
| 👥 Social & Guild | CovenService, TradeService, AuctionHouseService | CovenController, TradeController |
| 🌍 World & Environment | WorldAssemblyService (15KB), PlacementService, TycoonService, FlexZoneService, ResourceService | PlacementController, TycoonRenderController |
| 📈 Progression | QuestManager, StoryService, ExpeditionService, RetentionService, SanctumPassService, OfflineEarningsService | QuestController, FTUEController, OfflineEarningsController |
| 💰 Economy & Store | EconomyService, MonetizationService, StoreService | StoreController, MonetizationController |
| 🔧 Infrastructure | LiveOpsService, RemoteConfigService, ExperimentService, AnalyticsService, RateLimitService | TelemetryController, PerformanceMonitorController |
| 🛡️ Admin & Security | AdminService, PolicyComplianceService, ModerationSyncService | AdminDashboardController, PolicyComplianceController |
| 🌐 Cross-Server | CrossServerMessagingService, GlobalBroadcastService | BroadcastBannerController |
| 🧠 NPC & AI | MobService, NPCPsychologyService, SocialSimulationService | — |

---

## §6. Open Cloud API Scope (Least Privilege)

| Endpoint | Env Var | Scope | Fungsi |
|---|---|---|---|
| DataStores R/W | `ROBLOX_OPENCLOUD_API_KEY` | `universe.datastores.read`, `universe.datastores.write` | Web Dashboard — inspeksi/edit data player |
| MemoryStores | `ROBLOX_OPENCLOUD_API_KEY` | `universe.memorystores.write` | Leaderboard global, AuctionHouse lintas server |
| User Restrictions | `ROBLOX_OPENCLOUD_API_KEY` | `universe.user-restrictions.write` | Banning API via Discord Bot/Admin |
| Publishing | `ROBLOX_OPENCLOUD_API_KEY` | `universe.places.write` | CI/CD auto-publish via GitHub Actions |
| Luau Execution | `ROBLOX_OPENCLOUD_API_KEY` | `universe.luau-execution.write` | Hotfix jarak jauh — ⚠️ HIGH RISK, butuh konfirmasi pemilik |

> **Satu API key** dengan scope gabungan, disimpan di `.env` (gitignored) dan GitHub Actions secrets. Jangan pernah tulis literal di source.

---

## §7. Gap yang Teridentifikasi
> **Audit Riil**: 2026-07-27 — semua item di bawah terverifikasi dengan `grep` / baca langsung file .luau.

### 7A. Bugs Kritis (Broken Calls — Terverifikasi)

| # | Bug | File:Line | Bukti Grep | Severity |
|---|---|---|---|---|
| B1 | `EconomyService.GrantCoins()` tidak ada → AutoMining **tidak berfungsi** | `PetService.luau:80` | `grep "GrantCoins" src/` → 1 hit (caller), 0 hit (definition) | 🔴 BLOCKER |
| B2 | `PlayerDataService.SavePlayerProfile()` tidak ada → dipanggil dalam `pcall` (error tersembunyi) | `MonetizationService.luau:170` | `grep "SavePlayerProfile" src/` → 1 hit (caller), 0 hit (definition) | 🔴 BLOCKER |
| B3 | `AlchemyService` require `"BroadcastService"` (tidak ada) → `WaitForChild` akan hang selamanya | `AlchemyService.luau:12` | File adalah `GlobalBroadcastService`, bukan `BroadcastService` | 🔴 BLOCKER |
| B4 | `inventory.MaxStorage` tidak ada di `DataTypes.InventoryData` → pet storage check selalu nil→false | `PetService.luau:127` | `grep "MaxStorage" DataTypes.luau` → 0 hit | 🔴 HIGH |
| B5 | Hard currency ledger check `(initialBalance + amount) ~= finalBalance` selalu false untuk integer Lua | `EconomyService.luau:130` | Lua integer arithmethic: tidak ada float drift untuk whole numbers. **Bug logic**: check valid tapi terpicu pada float input | 🟡 MEDIUM |
| B6 | `ResourceService` mutasi `profileRes.Data.Inventory[itemId]` langsung (bukan `.Inventory.Items[itemId]`) → field salah | `ResourceService.luau:119` | `grep ".Data.Inventory\[" src/` | 🔴 HIGH |
| B7 | `ProfileStoreAdapter.SafeUpdateProfile()` tidak pernah dipakai oleh services lain | semua mutation services | `grep -rn "SafeUpdateProfile" src/` → 0 hit di luar `ProfileStoreAdapter.luau` sendiri | 🔴 HIGH — session lock tidak enforce |

### 7B. Architecture Gaps

| # | Gap | File | Status |
|---|---|---|---|
| A1 | `RateLimitService` tidak cover: `CombatEvent_Attack`, `CovenEvent_Create`, `CovenEvent_Donate`, `RequestGrab`, `RequestThrow`, `CraftRecipe`, `RequestCrystalPurification` | `RateLimitService.luau:17-25` | 🔴 Perlu tambah 7 action |
| A2 | 3 kandidat event masih Reliable: `PetMiningEvent`, `SyncShieldStatus`, `TriggerScreenShake` | §4 di atas | 🟡 Upgrade ke Unreliable |
| A3 | Dua direktori config terpisah: `Shared/Config/` (18 files) & `Shared/Configuration/` (12 files) — tidak ada konvensi jelas | Lihat §11 | 🟡 Konsolidasi |
| A4 | `CovenService` data hanya in-memory (`activeCovens` table) — tidak persist ke DataStore | `CovenService.luau` | 🔴 HIGH — data hilang saat server shutdown |
| A5 | Parallel Luau: 1 Actor saja (`MobActor`) | `src/Server/Actors/` | 🟡 WorldAssemblyService (15KB) masih main thread |
| A6 | `AlchemyService` memanggil `print()` palsu sebagai "DataStore update for Vercel" | `AlchemyService.luau:100` | 🟡 Bukan actual telemetry write |

---

## §8. Avatar & Aset Spesifikasi

Untuk aset layered clothing/kosmetik yang digunakan di COBLOX:
- Inner + outer cage R15
- ≤ 10.000 triangle per part
- ≤ 4 bone influence per vertex
- Format upload: `.fbx`

> ⚠️ Limit Roblox bisa berubah — selalu verifikasi ke [dokumentasi resmi terkini](https://create.roblox.com/docs/avatar) sebelum finalisasi aset.

---

## §9. Arsitektur Web Portal (`web/`)

```
web/
├── src/app/
│   ├── (public)/           ← Landing, leaderboard, halaman publik
│   ├── (admin)/            ← Dashboard admin (protected)
│   ├── api/                ← API routes → Open Cloud REST API
│   ├── llms.txt/           ← LLM-readable sitemap (AI SEO)
│   └── llms-full.txt/      ← Full live knowledge base
│       └── route.ts        ← Fetch live stats dari getUniverseStats() + getTopPlayers()
├── src/lib/
│   ├── roblox.ts           ← Open Cloud REST API client
│   └── db.ts               ← Prisma DB client
└── prisma/                 ← Schema DB
```

Web portal adalah **proyek terpisah** dari Roblox game. Jangan campur task Luau dengan task web kecuali diminta eksplisit.

---

## §10. Bug Tracker Aktif (Status Real-Time)
> **Diupdate**: 2026-07-27 via audit grep riil. Tandai `[FIXED]` ketika selesai.

| ID | Status | Deskripsi Singkat | File |
|---|---|---|---|
| B1 | `[OPEN]` | `GrantCoins` → harus `AddCurrency` | PetService.luau:80 |
| B2 | `[OPEN]` | `SavePlayerProfile` tidak ada | MonetizationService.luau:170 |
| B3 | `[OPEN]` | `BroadcastService` → harus `GlobalBroadcastService` | AlchemyService.luau:12 |
| B4 | `[OPEN]` | `MaxStorage` field tidak ada di DataTypes | PetService.luau:127 |
| B5 | `[OPEN]` | Ledger check logic | EconomyService.luau:130 |
| B6 | `[OPEN]` | Inventory direct-index (bukan `.Items`) | ResourceService.luau:119 |
| B7 | `[OPEN]` | `SafeUpdateProfile` zero usage | semua mutation services |

---

## §11. Catatan Arsitektur Config (Duality Issue)
> **Teridentifikasi**: 2026-07-27

Ada **dua direktori config** yang tumpang tindih:
- `src/Shared/Config/` → 18 files: Generated registries, ClientConfig, CovenConfig, LODConfig, MachineRegistry, dll.
- `src/Shared/Configuration/` → 12 files: EconomyConfig, EggData, LiveOpsConfig, MonetizationConfig, PetData, QuestConfig, RecipeConfig, WorldConfig, ZoneConfig, dll.

**Konvensi yang disepakati (belum diapply):**
- `Shared/Config/` = Generated/auto-generated registries (jangan edit manual)
- `Shared/Configuration/` = Hand-authored game config (edit manual oleh developer)

> Sebelum eksekusi implementasi, pastikan semua service import dari direktori yang tepat. `AlchemyService` import `RecipeConfig` dari `Configuration` ✅ — sudah benar.
