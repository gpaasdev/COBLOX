#!/usr/bin/env python3
import urllib.request
import urllib.parse
import urllib.error

key = "/N/G1bhX3kW+qyMlpVgyNM7WB5Nhj/X0s6+gSio4NZXKwX7d"
universe_id = "10545905192"

# DataStore API v1 listing requires datastoreName parameter or list endpoint
url = f"https://apis.roblox.com/datastores/v1/universes/{universe_id}/standard-datastores?prefix=COBLOX"

req = urllib.request.Request(url, headers={"x-api-key": key})
try:
    with urllib.request.urlopen(req) as resp:
        print("✅ DataStores List Success HTTP", resp.status, ":", resp.read().decode())
except urllib.error.HTTPError as e:
    print("❌ HTTP Error", e.code, ":", e.read().decode())
