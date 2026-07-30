[🏠 Master Index](../../docs/MASTER_INDEX.md)

# 🎵 COBLOX UX & Audio Direction Specification

## 1. UX Player Journey Standards
- **Zero-Friction Onboarding**: 10-Step FTUE State Machine guides players smoothly from initial spawn to Coven unlock.
- **HUD Ergonomics**: Collapsible drawers, uncluttered viewport, diegetic world prompts (`ProximityPrompt`) over 2D screen clutter.

## 2. Audio & Haptic Feedback
- **Tactile Feedback**: Every button press triggers a subtle sound chime combined with `HapticService:SetMotor()` for mobile taps.
- **Ambient Soundscapes**: Distinct atmospheric audio per Biome (Glacial, Void, Volcanic, Abyssal, Subterranean, Celestial).
