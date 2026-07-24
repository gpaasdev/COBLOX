#!/usr/bin/env python3
"""
Script to update Roblox Experience Metadata (Name & Description) via Open Cloud / API
"""

import os
import sys
import json
import urllib.request
import urllib.error

def load_env():
    env_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env")
    if os.path.exists(env_path):
        with open(env_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, val = line.split("=", 1)
                    os.environ[key.strip()] = val.strip().strip('"').strip("'")

def main():
    load_env()
    api_key = os.environ.get("ROBLOX_OPEN_CLOUD_API_KEY") or os.environ.get("ROBLOX_OPENCLOUD_API_KEY")
    universe_id = os.environ.get("ROBLOX_UNIVERSE_ID", "10545905192")

    if not api_key:
        print("❌ Missing API Key in .env")
        sys.exit(1)

    url = f"https://apis.roblox.com/universes/v1/{universe_id}"
    
    payload = {
        "name": "COBLOX: Multiverse Alchemy Sanctum 🧪⚡",
        "description": "🧪 Selamat Datang di COBLOX: Multiverse Alchemy Sanctum!\n\n✨ Tambang Kristal Mana, racik ramuan elemen legendaris, ciptakan Spirit Cybernetic, dan bangun Markas Alkimia impianmu!\n\n🌟 FITUR GAME UTAMA:\n• 🔮 Bejana Racik Alkimia 3x3 (Crafting & Transmutation)\n• ⚡ Fisika Interaktif: Angkat, Seret & Lempar Objek Fisik (0 Lag)\n• 🐾 Pet Spirit Cybernetic Hatching & Sistem Fusion\n• 🏆 50-Tier Seasonal Sanctum Battlepass & Daily Quests\n• 🛡️ Ekspedisi Guild, Shadow Raid & Mode PVP Zero-Trust\n\n🎁 Bergabunglah dengan Group Resmi kami untuk mendapatkan +10% Boost Aura Energy!\n👍 Tekan Like & Favorite untuk mendukung event update mingguan!"
    }

    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "x-api-key": api_key,
            "Content-Type": "application/json"
        },
        method="PATCH"
    )

    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            print(f"🎉 SUCCESS! Experience metadata updated on Roblox Cloud:\n{data}")
    except urllib.error.HTTPError as e:
        print(f"❌ HTTP Error {e.code}: {e.read().decode('utf-8')}")
    except Exception as e:
        print(f"❌ Exception: {e}")

if __name__ == "__main__":
    main()
