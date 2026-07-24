#!/usr/bin/env python3
"""
COBLOX Open Cloud Player Notification Dispatcher
================================================
Utility script to send push notifications for player re-engagement via Roblox Open Cloud API.
"""

import os
import json
import urllib.request
import urllib.error

ROBLOX_API_KEY = os.environ.get("ROBLOX_API_KEY", "")
UNIVERSE_ID = os.environ.get("ROBLOX_UNIVERSE_ID", "")

def send_player_notification(user_id, title, message):
    if not ROBLOX_API_KEY or not UNIVERSE_ID:
        print("[NotificationsManager] WARNING: ROBLOX_API_KEY or ROBLOX_UNIVERSE_ID not set.")
        return False

    url = f"https://apis.roblox.com/cloud/v2/universes/{UNIVERSE_ID}/notifications"
    payload = {
        "userId": user_id,
        "title": title,
        "message": message,
    }

    req = urllib.request.Request(url, data=json.dumps(payload).encode("utf-8"), headers={
        "x-api-key": ROBLOX_API_KEY,
        "Content-Type": "application/json"
    }, method="POST")

    try:
        with urllib.request.urlopen(req) as response:
            print(f"[NotificationsManager] Notification sent successfully to UserId {user_id}")
            return True
    except urllib.error.HTTPError as e:
        print(f"[NotificationsManager] HTTP Error {e.code}: {e.reason}")
    except Exception as e:
        print(f"[NotificationsManager] Error sending notification: {e}")

    return False

if __name__ == "__main__":
    print("--- COBLOX Open Cloud Notification Dispatcher ---")
    send_player_notification(12345678, "Sanctum Rewards!", "Your daily alchemical rewards are ready to collect.")
