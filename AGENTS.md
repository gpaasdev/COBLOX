# AGENTS.md — COBLOX Roblox Game (Single Source of Truth)

> **Cross-Tool Context File** (Antigravity, Claude Code, Cursor, Windsurf, Gemini CLI).
> See also `.agents/AGENTS.md` for local-only tool configuration (gitignored).

---

# 1. Project Architecture & Scope Boundaries

COBLOX is a **Roblox-exclusive sci-fantasy industrial sandbox game** built in Luau on the Roblox Engine using Rojo and Aftman.

---

# 2. Frozen Core Services & Configuration Rules

### Frozen Services
Do NOT refactor without approved ADR:
`SaveService`, `EconomyService`, `EggService`, `PetService`, `TycoonService`, `TradeService`, `RuntimeServer`, `RuntimeClient`.

### Configuration Additions
All content additions MUST be made via config files in `Content/Data/` or `Shared/Config/`.

---

# 3. Code Bounds & Standards

- **Header:** `--!strict` in all Luau scripts.
- **Linter:** `selene src/` must pass clean (0 errors/warnings).
- **Limits:** Max 300 lines/module, max 40 lines/function, cyclomatic complexity $< 10$.

---

# 4. Mandatory Luau Coding Patterns

### Registries — Data/Func Separation (ALL Registries)
**NEVER** iterate any registry table directly with `pairs()`. Use `Registry.GetAll()`:

```luau
local data = Registry.GetAll()  -- returns {_data} table (data only)
for id, entry in pairs(data) do
    -- entry is guaranteed to be a data table, never a function
end
```

This includes `RealmRegistry`, `GeneratedFairytaleSpiritRegistry`, and all `Generated*Registry` files.

### Service Registration Requirements
Every service in `RuntimeServer.server.luau` MUST have:
- `ServiceStatus = "Production",` — set to `"Experimental"` only for testing
- `Name = "ServiceName",` — matches the file name (no `table: 0x...` in boot logs)
- `Init()` — always present; boot order depends on `services{}` table position
- `Start()` — required for services that need post-boot activation; leave empty `function X.Start() end` if unused



```luau
local data = Registry.GetAll()  -- returns {_data} table (data only)
for id, entry in pairs(data) do
    -- entry is guaranteed to be a data table, never a function
end
```

### ControllerRegistry — Colon Notation for ALL Lifecycle Methods
Always use colon notation for `Init` AND `Start`, both must include `self` parameter:

```luau
function MyController.Init(self, Registry: any)
    ...
end

function MyController.Start(self, Registry: any)
    ...
end
```

The ControllerRegistry calls `controller:Init(Registry)` and `controller:Start(Registry)` using colon notation.
A `Start()` without `self` will misinterpret the Registry argument as `self`, causing nil errors on `self.maid`.

### File Naming — Consistency
- All services in `src/Server/Services/` must end in `Service.luau` (e.g., `QuestService.luau`, not `QuestManager.luau`).
- All controllers in `src/Client/Controllers/` must end in `Controller.luau`.


```luau
function MyController.Init(self, Registry: any)
    self.maid = Maid.new()
    self:_CreateUI()
end

function MyController._CreateUI(self)
    self.maid:GiveTask(someEvent:Connect(function() end))
end
```

### ContextActionService — No Return Value
`ContextActionService:BindAction()` returns `nil`. Do NOT wrap in `GiveTask()`:
```luau
ContextActionService:BindAction("ActionName", handler, ...)
self.maid:GiveTask(function()
    ContextActionService:UnbindAction("ActionName")
end)
```

### Spirit DropRate Parsing
`DropRate` uses percentage strings (e.g. `"1.5%"`):
```luau
local dropStr = tostring(spirit.DropRate):gsub("%%", "")
local dropWeight = tonumber(dropStr)
```

---

# 5. Security & Performance Guidelines

### Zero-Trust Security
- Always validate client inputs server-side.
- Enforce physical distance checks (≤ 15 studs) for spatial interactions.
- Validate payload arguments at runtime (`typeof()` checks) in all `RemoteEvent` and `RemoteFunction` handlers.
- All DataStore, MemoryStore, and HTTP calls MUST be wrapped in `pcall` or `xpcall`.

### Resource Budgeting
- Target total memory: < 2.5 GB RAM (Mobile Target).
- Use `ObjectPool` for transient visual effects and damage text (`Visible = false` recycling).
- `BillboardGui` instances MUST have `MaxDistance` set (≤ 35) with distance culling.
- Render AR Lens HUD elements via `ScreenGui` using `WorldToViewportPoint` projections, NEVER `BillboardGui`.

---

# 6. Definition of Done (DoD)

A task is DONE only when:
1. `selene src/` passes with 0 errors/warnings.
2. Rojo builds cleanly (`rojo build -o test.rbxl`).
3. Memory budget (< 2.5 GB RAM) and particle limits (≤ 20 active particles/emitter) are verified.
