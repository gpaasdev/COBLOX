[🏠 Master Index](../../MASTER_INDEX.md) > [🎨 Product & Design](./) > UI Component Library

# 🗃️ COBLOX UI Component Library

> **The Building Blocks of Interaction**
> This library inventories every permitted UI component in COBLOX. If a design requires a component not listed here, it must be formally proposed and added to this library first.

---

## 1. Anatomy of Components

Every component must define its anatomy (padding, fonts, colors) according to the [Style Guide](STYLE_GUIDE.md).

### States
All interactive components must support the following states:
- **Default:** Standard resting state.
- **Hover/Focus:** Visual indication of interactivity (e.g., slight scale up, brighter stroke).
- **Pressed/Active:** Tactile feedback (e.g., scale down, darker background).
- **Disabled:** Visually muted (e.g., 50% opacity, grayscale, no hover effect).

---

## 2. Component Inventory

### 2.1 Buttons
- **Primary Button:** Solid background (Brand Accent). Used for the main action on a screen (e.g., "Craft").
- **Secondary Button:** Outlined (Stroke only). Used for alternative actions.
- **Danger Button:** Solid background (Warning Red). Used for destructive actions (e.g., "Delete Save").
- **Icon Button:** Circular or square button containing only an icon. Used for close buttons, settings, or tight spaces.

### 2.2 Cards & Panels
- **Standard Card:** 16px corner radius, Level 1 shadow. Used to group related information (e.g., a Quest Card).
- **Machine Card:** A specialized card showing machine stats, current fuel, and an active progress bar.
- **Item/Spirit Card:** A card displaying an item's 3D viewport, rarity color background, and lore description.

### 2.3 Modals & Dialogs
- **Confirmation Modal:** Centered overlay, background blur, Level 3 shadow. Asks "Are you sure?"
- **Toast Notification:** Temporary slide-in notification at the top/bottom of the screen (e.g., "Inventory Full"). 

### 2.4 HUD Elements
- **Progress Widget:** A radial or linear bar showing completion (e.g., smelting progress).
- **Inventory Slot:** A 64x64 square (8px radius) with an icon, quantity badge (bottom right), and rarity stroke.
- **Status Badge:** A small pill-shaped indicator (e.g., "🟢 Online", "🔴 Overheating").
- **Tooltip:** Appears on hover/long-press. Dark background, white text. Must spawn instantly but fade in over 0.1s.

### 2.5 Complex Systems
- **Crafting Grid:** A matrix of Inventory Slots with directional arrows pointing to an Output Slot.
- **Marketplace Tile:** A vertical card showing item, price, seller, and a "Buy" button.

---

## 3. Animation & Responsive Behavior

- **Animation:** All components use spring physics (e.g., Flipper module) for state transitions. No linear tweens for UI scale.
- **Responsive Behavior:** Components must use `UIAspectRatioConstraint` or relative scale (UDim2) to ensure they do not stretch on ultrawide monitors or squash on mobile phones. Text must use `UITextSizeConstraint`.

---

## 4. Accessibility Rules
*(See [Accessibility Standard](../04-UX_AND_AUDIO/ACCESSIBILITY_STANDARD.md) for full details)*
- All touch targets (buttons) must be a minimum of 44x44 dp equivalent on mobile.
- All text must pass WCAG AA contrast ratios against its background state.
