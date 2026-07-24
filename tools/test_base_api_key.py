#!/usr/bin/env python3
import os
import re
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

# Match baseApiKey string
match = re.search(r'"baseApiKey"\s*:\s*"([^"]+)"', text)
if match:
    base_api_key = match.group(1)
    print("Found baseApiKey! Length:", len(base_api_key))
    print("baseApiKey value:", base_api_key)
else:
    print("baseApiKey not found in decoded bytes.")
    base_api_key = "/N/G1bhX3kW+qyMlpVgyNG7jJEJtprcdbn3V4vVYfC31n2Hg"

url = f"https://apis.roblox.com/messaging-service/v1/universes/{universe_id}/topics/test"
payload = json.dumps({"message": "Hello from baseApiKey test!"}).encode("utf-8")

req = urllib.request.Request(url, data=payload, headers={"x-api-key": base_api_key, "Content-Type": "application/json"}, method="POST")
try:
    with urllib.request.urlopen(req) as resp:
        print(f"SUCCESS! Status: {resp.status}")
except urllib.error.HTTPError as e:
    print(f"HTTP {e.code}: {e.read().decode('utf-8', errors='ignore')}")
except Exception as e:
    print(f"Error: {e}")
