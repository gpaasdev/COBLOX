#!/usr/bin/env python3
import os
import json
import base64
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
universe_id = os.environ.get("ROBLOX_UNIVERSE_ID")

# Extract JWT starting with "eyJ"
decoded = base64.b64decode(raw_key).decode('utf-8', errors='ignore')
jwt_start = decoded.find("eyJ")
jwt_token = decoded[jwt_start:] if jwt_start != -1 else raw_key

print("Extracted JWT Token length:", len(jwt_token))
print("JWT Token starts with:", jwt_token[:40])

url = f"https://apis.roblox.com/messaging-service/v1/universes/{universe_id}/topics/test"
payload = json.dumps({"message": "Hello from Open Cloud JWT!"}).encode("utf-8")

for hdrs in [
    {"x-api-key": jwt_token, "Content-Type": "application/json"},
    {"Authorization": f"Bearer {jwt_token}", "Content-Type": "application/json"},
    {"Authorization": jwt_token, "Content-Type": "application/json"},
]:
    header_name = list(hdrs.keys())[0] + (" (Bearer)" if "Bearer" in str(hdrs.values()) else "")
    req = urllib.request.Request(url, data=payload, headers=hdrs, method="POST")
    try:
        with urllib.request.urlopen(req) as resp:
            print(f"[{header_name}] SUCCESS! Status: {resp.status}")
    except urllib.error.HTTPError as e:
        print(f"[{header_name}] HTTP {e.code}: {e.read().decode('utf-8', errors='ignore')}")
    except Exception as e:
        print(f"[{header_name}] Error: {e}")
