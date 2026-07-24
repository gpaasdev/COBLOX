#!/usr/bin/env python3
"""
COBLOX: Multiverse Alchemy Sanctum - Unified Open Cloud Operations Hub (CLI)
Version: 1.1.0
Author: Antigravity AI Engine

Provides 1-click execution for:
  - deploy               : Build place via Rojo & publish to Roblox Cloud.
  - broadcast            : Send real-time cross-server announcement banner.
  - trigger-event        : Trigger LiveOps boosts (Double Mana, Rate Up) to active servers.
  - inspect-player       : Query player DataStore profile directly from Cloud.
  - set-player-data      : Update/overwrite player DataStore entry in Cloud.
  - list-datastore-keys  : List entries inside a DataStore.
  - memory-set-map       : Set item in MemoryStore Sorted Map (e.g. Global Leaderboard).
  - memory-get-map       : Read items from MemoryStore Sorted Map.
  - ban-player           : Restrict/Ban problematic player via User Restrictions API.
  - upload-assets        : Upload production branding assets (icons, passes, thumbnails).
"""

import os
import sys
import json
import argparse
import subprocess
import requests

def load_env(env_path=None):
    if env_path is None:
        env_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), ".env")
    env_vars = {}
    if os.path.exists(env_path):
        with open(env_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, val = line.split("=", 1)
                    env_vars[key.strip()] = val.strip().strip('"').strip("'")
    return env_vars

def get_config():
    env = load_env()
    api_key = env.get("ROBLOX_OPEN_CLOUD_API_KEY") or env.get("ROBLOX_OPENCLOUD_API_KEY")
    universe_id = env.get("ROBLOX_UNIVERSE_ID", "10545905192")
    place_id = env.get("ROBLOX_PLACE_ID", "105075159736246")
    
    if not api_key:
        print("❌ Error: Missing ROBLOX_OPEN_CLOUD_API_KEY in .env file!")
        sys.exit(1)
        
    return api_key, universe_id, place_id

# --- Deploy & Asset Commands ---
def cmd_deploy(args, api_key, universe_id, place_id):
    print("🚀 [COBLOX CLI] Compiling codebase via Rojo...")
    project_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    output_file = os.path.join(project_dir, "build.rbxl")
    
    res = subprocess.run(["rojo", "build", "-o", output_file], cwd=project_dir)
    if res.returncode != 0:
        print("❌ Rojo build failed!")
        sys.exit(1)
        
    print(f"📦 Build compiled successfully: {output_file}")
    print(f"⚡ Publishing build to Roblox Cloud (Universe: {universe_id}, Place: {place_id})...")
    
    url = f"https://apis.roblox.com/universes/v1/{universe_id}/places/{place_id}/versions?versionType=Published"
    headers = {
        "x-api-key": api_key,
        "Content-Type": "application/octet-stream"
    }
    
    with open(output_file, "rb") as f:
        data = f.read()
        
    response = requests.post(url, headers=headers, data=data)
    
    if response.status_code == 200:
        resp_json = response.json()
        version_num = resp_json.get("versionNumber", "N/A")
        print(f"🎉 SUCCESS! Published Version #{version_num} to Roblox Live Cloud!")
    else:
        print(f"❌ Deploy failed ({response.status_code}): {response.text}")
        
    if os.path.exists(output_file):
        os.remove(output_file)

def cmd_upload_assets(args, api_key, universe_id, place_id):
    print("🎨 [COBLOX CLI] Triggering Asset Upload Suite...")
    tools_dir = os.path.dirname(os.path.abspath(__file__))
    script_path = os.path.join(tools_dir, "upload_experience_assets.py")
    
    res = subprocess.run([sys.executable, script_path])
    if res.returncode == 0:
        print("🎉 SUCCESS! Asset upload suite completed.")
    else:
        print("❌ Asset upload script encountered an error.")

# --- MessagingService Commands ---
def cmd_broadcast(args, api_key, universe_id, place_id):
    topic = "COBLOX_LiveOps_Topic"
    payload = {
        "Type": "announcement",
        "Message": args.message,
        "Timestamp": os.popen("date +%s").read().strip()
    }
    
    url = f"https://apis.roblox.com/messaging-service/v1/universes/{universe_id}/topics/{topic}"
    headers = {
        "x-api-key": api_key,
        "Content-Type": "application/json"
    }
    body = {"message": json.dumps(payload)}
    
    print(f"📡 [COBLOX CLI] Broadcasting message to active game servers...")
    response = requests.post(url, headers=headers, json=body)
    if response.status_code == 200:
        print("🎉 SUCCESS! Announcement broadcasted to all live game servers.")
    else:
        print(f"❌ Broadcast failed ({response.status_code}): {response.text}")

def cmd_trigger_event(args, api_key, universe_id, place_id):
    topic = "COBLOX_LiveOps_Topic"
    payload = {
        "Type": "boost",
        "EventType": args.event,
        "Multiplier": args.multiplier,
        "Duration": args.duration,
        "Timestamp": os.popen("date +%s").read().strip()
    }
    
    url = f"https://apis.roblox.com/messaging-service/v1/universes/{universe_id}/topics/{topic}"
    headers = {
        "x-api-key": api_key,
        "Content-Type": "application/json"
    }
    body = {"message": json.dumps(payload)}
    
    print(f"🌟 [COBLOX CLI] Triggering LiveOps Event Boost...")
    response = requests.post(url, headers=headers, json=body)
    if response.status_code == 200:
        print("🎉 SUCCESS! LiveOps Boost event activated across all game servers!")
    else:
        print(f"❌ Event trigger failed ({response.status_code}): {response.text}")

# --- DataStore API Commands ---
def cmd_inspect_player(args, api_key, universe_id, place_id):
    datastore_name = args.datastore or "COBLOX_PlayerData_v1"
    key_name = f"Player_{args.user_id}"
    
    url = f"https://apis.roblox.com/datastores/v1/universes/{universe_id}/standard-datastores/datastore/entries/entry"
    params = {"datastoreName": datastore_name, "entryKey": key_name}
    headers = {"x-api-key": api_key}
    
    print(f"🔍 [COBLOX CLI] Fetching DataStore Profile for User ID: {args.user_id}...")
    response = requests.get(url, headers=headers, params=params)
    
    if response.status_code == 200:
        print("✅ Player Profile Data:")
        try:
            print(json.dumps(response.json(), indent=2))
        except:
            print(response.text)
    else:
        print(f"❌ DataStore fetch failed ({response.status_code}): {response.text}")

def cmd_set_player_data(args, api_key, universe_id, place_id):
    datastore_name = args.datastore or "COBLOX_PlayerData_v1"
    key_name = f"Player_{args.user_id}"
    
    url = f"https://apis.roblox.com/datastores/v1/universes/{universe_id}/standard-datastores/datastore/entries/entry"
    params = {"datastoreName": datastore_name, "entryKey": key_name}
    headers = {
        "x-api-key": api_key,
        "Content-Type": "application/json"
    }
    
    try:
        data = json.loads(args.data)
    except Exception as e:
        print(f"❌ Error parsing JSON payload data: {e}")
        sys.exit(1)
        
    print(f"💾 [COBLOX CLI] Writing data to DataStore key '{key_name}'...")
    response = requests.post(url, headers=headers, params=params, json=data)
    
    if response.status_code == 200:
        print(f"🎉 SUCCESS! Updated DataStore entry for Player {args.user_id}.")
    else:
        print(f"❌ DataStore write failed ({response.status_code}): {response.text}")

def cmd_list_datastore_keys(args, api_key, universe_id, place_id):
    datastore_name = args.datastore or "COBLOX_PlayerData_v1"
    url = f"https://apis.roblox.com/datastores/v1/universes/{universe_id}/standard-datastores/datastore/entries"
    params = {"datastoreName": datastore_name, "limit": args.limit or 25}
    headers = {"x-api-key": api_key}
    
    print(f"📋 [COBLOX CLI] Listing keys in DataStore '{datastore_name}'...")
    response = requests.get(url, headers=headers, params=params)
    
    if response.status_code == 200:
        print(json.dumps(response.json(), indent=2))
    else:
        print(f"❌ List keys failed ({response.status_code}): {response.text}")

# --- MemoryStore API Commands ---
def cmd_memory_set_map(args, api_key, universe_id, place_id):
    map_name = args.map_name or "GlobalLeaderboard_Coins"
    item_id = args.id or f"User_{args.user_id}"
    
    url = f"https://apis.roblox.com/memorystores/v1/universes/{universe_id}/sorted-maps/{map_name}/items"
    headers = {
        "x-api-key": api_key,
        "Content-Type": "application/json"
    }
    payload = {
        "id": item_id,
        "value": args.value,
        "ttl": f"{args.ttl}s" if args.ttl else "86400s"
    }
    
    print(f"⚡ [COBLOX CLI] Setting MemoryStore Sorted Map item '{item_id}' in '{map_name}'...")
    response = requests.post(url, headers=headers, json=payload)
    
    if response.status_code in [200, 201]:
        print(f"🎉 SUCCESS! Item set in MemoryStore Map '{map_name}'.")
    else:
        print(f"❌ MemoryStore set failed ({response.status_code}): {response.text}")

def cmd_memory_get_map(args, api_key, universe_id, place_id):
    map_name = args.map_name or "GlobalLeaderboard_Coins"
    url = f"https://apis.roblox.com/memorystores/v1/universes/{universe_id}/sorted-maps/{map_name}/items"
    headers = {"x-api-key": api_key}
    
    print(f"🔍 [COBLOX CLI] Reading items from MemoryStore Sorted Map '{map_name}'...")
    response = requests.get(url, headers=headers)
    
    if response.status_code == 200:
        print(json.dumps(response.json(), indent=2))
    else:
        print(f"❌ MemoryStore get failed ({response.status_code}): {response.text}")

# --- User Restrictions Commands ---
def cmd_ban_player(args, api_key, universe_id, place_id):
    url = f"https://apis.roblox.com/user-restrictions/v1/universes/{universe_id}/user-restrictions"
    headers = {
        "x-api-key": api_key,
        "Content-Type": "application/json"
    }
    payload = {
        "gameJoinRestriction": {
            "user": f"users/{args.user_id}",
            "duration": f"{args.duration}s" if args.duration else "PERMANENT",
            "privateReason": args.reason or "Exploiting violation",
            "displayReason": "Account restricted due to policy/exploit violation."
        }
    }
    
    print(f"🛡️ [COBLOX CLI] Restricting player (User ID: {args.user_id})...")
    response = requests.patch(url, headers=headers, json=payload)
    
    if response.status_code in [200, 201]:
        print(f"🎉 SUCCESS! Player {args.user_id} restricted successfully.")
    else:
        print(f"⚠️ User Restrictions API notice ({response.status_code}): {response.text}")
        print("💡 Broadcasting Emergency Ban signal via MessagingService fallback...")
        topic = "COBLOX_LiveOps_Topic"
        fallback_payload = {
            "Type": "ban",
            "UserId": int(args.user_id),
            "Reason": args.reason or "Zero-Trust Security Enforcement"
        }
        requests.post(
            f"https://apis.roblox.com/messaging-service/v1/universes/{universe_id}/topics/{topic}",
            headers=headers,
            json={"message": json.dumps(fallback_payload)}
        )
        print("✅ Fallback Ban signal sent to active game servers.")

def main():
    parser = argparse.ArgumentParser(description="COBLOX Open Cloud Unified Operational CLI v1.1.0")
    subparsers = parser.add_subparsers(dest="command", help="Operational command")
    
    # Deploy & Assets
    subparsers.add_parser("deploy", help="Build & publish place to Roblox Cloud")
    subparsers.add_parser("upload-assets", help="Upload branding images & passes")
    
    # Broadcast & LiveOps
    broadcast_parser = subparsers.add_parser("broadcast", help="Broadcast global announcement")
    broadcast_parser.add_argument("--message", "-m", required=True, help="Announcement message text")
    
    event_parser = subparsers.add_parser("trigger-event", help="Trigger LiveOps boost event")
    event_parser.add_argument("--event", "-e", required=True, choices=["DoubleMana", "GoldenEggRateUp", "AuraSpeedBoost"], help="Event type")
    event_parser.add_argument("--multiplier", "-mult", type=float, default=2.0, help="Boost multiplier")
    event_parser.add_argument("--duration", "-d", type=int, default=3600, help="Duration in seconds")
    
    # DataStore Commands
    inspect_parser = subparsers.add_parser("inspect-player", help="Inspect player DataStore profile")
    inspect_parser.add_argument("--user-id", "-u", required=True, help="Roblox User ID")
    inspect_parser.add_argument("--datastore", default="COBLOX_PlayerData_v1", help="DataStore name")
    
    set_data_parser = subparsers.add_parser("set-player-data", help="Set/Update DataStore profile")
    set_data_parser.add_argument("--user-id", "-u", required=True, help="Roblox User ID")
    set_data_parser.add_argument("--data", "-d", required=True, help="JSON string data payload")
    set_data_parser.add_argument("--datastore", default="COBLOX_PlayerData_v1", help="DataStore name")
    
    list_keys_parser = subparsers.add_parser("list-datastore-keys", help="List entry keys in DataStore")
    list_keys_parser.add_argument("--datastore", default="COBLOX_PlayerData_v1", help="DataStore name")
    list_keys_parser.add_argument("--limit", type=int, default=25, help="Number of keys to fetch")
    
    # MemoryStore Commands
    mem_set_parser = subparsers.add_parser("memory-set-map", help="Set item in MemoryStore Sorted Map")
    mem_set_parser.add_argument("--map-name", default="GlobalLeaderboard_Coins", help="Sorted map name")
    mem_set_parser.add_argument("--user-id", "-u", help="User ID if item ID is user")
    mem_set_parser.add_argument("--id", help="Item ID")
    mem_set_parser.add_argument("--value", required=True, help="Item JSON value or string")
    mem_set_parser.add_argument("--ttl", type=int, default=86400, help="Time-to-live in seconds")
    
    mem_get_parser = subparsers.add_parser("memory-get-map", help="Read items from MemoryStore Sorted Map")
    mem_get_parser.add_argument("--map-name", default="GlobalLeaderboard_Coins", help="Sorted map name")
    
    # User Restrictions
    ban_parser = subparsers.add_parser("ban-player", help="Ban/Restrict player via Open Cloud")
    ban_parser.add_argument("--user-id", "-u", required=True, help="Roblox User ID")
    ban_parser.add_argument("--reason", "-r", default="Zero-Trust Exploit Penalty", help="Reason")
    ban_parser.add_argument("--duration", "-d", type=int, default=86400, help="Duration in seconds")
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
        
    api_key, universe_id, place_id = get_config()
    
    if args.command == "deploy":
        cmd_deploy(args, api_key, universe_id, place_id)
    elif args.command == "broadcast":
        cmd_broadcast(args, api_key, universe_id, place_id)
    elif args.command == "trigger-event":
        cmd_trigger_event(args, api_key, universe_id, place_id)
    elif args.command == "inspect-player":
        cmd_inspect_player(args, api_key, universe_id, place_id)
    elif args.command == "set-player-data":
        cmd_set_player_data(args, api_key, universe_id, place_id)
    elif args.command == "list-datastore-keys":
        cmd_list_datastore_keys(args, api_key, universe_id, place_id)
    elif args.command == "memory-set-map":
        cmd_memory_set_map(args, api_key, universe_id, place_id)
    elif args.command == "memory-get-map":
        cmd_memory_get_map(args, api_key, universe_id, place_id)
    elif args.command == "ban-player":
        cmd_ban_player(args, api_key, universe_id, place_id)
    elif args.command == "upload-assets":
        cmd_upload_assets(args, api_key, universe_id, place_id)

if __name__ == "__main__":
    main()
