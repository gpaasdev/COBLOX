> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# GDD Sub-sistem: Sanctum Tycoon & 3x3 Grid Placement Engine

> **Status**: Approved  
> **Penulis**: Lead Systems Designer & AI Agent  
> **Terakhir Diperbarui**: 2026-07-24  
> **Verifikasi Terakhir**: 2026-07-24  
> **Pilar Implementasi**: Core Automation & Sanctum Building  

---

## Executive Summary

Sub-sistem Sanctum Tycoon mengendalikan pembangunan pabrik alkimia otomatis pemain di area pulau pribadi. Pemain menata posisi mesin, dropper, dan bejana alkimia dalam matriks *3x3 Modular Grid Placement* untuk menghasilkan kristal energi murni secara otomatis.

---

## Core Rules & Architecture

1. **3x3 Grid Snapping**: Penataan mesin dilakukan menggunakan matematika Raycast dari kursor mouse klien yang dipatok (*grid snapped*) pada kelipatan 3 studs.
2. **Bejana Energi (Energy Vault)**: Energi kristal ditampung hingga kapasitas maksimal 50,000 Energy. Saat Bejana penuh, suar aura neon memancar ke langit.
3. **Server-Authoritative Grid Validation**: `PlacementService.luau` memverifikasi di server bahwa posisi placement berada di dalam batas pulau (AABB Bounds) dan tidak menumpuk (*overlapping*) dengan mesin lain.

---

## Formulas

### Yield Accumulation Rate

```lua
energy_yield = base_dropper_rate * (1 + rebirth_multiplier) * event_multiplier
```

| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| base_dropper_rate | float | 1-500 | EconomyConfig | Output energi per detik mesin |
| rebirth_multiplier | float | 0.0-10.0 | Player Profile | Buff permanen dari Rebirth |
| event_multiplier | float | 1.0-3.0 | LiveOps | Buff event akhir pekan |

---

## Edge Cases & Mitigation

| Scenario | Expected Behavior | Rationale |
|----------|-------------------|-----------|
| Pemain mencoba meletakkan mesin di luar area Sanctum | Server menolak paket RPC (`ServiceResult.Success = false`) | Mencegah eksploitasi placement melayang |
| Dua mesin diletakkan di grid coordinate yang sama | PlacementService membatalkan item kedua | Mencegah penumpukan hitbox |

---

## Tuning Knobs

| Parameter | Current Value | Safe Range | Effect when Increased | Effect when Decreased |
|-----------|---------------|------------|-----------------------|-----------------------|
| Bejana Capacity | 50,000 | 10,000 - 200,000 | Waktu kumpul lebih lama | Lebih sering kumpul energi |
| Grid Unit Size | 3 studs | 2 - 5 studs | Area placement lebih renggang | Placement lebih padat |
