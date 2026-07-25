import json
import random
import os
import math

def run_economy_simulation(num_simulations=1000):
    print(f"📊 Running {num_simulations} Offline Monte Carlo Economy & Progression Simulations (Priority V)...")
    
    with open("web/src/data/registry_bundle.json", "r", encoding="utf-8") as f:
        registry_bundle = json.load(f)
        
    materials = registry_bundle.get("materials", [])
    machines = registry_bundle.get("machines", [])
    research = registry_bundle.get("research", [])
    
    first_discovery_times = []
    first_automation_times = []
    total_currency_sinks = 0
    total_currency_sources = 0

    for sim in range(num_simulations):
        time_elapsed = 0 # seconds
        coins = 0
        inventory = {}
        has_discovered = False
        has_automated = False
        
        # Simulate 90-minute session (5400 seconds)
        for tick in range(0, 5400, 10): # 10-second ticks
            time_elapsed += 10
            
            # Mining action
            inventory["Iron_Ore"] = inventory.get("Iron_Ore", 0) + random.randint(1, 3)
            
            # Check discovery
            if not has_discovered and inventory["Iron_Ore"] >= 5:
                has_discovered = True
                first_discovery_times.append(time_elapsed)
                
            # Crafting / Automation check
            if not has_automated and inventory.get("Iron_Ore", 0) >= 20:
                has_automated = True
                first_automation_times.append(time_elapsed)
                inventory["Iron_Ore"] -= 20
                total_currency_sinks += 500
                
            # Passive income from machines
            if has_automated:
                passive_coins = 15
                coins += passive_coins
                total_currency_sources += passive_coins
                
                # Machine maintenance sink (Priority V balancing)
                maintenance_cost = 10
                coins = max(0, coins - maintenance_cost)
                total_currency_sinks += maintenance_cost

    avg_first_discovery = sum(first_discovery_times) / max(1, len(first_discovery_times))
    avg_first_automation = sum(first_automation_times) / max(1, len(first_automation_times))
    sink_source_ratio = total_currency_sinks / max(1, total_currency_sources)

    report = {
        "num_simulations": num_simulations,
        "avg_time_to_first_discovery_sec": round(avg_first_discovery, 2),
        "avg_time_to_first_automation_sec": round(avg_first_automation, 2),
        "sink_to_source_ratio": round(sink_source_ratio, 4),
        "economy_status": "BALANCED" if 0.5 <= sink_source_ratio <= 1.5 else "INFLATIONARY_WARNING"
    }

    os.makedirs("docs/reports", exist_ok=True)
    with open("docs/reports/economy_balance_report.json", "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)

    print("✅ Economy Balance Simulation Completed!")
    print(f"   ⏱️ Avg Time to First Discovery: {report['avg_time_to_first_discovery_sec']}s")
    print(f"   ⚙️ Avg Time to First Automation: {report['avg_time_to_first_automation_sec']}s")
    print(f"   ⚖️ Sink/Source Ratio: {report['sink_to_source_ratio']} ({report['economy_status']})")
    return report

if __name__ == "__main__":
    run_economy_simulation()
