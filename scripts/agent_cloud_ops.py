#!/usr/bin/env python3
"""
COBLOX AI Agent Cloud Operations Utility
Provides autonomous Open Cloud capabilities for AI Agent (Antigravity):
- Luau Execution API
- Place Publishing & Versioning API
- DataStore Inspection API
"""

import sys
import os
import json
import urllib.request
import urllib.error

# Load environment variables
ENV_PATH = os.path.join(os.path.dirname(__file__), "../.env")
CONFIG = {}

if os.path.exists(ENV_PATH):
    with open(ENV_PATH, "r") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                CONFIG[k.strip()] = v.strip().strip('"')

API_KEY = CONFIG.get("ROBLOX_OPEN_CLOUD_API_KEY", "").strip('"').strip("'").strip()
UNIVERSE_ID = CONFIG.get("ROBLOX_UNIVERSE_ID", "10545905192")
PLACE_ID = CONFIG.get("ROBLOX_PLACE_ID", "105075159736246")

def introspect_key():
    """Validates API Key scopes via Open Cloud Introspect API"""
    url = "https://apis.roblox.com/api-keys/v1/introspect"
    data = json.dumps({"apiKey": API_KEY}).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req) as resp:
            res = json.loads(resp.read().decode())
            print(f"✅ Key Verified: Name='{res.get('name')}', Scopes={len(res.get('scopes', []))}")
            return res
    except urllib.error.HTTPError as e:
        print(f"❌ Introspect Error: {e.code} - {e.read().decode()}")
        return None

def execute_luau(script_code: str):
    """Submits a Luau task to server via Open Cloud Luau Execution API"""
    url = f"https://apis.roblox.com/luau-execution/v1/universes/{UNIVERSE_ID}/tasks"
    payload = {"script": script_code}
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers={
        "x-api-key": API_KEY,
        "Content-Type": "application/json"
    })
    try:
        with urllib.request.urlopen(req) as resp:
            res = json.loads(resp.read().decode())
            print(f"🚀 Luau Execution Task Submitted: ID={res.get('path')}")
            return res
    except urllib.error.HTTPError as e:
        print(f"⚠️ Luau Execution Error ({e.code}): {e.read().decode()}")
        return None

def read_datastore(datastore_name: str, entry_key: str, scope: str = "global"):
    """Reads a DataStore entry via Open Cloud DataStore API"""
    url = f"https://apis.roblox.com/datastores/v1/universes/{UNIVERSE_ID}/standard-datastores/datastore/entries/entry?datastoreName={datastore_name}&scope={scope}&entryKey={entry_key}"
    req = urllib.request.Request(url, headers={"x-api-key": API_KEY})
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode())
            print(f"📦 DataStore Read Success: {datastore_name}/{entry_key}")
            return data
    except urllib.error.HTTPError as e:
        print(f"❌ DataStore Read Error ({e.code}): {e.read().decode()}")
        return None

if __name__ == "__main__":
    print("==================================================")
    print("🤖 COBLOX AI Agent Cloud Operations Engine")
    print("==================================================")
    introspect_key()
