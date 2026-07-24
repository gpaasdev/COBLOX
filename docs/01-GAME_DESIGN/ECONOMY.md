> **[🏠 Master Index](../MASTER_INDEX.md) | [⬅️ Back to Docs](../README.md)**

# 03 — ECONOMY BIBLE & MONETIZATION STRATEGY

## 1. Currency Taxonomy & Sinks
- **Aura Energy (Coins - Soft Currency 1):** Dihasilkan dari Sanctum Grid, tambang pet, dan Rebirth. Digunakan untuk membiayai upgrade Sanctum, penetasan telur, dan membuat Coven Guild (10k Coins).
- **ChronoSparks (Gems - Soft Currency 2):** Dihasilkan dari Quests, Daily Streaks, dan Ekspedisi Dimensi. Digunakan untuk membuka item eksklusif dan transmudasi elemen.
- **Rebirth Tokens:** Diperoleh khusus melalui Rebirth. Memberikan permanent $+10\%$ Aura Multiplier per token.
- **Coven Treasury Pool:** Koin yang didonasikan oleh anggota klan untuk menaikkan level Coven. Level dihitung dengan formula logaritmik: $\text{Level} = \max\left(1, \lfloor 5 \times \ln(\text{Treasury} / 5000) \rfloor\right)$.
- **Robux (Hard Currency):** Digunakan untuk Developer Products (*Aura Energy Packs*, *ChronoSpark Packs*) dan Gamepasses (*VIP Multiplier*, *Auto-Craft*).

## 2. Drop Rate Matrix & Pity System
- **Pity Counter:** Setiap 100 penetasan telur tanpa pet Legendary menjamin 1 pet Legendary.
- **Luck Multiplier Formula:** $\text{Effective Rate} = \text{Base Rate} \times (1 + \text{Luck Stat} + \text{GamePass Boost} + \text{Coven Buff})$.

## 3. Idempotent Monetization & Context-Aware Prompts
- **Idempotency:** `MonetizationService.luau` mencatat `PurchaseId` dalam cache memori untuk menjamin tidak ada duplikasi pemberian saldo jika server mengalami pemicuan berulang (*retry*).
- **Context Triggers:** Prompt pembelian hanya muncul berdasarkan konteks alami (seperti saat slot inventory penuh atau koin kurang).
