# AGENTS.md — COBLOX

Sci-fantasy industrial sandbox di Roblox Engine. Luau `--!strict`, Rojo + Aftman.

## Tooling & Commands

```bash
aftman install              # install toolchain (Rojo, Selene, StyLua, luau-lsp)
rojo serve default.project.json  # sync → Studio
selene src/                 # linter — must pass 0 errors/warnings
stylua --check src/         # formatter check
stylua src/                 # format all
rojo build -o test.rbxl     # build check
python scripts/validate_rgs_compliance.py  # compliance audit
```

**CI** (`.github/workflows/ci.yml`): `selene src/` → `stylua --check src/` → `rojo build`.

## Architecture

| Layer | Dir | Entrypoint |
|-------|-----|------------|
| Server | `src/Server/Services/` | `RuntimeServer.server.luau` (7-tier boot) |
| Client | `src/Client/Controllers/` | `RuntimeClient.client.luau` (ControllerRegistry) |
| Shared | `src/Shared/` | Config, Utility, Types, Events, Network |
| Config | `src/Shared/Config/` | `Generated*Registry.luau` + `Content/Data/` |
| Assets | `src/Assets/` | Synced via Rojo to ReplicatedStorage.Shared.Assets |

- **Services** (`Service.luau` di `src/Server/Services/`) — `ServiceStatus`, `Name`, `Init(self)`, `Start(self)`, daftar di `RuntimeServer.server.luau`.
- **Controllers** (`Controller.luau` di `src/Client/Controllers/`) — `Init(self, Registry)`, `Start(self, Registry)`, daftar di `RuntimeClient.client.luau`.

## Pola Kode Wajib

### Registry — jangan iterasi langsung
```luau
local data = Registry.GetAll()  -- returns {_data} table, bukan tabel asli
for id, entry in pairs(data) do ... end
```
Berlaku untuk semua `Generated*Registry` + `RealmRegistry`.

### Controller — colon notation dengan `self`
```luau
function X.Init(self, Registry) self.maid = Maid.new() end
function X.Start(self, Registry) end
function X._Helper(self) end
```
⚠️ `Start(self, Registry)` tanpa `self` → Registry masuk sebagai `self` → `self.maid` nil.
⚠️ **Bug terverifikasi di `InteractionController.luau`** (line 24): `Init()` tanpa `self` — jika Registry dilewatkan akan error. ✅ **Fixed** — `self` ditambahkan.

### Maid/cleanup
```luau
self.maid = Maid.new()
self.maid:GiveTask(event:Connect(...))
```
`ContextActionService:BindAction()` return `nil` — jangan di-GiveTask:
```luau
self.maid:GiveTask(function() ContextActionService:UnbindAction("X") end)
```

### Lain-lain
- `DropRate` di config berupa string persen (`"1.5%"`): `tonumber(tostring(x):gsub("%%", ""))`
- Semua DataStore/HTTP/RemoteEvent handler: `pcall()` + `typeof()` validasi
- Interaksi fisik: jarak ≤ 15 studs, validasi server-side

## Frozen Services

Jangan refactor tanpa ADR: `EconomyService`, `EggService`, `PetService`, `TycoonService`, `TradeService`, `RuntimeServer`, `RuntimeClient`.

## Content Pipeline (Config-Driven)

Semua tambahan konten via file config, bukan edit service:
- **Items/Materials:** `Content/Data/Materials/` → `GeneratedMaterialRegistry`
- **Recipes:** `Content/Data/Recipes/` → `GeneratedRecipeRegistry`
- **Machines:** `Content/Data/Machines/` → `GeneratedMachineRegistry`
- **Spirits:** `Content/Data/Spirits/` → `GeneratedSpiritRegistry`
- **LiveOps:** `src/LiveOps/`

## Resource Budgets (Mobile Target)

| Item | Limit |
|------|-------|
| RAM | < 2.5 GB |
| Particles/emitter | ≤ 20 |
| BillboardGui MaxDistance | ≤ 35 |
| HUD AR elements | ScreenGui + WorldToViewportPoint (jangan BillboardGui) |

VFX transient: `ObjectPool` (Visible=false recycling).

## UPGRADE-1.md — Implementation Roadmap

`docs/02-ARCHITECTURE_AND_SPECS/UPGRADE-1.md` adalah vision document untuk **Roblox AI Engine Architect (RAEA)**. Status gap vs codebase:

| Priority | Area | Status |
|----------|------|--------|
| P0 | RAEA_ModernAvatarEngine module (6 fungsi) | ✅ SELESAI |
| 0.3 | CloudSyncService (MessagingService hot-reload) | ✅ SELESAI |
| 1 | Avatar modern + AvatarService (IK, FACS, clothing) | ✅ SELESAI |
| 2 | AI pipelines (Meshy, DeepMotion, Suno) — AssetGenerationService + AIPipelineService | ✅ SELESAI |
| 2 | MCPBridge, FallbackCodeGenerator, AIPrompt upgrade | ✅ SELESAI |
| 3 | Self-healing loop (LogService monitoring + error diagnosis) | ✅ Runtime monitoring |
| — | Fusion UI (replacement for Roact/Instance.new UI) | ✅ wally.toml dep + demo controller |
| — | R6→R15 retargeting adapter | ✅ SELESAI |

Lihat `docs/02-ARCHITECTURE_AND_SPECS/UPGRADE-1.md` untuk detail spesifikasi per-area.

## Docs Status

`docs/*` = **DEPRECATED / OBSOLETE** sebagai SSOT. `src/` dan `Content/Data/` adalah satu-satunya source of truth yang aktif.

## Web Portal

`web/` adalah Next.js 16 + Tailwind v4 + Prisma/Neon PostgreSQL. Lihat `web/AGENTS.md` untuk panduan spesifik (ada breaking changes di Next.js versi ini).

`cd web && npm run lint` → ESLint (TSX/TS).
`cd web && npm run lint:css` → stylelint (CSS) — jalankan jika ada perubahan CSS.

## Definisi Selesai (DoD)

1. `selene src/` → 0 errors/warnings
2. `rojo build -o test.rbxl` → sukses
3. `python scripts/validate_rgs_compliance.py` → clean
4. `cd web && npm run lint` → 0 warnings (jika ada perubahan TSX/TS)
5. `cd web && npm run lint:css` → 0 warnings (jika ada perubahan CSS)
6. Budget RAM (< 2.5 GB) & partikel (≤ 20/emitter) diverifikasi
