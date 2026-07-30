#!/usr/bin/env python3
"""Enrich creature JSONs with Damage, AttackSpeed, Defense, Abilities, LootTable."""
import json, os, re, math

CREATURES_DIR = "Content/Data/Creatures"

BASE_STATS = {
    "Beast": {"damage": (8, 25), "defense": (2, 8), "speed": (0.8, 1.4), "health_mult": 1.0, "abilities": ["ClawSwipes"]},
    "Golem": {"damage": (15, 45), "defense": (10, 30), "speed": (0.4, 0.8), "health_mult": 2.5, "abilities": ["GroundSlam", "RockShield"]},
    "Wisp": {"damage": (5, 18), "defense": (1, 5), "speed": (1.2, 1.8), "health_mult": 0.6, "abilities": ["EnergyBolt", "PhaseShift"]},
    "Parasite": {"damage": (6, 20), "defense": (1, 4), "speed": (1.0, 1.6), "health_mult": 0.7, "abilities": ["Leech", "PoisonBite"]},
    "Construct": {"damage": (10, 35), "defense": (8, 25), "speed": (0.5, 0.9), "health_mult": 2.0, "abilities": ["LaserBeam", "SelfRepair"]},
    "Abomination": {"damage": (12, 40), "defense": (5, 20), "speed": (0.6, 1.0), "health_mult": 1.8, "abilities": ["TentacleSlam", "CorruptAura"]},
    "Guardian": {"damage": (10, 30), "defense": (12, 35), "speed": (0.5, 0.9), "health_mult": 2.2, "abilities": ["ShieldWall", "HolyStrike"]},
    "Dragon": {"damage": (20, 60), "defense": (15, 40), "speed": (0.6, 1.0), "health_mult": 3.0, "abilities": ["FireBreath", "TailSwipe", "WingGust"]},
    "Void": {"damage": (30, 80), "defense": (20, 50), "speed": (0.7, 1.2), "health_mult": 4.0, "abilities": ["VoidRift", "ShadowTeleport", "AbyssalRoar"]},
    "MushroomGuardian": {"damage": (7, 22), "defense": (6, 18), "speed": (0.6, 1.0), "health_mult": 1.5, "abilities": ["SporeCloud", "RootEntangle"]},
    "WispHunter": {"damage": (9, 28), "defense": (3, 10), "speed": (1.1, 1.7), "health_mult": 0.8, "abilities": ["HuntersMark", "ShadowStrike"]},
}

LOOT_TABLES = {
    "Beast": [{"item": "RawMeat", "chance": 0.7, "min": 1, "max": 3}, {"item": "Leather", "chance": 0.4, "min": 1, "max": 2}],
    "Golem": [{"item": "StoneCore", "chance": 0.8, "min": 1, "max": 2}, {"item": "CrystalShard", "chance": 0.3, "min": 1, "max": 1}],
    "Wisp": [{"item": "EtherDust", "chance": 0.9, "min": 1, "max": 3}, {"item": "WispEssence", "chance": 0.2, "min": 1, "max": 1}],
    "Parasite": [{"item": "ParasiteClaw", "chance": 0.5, "min": 1, "max": 2}, {"item": "ToxicSac", "chance": 0.35, "min": 1, "max": 1}],
    "Construct": [{"item": "MetalScrap", "chance": 0.8, "min": 1, "max": 3}, {"item": "PowerCell", "chance": 0.25, "min": 1, "max": 1}],
    "Abomination": [{"item": "CorruptIchor", "chance": 0.6, "min": 1, "max": 2}, {"item": "TentacleFragment", "chance": 0.4, "min": 1, "max": 1}],
    "Guardian": [{"item": "GuardianShard", "chance": 0.7, "min": 1, "max": 2}, {"item": "HolySeal", "chance": 0.2, "min": 1, "max": 1}],
    "Dragon": [{"item": "DragonScale", "chance": 0.9, "min": 1, "max": 3}, {"item": "DragonHeart", "chance": 0.15, "min": 1, "max": 1}, {"item": "FlameGem", "chance": 0.3, "min": 1, "max": 1}],
    "Void": [{"item": "VoidShard", "chance": 1.0, "min": 1, "max": 3}, {"item": "AbyssalEye", "chance": 0.4, "min": 1, "max": 1}, {"item": "DarkEssence", "chance": 0.2, "min": 1, "max": 1}],
}


def _lerp(a, b, t): return a + (b - a) * t

def enrich(name, data):
    base, lvl = _parse(name)
    if not base:
        base = "Void"
    t = (lvl - 1) / 9.0 if lvl else 0.5
    stats = BASE_STATS.get(base, BASE_STATS["Beast"])

    data["Damage"] = round(_lerp(stats["damage"][0], stats["damage"][1], t))
    data["AttackSpeed"] = round(_lerp(stats["speed"][1], stats["speed"][0], t), 2)
    data["Defense"] = round(_lerp(stats["defense"][0], stats["defense"][1], t))
    if lvl:
        data["Health"] = round(100 * stats["health_mult"] * (1 + (lvl - 1) * 0.3))
    else:
        data["Health"] = data.get("Health", 1500)
    data["Abilities"] = stats["abilities"]
    data["LootTable"] = LOOT_TABLES.get(base, LOOT_TABLES["Beast"])
    data["XP"] = round(10 * (lvl or 5) * stats["health_mult"])
    return data

def _parse(name):
    m = re.match(r"(?:(?:Creature_|fairy_)?)(\w+)_Lvl(\d+)", name)
    if m:
        return m.group(1), int(m.group(2))
    m2 = re.match(r"(Void\w*)", name)
    if m2:
        return m2.group(1), None
    return None, None


def main():
    creatures_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), CREATURES_DIR)
    files = sorted(os.listdir(creatures_dir))
    updated = 0
    for fname in files:
        if not fname.endswith(".json"):
            continue
        fpath = os.path.join(creatures_dir, fname)
        with open(fpath) as f:
            data = json.load(f)
        enriched = enrich(fname, data)
        with open(fpath, "w") as f:
            json.dump(enriched, f, indent=2)
        updated += 1
        print(f"  {fname}: Dmg={enriched['Damage']} Spd={enriched['AttackSpeed']} Def={enriched['Defense']} HP={enriched['Health']} Abilities={len(enriched['Abilities'])}")
    print(f"\n✓ {updated} creature files enriched")

if __name__ == "__main__":
    main()
