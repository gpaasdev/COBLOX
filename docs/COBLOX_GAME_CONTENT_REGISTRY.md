> **[🏠 Master Index](MASTER_INDEX.md) | [⬅️ Back to Docs](README.md)**

# COBLOX — Game Content Registry (LGBOS v11.0)

> Daftar lengkap aset, item, produk, objek, dan seluruh isi game COBLOX: Multiverse Alchemy Sanctum.
> Dibuat dari sumber kode (`src/Shared/Config/`, `src/Shared/Configuration/`, `src/Assets/`, `Content/Data/`, `web/src/data/`) via Open Cloud API dan MCP Studio.

---

## Identitas Game

| Atribut | Nilai |
|---------|-------|
| Nama Game | COBLOX: Multiverse Alchemy Sanctum 🧪⚡ |
| Universe ID | `10545905192` |
| Place ID | `105075159736246` |
| Owner User ID | `11329819428` |
| Data Stores | `COBLOX_DataStore_LGBOS_v11`, `COBLOX_RegistrySnapshots`, `____PS` |
| Ordered Data Stores | `COBLOX_Leaderboard_Gems_v11`, `COBLOX_Leaderboard_Coins_v11` |
| Game Passes Database | `COBLOX_Covens_v1`, `CovenHideouts_v1` |

---

## 1. REALMS & ZONES

### Realms (2)

| ID | Nama | Place ID | Theme |
|----|------|----------|-------|
| MAIN | CyberAlchemist Realm | `105075159736246` | Sci-fantasy neon industrial |
| FAIRYTALE | Fairytale Fantasy Realm | `0` (TBD) | Enchanted nature/magic |

### Zones — CyberAlchemist Realm (4)

| ID | Nama | Required Rebirths | Cost (Coins) |
|----|------|-------------------|-------------|
| Zone_1_Lobby | Cyber Cyberia Lobby | 0 | 0 |
| Zone_2_Forest | Neon Forest Biome | 0 | 1,000 |
| Zone_3_Ocean | Abyssal Tech Ocean | 1 | 25,000 |
| Zone_4_Celestial | Celestial Void Peak | 3 | 500,000 |

### Zones — Fairytale Realm (6)

| ID | Nama |
|----|------|
| fairy_CentralHub | Fairytale Central Hub |
| fairy_EnchantedForest | Enchanted Forest |
| fairy_GlacialCavern | Glacial Cavern |
| fairy_VolcanicForge | Volcanic Forge |
| fairy_AetherSkyCitadel | Aether Sky Citadel |
| fairy_VoidCaves | Fairytale Void Caves |

### Portals (3)

| ID | From | To |
|----|------|----|
| Portal_Forest | Zone_1_Lobby | Zone_2_Forest |
| Portal_Ocean | Zone_2_Forest | Zone_3_Ocean |
| Portal_Celestial | Zone_3_Ocean | Zone_4_Celestial |

---

## 2. BIOMES (47)

### Core Biomes — 8 themes × 5 sectors + VoidCaves (41)

| Theme | Sectors | Biome Theme ID |
|-------|---------|----------------|
| Abyssal | 1–5 | `Biome_Abyssal_{1-5}` |
| Aether | 1–5 | `Biome_Aether_{1-5}` |
| Celestial | 1–5 | `Biome_Celestial_{1-5}` |
| Glacial | 1–5 | `Biome_Glacial_{1-5}` |
| Subterranean | 1–5 | `Biome_Subterranean_{1-5}` |
| Toxic | 1–5 | `Biome_Toxic_{1-5}` |
| Void | 1–5 | `Biome_Void_{1-5}` |
| Volcanic | 1–5 | `Biome_Volcanic_{1-5}` |
| VoidCaves | — | `VoidCaves` |

### Fairytale Biomes (6)

| File ID | Nama |
|---------|------|
| fairy_AetherSkyCitadel | Aether Sky Citadel |
| fairy_CentralHub | Fairytale Central Hub |
| fairy_EnchantedForest | Enchanted Forest |
| fairy_GlacialCavern | Glacial Cavern |
| fairy_VoidCaves | Void Caves |
| fairy_VolcanicForge | Volcanic Forge |

---

## 3. MATERIALS (112)

Disusun dalam 10 kategori material dengan sub-tahapan pemrosesan.

### Material Family Tree

Setiap material mengikuti siklus pemrosesan: **Ore → Refined → Alloy → Matrix → Crystal → Dust → Essence → Shard → Singularity → Vapor**

### Material Base — Bahan Dasar (6)

| ID | Nama | Density | Conductivity | Value |
|----|------|---------|-------------|-------|
| Iron | Iron | 7850.0 | 80.0 | 10 |
| AetherCrystal | Aether Crystal | 2100.0 | 10.0 | 250 |
| VoidBone | Void Bone | 1500.0 | 5.0 | 250 |
| FerriumAlloy | Ferrium Alloy | 8200.0 | 120.0 | 500 |
| FrostCrystal | Frost Crystal | 920.0 | 30.0 | 750 |
| EnchantedWood | Enchanted Wood | 450.0 | 55.0 | 280 |
| FairyDust | Fairy Dust | 2.0 | 200.0 | 1200 |
| VoidEssence | Void Essence | 1.0 | 250.0 | 3000 |

### Material Families (Full Processed Chains) — 104 materials

| Family | Ore → Refined → Alloy → Matrix → Crystal → Dust → Essence → Shard → Singularity → Vapor |
|--------|--------------------------------------------------------------------------------------|
| **Iron** | Value: 10 → 35 → 60 → 110 → 85 → 135 → 160 → 210 → 185 → 235 |
| **Copper** | Value: 260 → 285 → 310 → 360 → 335 → 385 → 410 → 460 → 435 → 485 |
| **Gold** | Value: 510 → 535 → 560 → 610 → 585 → 635 → 660 → 710 → 685 → 735 |
| **GoldVein** | Ore only — Value: 1500 |
| **Titanium** | Value: 760 → 785 → 810 → 860 → 835 → 885 → 910 → 960 → 935 → 985 |
| **Obsidian** | Value: 1510 → 1535 → 1560 → 1610 → 1585 → 1635 → 1660 → 1710 → 1685 → 1735 |
| **Mythril** | Value: 1760 → 1785 → 1810 → 1860 → 1835 → 1885 → 1910 → 1960 → 1935 → 1985 |
| **Adamantite** | Value: 2010 → 2035 → 2060 → 2110 → 2085 → 2135 → 2160 → 2210 → 2185 → 2235 |
| **Void** | Value: 1260 → 1285 → 1310 → 1360 → 1335 → 1385 → 1410 → 1460 → 1435 → 1485 |
| **Aether** | Value: 1010 → 1035 → 1060 → 1110 → 1085 → 1135 → 1160 → 1210 → 1185 → 1235 |
| **Quantum** | Value: 2260 → 2285 → 2310 → 2360 → 2335 → 2385 → 2410 → 2460 → 2435 → 2485 |

### Special Materials

| ID | Nama | Density | Conductivity | Value |
|----|------|---------|-------------|-------|
| AetherCrystal_Ore | Aether Crystal Ore | 850.0 | 95.0 | 450 |
| AetherCrystal_Shard | Aether Crystal Shard | 720.0 | 105.0 | 680 |
| MoonBloom_Petal | Moon Bloom Petal | 15.0 | 40.0 | 320 |

---

## 4. MACHINES (62)

### Main Machine Types (8) — Each has Mark 1 to Mark 10 (tiered progression)

| Type | DisplayName | Power | Heat | MaxHeat | Durability | Base Prod | Max Tier |
|------|------------|-------|------|---------|------------|-----------|----------|
| Smelter | Arcane Smelter | 15 | 20 | 1200 | 800 | 1.5 | 10 |
| Refinery | Alchemical Refinery | 20 | 25 | 1500 | 900 | 1.8 | 10 |
| Synthesizer | Arcane Synthesizer | 25 | 30 | 1800 | 700 | 2.0 | 10 |
| Reactor | Alchemical Reactor | 10 | 5 | 500 | 1000 | 1.0 | 10 |
| Turbine | Mana Turbine | 5 | 10 | 300 | 600 | 0.5 | 10 |
| Cooler | Cryo Cooler | 5 | 0 | 100 | 500 | 0.0 | 10 |
| Furnace | Mana Furnace | 8 | 15 | 900 | 600 | 0.8 | 5 |
| Crucible | Void Crucible | 25 | 30 | 2000 | 1500 | 2.0 | 5 |

### Tiers per Machine (Mark 1 → 10)
Semua mesin mengikuti skala: PowerConsumption = Mark × 100 (kecuali Furnace/Crucible caps di Mark 5).
MaxTemperature = Mark × 250 + 500 (dari 750 di Mark 1 hingga 3000 di Mark 10).

### Special Machines (2)

| ID | Nama | Power | MaxTemp |
|----|------|-------|---------|
| FusionReactor_v1 | Basic Fusion Reactor | 500 | 3000 |
| CryoCooler_v1 | Cryogenic Cooling Chamber | 1200 | 500 |

### Machine Costs (Base)

| Type | Coins | Gems |
|------|-------|------|
| Smelter | 8,000 | 50 |
| Refinery | 12,000 | 75 |
| Synthesizer | 15,000 | 100 |
| Reactor | 5,000 | 25 |
| Turbine | 3,000 | 10 |
| Cooler | 2,000 | 5 |
| Furnace | 3,000 | 10 |
| Crucible | 15,000 | 100 |

### Machine IDs (62 total)

`Smelter_v1` s.d. `Smelter_v10`, `Refinery_v1` s.d. `Refinery_v10`, `Synthesizer_v1` s.d. `Synthesizer_v10`,
`Reactor_v1` s.d. `Reactor_v10`, `Turbine_v1` s.d. `Turbine_v10`, `Cooler_v1` s.d. `Cooler_v10`,
`Furnace_v1`–`Furnace_v5`, `Crucible_v1`–`Crucible_v5`, `FusionReactor_v1`, `CryoCooler_v1`.

---

## 5. SPIRITS / PETS (55)

### Core Spirit Registry (40) — dari Content/Data/Spirits/

| ID | Nama | Rarity | Element | DropRate |
|----|------|--------|---------|----------|
| SP_ABYSSAL_KRAKEN | Abyssal Kraken | Epic | Water | 1.5% |
| SP_AETHER_WRAITH | Aether Wraith | Epic | Void | 2.0% |
| SP_ASH_PUFF | Ash Puff | Common | Fire | 7.0% |
| SP_BRONZE_DRAKE | Bronze Drake | Uncommon | Fire | 7.0% |
| SP_CELESTIAL_SERAPH | Celestial Seraph | Epic | Aether | 2.0% |
| SP_CLAY_PUP | Clay Pup | Common | Earth | 10.0% |
| SP_COAL_SPRITE | Coal Sprite | Common | Fire | 10.0% |
| SP_COPPER_WISP | Copper Wisp | Common | Lightning | 12.0% |
| SP_CRYSTAL_BEAR | Crystal Bear | Rare | Ice | 3.0% |
| SP_CRYSTAL_GOLEM | Crystal Golem | Rare | Earth | 3.0% |
| SP_ENCHANTED_DEER | Enchanted Deer | Rare | Nature | 4.0% |
| SP_ETHER_DRAKE | Ether Drake | Legendary | Aether | 0.3% |
| SP_FAIRY_FOX | Fairy Fox | Uncommon | Aether | 8.0% |
| SP_FLAME_CAT | Flame Cat | Uncommon | Fire | 5.0% |
| SP_FROST_PHOENIX | Frost Phoenix | Epic | Ice | 1.5% |
| SP_GLOW_MUSH | Glow Mush | Uncommon | Nature | 5.0% |
| SP_ICE_CUBE | Ice Cube | Uncommon | Water | 5.0% |
| SP_IRON_IMP | Iron Imp | Common | Earth | 15.0% |
| SP_LEAF_BUG | Leaf Bug | Common | Nature | 7.0% |
| SP_MAGMA_DRAGON | Magma Dragon | Epic | Fire | 1.5% |
| SP_MAGMA_SLIME | Magma Slime | Uncommon | Fire | 5.0% |
| SP_MOON_WISP | Moon Wisp | Uncommon | Nature | 7.0% |
| SP_MYTHRIL_SERPENT | Mythril Serpent | Epic | Aether | 3.0% |
| SP_OBSIDIAN_PHOENIX | Obsidian Phoenix | Rare | Fire | 5.0% |
| SP_PIXIE_SWARM | Pixie Swarm | Common | Wind | 15.0% |
| SP_QUANTUM_HYDRA | Quantum Hydra | Legendary | Quantum | 1.9% |
| SP_SAND_GOLEM | Sand Golem | Uncommon | Earth | 5.0% |
| SP_SHADOW_FOX | Shadow Fox | Rare | Dark | 3.0% |
| SP_SILVER_SYLPH | Silver Sylph | Uncommon | Wind | 8.0% |
| SP_SOLAR_DRAGON | Solar Dragon | Epic | Fire | 1.5% |
| SP_SPARK_BUG | Spark Bug | Common | Lightning | 7.0% |
| SP_STONE_GOBLIN | Stone Goblin | Common | Earth | 8.0% |
| SP_STORM_ELEMENTAL | Storm Elemental | Rare | Lightning | 2.0% |
| SP_SUN_LION | Sun Lion | Rare | Light | 3.0% |
| SP_THUNDER_BIRD | Thunder Bird | Uncommon | Lightning | 5.0% |
| SP_TITANIUM_WYVERN | Titanium Wyvern | Rare | Metal | 4.0% |
| SP_VOID_DRAGON | Void Dragon | Legendary | Void | 0.1% |
| SP_VOID_SHADE | Void Shade | Legendary | Void | 0.5% |
| SP_WATER_DRIP | Water Drip | Common | Water | 8.0% |
| SP_WIND_FLYER | Wind Flyer | Common | Wind | 8.0% |

### Fairytale Spirits (10)

| ID | Nama | Rarity | Element | DropRate |
|----|------|--------|---------|----------|
| SP_CELESTIAL_SERAPH | Celestial Seraph | Epic | Aether | 2.0% |
| SP_CRYSTAL_GOLEM | Crystal Golem | Rare | Earth | 3.0% |
| SP_ENCHANTED_DEER | Enchanted Deer | Rare | Nature | 4.0% |
| SP_ETHER_DRAKE | Ether Drake | Legendary | Aether | 0.3% |
| SP_FAIRY_FOX | Fairy Fox | Uncommon | Aether | 8.0% |
| SP_FROST_PHOENIX | Frost Phoenix | Epic | Ice | 1.5% |
| SP_MAGMA_DRAGON | Magma Dragon | Epic | Fire | 1.5% |
| SP_MOON_WISP | Moon Wisp | Uncommon | Nature | 7.0% |
| SP_PIXIE_SWARM | Pixie Swarm | Common | Wind | 15.0% |
| SP_VOID_SHADE | Void Shade | Legendary | Void | 0.5% |

### Pet Companions (15) — dari PetData.luau

| ID | Nama | Rarity | Multiplier | ModelAssetId |
|----|------|--------|------------|-------------|
| Pet_Common_Cat | Aura Whisper Cat | Common | 1.2× | 6820845348 |
| Pet_Uncommon_Dog | Sparks Hound | Uncommon | 1.5× | 1 (fallback) |
| WaterBender_Spirit | Mizuchi Water Spirit | Rare | 2.5× | 1 (fallback) |
| Pet_Rare_Bear | Grizzly Quantum Bear | Rare | 2.8× | 1 (fallback) |
| Pet_Rare_Fox | Mystic Spirit Fox | Rare | 2.4× | 6820845349 |
| Pet_Epic_Unicorn | Starlight Chakra Unicorn | Epic | 3.5× | 1 (fallback) |
| Pet_Epic_Pegasus | Astral Pegasus | Epic | 4.2× | 1 (fallback) |
| Pet_Legendary_Dragon | Thunder God Dragon | Legendary | 7.0× | 6820845347 |
| Pet_Legendary_Kraken | Abyssal Leviathan Kraken | Legendary | 8.5× | 1 (fallback) |
| Pet_Mythic_Phoenix | Solar Eclipse Phoenix | Mythic | 15.0× | 1 (fallback) |
| Pet_Mythic_Hydra | Void Hydra Lord | Mythic | 18.0× | 1 (fallback) |
| Pet_Secret_ChronoTitan | Chrono Void Titan | Secret | 100.0× | 1 (fallback) |
| Pet_Secret_CelestialVoid | Celestial Void Sovereign | Secret | 75.0× | 1 (fallback) |
| NineTailed_Fox | Kitsune Chakra Lord | Secret | 50.0× | 6820845349 |
| Pet_GodTier_VIP | Omniscient Golden Seraph | GodTier | 250.0× | 1 (fallback) [VIP Exclusive] |

---

## 6. RECIPES (45 + 3 hand-authored = 48)

### Generated Recipe Registry (45)

| ID | Nama | Tipe Output |
|----|------|------------|
| ABYSSAL_PASS | Abyssal Realm Pass | Key |
| ADAMANTITE_ALLOY | Adamantite Alloy | Material |
| ADAMANTITE_REFINED | Adamantite Refined | Material |
| AETHER_CRYSTAL | Aether Crystal | Material |
| AETHER_ESSENCE | Aether Essence | Material |
| AETHER_MATRIX | Aether Matrix | Material |
| AETHER_SINGULARITY | Aether Singularity | Material |
| AURA_POTION_MAJOR | Major Aura Potion | Consumable |
| AURA_POTION_MINOR | Minor Aura Potion | Consumable |
| CELESTIAL_KEYSTONE | Celestial Keystone | Key |
| COPPER_ALLOY | Copper Alloy | Material |
| COPPER_SHARD | Copper Shard | Material |
| CRYO_REAGENT | Cryo Reagent | Consumable |
| FERRIUM_ALLOY | Ferrium Alloy | Material |
| FUSION_CORE_EPIC | Epic Fusion Core | FusionCore |
| FUSION_CORE_LEGENDARY | Legendary Fusion Core | FusionCore |
| FUSION_CORE_RARE | Rare Fusion Core | FusionCore |
| FUSION_CORE_UNCOMMON | Uncommon Fusion Core | FusionCore |
| GOLD_ALLOY | Gold Alloy | Material |
| GUILD_BANNER | Guild Banner | Decoration |
| GUILD_STRONGBOX | Guild Strongbox | Currency |
| IRON_REFINED | Iron Refined | Material |
| MYTHRIL_REFINED | Mythril Refined | Material |
| MYTHRIL_SHARD | Mythril Shard | Material |
| OBSIDIAN_CRYSTAL | Obsidian Crystal | Material |
| PURIFICATION_CRYSTAL | Purification Crystal | Consumable |
| QUANTUM_ESSENCE | Quantum Essence | Material |
| REACTOR_CORE | Reactor Core | Machine |
| REBIRTH_CATALYST | Rebirth Catalyst | Catalyst |
| SANCTUM_TOKEN | Sanctum Token | Currency |
| SHADOW_RAID_TOKEN | Shadow Raid Token | RaidToken |
| SMELTER_UPGRADE | Smelter Upgrade | Machine |
| SPIRIT_CATALYST_EARTH | Spirit Catalyst (Earth) | Catalyst |
| SPIRIT_CATALYST_FIRE | Spirit Catalyst (Fire) | Catalyst |
| SPIRIT_CATALYST_LIGHTNING | Spirit Catalyst (Lightning) | Catalyst |
| SPIRIT_CATALYST_VOID | Spirit Catalyst (Void) | Catalyst |
| SPIRIT_CATALYST_WATER | Spirit Catalyst (Water) | Catalyst |
| SYNTHESIZER_CORE | Synthesizer Core | Machine |
| TURBINE_BLADE | Turbine Blade | Machine |
| VOID_CRYSTAL_COMPOUND | Void Crystal Compound | Material |
| fairy_AETHER_CRYSTAL_FUSION | Aether Crystal Fusion | Material |
| fairy_CELESTIAL_KEYSTONE | Celestial Keystone (Fairytale) | Key |
| fairy_ENCHANTED_ELIXIR | Enchanted Elixir | Consumable |
| fairy_FAIRY_WING_POTION | Fairy Wing Potion | Consumable |
| fairy_VOID_FORGING | Void Forging | Material |

### Hand-Authored Recipes (3) — dari RecipeConfig.luau

| Nama | Ingredients | Hasil | Rarity |
|------|------------|-------|--------|
| Basic Aura Potion | Aether Crystal + Mana Dew | Potion | Common |
| Ferrium Alloy | Iron + Coal + Flux | Ferrium Alloy | Uncommon |
| Void Crystal | Aether Crystal + Void Essence | Void Crystal | Rare |

### Alchemical Reaction (1) — dari ReactionRegistry

| ID | Required Temp | Pressure | Product | Yield |
|----|-------------|----------|---------|-------|
| ALCHEMICAL_REACTION | 1000°C – 2000°C | 5.0 atm | Aether Crystal | 1.2× |

---

## 7. RESEARCH NODES (152)

### Categories (6 utama + 2 spesial)

| Kategori | Jumlah Node |
|----------|-------------|
| Tech_Automation | 30 node |
| Tech_Engineering | 30 node |
| Tech_QuantumPhysics | 30 node |
| Tech_Thermodynamics | 30 node |
| Tech_VoidScience | 30 node |
| Tech_BasicFusion | 1 node (spesial) |
| Tech_CryoCooling | 1 node (spesial) |

Total: **152 research nodes** dari `Content/Data/Research/`.

### Hand-Authored Research (2) — dari ResearchRegistry.luau

| ID | Nama | Required Discoveries | Cost | Unlocks |
|----|------|---------------------|------|---------|
| Tech_BasicFusion | Basic Fusion Tech | 5 | 10,000 Coins | FusionReactor recipe |
| Tech_CryoCooling | Cryogenic Cooling | 3 | 7,500 Coins | CryoCooler recipe |

---

## 8. CREATURES (91)

### Core Creature Types (8) × 10 Levels + Boss = 81

| Type | Level Range | File Pattern |
|------|------------|--------------|
| Abomination | 1–10 | `Creature_Abomination_Lvl{1-10}` |
| Beast | 1–10 | `Creature_Beast_Lvl{1-10}` |
| Construct | 1–10 | `Creature_Construct_Lvl{1-10}` |
| Dragon | 1–10 | `Creature_Dragon_Lvl{1-10}` |
| Golem | 1–10 | `Creature_Golem_Lvl{1-10}` |
| Guardian | 1–10 | `Creature_Guardian_Lvl{1-10}` |
| Parasite | 1–10 | `Creature_Parasite_Lvl{1-10}` |
| Wisp | 1–10 | `Creature_Wisp_Lvl{1-10}` |

### Fairytale Creatures

| File | Type |
|------|------|
| fairy_TypeVariant | Variant fairytale dari tipe core + VoidBeast |

### Void Beast Boss

| File | Type |
|------|------|
| VoidBeast | Boss creature — entry paling sulit |

---

## 9. BADGES (15)

| ID | Nama | Description | Rarity |
|----|------|-------------|--------|
| BDG_BIOME_WALKER | Biome Walker | Visit 5 different biomes | 40.0% |
| BDG_COVEN_FOUNDER | Coven Founder | Create or join a Coven | 20.0% |
| BDG_DAILY_STREAK | Dedicated Alchemist | Complete daily quests 7 days in a row | 15.0% |
| BDG_FIRST_CRAFT | First Synthesis | Complete your first alchemical synthesis | 85.0% |
| BDG_LEGENDARY_HATCH | Legend Caller | Hatch a Legendary Spirit | 0.5% |
| BDG_MASTER_SMITH | Forge Lord | Upgrade a Machine to Mark 10 | 3.0% |
| BDG_MONSTER_SLAYER | Creature Conqueror | Defeat 100 hostile creatures | 25.0% |
| BDG_MULTIVERSE_TRAVELER | Multiverse Explorer | Enter Sector 5 of any Biome | 1.0% |
| BDG_PIONEER | Alchemist Pioneer | First 10,000 players to synthesize Tier 3 material | 1.2% |
| BDG_QUANTUM_MASTER | Quantum Master | Synthesize a Quantum Essence | 2.0% |
| BDG_RESEARCHER | Grand Scholar | Unlock 50 research nodes | 8.0% |
| BDG_SANCTUM_BUILDER | Sanctum Builder | Place 10 structures in your Sanctum | 30.0% |
| BDG_SHADOW_VETERAN | Shadow Veteran | Complete 10 Shadow Raids | 10.0% |
| BDG_SOUL_BONDER | Soul Bonder | Hatch your first Spirit companion | 60.0% |
| BDG_VETERAN | Seasoned Veteran | Reach 100 hours of total playtime | 5.0% |

---

## 10. MARKET PRODUCTS (2 generated + 8 monetization = 10 total)

### Generated Market (Gamepasses via Registry)

| ID | Nama | Harga | Mata Uang |
|----|------|-------|-----------|
| MKT_FAIRYTALE_PASS | Fairytale Realm Pass | 299 | Robux |
| MKT_VIP_PASS | Sanctum VIP Pass | 500 | Robux |

### Game Passes (4 + 3 pending) — dari MonetizationConfig

| ID | Nama | PriceRobux | Icon ID | Perks |
|----|------|-----------|---------|-------|
| VIP_Pass | ⭐ VIP Sanctum Overlord Pass | 499 | 13837943485 | Pet God-Tier, +50% Aura, VIP Pod Area, Golden Chat Tag |
| SuperLuck | 🍀 Super Alchemical Luck | 399 | 13837943486 | +100% Hatch Luck, Glow Particle Effect |
| Plus50Slots | 🎒 +50 Extra Inventory Slots | 199 | 13837943487 | +50 Max Inventory Slots |
| AutoHatch | ⚡ Quantum Auto-Hatch | 299 | 13837943488 | Continuous Auto Hatching |
| CYBER_NEON_TRAIL | Cyber Neon Trail | TBD | TBD | (pending Creator Dashboard creation) |
| FAIRYTALE_REALM_PASS | Fairytale Realm Pass | 299 | TBD | (pending) |
| CELESTIAL_WINGS_BUNDLE | Celestial Wings Bundle | 499 | TBD | (pending) |
| COVEN_GUILDMASTER | Coven Guildmaster | 999 | TBD | (pending) |

### Developer Products (4 + 2 pending)

| ID | Nama | PriceRobux | GrantAmount | Currency |
|----|------|-----------|-------------|----------|
| Gems_Small | 💎 Small Gems Sack | 49 | 100 | Gems |
| Gems_Large | 💎 Chest of Quantum Gems | 399 | 1000 | Gems |
| Coins_Small | 💰 Pouch of Mana Coins | 29 | 5000 | Coins |
| Coins_Large | 💰 Vault of Mana Coins | 249 | 50000 | Coins |
| FAIRY_DUST_PACK | Fairy Dust Pack | 99 | 500 | Fairy Dust (pending) |
| ENCHANTED_ELIXIR | Enchanted Elixir | 79 | 1 | (pending) |

### Additional Dev Products (from EconomyConfig)

| ID | Nama | Product ID |
|----|------|-----------|
| AURA_BOOST_MEDIUM | Aura Boost (Medium) | 3612013293 |
| CHRONO_SPARKS_PACK | Chrono Sparks Pack | 3612013298 |
| INSTANT_EGG_HATCH | Instant Egg Hatch | 3612013299 |
| REBIRTH_SKIP_TOKEN | Rebirth Skip Token | 3612013301 |

### Subscription

| Tier | Price | Benefits |
|------|-------|----------|
| Monthly Alchemist | $4.99/mo | 500 Gems/hari, +20% EXP, Spirit Fox, Golden Name Tag, Early Access |

---

## 11. WEAPONS (5 Tiers)

| ID | Nama | Tier | Damage | Range | Speed | CoinCost | RobuxCost | Level | Mesh ID |
|----|------|------|--------|-------|-------|----------|-----------|-------|---------|
| Fist | Fist | 1 | 10 | 8 | 0.4s | 0 | 0 | 0 | — |
| IronSword | Iron Sword | 2 | 25 | 14 | 0.45s | 5,000 | 0 | 2 | 47433 |
| FlameSaber | Flame Saber | 3 | 45 | 16 | 0.4s | 25,000 | 79 | 5 | 10288498712 |
| AetherBlade | Aether Blade | 4 | 75 | 18 | 0.35s | 100,000 | 199 | 10 | 15283548889 |
| VoidGreatsword | Void Greatsword | 5 | 120 | 22 | 0.5s | 500,000 | 499 | 20 | 6763151912 |

---

## 12. AVATAR ITEMS (11)

### Hats & Helmets (2)

| ID | Nama | AssetId | Currency | Price | VIP? | Buffs |
|----|------|---------|----------|-------|------|-------|
| Hat_GrandAlchemistCrown | Crown of the Grand Alchemist | 13837943485 | Gems | 250 | Yes | Aura 1.5×, Speed +4 |
| Hat_PyroGoggles | Pyro-Alchemical Goggles | 13837943487 | Coins | 1,200 | No | Speed +2 |

### Wings (2)

| ID | Nama | AssetId | Currency | Price | VIP? | Buffs |
|----|------|---------|----------|-------|------|-------|
| Wing_ChronoVoidWings | Chrono-Void Plasma Wings | 13837943488 | Robux | 150 | No | Speed +8, Aura 1.25× |
| Wing_AstralCrystalWings | Astral Cyan Crystal Wings | 13837943489 | Gems | 180 | No | Aura 1.2× |

### Auras & Trails (2)

| ID | Nama | AssetId | Currency | Price | VIP? | Buffs |
|----|------|---------|----------|-------|------|-------|
| Aura_OmniverseGodPulse | Omniverse God-Tier Aura | 13837943490 | Gems | 500 | Yes | Aura 2.0×, Pity +0.1 |
| Aura_MizuchiWaterFlow | Mizuchi Hydro Swirl | 13837943491 | Coins | 8,500 | No | Speed +3 |

### Outfits & Robes (2)

| ID | Nama | AssetId | Currency | Price | VIP? | Buffs |
|----|------|---------|----------|-------|------|-------|
| Outfit_CyberAlchemistRobes | Quantum Weave Cyber Robes | 13837943492 | Coins | 3,000 | No | Aura 1.1× |
| Outfit_VIPGodOverlordArmor | VIP Overlord Light Armor | 13837943493 | Gems | 300 | Yes | Aura 1.8×, Speed +6 |

### Back Accessories (1)

| ID | Nama | AssetId | Currency | Price | VIP? | Buffs |
|----|------|---------|----------|-------|------|-------|
| Back_QuantumAlchemicalVessel | Quantum Mana Extraction Vessel | 13837943494 | Coins | 4,500 | No | Aura 1.15× |

---

## 13. BUILDING BLOCKS (8)

### Block Palette

| ID | Nama | Material | Warna | Cost | Tier |
|----|------|----------|-------|------|------|
| Stone | Stone Block | Slate | RGB(120,120,120) | 10 Coins | 1 |
| Marble | Marble Block | Marble | RGB(230,230,240) | 25 Coins | 1 |
| Glass | Glass Block | Glass | RGB(180,210,255) | 50 Coins | 2 |
| NeonBlue | Neon Blue Block | Neon | RGB(56,189,248) | 5 Gems | 2 |
| NeonPurple | Neon Purple Block | Neon | RGB(168,85,247) | 10 Gems | 3 |
| Crystal | Crystal Block | Glass | RGB(255,255,255) | 25 Gems + 100 Coins | 3 |
| Gold | Gold Block | Metal | RGB(255,215,0) | 50 Gems | 4 |
| Void | Void Obsidian | SmoothPlastic | RGB(15,15,25) | 100 Gems | 4 |

### Grid Settings
- SnapSize: 4 studs
- Max Build Height: 20
- Max Blocks/Player: 500
- Block Size: 4×4×4 studs

---

## 14. GRID STRUCTURES (6)

| ID | Nama | Cost | Deskripsi | Size |
|----|------|------|-----------|------|
| DropperBasic | Basic Dropper | 500 | Produces Aura Energy crystals | 3×3×3 |
| ObeliskBasic | Basic Obelisk | 1,000 | Converts Aura Energy to Coins (1:1) | 3×6×3 |
| LabRacik | Lab Racik | 2,000 | Craft potions and alchemical items | 6×4×6 |
| GenesisPodStation | Genesis Pod Station | 3,000 | Hatch Spirit Pets from Genesis Pods | 6×3×6 |
| CrystalNode | Crystal Node | 800 | Auto-minable resource node (30s respawn) | 3×3×3 |
| BejanaMarkas | Bejana Markas | 1,500 | Storage vessel for Aura Energy (100K cap) | 3×4×3 |

### Grid Rules
- Cell Size: 3 studs
- Default Plot: 10×10 grid (30×30 studs)
- Max Structures/Plot: 100
- Max Placement Distance: 15 studs

---

## 15. TYCOON NODES (8)

| ID | Nama | Cost | Income/Speed |
|----|------|------|-------------|
| Dropper_Tier1 | Basic Mineral Synthesizer | 0 | 10 income/2.0s |
| Collector_Tier1 | Standard Energy Collector | 50 | 1.0× multiplier |
| Dropper_Tier2 | Plasma Core Generator | 250 | 45 income/1.5s |
| Conveyor_Speed1 | Magnetic Rail Conveyor | 500 | 1.5× speed |
| Dropper_Tier3 | Quantum Flux Excavator | 1,500 | 180 income/1.0s |
| Upgrader_Tier1 | Particle Multiplier Gate | 5,000 | 2.0× multiplier |
| Dropper_Tier4 | Dark Matter Harvester | 25,000 | 1,200 income/0.8s |
| Collector_Tier2 | Hyper-Drive Matrix Collector | 100,000 | 3.5× multiplier |

### Plots (6)
Alpha, Beta, Gamma, Delta, Epsilon, Zeta

---

## 16. EGGS & HATCHING (4 egg types + 3 pod types)

### Egg Types

| ID | Nama | Cost | Hatch Time | Pool |
|----|------|------|-----------|------|
| Egg_Basic | Starter Common Egg | 50 Coins | 1.0s | Common Cat (50%), Uncommon Dog (30%), Rare Fox (14%), Epic Unicorn (5%), Legendary Dragon (1%) |
| Egg_Forest | Deep Forest Egg | 500 Coins | 1.5s | Uncommon Dog (40%), Rare Fox (30%), Rare Bear (20%), Epic Pegasus (8%), Legendary Dragon (2%) |
| Egg_Ocean | Abyssal Ocean Egg | 5,000 Coins | 2.0s | Rare Bear (45%), Epic Unicorn (30%), Epic Pegasus (18%), Legendary Kraken (6%), Mythic Hydra (1%) |
| Egg_Celestial | Celestial Mythic Egg | 50,000 Coins + 100 Gems | 3.0s | Epic Pegasus (50%), Legendary Dragon (30%), Legendary Kraken (14%), Mythic Phoenix (5%), Secret CelestialVoid (0.9%), Secret ChronoTitan (0.1%) |

### Genesis Pod Types

| ID | Nama | Cost | Currency |
|----|------|------|----------|
| Basic | Basic Genesis Pod | 500 | Coins |
| Advanced | Advanced Genesis Pod | 2,000 | Coins |
| Mystic | Mystic Genesis Pod | 50 | ChronoSparks |

### Base Hatch Rates

| Rarity | Base Rate |
|--------|-----------|
| Common | 60% |
| Uncommon | 25% |
| Rare | 10% |
| Legendary | 4% |
| Mythic | 1% |

### Pity System
- Threshold: 100 hatches
- Guarantee: Legendary
- Luck stat: +2% per upgrade (max 10 upgrades)
- GamePass Super Luck: +25%
- Max effective rate: 95%
- Cooldown: 3s between hatches

---

## 17. QUESTS (5 Main + 2 Seasonal + 2 NPCs)

### Main Story Quests

| ID | Title | Description | Reward | Next |
|----|-------|-------------|--------|------|
| Quest_001_FirstDrop | First Extraction | Collect income from initial Tycoon Synthesizer | 250 Coins, 5 Gems | Quest_002 |
| Quest_002_FirstUpgrade | Factory Expansion | Purchase first Tycoon upgrade | 1,000 Coins, 10 Gems | Quest_003 |
| Quest_003_FirstHatch | Companion Companion | Hatch first pet from Starter Egg | 2,500 Coins, 25 Gems | Quest_004 |
| Quest_004_ForestTravel | Into the Neon Forest | Unlock Zone 2 (Neon Forest) | 10,000 Coins, 50 Gems | Quest_005 |
| Quest_005_RebirthPioneer | Quantum Rebirth | Perform first Rebirth | 50,000 Coins, 200 Gems | nil |

### Seasonal Quests (dari QuestRegistry)

| ID | Title |
|----|-------|
| SQ_CRYSTAL_HARVESTER | Crystal Harvester |
| SQ_SPIRIT_BREEDER | Spirit Breeder |

### NPCs

| ID | Nama | Zone |
|----|------|------|
| NPC_Guide_Cyber | Cyber Cyberia Overseer | Zone_1_Lobby |
| NPC_Merchant_Forest | Forest Relic Trader | Zone_2_Forest |

---

## 18. RESOURCE NODES & TOOLS

### Tools (3)

| ID | Nama | Type | Tier | Speed | Yield |
|----|------|------|------|-------|-------|
| StarterSickle | Novice Herbal Sickle | Sickle | 1 | 1.0s | 1.0× |
| StarterPickaxe | Rusty Mining Pick | Pickaxe | 1 | 1.2s | 1.0× |
| VoidBreakerPickaxe | Void-Breaker Titanium Pick | Pickaxe | 3 | 0.6s | 2.5× |

### Resource Nodes (3)

| ID | Nama | Type | MaxHP | Respawn | Tool Req | Loot Table |
|----|------|------|-------|---------|----------|------------|
| luminous_bush | Luminous Herb Bush | Herb | 1 | 10s | None | Luminous Herb (100%, 1-3), Aura Dew (25%, 1) |
| void_ore_node | Void Ore Deposit | Ore | 3 | 20s | Pickaxe T1 | Void Dust (100%, 2-4), Quantum Shard (15%, 1) |
| celestial_crystal_boss | Celestial Void Crystal (Boss) | Boss | 10 | 120s | Pickaxe T3 | Celestial Void Essence (100%, 1-2), Dragon Scale (50%, 1-2) |

### Spawn Zones (2)

| ID | Node | Max Nodes | Bounds |
|----|------|-----------|--------|
| Forest_Herb_Zone | luminous_bush | 15 | (-100,0,-100) → (100,0,100) |
| Void_Mines_Zone | void_ore_node | 8 | (200,0,200) → (400,0,400) |

---

## 19. SANCTUM / COVEN SYSTEM

### Economy
| Parameter | Value |
|-----------|-------|
| BASE_STARTER_AURA | 250 |
| BASE_STARTER_SPARKS | 25 |
| BASE_STARTER_COINS | 250 |
| BASE_STARTER_GEMS | 25 |
| VAULT_DAILY_INTEREST_RATE | 5% |
| COZY_RATING_LUCK_BOOST | 2% |
| REBIRTH_BASE_COST | 5,000 Coins |
| REBIRTH_COST_MULTIPLIER | 2.2× |
| REBIRTH_TOKEN_REWARD | 1 |
| MAX_BASE_EQUIP_SLOTS | 4 |
| MAX_BASE_INVENTORY_SLOTS | 75 (base, +50 via GamePass) |

### Coven Config
| Parameter | Value |
|-----------|-------|
| Creation Cost | 10,000 Coins |
| Max Members | 20 |
| Roles | Leader, Officer, Member |
| Treasury | Shared vault for guild upgrades |
| Hideout | Dedicated instanced place |

---

## 20. LIVE OPS

### Active Event
| Event | Status | Luck Boost | Coin Boost |
|-------|--------|-----------|------------|
| Weekend_2x_Luck | ✅ Active | 2.0× | 1.5× |

### Season Pass — Cyber Genesis Season 1
| Tier | XP Required | Reward |
|------|-------------|--------|
| 1 | 100 | 5,000 Coins |
| 2 | 250 | 50 Gems |
| 3 | 500 | Egg_Forest |
| 5 | 1,200 | Pet_Epic_Pegasus |
| 10 | 3,000 | Pet_Mythic_Phoenix |
| 20 | 10,000 | Pet_Secret_CelestialVoid |

### Daily Rewards (7-day cycle)
| Day | Rewards |
|-----|---------|
| 1 | 1,000 Coins + 5 Gems |
| 2 | 2,500 Coins + 10 Gems |
| 3 | 5,000 Coins + 20 Gems |
| 4 | 10,000 Coins + 35 Gems |
| 5 | Egg_Forest |
| 6 | 25,000 Coins + 75 Gems |
| 7 | Pet_Legendary_Dragon + 150 Gems |

---

## 21. 3D ASSETS — Model Manifest

### Nature Models
| Key | Asset ID | License |
|-----|----------|---------|
| StylizedTree_Emerald | `rbxassetid://1290033` | CC0 |
| StylizedTree_Sakura | `rbxassetid://1033714` | CC0 |
| RockCluster | `rbxassetid://1082499` | CC0 |
| FloatingIslandCore | `rbxassetid://4612462` | CC0 |
| ManaCrystalLarge | `rbxassetid://4943805` | CC0 |

### Tycoon Models
| Key | Asset ID |
|-----|----------|
| Dropper_Tier1 | `rbxassetid://11442510` |
| Dropper_Tier2 | `rbxassetid://11442511` |
| Dropper_Tier3 | `rbxassetid://11442512` |
| Dropper_Tier4 | `rbxassetid://11442513` |
| Collector_Tier1 | `rbxassetid://11442520` |
| Collector_Tier2 | `rbxassetid://11442521` |
| Upgrader_Tier1 | `rbxassetid://11442530` |
| Conveyor_Speed1 | `rbxassetid://11442540` |

### Mount Models
| Key | Asset ID | License |
|-----|----------|---------|
| NeonCrocodile | `rbxassetid://18863207` | CC0 |
| CosmicDragon | `rbxassetid://6820845347` | CC0 |

### Egg Models
| Key | Asset ID |
|-----|----------|
| Egg_Basic | `rbxassetid://7405468140` |
| Egg_Forest | `rbxassetid://7405468141` |
| Egg_Ocean | `rbxassetid://7405468142` |
| Egg_Celestial | `rbxassetid://7405468143` |

### Weapon Meshes
| Key | Asset ID |
|-----|----------|
| IronSword | `rbxassetid://47433` |
| FlameSaber | `rbxassetid://10288498712` |
| AetherBlade | `rbxassetid://15283548889` |
| VoidGreatsword | `rbxassetid://6763151912` |

### Fairytale Environment (Status: PROCESSING)
| Key | Asset ID |
|-----|----------|
| SkyboxTwilight | `rbxassetid://PROCESSING` |
| FloatingIslandLarge | `rbxassetid://PROCESSING` |
| EnchantedTree | `rbxassetid://PROCESSING` |
| BioluminescentMushroom | `rbxassetid://PROCESSING` |
| CrystalNodeAether | `rbxassetid://PROCESSING` |
| AncientPortalArch | `rbxassetid://PROCESSING` |

### Fairytale Items (Status: PROCESSING)
| Key | Asset ID |
|-----|----------|
| GenesisPodCommon | `rbxassetid://PROCESSING` |
| GenesisPodLegendary | `rbxassetid://PROCESSING` |
| AetherCrystalMesh | `rbxassetid://PROCESSING` |
| ManaBloom | `rbxassetid://PROCESSING` |

### Fairytale Entities (Status: PROCESSING)
| Key | Asset ID |
|-----|----------|
| SpiritFoxMesh | `rbxassetid://PROCESSING` |
| CrystalGolemMesh | `rbxassetid://PROCESSING` |
| PixieSwarm | `rbxassetid://PROCESSING` |
| FairyDragon | `rbxassetid://PROCESSING` |

### Fairytale Cosmetics (Status: PROCESSING)
| Key | Asset ID |
|-----|----------|
| WingsAether | `rbxassetid://PROCESSING` |
| FairyCrown | `rbxassetid://PROCESSING` |
| EnchantedRobe | `rbxassetid://PROCESSING` |

### Pet Models
| Key | Asset ID |
|-----|----------|
| Pet_Common_Cat | 6820845348 |
| Pet_Legendary_Dragon | 6820845347 |
| Pet_Rare_Fox / NineTailed_Fox | 6820845349 |

---

## 22. AUDIO ASSETS

### SFX (5)
| Key | Asset ID |
|-----|----------|
| CoinPurchase | `rbxassetid://6895079853` |
| EggHatchCommon | `rbxassetid://9114224001` |
| EggHatchLegendary | `rbxassetid://9114224500` |
| PortalWarp | `rbxassetid://9114225100` |
| MountRoar | `rbxassetid://7145437362` |

### BGM (2)
| Key | Asset ID |
|-----|----------|
| LobbyTheme | `rbxassetid://1837879084` |
| ForestTheme | `rbxassetid://1837879500` |

### Fairytale Audio (4)
| Key | Asset ID |
|-----|----------|
| FairytaleBGM_Main | `rbxassetid://134088863499105` |
| MagicHatchSFX | `rbxassetid://134725968275841` |
| AuraChannelSFX | `rbxassetid://96494887569423` |
| EnchantedAmbient | `rbxassetid://94524502065950` |

---

## 23. PARTICLE ASSETS

| Key | Asset ID |
|-----|----------|
| FairytaleSparkles | `rbxassetid://74429346357342` |
| GlowingMotes | `rbxassetid://86655373792709` |
| AuraChannelTrail | `rbxassetid://131962962069775` |
| TransmutationBurst | `rbxassetid://124374758528939` |

---

## 24. UI ICONS (5)

| Key | Asset ID |
|-----|----------|
| CoinIcon | `rbxassetid://6031086229` |
| GemIcon | `rbxassetid://6031086300` |
| RebirthIcon | `rbxassetid://6031086450` |
| CrystalIcon | `rbxassetid://6031086500` |
| MountIcon | `rbxassetid://6031086550` |

---

## 25. PBR MATERIALS (Pending Upload)

| Material | Maps |
|----------|------|
| PolyHavenSteel | ColorMap, NormalMap, RoughnessMap, MetalnessMap |
| PolyHavenMarble | ColorMap, NormalMap, RoughnessMap |

---

## 26. MONETIZATION SUMMARY

### Revenue Streams
| Stream | Items | Price Range |
|--------|-------|-------------|
| Game Passes | 8 total (4 live, 3 designed, 1 pending) | 199–999 R$ |
| Developer Products | 8 total (4 live, 2 designed, 2 legacy) | 29–399 R$ |
| Subscription | 1 tier | $4.99/month |
| Avatar Items | 11 items | Coins/Gems/Robux |
| Building Blocks | 8 types | Coins/Gems |

### Key Product IDs (Creator Dashboard)
| Product | ID |
|---------|----|
| VIP_PASS | 1923436403 |
| SUPER_LUCK | 1924362417 |
| PLUS_50_INVENTORY_SLOTS | 1924818406 |
| AUTO_HATCH | 1925292405 |
| CYBER_NEON_TRAIL | 1923484423 |
| GEMS_LARGE_PACK | 3611126995 |
| COINS_LARGE_PACK | 3611126895 |
| GEMS_SMALL_PACK | 3611126819 |
| COINS_SMALL_PACK | 3611126655 |
| AURA_BOOST_MEDIUM | 3612013293 |
| CHRONO_SPARKS_PACK | 3612013298 |
| INSTANT_EGG_HATCH | 3612013299 |
| REBIRTH_SKIP_TOKEN | 3612013301 |

---

## 27. SERVICE & CONTROLLER ARCHITECTURE

### Server Services (78)

| Tier | Services |
|------|----------|
| **TIER 0** (Boot) | ExperimentService, LaunchDataService, LiveOpsService, PolicyComplianceService, RateLimitService, RemoteConfigService |
| **TIER 1** (Persistence) | PlayerDataService, ProfileStoreAdapter, RetentionService |
| **TIER 1.5** | DailyLoginService, LeaderboardService, MacroEconomyService, PoliticalService, SocialSimulationService |
| **TIER 2** (Gameplay Core) | AdminService, CombatService, CovenService, ExpeditionService, MobService, OnboardingService, QuestService, SanctumPassService, StoryService, StoreService |
| **TIER 2.5** | DiscoveryService, MachineService, ReactionEngine |
| **TIER 2.75** | RealmAssemblyService, RealmTeleportService |
| **TIER 3** (Economy) | AnalyticsService, EconomyService, EggService, GlobalBroadcastService, HatchService, MonetizationService, OfflineEarningsService, PetService, PlacementService, PotionVaultService, RecipeService, SetorAuraService, ShadowRaidService, TradeService, TycoonService |
| **TIER 3.5** | AlchemyService, BlockBuilderService, ResourceService, InteractionService |
| **TIER 4** | ConsumableMutationService, CrystalPurificationService, FlexZoneService, KarmaContractService |
| **TIER 4+** | AnnouncementService, CrossServerMessagingService |
| **TIER 5** | BadgeService, RewardedAdService, SocialEngagementService |
| **TIER 5.5** | SubscriptionService |
| **TIER 6** | WeaponService |
| **TIER 7** (LiveOps/Tools) | ABTestingService, AccessoryOptimizationService, AdminDashboardService, AnalyticsTrackerService, AuctionHouseService, BusinessService, CovenHideoutDataService, EventCalendarService, FeatureFlagService, FeedbackService, ModerationSyncService, NPCPsychologyService, ReferralService, SessionService, WorldAssemblyService, WorldGenerationService |
| **Post-Boot** | IntegrationTestService |

### Client Controllers (50)
Termasuk: AccessibilityController, ActionMenuController, AlchemyController, AnimationController, ARLensController, AudioController, CombatController, CombatVFXController, CutsceneController, MachineController, PetRenderController, TycoonRenderController, dan 38 lainnya.

---

## 28. WEB PORTAL (Next.js)

### Tech Stack
| Komponen | Teknologi |
|----------|-----------|
| Framework | Next.js 16.2.11 |
| UI | React 19.2.4 + Tailwind CSS |
| Database | PostgreSQL via Neon + Prisma 6.19.0 |
| Auth | NextAuth v4 |
| Deployment | Vercel |

### Database Models (10)
`RobloxGame`, `DevResource`, `PlayerCode`, `MarketAsset`, `Recipe`, `Spirit`, `Badge`, `BlogPost`, `LegalPage`, `ConfigEntry`, `Redirect`

### API Routes (8)
`/api/auth/[...nextauth]`, `/api/cms`, `/api/config`, `/api/datastore`, `/api/monitoring`, `/api/redirect`, `/api/webhook`, `/api/webhook/roblox`

### Public Routes
Home, Badges, Market, Recipes, Knowledge Base, Leaderboard, Announcements, Machines

### Admin Routes
Login, Dashboard, Monitoring, CMS, DataStore Browser, Config Editor, LiveOps

---

## 29. DATASTORE SCHEMA

| DataStore | Key Prefix | Data |
|-----------|-----------|------|
| COBLOX_DataStore_LGBOS_v11 | `COBLOX_LGBOS_v11_` | Player profiles (ProfileStore) |
| COBLOX_Leaderboard_Gems_v11 | — | Ordered: Gems leaderboard |
| COBLOX_Leaderboard_Coins_v11 | — | Ordered: Coins leaderboard |
| COBLOX_Covens_v1 | — | Coven persistence |
| CovenHideouts_v1 | — | Hideout persistence |
| COBLOX_RegistrySnapshots | — | Registry backup snapshots |

---

> **Dibuat pada:** 2026-07-30
> **Sumber:** `Content/Data/`, `src/Shared/Config/`, `src/Shared/Configuration/`, `src/Assets/`, `web/src/data/`
> **Open Cloud API Key:** Valid (scopes: 50+) | Universe: `10545905192` | Place: `105075159736246`
