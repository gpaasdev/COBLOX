#!/usr/bin/env python3
import os
import rblxopencloud

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
raw_key = os.environ.get("ROBLOX_OPEN_CLOUD_API_KEY", "")
prefix_key = raw_key[:48] if len(raw_key) >= 48 else raw_key
user_id = 11329819428

print(f"Full Key Length: {len(raw_key)}")
print(f"Extracted 48-char Prefix Key: {prefix_key}")

file_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "docs", "ASSETS", "pass_super_luck.png")

for label, key_val in [("48-char Prefix Key", prefix_key), ("Full Key", raw_key)]:
    print(f"\n--- Testing Asset Upload with [{label}] ---")
    try:
        key_obj = rblxopencloud.ApiKey(key_val)
        user = key_obj.get_user(user_id)
        with open(file_path, "rb") as f:
            operation = user.upload_asset(
                file=f,
                asset_type=rblxopencloud.AssetType.Decal,
                name="COBLOX Super Luck Pass Icon",
                description="COBLOX GamePass Icon"
            )
            print("✅ Asset Operation Response:", operation)
    except rblxopencloud.Forbidden as e:
        print("❌ Forbidden (Permissions Issue):", e)
    except rblxopencloud.RateLimited as e:
        print("❌ RateLimited:", e)
    except rblxopencloud.HttpException as e:
        print(f"❌ HttpException {e.status_code}:", e)
    except Exception as e:
        print("❌ SDK Error:", e)
