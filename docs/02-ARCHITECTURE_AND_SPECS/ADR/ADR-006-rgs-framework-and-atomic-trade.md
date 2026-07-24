> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# ADR-006: Kerangka Kerja Roblox Game Studios (RGS) & Protokol Atomic Trade Escrow

## Status

Accepted

## Date

2026-07-24

## Decision Makers

Lead Architect & AI Coding Assistant Agent

## Summary

Mengadopsi kerangka kerja Roblox Game Studios (RGS) untuk otomatisasi review desain, review kode, dan pengecekan keseimbangan ekonomi, serta menerapkan protokol pertukaran atomik 2-langkah (*Atomic 2-Step Escrow*) pada `TradeService.luau`.

## Roblox Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Roblox Studio + Luau (`--!strict`) |
| **Domain** | Framework / Governance / Economy |
| **Knowledge Risk** | Low |
| **API Used** | HttpService (GUID), ProfileStore v3, NetChannels |

## Context

Proyek memerlukan standar evaluasi yang konsisten saat agen AI menambahkan fitur baru, serta mekanisme perdagangan item antar-pemain yang terisolasi dari bahaya inflasi dan eksploitasi duplikasi item.

## Decision

1. Memasang **RGS Templates & AI Skills** (`rgs-code-review`, `rgs-design-review`, `rgs-balance-check`) ke dalam `.agents/skills/`.
2. Mengimplementasikan **Atomic 2-Step Trade Escrow** pada `TradeService.luau` dengan validasi Rebirth transfer cap harian per GDD Section 10.
