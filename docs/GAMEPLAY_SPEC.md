> **[🏠 Master Index](MASTER_INDEX.md) | [⬅️ Back to Docs](README.md)**

# 🎮 COBLOX Gameplay Specification

## 1. Gameplay Core Loop
Siklus utama permainan berbasis industri sci-fantasy:
$$\text{Harvest (Material)} \longrightarrow \text{Refine (Smelter/Reactor)} \longrightarrow \text{Craft (Recipes)} \longrightarrow \text{Automate (Machines)}$$

## 2. Dynamic Systems
- **Machines & Automation:** Mesin diolah via `MachineService.luau` berdasarkan konfigurasi `GeneratedMachineRegistry.luau`.
- **Recipes & Synthesis:** Kombinasi bahan kimia/materi diatur oleh `RecipeService.luau` dan `ReactionEngine.luau`.
- **Spirits & Companions:** Roh pendamping diperoleh melalui `EggService.luau` / `HatchService.luau` dengan tingkat *DropRate* terurai dari persen (contoh: `"1.5%"`).
- **Combat & Mobs:** Musuh dan pertarungan dikelola oleh `MobService.luau` dan `CombatService.luau`.
