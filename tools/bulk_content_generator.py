import os
import json

BASE_PATH = "Content/Data"

def generate_bulk_content():
    print("🚀 Starting Bulk Content Scale Generation (Priority M)...")
    
    # 1. Materials (≥100)
    os.makedirs(f"{BASE_PATH}/Materials", exist_ok=True)
    elements = ["Iron", "Copper", "Gold", "Titanium", "Aether", "Void", "Obsidian", "Mythril", "Adamantite", "Quantum"]
    tiers = ["Ore", "Refined", "Alloy", "Crystal", "Matrix", "Dust", "Essence", "Singularity", "Shard", "Vapor"]
    
    mat_count = 0
    for elem in elements:
        for tier in tiers:
            mat_id = f"{elem}_{tier}"
            data = {
                "Id": mat_id,
                "Name": f"{elem} {tier}",
                "Density": round(1000 + (mat_count * 75.5), 2),
                "Conductivity": round(10 + (mat_count * 1.5), 2),
                "Value": 10 + (mat_count * 25)
            }
            with open(f"{BASE_PATH}/Materials/{mat_id}.json", "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2)
            mat_count += 1
    print(f"✅ Generated {mat_count} Materials.")

    # 2. Machines (≥60)
    os.makedirs(f"{BASE_PATH}/Machines", exist_ok=True)
    m_types = ["Reactor", "Smelter", "Cooler", "Turbine", "Synthesizer", "Refinery"]
    mach_count = 0
    for mt in m_types:
        for v in range(1, 11):
            mach_id = f"{mt}_v{v}"
            data = {
                "Id": mach_id,
                "Name": f"Industrial {mt} Mark {v}",
                "PowerConsumption": 100 * v,
                "MaxTemperature": 500 + (v * 250)
            }
            with open(f"{BASE_PATH}/Machines/{mach_id}.json", "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2)
            mach_count += 1
    print(f"✅ Generated {mach_count} Machines.")

    # 3. Research Nodes (≥150)
    os.makedirs(f"{BASE_PATH}/Research", exist_ok=True)
    res_count = 0
    categories = ["Engineering", "Thermodynamics", "VoidScience", "Automation", "QuantumPhysics"]
    for cat in categories:
        for idx in range(1, 31):
            res_id = f"Tech_{cat}_{idx}"
            data = {
                "Id": res_id,
                "Name": f"{cat} Specialization Level {idx}",
                "RequiredDiscoveries": ["Iron_Ore"],
                "Cost": 100 * idx
            }
            with open(f"{BASE_PATH}/Research/{res_id}.json", "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2)
            res_count += 1
    print(f"✅ Generated {res_count} Research Nodes.")

    # 4. Biomes (≥40)
    os.makedirs(f"{BASE_PATH}/Biomes", exist_ok=True)
    biome_types = ["Volcanic", "Subterranean", "Glacial", "Toxic", "Void", "Aether", "Celestial", "Abyssal"]
    biome_count = 0
    for btype in biome_types:
        for sec in range(1, 6):
            b_id = f"Biome_{btype}_{sec}"
            data = {
                "Id": b_id,
                "Name": f"{btype} Wastes Sector {sec}",
                "Temperature": round(200.0 + (sec * 50.0), 1)
            }
            with open(f"{BASE_PATH}/Biomes/{b_id}.json", "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2)
            biome_count += 1
    print(f"✅ Generated {biome_count} Biomes.")

    # 5. Creatures (≥80)
    os.makedirs(f"{BASE_PATH}/Creatures", exist_ok=True)
    c_types = ["Beast", "Golem", "Wisp", "Abomination", "Guardian", "Parasite", "Construct", "Dragon"]
    c_count = 0
    for ct in c_types:
        for lvl in range(1, 11):
            c_id = f"Creature_{ct}_Lvl{lvl}"
            data = {
                "Id": c_id,
                "Name": f"{ct} Elite Grade {lvl}",
                "Health": 100 * (lvl ** 2)
            }
            with open(f"{BASE_PATH}/Creatures/{c_id}.json", "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2)
            c_count += 1
    print(f"✅ Generated {c_count} Creatures.")

    print("🎉 Bulk Content Generation Completed Successfully!")

if __name__ == "__main__":
    generate_bulk_content()
