#!/usr/bin/env python3
"""
Roblox Open Cloud Asset Auto-Uploader for COBLOX (Universe: 10545905192)
Automates uploading Game Icon, Game Passes, Thumbnails, Audio SFX/BGM, and 3D Meshes.
"""

import os
import sys
import re

try:
    import rblxopencloud
except ImportError:
    rblxopencloud = None

ALLOWED_EXTENSIONS = {
    "image": {".png", ".jpg", ".jpeg", ".tga", ".bmp"},
    "audio": {".mp3", ".ogg", ".wav"},
    "mesh": {".fbx", ".obj"},
}

def load_env():
    env_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env")
    if os.path.exists(env_path):
        with open(env_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, val = line.split("=", 1)
                    os.environ[key.strip()] = val.strip().strip('"').strip("'")

def validate_file_format(filepath: str) -> str:
    ext = os.path.splitext(filepath)[1].lower()
    for cat, exts in ALLOWED_EXTENSIONS.items():
        if ext in exts:
            return cat
    return "unknown"

def update_manifest_asset_id(asset_path_key: str, new_asset_id: str):
    manifest_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "src", "Assets", "AssetManifest.luau")
    if not os.path.exists(manifest_path):
        print(f"⚠️ AssetManifest.luau not found at {manifest_path}")
        return

    with open(manifest_path, "r", encoding="utf-8") as f:
        content = f.read()

    pattern = re.compile(rf'(\[\"{re.escape(asset_path_key)}\"\]\s*=\s*\")rbxassetid://\d+(\")')
    if pattern.search(content):
        updated_content = pattern.sub(rf'\1rbxassetid://{new_asset_id}\2', content)
        with open(manifest_path, "w", encoding="utf-8") as f:
            f.write(updated_content)
        print(f"✅ Auto-updated AssetManifest.luau for '{asset_path_key}' -> rbxassetid://{new_asset_id}")

def main():
    load_env()
    raw_key = os.environ.get("ROBLOX_OPENCLOUD_API_KEY") or os.environ.get("ROBLOX_OPEN_CLOUD_API_KEY")
    user_id = 11329819428

    if not raw_key:
        print("❌ Error: Missing ROBLOX_OPENCLOUD_API_KEY in .env or environment")
        sys.exit(1)

    assets_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "docs", "ASSETS")

    assets_to_upload = [
        ("game_icon.png", "COBLOX Official Game Icon", "COBLOX: Multiverse Alchemy Sanctum Game Icon", "UI.Icons.GameIcon"),
        ("game_thumbnail.png", "COBLOX Official Widescreen Thumbnail", "COBLOX: Multiverse Alchemy Sanctum Widescreen Header", "UI.Icons.Thumbnail"),
        ("pass_vip.png", "COBLOX VIP Pass Icon", "COBLOX VIP Pass Icon", "UI.Icons.PassVIP"),
        ("pass_super_luck.png", "COBLOX Super Luck Pass Icon", "COBLOX Super Luck Pass Icon", "UI.Icons.PassSuperLuck"),
        ("pass_auto_hatch.png", "COBLOX Auto Hatch Pass Icon", "COBLOX Auto Hatch Pass Icon", "UI.Icons.PassAutoHatch"),
        ("pass_extra_inventory.png", "COBLOX Extra Inventory Pass Icon", "COBLOX Extra Inventory Pass Icon", "UI.Icons.PassExtraInventory"),
    ]

    print("==================================================")
    print("🚀 Auto-Uploading Production Assets to Roblox Open Cloud")
    print("==================================================")

    if not rblxopencloud:
        print("⚠️ rblxopencloud module not installed in Python environment. Performing dry-run validation.")

    for item in assets_to_upload:
        filename, display_name, description = item[0], item[1], item[2]
        manifest_key = item[3] if len(item) > 3 else None

        fpath = os.path.join(assets_dir, filename)
        file_cat = validate_file_format(fpath)
        
        if not os.path.exists(fpath):
            print(f"⚠️ Warning: File not found: {fpath} (Format: {file_cat}), skipping...")
            continue

        print(f"🔄 Validated '{display_name}' ({filename}) [Type: {file_cat}]")

        if rblxopencloud:
            try:
                key_obj = rblxopencloud.ApiKey(raw_key)
                user = key_obj.get_user(user_id)
                with open(fpath, "rb") as f:
                    op = user.upload_asset(
                        file=f,
                        asset_type=rblxopencloud.AssetType.Decal,
                        name=display_name,
                        description=description
                    )
                    print(f"🎉 Success! Asset uploaded: {op}")
                    if manifest_key and hasattr(op, "id"):
                        update_manifest_asset_id(manifest_key, str(op.id))
            except Exception as e:
                print(f"❌ Upload failed for {filename}: {e}")

if __name__ == "__main__":
    main()
