> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# Rencana Pengujian (Test Plan): [Nama Sistem]

> **[🏠 Master Index](../MASTER_INDEX.md) | [⬅️ Back to Docs](../README.md)**

*Tanggal Dibuat: [Tanggal]*  
*Penanggung Jawab: [Nama]*  
*Status: [Draft / Ready / Executing / Complete]*  

---

## Overview

[Rencana pengujian ini mencakup sistem apa? Apa tujuan dari pengujian ini?]

---

## Test Scope

### In Scope
- [Fitur 1]
- [Fitur 2]
- [Fitur 3]

### Out of Scope
- [Fitur di luar cakupan 1]
- [Fitur di luar cakupan 2]

---

## Test Environment

| Environment | Description | Purpose |
|-------------|-------------|---------|
| Studio Testing | Roblox Studio Local Test | Unit Test & Iterasi Cepat |
| Private Server | Server Roblox Privat | Integration Test & Multi-Player Test |
| Public Server | Server Roblox Publik | Final Pre-Launch Test |

---

## Test Types

### 1. Unit Testing

Menguji modul fungsi secara independen.

| Test ID | Test Case | Input | Expected Output | Actual Result | Status |
|---------|-----------|-------|-----------------|---------------|--------|
| UT-001 | Kalkulasi Coins | base=10, mult=2.0 | 20 | | |
| UT-002 | Kalkulasi Gems | totalScore=10000, resets=5 | 15 | | |
| UT-003 | Upgrade Cost | level=3 | 500 | | |

### 2. Integration Testing

Menguji interaksi antar modul.

| Test ID | Test Case | Pre-conditions | Test Steps | Expected Result | Status |
|---------|-----------|----------------|------------|-----------------|--------|
| IT-001 | Sentuh Objek dapat Coins | Player online, Objek eksis | 1. Sentuh objek<br>2. Cek Coins | Coins bertambah | |
| IT-002 | Rebirth dapat Gems | Player memiliki Coins | 1. Klik Rebirth<br>2. Cek Gems | Gems bertambah, Coins di-reset | |
| IT-003 | Beli Upgrade | Player punya Coins cukup | 1. Klik Upgrade<br>2. Cek level & Coins | Level +1, Coins berkurang | |

### 3. Multiplayer Testing

Menguji skenario multi-pemain (Multiplayer).

| Test ID | Test Case | Player Count | Test Steps | Expected Result | Status |
|---------|-----------|--------------|------------|-----------------|--------|
| MT-001 | Sentuh objek bersamaan | 2 | 1. 2 Player menyentuh objek bersamaan<br>2. Cek Coins masing-masing | Masing-masing mendapat Coins secara independen | |
| MT-002 | PVP Combat | 2 | 1. Player A menyerang Player B<br>2. Cek Damage | Damage terkalkulasi dengan benar | |
| MT-003 | Boss Battle | 5 | 1. 5 Player menyerang Boss bersamaan<br>2. Cek reward | Last-hit player dapat bonus, peserta lain dapat participation reward | |

### 4. Boundary Testing

Menguji Edge Cases dan nilai ekstrem.

| Test ID | Test Case | Boundary Condition | Expected Result | Status |
|---------|-----------|--------------------|-----------------|--------|
| BT-001 | Coins Overflow | Coins mencapai Max Limit | Tidak overflow, bertahan di Max Limit | |
| BT-002 | Zero Multiplier | Seluruh multiplier = 0 | Mengembalikan 0 atau nilai minimum | |
| BT-003 | Negative Input | Input nilai negatif | Di-reject atau di-clamp ke 0 | |
| BT-004 | Empty Data | DataStore mengembalikan nil | Menggunakan Default Data | |

### 5. Performance Testing

Menguji performa dan penggunaan sumber daya.

| Test ID | Test Case | Test Method | Metric | Target | Actual Result | Status |
|---------|-----------|-------------|--------|--------|---------------|--------|
| PT-001 | Spawn Object Perf | 1000 objek spawn bersamaan | Frame Rate | ≥60 fps | | |
| PT-002 | Calculation Perf | 1000x kalkulasi/detik | Execution Time | ≤1 ms | | |
| PT-003 | DataStore Request | 10 Player save bersamaan | Request Time | ≤3 s | | |
| PT-004 | Memory Usage | Running 1 jam | Memory Growth | ≤10 MB | | |

### 6. Security Testing

Menguji sistem Anti-Cheat dan keamanan data.

| Test ID | Test Case | Attack Method | Expected Result | Status |
|---------|-----------|---------------|-----------------|--------|
| ST-001 | Fake RemoteEvent | Client mengirim data palsu | Server menolak request, catat Log Warning | |
| ST-002 | Spam Purchase | Klik beli berkali-kali secara instan | Hanya diproses 1 kali (RateLimited) | |
| ST-003 | Data Tampering | Mengubah data lokal | Data server tidak berpengaruh (Server-Authoritative) | |
