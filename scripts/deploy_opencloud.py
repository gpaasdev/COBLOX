#!/usr/bin/env python3
"""
Roblox Open Cloud Deployment Script for COBLOX
Builds project using Rojo and uploads .rbxl directly to Roblox Open Cloud API.
"""

import os
import sys
import subprocess
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
    env = load_env()
    api_key = env.get("ROBLOX_OPEN_CLOUD_API_KEY")
    universe_id = env.get("ROBLOX_UNIVERSE_ID")
    place_id = env.get("ROBLOX_PLACE_ID")

    if not api_key or not universe_id or not place_id:
        print("❌ Error: Missing ROBLOX_OPEN_CLOUD_API_KEY, ROBLOX_UNIVERSE_ID, or ROBLOX_PLACE_ID in .env")
        sys.exit(1)

    print("🔨 Building project with Rojo...")
    build_result = subprocess.run(["rojo", "build", "-o", "test.rbxl"], capture_output=True, text=True)
    if build_result.returncode != 0:
        print(f"❌ Rojo build failed:\n{build_result.stderr}")
        sys.exit(1)

    print("✅ Rojo build successful (test.rbxl).")
    print(f"🚀 Publishing to Roblox Open Cloud (Universe: {universe_id}, Place: {place_id})...")

    url = f"https://apis.roblox.com/universes/v1/{universe_id}/places/{place_id}/versions?versionType=Published"
    headers = {
        "x-api-key": api_key,
        "Content-Type": "application/octet-stream"
    }

    for attempt in range(1, 6):
        try:
            with open("test.rbxl", "rb") as f:
                file_data = f.read()

            print(f"🔄 Attempt #{attempt} sending upload request...")
            response = requests.post(url, headers=headers, data=file_data)
            
            if response.status_code == 200:
                data = response.json()
                print(f"🎉 SUCCESS! Published Version #{data.get('versionNumber')} to Roblox Open Cloud!")
                return
            elif response.status_code == 409:
                print(f"⚠️ 409 Conflict (Server Busy). Retrying in 5 seconds... ({attempt}/5)")
                import time
                time.sleep(5)
            else:
                print(f"❌ Deployment failed with status code {response.status_code}:")
                print(response.text)
                sys.exit(1)
        except Exception as e:
            print(f"❌ Exception during deployment: {e}")
            sys.exit(1)

    print("❌ Failed after 5 retries due to Roblox Open Cloud rate-limiting / server busy.")
    sys.exit(1)

if __name__ == "__main__":
    main()
