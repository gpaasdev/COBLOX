[🏠 Master Index](../../docs/MASTER_INDEX.md)

# COBLOX Content Pipeline Documentation

## Single Source of Truth (`content/`)
- `materials/`: Material definitions and property catalogs.
- `recipes/`: Transmutation formulas and ingredients.
- `spirits/`: 30 Pets catalog across 5 rarities.
- `badges/`: 15 Achievement milestones.

## Pipeline Command
```bash
python3 scripts/registry/generate_registry.py
```
Outputs immutable snapshot `.json` to `registry/snapshots/` and updates `registry/latest.json`.
