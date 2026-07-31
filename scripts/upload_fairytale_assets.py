#!/usr/bin/env python3
"""
COBLOX Fairytale Asset Uploader — Open Cloud Assets v2
Uploads the generated Fairytale Realm PNGs as Decal assets and injects the
returned asset IDs into src/Assets/AssetManifestFairytale.luau, replacing the
rbxassetid://PROCESSING placeholders.

Usage:
    python3 scripts/upload_fairytale_assets.py --dry-run
    python3 scripts/upload_fairytale_assets.py --upload

Requires env (reads repo .env): ROBLOX_OPEN_CLOUD_API_KEY (asset:write), ROBLOX_USER_ID
"""

import argparse
import json
import os
import re
import sys
import time
import urllib.request
import urllib.error
from pathlib import Path

ASSETS_API = "https://apis.roblox.com/assets/v1/assets"
ENV_PATH = Path(__file__).resolve().parent.parent / ".env"
MANIFEST_PATH = (
    Path(__file__).resolve().parent.parent / "src" / "Assets" / "AssetManifestFairytale.luau"
)
PNG_DIR = Path("/Users/mac/.gemini/antigravity-ide/brain/e0db8d2f-2409-4caf-bf21-38e10d33914c")

# slot → (png file, display name)
UPLOADS = {
    "AetherCrystalMesh": ("coblox_aether_crystal_icon_1785401127587.png", "COBLOX Aether Crystal Icon"),
    "CrystalNodeAether": ("coblox_pyro_crystal_icon_1785399800506.png", "COBLOX Pyro Crystal Icon"),
    "SpiritFoxMesh": ("coblox_spirit_fox_companion_1785399868653.png", "COBLOX Spirit Fox Companion Icon"),
    "FairyDragon": ("coblox_fairy_dragon_companion_1785401143264.png", "COBLOX Fairy Dragon Companion Icon"),
    "ManaBloom": ("coblox_quantum_essence_icon_1785401313760.png", "COBLOX Quantum Essence Icon"),
    "TransmutationBadge": ("coblox_transmutation_badge_icon_1785401337067.png", "COBLOX Transmutation Badge Icon"),
}


def load_env():
    config = {}
    if ENV_PATH.exists():
        for line in ENV_PATH.read_text().splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                config[k.strip()] = v.strip().strip('"').strip("'")
    return config


def multipart_post(url, headers, fields, file_path):
    boundary = "----COBLOXBoundary" + str(int(time.time() * 1000))
    body = bytearray()
    for name, value in fields.items():
        body += f"--{boundary}\r\n".encode()
        body += f'Content-Disposition: form-data; name="{name}"\r\n\r\n'.encode()
        body += value.encode() + b"\r\n"
    body += f"--{boundary}\r\n".encode()
    body += f'Content-Disposition: form-data; name="fileContent"; filename="{Path(file_path).name}"\r\n'.encode()
    body += b"Content-Type: image/png\r\n\r\n"
    body += Path(file_path).read_bytes() + b"\r\n"
    body += f"--{boundary}--\r\n".encode()

    headers["Content-Type"] = f"multipart/form-data; boundary={boundary}"
    req = urllib.request.Request(url, data=bytes(body), headers=headers, method="POST")
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode())


def poll_operation(api_key, op_path, timeout=60):
    if op_path.startswith("http"):
        url = op_path
    else:
        op_id = op_path.rsplit("/", 1)[-1]
        url = f"https://apis.roblox.com/assets/v1/operations/{op_id}"
    deadline = time.time() + timeout
    while time.time() < deadline:
        req = urllib.request.Request(url, headers={"x-api-key": api_key})
        with urllib.request.urlopen(req) as resp:
            op = json.loads(resp.read().decode())
        if op.get("done"):
            return op
        time.sleep(2)
    raise TimeoutError(f"Operation {op_path} did not complete within {timeout}s")


def extract_asset_id(op):
    response = op.get("response") or {}
    return response.get("assetId") or response.get("path", "").rsplit("/", 1)[-1]


def patch_manifest(slot, asset_id):
    if not MANIFEST_PATH.exists():
        print(f"  WARN: manifest not found at {MANIFEST_PATH}")
        return
    content = MANIFEST_PATH.read_text()
    pattern = re.compile(rf'({slot}\s*=\s*)"rbxassetid://PROCESSING"')
    if not pattern.search(content):
        print(f"  SKIP: slot '{slot}' not a PROCESSING placeholder (already patched?)")
        return
    new_content = pattern.sub(rf'\1"rbxassetid://{asset_id}"', content)
    MANIFEST_PATH.write_text(new_content)
    print(f"  PATCHED: {slot} → rbxassetid://{asset_id}")


def run(dry_run):
    config = load_env()
    api_key = config.get("ROBLOX_OPEN_CLOUD_API_KEY", "")
    user_id = config.get("ROBLOX_USER_ID", "")
    if not api_key:
        print("ERROR: ROBLOX_OPEN_CLOUD_API_KEY missing in .env")
        sys.exit(1)
    if not user_id:
        print("ERROR: ROBLOX_USER_ID missing in .env")
        sys.exit(1)

    headers = {"x-api-key": api_key, "User-Agent": "COBLOX-AssetUploader/1.0"}

    for slot, (filename, display_name) in UPLOADS.items():
        file_path = PNG_DIR / filename
        if not file_path.exists():
            print(f"  SKIP: {slot} — file missing: {file_path}")
            continue
        if dry_run:
            print(f"[DRY-RUN] {slot} ← {filename}")
            continue

        content = MANIFEST_PATH.read_text() if MANIFEST_PATH.exists() else ""
        existing = re.search(rf'{slot}\s*=\s*"rbxassetid://(\d+)"', content)
        if existing:
            print(f"  SKIP-UPLOAD: {slot} already patched → rbxassetid://{existing.group(1)}")
            continue

        request_json = json.dumps(
            {
                "assetType": "Decal",
                "displayName": display_name,
                "description": f"COBLOX Fairytale Realm asset ({slot})",
                "creationContext": {"creator": {"userId": str(user_id)}},
            }
        )
        try:
            result = multipart_post(
                ASSETS_API, dict(headers), {"request": request_json}, file_path
            )
        except urllib.error.HTTPError as e:
            body = e.read().decode()
            print(f"  FAILED: {slot} — HTTP {e.code}: {body[:400]}")
            continue

        op_path = result.get("path") or result.get("operationId")
        if op_path:
            try:
                op = poll_operation(api_key, op_path)
            except TimeoutError as e:
                print(f"  FAILED: {slot} — {e}")
                continue
            asset_id = extract_asset_id(op)
        else:
            asset_id = result.get("assetId")

        if asset_id:
            print(f"  UPLOADED: {slot} → rbxassetid://{asset_id}")
            patch_manifest(slot, asset_id)
        else:
            print(f"  FAILED: {slot} — no assetId in response: {json.dumps(result)[:400]}")


def main():
    parser = argparse.ArgumentParser(description="COBLOX Fairytale Asset Uploader")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--upload", action="store_true")
    args = parser.parse_args()
    if args.upload:
        run(dry_run=False)
    else:
        run(dry_run=True)


if __name__ == "__main__":
    main()
