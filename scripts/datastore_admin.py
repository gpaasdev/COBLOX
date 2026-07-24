#!/usr/bin/env python3
"""
Roblox Open Cloud DataStore Admin CLI for COBLOX
Inspect and update player profile data in Cloud DataStore.
"""

import os
import sys
import argparse
import requests

def load_env(env_path=".env"):
    env_vars = {}
    if os.path.exists(env_path):
        with open(env_path, "r") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, val = line.split("=", 1)
                    env_vars[key.strip()] = val.strip().strip('"').strip("'")
    return env_vars

def main():
    parser = argparse.ArgumentParser(description="COBLOX Cloud DataStore Admin CLI")
    subparsers = parser.add_subparsers(dest="command", help="Command to execute")

    inspect_parser = subparsers.add_parser("inspect", help="Inspect player data")
    inspect_parser.add_argument("--user-id", required=True, help="Roblox User ID")
    inspect_parser.add_argument("--datastore", default="COBLOX_PlayerData_v1", help="DataStore name")

    args = parser.parse_args()

    env = load_env()
    api_key = env.get("ROBLOX_OPEN_CLOUD_API_KEY")
    universe_id = env.get("ROBLOX_UNIVERSE_ID")

    if not api_key or not universe_id:
        print("❌ Error: ROBLOX_OPEN_CLOUD_API_KEY or ROBLOX_UNIVERSE_ID missing in .env")
        sys.exit(1)

    if args.command == "inspect":
        key_name = f"Player_{args.user_id}"
        url = f"https://apis.roblox.com/datastores/v1/universes/{universe_id}/standard-datastores/datastore/entries/entry"
        params = {
            "datastoreName": args.datastore,
            "entryKey": key_name
        }
        headers = {"x-api-key": api_key}

        print(f"🔍 Inspecting DataStore key '{key_name}' in '{args.datastore}'...")
        response = requests.get(url, headers=headers, params=params)
        
        if response.status_code == 200:
            print("✅ Player Profile Data:")
            print(response.text)
        else:
            print(f"❌ Failed to fetch data ({response.status_code}): {response.text}")

if __name__ == "__main__":
    main()
