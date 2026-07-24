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
                    os.environ[key.strip()] = val.strip().strip('"').strip("'")

load_env()
raw_key = os.environ.get("ROBLOX_OPEN_CLOUD_API_KEY", "")
clean_key = raw_key.replace("\n", "").replace("\r", "").replace(" ", "").strip()
universe_id = "10545905192"

endpoints = [
    f"https://apis.roblox.com/cloud/v2/universes/{universe_id}/configs",
    f"https://apis.roblox.com/datastores/v1/universes/{universe_id}/standard-datastores",
    f"https://apis.roblox.com/assets/v1/assets",
]

for url in endpoints:
    print(f"\n--- Requesting: {url} ---")
    req = urllib.request.Request(url, headers={"x-api-key": clean_key})
    try:
        with urllib.request.urlopen(req) as resp:
            print(f"✅ SUCCESS! Status: {resp.status}")
            data = json.loads(resp.read().decode('utf-8'))
            print(json.dumps(data, indent=2)[:300])
    except urllib.error.HTTPError as e:
        body = e.read().decode('utf-8', errors='ignore')
        print(f"❌ HTTP {e.code}: {body}")
    except Exception as e:
        print(f"❌ Error: {e}")
