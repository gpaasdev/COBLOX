#!/usr/bin/env python3
"""
scripts/create_badges.py
Create all 15 COBLOX badges via Open Cloud API (legacy-badges).
Also update existing badge name/description/icon.
Usage: python scripts/create_badges.py --create-all
       python scripts/create_badges.py --update 644041556488993 --name "Soul Bonder" --desc "Hatch your first Spirit companion"
"""
import os
import sys
import json
import argparse
import urllib.request
import urllib.parse

API_BASE = "https://apis.roblox.com"
UNIVERSE_ID = os.environ.get("ROBLOX_UNIVERSE_ID", "10545905192")
API_KEY = os.environ.get("ROBLOX_OPEN_CLOUD_API_KEY") or os.environ.get("ROBLOX_OPENCLOUD_API_KEY")

BADGES = [
    {"key": "BDG_FIRST_CRAFT", "name": "First Synthesis", "desc": "Complete your first alchemical synthesis."},
    {"key": "BDG_SOUL_BONDER", "name": "Soul Bonder", "desc": "Hatch your first Spirit companion."},
    {"key": "BDG_BIOME_WALKER", "name": "Biome Walker", "desc": "Visit 5 different biomes."},
    {"key": "BDG_SANCTUM_BUILDER", "name": "Sanctum Builder", "desc": "Place 10 structures in your Sanctum."},
    {"key": "BDG_COVEN_FOUNDER", "name": "Coven Founder", "desc": "Create or join a Coven."},
    {"key": "BDG_DAILY_STREAK", "name": "Dedicated Alchemist", "desc": "Complete daily quests 7 days in a row."},
    {"key": "BDG_MONSTER_SLAYER", "name": "Creature Conqueror", "desc": "Defeat 100 hostile creatures."},
    {"key": "BDG_SHADOW_VETERAN", "name": "Shadow Veteran", "desc": "Complete 10 Shadow Raids."},
    {"key": "BDG_RESEARCHER", "name": "Grand Scholar", "desc": "Unlock 50 research nodes."},
    {"key": "BDG_VETERAN", "name": "Seasoned Veteran", "desc": "Reach 100 hours of total playtime."},
    {"key": "BDG_MASTER_SMITH", "name": "Forge Lord", "desc": "Upgrade a Machine to Mark 10."},
    {"key": "BDG_QUANTUM_MASTER", "name": "Quantum Master", "desc": "Synthesize a Quantum Essence."},
    {"key": "BDG_LEGENDARY_HATCH", "name": "Legend Caller", "desc": "Hatch a Legendary Spirit."},
    {"key": "BDG_PIONEER", "name": "Alchemist Pioneer", "desc": "Awarded to the first 10,000 players who synthesize a Tier 3 material."},
    {"key": "BDG_MULTIVERSE_TRAVELER", "name": "Multiverse Explorer", "desc": "Enter Sector 5 of any Biome."},
]

def call_api(method, path, data=None, files=None, content_type="application/json"):
    url = f"{API_BASE}{path}"
    headers = {"x-api-key": API_KEY}
    if content_type:
        headers["Content-Type"] = content_type
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, method=method, data=body, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        error_body = e.read().decode()
        print(f"  ❌ HTTP {e.code}: {error_body}")
        return None

def create_badge(name, description, icon_path=None):
    """Create a single badge via Open Cloud API."""
    path = f"/legacy-badges/v1/universes/{UNIVERSE_ID}/badges"
    payload = {
        "name": name,
        "description": description,
        "paymentSourceType": 2,  # Group funds
        "expectedCost": 0,
        "isActive": True,
    }
    result = call_api("POST", path, payload)
    if result:
        print(f"  ✅ Created badge: {name} (ID: {result.get('id')})")
    return result

def get_existing_badges():
    """Get existing badges for the universe."""
    path = f"/legacy-badges/v1/universes/{UNIVERSE_ID}/badges"
    result = call_api("GET", path)
    if result:
        return {b["name"]: b for b in result.get("data", [])}
    return {}

def main():
    parser = argparse.ArgumentParser(description="Manage COBLOX badges via Open Cloud")
    parser.add_argument("--create-all", action="store_true", help="Create all 15 badges")
    parser.add_argument("--list", action="store_true", help="List existing badges")
    parser.add_argument("--update", type=int, help="Update a badge by ID")
    parser.add_argument("--name", help="New name for badge (with --update)")
    parser.add_argument("--desc", help="New description for badge (with --update)")
    args = parser.parse_args()

    if not API_KEY:
        print("❌ ROBLOX_OPEN_CLOUD_API_KEY not set.")
        sys.exit(1)

    if args.list:
        badges = get_existing_badges()
        print(f"Existing badges ({len(badges)}):")
        for name, info in badges.items():
            print(f"  {info['id']}: {name} — {info.get('description', '')}")

    elif args.update:
        if args.name or args.desc:
            data = {}
            if args.name:
                data["name"] = args.name
            if args.desc:
                data["description"] = args.desc
            result = call_api("PATCH", f"/legacy-badges/v1/badges/{args.update}", data)
            if result is not None:
                print(f"  ✅ Updated badge {args.update}")
        else:
            print("  ⚠️ Provide --name and/or --desc")

    elif args.create_all:
        print(f"Creating {len(BADGES)} badges for universe {UNIVERSE_ID}...")
        existing = get_existing_badges()
        for badge in BADGES:
            if badge["name"] in existing:
                print(f"  ⏭️ Skipping {badge['key']} ({badge['name']}) — already exists (ID: {existing[badge['name']]['id']})")
            else:
                result = create_badge(badge["name"], badge["desc"])
                if result:
                    print(f"    → Map to BADGE_IDS in BadgeService.luau: {badge['key']} = {result.get('id')}")
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
