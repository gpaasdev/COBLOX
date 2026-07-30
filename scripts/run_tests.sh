#!/bin/bash
# COBLOX Test Runner
# Runs all .spec.luau files under src/

set -e

SPEC_FILES=$(find src -name "*.spec.luau" -type f 2>/dev/null || echo "")
SPEC_COUNT=$(echo "$SPEC_FILES" | grep -c . || echo 0)

echo "========================================"
echo " COBLOX Test Runner"
echo " Found $SPEC_COUNT spec files"
echo "========================================"

if [ "$SPEC_COUNT" -eq 0 ]; then
    echo "No spec files found."
    exit 0
fi

echo ""
echo "$SPEC_FILES"
echo ""

# Run each spec via lune if available, otherwise validate syntax
if command -v lune &> /dev/null; then
    echo "=== Running tests via Lune ==="
    FAILED=0
    while IFS= read -r spec; do
        echo "  Testing: $spec"
        if ! lune run "$spec" 2>&1; then
            echo "  FAILED: $spec"
            FAILED=$((FAILED + 1))
        fi
    done <<< "$SPEC_FILES"
    if [ "$FAILED" -gt 0 ]; then
        echo "❌ $FAILED test(s) failed"
        exit 1
    fi
    echo "✅ All tests passed"
else
    echo "Lune not installed. Skipping test execution."
    echo "Install with: aftman add lune"
fi

# Validate spec file syntax via luau-lsp
if command -v luau-lsp &> /dev/null; then
    echo ""
    echo "=== Syntax checking spec files ==="
    while IFS= read -r spec; do
        luau-lsp check --mode=strict "$spec" 2>&1 || true
    done <<< "$SPEC_FILES"
fi
