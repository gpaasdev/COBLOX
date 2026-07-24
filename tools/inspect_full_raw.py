#!/usr/bin/env python3
import os
import base64

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

try:
    decoded_bytes = base64.b64decode(raw_key)
    print("Decoded raw bytes length:", len(decoded_bytes))
    print("Decoded repr:", repr(decoded_bytes[:200]))
except Exception as e:
    print("Error:", e)
