---
name: roblox-alchemy-sanctum-skill
description: >-
  Architectural and development guidelines for COBLOX: Multiverse Alchemy Sanctum
  (LGBOS v11.0). Enforces Server-Authoritative Zero-Trust SOA, ProfileStore v3
  session locking, distance checks (<= 15 studs), config-driven elemental synthesis,
  and memory optimization (<6GB RAM). Use when building or refactoring Roblox Luau
  services, controllers, or configurations for COBLOX.
---

# Roblox Alchemy Sanctum Skill (LGBOS v11.0)

## Overview
This skill governs the development of **COBLOX: Multiverse Alchemy Sanctum**, a visual-first, stealth-education sci-fantasy sandbox on Roblox.

## Core Architectural Rules
1. **Server-Authoritative Zero-Trust**:
   - Client requests are ALWAYS validated on the server.
   - Physical distance check must be enforced ($\le 15\text{ studs}$) for placement, crafting, and interactions.
   - Balance and inventory checks happen server-side before state mutation.
2. **ProfileStore v3 Session Locking**:
   - `SaveService.luau` manages player session locks.
   - Skema: Currencies (`EnergyCores`, `ChronoCrystals`, `QuantumBadges`), Inventory (`Spirits`, `Items`), SanctumGrid (`Structures`, `CozyRating`), VaultData (`DepositedAmount`, `LastDepositTimestamp`).
3. **Memory & Performance Budget**:
   - Total RAM budget: $<6\text{ GB}$.
   - Max CPU server load: $<5\%$.
   - Max particles per plot: $\le 20$ active particles.
   - Use `ObjectPool.luau` for all transient VFX and drop items.

## Glosarium & Terminology
- **Coins** $\to$ **Aura Energy**
- **Gems** $\to$ **Chrono Spark**
- **Rebirth Tokens** $\to$ **Fusion Badges**
- **Pets** $\to$ **Spirit Companions**
- **Eggs** $\to$ **Genesis Pods**
- **Plot** $\to$ **Alchemy Sanctum**
- **Compound Vault** $\to$ **Quantum Bank**

## Service-Oriented Architecture (SOA)
- `SaveService.luau`: Data persistence & buffering
- `RecipeService.luau`: Elemental synthesis logic
- `PlacementService.luau`: Grid collision & distance validation
- `EconomyService.luau`: Quantum Vault exponential interest math: $V(t) = P \times (1+r)^{\Delta t}$

## Common Mistakes
1. Trusting client positions without a magnitude check ($\le 15$ studs).
2. Spawning visual particles without recycling via `ObjectPool`.
3. Hardcoding recipe formulas in services instead of `RecipeConfig.luau`.
