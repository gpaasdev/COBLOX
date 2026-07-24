> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# ADR-001: Penggunaan ProfileStore Dibandingkan ProfileService

## Status

Accepted

## Date

2026-07-01

## Decision Makers

Core Engineering Team

## Summary

Menggunakan ProfileStore v3 sebagai lapisan persistensi DataStore utama menggantikan ProfileService untuk mendapatkan Session Locking otomatis, mitigasi korupsi data, dan dukungan native Luau strict typing.

## Roblox Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Roblox Studio + Luau (`--!strict`) |
| **Domain** | Core / DataStore |
| **Knowledge Risk** | Low |
| **API Used** | DataStoreService, ProfileStore v3 |

## Context

Proyek COBLOX memerlukan penyimpanan data pemain (Sanctum Grid, Currency, Pet Inventory, Coven Data) yang tahan uji terhadap duplikasi item, pemadaman server Roblox, dan masalah pembukaan dua sesi bersamaan (*double session*).

## Decision

Mengadopsi **ProfileStore v3** melalui `ProfileStoreAdapter.luau` dan `PlayerDataService.luau`.

### Implementation Highlights

- **Session Locking:** `PlayerAdded` akan mengklaim kuis sesi secara eksklusif.
- **Exponential Backoff:** Mencoba ulang pengaksesan DataStore hingga 5 kali saat terjadi kegagalan jarangan.
- **Schema Reconciliation:** Menjamin field profil baru otomatis terisi dengan nilai bawaan (*default value*).
