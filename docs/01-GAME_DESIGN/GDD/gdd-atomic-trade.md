> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# GDD Sub-sistem: Atomic 2-Step Trade Escrow Protocol

> **Status**: Approved  
> **Penulis**: Lead Security Engineer & AI Agent  
> **Terakhir Diperbarui**: 2026-07-24  
> **Verifikasi Terakhir**: 2026-07-24  
> **Pilar Implementasi**: Zero-Trust Escrow Trading & Anti-Inflation  

---

## Executive Summary

Sub-sistem Atomic Trade menyediakan mekanisme perdagangan antar-pemain yang 100% aman dari duplikasi item dan inflasi. Perdagangan dilakukan melalui 2 tahap konfirmasi (*2-Step Confirmation*) dengan garansi swap atomik dan pembatasan batas transfer harian berbasis Rebirth.

---

## Core Rules

1. **2-Step Confirmation**: Kedua pemain wajib mengonfirmasi penawaran pada Tahap 1 (Lock Offer) dan Tahap 2 (Final Confirmation) sebelum pertukaran dieksekusi.
2. **Item Quarantine**: Pet UUID yang sedang ditawarkan di dalam sesi trade aktif di-quarantine oleh server dan tidak dapat dijual atau dilebur.
3. **Rebirth Transfer Cap**: Transfer koin dibatasi per hari berdasarkan level Rebirth untuk mencegah inflasi akun bot.

---

## Formulas

### Daily Coin Transfer Limit Cap

```lua
max_transfer_cap = (rebirth_level + 1) * 100000
```

| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| rebirth_level | integer | 0 - 50 | Player Profile | Level Rebirth pemain yang mentransfer koin |

---

## Edge Cases

| Scenario | Expected Behavior | Rationale |
|----------|-------------------|-----------|
| Salah satu pemain disconnect saat transaksi dieksekusi | Sesi ditutup otomatis dan seluruh item dikembalikan dari karantina | Menjamin pertukaran bersifat atomik (all-or-nothing) |
| Jumlah koin melebihi batas Rebirth transfer cap | Pertukaran dibatalkan dengan pesan error `TRANSFER_CAP_EXCEEDED` | Mencegah transaksi RMT / bot ilegal |

---

## Tuning Knobs

| Parameter | Current Value | Safe Range | Effect when Increased | Effect when Decreased |
|-----------|---------------|------------|-----------------------|-----------------------|
| Base Rebirth Cap | 100,000 Coins | 50,000 - 500,000 | Batas transfer koin lebih besar | Batas transfer koin lebih ketat |
| RateLimit Window | 0.5 detik | 0.2 - 2.0 detik | Mencegah spam request trade | Pengalaman trade lebih responsif |
