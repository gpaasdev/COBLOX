#!/usr/bin/env python3
"""
Create missing COBLOX badges via Roblox Badges API.

Usage:
  export ROBLOX_ACCESS_TOKEN=your_oauth_token_here
  python3 scripts/create_badges.py

  # Dry-run: check quota and list what would be created
  python3 scripts/create_badges.py --dry-run

Auth: This script requires OAuth 2.0 (Bearer token) with legacy-universe:manage scope.
Get a token at: https://create.roblox.com/dashboard/credentials
"""
import os, sys, json, urllib.request, urllib.error, urllib.parse, uuid, io

TOKEN = os.environ.get("ROBLOX_ACCESS_TOKEN", "")
COOKIE = os.environ.get("ROBLOSECURITY", "")
UNIVERSE_ID = os.environ.get("ROBLOX_UNIVERSE_ID", "10545905192")
DRY_RUN = "--dry-run" in sys.argv

BADGES = [
    {"key": "BDG_MONSTER_SLAYER", "name": "Monster Slayer", "desc": "Defeat 100 monsters"},
    {"key": "BDG_SHADOW_VETERAN", "name": "Shadow Veteran", "desc": "Win 50 Shadow Raids"},
    {"key": "BDG_RESEARCHER", "name": "Researcher", "desc": "Unlock 20 Codex entries"},
    {"key": "BDG_VETERAN", "name": "Veteran", "desc": "Play for 100 hours"},
    {"key": "BDG_MASTER_SMITH", "name": "Master Smith", "desc": "Smelt 1000 ores"},
    {"key": "BDG_QUANTUM_MASTER", "name": "Quantum Master", "desc": "Reach Rebirth level 10"},
    {"key": "BDG_LEGENDARY_HATCH", "name": "Legendary Hatcher", "desc": "Hatch 10 Legendary pets"},
    {"key": "BDG_MULTIVERSE_TRAVELER", "name": "Multiverse Traveler", "desc": "Visit all realms"},
]


XSRF_TOKEN = None


def req(method, url, data=None, form=False, files=None):
    global XSRF_TOKEN
    h = {}
    if TOKEN:
        h["Authorization"] = f"Bearer {TOKEN}"
    elif COOKIE:
        h["Cookie"] = f".ROBLOSECURITY={COOKIE}"
    if XSRF_TOKEN:
        h["x-csrf-token"] = XSRF_TOKEN
    b = None
    if files:
        boundary = str(uuid.uuid4())
        h["Content-Type"] = f"multipart/form-data; boundary={boundary}"
        parts = []
        if data:
            for k, v in data.items():
                parts.append(f'--{boundary}\r\nContent-Disposition: form-data; name="{k}"\r\n\r\n{v}\r\n'.encode())
        for field_name, (filename, file_data, content_type) in files.items():
            parts.append(f'--{boundary}\r\nContent-Disposition: form-data; name="{field_name}"; filename="{filename}"\r\nContent-Type: {content_type}\r\n\r\n'.encode())
            parts.append(file_data)
            parts.append(b'\r\n')
        parts.append(f'--{boundary}--\r\n'.encode())
        b = b''.join(parts)
    elif form:
        h["Content-Type"] = "application/x-www-form-urlencoded"
        b = urllib.parse.urlencode(data).encode()
    elif data is not None:
        h["Content-Type"] = "application/json"
        b = json.dumps(data).encode()
    r = urllib.request.Request(url, data=b, headers=h, method=method)
    try:
        with urllib.request.urlopen(r) as resp:
            body = resp.read()
            xsrf = resp.headers.get("x-csrf-token")
            if xsrf:
                XSRF_TOKEN = xsrf
            return json.loads(body) if body else {}
    except urllib.error.HTTPError as e:
        body = e.read().decode()
        xsrf = e.headers.get("x-csrf-token")
        if xsrf and not XSRF_TOKEN:
            XSRF_TOKEN = xsrf
            print(f"  Got XSRF token, retrying...")
            return req(method, url, data, form, files)
        print(f"  HTTP {e.code}: {body[:300]}")
        return None


def main():
    if not TOKEN and not COOKIE:
        print("⚠️  ROBLOX_ACCESS_TOKEN or ROBLOSECURITY not set")
        print("   Get a token at: https://create.roblox.com/dashboard/credentials")
        print("   Or use: export ROBLOSECURITY=.ROBLOSECURITY_cookie_value\n")

    BASE = "https://badges.roblox.com"

    # Check quota
    quota_url = f"{BASE}/v1/universes/{UNIVERSE_ID}/free-badges-quota"
    if TOKEN or COOKIE:
        quota = req("GET", quota_url)
        if quota is not None:
            print(f"📊 Free badge quota remaining: {quota}")
        else:
            print("⚠️  Could not check quota — auth might be invalid")
    else:
        print("📊 Free badge quota: ? (set ROBLOX_ACCESS_TOKEN or ROBLOSECURITY to check)")

    print(f"\n📋 Badges to create: {len(BADGES)}")
    for b in BADGES:
        print(f"   {b['key']:40s} {b['name']:25s} {b['desc']}")

    if DRY_RUN or not (TOKEN or COOKIE):
        print("\n💡 Set ROBLOX_ACCESS_TOKEN or ROBLOSECURITY and remove --dry-run to execute")
        return

    # Check existing badges
    existing_url = f"{BASE}/v1/universes/{UNIVERSE_ID}/badges?limit=100"
    existing = req("GET", existing_url)
    existing_names = set()
    if existing:
        for badge in existing.get("data", []):
            existing_names.add(badge["name"])
        print(f"\n📋 Found {len(existing_names)} existing badges")

    # Create badges
    icon_path = os.environ.get("BADGE_ICON", "/tmp/badge_icon.png")
    if not os.path.exists(icon_path):
        print(f"⚠️  Badge icon not found at {icon_path}, generating placeholder...")
        import struct, zlib
        def create_png(w, h, r, g, b):
            def chunk(ctype, data):
                c = ctype + data
                return struct.pack('>I', len(data)) + c + struct.pack('>I', zlib.crc32(c) & 0xffffffff)
            ihdr = struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0)
            raw = b''
            for y in range(h):
                raw += b'\x00' + bytes([r, g, b]) * w
            idat = zlib.compress(raw)
            return b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', ihdr) + chunk(b'IDAT', idat) + chunk(b'IEND', b'')
        with open(icon_path, 'wb') as f:
            f.write(create_png(512, 512, 255, 215, 0))
        print(f"   Created {icon_path}")

    with open(icon_path, 'rb') as f:
        icon_data = f.read()

    created = 0
    for b in BADGES:
        if b["name"] in existing_names:
            print(f"⏭️  {b['key']} — already exists")
            continue
        create_url = f"{BASE}/v1/universes/{UNIVERSE_ID}/badges"
        form_data = {
            "name": b["name"],
            "description": b["desc"],
            "isActive": "true",
        }
        files_data = {
            "files": (f"{b['key']}.png", icon_data, "image/png"),
        }
        print(f"🔨 Creating {b['key']} ({b['name']})...")
        result = req("POST", create_url, form_data, files=files_data)
        if result and result.get("id"):
            print(f"   ✅ Created! Badge ID: {result['id']}")
            created += 1
        else:
            print(f"   ❌ Failed: {result}")

    print(f"\n✅ Done. Created {created} badges today.")
    print("   Update BadgeService.luau BADGE_IDS with the new IDs printed above.")


if __name__ == "__main__":
    main()
