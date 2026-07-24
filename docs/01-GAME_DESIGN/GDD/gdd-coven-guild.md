> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# GDD Sub-sistem: Alchemist Covens (Guild System)

> **Status**: Approved  
> **Penulis**: Lead Social Systems Designer & AI Agent  
> **Terakhir Diperbarui**: 2026-07-24  
> **Verifikasi Terakhir**: 2026-07-24  
> **Pilar Implementasi**: Social Guild & Anti-Inflation Economy  

---

## Executive Summary

Sub-sistem Alchemist Covens memungkinkan pemain membentuk perkumpulan (klan) untuk bergotong-royong mendonasikan koin ke kas klan (*Treasury Pool*). Level klan ditingkatkan menggunakan formula logaritmik anti-inflasi untuk membuka Coven Buffs bagi seluruh anggota.

---

## Core Rules

1. **Coven Creation Cost**: Memerlukan 10,000 Coins untuk mendirikan Ordo Alkemis baru.
2. **Treasury Donation**: Anggota dapat mendonasikan koin ke kas klan untuk menaikkan peringkat klan.
3. **Logarithmic Level Scaling**: Level klan penskalaannya melambat seiring tingginya saldo kas untuk mencegah dominasi klan sultan (*Anti-Inflation*).

---

## Formulas

### Logarithmic Coven Level Formula

```lua
level = math.max(1, math.floor(5 * math.log(treasury_coins / 5000)))
```

| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| treasury_coins | integer | 0 - 100,000,000 | Coven Profile | Total koin terkumpul di kas klan |

---

## Edge Cases

| Scenario | Expected Behavior | Rationale |
|----------|-------------------|-----------|
| Kas klan bernilai 0 Coins | Level klan di-clamp pada nilai minimal Level 1 | Mencegah error `math.log(0)` atau level 0 |
| Pemain keluar klan saat bonus aktif | Buff klan langsung dicabut dari atribut pemain | Mencegah penyalahgunaan buff klan |

---

## Tuning Knobs

| Parameter | Current Value | Safe Range | Effect when Increased | Effect when Decreased |
|-----------|---------------|------------|-----------------------|-----------------------|
| Base Treasury Unit | 5,000 Coins | 1,000 - 20,000 | Lebih sulit naik level | Lebih mudah naik level |
| Creation Cost | 10,000 Coins | 5,000 - 50,000 | Klan lebih eksklusif | Lebih banyak klan kecil |
