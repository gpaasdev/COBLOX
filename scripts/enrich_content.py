#!/usr/bin/env python3
"""Deepen biome / machine / spirit / reaction JSON data."""
import json, os, re, random

DATA = "Content/Data"
random.seed(42)

# ── Biomes ─────────────────────────────────────────────────────────────
BIOME_TRAITS = {
    "Volcanic": {"danger": 4, "tier": "T3", "ambient": "LavaCrackle", "color": "#ff4422",
        "resources": ["Obsidian", "Sulfur", "MagmaCore"], "drop_mult": 1.4,
        "creatures": ["Creature_Beast_Lvl5", "Creature_Golem_Lvl3", "Creature_Dragon_Lvl1"]},
    "Glacial": {"danger": 3, "tier": "T2", "ambient": "WindHowl", "color": "#88ccff",
        "resources": ["IceShard", "FrostCrystal", "Permafrost"],
        "creatures": ["Creature_Wisp_Lvl3", "Creature_Guardian_Lvl2"]},
    "Toxic": {"danger": 4, "tier": "T3", "ambient": "ToxicBubble", "color": "#66ff44",
        "resources": ["ToxicSac", "CorruptIchor", "BioMass"],
        "creatures": ["Creature_Parasite_Lvl4", "Creature_Abomination_Lvl2"]},
    "Aether": {"danger": 3, "tier": "T2", "ambient": "CelestialHum", "color": "#ccaaff",
        "resources": ["AetherCrystal", "EtherDust", "StarShard"],
        "creatures": ["Creature_Wisp_Lvl5", "Creature_Construct_Lvl3"]},
    "Celestial": {"danger": 5, "tier": "T4", "ambient": "StellarChime", "color": "#ffddaa",
        "resources": ["CelestialOrb", "StarFragment", "LightEssence"],
        "creatures": ["Creature_Dragon_Lvl5", "Creature_Construct_Lvl7"]},
    "Abyssal": {"danger": 5, "tier": "T4", "ambient": "DeepRumble", "color": "#4422aa",
        "resources": ["AbyssalEye", "DarkEssence", "VoidShard"],
        "creatures": ["Creature_Abomination_Lvl5", "Creature_Guardian_Lvl6"]},
    "Subterranean": {"danger": 3, "tier": "T2", "ambient": "CaveDrip", "color": "#886644",
        "resources": ["StoneCore", "CrystalShard", "MetalScrap"],
        "creatures": ["Creature_Golem_Lvl2", "Creature_Construct_Lvl2", "Creature_Parasite_Lvl2"]},
    "Void": {"danger": 6, "tier": "T5", "ambient": "VoidWhisper", "color": "#220044",
        "resources": ["VoidShard", "AbyssalEye", "DarkEssence"],
        "creatures": ["Creature_Dragon_Lvl8", "Creature_Abomination_Lvl8"]},
    "fairy": {"danger": 2, "tier": "T1", "ambient": "ForestBirds", "color": "#88ff88",
        "resources": ["WoodPlank", "Herb", "Fiber"],
        "creatures": ["Creature_Beast_Lvl2", "Creature_Wisp_Lvl2"]},
}

def enrich_biome(fname, data):
    bio_type = _detect_core(data.get("Id", ""))
    lvl = int(re.search(r"_(\d+)", fname).group(1)) if re.search(r"_(\d+)", fname) else 1
    traits = BIOME_TRAITS.get(bio_type, BIOME_TRAITS["fairy"])
    t = (lvl - 1) / 4.0 if lvl <= 5 else 1.0
    data["Tier"] = f"T{min(lvl, 5)}"
    data["DangerLevel"] = traits["danger"]
    data["AmbientSound"] = traits["ambient"]
    data["Color"] = traits["color"]
    data["Resources"] = [{"item": r, "chance": 0.3 + lvl * 0.05, "min": 1, "max": lvl} for r in traits["resources"]]
    spawn_creatures = traits["creatures"]
    lvl_offset = (lvl - 1) * 3
    data["SpawnTable"] = [
        {"creature": c, "weight": w, "minLevel": lvl_offset + 1, "maxLevel": lvl_offset + 3}
        for w, c in [(3, sc) for sc in spawn_creatures]
    ]
    return data


# ── Machines ───────────────────────────────────────────────────────────
MACHINE_TRAITS = {
    "Smelter": {"input": ["IronOre", "CopperOre", "GoldOre", "Stone"],
        "output": ["IronIngot", "CopperIngot", "GoldIngot", "RefinedStone"], "speed": 5.0, "efficiency": 0.7},
    "Refinery": {"input": ["CrudeOil", "OrganicSlurry", "ToxicSac"],
        "output": ["Fuel", "BioMass", "PurifiedIchor"], "speed": 8.0, "efficiency": 0.6},
    "Synthesizer": {"input": ["AetherCrystal", "EtherDust", "CrystalShard"],
        "output": ["SyntheticGem", "PowerCell", "EnergyOrb"], "speed": 6.0, "efficiency": 0.75},
    "Cooler": {"input": ["Water", "IceShard", "LiquidNitrogen"],
        "output": ["Coolant", "CryoFuel", "ChilledAir"], "speed": 3.0, "efficiency": 0.8},
    "Reactor": {"input": ["Uranium", "Plutonium", "MagmaCore"],
        "output": ["EnergyCell", "Plasma", "Steam"], "speed": 12.0, "efficiency": 0.5},
    "Turbine": {"input": ["Steam", "WindForce", "Plasma"],
        "output": ["Electricity", "KineticEnergy"], "speed": 4.0, "efficiency": 0.85},
    "CryoCooler": {"input": ["LiquidHelium", "IceShard"],
        "output": ["AbsoluteZeroCoolant", "Superconductor"], "speed": 2.0, "efficiency": 0.9},
    "FusionReactor": {"input": ["Deuterium", "Tritium", "Plasma"],
        "output": ["FusionCell", "NeutronFlux"], "speed": 15.0, "efficiency": 0.4},
}

def enrich_machine(fname, data):
    match = re.match(r"(\w+?)(?:'s|_v)?(\d*)", fname.replace("-", ""))
    mtype = _match_machine(fname)
    ver = int(re.search(r"_v?(\d+)", fname).group(1)) if re.search(r"_v?(\d+)", fname) else 1
    traits = MACHINE_TRAITS.get(mtype, {"input": ["Generic"], "output": ["Product"], "speed": 1.0, "efficiency": 0.5})
    data["Tier"] = f"T{min((ver // 2) + 1, 5)}"
    data["MachineType"] = mtype
    data["Version"] = ver
    data["InputTypes"] = traits["input"]
    data["OutputTypes"] = traits["output"]
    data["Speed"] = round(traits["speed"] * (1 + (ver - 1) * 0.1), 1)
    data["Efficiency"] = round(traits["efficiency"] + (ver - 1) * 0.02, 2)
    data["RecipeMap"] = [f"Recipe_{mtype}_{i}" for i in range(1, min(ver + 1, 4))]
    return data


# ── Spirits ────────────────────────────────────────────────────────────
SPIRIT_BASE_STATS = {
    "COMMON": {"hp": (50, 150), "atk": (5, 15), "def": (3, 10), "spd": (0.8, 1.2)},
    "UNCOMMON": {"hp": (120, 300), "atk": (12, 30), "def": (8, 20), "spd": (0.7, 1.1)},
    "RARE": {"hp": (250, 600), "atk": (25, 60), "def": (15, 40), "spd": (0.6, 1.0)},
    "EPIC": {"hp": (500, 1200), "atk": (50, 120), "def": (30, 80), "spd": (0.5, 0.9)},
    "LEGENDARY": {"hp": (1000, 2500), "atk": (100, 250), "def": (60, 150), "spd": (0.4, 0.8)},
    "MYTHIC": {"hp": (2000, 5000), "atk": (200, 500), "def": (120, 300), "spd": (0.3, 0.7)},
}

ELEMENTS = ["Fire", "Water", "Earth", "Air", "Aether", "Void", "Light", "Shadow", "Crystal", "Nature"]

SPIRIT_ABILITIES_POOL = {
    "Fire": ["FlameBurst", "Inferno", "FireShield", "BurnTouch"],
    "Water": ["HealingRain", "TidalWave", "FrostArmor", "HydroPump"],
    "Earth": ["RockBarrier", "Quake", "StoneSkin", "SandTrap"],
    "Air": ["WindBlade", "StormCall", "FeatherStep", "Tornado"],
    "Aether": ["ArcaneBolt", "Teleport", "ManaShield", "Starfall"],
    "Void": ["ShadowStrike", "VoidRift", "DarkPulse", "SoulSteal"],
    "Light": ["HolyLight", "Radiance", "Purify", "Blessing"],
    "Shadow": ["NightSlash", "ShadowCloak", "LifeLeech", "Curse"],
    "Crystal": ["CrystalShard", "Reflect", "GemArmor", "PrismBeam"],
    "Nature": ["VineWhip", "Regrowth", "PoisonSpores", "WildRage"],
}

def enrich_spirit(fname, data):
    rarity = data.get("Rarity", "Common").upper()
    element = data.get("Element", "Fire")
    stats = SPIRIT_BASE_STATS.get(rarity, SPIRIT_BASE_STATS["COMMON"])
    t_hash = sum(ord(c) for c in fname) / 100.0
    t = t_hash - int(t_hash)

    data["Stats"] = {
        "HP": round(stats["hp"][0] + (stats["hp"][1] - stats["hp"][0]) * t),
        "Attack": round(stats["atk"][0] + (stats["atk"][1] - stats["atk"][0]) * t),
        "Defense": round(stats["def"][0] + (stats["def"][1] - stats["def"][0]) * t),
        "Speed": round(stats["spd"][1] - (stats["spd"][1] - stats["spd"][0]) * t, 2),
    }

    abilities_pool = SPIRIT_ABILITIES_POOL.get(element, SPIRIT_ABILITIES_POOL["Fire"])
    num_abilities = min(2 if rarity in ("COMMON", "UNCOMMON") else 3 if rarity in ("RARE", "EPIC") else 4, len(abilities_pool))
    data["Abilities"] = abilities_pool[:num_abilities]

    data["SkillPool"] = abilities_pool

    scale = {"COMMON": 1, "UNCOMMON": 2, "RARE": 3, "EPIC": 4, "LEGENDARY": 5, "MYTHIC": 6}
    sp = scale.get(rarity, 1)
    data["EvolutionPath"] = {
        "maxLevel": 10 + sp * 5,
        "evolvesTo": next((s for s in _SPIRIT_EVOLUTIONS.get(fname.replace(".json", ""), [])), None),
        "evolutionMat": f"{element}Essence",
    }

    data["FusionMaterials"] = [
        {"item": f"{element}Essence", "count": sp},
        {"item": "Gold", "count": sp * 10},
    ]
    return data


_SPIRIT_EVOLUTIONS = {
    "COALSPRITE": ["FLAMECAT"],
    "FLAMECAT": ["MAGMASLIME"],
    "MAGMASLIME": ["SOLARDRAGON"],
    "ICECUBE": ["WATERDRIP"],
    "WATERDRIP": ["STORMELEMENTAL"],
    "CLAYPUP": ["STONEGOBLIN"],
    "STONEGOBLIN": ["SANDGOLEM"],
    "SANDGOLEM": ["CRYSTALBEAR"],
    "ASHPUFF": ["SPARKBUG"],
    "SPARKBUG": ["WINDFLYER"],
    "WINDFLYER": ["THUNDERBIRD"],
    "LEAFBUG": ["GLOWMUSH"],
    "GLOWMUSH": ["SUNLION"],
    "COPPERWISP": ["BRONZEDRAKE"],
    "BRONZEDRAKE": ["SILVERSYLPH"],
    "SILVERSYLPH": ["IRONIMP"],
    "IRONIMP": ["TITANIUMWYVERN"],
    "TITANIUMWYVERN": ["MYTHRILSERPENT"],
    "MYTHRILSERPENT": ["QUANTUMHYDRA"],
    "SHADOWFOX": ["AETHERWRAITH"],
    "AETHERWRAITH": ["ABYSSALKRAKEN"],
    "OBSIDIANPHOENIX": ["SOLARDRAGON"],
    "SOLARDRAGON": ["QUANTUMHYDRA"],
    "CRYSTALBEAR": ["TITANIUMWYVERN", "OBSIDIANPHOENIX"],
    "STORMELEMENTAL": ["ABYSSALKRAKEN"],
    "SUNLION": ["SOLARDRAGON"],
}

# ── Reactions ──────────────────────────────────────────────────────────
MORE_REACTIONS = {
    "Pyrolysis": {"materials": {"Wood": 3, "Sulfur": 1}, "temp": (400, 800), "product": "Charcoal", "yield": 2.0, "energy": 50},
    "Electrolysis": {"materials": {"Water": 5, "Salt": 1}, "temp": (100, 300), "product": "Hydrogen", "yield": 3.0, "energy": 150},
    "CrystalGrowth": {"materials": {"AetherCrystal": 2, "EtherDust": 3}, "temp": (800, 1200), "product": "LargeCrystal", "yield": 1.0, "energy": 200},
    "Corruption": {"materials": {"BioMass": 3, "ToxicSac": 1}, "temp": (100, 400), "product": "CorruptIchor", "yield": 1.5, "energy": 80},
    "Purification": {"materials": {"CorruptIchor": 2, "HolySeal": 1}, "temp": (600, 1000), "product": "PurifiedIchor", "yield": 1.0, "energy": 120},
    "FusionFerrium": {"materials": {"Iron": 5, "AetherCrystal": 1}, "temp": (1500, 2500), "product": "FerriumAlloy", "yield": 1.0, "energy": 100},
    "ArcaneInfusion": {"materials": {"StarShard": 2, "ManaCrystal": 3}, "temp": (1000, 2000), "product": "ArcaneGem", "yield": 1.0, "energy": 300},
    "VoidExtraction": {"materials": {"VoidShard": 3, "DarkEssence": 2}, "temp": (2000, 3000), "product": "PureVoid", "yield": 0.5, "energy": 500},
    "BioSynthesis": {"materials": {"Fiber": 5, "Herb": 3, "Water": 2}, "temp": (200, 500), "product": "Medicine", "yield": 2.0, "energy": 60},
    "CryoFreeze": {"materials": {"IceShard": 3, "LiquidHelium": 1}, "temp": (-100, 50), "product": "AbsoluteZeroCoolant", "yield": 1.0, "energy": 200},
    "PlasmaForm": {"materials": {"EnergyCell": 2, "MagmaCore": 1}, "temp": (3000, 5000), "product": "Plasma", "yield": 1.0, "energy": 400},
    "SolarRefine": {"materials": {"GoldOre": 3, "SunlightEssence": 1}, "temp": (1000, 1500), "product": "RefinedGold", "yield": 2.0, "energy": 150},
    "Distillation": {"materials": {"CrudeOil": 5}, "temp": (200, 400), "product": "Fuel", "yield": 3.0, "energy": 100},
    "AlloyFusion": {"materials": {"CopperIngot": 2, "TinIngot": 1}, "temp": (800, 1200), "product": "BronzeIngot", "yield": 2.0, "energy": 80},
    "Enchantment": {"materials": {"ArcaneGem": 1, "WeaponPart": 1}, "temp": (500, 1000), "product": "EnchantedWeapon", "yield": 1.0, "energy": 250},
}

# ── Helpers ────────────────────────────────────────────────────────────

def _detect_core(name):
    for prefix in ["Volcanic", "Glacial", "Toxic", "Aether", "Celestial", "Abyssal", "Subterranean", "Void", "fairy", "CentralHub"]:
        if prefix.lower() in name.lower():
            return prefix
    return "fairy"

def _match_machine(fname):
    for mtype in ["FusionReactor", "CryoCooler", "Smelter", "Refinery", "Synthesizer", "Cooler", "Reactor", "Turbine"]:
        if mtype.lower() in fname.lower():
            return mtype
    return "Smelter"


def main():
    root = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), DATA)
    counts = {}

    # Biomes
    bio_dir = os.path.join(root, "Biomes")
    counts["biomes"] = 0
    for fname in sorted(os.listdir(bio_dir)):
        if not fname.endswith(".json"): continue
        fpath = os.path.join(bio_dir, fname)
        with open(fpath) as f: data = json.load(f)
        enrich_biome(fname, data)
        with open(fpath, "w") as f: json.dump(data, f, indent=2)
        counts["biomes"] += 1

    # Machines
    mach_dir = os.path.join(root, "Machines")
    counts["machines"] = 0
    for fname in sorted(os.listdir(mach_dir)):
        if not fname.endswith(".json"): continue
        fpath = os.path.join(mach_dir, fname)
        with open(fpath) as f: data = json.load(f)
        enrich_machine(fname, data)
        with open(fpath, "w") as f: json.dump(data, f, indent=2)
        counts["machines"] += 1

    # Spirits
    spi_dir = os.path.join(root, "Spirits")
    counts["spirits"] = 0
    for fname in sorted(os.listdir(spi_dir)):
        if not fname.endswith(".json"): continue
        fpath = os.path.join(spi_dir, fname)
        with open(fpath) as f: data = json.load(f)
        enrich_spirit(fname, data)
        with open(fpath, "w") as f: json.dump(data, f, indent=2)
        counts["spirits"] += 1

    # Reactions — keep FerriumFusion, add the rest
    rxn_dir = os.path.join(root, "Reactions")
    counts["reactions"] = 0
    for rxn_id, rxn in MORE_REACTIONS.items():
        fpath = os.path.join(rxn_dir, f"{rxn_id}.json")
        data = {
            "Id": rxn_id,
            "Name": rxn_id,
            "RequiredMaterials": rxn["materials"],
            "MinTemperature": rxn["temp"][0],
            "MaxTemperature": rxn["temp"][1],
            "MinPressure": 1.0,
            "Product": rxn["product"],
            "YieldRatio": rxn["yield"],
            "EnergyRequired": rxn["energy"],
            "EntropyGenerated": round(0.05 + rxn["energy"] / 5000, 3),
        }
        with open(fpath, "w") as f: json.dump(data, f, indent=2)
        counts["reactions"] += 1

    print(f"✓ {counts['biomes']} biomes enriched")
    print(f"✓ {counts['machines']} machines enriched")
    print(f"✓ {counts['spirits']} spirits enriched")
    print(f"✓ {counts['reactions']} reaction files (including {len(MORE_REACTIONS)} new)")

if __name__ == "__main__":
    main()
