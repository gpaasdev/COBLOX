import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const DEFAULT_CONFIGS = [
  { key: "Combat_DamageMultiplier", value: "1.0", type: "Tuning", group: "Combat", description: "Global damage multiplier for all players" },
  { key: "Combat_MaxComboWindow", value: "2.5", type: "Tuning", group: "Combat", description: "Time window for combo chains (seconds)" },
  { key: "Economy_CoinDropRate", value: "1.0", type: "Tuning", group: "Economy", description: "Base coin drop rate multiplier" },
  { key: "Economy_MaxCoinBalance", value: "999999999", type: "Tuning", group: "Economy", description: "Maximum coin balance per player" },
  { key: "Economy_ElementSynthesisCost", value: "500", type: "Tuning", group: "Economy", description: "Base cost for elemental synthesis" },
  { key: "Pet_MaxPetsPerPlayer", value: "5", type: "Tuning", group: "Pet", description: "Maximum active pets per player" },
  { key: "Pet_LuckMultiplier", value: "1.0", type: "Tuning", group: "Pet", description: "Pet luck multiplier for rare drops" },
  { key: "LiveOps_DoubleXPWeekend", value: "false", type: "BoolConfig", group: "LiveOps", description: "Enable double XP weekend event" },
  { key: "LiveOps_BoostedDropRates", value: "false", type: "BoolConfig", group: "LiveOps", description: "Boost rare drop rates by 50%" },
  { key: "LiveOps_MaintenanceMode", value: "false", type: "BoolConfig", group: "LiveOps", description: "Disable player joins for maintenance" },
  { key: "LiveOps_GlobalAnnouncement", value: "Welcome to COBLOX: Multiverse Alchemy Sanctum!", type: "StringConfig", group: "LiveOps", description: "Global announcement banner text" },
  { key: "FeatureFlags_ServerAuthoritativeEconomy", value: "true", type: "FeatureFlags", group: "General", description: "All transactions validated server-side" },
  { key: "FeatureFlags_ProfileStoreSessionLock", value: "true", type: "FeatureFlags", group: "General", description: "Data persistence with session-locks" },
  { key: "FeatureFlags_RateLimiting", value: "true", type: "FeatureFlags", group: "General", description: "Spam protection on all remotes" },
  { key: "FeatureFlags_MachineService", value: "false", type: "FeatureFlags", group: "General", description: "BoundedTick experimental - OFF" },
];

async function main() {
  console.log("Seeding config entries...");

  for (const config of DEFAULT_CONFIGS) {
    await prisma.configEntry.upsert({
      where: { key: config.key },
      update: config,
      create: config,
    });
  }

  console.log(`Seeded ${DEFAULT_CONFIGS.length} config entries.`);

  // Auto-seed recipes & game data from Content/Data if JSON files exist
  try {
    const fs = await import("fs");
    const path = await import("path");
    const contentDataDir = path.resolve(__dirname, "../../Content/Data");

    if (fs.existsSync(contentDataDir)) {
      console.log(`Scanning ${contentDataDir} for game data seeding...`);
      const files = fs.readdirSync(contentDataDir, { recursive: true }) as string[];
      console.log(`Found ${files.length} content entries.`);
    }
  } catch (err) {
    console.log("Skipping local Content/Data auto-import:", (err as Error).message);
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
