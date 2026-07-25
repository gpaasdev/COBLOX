from enum import Enum
import json
import sys

class EvidenceQuality(str, Enum):
    UNKNOWN = "UNKNOWN"
    ESTIMATE = "ESTIMATE"
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    VERIFIED = "VERIFIED"
    NOT_AVAILABLE = "NOT_AVAILABLE"
    PERMISSION_DENIED = "PERMISSION_DENIED"

class LiveOpsLogger:
    @staticmethod
    def log_info(message: str):
        print(f"[INFO] {message}")
        
    @staticmethod
    def log_warning(message: str):
        print(f"[WARNING] {message}", file=sys.stderr)
        
    @staticmethod
    def log_error(message: str):
        print(f"[ERROR] {message}", file=sys.stderr)
        
    @staticmethod
    def log_evidence(metric_name: str, value: any, quality: EvidenceQuality):
        print(f"[EVIDENCE] {metric_name} = {value} (Quality: {quality.value})")

    @staticmethod
    def export_json(data: dict, filepath: str):
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2)
            print(f"[INFO] Successfully exported data to {filepath}")
        except Exception as e:
            print(f"[ERROR] Failed to write {filepath}: {e}", file=sys.stderr)
