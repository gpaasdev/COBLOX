> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# GDD Sub-sistem: Begal Aura, Karma Bounty & Overclock Mode

> **Status**: Approved  
> **Penulis**: Lead Action & Social Gameplay Designer & AI Agent  
> **Terakhir Diperbarui**: 2026-07-24  
> **Verifikasi Terakhir**: 2026-07-24  
> **Pilar Implementasi**: Action Combat, Social Dynamics & Revenge Loop  

---

## Executive Summary

Sub-sistem ini mengendalikan siklus aksi dan balas dendam (*Revenge Loop*). Pemain dapat membegal aura dari Markas pemain lain (**🥷 Begal Aura**). Korban akan memicu sistem **🎯 Kena Karma!** otomatis dengan Kompas Pelacak untuk memburu pembegal ($\le 15$ studs) dan merebut kembali auranya plus **1.5x Retribusi Bonus**.

---

## Core Rules

1. **Begal Aura Mechanism**: Membegal aura memicu penalti WalkSpeed (-15%) pada pembegal saat membawa muatan kristal energi.
2. **Karma Bounty Tracking**: Korban mengaktifkan Kompas Pelacak di HUD yang mengarah langsung ke posisi pembegal secara real-time.
3. **1.5x Retribution Bonus**: Jika korban berhasil mengalahkan pembegal ($\le 15$ studs), korban mendapatkan seluruh auranya kembali ditambah bonus retribusi 1.5x.
4. **Overclock & Giant Mode**: Meminum ramuan di Lab Racik memicu **⚡ Overclock Mode (Speed 45 + Screen Shake)** atau **Mode Raksasa (Scale 2.5x + 500 HP)**.
5. **Flexing Shrine**: Memungkinkan pemain memamerkan kekayaan di panggung utama dengan memicu Hujan Koin, Sky Color Override 60s, dan Billboard Server.

---

## Formulas

### Retribution Reward Formula

```lua
reclaim_reward = stolen_aura_energy * 1.5
```

| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| stolen_aura_energy | float | 1,000 - 50,000 | Karma Contract | Jumlah energi yang dibegal |

---

## Edge Cases

| Scenario | Expected Behavior | Rationale |
|----------|-------------------|-----------|
| Pembegal disconnect saat dikejar | Aura yang dibegal otomatis kembali ke Bejana korban | Mencegah pembegal kabur dari game (*combat logging*) |
| Jarak serangan melebihi 15 studs saat merebut karma | Server menolak hit-register | Enforcing Zero-Trust physical distance check |

---

## Tuning Knobs

| Parameter | Current Value | Safe Range | Effect when Increased | Effect when Decreased |
|-----------|---------------|------------|-----------------------|-----------------------|
| Retribution Multiplier | 1.5x | 1.2x - 2.0x | Insentif mengejar pembegal lebih besar | Hadiah balas dendam lebih kecil |
| Overclock Speed | 45 WalkSpeed | 30 - 60 | Pergerakan karakter sangat cepat | Pergerakan lebih terkontrol |
| Giant Scale | 2.5x | 1.5x - 4.0x | Ukuran karakter membesar dramatis | Ukuran karakter sedang |
