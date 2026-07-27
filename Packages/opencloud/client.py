#!/usr/bin/env python3
"""
packages/opencloud/client.py
Single Reusable OpenCloudClient Abstraction for Roblox Open Cloud API v2.
"""

import os
import sys
import json
import urllib.request
import urllib.parse
from typing import Dict, Any, Optional

class OpenCloudClient:
    def __init__(self, api_key: Optional[str] = None, universe_id: Optional[str] = None, place_id: Optional[str] = None):
        self.api_key = api_key or os.environ.get("ROBLOX_OPEN_CLOUD_API_KEY") or os.environ.get("ROBLOX_OPENCLOUD_API_KEY")
        self.universe_id = universe_id or os.environ.get("ROBLOX_UNIVERSE_ID")
        self.place_id = place_id or os.environ.get("ROBLOX_PLACE_ID")

        if not self.api_key:
            raise ValueError("ROBLOX_OPEN_CLOUD_API_KEY environment variable missing.")

    def _headers(self, content_type: str = "application/json") -> Dict[str, str]:
        headers = {"x-api-key": self.api_key}
        if content_type:
            headers["content-type"] = content_type
        return headers

    def publish_place(self, file_path: str, version_type: str = "Published") -> Dict[str, Any]:
        """Publish place .rbxl using Open Cloud v1 universes endpoint.
        
        NOTE: The v2 :publish endpoint is only available for cloud-native places.
        The v1 universes/v1 endpoint is the standard way to publish .rbxl binaries.
        """
        if not self.universe_id or not self.place_id:
            raise ValueError("universe_id and place_id are required for place publishing.")
        
        url = f"https://apis.roblox.com/universes/v1/{self.universe_id}/places/{self.place_id}/versions?versionType={version_type}"
        with open(file_path, "rb") as f:
            data = f.read()

        req = urllib.request.Request(url, method="POST", data=data, headers=self._headers("application/octet-stream"))
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode())

    def read_datastore_entry(self, datastore: str, key: str, scope: str = "global") -> Dict[str, Any]:
        """Read DataStore entry via Open Cloud v2."""
        ds_enc = urllib.parse.quote(datastore, safe="")
        key_enc = urllib.parse.quote(key, safe="")
        url = f"https://apis.roblox.com/cloud/v2/universes/{self.universe_id}/data-stores/{ds_enc}/scopes/{scope}/entries/{key_enc}"

        req = urllib.request.Request(url, method="GET", headers=self._headers())
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read().decode())

    def write_datastore_entry(self, datastore: str, key: str, value: Dict[str, Any], scope: str = "global") -> Dict[str, Any]:
        """Write DataStore entry via Open Cloud v2 PATCH."""
        ds_enc = urllib.parse.quote(datastore, safe="")
        key_enc = urllib.parse.quote(key, safe="")
        url = f"https://apis.roblox.com/cloud/v2/universes/{self.universe_id}/data-stores/{ds_enc}/scopes/{scope}/entries/{key_enc}"
        
        payload = json.dumps({"value": value}).encode()
        req = urllib.request.Request(url, method="PATCH", data=payload, headers=self._headers())
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read().decode())

    def publish_message(self, topic: str, message: Dict[str, Any]) -> Dict[str, Any]:
        """Publish cross-server Message via Open Cloud v2."""
        url = f"https://apis.roblox.com/cloud/v2/universes/{self.universe_id}/messages:publish"
        payload = json.dumps({"topic": topic, "message": json.dumps(message)}).encode()
        req = urllib.request.Request(url, method="POST", data=payload, headers=self._headers())
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read().decode())

    def ban_player(self, user_id: str, reason: str, duration_sec: Optional[int] = None) -> Dict[str, Any]:
        """Apply user restriction / ban via Open Cloud v2."""
        url = f"https://apis.roblox.com/cloud/v2/universes/{self.universe_id}/user-restrictions/{user_id}"
        payload_data: Dict[str, Any] = {
            "gameJoinRestriction": {
                "active": True,
                "privateReason": reason,
                "displayReason": "Pelanggaran aturan COBLOX.",
                "excludeAltAccounts": True,
            }
        }
        if duration_sec:
            payload_data["gameJoinRestriction"]["duration"] = f"{duration_sec}s"
            
        payload = json.dumps(payload_data).encode()
        req = urllib.request.Request(url, method="PATCH", data=payload, headers=self._headers())
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read().decode())

if __name__ == "__main__":
    print("✅ OpenCloudClient module initialized.")
