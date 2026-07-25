#!/usr/bin/env python3
import urllib.request
import urllib.error
import json
import datetime
import os
import sys

# Ensure tools/ is in PYTHONPATH for direct execution
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from tools.liveops.config import Config
from tools.liveops.logger import LiveOpsLogger, EvidenceQuality
from tools.liveops.models import RawEvidence

def collect_universe_metadata(evidence: RawEvidence):
    if not Config.can_collect_roblox():
        evidence.collection_status["universe"] = EvidenceQuality.NOT_AVAILABLE
        LiveOpsLogger.log_warning("Roblox integration missing. Skipping Universe metadata collection.")
        return

    url = f"https://games.roblox.com/v1/games?universeIds={Config.ROBLOX_UNIVERSE_ID}"
    try:
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            if data and "data" in data and len(data["data"]) > 0:
                evidence.universe_metadata = data["data"][0]
                evidence.collection_status["universe"] = EvidenceQuality.HIGH
            else:
                evidence.collection_status["universe"] = EvidenceQuality.LOW
    except urllib.error.HTTPError as e:
        evidence.collection_status["universe"] = EvidenceQuality.UNKNOWN
        LiveOpsLogger.log_error(f"Failed to fetch Universe metadata: {e.code} {e.reason}")
    except Exception as e:
        evidence.collection_status["universe"] = EvidenceQuality.UNKNOWN
        LiveOpsLogger.log_error(f"Error fetching Universe metadata: {e}")

def collect_datastore_metrics(evidence: RawEvidence):
    if not Config.can_collect_roblox():
        evidence.collection_status["datastore"] = EvidenceQuality.NOT_AVAILABLE
        return

    url = f"https://apis.roblox.com/cloud/v2/universes/{Config.ROBLOX_UNIVERSE_ID}/data-stores/{Config.ROBLOX_DATASTORE}/entries?maxPageSize=10"
    try:
        req = urllib.request.Request(url)
        req.add_header("x-api-key", Config.ROBLOX_API_KEY)
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            # For privacy/security, we do not store the actual PII/player data.
            # We only store the count of entries retrieved to prove datastore is accessible.
            evidence.datastore_metrics["entries_sampled"] = len(data.get("datastoreEntries", []))
            evidence.datastore_metrics["has_next_page"] = bool(data.get("nextPageToken"))
            evidence.collection_status["datastore"] = EvidenceQuality.HIGH
    except urllib.error.HTTPError as e:
        if e.code == 403 or e.code == 401:
            evidence.collection_status["datastore"] = EvidenceQuality.PERMISSION_DENIED
        else:
            evidence.collection_status["datastore"] = EvidenceQuality.UNKNOWN
        LiveOpsLogger.log_error(f"Failed to fetch DataStore metrics: {e.code} {e.reason}")
    except Exception as e:
        evidence.collection_status["datastore"] = EvidenceQuality.UNKNOWN
        LiveOpsLogger.log_error(f"Error fetching DataStore metrics: {e}")

def main():
    Config.print_status()
    
    timestamp = datetime.datetime.now(datetime.timezone.utc).isoformat().replace("+00:00", "Z")
    evidence = RawEvidence(timestamp=timestamp)
    
    LiveOpsLogger.log_info("Starting Evidence Collection...")
    collect_universe_metadata(evidence)
    collect_datastore_metrics(evidence)
    
    # Dump to raw.json
    output_data = {
        "timestamp": evidence.timestamp,
        "universe_metadata": evidence.universe_metadata,
        "datastore_metrics": evidence.datastore_metrics,
        "collection_status": {k: v.value for k, v in evidence.collection_status.items()}
    }
    
    LiveOpsLogger.export_json(output_data, "raw.json")
    LiveOpsLogger.log_info("Collection phase complete.")

if __name__ == "__main__":
    main()
