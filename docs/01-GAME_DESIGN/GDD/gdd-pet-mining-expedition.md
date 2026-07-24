> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# GDD Sub-sistem: Active Pet Mining & AFK Expedition

> **Status**: Approved  
> **Penulis**: Lead Gameplay Programmer & AI Agent  
> **Terakhir Diperbarui**: 2026-07-24  
> **Verifikasi Terakhir**: 2026-07-24  
> **Pilar Implementasi**: Pet Collection & Passive Progression  

---

## Executive Summary

Sub-sistem Active Pet Mining memungkinkan *Spirit Pets* yang dipanggil oleh pemain untuk secara aktif melacak, meluncur, dan menambang *Crystal Nodes* terdekat. Selain itu, pemain dapat menugaskan pet pada *AFK Expeditions* untuk mengumpulkan bahan langka dan ChronoSparks (Gems) secara luring.

---

## Core Rules & Mechanics

1. **Auto-Mining Radius**: Pet mendeteksi *Crystal Node* terdekat dalam jangkauan radius 30 studs setiap 2 detik.
2. **Tween Impact Animation**: Pet meluncur menuju node menggunakan animasi *Back Out Easing* elastis dan memicu efek *Particle Trail Aura*.
3. **AFK Expedition**: Pet yang dikirim pada ekspedisi akan tetap mengumpulkan hadiah saat pemain offline hingga batas 24 jam.

---

## Formulas

### Pet Damage per Hit

```lua
damage = pet_base_power * (1 + elemental_affinity_bonus) * coven_buff
```

| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| pet_base_power | float | 5-1000 | PetData | Kekuatan dasar pet berdasarkan Rarity |
| elemental_affinity_bonus | float | 0.0-0.5 | Item System | Bonus elemen serupa |
| coven_buff | float | 0.0-0.25 | Coven System | Bonus dari klan |

---

## Edge Cases

| Scenario | Expected Behavior | Rationale |
|----------|-------------------|-----------|
| Node hancur sebelum Pet sampai | Pet membatalkan Tween dan melacak node terdekat lain | Mencegah Pet terjebak di koordinat kosong |
| Pemain offline lebih dari 24 jam saat ekspedisi | Akumulasi hadiah di-clamp pada batas 24 jam | Menjaga keseimbangan ekonomi AFK |

---

## Tuning Knobs

| Parameter | Current Value | Safe Range | Effect when Increased | Effect when Decreased |
|-----------|---------------|------------|-----------------------|-----------------------|
| Detection Radius | 30 studs | 15 - 50 studs | Jangkauan tambang lebih jauh | Pet hanya menambang objek dekat |
| Expedition Cap | 24 jam | 8 - 48 jam | Waktu klaim lebih longgar | Pemain harus sering login |
