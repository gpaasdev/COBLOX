[🏠 Master Index](../../MASTER_INDEX.md) > [🎨 Product & Design](./) > Style Guide

# 📏 COBLOX Style Guide

> **The Practical Implementation of the Creative OS**
> While the Creative Bible defines our philosophy, this Style Guide provides the concrete, mathematical rules for implementing that philosophy in COBLOX. This ensures pixel-perfect consistency across all contributions, whether by human artists or AI agents.

---

## 1. Grid and Spacing

We use a strict **4px/8px modular grid system** for all UI elements.

- **Base Unit:** 4px
- **Micro Spacing:** 4px (Between icon and text inside a button)
- **Standard Spacing:** 8px (Between buttons in a row)
- **Section Spacing:** 16px (Between distinct groups of information)
- **Container Padding:** 24px (Outer padding for modals and cards)
- **Macro Spacing:** 32px or 48px (Between major sections on a full-screen HUD)

---

## 2. Corner Radii (Border Radius)

Curvature defines our hierarchy and relates to our "Industrial" aesthetic (machined edges).

- **Inner Elements (Tags, Badges, Small Icons):** 4px
- **Interactive Elements (Buttons, Inputs, Small Cards):** 8px
- **Structural Elements (Modals, Panels, Large Cards):** 16px
- **Circular Elements (Avatars, Circular Buttons):** 50% (Fully rounded)

*Rule:* If a container has an 8px radius and 4px padding, the inner element should have a 4px radius to perfectly nest.

---

## 3. Typography Hierarchy

Refer to `DESIGN_SYSTEM.md` for specific font families (e.g., Gotham/Montserrat for headers, Inter/Roboto for body). Here is the hierarchical application:

- **H1 (Display):** 48px, Bold, Uppercase. Use for major screen titles (e.g., "AETHERIC REFINERY").
- **H2 (Section Header):** 32px, Semi-Bold, Uppercase. Use for modal titles.
- **H3 (Subsection):** 24px, Medium, Title Case. Use for card titles.
- **Body (Primary):** 16px, Regular. Use for main descriptions and chat.
- **Body (Secondary):** 14px, Regular, 70% Opacity. Use for lore text and minor details.
- **Micro (Badges/Tags):** 12px, Bold, Uppercase. Use for quantities ("x14") and rarity tags.

*Rule:* All UI text MUST utilize `UIStroke` or `TextStrokeTransparency` to ensure readability against dynamic 3D backgrounds.

---

## 4. Shadows and Depth

Elevation is critical to separate interactive elements from background panels.

- **Level 0 (Flat):** No shadow. Background panels.
- **Level 1 (Card):** Y-Offset: 4px, Blur: 8px, Color: `#000000` at 30% opacity.
- **Level 2 (Dropdown/Hover):** Y-Offset: 8px, Blur: 16px, Color: `#000000` at 40% opacity.
- **Level 3 (Modal/Popup):** Y-Offset: 16px, Blur: 32px, Color: `#000000` at 50% opacity.

---

## 5. Gradients & Glow Intensity

Gradients should be used sparingly to indicate premium or magical states, not as a crutch for generic backgrounds.

- **Primary Glow (Magitek Core):** `Color3.fromRGB(0, 255, 200)` (Cyan) with a blur radius of 12-24px depending on the element size. Use this for active states and rare items.
- **Warning Glow (Overheating/Danger):** `Color3.fromRGB(255, 60, 0)` (Neon Orange/Red).
- **Background Gradients:** If used, should be extremely subtle linear gradients (e.g., from `#1A1C20` to `#0D0E12`) to provide a sense of metallic depth, never loud rainbow gradients.

---

## 6. Naming Conventions

Consistency in naming prevents confusion in both code and asset libraries.

- **Folders/Directories:** `UPPER_SNAKE_CASE` (e.g., `05_CREATIVE_AND_MARKETING`)
- **Files (Scripts, Markdown):** `PascalCase.lua` or `UPPER_SNAKE_CASE.md` depending on established patterns.
- **UI Instances:** `PascalCase` (e.g., `InventoryMainPanel`, `ConfirmButton`)
- **Icons/Textures (Asset IDs):** `prefix_descriptor_state` in `snake_case` (e.g., `ic_gem_ruby_active`, `tex_brass_scratched`)
- **Game Items:** `Title Case` (e.g., "Aetheric Compressor", "Raw Voidstone")

---

## 7. Terminology & Copywriting

Standardize terms so players don't get confused.

- **Use "Craft"**, not "Make" or "Build" (unless referring to base building).
- **Use "Refine"**, not "Process" or "Smelt".
- **Use "Sanctum"**, not "Church" or "Temple".
- **Use "Yield"**, not "Drop Rate".
- **Use "Blueprint"**, not "Recipe".

### Capitalization Rules
- Always capitalize named in-game Items, Machines, and Factions (e.g., "Use the Copper Wire in the Assembler").
- UI Buttons use **Title Case** (e.g., "Refine Materials", "Cancel Order").

### Emoji Policy
- **Strictly Prohibited in UI:** Emojis (🔥, ⚔️, 💰) look cheap and break immersion. We use custom SVG/Image icons for all UI elements.
- **Allowed:** Emojis are only allowed in developer documentation (like this wiki), git commit messages, and community Discord announcements.

---

## 8. Iconography Grid (The Icon System)

All custom 2D icons must fit within a standard container grid to ensure consistent visual weight.

- **Base Canvas:** 256x256 or 512x512.
- **Safe Zone:** 10% padding from the edge (e.g., a 256x256 icon should fit its main mass within a 204x204 central bounding box).
- **Perspective:** 
  - *Materials/Resources:* Isometric (3/4 view) to show volume.
  - *UI Actions (Settings, Close, Search):* Flat, front-facing, single-color (usually white/off-white).
- **Line Weight:** If using outlined styles, the line weight must be visually consistent (e.g., an 8px stroke on a 256x256 canvas).

---

## 9. Implementation Checklist

Before approving any UI or visual asset, ask:
1. Does it use the 4px/8px grid?
2. Are corner radii mathematically consistent?
3. Is `UIStroke` applied for contrast?
4. Are all terms from the standard terminology list?
5. Are there exactly zero emojis used in the final render?
