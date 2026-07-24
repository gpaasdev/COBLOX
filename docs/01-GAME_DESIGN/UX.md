> **[🏠 Master Index](../MASTER_INDEX.md) | [⬅️ Back to Docs](../README.md)**

# 04 — UX BIBLE & GRAPHICS DATA DEFINITION (GDD)

## 1. UI Screen Flow & Navigation Hierarchy

```text
COBLOX_AlchemyHUD (Main ScreenGui)
├── TopBar (Aura Energy ⚡, ChronoSparks ✨, LiveOps Boost Indicator)
├── Collapsible SideDrawer (MaxWidth = 180px)
│   ├── Grid Sanctum (Placement Engine Toggle)
│   ├── Bejana Sintesis (Synthesis Vessel)
│   ├── Penetasan Spirit (Spirit Hatchery)
│   ├── Ordo Coven (Coven Guild Modal)
│   ├── Kodeks Multiverse (Lore Archive Reader)
│   ├── Pusat Tukar (Trade Escrow Modal)
│   ├── Rebirth (Sanctum Evolution Trigger)
│   └── Toko (Shop & DevProducts)
└── Quick Action HUD (Combat Skill Hotbar: Attack, Dash, Parry)
```

---

## 2. Dynamic Graphics Data Definition (UI Data Contracts)
Sesuai spesifikasi **Graphics Data Definition (GDD)**, setiap modal UI dipisahkan dari logika bisnis dan mengonsumsi *Data Binding Contract* secara dinamis:

### A. Coven Order Modal Data Contract
```json
{
  "covenId": "string",
  "covenName": "string",
  "level": "number",
  "treasuryCoins": "number",
  "globalMultiplierBuff": "number (percentage)",
  "members": ["number (userId)"]
}
```

### B. Trade Escrow Dual-Confirm Data Contract
```json
{
  "sessionState": "Selecting | Locked | CountingDown | Executed",
  "myOffers": [{ "id": "string", "itemType": "Pet | Material", "amount": "number" }],
  "partnerOffers": [{ "id": "string", "itemType": "Pet | Material", "amount": "number" }],
  "countdownRemaining": "number"
}
```

---

## 3. Localization Heuristics (Indonesian-First & Global-Ready)
- **Automatic Language Switcher:** `LocalizationController.luau` membaca `RobloxLocaleId`.
- **Indonesian Default (`id-id`):** Teks menggunakan frasa aksi yang ringkas dan akrab bagi Gen Z/Alpha Indonesia (*"Klaim Plot"*, *"Kunci Penawaran"*, *"Buat Ordo"*).
- **English Default (`en-us`):** Teks menggunakan peristilahan game global (*"Claim Factory Plot"*, *"Lock Offer"*, *"Create Coven"*).

---

## 4. Accessibility & Haptic Feedback Standards
- **Touch Targets:** Ukuran tombol minimal $48\times 48\text{ dp}$ pada perangkat seluler.
- **Button Animation Engine:** Seluruh tombol berinteraksi dengan `UIButtonAnimator.luau` (efek *Hover spring scaling*, *Click audio chime*, dan *UI Spark particle emitters*).
- **Contrast Ratio:** Teks label menggunakan standar rasio kontras 4.5:1 (Slate 900 `#0F172A` background dengan Quantum Gold `#F59E0B` & Spark Cyan `#06B6D4`).
