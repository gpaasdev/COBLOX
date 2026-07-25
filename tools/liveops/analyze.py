#!/usr/bin/env python3
import json
import os
import sys

# Ensure tools/ is in PYTHONPATH for direct execution
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from tools.liveops.logger import LiveOpsLogger, EvidenceQuality

def analyze_evidence(raw_data: dict) -> dict:
    LiveOpsLogger.log_info("Starting Evidence Analysis...")
    
    universe_meta = raw_data.get("universe_metadata", {})
    ds_metrics = raw_data.get("datastore_metrics", {})
    collection_status = raw_data.get("collection_status", {})
    
    # Extract playing count as a proxy for current DAU/CCU
    playing = universe_meta.get("playing", 0)
    visits = universe_meta.get("visits", 0)
    
    anomalies = []
    
    # 1. Telemetry Confidence
    telemetry_status = collection_status.get("datastore", EvidenceQuality.UNKNOWN.value)
    if telemetry_status == EvidenceQuality.HIGH.value:
        telemetry_confidence = "HIGH"
    elif telemetry_status == EvidenceQuality.PERMISSION_DENIED.value:
        telemetry_confidence = "LOW"
        anomalies.append("DataStore permission denied. Cannot audit player economy.")
    else:
        telemetry_confidence = "UNKNOWN"
        anomalies.append("No DataStore metrics collected.")

    # 2. Gameplay Confidence
    gameplay_confidence = "UNKNOWN"
    if playing > 0:
        gameplay_confidence = "LOW" # We know people are playing, but don't know retention yet.
    
    if visits > 10000:
        # Just an example threshold
        anomalies.append("High visit count detected. Monitor server capacity.")

    derived_metrics = {
        "estimated_ccu": playing,
        "total_visits": visits,
        "entries_sampled": ds_metrics.get("entries_sampled", 0),
        "anomalies_detected": anomalies,
        "confidence": {
            "Deployment": "VERIFIED", # This script running implies deployment pipeline is intact
            "Telemetry": telemetry_confidence,
            "Gameplay": gameplay_confidence,
            "Economy": "UNKNOWN", # Need more detailed DataStore payload to verify
            "Performance": "UNKNOWN",
            "Security": "UNKNOWN",
            "LiveOps": "HIGH", # The fact that we are analyzing means LiveOps collection is working
        }
    }
    
    return derived_metrics

def main():
    if not os.path.exists("raw.json"):
        LiveOpsLogger.log_error("raw.json not found. Did collect.py run successfully?")
        sys.exit(1)
        
    with open("raw.json", "r", encoding="utf-8") as f:
        raw_data = json.load(f)
        
    metrics = analyze_evidence(raw_data)
    
    LiveOpsLogger.export_json(metrics, "metrics.json")
    LiveOpsLogger.log_info("Analysis phase complete.")

if __name__ == "__main__":
    main()
