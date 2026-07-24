> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# ADR-005: Client-Side Cosmetic Object Pooling

## Status

Accepted

## Date

2026-07-10

## Decision Makers

Core Client & Graphics Team

## Summary

Menggunakan `ObjectPool.luau` di sisi klien untuk efek visual droppers, koin melayang, dan partikel aura demi menjaga konsumsi memori $< 6\text{ GB}$ RAM dan frame rate $\ge 60$ FPS.

## Roblox Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Roblox Studio + Luau |
| **Domain** | Performance / VFX |
| **Knowledge Risk** | Low |
| **API Used** | Instance.new, Part Cache |

## Context

Membuat dan menghancurkan ratusan Part/Particle secara terus-menerus (`Instance.new` / `:Destroy()`) menyebabkan pembersihan memori (*Garbage Collection*) memicu lag suttering.

## Decision

Seluruh efek visual sementara wajib didaur ulang menggunakan **`ObjectPool.luau`**. Max 20 partikel aktif per emitter.
