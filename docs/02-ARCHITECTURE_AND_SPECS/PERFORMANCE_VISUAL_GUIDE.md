[🏠 Master Index](../../MASTER_INDEX.md) > [🏗️ Architecture & Specs](./) > Performance & Visual Guide

# 📊 COBLOX Performance & Visual Budget Guide

> **Beauty Without the Bottleneck**
> COBLOX targets a massive, cross-platform audience. Our visual fidelity must scale from high-end PCs down to low-end mobile devices (< 2.5 GB RAM). This document defines strict technical budgets for all assets to prevent memory leaks, FPS drops, and server lag.

---

## 1. 3D Asset Budgets

We rely on strong silhouettes and normal maps rather than raw geometry.

- **Small Props (Items, Resources):** < 250 Triangles.
- **Medium Machines (Smelters, Assemblers):** < 1,500 Triangles.
- **Hero Machines (The Crucible, End-game Tech):** < 5,000 Triangles.
- **Characters / Bosses:** < 10,000 Triangles.

*Rule:* Every mesh must have an aggressive LOD (Level of Detail) curve. If a machine is 100 studs away, it should render at < 20% of its base triangle count.

---

## 2. Texture & Material Budgets

- **Texture Resolution:** 
  - Max 1024x1024 for Hero assets.
  - 512x512 or 256x256 for standard machines and props.
- **Material Reuse:** Use Roblox's built-in `MaterialVariant` system heavily. Do not upload unique PBR maps for every single brass pipe. Create a single "Scratched Brass" MaterialVariant and apply it globally.
- **Color Mapping:** For small items, use Vertex Colors or palette textures (a single 256x256 texture mapping colors for hundreds of items) to save memory.

---

## 3. Lighting & VFX Budgets

- **Dynamic Lights (PointLight, SpotLight):** Extremely expensive. Max 3 dynamic lights per machine. They must have `Shadows = false` unless critical for the player's focus.
- **Particle Emitters:** 
  - Max 20 active particles per emitter.
  - Max 5 emitters per machine.
  - MUST use `ObjectPool` for transient visual effects (sparks, explosions). Never instantiate and destroy particles rapidly.

---

## 4. UI & Spatial Render Budgets

- **BillboardGuis:** Heavy performance killers when spammed. 
  - All `BillboardGui` instances MUST have `MaxDistance` set ($\le 35$).
  - Use distance culling scripts to disable rendering for machines outside the immediate viewport.
- **ScreenGuis:** For AR lenses/HUD elements tracking 3D space, use `WorldToViewportPoint` projections via `NodeWidgetPool`, rather than attaching hundreds of `BillboardGuis` to the workspace.

---

## 5. Network Replication Budget

- **Server-to-Client Updates:** The server cannot send visual update packets for every machine every frame.
- **Visual Interpolation:** The server tells the client "Machine X is now active." The client handles the animation, particle spawning, and sound looping locally. The server only replicates state changes, not visual frames.
