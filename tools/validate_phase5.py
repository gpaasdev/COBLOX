#!/usr/bin/env python3
"""
tools/validate_phase5.py
Production Validation Gate for Phases 0-4 COBLOX Fairytale Realm.
Verifies: services, controllers, content, monetization, config integrity.
Usage: python tools/validate_phase5.py
"""
import os
import sys
import json

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PASS = 0
FAIL = 0
WARN = 0

def check(label, condition, detail=""):
    global PASS, FAIL, WARN
    if condition:
        PASS += 1
        print(f"  ✅ {label}")
    else:
        FAIL += 1
        print(f"  ❌ {label} — {detail}")

def check_file(path):
    exists = os.path.isfile(path)
    check(f"File exists: {os.path.relpath(path, BASE_DIR)}", exists)
    return exists

def main():
    global PASS, FAIL, WARN
    print("=" * 60)
    print("COBLOX Phase 5 Production Validation")
    print("=" * 60)

    # Phase 0 — Services
    print("\n--- Phase 0: Production Services ---")
    check_file("src/Server/Services/RewardedAdService.luau")
    check_file("src/Server/Services/BadgeService.luau")
    check_file("src/Server/Services/SocialEngagementService.luau")
    check_file("src/Server/Services/PolicyComplianceService.luau")

    # Phase 1 — Realm Infrastructure
    print("\n--- Phase 1: Realm Infrastructure ---")
    check_file("src/Shared/Configuration/RealmConfig.luau")
    check_file("src/Shared/Config/RealmRegistry.luau")
    check_file("src/Server/Services/RealmAssemblyService.luau")
    check_file("src/Server/Services/RealmTeleportService.luau")
    check_file("fairytale/default.project.json")

    # Phase 1 — Client Controllers
    print("\n--- Phase 1: Client Controllers ---")
    check_file("src/Client/Controllers/AdRewardController.luau")
    check_file("src/Client/Controllers/BadgeNotificationController.luau")
    check_file("src/Client/Controllers/RealmEntryController.luau")
    check_file("src/Client/Controllers/SocialInviteController.luau")

    # Phase 2 — Fairytale Content
    print("\n--- Phase 2: Fairytale Content ---")
    spirit_dir = "Content/Data/Spirits"
    fairy_spirits = [f for f in os.listdir(os.path.join(BASE_DIR, spirit_dir)) if f.startswith("fairy_")]
    check(f"Fairytale spirit files ({len(fairy_spirits)})", len(fairy_spirits) >= 10)
    for s in fairy_spirits:
        check_file(f"{spirit_dir}/{s}")

    creature_dir = "Content/Data/Creatures"
    fairy_creatures = [f for f in os.listdir(os.path.join(BASE_DIR, creature_dir)) if f.startswith("fairy_")]
    check(f"Fairytale creature files ({len(fairy_creatures)})", len(fairy_creatures) >= 5)
    for c in fairy_creatures:
        check_file(f"{creature_dir}/{c}")

    biome_dir = "Content/Data/Biomes"
    fairy_biomes = [f for f in os.listdir(os.path.join(BASE_DIR, biome_dir)) if f.startswith("fairy_")]
    check(f"Fairytale biome files ({len(fairy_biomes)})", len(fairy_biomes) >= 5)
    for b in fairy_biomes:
        check_file(f"{biome_dir}/{b}")

    material_dir = "Content/Data/Materials"
    fairy_materials = [f for f in os.listdir(os.path.join(BASE_DIR, material_dir)) if "Fairy" in f or "Aether" in f or "Frost" in f or "Gold" in f or "Void" in f or "Moon" in f or "Enchanted" in f]
    check(f"Fairytale material files ({len(fairy_materials)})", len(fairy_materials) >= 5)

    recipe_dir = "Content/Data/Recipes"
    fairy_recipes = [f for f in os.listdir(os.path.join(BASE_DIR, recipe_dir)) if f.startswith("fairy_")]
    check(f"Fairytale recipe files ({len(fairy_recipes)})", len(fairy_recipes) >= 3)
    check_file("src/Shared/Config/GeneratedFairytaleSpiritRegistry.luau")
    check_file("src/Content/FairytaleBiomeRegistry.luau")

    # Phase 3 — Monetization
    print("\n--- Phase 3: Monetization ---")
    check_file("src/Server/Services/SubscriptionService.luau")
    
    # Check EconomyConfig for fairytale entries
    with open(os.path.join(BASE_DIR, "src/Shared/Configuration/EconomyConfig.luau")) as f:
        econ = f.read()
        check("EconomyConfig has FAIRYTALE_REALM_PASS", "FAIRYTALE_REALM_PASS" in econ)
        check("EconomyConfig has CELESTIAL_WINGS_BUNDLE", "CELESTIAL_WINGS_BUNDLE" in econ)
        check("EconomyConfig has SUBSCRIPTION config", "SUBSCRIPTION" in econ)
        check("EconomyConfig has MONTHLY_ALCHEMIST_ID", "MONTHLY_ALCHEMIST_ID" in econ)

    # Runtime registration
    print("\n--- Runtime Registration ---")
    with open(os.path.join(BASE_DIR, "src/Server/RuntimeServer.server.luau")) as f:
        rt = f.read()
        check("RuntimeServer has RewardedAdService", "RewardedAdService" in rt)
        check("RuntimeServer has BadgeService", "BadgeService" in rt)
        check("RuntimeServer has SocialEngagementService", "SocialEngagementService" in rt)
        check("RuntimeServer has RealmAssemblyService", "RealmAssemblyService" in rt)
        check("RuntimeServer has RealmTeleportService", "RealmTeleportService" in rt)
        check("RuntimeServer has SubscriptionService", "SubscriptionService" in rt)

    with open(os.path.join(BASE_DIR, "src/Client/RuntimeClient.client.luau")) as f:
        rc = f.read()
        check("RuntimeClient has AdRewardController", "AdRewardController" in rc)
        check("RuntimeClient has BadgeNotificationController", "BadgeNotificationController" in rc)
        check("RuntimeClient has RealmEntryController", "RealmEntryController" in rc)
        check("RuntimeClient has SocialInviteController", "SocialInviteController" in rc)

    # BOOT_FLAGS
    with open(os.path.join(BASE_DIR, "src/Shared/Configuration/GameConfig.luau")) as f:
        cfg = f.read()
        check("BOOT_FLAGS: RewardedAdService", "RewardedAdService = true" in cfg)
        check("BOOT_FLAGS: BadgeService", "BadgeService = true" in cfg)
        check("BOOT_FLAGS: SocialEngagementService", "SocialEngagementService = true" in cfg)
        check("BOOT_FLAGS: RealmAssemblyService", "RealmAssemblyService = true" in cfg)
        check("BOOT_FLAGS: RealmTeleportService", "RealmTeleportService = true" in cfg)
        check("BOOT_FLAGS: SubscriptionService", "SubscriptionService = true" in cfg)

    # CI/CD
    print("\n--- CI/CD ---")
    check_file(".github/workflows/deploy.yml")
    check_file("scripts/deploy_fairytale.py")
    check_file("scripts/create_badges.py")
    check_file("packages/opencloud/client.py")

    # Open Cloud API
    print("\n--- Open Cloud API Connection ---")
    import urllib.request
    import urllib.error
    api_key = os.environ.get("ROBLOX_OPEN_CLOUD_API_KEY") or os.environ.get("ROBLOX_OPENCLOUD_API_KEY", "")
    universe_id = os.environ.get("ROBLOX_UNIVERSE_ID", "10545905192")
    
    if api_key:
        try:
            req = urllib.request.Request(
                f"https://apis.roblox.com/cloud/v2/universes/{universe_id}",
                headers={"x-api-key": api_key}
            )
            with urllib.request.urlopen(req, timeout=10) as resp:
                data = json.loads(resp.read().decode())
                check(f"Open Cloud API connection OK — Universe: {data.get('displayName', '?')[:40]}", True)
        except Exception as e:
            check(f"Open Cloud API connection", False, str(e)[:60])
    else:
        WARN += 1
        print("  ⚠️ No Open Cloud API key in env (will use CI/CD secrets in production)")

    # Summary
    print(f"\n{'=' * 60}")
    total = PASS + FAIL
    print(f"Results: {PASS}/{total} passed, {FAIL} failed, {WARN} warnings")
    if FAIL == 0:
        print("✅ ALL VALIDATIONS PASSED — Production Ready!")
    else:
        print(f"❌ {FAIL} validations failed — review before deployment")
    print(f"{'=' * 60}")

if __name__ == "__main__":
    main()
