---
name: gamedev-economy-crafting
description: >-
  Game economy design, compounding interest math, config-driven crafting matrices,
  gacha drop rates, and anti-duplication security patterns for game developers.
---

# Game Dev Economy & Crafting Skill

## Overview
This skill establishes scalable, anti-cheat economy patterns and config-driven crafting engines for sandbox and simulator games.

## Core Patterns
1. **Config-Driven Crafting Matrix**:
   - Store formulas in table configurations (`RecipeConfig.luau` / JSON / YAML).
   - Validate input ingredient quantities and types on the server before consumption.
   - Enforce craft timers server-side with anti-exploit timestamps.
2. **Exploding Numbers & Compound Vault**:
   - Calculate compound interest dynamically using continuous or interval formulas:
     $$V(t) = P \times (1 + r)^{\Delta t}$$
   - Apply passive luck boosts (e.g. Cozy Rating) to gacha drop rates.
3. **Anti-Duplication & Transaction Integrity**:
   - Mutate currency and inventory atomically under session locks (ProfileStore).
   - Require double verification for P2P trade operations.

## Common Mistakes
1. Trusting client crafting requests without re-verifying item inventories server-side.
2. Hardcoding gacha drop chances or item stats directly inside handler logic.
3. Calculating interest with loop iterations instead of delta time formulas.
