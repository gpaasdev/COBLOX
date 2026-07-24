#!/usr/bin/env python3
import os
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
                    os.environ[key.strip()] = val.strip().strip('"')

load_env()

API_KEY = os.getenv("ROBLOX_OPEN_CLOUD_API_KEY", "")
UNIVERSE_ID = os.getenv("ROBLOX_UNIVERSE_ID", "10545905192")
USER_ID = os.getenv("ROBLOX_USER_ID", "11329819428")

print(f"Testing API Key (Length: {len(API_KEY)})")
print(f"Prefix: {API_KEY[:20]}...")

def test_endpoint(url, headers, label):
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req) as resp:
            print(f"✅ [{label}] Success ({resp.status}): {resp.read().decode('utf-8')[:200]}")
    except urllib.error.HTTPError as e:
        body = e.read().decode('utf-8') if e.fp else ""
        print(f"❌ [{label}] HTTP {e.code}: {body[:200]}")
    except Exception as e:
        print(f"❌ [{label}] Exception: {e}")

# Test 1: Configs API v2 with x-api-key
url_configs = f"https://apis.roblox.com/cloud/v2/universes/{UNIVERSE_ID}/developer-products"
test_endpoint(url_configs, {"x-api-key": API_KEY}, "Configs v2 (x-api-key)")

# Test 2: DataStore API v1 with x-api-key
url_datastores = f"https://apis.roblox.com/datastores/v1/universes/{UNIVERSE_ID}/standard-datastores"
test_endpoint(url_datastores, {"x-api-key": API_KEY}, "DataStores v1 (x-api-key)")

# Test 3: Assets API v1 with x-api-key
url_assets = f"https://apis.roblox.com/assets/v1/assets/1"
test_endpoint(url_assets, {"x-api-key": API_KEY}, "Assets v1 (x-api-key)")
