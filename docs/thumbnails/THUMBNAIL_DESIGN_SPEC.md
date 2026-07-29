# COBLOX Thumbnail Design System

## Format Specifications
- **Dimensions:** 150x150 pixels (Roblox standard)
- **Format:** PNG with transparency
- **Color Profile:** sRGB
- **Max File Size:** 1MB
- **Style:** Sci-fantasy alkimia, dark background, vibrant neon accents

## Color Palette
| Color | Hex | Usage |
|-------|-----|-------|
| Dark Background | `#0F172A` (Slate 900) | Main bg |
| Aura Gold | `#F59E0B` | Primary accent |
| Spark Cyan | `#06B6D4` | Secondary accent |
| Energy Purple | `#8B5CF6` | Premium/Epic |
| Success Green | `#22C55E` | Confirmed/Active |

## Product Thumbnail Requirements

### GamePasses (150x150)

| Product | Design Description | Elements |
|---------|-------------------|----------|
| **Fairytale Realm Pass** | Fantasy portal arch with twilight sky gradient | Portal arch silhouette, stars, purple-blue gradient, floating islands silhouette |
| **Celestial Wings Bundle** | Aether wings on dark background with sparkle particles | Wing outline in cyan-gold gradient, particle dots, glow effect |
| **Coven Guildmaster License** | Guild crest/shield with gold accents | Shield shape, crossed swords, crown, gold trim, dark bg |
| **VIP Sanctum Overlord** | Crown with neon purple glow (EXISTING - needs update) | Crown silhouette, purple glow, particle sparkles |
| **Super Luck** | Four-leaf clover with gold sparkles (EXISTING) | Clover in gold, sparkle dots, green glow |
| **+50 Inventory** | Backpack with +50 badge (EXISTING) | Backpack icon, "+50" badge, cyan accent |
| **Auto-Hatch** | Egg with play button (EXISTING) | Egg silhouette, play triangle, green glow |

### Developer Products (150x150)

| Product | Design Description | Elements |
|---------|-------------------|----------|
| **Fairy Dust Pack** | Sparkling dust particles with fairy silhouette | Glowing dots, fairy wing silhouette, purple-pink gradient |
| **Enchanted Elixir** | Glowing potion bottle | Potion bottle, liquid fill in cyan, bubble particles, glow |
| **Coins Small/Large** | Coin stack (EXISTING) | Gold coins stacked, "25"/"99" badge |
| **Gems Small/Large** | Diamond crystal (EXISTING) | Purple diamond, sparkle, "49"/"399" badge |
| **Aura Boost** | Lightning bolt (EXISTING) | Lightning in gold, energy ring |
| **Chrono Sparks** | Spark/star burst (EXISTING) | Star burst, cyan-blue gradient |
| **Rebirth Token** | Infinity symbol (EXISTING) | Infinity loop in purple-gold |

### Subscription (150x150)

| Product | Design Description | Elements |
|---------|-------------------|----------|
| **Monthly Alchemist** | Calendar badge with fox silhouette | Calendar page, small fox icon, "$4.99" text, gold border |

## Implementation Notes
- Use Roblox Creator Dashboard for final upload
- Badge icons can be uploaded via Open Cloud API:
  ```
  POST /legacy-publish/v1/badges/{badgeId}/icon
  ```
- GamePass/DevProduct images must be uploaded via Creator Dashboard directly
- Icons should use the `IconImageId` field in `MonetizationConfig.luau`
- Placeholder text should be "Coming Soon" in slate-gray until replaced
