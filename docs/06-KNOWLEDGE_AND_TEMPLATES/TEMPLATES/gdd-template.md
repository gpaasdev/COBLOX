> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# [Nama Sistem / Mekanisme]

> **[🏠 Master Index](../MASTER_INDEX.md) | [⬅️ Back to Docs](../README.md)**

> **Status**: Draft | In Review | Approved | Implemented  
> **Penulis**: [Nama atau AI Agent]  
> **Terakhir Diperbarui**: [Tanggal]  
> **Verifikasi Terakhir**: [Tanggal — konfirmasi terakhir akurasi dokumen]  
> **Pilar Implementasi**: [Pilar game yang didukung oleh sistem ini]  

---

## Ringkasan (Executive Summary)

[2-3 kalimat: Sistem apa ini, apa yang dilakukan pemain dengannya, dan mengapa sistem ini ada di dalam game. Ditulis untuk efisiensi pembacaan skenario — gunakan bagian ini untuk memutuskan apakah perlu membaca seluruh dokumen. Tanpa jargon rumit.]

> **Quick Reference** — Layer: `[Base | Core | Feature | Polish]` · Priority: `[MVP | Vertical Slice | Alpha | Full Vision]` · Key Dependencies: `[Nama Sistem atau "None"]`

---

## Overview

[1 paragraf: Jelaskan mekanisme ini kepada seseorang yang belum mengenali proyek. Apa sistemnya, apa yang dilakukan pemain, dan mengapa sistem ini ada?]

---

## Player Fantasy

[Apa yang harus **dirasakan** pemain saat berinteraksi dengan mekanisme ini? Emosi atau power fantasy apa yang dilayani? Bagian ini memandu semua keputusan detail di bawah ini.]

---

## Detailed Design

### Core Rules

[Aturan yang presisi dan bebas ambiguitas. Programmer harus dapat mengimplementasikan bagian ini tanpa perlu ragu. Gunakan aturan bernomor untuk urutan alur, dan bullet points untuk properti.]

### States & Transitions

[Jika sistem ini memiliki State seperti status senjata, status efek, atau stage, catat setiap State dan transisi State yang valid.]

| State | Condition In | Condition Out | Behavior |
|-------|--------------|---------------|----------|
|       |              |               |          |

### Interaction with Other Systems

[Bagaimana sistem ini berinteraksi dengan Combat, Inventory, Progression, dan UI? Untuk setiap interaksi, tentukan Interface: data apa yang masuk, data apa yang keluar, dan siapa yang bertanggung jawab.]

---

## Formulas

[Setiap rumus matematika yang digunakan oleh sistem ini.]

### [Nama Formula]

```lua
result = base_value * (1 + modifier_sum) * scaling_factor
```

| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| base_value | float | 1-100 | Config File | Nilai dasar sebelum modifikasi |
| modifier_sum | float | -0.9 s/d 5.0 | Calculated | Jumlah seluruh modifier aktif |
| scaling_factor | float | 0.5-2.0 | Config File | Scaling berbasis level |

**Expected Output Range**: [Min] s/d [Max]  
**Edge Cases**: Ketika `modifier_sum` < -0.9, clamp ke -0.9 untuk mencegah hasil negatif.

---

## Edge Cases

[Dokumentasikan perilaku pada situasi tidak normal. Setiap Edge Case harus memiliki solusi yang jelas.]

| Scenario | Expected Behavior | Rationale |
|----------|-------------------|-----------|
| [Jika X bernilai Nol?] | [Hal ini akan terjadi] | [Karena alasan ini] |
| [Jika dua efek memicu secara bersamaan?] | [Aturan prioritas] | [Alasan desain] |

---

## Dependencies

[Daftar setiap sistem yang menjadi dependensi atau yang bergantung pada mekanisme ini.]

| System | Direction | Dependency Nature |
|--------|-----------|-------------------|
| [Combat] | Sistem ini bergantung pada Combat | Membutuhkan hasil kalkulasi Damage |
| [Inventory] | Inventory bergantung pada sistem ini | Menyediakan data efek Item |

---

## Tuning Knobs

[Setiap nilai balancing yang dapat disesuaikan. Mencakup nilai saat ini, range aman, dan dampak dari nilai ekstrem.]

| Parameter | Current Value | Safe Range | Effect when Increased | Effect when Decreased |
|-----------|---------------|------------|-----------------------|-----------------------|
|           |               |            |                       |                       |

---

## Visual & Audio Requirements

[Umpan balik visual dan audio apa yang dibutuhkan oleh mekanisme ini?]

| Event | Visual Feedback | Audio Feedback | Priority |
|-------|-----------------|----------------|----------|
|       |                 |                |          |

---

## Game Feel

> **Catatan**: Visual/Audio Requirements mencatat **event** umpan balik apa yang terjadi (pemetaan Event ke Asset). Game Feel mencatat **bagaimana** mekanisme itu dirasakan — responsivitas interaksi, impresi bobot, ritme, dan kualitas kinestetik. Ini adalah target desain untuk budget animasi, arsitektur input handling, dan timing hitbox.

### Reference Feel

[Rujuk game, mekanisme, atau momen spesifik untuk menangkap Game Feel target. Jelaskan kualitas apa yang Anda ambil sebagai referensi.]
