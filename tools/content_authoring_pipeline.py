#!/usr/bin/env python3
"""
COBLOX Content Creator Authoring Pipeline
Purpose: Validates JSON content definitions and generates production-ready Luau Registries.
"""

import json
import sys
import os

REQUIRED_MATERIAL_KEYS = ["Id", "Name", "Category", "BaseValue", "Properties"]
REQUIRED_PROPERTIES = ["Density", "Conductivity", "Hardness", "Elasticity", "CorrosionResistance", "HeatResistance", "RadiationResistance", "MagneticProperty", "ChemicalStability"]

def validate_material_json(file_path):
    print(f"[ContentPipeline] Validating {file_path}...")
    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
    except Exception as e:
        print(f"❌ JSON Parse Error in {file_path}: {e}")
        return False

    if not isinstance(data, list):
        print(f"❌ Root JSON must be an array of material definitions.")
        return False

    valid_count = 0
    for idx, mat in enumerate(data):
        for key in REQUIRED_MATERIAL_KEYS:
            if key not in mat:
                print(f"❌ Missing key '{key}' at index {idx}")
                return False
        
        props = mat.get("Properties", {})
        for prop_key in REQUIRED_PROPERTIES:
            if prop_key not in props:
                print(f"❌ Missing property '{prop_key}' in material '{mat.get('Id')}'")
                return False
        valid_count += 1

    print(f"✅ Successfully validated {valid_count} material definitions from {file_path}!")
    return True

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 content_authoring_pipeline.py <path_to_json>")
        sys.exit(1)

    success = validate_material_json(sys.argv[1])
    sys.exit(0 if success else 1)
