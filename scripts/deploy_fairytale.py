#!/usr/bin/env python3
"""
scripts/deploy_fairytale.py
Build & publish Fairytale Realm place to Roblox via Open Cloud API.
Usage: python scripts/deploy_fairytale.py [--place-id PLACE_ID]
"""
import os
import sys
import subprocess
import argparse

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from packages.opencloud.client import OpenCloudClient

FAIRYTALE_DIR = os.path.join(os.path.dirname(__file__), "..", "fairytale")
BUILD_OUTPUT = "COBLOX_Fairytale.rbxl"

def main():
    parser = argparse.ArgumentParser(description="Build & deploy Fairytale Realm")
    parser.add_argument("--place-id", help="Override FAIRYTALE place ID")
    args = parser.parse_args()

    place_id = args.place_id or os.environ.get("ROBLOX_FAIRYTALE_PLACE_ID")
    if not place_id:
        print("❌ ROBLOX_FAIRYTALE_PLACE_ID not set. Provide --place-id or set env var.")
        sys.exit(1)

    # Build with Rojo
    print("🔨 Building Fairytale place...")
    result = subprocess.run(
        ["rojo", "build", FAIRYTALE_DIR, "-o", BUILD_OUTPUT],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"❌ Build failed:\n{result.stderr}")
        sys.exit(1)
    print(f"✅ Built: {BUILD_OUTPUT}")

    # Publish
    print(f"📤 Publishing to place ID: {place_id}...")
    client = OpenCloudClient()
    client.place_id = place_id
    client.publish_place(BUILD_OUTPUT)
    print("✅ Fairytale Realm deployed!")

if __name__ == "__main__":
    main()
