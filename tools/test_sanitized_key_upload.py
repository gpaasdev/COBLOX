#!/usr/bin/env python3
import rblxopencloud

clean_key = "/N/G1bhX3kW+qyMlpVgyNM7WB5Nhj/X0s6+gSio4NZXKwX7d"
print(f"Testing clean_key: {clean_key} (length {len(clean_key)})")

key_obj = rblxopencloud.ApiKey(clean_key)
user = key_obj.get_user(11329819428)

try:
    with open("docs/ASSETS/pass_super_luck.png", "rb") as f:
        operation = user.upload_asset(
            file=f,
            asset_type=rblxopencloud.AssetType.Decal,
            name="COBLOX Super Luck Pass Icon",
            description="COBLOX GamePass Icon"
        )
        print("✅ Asset upload response:", operation)
except Exception as e:
    print("❌ Upload failed:", e)
