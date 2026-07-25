from dataclasses import dataclass, field
from typing import Dict, Any, List
from .logger import EvidenceQuality

@dataclass
class RawEvidence:
    """Represents the raw data collected from production."""
    timestamp: str
    universe_metadata: Dict[str, Any] = field(default_factory=dict)
    datastore_metrics: Dict[str, Any] = field(default_factory=dict)
    github_metadata: Dict[str, Any] = field(default_factory=dict)
    collection_status: Dict[str, EvidenceQuality] = field(default_factory=dict)

@dataclass
class ConfidenceDimension:
    score: EvidenceQuality
    reasoning: str

@dataclass
class DerivedMetrics:
    """Represents the calculated metrics based on raw evidence."""
    estimated_dau: str = "UNKNOWN"
    total_players_tracked: int = 0
    anomalies_detected: List[str] = field(default_factory=list)
    confidence: Dict[str, str] = field(default_factory=dict)

@dataclass
class IntelligenceReport:
    """The final report structure."""
    date: str
    raw_evidence_summary: str
    metrics: DerivedMetrics
    recommendations: List[str]
    missing_evidence: List[str]
