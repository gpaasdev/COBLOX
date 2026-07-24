#!/usr/bin/env python3
"""
Roblox Open Cloud LiveOps & Messaging Service CLI for COBLOX
Broadcasts global messages or triggers event boosts to active game servers in real time.
"""

import os
import sys
import json
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
    parser = argparse.ArgumentParser(description="COBLOX LiveOps Broadcast CLI")
    parser.add_argument("--topic", default="COBLOX_LiveOps_Topic", help="MessagingService topic")
    parser.add_argument("--type", choices=["announcement", "boost"], default="announcement", help="Event type")
    parser.add_argument("--message", required=True, help="Message text or boost configuration payload")

    args = parser.parse_args()

    env = load_env()
    api_key = env.get("ROBLOX_OPEN_CLOUD_API_KEY")
    universe_id = env.get("ROBLOX_UNIVERSE_ID")

    if not api_key or not universe_id:
        print("❌ Error: ROBLOX_OPEN_CLOUD_API_KEY or ROBLOX_UNIVERSE_ID missing in .env")
        sys.exit(1)

    payload_data = {
        "Type": args.type,
        "Message": args.message,
        "Timestamp": os.popen("date +%s").read().strip()
    }

    url = f"https://apis.roblox.com/messaging-service/v1/universes/{universe_id}/topics/{args.topic}"
    headers = {
        "x-api-key": api_key,
        "Content-Type": "application/json"
    }
    body = {
        "message": json.dumps(payload_data)
    }

    print(f"📡 Broadcasting LiveOps signal (Topic: '{args.topic}', Type: '{args.type}')...")
    response = requests.post(url, headers=headers, json=body)

    if response.status_code == 200:
        print("🎉 SUCCESS! LiveOps broadcast delivered to active servers.")
    else:
        print(f"❌ Broadcast failed ({response.status_code}): {response.text}")

if __name__ == "__main__":
    main()
