#!/usr/bin/env python3
import os
import re
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
decoded_bytes = base64.b64decode(raw_key)

ascii_strings = re.findall(r'[\x20-\x7E]{4,}', decoded_bytes.decode('latin-1'))
for s in ascii_strings[:15]:
    print("Found string:", repr(s))
