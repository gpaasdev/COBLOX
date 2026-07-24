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
api_key = os.environ.get("ROBLOX_OPEN_CLOUD_API_KEY", "")
user_id = "11329819428" # hycoblox

url = "https://apis.roblox.com/assets/v1/assets"
boundary = "---------------------------RobloxFormBoundary987654321"

json_data = {
    "assetType": "Decal",
    "displayName": "Test Asset Upload",
    "description": "COBLOX Test",
    "creationContext": {
        "creator": {
            "userId": user_id
        }
    }
}

test_file_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "docs", "ASSETS", "pass_super_luck.png")
with open(test_file_path, "rb") as f:
    img_bytes = f.read()

body = bytearray()
body.extend(f"--{boundary}\r\n".encode("utf-8"))
body.extend('Content-Disposition: form-data; name="request"\r\nContent-Type: application/json\r\n\r\n'.encode("utf-8"))
body.extend(json.dumps(json_data).encode("utf-8"))
body.extend(f"\r\n--{boundary}\r\n".encode("utf-8"))
body.extend('Content-Disposition: form-data; name="fileContent"; filename="pass_super_luck.png"\r\nContent-Type: image/png\r\n\r\n'.encode("utf-8"))
body.extend(img_bytes)
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
        print(f"SUCCESS! Status: {resp.status}")
        print(resp.read().decode('utf-8'))
except urllib.error.HTTPError as e:
    print(f"HTTP {e.code}: {e.read().decode('utf-8', errors='ignore')}")
except Exception as e:
    print(f"Error: {e}")
