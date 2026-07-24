#!/usr/bin/env python3
import os
import re
import sys
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

decoded_bytes = base64.b64decode(raw_key)
text = decoded_bytes.decode('utf-8', errors='ignore')

match = re.search(r'(eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+)', text)
if match:
    clean_jwt = match.group(1)
    print("Found clean JWT! Length:", len(clean_jwt))
    print("Clean JWT Starts with:", clean_jwt[:50])
    print("Clean JWT Ends with:", clean_jwt[-30:])
else:
    print("No clean JWT pattern found in decoded bytes.")
    sys.exit(1)

# Decode JWT Payload
jwt_parts = clean_jwt.split(".")
payload_b64 = jwt_parts[1]
payload_b64 += "=" * ((4 - len(payload_b64) % 4) % 4)
try:
    payload_bytes = base64.urlsafe_b64decode(payload_b64)
    print("\nDecoded JWT Payload String:", repr(payload_bytes))
    payload_json = json.loads(payload_bytes.decode('utf-8', errors='ignore'))
    print("JWT Payload Claims:")
    print(json.dumps(payload_json, indent=2))
except Exception as e:
    print("Payload decode error:", e)

# Test sending clean_jwt
url = f"https://apis.roblox.com/messaging-service/v1/universes/{universe_id}/topics/test"
payload = json.dumps({"message": "Hello from Open Cloud Clean JWT!"}).encode("utf-8")

for hdrs in [
    {"x-api-key": clean_jwt, "Content-Type": "application/json"},
    {"Authorization": f"Bearer {clean_jwt}", "Content-Type": "application/json"},
    {"Authorization": clean_jwt, "Content-Type": "application/json"},
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
