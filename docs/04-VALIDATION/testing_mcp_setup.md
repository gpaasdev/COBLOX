# MCP Testing Setup

## 1. Roblox Studio MCP
Untuk menjalankan IntegrationTestService dan testing otomatis:

1. **Install Studio plugin**: Download dari [Chrrxs/robloxstudio-mcp releases](https://github.com/Chrrxs/robloxstudio-mcp/releases) ke folder Plugins
2. **Enable HTTP**: Experience Settings → Security → Allow HTTP Requests ✅ (sudah)
3. **Buka Studio**: Plugin akan auto-connect ke MCP server di port 58741
4. **Sync via Rojo**: `rojo build default.project.json -o COBLOX_Production.rbxl`

### MCP Tools tersedia (43 tools):
- `get_script_source` / `edit_script` — baca/edit script
- `create_script` — buat script baru
- `get_place_info` — eksplorasi struktur game
- `search_objects` — cari instance
- `capture_screenshot` — screenshot gameplay
- `get_playtest_output` — baca log playtest
- `start_playtest` — mulai playtest
- `export_build` — build place

## 2. IntegrationTestService
File: `src/Server/Services/IntegrationTestService.luau`

Test coverage:
- ✅ RecipeRegistry — 45 recipes valid
- ✅ SpiritRegistry — 40 spirits, 5 rarities
- ✅ MachineConfig — 8 types, costs
- ✅ WeaponConfig — 5 weapons valid
- ✅ PlacemenFlow — GridConfig structures
- ✅ Recipe match engine — match by ingredients

Run via: `IntegrationTestService.Start()` di command bar Studio

## 3. Roblox Open Cloud MCP (existing)
Sudah terkonfigurasi di opencode.json — tools:
- `config` — experience configs
- `data-stores` — read/write DataStore entries
- `ordered-data-stores` — leaderboard
- `badges` — badge management
- `monetization` — game passes, dev products
- `luau-execution` — Open Cloud Luau execution
- `notifications` — send notifications
