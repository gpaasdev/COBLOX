[🏠 Master Index](../../MASTER_INDEX.md) > [🎵 UX & Audio](./) > Accessibility Standard

# ♿ COBLOX Accessibility Standard

> **Gaming for Everyone**
> Complex industrial automation games can be visually and cognitively overwhelming. This standard ensures that COBLOX remains playable and enjoyable for as wide an audience as possible. Accessibility is not an afterthought; it is a core design requirement.

---

## 1. Visual Accessibility

### 1.1 Contrast & Color Blindness
- **WCAG AA Compliance:** All UI text must have a minimum contrast ratio of 4.5:1 against its background.
- **Color Independence:** Never rely solely on color to convey information. If a machine is overheating (Red), it must also emit a distinct particle effect (Smoke) and play an audio cue (Warning Siren).
- **Color Blind Filters:** The game must support Tritanopia, Deuteranopia, and Protanopia filters via a settings menu that adjusts specific UI hues (especially resource rarity colors).

### 1.2 Text & Typography
- **Scalable Text:** UI must support a "Large Text" mode that increases base font size from 16px to 24px without breaking the layout.
- **Subtitles:** All voice lines, boss telegraphs, and narrative events MUST have subtitles. Subtitles must feature a semi-transparent black backing plate to ensure readability against bright environments.

---

## 2. Motion & Camera Accessibility

- **Motion Sickness:** Head bobbing, camera shake (e.g., from nearby explosions or heavy machinery), and FOV-altering sprints MUST have a toggle in the settings to disable them.
- **Flash/Strobe Warnings:** Avoid strobe effects greater than 3 flashes per second to prevent triggering photosensitive epilepsy. Lightning strikes and magical bursts must ease-in and ease-out.

---

## 3. Cognitive Accessibility

- **Information Pacing:** Do not overwhelm the player. FTUE (First Time User Experience) must introduce one concept at a time.
- **Always Accessible Glossary:** Players must have access to a "Codex" or "Blueprint Archive" at all times to remind them how specific machines or recipes work.

---

## 4. Motor & Control Accessibility

- **Full Remapping:** Every action in the game must be remappable for Keyboard, Mouse, and Controller.
- **Toggle vs. Hold:** Actions that typically require holding a button (e.g., continuous mining, sprinting) must have a "Toggle" option in the settings.
- **Haptic Feedback:** Controller rumble and mobile haptics should reinforce important events (taking damage, completing a craft), but must have an intensity slider (0-100%).
