> **[🏠 Master Index](MASTER_INDEX.md) | [⬅️ Back to Docs](README.md)**

# 📈 COBLOX LiveOps & Monetization Specification

## 1. Monetization Matrix
- **Developer Products & Passes:** Transaksi diproses via `MonetizationService.luau` & `ProcessReceipt` idempotency pattern di `StoreService.luau`.
- **Rewarded Video Ads & Immersive Ads:** Terintegrasi di `RewardedAdService.luau` untuk memberikan dorongan (*boost*) temporer kepada pemain.

## 2. Analytics & Telemetry
- **AnalyticsTrackerService:** Mencatat transaksi ekonomi (sink/source), gacha pull, milestone otomatisasi, dan penggunaan DataStore.
- **Badges System:** Dikelola oleh `BadgeService.luau` menggunakan ID resmi Roblox yang terdaftar di `GeneratedBadgeRegistry.luau`.
