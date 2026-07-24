> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# 📚 Research Notes — Roblox Cloud, Analytics, Engine Reference & Safety
## COBLOX: Multiverse Alchemy Sanctum

> **Kebijakan Dokumen:** File ini **kumulatif** — riset baru selalu ditambahkan (append), tidak pernah menimpa. Setiap update menambah Changelog entry.

## 📅 Changelog
| Tanggal           | Versi | Perubahan                                                                             |
| -------------------| -------| ---------------------------------------------------------------------------------------|
| 2026-07-23 T12:30 | v1.0  | Initial: Cloud, Analytics, Economy Events, Engine Reference, Open Cloud               |
| 2026-07-23 T16:42 | v1.1  | Added: Optimization strategies for Places, Characters, Accessories, and Products      |

---

## 4. Optimasi Engine Roblox: Places, Avatars, Accessories & Products

Berdasarkan referensi *Roblox Engine API*, berikut adalah pedoman inti untuk memaksimalkan performa dan fungsionalitas komponen utama game:

### 4.1. Experiences & Places (Universes)
* **Workspace.StreamingEnabled:** Wajib diaktifkan untuk map besar. Fitur ini secara dinamis memuat (*load*) dan melepas (*unload*) *Parts* di sekitar pemain, mengurangi beban memori klien (< 6GB RAM target).
* **TeleportService:** Untuk game *multi-place* (misal: Main Hub ke Dungeon), gunakan `TeleportService:TeleportAsync`. Selalu sertakan layar *loading* kustom (Teleport UI) agar UX tetap *seamless*.
* **Memory Management:** Hindari membiarkan objek fisik tak terpakai di `Workspace`. Gunakan `Debris` service atau `ObjectPool` untuk proyektil, efek visual sementara, dan node UI.

### 4.2. Characters & Avatars
* **HumanoidDescription API:** Jangan merakit (*weld*) aksesoris secara manual. Gunakan `Players:GetHumanoidDescriptionFromUserId()` dan `Humanoid:ApplyDescription()` untuk mengganti baju, animasi, atau wujud karakter secara instan dan efisien.
* **Client-Side Physics (Network Ownership):** Berikan *Network Ownership* (kepemilikan jaringan) kepada pemain untuk *Parts* yang mereka kendalikan langsung (seperti proyektil skill atau kendaraan) agar gerakan terasa mulus tanpa latensi server.
* **Collision Groups:** Gunakan `PhysicsService` untuk memisahkan grup tabrakan (misal: Pet tidak boleh menabrak Player atau dinding).

### 4.3. Accessories & Mesh Optimization
* **CollisionFidelity:** Untuk semua aksesoris (*Hats, Wings, Weapons*), set `CollisionFidelity` menjadi `Box` atau matikan tabrakan sepenuhnya (`CanCollide = false`, `CanQuery = false`). Jangan gunakan `Default` atau `PreciseConvexDecomposition` karena sangat berat untuk fisika server.
* **Texture Resolusi Menengah:** Batasi tekstur aksesoris maksimum 512x512, Roblox secara otomatis akan mengompresinya, namun file asli yang lebih kecil mengurangi waktu *download* (LCP/TTR).

### 4.4. Products, Game Passes, & Monetization
* **MarketplaceService.ProcessReceipt:** Ini adalah **inti** dari optimasi produk. *ProcessReceipt* harus dibuat se-robust mungkin. Roblox akan terus mengirim ulang struk pembelian jika server gagal merespons `Enum.ProductPurchaseDecision.PurchaseGranted`. Selalu pastikan barang/mata uang diberikan *sebelum* merespons granted.
* **Caching Ownership:** `MarketplaceService:UserOwnsGamePassAsync()` memiliki *rate limit* yang ketat. Jika pemain memiliki *Game Pass*, simpan statusnya di `ProfileStore` atau tabel memori server agar tidak perlu dipanggil ulang setiap kali pemain *respawn* atau masuk.
* **Analytics untuk Monetisasi:** Setiap pembelian harus ditempelkan dengan `AnalyticsService:LogEconomyEvent()` untuk melacak *Conversion Rate* dan *LTV (Life Time Value)* per *Product ID*.
| 2026-07-23 T12:38 | v1.1  | + Safety docs: TextService, PolicyService, BanAsync, IsVerified, Content Maturity     |
| 2026-07-23 T12:38 | v1.1  | + Security Architecture: server authority, replication security, script decompilation |
| 2026-07-23 T12:38 | v1.1  | + Gap analysis: konfirmasi cakupan vs yang belum dipelajari                           |

---

## 🔗 Daftar Tautan Referensi yang Dipelajari

### Analytics & Production
| Dokumen | URL | Status |
|---|---|---|
| Event Types (Overview) | https://create.roblox.com/docs/id-id/production/analytics/event-types | ✅ Dipelajari |
| Economy Events | https://create.roblox.com/docs/id-id/production/analytics/economy-events | ✅ Dipelajari |
| Custom Events | https://create.roblox.com/docs/id-id/production/analytics/custom-events | ✅ Dipelajari |
| Custom Fields | https://create.roblox.com/docs/id-id/production/analytics/custom-fields | ✅ Dipelajari |
| Monetization Analytics | https://create.roblox.com/docs/id-id/production/analytics/monetization | ✅ Dipelajari |
| Remote Configs | https://create.roblox.com/docs/id-id/production/configs | ✅ Dipelajari |
| Experiments (A/B Testing) | https://create.roblox.com/docs/id-id/production/experiments | ✅ Dipelajari |
| Funnel Events | https://create.roblox.com/docs/en-us/production/analytics/funnel-events | 📌 Terkait |

### Engine Reference (Class API)
| Kelas | URL | Status |
|---|---|---|
| AnalyticsService | https://create.roblox.com/docs/en-us/reference/engine/classes/AnalyticsService | ✅ Dipelajari lengkap |
| ConfigService | https://create.roblox.com/docs/en-us/reference/engine/classes/ConfigService | ✅ Dipelajari lengkap |
| ConfigSnapshot | https://create.roblox.com/docs/en-us/reference/engine/classes/ConfigSnapshot | ✅ Dipelajari lengkap |
| MarketplaceService | https://create.roblox.com/docs/en-us/reference/engine/classes/MarketplaceService | ✅ Dipelajari |
| MessagingService | https://create.roblox.com/docs/en-us/reference/engine/classes/MessagingService | ✅ Dipelajari |
| DataStoreService | https://create.roblox.com/docs/en-us/reference/engine/classes/DataStoreService | ✅ Dipelajari |
| HttpService | https://create.roblox.com/docs/en-us/reference/engine/classes/HttpService | 📌 Terkait |

### Enums Penting
| Enum | URL | Keterangan |
|---|---|---|
| AnalyticsEconomyFlowType | https://create.roblox.com/docs/en-us/reference/engine/enums/AnalyticsEconomyFlowType | Source / Sink |
| AnalyticsEconomyTransactionType | https://create.roblox.com/docs/en-us/reference/engine/enums/AnalyticsEconomyTransactionType | IAP / Shop / Gameplay / TimedReward / Onboarding / ContextualPurchase |
| AnalyticsCustomFieldKeys | https://create.roblox.com/docs/en-us/reference/engine/enums/AnalyticsCustomFieldKeys | CustomField01 / CustomField02 / CustomField03 |
| ActivePayerStatus | https://create.roblox.com/docs/en-us/reference/engine/enums/ActivePayerStatus | Top15Percent, Active, dll. |
| WhenUserFirstPlayed | https://create.roblox.com/docs/en-us/reference/engine/enums/WhenUserFirstPlayed | Days0To30, dll. |
| PlayerPlatformSpenderStatus | https://create.roblox.com/docs/en-us/reference/engine/enums/PlayerPlatformSpenderStatus | Platform-wide spender bucket |

### Open Cloud REST API
| Kategori | URL | Status |
|---|---|---|
| Cloud API Reference (Index) | https://create.roblox.com/docs/en-us/cloud | ✅ Dipelajari |
| Notifications | https://create.roblox.com/docs/en-us/cloud/features/notifications | ✅ Dipelajari |
| Universes (Messaging, Place) | https://create.roblox.com/docs/en-us/cloud/features/universes | ✅ Dipelajari |
| Data & Memory Stores | https://create.roblox.com/docs/en-us/cloud/features/storage | ✅ Dipelajari |
| Luau Execution | https://create.roblox.com/docs/en-us/cloud/features/luau-execution | ✅ Dipelajari |
| Developer Products | https://create.roblox.com/docs/en-us/cloud/reference/features/developer-products | ✅ Dipelajari |
| Game Passes | https://create.roblox.com/docs/en-us/cloud/reference/features/game-passes | ✅ Dipelajari |
| Webhook Notifications | https://create.roblox.com/docs/en-us/webhooks/webhook-notifications | ✅ Dipelajari |
| API Keys | https://create.roblox.com/docs/en-us/auth/api-keys | 📌 Diperlukan untuk implementasi |
| OAuth 2.0 | https://create.roblox.com/docs/en-us/auth/oauth2-overview | 📌 Terkait |

### Referensi Game Design yang Dipelajari Sebelumnya
| Dokumen | URL |
|---|---|
| GraphicsDataDefinition (SuperFlyTV) | https://github.com/SuperFlyTV/GraphicsDataDefinition |
| Awesome Game Design | https://github.com/Roobyx/awesome-game-design |
| OpenAgenticGame GDD | https://github.com/wanghaisheng/openagenticgame-gdd |

---

## 📋 Catatan API Kritis — AnalyticsService

### Method Signatures (Verified dari Engine Reference)

```lua
-- 1. ECONOMY EVENT
AnalyticsService:LogEconomyEvent(
    player: Player,
    flowType: Enum.AnalyticsEconomyFlowType,  -- Source | Sink
    currency: string,                          -- "AuraEnergy" | "ChronoSparks" | "RebirthTokens"
    amount: double,                            -- SELALU POSITIF (sink pun positif!)
    currentBalance: double,                    -- Balance SETELAH transaksi
    transactionType: string,                   -- Enum.Name atau string kustom
    itemSKU: string?,                          -- Opsional: identifier item
    customFields: Dictionary?                  -- Opsional: max 3 fields, nilai string
)

-- 2. CUSTOM EVENT
AnalyticsService:LogCustomEvent(
    player: Player,
    eventName: string,   -- Max 100 unique names per experience
    value: double?,      -- Default 1
    customFields: Dictionary?
)

-- 3. FUNNEL STEP (non-FTUE, multi-sesi)
AnalyticsService:LogFunnelStepEvent(
    player: Player,
    funnelName: string,
    funnelSessionId: string,  -- UUID; gunakan HttpService:GenerateGUID(false)
    step: int,                -- 1-100
    stepName: string?,
    customFields: Dictionary?
)

-- 4. ONBOARDING FUNNEL (khusus FTUE, tidak perlu sessionId)
AnalyticsService:LogOnboardingFunnelStepEvent(
    player: Player,
    step: int,         -- 1-100. Skip step = intermediate steps dianggap complete
    stepName: string?,
    customFields: Dictionary?
)

-- 5. PROGRESSION COMPLETE
AnalyticsService:LogProgressionCompleteEvent(
    player: Player,
    progressionPathName: string,
    level: int,
    levelName: string,
    customFields: Dictionary?
)

-- 6. PLAYER SEGMENTS (yields, cached per player per server session)
AnalyticsService:GetPlayerSegmentsAsync(player: Player): {
    HasData: boolean,
    ActivePayerStatus: Enum.ActivePayerStatus,
    WhenUserFirstPlayed: Enum.WhenUserFirstPlayed,
    PlatformSpenderStatus: Enum.PlayerPlatformSpenderStatus,
}
```

### Aturan Wajib AnalyticsService
- **Server-only** — Tidak bisa dipanggil dari client
- **Published games only** — Di Studio: silent fail (tidak crash), tapi tidak ada data
- **SEMUA panggilan WAJIB `pcall()`** — Kegagalan API tidak boleh mengganggu game loop
- `amount` pada `LogEconomyEvent` **SELALU positif** — baik Source maupun Sink
- `currentBalance` adalah balance **SETELAH** transaksi selesai
- Custom Fields: nilai **WAJIB string** (`tostring(number)`)
- Custom Fields keys: gunakan `Enum.AnalyticsCustomFieldKeys.CustomField01.Name` dll.
- Max **8.000 kombinasi unik** custom field values per experience
- Max **100 unique event names** untuk Custom Events

### Transaction Type Values
```lua
Enum.AnalyticsEconomyTransactionType.IAP.Name               -- "IAP"
Enum.AnalyticsEconomyTransactionType.TimedReward.Name       -- "TimedReward"
Enum.AnalyticsEconomyTransactionType.Onboarding.Name        -- "Onboarding"
Enum.AnalyticsEconomyTransactionType.Shop.Name              -- "Shop"
Enum.AnalyticsEconomyTransactionType.Gameplay.Name          -- "Gameplay"
Enum.AnalyticsEconomyTransactionType.ContextualPurchase.Name -- "ContextualPurchase"
```

---

## 📋 Catatan API Kritis — ConfigService & Experiments

### Method Signatures

```lua
-- GLOBAL CONFIG
local snapshot = ConfigService:GetConfigAsync()  -- yields; throws jika gagal
local val = snapshot:GetValue("myKey")           -- nil jika key tidak ada
snapshot.UpdateAvailable:Connect(function()
    snapshot:Refresh()  -- Hot-reload!
end)
snapshot:GetValueChangedSignal("bossHealth"):Connect(function(newVal) end)

-- PLAYER-SPECIFIC CONFIG (untuk experiments / A/B testing)
local playerSnap = ConfigService:GetConfigForPlayerAsync(player)  -- yields
local val = playerSnap:GetValue("leaderboardColor")  -- Enrolls player saat GetValue dipanggil!
```

### Aturan Wajib ConfigService
- **Server-only** — Client scripts: error
- `GetConfigAsync()` **throws** jika gagal load — WAJIB `pcall()`
- Enrollment experiment hanya terjadi saat **`GetValue()` pertama kali dipanggil** (lazy enrollment)
- Panggil `GetConfigForPlayerAsync()` **saat fitur relevan** — bukan di PlayerAdded
- `ConfigSnapshot` adalah snapshot point-in-time — perlu `Refresh()` untuk update
- Max **1.000 active configs** per experience
- Supported types: `string`, `number`, `boolean`, `JSON` (max 100.000 char)

### Config Keys COBLOX (dengan defaults dari RemoteConfigRepository)
```
TUNING (number):
  AuraEnergyMultiplier         = 1.0
  VaultInterestRate            = 0.05
  HatchChanceLegendaryMultiplier = 1.0
  RebirthCost                  = 1000000
  CovenCreationCost            = 10000
  PityHatchThreshold           = 100
  MaxOfflineSynthesisHours     = 12
  DailyStreakResetWindowHours  = 48

FEATURE FLAGS (boolean):
  EnableGlobalAuctionHouse     = true
  EnableLiveOpsEvents          = true
  EnableDoubleXPWeekend        = true
  EnableQuantumVaultInterest   = true
  LiveOpsDoubleAura            = false   ← toggle untuk weekend event
```

---

## 📋 Catatan API Kritis — Open Cloud REST

### Base URL
```
https://apis.roblox.com/cloud/v2/
```

### Autentikasi
```http
x-api-key: {YOUR_API_KEY}
```

### Endpoint Paling Relevan untuk COBLOX

#### 1. Experience Notifications (Push ke Offline Player)
```http
POST https://apis.roblox.com/cloud/v2/users/{userId}/notifications
{
  "source": { "universeId": "YOUR_UNIVERSE_ID" },
  "payload": {
    "type": "MOMENT",
    "messageId": "daily_streak_reminder",
    "joinExperienceParameters": { "launchData": "daily_streak" }
  }
}
```

#### 2. Cross-Server Broadcast (MessagingService via Open Cloud)
```http
POST https://apis.roblox.com/cloud/v2/universes/{universeId}:publishMessage
{ "topic": "LiveOpsUpdate", "message": "{\"eventType\": \"DoubleAura\", \"active\": true}" }
```

#### 3. DataStore Snapshot (Daily Backup)
```http
POST https://apis.roblox.com/cloud/v2/universes/{universeId}/datastores:snapshot
```

#### 4. Update Developer Product (Programmatic LiveOps)
```http
PATCH https://apis.roblox.com/cloud/v2/universes/{universeId}/developer-products/{productId}
{ "displayName": "🔥 2x Coins Pack (SALE!)", "price": 15 }
```

#### 5. Luau Execution (Admin Automation)
```http
POST https://apis.roblox.com/cloud/v2/universes/{universeId}/places/{placeId}/luau-execution-sessions/tasks
{ "script": "-- admin script here" }
```

### Open Cloud vs In-Game API — Perbedaan Fundamental
| Aspek | Open Cloud | In-Game Luau |
|---|---|---|
| Lokasi pemanggil | Backend eksternal / tools | Server script Luau |
| Push Notif ke offline player | ✅ | ❌ |
| Restart server | ✅ | ❌ |
| DataStore | REST full CRUD | `DataStoreService` |
| Messaging | REST → semua server | `MessagingService:PublishAsync` |

---

## 🗺️ Pemetaan Event Analytics COBLOX — Tabel Lengkap

### Economy Events
| Trigger | Currency | Flow | TxType | ItemSKU |
|---|---|---|---|---|
| Dropper yield | AuraEnergy | Source | Gameplay | `Dropper_Yield` |
| IAP Coins Small (+5k) | AuraEnergy | Source | IAP | `AuraPack_5k` |
| IAP Coins Large (+50k) | AuraEnergy | Source | IAP | `AuraPack_50k` |
| IAP Gems Small (+100) | ChronoSparks | Source | IAP | `GemPack_100` |
| IAP Gems Large (+1000) | ChronoSparks | Source | IAP | `GemPack_1k` |
| Daily Streak Bonus | AuraEnergy | Source | TimedReward | `DailyStreak_D{n}` |
| FTUE Welcome Gift | AuraEnergy | Source | Onboarding | `FTUE_Welcome_250` |
| Offline Synthesis | AuraEnergy | Source | Gameplay | `OfflineSynthesis` |
| Coven Creation | AuraEnergy | Sink | Shop | `CovenCreation_10k` |
| Coven Donation | AuraEnergy | Sink | Shop | `CovenDonation` |
| Hatch SpiritPod | AuraEnergy | Sink | Shop | `SpiritPod_Hatch` |
| Machine Upgrade | AuraEnergy | Sink | Shop | `Upgrade-{type}` |
| Rebirth Token Grant | RebirthTokens | Source | Gameplay | `RebirthGrant` |

### Custom Events (100 slot total)
| EventName | Value | CF01 | CF02 | CF03 |
|---|---|---|---|---|
| `SpiritPod_Hatched` | 1 | `Rarity-{Common/../Mythic}` | `Rebirth-{n}` | — |
| `Trade_Completed` | 1 | `ItemType-{Pet/Material}` | `Rebirth-{n}` | `Locale-{id/en}` |
| `Boss_Defeated` | 1 | `BossType-{name}` | `Rebirth-{n}` | `Mode-{Solo/Party}` |
| `Expedition_Completed` | duration_seconds | `ExpedType-{name}` | `Rebirth-{n}` | — |
| `Placement_Made` | 1 | `Machine-{type}` | `Rebirth-{n}` | — |
| `Coven_Created` | 1 | `Rebirth-{n}` | — | — |
| `Rebirth_Completed` | tokenCount | `RebirthNum-{n}` | — | — |
| `Lore_Collected` | 1 | `LoreId-{id}` | — | — |
| `Daily_Login` | streak | `Streak-{n}` | `Rebirth-{n}` | — |
| `Quest_Completed` | 1 | `QuestType-{name}` | `Rebirth-{n}` | — |

### Onboarding Funnel Steps
| Step | StepName | Trigger |
|---|---|---|
| 1 | `Spawn_Sanctum` | `OnboardingService.TriggerState(1)` |
| 2 | `Approach_IceWall` | `OnboardingService.TriggerState(2)` |
| 3 | `Complete_Core_FTUE` | `OnboardingService.TriggerState(3)` |
| 4 | `Hatch_First_SpiritPod` | `EggService` → DomainEvent |
| 5 | `Place_First_Machine` | `PlacementService` → DomainEvent |

---

## 🔒 Security Finding

**ISSUE KRITIS:** `MonetizationService.luau` line 42 mengandung `SECRET_WEBHOOK_PATH` yang hardcoded di source code.

**Solusi (urutan preferensi):**
1. Gunakan **Roblox Webhooks** (Open Cloud outbound) — Roblox kirim notif ke backend, tidak perlu secret di game server
2. Simpan URL di DataStore admin-only
3. Sementara: pindahkan ke ConfigService sebagai string config

**Roblox Webhook Events yang Tersedia:**
- `RightToErasureRequest` (GDPR)
- `SubscriptionCancelled` / `SubscriptionPurchased` / `SubscriptionRefunded` / `SubscriptionRenewed`
- `UserRestrictionUpdate`

---

## 📦 Arsitektur Ringkasan

```
[In-Game Server]
  AnalyticsService.luau  → Roblox AnalyticsService (LogEconomyEvent, LogCustomEvent, etc.)
  RemoteConfigService.luau → ConfigService:GetConfigAsync() + fallback RemoteConfigRepository
  ExperimentService.luau  → ConfigService:GetConfigForPlayerAsync() lazy enrollment
  BroadcastService.luau   → MessagingService:SubscribeAsync/PublishAsync (typed channels)

[External Backend]
  Roblox Webhook Receiver → gantikan webhook Guilded di MonetizationService
  Open Cloud API Calls    → Push notifs, DataStore snapshot, LiveOps automation
```

---

*Catatan terakhir diperbarui: 2026-07-23T12:30 WIB*
*Penyusun: Antigravity AI — COBLOX Engineering Research Session*

---

## ✅ Gap Analysis — Cakupan Riset vs Yang Diminta (v1.1 Addendum)

### Konfirmasi Status per URL yang Ditanyakan

| URL yang Diminta | Status | Catatan |
|---|---|---|
| https://create.roblox.com/docs/id-id/cloud | ✅ **Dicakup penuh** | Open Cloud REST API: Notifications, DataStore, MessagingService, Luau Execution, Developer Products, Webhook |
| https://create.roblox.com/docs/id-id/reference/engine | ⚠️ **Dicakup sebagian** | AnalyticsService ✅, ConfigService ✅, MessagingService ✅, DataStoreService ✅ — TextService ❌, PolicyService ❌, Players.BanAsync ❌ (ditambahkan di v1.1) |
| https://create.roblox.com/docs/id-id/production/analytics/economy-events | ✅ **Dicakup penuh** | LogEconomyEvent, Source/Sink, TxType, itemSKU, Custom Fields |
| https://create.roblox.com/docs/id-id/safety | ❌ **Belum dicakup** | BARU di v1.1: TextService filtering, PolicyService, BanAsync, Content Maturity, Safety Dashboard, Security Architecture |

---

## 🛡️ Safety & Security APIs (v1.1 — Baru Ditambahkan)

### Sumber URL yang Dipelajari (Safety Section)
| Dokumen | URL | Status |
|---|---|---|
| Safety Overview | https://create.roblox.com/docs/en-us/safety | ✅ v1.1 |
| Security Tactics & Cheat Mitigation | https://create.roblox.com/docs/en-us/scripting/security/security-tactics | ✅ v1.1 |
| Network Ownership & Movement Validation | https://create.roblox.com/docs/en-us/scripting/security/network-ownership | ✅ v1.1 |
| Access Control & Confidentiality | https://create.roblox.com/docs/en-us/scripting/security/access-control | ✅ v1.1 |
| Text Filtering | https://create.roblox.com/docs/en-us/ui/text-filtering | ✅ v1.1 |
| Content Maturity Questionnaire | https://create.roblox.com/docs/en-us/production/promotion/content-maturity | ✅ v1.1 |
| TextService (Engine Class) | https://create.roblox.com/docs/en-us/reference/engine/classes/TextService | ✅ v1.1 |
| PolicyService (Engine Class) | https://create.roblox.com/docs/en-us/reference/engine/classes/PolicyService | ✅ v1.1 |
| Players.BanAsync (Engine Method) | https://create.roblox.com/docs/en-us/reference/engine/classes/Players | ✅ v1.1 |

---

### TextService — Method Signatures

```lua
-- FILTER TEXT (Server-only, WAJIB untuk semua user-generated text)
local filterResult = TextService:FilterStringAsync(
    text,          -- string: teks untuk difilter
    fromUserId,    -- int64: UserId pengirim
    textContext?   -- TextFilterContext: PrivateChat (default) atau PublicChat
)  -- Returns: TextFilterResult

-- Distribute filtered text:
local ok, filtered = pcall(function()
    return filterResult:GetNonChatStringForBroadcastAsync()  -- Public (semua player)
end)

-- Filter DAN Translate sekaligus:
local result = TextService:FilterAndTranslateStringAsync(
    text, fromUserId, targetLocales, textContext?
)  -- Returns: TextFilterTranslatedResult
```

**Aturan COBLOX:**
- **WAJIB** filter semua user-generated text: nama pet, tanda, pesan Coven
- Jangan filter per-karakter saat mengetik — hanya setelah submit
- Selalu `pcall()` karena yields dan bisa gagal
- Simpan text di server, bukan di client

**Use cases di COBLOX:**
| Fitur | Teks yang perlu difilter |
|---|---|
| Coven name | Saat `CovenService.CreateCoven(name)` |
| Coven description | Saat update description |
| Spirit Memory name | Saat player memberi nama SpiritPod |
| Trade chat | Semua pesan dalam TradeService |

---

### PolicyService — Method Signatures

```lua
-- DAPATKAN POLICY INFO UNTUK PLAYER (yields, server-only)
local policyInfo = PolicyService:GetPolicyInfoForPlayerAsync(player)

-- Struktur return:
-- policyInfo.AreAdsAllowed: boolean
-- policyInfo.ArePaidRandomItemsRestricted: boolean  ← KRITIS untuk EggService!
-- policyInfo.IsEligibleToPurchaseSubscription: boolean
-- policyInfo.IsPaidItemTradingAllowed: boolean  ← KRITIS untuk TradeService!
-- policyInfo.IsSubjectToChinaPolicies: boolean
-- policyInfo.IsContentSharingAllowed: boolean
```

> [!IMPORTANT]
> **COBLOX sudah menggunakannya!** `PolicyComplianceService.luau` sudah wraps `GetPolicyInfoForPlayerAsync`. Konfirmasi:
> - `EggService.luau` sudah cek `PolicyComplianceService:CanPurchasePaidRandomItem(player)` ✅
> - `TradeService.luau` **BELUM** cek `IsPaidItemTradingAllowed` — perlu ditambahkan

---

### Players — Safety APIs (BanAsync, UnbanAsync, IsVerified)

```lua
-- BAN PLAYER (server-only, production-only, yields)
Players:BanAsync({
    UserIds = { player.UserId },              -- atau multiple UserIds
    Duration = 86400,                         -- detik; -1 = permanent
    DisplayReason = "Violated rules #5",      -- ditampilkan ke user
    PrivateReason = "Internal log notes...",  -- max 1000 char, tidak difilter, tidak ke client
    ExcludeAltAccounts = false,               -- true = tidak propagate ke alt
    ApplyToUniverse = true,                   -- true = ban di semua Place
})

-- UNBAN
Players:UnbanAsync({
    UserIds = { userId },
    ApplyToUniverse = true,
})

-- GET BAN HISTORY
local pages = Players:GetBanHistoryAsync(userId)  -- Returns BanHistoryPages

-- IS IDENTITY VERIFIED
local verified = player:IsVerified()  -- boolean; deter cheaters & scammers
```

**Aturan Wajib:**
- `BanAsync` dan `GetBanHistoryAsync` hanya berjalan di **production server**, tidak di Studio
- Selalu `pcall()` — HTTP call ke backend Roblox, bisa fail
- `PrivateReason` tidak perlu TextFilter — tidak pernah dikirim ke client
- Enable via `Players.BanningEnabled = true` di Studio settings

**Implementasi di COBLOX (rekomendasi):**
```lua
-- Di AdminService.luau — UPGRADE:
function AdminService.BanPlayer(adminPlayer: Player, targetUserId: number, reason: string, durationHours: number)
    -- Validasi admin terlebih dahulu
    if not AdminService.IsAdmin(adminPlayer) then return end
    
    local ok, err = pcall(function()
        Players:BanAsync({
            UserIds = { targetUserId },
            Duration = durationHours * 3600,
            DisplayReason = "Violation of COBLOX rules",
            PrivateReason = reason .. " | By: " .. adminPlayer.Name,
            ExcludeAltAccounts = false,
            ApplyToUniverse = true,
        })
    end)
    if not ok then
        warn("[AdminService] BanAsync failed:", err)
    end
end
```

---

### Content Maturity — Relevansi COBLOX

| Kriteria | Status COBLOX |
|---|---|
| Maturity Questionnaire wajib diisi | ⚠️ Perlu dikonfirmasi — wajib untuk semua game publik |
| Target audiens 13+ / 16+ (survei) | ✅ Sudah didiskusikan — rating minimum `AllAges` atau `9+` |
| Private spaces (bedroom, closet) | ✅ Tidak ada — Sanctum setting fantasy |
| Trading dengan paid items | ⚠️ Harus tambahkan `IsPaidItemTradingAllowed` check di TradeService |

---

## 🏛️ Security Architecture — Prinsip Kritis (v1.1)

> Diambil dari: security-tactics, network-ownership, access-control docs

### Prinsip Dasar (Sudah Diterapkan di COBLOX)

| Prinsip | Status COBLOX | Bukti |
|---|---|---|
| **Never trust the client** | ✅ | Semua service di `ServerScriptService`, distance check ≤15 studs |
| **Server authority** | ✅ | EconomyService, ProfileStoreAdapter — semua mutasi di server |
| **Security by design** | ✅ | `--!strict`, ServiceResult pattern, pcall wrapping |
| **Validate before execute** | ✅ | Balance check sebelum DeductCoins, ownership check di TradeService |

### Gap yang Ditemukan dari Security Docs

| Issue                                                            | Lokasi                                       | Prioritas　 |
| ------------------------------------------------------------------| ----------------------------------------------| -------------|
| `TradeService` tidak check `IsPaidItemTradingAllowed`            | `TradeService.luau`                          | 🔶 Tinggi　 |
| `SECRET_WEBHOOK_PATH` hardcoded                                  | `MonetizationService.luau`                   | 🔴 Kritis　 |
| Tidak ada rate-limiting di `RemoteEvent` handlers                | `StoryService, EggService`                   | 🔶 Tinggi　 |
| Script `ModuleScript` yang shared — pisahkan server/client logic | Beberapa ModuleScript di `ReplicatedStorage` | 🔷 Menengah |
| Secure teleportation belum dikonfigurasi untuk subplaces         | Studio Creator Dashboard                     | 🔷 Menengah |

### Pattern: Remote Rate Limiting (Rekomendasi Tambahan)

```lua
-- Tambahkan ke semua RemoteEvent handlers yang menerima aksi dari client:
local lastCallTime: {[number]: number} = {}
local RATE_LIMIT_SECONDS = 1.0  -- 1 detik per aksi

remote.OnServerEvent:Connect(function(player: Player, action: string, data: any)
    -- Rate limit check
    local now = os.clock()
    if lastCallTime[player.UserId] and (now - lastCallTime[player.UserId]) < RATE_LIMIT_SECONDS then
        warn("[RateLimit] Player", player.Name, "exceeded rate limit")
        return  -- Silently ignore
    end
    lastCallTime[player.UserId] = now
    
    -- ... actual handler logic
end)
```

---

## 🔍 Engine Reference — Classes Belum Dipelajari (Backlog)

Kelas-kelas ini ada di reference/engine tapi belum dipelajari secara mendalam:

| Kelas | URL | Relevansi COBLOX | Prioritas |
|---|---|---|---|
| `TeleportService` | https://create.roblox.com/docs/en-us/reference/engine/classes/TeleportService | Multi-place transition | 🔷 Menengah |
| `SoundService` | https://create.roblox.com/docs/en-us/reference/engine/classes/SoundService | Audio Bible implementasi | 🔷 Menengah |
| `MarketplaceService` | https://create.roblox.com/docs/en-us/reference/engine/classes/MarketplaceService | GamePass check, subscription | ✅ Sebagian dipelajari |
| `AvatarCreationService` | https://create.roblox.com/docs/en-us/reference/engine/classes/AvatarCreationService | Photo-to-Avatar (opsional) | 🔵 Rendah |
| `LocalizationService` | https://create.roblox.com/docs/en-us/reference/engine/classes/LocalizationService | LocalizationController | 🔷 Menengah |
| `MemoryStoreService` | https://create.roblox.com/docs/en-us/reference/engine/classes/MemoryStoreService | Cross-server auction house | 🔶 Tinggi |
| `UserInputService` | https://create.roblox.com/docs/en-us/reference/engine/classes/UserInputService | Client controllers | ✅ Implisit |
| `BanHistoryPages` | https://create.roblox.com/docs/en-us/reference/engine/classes/BanHistoryPages | AdminService BanAsync | ✅ v1.1 |

> **`MemoryStoreService`** adalah prioritas tertinggi untuk dipelajari selanjutnya — dibutuhkan untuk Global Auction House (leaderboard cross-server, bid caching).

---

## 🏗️ AssetService:CreatePlaceAsync (Dynamic Instance Generation)

Fungsi `AssetService:CreatePlaceAsync(templatePlaceId, name, description)` sangat krusial untuk game berbasis RPG atau sandbox, karena fungsi ini memungkinkan server untuk mengkloning sebuah "Template Place" menjadi Place baru yang beroperasi di dalam Universe yang sama secara instan (saat runtime).

**Signatur API:**
```lua
local AssetService = game:GetService("AssetService")
local newPlaceId = AssetService:CreatePlaceAsync(
    123456789, -- Template Place ID
    "Coven Hideout - The Order of the Phoenix",
    "Private alchemy sanctuary."
)
```

### 💡 Relevansi dengan COBLOX (Multiverse Alchemy Sanctum):
1. **Instanced Coven Hideouts (Markas Pribadi/Klan):** Alih-alih memuat ratusan rumah player di satu server utama (yang bisa membuat server lag/mencapai limit 6GB RAM), kita bisa men-generate "Pulau Sanctum" pribadi untuk setiap Coven menggunakan API ini.
2. **Instanced Boss / Raid Dungeons:** Saat party player akan melawan Raid Boss, kita bisa me-request pembuatan *dungeon* instan dari Template Place sehingga tidak ada party lain yang mengganggu (mirip sistem di Destiny atau WoW).
3. **Teleportasi Seamless:** Setelah `newPlaceId` didapatkan, kita dapat menyimpannya ke `DataStore` atau langsung melempar data tersebut ke `TeleportService:TeleportToPlaceInstance(newPlaceId, ...)` untuk memindahkan pemain.

---

*Catatan terakhir diperbarui: 2026-07-23T13:30 WIB (v1.2)*
*Penyusun: Antigravity AI — COBLOX Engineering Research Session*
