> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# ADR-002: Adopsi Service-Oriented Architecture (SOA)

## Status

Accepted

## Date

2026-07-02

## Decision Makers

Core Engineering Team

## Summary

Pemisahan tegas logika aplikasi menjadi Client Controllers (`src/Client/Controllers/`) dan Server Services (`src/Server/Services/`) untuk menjaga Server Authority dan modularitas kode.

## Roblox Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Roblox Studio + Luau |
| **Domain** | Architecture / Framework |
| **Knowledge Risk** | Low |
| **API Used** | ReplicatedStorage, ServerScriptService |

## Context

Tanpa pemisahan arsitektur yang jelas, logika game Roblox sering tercampur antara tampilan (UI/Rendering) dan logika bisnis (Ekonomi/Inventory), yang memicu risiko exploit dan kode yang sulit dipelihara.

## Decision

Menetapkan aturan **Service-Oriented Architecture (SOA)**:
- **Server Services:** Pengelola logika bisnis, penyimpanan data, dan validasi otoritas.
- **Client Controllers:** Pengelola visual, audio, input handling, dan rendering UI.
