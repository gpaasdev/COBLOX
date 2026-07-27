# src/Shared/Configuration/ — Hand-Authored Configs

> **HAND-AUTHORED ONLY** — These files are written and maintained by developers.
> Do NOT place generated pipeline output here (use `src/Shared/Config/` for that).

## Contents

| File | Purpose |
|---|---|
| `GameConfig.luau` | Central gameplay constants: combat params, mob stats, economy rates, pet config |
| `RecipeConfig.luau` | Alchemy recipe definitions (ingredients, results, rarities) |
| `PetData.luau` | Pet species definitions, base multipliers, rarity tiers |
| `CovenConfig.luau` | Coven system parameters (template place ID, naming format) |
| `AssetManifest.luau` | Asset ID registry for audio, images, and particle effects |

## Naming Convention

- Hand-authored configs: `PascalCase.luau`
- No `Generated` prefix
- All numbers must reference `GameConfig.luau` — avoid magic numbers in services

## Relationship to `src/Shared/Config/`

```
content/            ← SSOT (YAML/JSON)
    ↓ generate_registry.py
src/Shared/Config/  ← Generated output (DO NOT EDIT)

src/Shared/Configuration/  ← Hand-authored (edit freely)
    GameConfig.luau
    RecipeConfig.luau
    ...
```
