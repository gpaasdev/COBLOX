#!/usr/bin/env python3
import os
import json
import base64
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
print("Full Key Length:", len(API_KEY))

# Check if there are '.' separating JWT parts
parts = API_KEY.split('.')
print(f"Key has {len(parts)} parts separated by dots.")

for i, part in enumerate(parts):
    print(f"Part {i} length: {len(part)}")
    if part.startswith("eyJ"): # Standard JWT header/payload base64
        try:
            # Pad base64
            padded = part + '=' * (-len(part) % 4)
            decoded = base64.b64decode(padded).decode('utf-8', errors='ignore')
            print(f"  Decoded Part {i}: {decoded}")
        except Exception as e:
            print(f"  Failed to decode Part {i}: {e}")

UNIVERSE_ID = os.getenv("ROBLOX_UNIVERSE_ID", "10545905192")

# Test both x-api-key and Authorization: Bearer
urls = [
    f"https://apis.roblox.com/datastores/v1/universes/{UNIVERSE_ID}/standard-datastores",
    f"https://apis.roblox.com/cloud/v2/universes/{UNIVERSE_ID}",
]

for url in urls:
    print(f"\n--- Testing URL: {url} ---")
    for auth_name, auth_header in [
        ("x-api-key Full", {"x-api-key": API_KEY}),
        ("Bearer Full", {"Authorization": f"Bearer {API_KEY}"}),
        ("x-api-key Prefix 48", {"x-api-key": API_KEY[:48]}),
        ("Bearer JWT Part", {"Authorization": f"Bearer {parts[0]}" if len(parts)>1 else {"x-api-key": API_KEY}}),
    ]:
        req = urllib.request.Request(url, headers=auth_header)
        try:
            with urllib.request.urlopen(req) as resp:
                print(f"  ✅ [{auth_name}] HTTP {resp.status}: {resp.read().decode('utf-8')[:200]}")
        except urllib.error.HTTPError as e:
            body = e.read().decode('utf-8') if e.fp else ""
            print(f"  ❌ [{auth_name}] HTTP {e.code}: {body[:200]}")
        except Exception as e:
            print(f"  ❌ [{auth_name}] Error: {e}")
