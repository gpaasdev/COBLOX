#!/usr/bin/env python3
"""
scripts/import_open_assets.py
Open Source & CC0 3D Asset Import Manager for COBLOX: Multiverse Alchemy Sanctum
Organizes Kenney.nl, Synty, and Open Source 3D Assets into src/Assets/ for Rojo syncing.
"""

import os
import sys

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS_DIR = os.path.join(BASE_DIR, "src", "Assets")

SUBDIRECTORIES = [
    "Models/Nature",
    "Models/Altars",
    "Models/Mounts",
    "Models/Machines",
    "Textures/Environment",
    "Textures/UI",
    "Audio/SFX",
]

def initialize_asset_structure():
    print("==================================================")
    print("📦 COBLOX Open Source Asset Structure Initializer")
    print("==================================================")
    
    for sub in SUBDIRECTORIES:
        target_path = os.path.join(ASSETS_DIR, sub)
        os.makedirs(target_path, exist_ok=True)
        init_file = os.path.join(target_path, ".gitkeep")
        if not os.path.exists(init_file):
            with open(init_file, "w") as f:
                f.write("# Asset directory placeholder\n")
        print(f"  [OK] Initialized: {target_path}")

    print("\n✅ Asset structure initialized successfully under src/Assets/")

if __name__ == "__main__":
    initialize_asset_structure()
