---
name: ui-ux-game-design-standards
description: >-
  General UI/UX, visual design, and copywriting standards for web, desktop, and game
  interfaces. Enforces Anti-AI-slop principles, vibrant color palettes, tactile feedback,
  responsive layouts, and visual juiciness.
---

# UI/UX & Visual Design Standards

## Overview
This skill provides universal UI/UX guidelines to ensure every application or game created produces a premium, visual-first, and highly engaging user experience.

## Design Rules

### 1. Anti-AI-Slop & Premium Aesthetics
- **No Generic Color Schemes**: Avoid plain red/blue/green defaults. Use curated, harmonious HSL palettes with dark modes, glassmorphism, and accent gradients.
- **Modern Typography**: Use modern web fonts (e.g. Inter, Outfit, Roboto) or custom game typography with proper hierarchy and line height.

### 2. Tactile Feedback & Micro-Animations
- **Interactive States**: Buttons and interactive objects must bounce or scale using elastic spring tweening on hover/press.
- **Auditory & Haptic Feedback**: Pair visual actions with sound chimes and subtle camera/viewport shakes.

### 3. Spatial & Clean Layouts
- **Uncluttered Viewports**: Hide deep menus inside collapsible side drawers (`MaxWidth` constraints).
- **Diegetic & Spatial UI**: Prefer 3D in-world interactive prompts (SurfaceGui/ProximityPrompt) over heavy 2D overlays when applicable.

## Quality Checklist
- [ ] Vibrant, non-default color palette
- [ ] Smooth spring transitions on interactive elements
- [ ] Clean responsive layout across screens (Mobile, Desktop, Console)
- [ ] Zero static placeholder images or text
