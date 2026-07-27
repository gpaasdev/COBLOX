[🏠 Master Index](../../docs/MASTER_INDEX.md)

# COBLOX System Architecture Reference (v11.0 Master Directive)

## Overview
COBLOX is a data-driven, server-authoritative Roblox platform utilizing zero-trust architecture, immutable registry snapshots, and Open Cloud API v2 integration.

## Key Architectures
1. **Repository & Provider Layer**: Web UI consumes `ContentRepository` abstraction, isolating presentation from network protocols.
2. **Immutable Registry Snapshots**: Content in `content/` generates immutable snapshots stored in `registry/snapshots/` and versioned by `latest.json`.
3. **FTUE Enum State Machine**: Onboarding progresses through explicit enum states (`WELCOME` -> `COMPLETE`).
4. **OpenCloudClient**: Single Python abstraction for all Open Cloud v2 operations (`packages/opencloud/client.py`).
