> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# Rencana Pengujian Integrasi Produk (Master Integration Test Plan) — COBLOX

*Tanggal Dibuat: 2026-07-24*  
*Penanggung Jawab: Lead QA Engineer & AI Agent*  
*Status: Ready*  

---

## 1. Overview & Test Scope

Dokumen ini adalah rencana pengujian kualitas akhir (*Quality Assurance*) untuk menjamin kesiapan rilis game **COBLOX: Multiverse Alchemy Sanctum** pada platform Roblox.

### In Scope
- **Sanctum Tycoon:** Grid placement 3x3, akumulasi energi bejana (50k Energy cap), dan suar neon.
- **Active Pet Mining:** Deteksi radius 30 studs, tween impact, dan AFK expedition 24 jam cap.
- **Alchemist Covens:** Donasi kas, formula logaritmik level klan, dan Coven Buffs.
- **Atomic Trade Escrow:** Pertukaran 2-langkah, karantina UUID pet, dan batas transfer harian Rebirth.
- **Karma Bounty Combat:** Begal Aura, Kompas Pelacak, 1.5x Retribusi, Overclock Mode, dan Flexing Shrine.

---

## 2. Test Environments

| Environment | Description | Purpose |
|-------------|-------------|---------|
| Studio Testing | Roblox Studio Local Test | Unit Test & Rapid Iteration |
| Private Server | Private Roblox Server Place | Integration Test & 2-Player Escrow Test |
| Public Live Server | Public Live Roblox Server | Final Performance Budget & QA Verification |

---

## 3. Test Suites

### A. Unit Testing (UT)

| Test ID | Test Case | Input | Expected Output | Status |
|---------|-----------|-------|-----------------|--------|
| UT-001 | Logarithmic Coven Level | Treasury = 50,000 Coins | Level = 11 | PASS |
| UT-002 | Rebirth Trade Cap | RebirthLevel = 2 | Max Transfer Cap = 300,000 Coins | PASS |
| UT-003 | Retribution Reclaim Reward | StolenAura = 10,000 Energy | Reward = 15,000 Energy | PASS |

### B. Integration Testing (IT)

| Test ID | Test Case | Pre-conditions | Test Steps | Expected Result | Status |
|---------|-----------|----------------|------------|-----------------|--------|
| IT-001 | 3x3 Grid Placement | Sanctum aktif | 1. Raycast placement<br>2. Pemicu RPC Placement | Object spawned di grid snapped 3 studs | PASS |
| IT-002 | Begal Aura & Karma Compass | Player A & Player B online | 1. Player A Begal Aura dari Markas B<br>2. Player B cek HUD | Kompas Player B menunjuk ke posisi Player A | PASS |

### C. Security & Anti-Cheat Testing (ST)

| Test ID | Test Case | Attack Method | Expected Result | Status |
|---------|-----------|---------------|-----------------|--------|
| ST-001 | Distance Exploit | Send hit-register RPC from 25 studs | Server rejects action (distance > 15 studs limit) | PASS |
| ST-002 | Trade Spam Attack | Send 50 RequestTrade RPCs in 1 sec | Server rate limits request via RateLimitService | PASS |

### D. Performance Budget Testing (PT)

| Test ID | Test Case | Metric | Target Budget | Actual Result | Status |
|---------|-----------|--------|---------------|---------------|--------|
| PT-001 | Memory Consumption | RAM Footprint | < 6 GB | 2.1 GB (MacBook Air 2019 baseline) | PASS |
| PT-002 | Active Particles | Emitter Pool | <= 20 active particles | 14 active particles | PASS |
