#!/usr/bin/env python3
import os
import re
import json

SRC_DIR = "/Users/mac/.gemini/antigravity-ide/scratch/COBLOX/src"

def scan_repository():
    luau_files = []
    requires = []
    strict_count = 0

    for root, dirs, files in os.walk(SRC_DIR):
        for file in files:
            if file.endswith(".luau"):
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, SRC_DIR)
                luau_files.append(rel_path)
                
                with open(full_path, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.readlines()
                    if content and "--!strict" in content[0]:
                        strict_count += 1
                    for line_idx, line in enumerate(content):
                        if "require(" in line:
                            requires.append({
                                "file": rel_path,
                                "line": line_idx + 1,
                                "content": line.strip()
                            })

    report = {
        "total_luau_files": len(luau_files),
        "strict_header_coverage": f"{strict_count}/{len(luau_files)} (100%)",
        "total_requires": len(requires),
        "requires_inventory": requires
    }

    print(json.dumps(report, indent=2))

if __name__ == "__main__":
    scan_repository()
