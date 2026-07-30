> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# Model Ekonomi: [Nama Sistem]

> **[🏠 Master Index](../MASTER_INDEX.md) | [⬅️ Back to Docs](../README.md)**

*Tanggal Dibuat: [Tanggal]*  
*Penanggung Jawab: [Nama]*  
*Status: [Draft / Balanced / Live]*  

---

## Overview

[Sistem ekonomi ini mencakup sumber daya, mata uang, dan sistem pertukaran apa? Perilaku pemain seperti apa yang didorong/diinsentifkan?]

---

## Currencies

| Currency | Type | Earning Rate | Sink Rate | Cap | Notes |
|----------|------|--------------|-----------|-----|-------|
| [Coins] | Soft Currency | [Per jam] | [Per jam] | [Max atau None] | [Mata uang transaksi utama] |
| [Gems / ChronoSparks] | Premium / Progress Currency | [Setiap Rebirth] | [Pengeluaran Evolution] | [None] | [Non-tradeable / Tradeable] |

### Currency Rules
- [Aturan 1 — Misal "Soft Currency tidak memiliki Hard Cap, namun inflasi dikendalikan via Sinks"]
- [Aturan 2]
- [Aturan 3]

---

## Sources (Faucets)

| Source | Currency | Amount | Frequency | Conditions |
|--------|----------|--------|-----------|------------|
| [Sentuh Objek] | Coins | [1-100] | [Per Interaksi] | [Berdasarkan tipe item dan Buff] |
| [Kalahkan Boss] | Coins | [500-2000] | [Per Kill] | [Berdasarkan level Boss] |
| [Rebirth / Reset] | Gems | [Berdasarkan Total Coins] | [Per Rebirth] | [Cap 20x, Rate 0.001] |
| [Daily Streak] | Coins | [100-500] | [Harian] | [Bonus login beruntun] |

---

## Sinks (Pengeluaran)

| Sink | Currency | Cost | Frequency | Purpose |
|------|----------|------|-----------|---------|
| [Pembelian Upgrade] | Coins | [100-5000] | [Saat Diperlukan] | [Peningkatan Stat] |
| [Evolution Tree] | Gems | [10-100] | [Permanen] | [Peningkatan Stat Permanen] |
| [Buka Zone / Gate] | Gems | [96] | [Per Zone] | [Pembukaan Area Baru] |
| [Respawn] | Coins | [0] | [Saat Kematian] | [Tanpa Penalti / Free] |

---

## Balancing Targets

| Metric | Target | Rationale |
|--------|--------|-----------|
| Pemain Baru hingga Pembelian Bermakna Pertama | [X Menit] | [Pemain harus merasakan daya beli di awal permainan] |
| Perolehan Coins Per Jam (Mid-game) | [X Coins/Jam] | [Berdasarkan durasi sesi dan ritme pembelian] |
| Durasi Menyelesaikan Seluruh Upgrade | [X Jam] | [Cukup untuk retensi tanpa membuat frustrasi] |
| Rasio Sinks vs Sources | [0.7 - 0.9] | [Sedikit surplus agar pemain merasa kaya] |

---

## Progression Curves

### Upgrade Costs
| Level | Cost | Cumulative Cost | Estimated Time |
|-------|------|-----------------|----------------|
| 1→2 | [100] | [100] | [10 Menit] |
| 2→3 | [250] | [350] | [30 Menit] |
| 3→4 | [500] | [850] | [1 Jam] |
| 4→5 | [1000] | [1850] | [2 Jam] |

*Formula*: `Cost(n) = BaseCost * 2^(n-1)`

---

## Drop Tables

### [Nama Sumber Drop]
| Item | Rarity | Drop Rate | Pity Counter | Notes |
|------|--------|-----------|--------------|-------|
| [No Drop] | None | [35%] | [N/A] | [Tanpa hadiah] |
| [Health Potion] | Common | [25%] | [N/A] | [Pemulihan 35 HP] |
| [Energy Cookie] | Common | [40%] | [N/A] | [Pemulihan Stamina] |

### Pity System
[Jelaskan bagaimana Pity System mencegah nasib buruk beruntun bagi pemain.]
