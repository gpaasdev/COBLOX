> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# ADR-003: Sistem Event-Driven Signal

## Status

Accepted

## Date

2026-07-03

## Decision Makers

Core Engineering Team

## Summary

Menggunakan modul `Signal.luau` berkinerja tinggi untuk komunikasi internal antar Service/Controller guna menghilangkan beban CPU akibat Polling / Heartbeat loop.

## Roblox Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Roblox Studio + Luau |
| **Domain** | Core / Messaging |
| **Knowledge Risk** | Low |
| **API Used** | Custom Signal / BindableEvent equivalent |

## Context

Penggunaan loop `task.wait()` atau `RunService.Heartbeat` untuk mengecek perubahan state (seperti jumlah koin atau kesehatan) menguras beban CPU, terutama pada baseline hardware low-end (MacBook Air 2019 / Mobile).

## Decision

Menggunakan sistem **Event-Driven Pub/Sub** berbasis `Signal.luau` untuk seluruh notifikasi perubahan state internal.
