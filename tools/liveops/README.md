# COBLOX LiveOps Intelligence Platform

The LiveOps Intelligence Platform is an automated, GitHub Actions-driven ecosystem that periodically collects production evidence from Roblox Open Cloud, analyzes the data, and generates actionable intelligence reports.

## Architecture

The platform follows a strict separation of concerns, broken down into three stages orchestrated by GitHub Actions.

1. **Collect (`collect.py`)**: Fetches raw data from Roblox Open Cloud (Universe metadata, Place metadata, DataStore stats). Never mutates production state (Read-Only). Outputs `raw.json`.
2. **Analyze (`analyze.py`)**: Parses `raw.json` to calculate derived metrics (e.g. estimated CCU based on active sessions), detects anomalies, and assigns confidence scores. Outputs `metrics.json`.
3. **Report (`report.py`)**: Consumes `raw.json` and `metrics.json` to render a human-readable `report.md`, which is then published to the GitHub Job Summary.

## Execution Workflow

The pipeline is orchestrated via 3 GitHub Actions workflows, optimized for GitHub Free:
- `01_liveops_collect.yml` (Runs every 6 hours)
- `02_liveops_analyze.yml` (Triggered on completion of 01)
- `03_liveops_report.yml` (Triggered on completion of 02)

Artifacts (`raw.json`, `metrics.json`, `report.md`) are passed between workflows using the `gh run download` CLI and standard GitHub artifact uploads with a 7-day retention limit to preserve repository space.

## Setup Instructions

To enable the LiveOps platform, you must configure the following **Repository Secrets** in your GitHub repository:

* `ROBLOX_API_KEY`: An Open Cloud API Key with Read permissions to the game's Universe and DataStores.
* `ROBLOX_UNIVERSE_ID`: The Universe ID of the COBLOX experience.
* `ROBLOX_PLACE_ID`: The root Place ID.
* `ROBLOX_DATASTORE`: The target DataStore to monitor (default: `PlayerData_v1`).

### Graceful Degradation
If any of the secrets are missing, the pipeline will **not** crash. Instead, the missing integrations will silently degrade, marking the corresponding evidence as `UNKNOWN` or `PERMISSION_DENIED` in the final report. This ensures that whatever data can be gathered is still reported.

## Principles
- **Evidence-Driven**: No metrics are fabricated. If evidence cannot be collected, it is reported as `UNKNOWN`.
- **Read-Only Guarantee**: This platform will never run a POST/PUT/PATCH operation against the production economy or datastores.
- **Repository Hygiene**: Long-term historical data is strictly kept out of the `main` branch to prevent bloating the repository.
