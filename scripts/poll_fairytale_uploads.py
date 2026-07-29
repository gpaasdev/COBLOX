#!/usr/bin/env python3
"""Poll Fairytale asset upload operations and update manifest when ready."""
import json, os, requests, time, sys

API_KEY = os.environ.get("ROBLOX_OPEN_CLOUD_API_KEY")
MANIFEST = os.path.join(os.path.dirname(__file__), "..", "src", "Assets", "AssetManifestFairytale.luau")

OPS = {
    "Environment": {
        "SkyboxTwilight": "67245774-4e5e-4e16-8b06-43783f2ef5b1",
        "FloatingIslandLarge": "aba15ed5-296e-4d4d-953d-ecc05155945e",
        "EnchantedTree": "594f63dc-e910-4fb2-91fe-906954882a0d",
        "BioluminescentMushroom": "5c68bbe1-63af-4b73-aac3-5f20af31cc98",
        "CrystalNodeAether": "393e8989-3cd1-4951-a27e-adc25af25a45",
        "AncientPortalArch": "2b5f1620-ad04-48d5-b8f6-84d96d4d59e9",
    },
    "Items": {
        "GenesisPodCommon": "be5e29a5-bcf5-4ba1-bf87-e3ab8840735f",
        "GenesisPodLegendary": "8dc25314-942f-4099-b6d3-a4319080d5e8",
        "AetherCrystalMesh": "2ee3483d-5895-42d6-8cf7-b405bb443f9e",
        "ManaBloom": "25897311-1af2-4c99-a07b-342d5cd70e36",
    },
    "Entities": {
        "SpiritFoxMesh": "7ea2c978-5191-4123-b742-12f0b2736538",
        "CrystalGolemMesh": "a9e7d7db-ce4c-464b-978f-bf6171b40c80",
        "PixieSwarm": "2493386b-729f-492d-a6ac-e0b1287ab3ba",
        "FairyDragon": "7df0ff13-e9eb-4ff4-bd7f-fd9e3a279abb",
    },
    "Cosmetics": {
        "WingsAether": "cce57867-a233-462f-86ab-6aa262c41047",
        "FairyCrown": "b93fa550-1cb0-432c-92be-638ef22c03ca",
        "EnchantedRobe": "8e8f88cb-4449-4508-b9b2-67c5f577c9bd",
    },
}

def poll():
    updated = False
    for category, items in OPS.items():
        for name, op_id in items.items():
            resp = requests.get(f"https://apis.roblox.com/assets/v1/operations/{op_id}", headers={"x-api-key": API_KEY})
            data = resp.json()
            if data.get("done"):
                aid = data.get("response", {}).get("assetId")
                if aid:
                    print(f"✅ {name}: rbxassetid://{aid}")
                    OPS[category][name] = f"rbxassetid://{aid}"
                    updated = True
                else:
                    print(f"⚠️ {name}: done but no assetId")
            else:
                print(f"⏳ {name}: still processing")
    
    if updated:
        update_manifest()
        print("\n🔄 Manifest updated. Run build + publish when ready.")
    else:
        print(f"\n⏳ All pending. Check again later.")

def update_manifest():
    with open(MANIFEST, "r") as f:
        content = f.read()
    for category, items in OPS.items():
        for name, value in items.items():
            if value.startswith("rbxassetid://"):
                old = f'{name} = "rbxassetid://PROCESSING"'
                new = f'{name} = "{value}"'
                if old in content:
                    content = content.replace(old, new)
    with open(MANIFEST, "w") as f:
        f.write(content)

if __name__ == "__main__":
    poll()
    if "--watch" in sys.argv:
        while True:
            time.sleep(30)
            poll()
