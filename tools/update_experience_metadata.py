#!/usr/bin/env python3
"""
tools/update_experience_metadata.py

Updates COBLOX universe metadata via Roblox Open Cloud v2 API.

SETTABLE via API:
  displayName, description, visibility, desktopEnabled, mobileEnabled,
  tabletEnabled, consoleEnabled, vrEnabled

NOT settable via API (must be configured in Creator Dashboard):
  ageRating  — requires Content Maturity Questionnaire at:
               https://create.roblox.com/dashboard/creations/experiences/<universeId>/configure-start-place

Run:
    python3 tools/update_experience_metadata.py
"""

import os
import sys
import json
import urllib.request
import urllib.error


def load_env() -> None:
    env_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env")
    if os.path.exists(env_path):
        with open(env_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, val = line.split("=", 1)
                    os.environ.setdefault(key.strip(), val.strip().strip('"').strip("'"))


DISPLAY_NAME = "COBLOX: Multiverse Alchemy Sanctum \U0001f9ea\u26a1"
DESCRIPTION = (
    "\U0001f9ea Selamat Datang di COBLOX: Multiverse Alchemy Sanctum!\n\n"
    "\u2728 Tambang Kristal Mana, racik ramuan elemen legendaris, ciptakan Spirit Cybernetic, "
    "dan bangun Markas Alkimia impianmu!\n\n"
    "\U0001f31f FITUR GAME UTAMA:\n"
    "\u2022 \U0001f52e Bejana Racik Alkimia 3x3 (Crafting & Transmutation)\n"
    "\u2022 \u26a1 Fisika Interaktif: Angkat, Seret & Lempar Objek Fisik (0 Lag)\n"
    "\u2022 \U0001f43e Pet Spirit Cybernetic Hatching & Sistem Fusion\n"
    "\u2022 \U0001f3c6 50-Tier Seasonal Sanctum Battlepass & Daily Quests\n"
    "\u2022 \U0001f6e1\ufe0f Ekspedisi Guild, Shadow Raid & Mode PVP Zero-Trust\n\n"
    "\U0001f381 Bergabunglah dengan Group Resmi untuk mendapatkan +10% Boost Aura Energy!\n"
    "\u2b50 ROBLOX PREMIUM BENEFITS: Pemain Premium mendapatkan +20% Aura Energy Boost "
    "& 1.2x Luck Multiplier otomatis!\n"
    "\U0001f44d Tekan Like & Favorite untuk mendukung event update mingguan!"
)

UNIVERSE_CONFIG = {
    "displayName": DISPLAY_NAME,
    "description": DESCRIPTION,
    "visibility": "PUBLIC",
    "desktopEnabled": True,
    "mobileEnabled": True,
    "tabletEnabled": True,
    "consoleEnabled": False,
    "vrEnabled": True,
}


def patch_universe(api_key: str, universe_id: str, payload: dict) -> dict:
    url = f"https://apis.roblox.com/cloud/v2/universes/{universe_id}"
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url, data=data, method="PATCH",
        headers={"x-api-key": api_key, "Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=15) as resp:
        return json.loads(resp.read().decode("utf-8"))


def main() -> None:
    load_env()
    api_key = os.environ.get("ROBLOX_OPEN_CLOUD_API_KEY") or os.environ.get("ROBLOX_OPENCLOUD_API_KEY")
    universe_id = os.environ.get("ROBLOX_UNIVERSE_ID")

    if not api_key or not universe_id:
        print("❌ Missing ROBLOX_OPEN_CLOUD_API_KEY or ROBLOX_UNIVERSE_ID in .env")
        sys.exit(1)

    print(f"Updating universe {universe_id} metadata...")
    try:
        result = patch_universe(api_key, universe_id, UNIVERSE_CONFIG)
        print("✅ Universe metadata updated:")
        print(f"  displayName : {result.get('displayName')}")
        print(f"  visibility  : {result.get('visibility')}")
        print(f"  ageRating   : {result.get('ageRating')} (read-only via API)")
        print(f"  updateTime  : {result.get('updateTime')}")
        print()
        print("⚠️  ACTION REQUIRED — ageRating must be set manually in Creator Dashboard:")
        print(f"  https://create.roblox.com/dashboard/creations/experiences/{universe_id}/configure-start-place")
        print("  Complete the Content Maturity Questionnaire and set rating to 'All Ages'.")
    except urllib.error.HTTPError as e:
        print(f"❌ HTTP {e.code}: {e.read().decode()}")
        sys.exit(1)
    except Exception as exc:
        print(f"❌ Exception: {exc}")
        sys.exit(1)


if __name__ == "__main__":
    main()
