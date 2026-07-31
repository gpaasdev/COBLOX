import { writeFileSync, readFileSync, existsSync } from "fs";
import { resolve } from "path";
import { PrismaClient } from "@prisma/client";

/**
 * Sync Monetization — pull live GamePass + DevProduct pricing from
 * Roblox Open Cloud Economy v2 APIs into web/src/data/registry/market.json
 * and upsert Prisma MarketAsset rows when DATABASE_URL is configured.
 *
 * Usage: npx tsx scripts/sync_monetization.ts
 * Env:  ROBLOX_OPEN_CLOUD_API_KEY, ROBLOX_UNIVERSE_ID (optional DATABASE_URL)
 */

const API_KEY = process.env.ROBLOX_OPEN_CLOUD_API_KEY;
const UNIVERSE_ID = process.env.ROBLOX_UNIVERSE_ID || "10545905192";
const PLACE_ID = process.env.ROBLOX_PLACE_ID || "105075159736246";
const REGISTRY_PATH = resolve(__dirname, "../src/data/registry/market.json");

interface EconomyItem {
  id: number;
  name: string;
  description: string;
  price: number | null;
  isForSale: boolean;
  category: "Gamepass" | "Developer Product";
  imageUrl: string;
}

function normalizeName(name: string): string {
  return name
    .toLowerCase()
    .replace(/[^\w\s]/g, "")
    .replace(/\s+/g, " ")
    .trim();
}

function slugify(name: string): string {
  return normalizeName(name).replace(/\s+/g, "-").replace(/-+/g, "-").replace(/^-+|-+$/g, "");
}

function priceOf(item: { priceInformation?: { defaultPriceInRobux?: number | null } | null }): number | null {
  return item.priceInformation?.defaultPriceInRobux ?? null;
}

async function fetchAll<T>(path: string, field: string, pageSize = 100): Promise<T[]> {
  const items: T[] = [];
  let pageToken: string | null = null;

  for (let i = 0; i < 10; i++) {
    const url = new URL(path);
    url.searchParams.set("page_size", String(pageSize));
    if (pageToken) url.searchParams.set("page_token", pageToken);

    const apiKey = API_KEY ?? "";
    const res = await fetch(url.toString(), {
      headers: { "x-api-key": apiKey, Accept: "application/json" },
    });
    if (!res.ok) {
      throw new Error(
        `Economy API ${res.status}: ${url.pathname} (keyLen=${apiKey.length})`
      );
    }

    const data: Record<string, unknown> = await res.json();
    const raw = Array.isArray(data[field]) ? (data[field] as T[]) : [];
    items.push(...raw);

    pageToken = (data.nextPageToken as string | null) || null;
    if (!pageToken || raw.length === 0) break;
  }
  return items;
}

async function resolveThumbnails(assetIds: number[]): Promise<Map<number, string>> {
  const map = new Map<number, string>();
  for (let i = 0; i < assetIds.length; i += 100) {
    const chunk = assetIds.slice(i, i + 100);
    try {
      const res = await fetch(
        `https://thumbnails.roblox.com/v1/assets?assetIds=${chunk.join(",")}&size=420x420&format=Png`
      );
      if (res.ok) {
        const data: { data?: Array<{ targetId: number; state: string; imageUrl?: string }> } =
          await res.json();
        for (const t of data.data || []) {
          if (t.state === "Completed" && t.imageUrl) map.set(t.targetId, t.imageUrl);
        }
      }
    } catch {
      // non-critical — image falls back to placeholder
    }
  }
  return map;
}

interface GamePassApi {
  gamePassId: number;
  name: string;
  description?: string;
  isForSale: boolean;
  iconAssetId?: number | null;
  priceInformation?: { defaultPriceInRobux?: number | null } | null;
}

interface DevProductApi {
  productId: number;
  name: string;
  description?: string;
  isForSale: boolean;
  iconImageAssetId?: number | null;
  priceInformation?: { defaultPriceInRobux?: number | null } | null;
}

async function fetchMonetization(): Promise<EconomyItem[]> {
  if (!API_KEY) {
    console.warn("ROBLOX_OPEN_CLOUD_API_KEY not set — market.json left unchanged.");
    return [];
  }

  const gamePasses = await fetchAll<GamePassApi>(
    `https://apis.roblox.com/game-passes/v1/universes/${UNIVERSE_ID}/game-passes/creator`,
    "gamePasses"
  );
  const devProducts = await fetchAll<DevProductApi>(
    `https://apis.roblox.com/developer-products/v2/universes/${UNIVERSE_ID}/developer-products/creator`,
    "developerProducts"
  );

  const gpThumbs = await resolveThumbnails(gamePasses.map((gp) => gp.gamePassId));
  const dpThumbs = await resolveThumbnails(
    devProducts.map((dp) => dp.iconImageAssetId).filter((v): v is number => !!v)
  );

  const items: EconomyItem[] = [
    ...gamePasses.map((gp) => ({
      id: gp.gamePassId,
      name: gp.name,
      description: gp.description || "",
      price: priceOf(gp),
      isForSale: gp.isForSale,
      category: "Gamepass" as const,
      imageUrl:
        gpThumbs.get(gp.gamePassId) ||
        (typeof gp.iconAssetId === "number"
          ? `https://tr.rbxcdn.com/180DAY-0/420/420/Image/Png/noFilter`
          : ""),
    })),
    ...devProducts.map((dp) => ({
      id: dp.productId,
      name: dp.name,
      description: dp.description || "",
      price: priceOf(dp),
      isForSale: dp.isForSale,
      category: "Developer Product" as const,
      imageUrl:
        (typeof dp.iconImageAssetId === "number" &&
          dpThumbs.get(dp.iconImageAssetId)) ||
        `https://tr.rbxcdn.com/180DAY-0/420/420/Image/Png/noFilter`,
    })),
  ];

  return items.filter((item) => item.isForSale || item.price !== null);
}

interface CuratedEntry {
  Id?: string;
  id?: string | number;
  Name?: string;
  name?: string;
  Description?: string;
  description?: string;
  Price?: number;
  price?: number;
  Category?: string;
  category?: string;
  ImageUrl?: string;
  imageUrl?: string;
  AssetId?: number;
  BuyUrl?: string;
}

interface CatalogEntry {
  Id: string;
  Name: string;
  Description: string;
  Price: number;
  Currency: string;
  Category: string;
  ImageUrl: string;
  AssetId: number;
  BuyUrl: string;
}

function loadCurated(): CuratedEntry[] {
  if (!existsSync(REGISTRY_PATH)) return [];
  try {
    const raw = readFileSync(REGISTRY_PATH, "utf8");
    const data = JSON.parse(raw);
    return Array.isArray(data) ? (data as CuratedEntry[]) : [];
  } catch {
    return [];
  }
}

function mergeCatalog(live: EconomyItem[], curated: CuratedEntry[]): CatalogEntry[] {
  const byName = new Map<string, EconomyItem>();
  for (const item of live) byName.set(normalizeName(item.name), item);

  const merged: CatalogEntry[] = [];
  const seen = new Set<string>();

  // Curated entries first — keep custom images/descriptions, refresh prices from live.
  for (const entry of curated) {
    const key = normalizeName(entry.Name || entry.name || "");
    const liveItem = byName.get(key);
    merged.push({
      Id: entry.Id || String(entry.id || "") || (liveItem ? `MKT_${liveItem.id}` : `MKT_${key}`),
      Name: entry.Name || entry.name || "",
      Description: entry.Description || entry.description || "",
      Price: liveItem ? liveItem.price || entry.Price || 0 : entry.Price || 0,
      Currency: "Robux",
      Category: liveItem ? liveItem.category : entry.Category || "Gamepass",
      ImageUrl: entry.ImageUrl || entry.imageUrl || "",
      AssetId: liveItem ? liveItem.id : entry.AssetId || 0,
      BuyUrl: liveItem
        ? liveItem.category === "Gamepass"
          ? `https://www.roblox.com/game-pass/${liveItem.id}`
          : `https://www.roblox.com/games/${PLACE_ID}`
        : entry.BuyUrl || "",
    });
    if (key) seen.add(key);
  }

  // Live items not already curated.
  for (const item of live) {
    const key = normalizeName(item.name);
    if (seen.has(key)) continue;
    seen.add(key);
    merged.push({
      Id: `MKT_${item.id}`,
      Name: item.name,
      Description: item.description,
      Price: item.price ?? 0,
      Currency: "Robux",
      Category: item.category,
      ImageUrl: item.imageUrl,
      AssetId: item.id,
      BuyUrl:
        item.category === "Gamepass"
          ? `https://www.roblox.com/game-pass/${item.id}`
          : `https://www.roblox.com/games/${PLACE_ID}`,
    });
  }

  // Deterministic ordering: Gamepass first, then price desc, then name.
  const catRank: Record<string, number> = { Gamepass: 0, "Developer Product": 1 };
  merged.sort((a, b) => {
    const ca = catRank[a.Category] ?? 9;
    const cb = catRank[b.Category] ?? 9;
    if (ca !== cb) return ca - cb;
    if ((b.Price || 0) !== (a.Price || 0)) return (b.Price || 0) - (a.Price || 0);
    return String(a.Name).localeCompare(String(b.Name));
  });

  return merged;
}

async function upsertPrisma(catalog: CatalogEntry[]) {
  if (!process.env.DATABASE_URL) {
    console.log("DATABASE_URL not set — skipping Prisma MarketAsset upsert.");
    return;
  }
  const prisma = new PrismaClient();
  try {
    let count = 0;
    for (const item of catalog) {
      const assetId = Number(item.AssetId || 0);
      if (!assetId) continue;
      await prisma.marketAsset.upsert({
        where: { assetId },
        update: {
          name: item.Name,
          description: item.Description || "",
          price: item.Price || 0,
          currency: item.Currency || "Robux",
          category: item.Category || "Gamepass",
          slug: slugify(item.Name),
          imageUrl: item.ImageUrl || "",
        },
        create: {
          assetId,
          name: item.Name,
          description: item.Description || "",
          price: item.Price || 0,
          currency: item.Currency || "Robux",
          category: item.Category || "Gamepass",
          slug: slugify(item.Name),
          imageUrl: item.ImageUrl || "",
        },
      });
      count++;
    }
    console.log(`Upserted ${count} MarketAsset rows into Prisma.`);
  } finally {
    await prisma.$disconnect();
  }
}

async function main() {
  console.log("🚀 Syncing monetization from Roblox Economy v2...");
  const live = await fetchMonetization();
  const curated = loadCurated();
  const catalog = mergeCatalog(live, curated);
  writeFileSync(REGISTRY_PATH, JSON.stringify(catalog, null, 2) + "\n", "utf8");
  console.log(`Wrote ${catalog.length} entries (${live.length} live) → market.json`);
  await upsertPrisma(catalog);
}

if (require.main === module) {
  main()
    .then(() => process.exit(0))
    .catch((err) => {
      console.error("💥 Monetization sync failed:", err);
      process.exit(1);
    });
}
