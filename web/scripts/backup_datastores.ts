import { PrismaClient } from "@prisma/client";

const DATASTORES = ["COBLOX_DataStore_LGBOS_v11"];
const UNIVERSE_ID = process.env.ROBLOX_UNIVERSE_ID ?? "10545905192";
const API_KEY = process.env.ROBLOX_OPEN_CLOUD_API_KEY ?? process.env.ROBLOX_API_KEY ?? "";

function getCredentials() {
  if (!UNIVERSE_ID || !API_KEY) {
    throw new Error("Missing Roblox Open Cloud credentials (ROBLOX_OPEN_CLOUD_API_KEY)");
  }
  return { universeId: UNIVERSE_ID, apiKey: API_KEY };
}

async function listEntryKeys(datastoreName: string, universeId: string, apiKey: string) {
  const keys: string[] = [];
  let cursor: string | undefined;
  do {
    const url = new URL(
      `https://apis.roblox.com/datastores/v1/universes/${universeId}/standard-datastores/datastore/entries`,
    );
    url.searchParams.set("datastoreName", datastoreName);
    url.searchParams.set("limit", "100");
    if (cursor) url.searchParams.set("cursor", cursor);

    const res = await fetch(url, { headers: { "x-api-key": apiKey } });
    if (!res.ok) {
      throw new Error(`List entries failed (${res.status}): ${await res.text()}`);
    }
    const data = (await res.json()) as {
      keys?: { key: string }[];
      nextPageCursor?: string;
    };
    for (const k of data.keys ?? []) keys.push(k.key);
    cursor = data.nextPageCursor;
  } while (cursor);
  return keys;
}

async function readEntry(datastoreName: string, entryKey: string, universeId: string, apiKey: string) {
  const url = new URL(
    `https://apis.roblox.com/datastores/v1/universes/${universeId}/standard-datastores/datastore/entries/entry`,
  );
  url.searchParams.set("datastoreName", datastoreName);
  url.searchParams.set("scope", "global");
  url.searchParams.set("entryKey", entryKey);

  const res = await fetch(url, { headers: { "x-api-key": apiKey } });
  if (!res.ok) {
    if (res.status === 404) return null;
    throw new Error(`Read entry failed (${res.status}): ${await res.text()}`);
  }
  const body = (await res.json()) as { version?: string; [key: string]: unknown };
  const { version, ...payload } = body;
  return { version: version ?? "", payload: JSON.stringify(payload) };
}

async function main() {
  const { universeId, apiKey } = getCredentials();
  const prisma = new PrismaClient();
  const results: { datastore: string; key: string; status: string }[] = [];
  let total = 0;

  try {
    console.log(`🚀 Backing up DataStores to Neon (universe ${universeId})...`);
    for (const datastoreName of DATASTORES) {
      const keys = await listEntryKeys(datastoreName, universeId, apiKey);
      for (const entryKey of keys) {
        const entry = await readEntry(datastoreName, entryKey, universeId, apiKey);
        if (!entry) {
          results.push({ datastore: datastoreName, key: entryKey, status: "skipped-404" });
          continue;
        }
        await prisma.dataStoreSnapshot.upsert({
          where: {
            datastoreName_entryKey_scope: {
              datastoreName,
              entryKey,
              scope: "global",
            },
          },
          update: { payload: entry.payload, version: entry.version },
          create: {
            datastoreName,
            entryKey,
            scope: "global",
            payload: entry.payload,
            version: entry.version,
          },
        });
        total++;
        results.push({ datastore: datastoreName, key: entryKey, status: "upserted" });
      }
    }
    console.log(`✅ Upserted ${total} DataStore snapshots into Neon.`);
    for (const r of results) console.log(`  ${r.status.padEnd(12)} ${r.datastore}/${r.key}`);
  } finally {
    await prisma.$disconnect();
  }
}

main().catch((error) => {
  console.error("❌ DataStore backup failed:", error);
  process.exit(1);
});
