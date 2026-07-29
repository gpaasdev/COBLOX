#!/usr/bin/env python3
"""
Push RemoteConfigRepository values to Roblox Experience Configs (Cloud API).
After running, RemoteConfigRepository.luau becomes a fallback-only dependency.

Usage:
  export ROBLOX_OPEN_CLOUD_API_KEY=your_key_here
  python3 scripts/sync_configs.py
"""
import os, sys, json, urllib.request, urllib.error

API_KEY = os.environ.get("ROBLOX_OPEN_CLOUD_API_KEY", "")
UNIVERSE_ID = os.environ.get("ROBLOX_UNIVERSE_ID", "10545905192")
BASE = "https://apis.roblox.com"

# Flattened config values extracted from RemoteConfigRepository.luau
CONFIG_ENTRIES = {
    # FeatureFlags (bool)
    "EnableGlobalAuctionHouse": True,
    "EnableLiveOpsEvents": True,
    "EnableDoubleXPWeekend": True,
    "EnableQuantumVaultInterest": True,
    "EnableLiveOpsJoinPopup": True,
    "EnableLiveOpsTopBar": True,
    "EnableLiveOpsDrawer": True,
    "SkipCinematic": True,
    "ServiceEnabled_MachineService": False,
    "ServiceEnabled_DiscoveryService": True,
    "ServiceEnabled_ReactionEngine": True,
    "ServiceEnabled_AlchemyService": True,
    "ServiceEnabled_EventCalendar": True,

    # Tuning (number)
    "Combat_BaseDamage": 10,
    "Combat_Range": 15,
    "Combat_MobCombatRange": 15,
    "Combat_MobAttackRange": 6,
    "Combat_MobAggroRadius": 30,
    "Combat_MobLeashDistance": 45,
    "Combat_MobWindupDuration": 1.0,
    "Combat_MobSpeed": 14,
    "Economy_VaultInterestRate": 0.05,
    "Economy_VaultMaxCapDays": 30,
    "Economy_RebirthBaseCost": 100000,
    "Economy_RebirthScalingExponent": 2.5,
    "Economy_RebirthTokenReward": 1,
    "Economy_LedgerMaxEntries": 100,
    "Economy_CrystalDepositCap": 5000000,
    "Economy_LargeDepositBroadcastMin": 10000,
    "Economy_BaseStarterAura": 250,
    "Economy_BaseStarterSparks": 25,
    "Economy_BaseStarterCoins": 250,
    "Economy_BaseStarterGems": 25,
    "Economy_VaultDailyInterestRate": 0.05,
    "Economy_CozyRatingLuckBoost": 0.02,
    "Economy_RebirthBaseCostCoins": 5000,
    "Economy_RebirthCostMultiplier": 2.2,
    "Economy_RebirthTokenRewardBase": 1,
    "Economy_MaxBaseEquipSlots": 4,
    "Economy_MaxBaseInventorySlots": 75,
    "Pet_MaxStorage": 50,
    "Pet_AutoMiningInterval": 2.0,
    "Pet_AutoMiningBaseYield": 10,
    "Pet_AwakeningMultiplierBonus": 0.5,
    "Pet_ScanRadius": 15,
    "LiveOps_LuckMultiplier": 1.0,
    "LiveOps_CoinMultiplier": 1.0,
    "LiveOps_XPMultiplier": 1.0,
    "LiveOps_AuraMultiplier": 1.0,
    "LiveOps_HatchLuckMultiplier": 1.0,
    "LiveOps_SeasonXpPerHatch": 10,
    "LiveOps_SeasonXpPerRebirth": 250,
    "Hatch_ChanceLegendaryMultiplier": 1.0,
    "Quest_DailyRewardCoins": 500,
    "Quest_DailyRewardXP": 100,
    "Machine_MaxPerFrame": 10,
    "Machine_DefaultHeat": 293,
    "Machine_WasteThreshold": 100,
    "AuraEnergyMultiplier": 1.0,
    "RebirthCost": 1000000,
    "RebirthAuraMultiplier": 0.10,
    "BlockBuilder_MaxPlotDistance": 15,
    "BillboardMaxDistance": 60,
    "PlotMaxDistance": 45,

    # StringConfig
    "LiveOps_ActiveSeasonId": "Season_01_MythicRise",
    "LiveOps_GlobalAnnouncement": "",
    "Monetization_GuildedWebhookURL": "",

    # BoolConfig
    "LiveOps_WeekendDoubleLuck": True,
    "LiveOps_WeekendDoubleCoins": True,
}

REPOSITORY = "InExperienceConfig"


def req(method, url, data=None):
    h = {"x-api-key": API_KEY, "Content-Type": "application/json"}
    b = json.dumps(data).encode() if data else None
    r = urllib.request.Request(url, data=b, headers=h, method=method)
    try:
        with urllib.request.urlopen(r) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        body = e.read().decode()
        print(f"  HTTP {e.code}: {body[:200]}")
        return None


def main():
    if not API_KEY:
        print("⚠️  ROBLOX_OPEN_CLOUD_API_KEY not set — dry-run")
        print(f"   Would push {len(CONFIG_ENTRIES)} config entries to Universe {UNIVERSE_ID}")
        for k, v in sorted(CONFIG_ENTRIES.items()):
            print(f"     {k:50s} = {v}")
        return

    config_url = f"{BASE}/creator-configs-public-api/v1/configs/universes/{UNIVERSE_ID}/repositories/{REPOSITORY}"

    # Step 1: Get current config to check
    print("📖 Reading current published config...")
    current = req("GET", config_url)
    if current:
        entries = current.get("entries", {})
        print(f"   Current entries: {len(entries)}")
    else:
        print("   No existing config or read failed")

    # Step 2: Stage draft
    print(f"\n📝 Staging draft with {len(CONFIG_ENTRIES)} entries...")
    draft = req("PUT", f"{config_url}/draft:overwrite", {"entries": CONFIG_ENTRIES})
    if not draft:
        print("❌ Failed to create draft")
        sys.exit(1)
    draft_hash = draft.get("draftHash")
    print(f"   Draft staged. Hash: {draft_hash}")

    # Step 3: Publish
    print("\n🚀 Publishing config...")
    result = req("POST", f"{config_url}/publish", {
        "draftHash": draft_hash,
        "message": "Sync from RemoteConfigRepository defaults",
        "deploymentStrategy": "Immediate",
    })
    if result:
        version = result.get("configVersion")
        print(f"✅ Published at config version {version}")
    else:
        print("❌ Publish failed")


if __name__ == "__main__":
    main()
