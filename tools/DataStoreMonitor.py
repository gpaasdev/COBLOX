#!/usr/bin/env python3
"""
COBLOX Open Cloud DataStore External Monitor
============================================
Utility script for monitoring player DataStore health via Roblox Open Cloud REST API v2.
"""

import os
import sys
import json
import urllib.request
import urllib.error

ROBLOX_API_KEY = os.environ.get("ROBLOX_API_KEY", "")
UNIVERSE_ID = os.environ.get("ROBLOX_UNIVERSE_ID", "")

def fetch_datastore_entries(datastore_name):
    if not ROBLOX_API_KEY or not UNIVERSE_ID:
        print("[DataStoreMonitor] WARNING: ROBLOX_API_KEY or ROBLOX_UNIVERSE_ID not set.")
        return None

    url = f"https://apis.roblox.com/cloud/v2/universes/{UNIVERSE_ID}/data-stores/{datastore_name}/entries"
    req = urllib.request.Request(url)
    req.add_header("x-api-key", ROBLOX_API_KEY)

    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            print(f"[DataStoreMonitor] Successfully retrieved entries for DataStore '{datastore_name}':")
            print(json.dumps(data, indent=2))
            return data
    except urllib.error.HTTPError as e:
        print(f"[DataStoreMonitor] HTTP Error {e.code}: {e.reason}")
    except Exception as e:
        print(f"[DataStoreMonitor] Error fetching DataStore entries: {e}")

if __name__ == "__main__":
    print("--- COBLOX Open Cloud DataStore Monitor ---")
    fetch_datastore_entries("PlayerData_v1")
