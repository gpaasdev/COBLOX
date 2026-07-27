[🏠 Master Index](../../MASTER_INDEX.md) > [🎨 Creative & Marketing](./) > Content Bible

# 📦 COBLOX Content Bible

> **The Blueprint for Game Data**
> As COBLOX expands, consistency in how items, machines, and resources are structured is paramount. This document defines the rules for all game content to ensure mechanical balance and narrative cohesion.

---

## 1. Item Taxonomy & Naming Conventions

All items fall into specific categories. Their names must reflect their category and Tier.

- **Raw Resources:** Natural materials. Format: `[State] [Material]`.
  - *Example:* "Raw Iron", "Crystalline Aether", "Volatile Gas".
- **Processed Materials:** Refined resources. Format: `[Treatment] [Material] [Form]`.
  - *Example:* "Smelted Iron Ingot", "Polished Aether Lens".
- **Machine Components:** Parts used for crafting. Format: `[Material] [Mechanical Part]`.
  - *Example:* "Brass Gear", "Copper Wire", "Obsidian Chassis".
- **Machinery:** Functional units. Format: `[Power Source/Adjective] [Function]`.
  - *Example:* "Steam-Powered Crusher", "Aetheric Compressor", "Void Centrifuge".

---

## 2. Rarity System

Rarity in COBLOX signifies both the difficulty to acquire and the density of magical/industrial energy. It is visually represented by specific colors.

1. **Common (Gray - `#A0A5B0`):** Foundational materials. Dirt, Stone, Scrap Iron.
2. **Uncommon (Green - `#4CAF50`):** Basic processed goods. Copper Wire, Brass Gear.
3. **Rare (Blue - `#2196F3`):** Advanced components. Aether Cores, Steel Plates.
4. **Epic (Purple - `#9C27B0`):** Highly volatile/magical items. Voidstone, Sanctum Relics.
5. **Legendary (Gold - `#FFC107`):** Unique, world-altering artifacts. The Coven's Engine.

*Rule:* Rarity colors must be used consistently across UI tags, particle effects when dropped, and item background cards.

---

## 3. Description & Lore Injection

Every item must have a mechanical description and a lore string.

**Format:**
> **[Item Name]**
> *[Lore String - Italicized. Max 2 sentences.]*
> [Mechanical Description - Clear, factual, no fluff.]

**Example:**
> **Aetheric Compressor**
> *A salvaged Sanctum design, retrofitted with heavy Coven brass. It hums with barely contained pressure.*
> Compresses 5x Crystalline Aether into 1x Dense Aether Core. Speed: 2.5s per cycle.

---

## 4. Statistics and Balancing Philosophy

To prevent runaway power creep, COBLOX uses a **Diminishing Returns on Speed** but **Linear Scaling on Capacity** model.

- **Early Game (Tiers 1-2):** Upgrades provide massive speed boosts to keep the player engaged.
- **Mid Game (Tiers 3-4):** Speed upgrades diminish. The focus shifts to logistical efficiency (belts, pipes, storage capacity).
- **End Game (Tiers 5+):** Focus is entirely on massive parallel automation, not single-machine speed.

### Number Caps
Avoid numbers that are difficult to parse at a glance.
- If a machine holds 1,000,000 resources, display it as `1M`.
- If an item drops with a 0.0001% chance, the system is flawed. The lowest permissible drop rate for a farmable item is `0.1%` (1 in 1000).

---

## 5. Progression & Reward Philosophy

- **No Dead Ends:** Every resource, even Tier 1 Wood, must have a sink in the late game (e.g., converted to Biomass for fuel).
- **The "Aha!" Moment:** Every major tier unlock should solve a frustrating logistical problem from the previous tier (e.g., unlocking pipes after manually carrying liquids).
- **Respect the Player's Time:** Grinding is acceptable; AFK-idling for 24 hours to progress is not. Use active play (exploration, boss fighting) to accelerate passive play.
