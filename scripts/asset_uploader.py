#!/usr/bin/env python3
"""
COBLOX Asset Uploader — replaces rbxassetid://PROCESSING / PENDING_UPLOAD
placeholders via Roblox Open Cloud Assets API.

Usage:
    python3 scripts/asset_uploader.py --dry-run
    python3 scripts/asset_uploader.py --upload

Requires env: ROBLOX_OPEN_CLOUD_API_KEY
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path

API_BASE = "https://apis.roblox.com/cloud/v2"

ASSET_DIR = Path(__file__).resolve().parent.parent / "src" / "Assets"

FAIRYTALE_PLACEHOLDERS = {
    "SkyboxTwilight": {"file": None, "type": "Decal"},
    "FloatingIslandLarge": {"file": None, "type": "MeshPart"},
    "EnchantedTree": {"file": None, "type": "MeshPart"},
    "BioluminescentMushroom": {"file": None, "type": "MeshPart"},
    "CrystalNodeAether": {"file": None, "type": "MeshPart"},
    "AncientPortalArch": {"file": None, "type": "MeshPart"},
    "GenesisPodCommon": {"file": None, "type": "MeshPart"},
    "GenesisPodLegendary": {"file": None, "type": "MeshPart"},
    "AetherCrystalMesh": {"file": None, "type": "MeshPart"},
    "ManaBloom": {"file": None, "type": "MeshPart"},
    "SpiritFoxMesh": {"file": None, "type": "MeshPart"},
    "CrystalGolemMesh": {"file": None, "type": "MeshPart"},
    "PixieSwarm": {"file": None, "type": "MeshPart"},
    "FairyDragon": {"file": None, "type": "MeshPart"},
    "WingsAether": {"file": None, "type": "MeshPart"},
    "FairyCrown": {"file": None, "type": "MeshPart"},
    "EnchantedRobe": {"file": None, "type": "MeshPart"},
}

PBR_PLACEHOLDERS = {
    "PolyHavenSteel/ColorMap": "PENDING_UPLOAD",
    "PolyHavenSteel/NormalMap": "PENDING_UPLOAD",
    "PolyHavenSteel/RoughnessMap": "PENDING_UPLOAD",
    "PolyHavenSteel/MetalnessMap": "PENDING_UPLOAD",
    "PolyHavenMarble/ColorMap": "PENDING_UPLOAD",
    "PolyHavenMarble/NormalMap": "PENDING_UPLOAD",
    "PolyHavenMarble/RoughnessMap": "PENDING_UPLOAD",
}


def get_api_key():
    key = os.environ.get("ROBLOX_OPEN_CLOUD_API_KEY")
    if not key:
        print("ERROR: ROBLOX_OPEN_CLOUD_API_KEY not set")
        sys.exit(1)
    return key


def upload_asset(api_key, file_path, name, asset_type, dry_run=False):
    if dry_run:
        print(f"[DRY-RUN] Would upload {file_path} as {name} ({asset_type})")
        return f"rbxassetid://PLACEHOLDER_{name}"

    if not file_path or not Path(file_path).exists():
        print(f"  SKIP: {name} — no file at {file_path}")
        return None

    url = f"{API_BASE}/assets/v1"
    headers = {"x-api-key": api_key}

    import requests

    with open(file_path, "rb") as f:
        files = {"file": (Path(file_path).name, f, "image/png")}
        data = {"name": name, "assetType": asset_type}
        resp = requests.post(url, headers=headers, data=data, files=files)

    if resp.status_code == 200:
        result = resp.json()
        asset_id = result.get("assetId")
        print(f"  UPLOADED: {name} → rbxassetid://{asset_id}")
        return f"rbxassetid://{asset_id}"
    else:
        print(f"  FAILED: {name} — {resp.status_code}: {resp.text}")
        return None


def patch_luau_file(filepath, placeholder_re, asset_id):
    content = filepath.read_text()
    new_content = re.sub(placeholder_re, asset_id, content)
    if new_content != content:
        filepath.write_text(new_content)
        print(f"  PATCHED: {filepath.name}")
        return True
    return False


def run_dry_run():
    print("=== DRY RUN — Placeholders to replace ===")
    print(f"\nAssetManifestFairytale.luau ({len(FAIRTALE_PLACEHOLDERS)} placeholders):")
    for name, info in FAIRYTALE_PLACEHOLDERS.items():
        status = "NEEDS FILE" if info["file"] is None else f"FILE: {info['file']}"
        print(f"  {name} ({info['type']}) — {status}")

    print(f"\nAssetManifest.luau PBR ({len(PBR_PLACEHOLDERS)} placeholders):")
    for path, val in PBR_PLACEHOLDERS.items():
        print(f"  {path} — {val}")

    print("\nUpload commands to run with --upload:")
    print("  python3 scripts/asset_uploader.py --upload")


def run_upload():
    api_key = get_api_key()
    manifest_path = ASSET_DIR / "AssetManifestFairytale.luau"
    manifest_main_path = ASSET_DIR / "AssetManifest.luau"

    print("=== UPLOADING ASSETS ===")

    for name, info in FAIRYTALE_PLACEHOLDERS.items():
        aid = upload_asset(api_key, info["file"], f"COBLOX_{name}", info["type"])
        if aid:
            pattern = rf'["\']{name}["\']\s*=\s*"rbxassetid://PROCESSING"'
            replacement = f'"{name}" = "{aid}"'
            patch_luau_file(manifest_path, pattern, replacement)

    print("\n=== PBR Materials (manual upload required) ===")
    print("PBR textures need manual Creator Dashboard upload or asset_pipeline_3d.py")


def main():
    parser = argparse.ArgumentParser(description="COBLOX Asset Uploader")
    parser.add_argument("--dry-run", action="store_true", help="Show what would be uploaded")
    parser.add_argument("--upload", action="store_true", help="Upload assets and patch manifests")
    args = parser.parse_args()

    if args.dry_run:
        run_dry_run()
    elif args.upload:
        run_upload()
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
