#!/usr/bin/env python3
"""
scripts/deploy_opencloud.py
Roblox Open Cloud Deployment Script for COBLOX using OpenCloudClient abstraction.
"""

import os
import sys
import subprocess

# Ensure Packages directory is on Python path for local module resolution
_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_PACKAGES_DIR = os.path.join(_ROOT, "Packages")
if _PACKAGES_DIR not in sys.path:
    sys.path.insert(0, _PACKAGES_DIR)

from opencloud.client import OpenCloudClient

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
    for k, v in env.items():
        os.environ[k] = v

    print("🔨 Building project with Rojo...")
    build_result = subprocess.run(["rojo", "build", "-o", "test.rbxl"], capture_output=True, text=True)
    if build_result.returncode != 0:
        print(f"❌ Rojo build failed:\n{build_result.stderr}")
        sys.exit(1)

    print("✅ Rojo build successful (test.rbxl).")

    try:
        client = OpenCloudClient()
        print(f"🚀 Publishing via Open Cloud v2 (Universe: {client.universe_id}, Place: {client.place_id})...")
        result = client.publish_place("test.rbxl")
        print(f"🎉 SUCCESS! Published version via Open Cloud v2 API!")
        print(result)
    except Exception as e:
        print(f"❌ Exception during deployment: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
