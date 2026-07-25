import os

class Config:
    """
    LiveOps Intelligence Platform Configuration.
    Loads secrets securely and provides graceful degradation flags.
    Never hardcodes secrets.
    """
    ROBLOX_API_KEY = os.environ.get("ROBLOX_OPEN_CLOUD_API_KEY", "")
    ROBLOX_UNIVERSE_ID = os.environ.get("ROBLOX_UNIVERSE_ID", "")
    ROBLOX_PLACE_ID = os.environ.get("ROBLOX_PLACE_ID", "")
    ROBLOX_DATASTORE = os.environ.get("ROBLOX_DATASTORE", "PlayerData_v1")
    OPEN_CLOUD_ENDPOINT = os.environ.get("OPEN_CLOUD_ENDPOINT", "https://apis.roblox.com/cloud/v2")
    
    # Optional integrations
    DISCORD_WEBHOOK = os.environ.get("DISCORD_WEBHOOK", "")
    
    @classmethod
    def can_collect_roblox(cls) -> bool:
        return bool(cls.ROBLOX_API_KEY and cls.ROBLOX_UNIVERSE_ID)
    
    @classmethod
    def print_status(cls):
        print("--- LiveOps Configuration Status ---")
        print(f"Roblox Integration: {'READY' if cls.can_collect_roblox() else 'MISSING SECRETS'}")
        print(f"Discord Webhook: {'READY' if cls.DISCORD_WEBHOOK else 'NOT CONFIGURED'}")
        print("------------------------------------")
