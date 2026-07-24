#!/usr/bin/env python3
import json
import urllib.request
import urllib.error

place_ids = ["10545905192", "105075159736246"]

for pid in place_ids:
    url = f"https://apis.roblox.com/universes/v1/places/{pid}/universe"
    try:
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode('utf-8'))
            print(f"Place ID {pid} -> Universe ID: {data.get('universeId')}")
    except Exception as e:
        print(f"Place ID {pid} query error: {e}")
