#!/usr/bin/env python3
"""
Roblox Open Cloud CLI Utility for COBLOX (LGBOS v11.0)
Provides integration with Roblox Open Cloud APIs:
- Assets API v1 (Upload decals / images)
- Place Publishing API
"""

import os
import sys
import json
import urllib.request
import urllib.error

USER_ID = "11329819428" # Account: hycoblox

def load_env():
    env_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env")
    if os.path.exists(env_path):
        with open(env_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, val = line.split("=", 1)
                    os.environ[key.strip()] = val.strip().strip('"').strip("'")

def get_config():
    load_env()
    api_key = os.environ.get("ROBLOX_OPEN_CLOUD_API_KEY")
    universe_id = os.environ.get("ROBLOX_UNIVERSE_ID")
    place_id = os.environ.get("ROBLOX_PLACE_ID")
    return api_key, universe_id, place_id

def upload_asset(file_path: str, display_name: str, description: str = "COBLOX Asset"):
    """Upload an image asset to Roblox via Open Cloud Assets API v1."""
    api_key, _, _ = get_config()
    if not api_key:
        print("[Error] Missing API Key in .env")
        return None

    url = "https://apis.roblox.com/assets/v1/assets"
    boundary = "----RobloxOpenCloudBoundary123456"
    
    json_payload = {
        "assetType": "Decal",
        "displayName": display_name,
        "description": description,
        "creationContext": {
            "creator": {
                "userId": USER_ID
            }
        }
    }

    if not os.path.exists(file_path):
        print(f"[Error] File not found: {file_path}")
        return None

    with open(file_path, "rb") as f:
        file_bytes = f.read()

    body = bytearray()
    body.extend(f"--{boundary}\r\n".encode("utf-8"))
    body.extend(f'Content-Disposition: form-data; name="request"\r\nContent-Type: application/json\r\n\r\n'.encode("utf-8"))
    body.extend(json.dumps(json_payload).encode("utf-8"))
    body.extend(f"\r\n--{boundary}\r\n".encode("utf-8"))
    body.extend(f'Content-Disposition: form-data; name="fileContent"; filename="{os.path.basename(file_path)}"\r\nContent-Type: image/png\r\n\r\n'.encode("utf-8"))
    body.extend(file_bytes)
    body.extend(f"\r\n--{boundary}--\r\n".encode("utf-8"))

    req = urllib.request.Request(
        url,
        data=body,
        headers={
            "x-api-key": api_key,
            "Content-Type": f"multipart/form-data; boundary={boundary}"
        },
        method="POST"
    )

    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            print(f"✅ [OpenCloud Asset API] Upload request submitted for '{display_name}': {data}")
            return data
    except urllib.error.HTTPError as e:
        print(f"❌ [OpenCloud Asset Error] HTTP {e.code}: {e.read().decode('utf-8')}")
    except Exception as e:
        print(f"❌ [OpenCloud Asset Error] {e}")
    return None

if __name__ == "__main__":
    api_key, universe_id, place_id = get_config()
    print("==================================================")
    print("🤖 COBLOX Roblox Open Cloud Integration (LGBOS v11.0)")
    print("==================================================")
    print(f"• User ID     : {USER_ID} (hycoblox)")
    print(f"• Universe ID : {universe_id}")
    print(f"• Place ID    : {place_id}")
    print(f"• API Key Status: {'Configured & Secured in .env' if api_key else 'Missing'}")
    print("==================================================")

    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        if cmd == "upload" and len(sys.argv) >= 4:
            fpath = sys.argv[2]
            dname = sys.argv[3]
            upload_asset(fpath, dname)
