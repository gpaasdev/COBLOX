#!/usr/bin/env python3
"""
Sync GameLocalization.luau keys to Roblox Cloud Localization Table.

Usage:
  export ROBLOX_OPEN_CLOUD_API_KEY=your_key_here
  python3 scripts/sync_localization.py

Dry-run (no API calls):
  python3 scripts/sync_localization.py
"""
import os, sys, re, json, urllib.request, urllib.error

API_KEY = os.environ.get("ROBLOX_OPEN_CLOUD_API_KEY", "")
UNIVERSE_ID = os.environ.get("ROBLOX_UNIVERSE_ID", "10545905192")
LOC_FILE = os.path.join(os.path.dirname(__file__), "..", "src", "Shared", "Localization", "GameLocalization.luau")

BASE = "https://apis.roblox.com"


def req(method, url, data=None):
    h = {"x-api-key": API_KEY, "Content-Type": "application/json"}
    b = json.dumps(data).encode() if data else None
    r = urllib.request.Request(url, data=b, headers=h, method=method)
    try:
        with urllib.request.urlopen(r) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        body = e.read().decode()
        print(f"  HTTP {e.code}: {body}")
        return None


def parse_luau_dict(content):
    locales, current_locale = {}, None
    for line in content.split("\n"):
        m = re.match(r'\s*\["([a-z-]+)"\]\s*=\s*\{', line)
        if m:
            current_locale = m.group(1)
            locales[current_locale] = {}
            continue
        if current_locale:
            m2 = re.match(r'\s*\["(\w+)"\]\s*=\s*"(.+)"', line)
            if m2:
                k, v = m2.group(1), m2.group(2).replace('\\"', '"').replace('%%', '%')
                locales[current_locale][k] = v
    return locales


def get_table_id():
    if not API_KEY:
        return None
    url = f"{BASE}/legacy-localization-tables/v1/autolocalization/games/{UNIVERSE_ID}/autolocalizationtable"
    r = req("POST", url)
    if r:
        tid = r.get("autoLocalizationTableId")
        print(f"  Table ID: {tid}")
        return tid
    return None


def push_entries(table_id, entries):
    chunk_size = 50
    items = sorted(entries.items())
    url = f"{BASE}/legacy-localization-tables/v1/localization-table/tables/{table_id}?gameId={UNIVERSE_ID}"
    total_ok, total_fail = 0, 0
    for i in range(0, len(items), chunk_size):
        chunk = items[i:i + chunk_size]
        payload = {
            "entries": [{
                "identifier": k,
                "translations": json.dumps({"id": v}),
            } for k, v in chunk]
        }
        print(f"  Chunk {i // chunk_size + 1}/{(len(items) + chunk_size - 1) // chunk_size} ({len(chunk)} entries)...")
        r = req("PATCH", url, payload)
        if r:
            failed = r.get("failedEntriesAndTranslations", [])
            mod = r.get("modifiedEntriesAndTranslations", [])
            total_ok += len(mod)
            total_fail += len(failed)
            for f in failed:
                print(f"    FAIL: {f.get('identifier')}: {f.get('error')}")
        else:
            print(f"    FAILED chunk")
            total_fail += len(chunk)
    print(f"  Total: {total_ok} OK, {total_fail} failed")
    return total_fail == 0


def enable_manual_table():
    """Switch from auto-localization to manual localization table mode."""
    url = f"{BASE}/legacy-localization-tables/v1/autolocalization/games/{UNIVERSE_ID}/settings"
    payload = {
        "isAutolocalizationEnabled": False,
        "isAutomaticEntriesSettingEnabled": False,
        "isAutomaticEntriesDeletionsEnabled": False,
        "shouldUseLocalizationTable": True,
    }
    r = req("PATCH", url, payload)
    if r is not None:
        print("  ✅ Switched to manual localization table mode")
        return True
    print("  ⚠️  Could not switch to manual mode (may already be set)")
    return False


def main():
    if not os.path.exists(LOC_FILE):
        print(f"❌ File not found: {LOC_FILE}")
        sys.exit(1)
    with open(LOC_FILE) as f:
        content = f.read()
    locales = parse_luau_dict(content)
    source = locales.get("id-id", {})
    print(f"📖 Read {len(source)} keys from id-id (source language)")
    if not API_KEY:
        print("\n⚠️  ROBLOX_OPEN_CLOUD_API_KEY not set — dry-run mode")
        print("   Set it with: export ROBLOX_OPEN_CLOUD_API_KEY=your_key")
        print(f"\n   Would push {len(source)} keys to Universe {UNIVERSE_ID}")
        for k in sorted(source.keys()):
            print(f"     {k:45s} = {source[k][:60]}")
        return
    enable_manual_table()
    table_id = get_table_id()
    if not table_id:
        print("❌ Could not get localization table ID")
        sys.exit(1)
    ok = push_entries(table_id, source)
    if ok:
        print(f"\n✅ Synced {len(source)} keys to Cloud Localization Table {table_id}")
    else:
        print(f"\n❌ Some entries failed to sync")


if __name__ == "__main__":
    main()
