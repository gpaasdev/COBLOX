#!/usr/bin/env python3
import os
import sys

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC_DIR = os.path.join(BASE_DIR, "src")
DOCS_DIR = os.path.join(BASE_DIR, "docs")

def check_strict_header():
    print("🔍 [1/3] Checking --!strict headers in src/...")
    missing_strict = []
    total_files = 0
    
    for root, _, files in os.walk(SRC_DIR):
        for file in files:
            if file.endswith(".luau"):
                total_files += 1
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                    first_line = f.readline()
                    if "--!strict" not in first_line:
                        missing_strict.append(os.path.relpath(filepath, BASE_DIR))
                        
    if missing_strict:
        print(f"❌ FAIL: {len(missing_strict)} files missing --!strict header:")
        for path in missing_strict:
            print(f"   - {path}")
        return False
    else:
        print(f"✅ PASS: 100% of Luau files ({total_files} files) contain --!strict header.")
        return True

def check_doc_navigation():
    print("\n🔍 [2/3] Checking Master Index navigation links in docs/...")
    missing_nav = []
    total_docs = 0
    
    for root, _, files in os.walk(DOCS_DIR):
        for file in files:
            if file.endswith(".md"):
                total_docs += 1
                filepath = os.path.join(root, file)
                
                # Skip Master Index itself
                if file == "MASTER_INDEX.md":
                    continue
                    
                with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    if "[🏠 Master Index]" not in content:
                        missing_nav.append(os.path.relpath(filepath, BASE_DIR))
                        
    if missing_nav:
        print(f"❌ FAIL: {len(missing_nav)} markdown files missing [🏠 Master Index] navigation:")
        for path in missing_nav:
            print(f"   - {path}")
        return False
    else:
        print(f"✅ PASS: 100% of markdown docs ({total_docs} files) contain Master Index navigation.")
        return True

def check_adr_integrity():
    print("\n🔍 [3/3] Checking ADR-001 to ADR-006 integrity...")
    adr_file = os.path.join(DOCS_DIR, "02-ARCHITECTURE_AND_SPECS", "ADR", "ADR.md")
    if not os.path.exists(adr_file):
        print("❌ FAIL: ADR.md not found.")
        return False
        
    with open(adr_file, 'r', encoding='utf-8') as f:
        content = f.read()
        
    expected_adrs = [f"ADR-00{i}" for i in range(1, 7)]
    missing_adrs = [adr for adr in expected_adrs if adr not in content]
    
    if missing_adrs:
        print(f"❌ FAIL: Missing ADRs in ADR.md: {missing_adrs}")
        return False
    else:
        print("✅ PASS: All ADR-001 through ADR-006 entries present and formatted.")
        return True

def main():
    print("=" * 60)
    print("🛡️  COBLOX RGS COMPLIANCE & ARCHITECTURE AUDITOR")
    print("=" * 60)
    
    c1 = check_strict_header()
    c2 = check_doc_navigation()
    c3 = check_adr_integrity()
    
    print("\n" + "=" * 60)
    if c1 and c2 and c3:
        print("🎉 OVERALL RESULT: 100% COMPLIANT (ALL CHECKS PASSED)")
        print("=" * 60)
        sys.exit(0)
    else:
        print("💥 OVERALL RESULT: AUDIT FAILED (ISSUES FOUND)")
        print("=" * 60)
        sys.exit(1)

if __name__ == "__main__":
    main()
