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

ascii_strings = re.findall(r'[\x20-\x7E]{4,}', decoded_bytes.decode('latin-1'))
jwt_part1 = ascii_strings[1] # Starts with eyJ...
jwt_part2 = ascii_strings[2] # Rest of JWT

reconstructed_jwt = jwt_part1 + jwt_part2
print("Reconstructed JWT Length:", len(reconstructed_jwt))
print("Reconstructed JWT Start:", reconstructed_jwt[:60])
print("Reconstructed JWT End:", reconstructed_jwt[-40:])

# Test payload decoding
parts = reconstructed_jwt.split(".")
print("\nJWT Parts count:", len(parts))
if len(parts) == 3:
    header_b64, payload_b64, sig_b64 = parts
    payload_b64 += "=" * ((4 - len(payload_b64) % 4) % 4)
    payload_bytes = base64.urlsafe_b64decode(payload_b64)
    print("\nDecoded JWT Payload:")
    print(payload_bytes.decode('utf-8', errors='ignore'))

# Test sending reconstructed_jwt
url = f"https://apis.roblox.com/messaging-service/v1/universes/{universe_id}/topics/test"
payload = json.dumps({"message": "Hello from Reconstructed JWT!"}).encode("utf-8")

for hdrs in [
    {"x-api-key": reconstructed_jwt, "Content-Type": "application/json"},
    {"Authorization": f"Bearer {reconstructed_jwt}", "Content-Type": "application/json"},
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
