#!/usr/bin/env python3
import urllib.request
import urllib.error

base_key = "g2yo3NyNxkS3x+GVgbIc48JKZ/Y45oQcViuntjwxJfnuC4A8"
universe_id = "10545905192"

url = f"https://apis.roblox.com/datastores/v1/universes/{universe_id}/standard-datastores"
req = urllib.request.Request(url, headers={"x-api-key": base_key})

try:
    with urllib.request.urlopen(req) as resp:
        print(f"✅ Success HTTP {resp.status}:", resp.read().decode('utf-8'))
except urllib.error.HTTPError as e:
    print(f"❌ HTTP {e.code}:", e.read().decode('utf-8'))
