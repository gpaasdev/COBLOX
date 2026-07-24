#!/usr/bin/env python3
import os
import json
import requests

def load_env():
    env_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env")
    if os.path.exists(env_path):
        with open(env_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, val = line.split("=", 1)
                    os.environ[key.strip()] = val.strip().strip('"').strip("'")

load_env()
api_key = os.environ.get("ROBLOX_OPEN_CLOUD_API_KEY", "")
user_id = "11329819428" # hycoblox

url = "https://apis.roblox.com/assets/v1/assets"
headers = {
    "x-api-key": api_key
}

request_data = {
    "assetType": "Decal",
    "displayName": "COBLOX Super Luck Pass Icon",
    "description": "COBLOX GamePass Icon",
    "creationContext": {
        "creator": {
            "userId": user_id
        }
    }
}

file_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "docs", "ASSETS", "pass_super_luck.png")

with open(file_path, "rb") as f:
    files = {
        "request": (None, json.dumps(request_data), "application/json"),
        "fileContent": ("pass_super_luck.png", f, "image/png")
    }
    resp = requests.post(url, headers=headers, files=files)

print("Status Code:", resp.status_code)
print("Response Text:", resp.text)
