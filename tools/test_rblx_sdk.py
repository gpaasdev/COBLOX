#!/usr/bin/env python3
import os
import rblxopencloud

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
api_key = os.environ.get("ROBLOX_OPEN_CLOUD_API_KEY", "")
universe_id = int(os.environ.get("ROBLOX_UNIVERSE_ID", "10545905192"))

print("Testing rblx-open-cloud SDK v2.3.0...")
print(f"API Key present: {bool(api_key)}, Universe ID: {universe_id}")

try:
    universe = rblxopencloud.Universe(universe_id, api_key=api_key)
    print("Universe Object Created:", universe)
    
    # Try fetching DataStores list or publishing message
    datastores = universe.list_datastores()
    print("DataStores list response:", list(datastores))
except Exception as e:
    print("SDK Error:", e)
