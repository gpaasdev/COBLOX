> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# ADR-004: Model Server-Authoritative Zero-Trust Security

## Status

Accepted

## Date

2026-07-05

## Decision Makers

Core Security & Backend Architecture

## Summary

Seluruh kalkulasi koin, transaksi, interaksi combat, dan klaim hadiah wajib diverifikasi 100% di server dengan batasan fisik ($\le 15$ studs) dan rate limiting.

## Roblox Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Roblox Studio + Luau |
| **Domain** | Security / Network |
| **Knowledge Risk** | Low |
| **API Used** | RemoteEvent, RemoteFunction, NetChannels |

## Context

Klien pada Roblox dapat dimodifikasi oleh pemain berbahaya (exploiter). Kepercayaan pada data yang dikirim oleh klien adalah penyebab utama exploit duplikasi item dan pencurian saldo.

## Decision

Menetapkan kebijakan **Zero-Trust**:
1. Klien tidak pernah mengirimkan nilai numerik (koin/damage) ke server; klien hanya mengirimkan Niat (Intent).
2. Server selalu memeriksa jarak fisik ($\le 15$ studs) dan RateLimit via `RateLimitService.luau`.
