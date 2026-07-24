#!/usr/bin/env python3
import os
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
                    os.environ[key.strip()] = val.strip().strip('"')

load_env()

API_KEY = os.getenv("ROBLOX_OPEN_CLOUD_API_KEY", "")
UNIVERSE_ID = os.getenv("ROBLOX_UNIVERSE_ID", "10545905192")
USER_ID = os.getenv("ROBLOX_USER_ID", "11329819428")

prefix_key = API_KEY[:48] if len(API_KEY) >= 48 else API_KEY

print(f"Full Key Length: {len(API_KEY)}")
print(f"Extracted 48-char Prefix: {prefix_key}")

endpoints = [
    ("DataStores v1", f"https://apis.roblox.com/datastores/v1/universes/{UNIVERSE_ID}/standard-datastores"),
    ("Developer Products v2", f"https://apis.roblox.com/cloud/v2/universes/{UNIVERSE_ID}/developer-products"),
    ("User Restriction v2", f"https://apis.roblox.com/cloud/v2/universes/{UNIVERSE_ID}/user-restrictions"),
]

for label, url in endpoints:
    print(f"\n--- Testing Endpoint: {label} ---")
    for key_label, key_val in [("48-char Prefix", prefix_key), ("Full String", API_KEY)]:
        req = urllib.request.Request(url, headers={"x-api-key": key_val})
        try:
            with urllib.request.urlopen(req) as resp:
                print(f"  ✅ [{key_label}] HTTP {resp.status}: {resp.read().decode('utf-8')[:200]}")
        except urllib.error.HTTPError as e:
            body = e.read().decode('utf-8') if e.fp else ""
            print(f"  ❌ [{key_label}] HTTP {e.code}: {body[:200]}")
        except Exception as e:
            print(f"  ❌ [{key_label}] Error: {e}")
