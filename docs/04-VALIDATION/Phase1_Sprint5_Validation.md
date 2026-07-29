# Phase 1 — Sprint 5 Validation Report

**Date**: 2026-07-28
**Status**: PASS — Ready for Client UI
**Schema Version**: 5
**Services Booted**: 46 (44 existing + 2 new)

---

## Runtime Status

| Check | Result |
|-------|--------|
| Rojo Build | PASS |
| Selene Lint | PASS (0 errors, 0 warnings) |
| Boot Failure | **FIXED** — ReactionRegistry:25 `pairs()` function-value bug |
| Service Boot | PASS — all 46 services resolve |

## Service Boot Matrix

| Tier | Service | Init | Start | Status |
|------|---------|------|-------|--------|
| 0 | RateLimitService | ✅ | ✅ | PASS |
| 0 | RemoteConfigService | ✅ | ✅ | PASS |
| 0 | ExperimentService | ✅ | ✅ | PASS |
| 0 | LiveOpsService | ✅ | ✅ | PASS |
| 0 | PolicyComplianceService | ✅ | ✅ | PASS |
| 0 | LaunchDataService | ✅ | ✅ | PASS |
| 1 | PlayerDataService | ✅ | ✅ | PASS |
| 1 | ProfileStoreAdapter | ✅ | ✅ | PASS |
| 1 | RetentionService | ✅ | ✅ | PASS |
| 1.5 | DailyLoginService | ✅ | ✅ | PASS |
| 1.5 | LeaderboardService | ✅ | ✅ | PASS |
| 1.5 | SocialSimulationService | ✅ | ✅ | PASS |
| 1.5 | PoliticalService | ✅ | ✅ | PASS |
| 1.5 | MacroEconomyService | ✅ | ✅ | PASS |
| 2 | StoryService | ✅ | ✅ | PASS |
| 2 | SanctumPassService | ✅ | ✅ | PASS |
| 2 | AdminService | ✅ | ✅ | PASS |
| 2 | CombatService | ✅ | ✅ | PASS |
| 2 | MobService | ✅ | ✅ | PASS |
| 2 | CovenService | ✅ | ✅ | PASS |
| 2 | ExpeditionService | ✅ | ✅ | PASS |
| 2 | QuestManager | ✅ | ✅ | PASS |
| 2 | OnboardingService | ✅ | ✅ | PASS |
| 2 | StoreService | ✅ | ✅ | PASS |
| 2 | WorldAssemblyService | ✅ | ✅ | PASS |
| 2.5 | DiscoveryService | ⏭️ | ⏭️ | BOOT_FLAGS=false |
| 2.5 | ReactionEngine | ⏭️ | ⏭️ | BOOT_FLAGS=false |
| 2.5 | MachineService | ⏭️ | ⏭️ | BOOT_FLAGS=false |
| 3 | AnalyticsService | ✅ | ✅ | PASS |
| 3 | MonetizationService | ✅ | ✅ | PASS |
| 3 | EconomyService | ✅ | ✅ | PASS |
| 3 | RecipeService | ✅ | ✅ | PASS |
| 3 | **PlacementService** | ✅ | ✅ | **PASS** (Phase 1) |
| 3 | PetService | ✅ | ✅ | PASS |
| 3 | EggService | ✅ | ✅ | PASS |
| 3 | **HatchService** | ✅ | ✅ | **PASS** (Phase 1 NEW) |
| 3 | **SetorAuraService** | ✅ | ✅ | **PASS** (Phase 1 NEW) |
| 3 | TycoonService | ✅ | ✅ | PASS |
| 3 | TradeService | ✅ | ✅ | PASS |
| 3 | PotionVaultService | ✅ | ✅ | PASS |
| 3 | OfflineEarningsService | ✅ | ✅ | PASS |
| 3 | GlobalBroadcastService | ✅ | ✅ | PASS |
| 3 | ShadowRaidService | ✅ | ✅ | PASS |
| 3.5 | AlchemyService | ⏭️ | ⏭️ | BOOT_FLAGS=false |
| 3.5 | ResourceService | ⏭️ | ⏭️ | BOOT_FLAGS=false |
| 3.5 | InteractionService | ⏭️ | ⏭️ | BOOT_FLAGS=false |
| 4 | CrystalPurificationService | ✅ | ✅ | PASS |
| 4 | ConsumableMutationService | ✅ | ✅ | PASS |
| 4 | KarmaContractService | ✅ | ✅ | PASS |
| 4 | FlexZoneService | ✅ | ✅ | PASS |
| 4+ | AnnouncementService | ✅ | ✅ | PASS |
| 4+ | CrossServerMessagingService | ✅ | ✅ | PASS |

## Schema Validation

| Check | Result |
|-------|--------|
| DataTypes.luau PlayerProfile | ✅ Fields match default profile |
| SanctumGridData.Cells type | **FIXED** — Changed from `{GridCell}` to `{[string]:GridCell}` |
| Default profile SchemaVersion | 5 |
| New fields optional (`?`) | ✅ SanctumGrid?, CovenMembership?, HatchCooldown?, TransportState? |
| v4→v5 migration | Implicit — nil fields default on first write |
| WalletData | ✅ 6 currencies unchanged |
| InventoryData | ✅ PityCounter, MaxPetStorage preserved |

## Gameplay Validation

### Placement System

| Check | Result |
|-------|--------|
| Grid snapping (3x3) | ✅ `SnappedX = math.round(X / 3) * 3` |
| Distance check (≤15 studs) | ✅ Server-authoritative |
| Grid collision | ✅ Dictionary-based, nil-check before insert |
| Structure registry | ✅ GridConfig.STRUCTURES validates |
| Structure limit | **FIXED** — Changed `#grid.Cells` to `pairs()` count for dict |
| Removal + 50% refund | **FIXED** — `AddCoins` → `AddCurrency` |
| AABB collision check | ✅ Workspace:GetPartBoundsInBox |
| Rate limiting | ✅ 0.5s placement, 1.0s removal |

### Hatch System

| Check | Result |
|-------|--------|
| Pity guarantee | **FIXED** — Moved before roll loop (was inside `pairs()`) |
| Rarity roll | ✅ Weighted cumulative probability |
| Currency deduction | **FIXED** — Result now checked before proceeding |
| Cooldown enforcement | ✅ Profile-based timestamp check |
| Inventory space | ✅ Pet count vs MaxPetStorage |
| LiveOps multiplier | ✅ Reads from LiveOpsConfig |
| Rate limiting | ✅ HatchConfig.HATCH_COOLDOWN (3s) |

### SetorAura Transport

| Check | Result |
|-------|--------|
| State machine | ✅ IDLE → TRANSPORTING → DEPOSITING → IDLE |
| Duplicate prevention | ✅ Rejects if not IDLE |
| Equipped pet check | ✅ Requires ≥1 equipped pet |
| Yield calculation | ✅ Base × (1 + pet contributions) |
| Player disconnect | **FIXED** — Guards in task.delay callbacks |
| Unused imports | **FIXED** — Removed HttpService, GridConfig |

### Economy Integration

| Check | Result |
|-------|--------|
| HasCurrency | ✅ New utility added to EconomyService |
| DeductCurrency | ✅ New utility with balance check |
| AddCurrency | ✅ Existing, used for refunds and transport |
| Currency duplication | No path found — deduction checked before creation |
| Negative balance | Impossible — DeductCurrency checks balance first |
| Ledger entries | ✅ DeductCurrency logs via SafeUpdateProfile |

## Persistence Validation

| Check | Result |
|-------|--------|
| New profile creation | ✅ All v5 fields populated in default |
| Existing v4 profile | ✅ New fields nil, nil-checked in all consumers |
| SanctumGrid nil | ✅ PlacementService creates default if nil |
| CovenMembership nil | ✅ CovenService nil-checks before access |
| HatchCooldown nil | ✅ HatchService nil-checks before timestamp compare |
| TransportState nil | ✅ SetorAuraService nil-checks before state compare |

## Performance Notes

| Metric | Value |
|--------|-------|
| Boot time | <6s (ProfileStore init is bottleneck) |
| Phase 1 hot loops | None — all event-driven |
| Rate limits | All Phase 1 remotes rate-limited |
| Memory allocations | No new per-frame allocations |

## Bugs Fixed During Validation

1. **CRITICAL** — `ReactionRegistry:25` boot crash: `pairs()` on generated registry yielded function values alongside data entries. Fixed with type-guard filter in ReactionRegistry.luau and MaterialRegistry.luau.

2. **HIGH** — `PlacementService.RemoveStructure` called non-existent `EconomyService.AddCoins`. Fixed to `AddCurrency`.

3. **HIGH** — `PlacementService` used `#grid.Cells` on dictionary type. Fixed to `pairs()` count.

4. **HIGH** — `HatchService.RollRarity` pity check was inside `pairs()` loop — guaranteed rarity only triggered if iterated first. Fixed: pity check moved before loop.

5. **MEDIUM** — `HatchService.HatchPod` ignored `DeductCurrency` result. Fixed: now checks and returns error on failure.

6. **MEDIUM** — `SetorAuraService` task.delay callbacks had no player disconnect guard. Fixed: `Players:FindFirstChild` check in both callbacks.

7. **LOW** — `SetorAuraService` imported unused `HttpService` and `GridConfig`. Removed.

8. **LOW** — `SanctumGridData.Cells` typed as array but used as dictionary. Fixed to `{[string]: GridCell}`.

## Known Issues

| Severity | Issue | Status |
|----------|-------|--------|
| Low | EggService has partial pity integration (pre-existing) | Deferred to Phase 2 |
| Low | Client UI controllers not yet wired (Phase 1 Sprint 3.2-3.3) | Pending client work |

## Technical Debt

- EggService and HatchService overlap — EggService should be deprecated or consolidated
- Collision check in PlacementService filters entire Workspace (could be scoped to Sanctum plot)

## Blocking Bugs

None.

## Readiness for Client UI

**PASS** — All exit criteria met:
- 0 critical runtime failures
- 0 persistence corruption paths
- 0 schema mismatches
- 0 service boot failures
- 0 currency exploits
- 0 placement exploits
- 0 blocking validation issues
