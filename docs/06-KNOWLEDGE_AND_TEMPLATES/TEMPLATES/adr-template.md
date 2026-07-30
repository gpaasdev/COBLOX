> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# ADR-[NNNN]: [Judul Keputusan]

> **[🏠 Master Index](../MASTER_INDEX.md) | [⬅️ Back to Docs](../README.md)**

## Status

[Proposed | Accepted | Deprecated | Superseded by ADR-XXXX]

## Date

[YYYY-MM-DD — Tanggal ADR ini ditulis]

## Last Verified

[YYYY-MM-DD — Tanggal terakhir verifikasi akurasi ADR ini]

## Decision Makers

[Siapa saja yang terlibat dalam pengambilan keputusan ini]

## Summary

[2 kalimat: Masalah apa yang diselesaikan oleh ADR ini, dan apa keputusan akhirnya. Ditulis untuk efisiensi pemindaian cepat — sebutkan secara spesifik: nama sistem, masalah, dan metode yang dipilih.]

## Roblox Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Roblox Studio + Luau |
| **Domain** | [Physics / Rendering / UI / Audio / Navigation / Animation / Network / Core / Input / Scripting] |
| **Knowledge Risk** | [Low — Dalam data pelatihan / Medium — Perlu verifikasi / High — Wajib pengujian langsung] |
| **Reference Lookup** | [Seperti `GameConfig.luau`, `VISION.md`] |
| **API Used** | [Roblox API spesifik yang diandalkan oleh keputusan ini] |
| **Validation Needed** | [Perilaku spesifik yang perlu diuji pada versi target Roblox, atau "None"] |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | [ADR-NNNN (Wajib di-accept terlebih dahulu), atau "None"] |
| **Enables** | [ADR-NNNN (ADR ini membuka jalan bagi keputusan tersebut), atau "None"] |
| **Blocks** | [Nama Epic/Story — Tidak dapat dimulai sebelum ADR ini di-accept, atau "None"] |
| **Ordering Notes** | [Catatan urutan eksekusi lainnya yang belum tercakup di atas] |

---

## Context

### Problem Statement

[Masalah apa yang sedang kita selesaikan? Mengapa keputusan ini harus dibuat sekarang? Apa konsekuensinya jika tidak mengambil keputusan?]

### Current State

[Bagaimana sistem bekerja saat ini? Masalah apa yang ada pada pendekatan saat ini?]

### Constraints

- [Technical Constraints — Batasan Roblox Engine, persyaratan platform]
- [Time Constraints — Tekanan deadline, dependensi lain]
- [Resource Constraints — Ukuran tim, keahlian yang tersedia]
- [Compatibility Requirements — Harus kompatibel dengan sistem yang ada]

### Requirements

- [Functional Requirement 1]
- [Functional Requirement 2]
- [Performance Requirement — Spesifik dan dapat diukur]
- [Scalability Requirement]

---

## Decision

[Keputusan teknis yang eksplisit dan cukup detail agar dapat diimplementasikan tanpa perlu klarifikasi tambahan.]

### Architecture

```
[Diagram ASCII yang menunjukkan arsitektur sistem dari keputusan ini.
Menampilkan komponen, arah aliran data (data flow), dan interface utama.]
```

### Key Interfaces

```lua
-- [Definisi Interface yang dibuat oleh keputusan ini]
-- Ini menjadi kontrak kerja yang wajib dipatuhi oleh implementer

local ISystemName = {
    method1 = function(self, param1, param2) end,
    method2 = function(self, param1) end,
}
```

### Implementation Guidelines

[Panduan spesifik bagi programmer untuk mengimplementasikan keputusan ini.]

```lua
-- Struktur contoh implementasi
local SystemName = {}
SystemName.__index = SystemName

function SystemName.new()
    local self = setmetatable({}, SystemName)
    return self
end
```

---

## Consequences

### Positive Consequences

- [Dampak positif 1]
- [Dampak positif 2]

### Negative Consequences / Trade-offs

- [Dampak negatif atau Trade-off 1]
- [Dampak negatif atau Trade-off 2]

### Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risiko A] | High/Med/Low | High/Med/Low | [Strategi Mitigasi] |

---

## Verification Plan

### Automated Tests

- [ ] Unit Test: [Nama Test / Perilaku]
- [ ] Integration Test: [Alur pengujian]

### Manual Verification

- [ ] [Langkah-langkah pengujian manual di Roblox Studio atau Live Server]
