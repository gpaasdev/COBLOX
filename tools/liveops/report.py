#!/usr/bin/env python3
import json
import os
import sys

def generate_markdown_report(raw_data: dict, metrics: dict) -> str:
    timestamp = raw_data.get("timestamp", "UNKNOWN")
    anomalies = metrics.get("anomalies_detected", [])
    
    md = [
        f"# COBLOX Daily Intelligence Report",
        f"**Date/Time:** {timestamp}",
        f"",
        f"## Executive Summary",
    ]
    
    if anomalies:
        md.append("⚠️ **Anomalies Detected:**")
        for a in anomalies:
            md.append(f"- {a}")
    else:
        md.append("✅ No critical anomalies detected in this observation window.")
        
    md.extend([
        "",
        "## Derived Metrics",
        f"- **Estimated CCU (Playing):** {metrics.get('estimated_ccu', 'UNKNOWN')}",
        f"- **Total Visits:** {metrics.get('total_visits', 'UNKNOWN')}",
        f"- **DataStore Entries Sampled:** {metrics.get('entries_sampled', 'UNKNOWN')}",
        "",
        "## Production Confidence",
        "| Dimension | Status |",
        "| :--- | :--- |"
    ])
    
    confidence_data = metrics.get("confidence", {})
    for dim, score in confidence_data.items():
        md.append(f"| {dim} | **{score}** |")
        
    md.extend([
        "",
        "## Missing Evidence",
    ])
    
    collection_status = raw_data.get("collection_status", {})
    missing_found = False
    for source, status in collection_status.items():
        if status in ["UNKNOWN", "NOT_AVAILABLE", "PERMISSION_DENIED"]:
            md.append(f"- **{source}**: {status}")
            missing_found = True
            
    if not missing_found:
        md.append("All requested evidence sources were successfully collected.")
        
    md.extend([
        "",
        "## Recommendations",
        "- **Next Observation Window**: Continue 6-hour polling schedule.",
    ])
    
    if "UNKNOWN" in confidence_data.values() or "LOW" in confidence_data.values():
        md.append("- **Action**: Prioritize engineering efforts on collecting evidence for dimensions marked UNKNOWN or LOW before building new features.")
    
    return "\n".join(md)

def main():
    if not os.path.exists("raw.json") or not os.path.exists("metrics.json"):
        print("[ERROR] Missing raw.json or metrics.json. Cannot generate report.", file=sys.stderr)
        sys.exit(1)
        
    with open("raw.json", "r", encoding="utf-8") as f:
        raw_data = json.load(f)
    
    with open("metrics.json", "r", encoding="utf-8") as f:
        metrics = json.load(f)
        
    report_content = generate_markdown_report(raw_data, metrics)
    
    with open("report.md", "w", encoding="utf-8") as f:
        f.write(report_content)
        
    print("[INFO] Generated report.md successfully.")
    
if __name__ == "__main__":
    main()
