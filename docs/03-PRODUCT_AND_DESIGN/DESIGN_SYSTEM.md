[🏠 Master Index](../../docs/MASTER_INDEX.md)

# 🎨 COBLOX Unified Design System Specification

## 1. Visual Language & Style
- **Aesthetic**: Modern Dark Glassmorphism (Sci-Fantasy Industrial).
- **Core Visual Tokens**:
  - `Surface_Background`: `#0F1015` (Deep Abyss)
  - `Surface_Glass`: `rgba(26, 29, 38, 0.75)` with `12px` Blur
  - `Primary_Accent`: `#3B82F6` (Alchemy Blue)
  - `Secondary_Accent`: `#10B981` (Aura Emerald)
  - `Warning_Accent`: `#F59E0B` (Chrono Amber)
  - `Mythic_Accent`: `#8B5CF6` (Void Purple)

## 2. Typography Specification
- **Font Family**: Builder Sans / Inter
- **Sizes**:
  - `Title`: 24px Bold (LineHeight: 120%)
  - `Header`: 18px SemiBold (LineHeight: 130%)
  - `Body`: 14px Regular (LineHeight: 140%)
  - `Caption`: 12px Medium (LineHeight: 140%)

## 3. UI Component Standards
- **Buttons**: Touch Target $\ge 44\times44$ dp, `CornerRadius = 8px`, `UIStroke` 1px `#3B82F6`.
- **Containers**: Max Width boundaries (`MaxWidth`), auto-layout `UIListLayout` with `Padding = 8px`.
- **Text Readability (A11y)**: All text elements MUST include `UIStroke` (Black, 0.3 transparency).
