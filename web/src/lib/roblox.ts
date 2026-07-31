export interface UniverseStats {
  id: number;
  name: string;
  description: string;
  playing: number;
  visits: number;
  favoritedCount: number;
  updated: string;
}

export interface LeaderboardPlayer {
  rank: number;
  username: string;
  userId: number;
  score: number;
  slug: string;
  lastUpdated: string;
}

export interface MarketAsset {
  id: number;
  name: string;
  description: string;
  price: number;
  currency: string;
  category: string;
  slug: string;
  imageUrl: string;
  buyUrl?: string;
}

export interface Recipe {
  id: string;
  name: string;
  description: string;
  ingredients: string[];
  outputType: string;
  slug: string;
}

export interface Spirit {
  id: string;
  name: string;
  description: string;
  rarity: string;
  element: string;
  dropRate: string;
  slug: string;
}

export interface Badge {
  id: number;
  name: string;
  description: string;
  rarityPercent: number;
  slug: string;
}

const ROBLOX_API_KEY = process.env.ROBLOX_OPEN_CLOUD_API_KEY || process.env.ROBLOX_API_KEY || "";
const ROBLOX_UNIVERSE_ID = process.env.ROBLOX_UNIVERSE_ID || "10545905192";

/**
 * Roblox Open Cloud API Client with Next.js ISR (60s Revalidation)
 */
export async function getUniverseStats(): Promise<UniverseStats> {
  try {
    if (!ROBLOX_API_KEY) {
      return {
        id: Number(ROBLOX_UNIVERSE_ID),
        name: "COBLOX: Multiverse Alchemy Sanctum",
        description: "Hybrid Pet Tycoon & Social Action Alkimia di Roblox.",
        playing: 0,
        visits: 0,
        favoritedCount: 0,
        updated: new Date().toISOString(),
      };
    }

    const response = await fetch(
      `https://apis.roblox.com/cloud/v2/universes/${ROBLOX_UNIVERSE_ID}`,
      {
        headers: {
          "x-api-key": ROBLOX_API_KEY,
          Accept: "application/json",
        },
        next: { revalidate: 60 },
      }
    );

    if (!response.ok) {
      throw new Error(`Roblox API Error: ${response.status} ${response.statusText}`);
    }

    const data = await response.json();
    return {
      id: Number(ROBLOX_UNIVERSE_ID),
      name: data.displayName || data.name || "COBLOX: Multiverse Alchemy Sanctum",
      description: data.description || "Hybrid Pet Tycoon & Social Action Alkimia.",
      playing: data.playing || 0,
      visits: data.visits || 0,
      favoritedCount: data.favoritedCount || 0,
      updated: data.updateTime || new Date().toISOString(),
    };
  } catch (error) {
    console.warn("Failed to fetch universe stats from Roblox Open Cloud:", error);
    return {
      id: Number(ROBLOX_UNIVERSE_ID),
      name: "COBLOX: Multiverse Alchemy Sanctum",
      description: "Hybrid Pet Tycoon & Social Action Alkimia di Roblox.",
      playing: 0,
      visits: 0,
      favoritedCount: 0,
      updated: new Date().toISOString(),
    };
  }
}

/**
 * Fetch Top Players Leaderboard from Roblox Open Cloud DataStore API
 */
export async function getTopPlayers(limit: number = 50): Promise<LeaderboardPlayer[]> {
  try {
    if (!ROBLOX_API_KEY) {
      return [];
    }

    const response = await fetch(
      `https://apis.roblox.com/ordered-datastores/v1/universes/${ROBLOX_UNIVERSE_ID}/orderedDataStores/COBLOX_Leaderboard_Gems_v11/scopes/global/entries?max_page_size=${limit}&order_by=Desc`,
      {
        headers: {
          "x-api-key": ROBLOX_API_KEY,
          Accept: "application/json",
        },
        next: { revalidate: 60 },
      }
    );

    if (!response.ok) {
      // Fallback to standard DataStore listing if OrderedDataStore is empty
      const stdRes = await fetch(
        `https://apis.roblox.com/datastores/v1/universes/${ROBLOX_UNIVERSE_ID}/standard-datastores/datastore/entries?datastoreName=COBLOX_DataStore_LGBOS_v11&limit=${limit}`,
        {
          headers: { "x-api-key": ROBLOX_API_KEY, Accept: "application/json" },
          next: { revalidate: 60 }
        }
      );
      if (!stdRes.ok) throw new Error(`OrderedDataStore API Error: ${response.statusText}`);
      const stdData = await stdRes.json();
      const keys = stdData.keys || [];

      return Promise.all(keys.map(async (entry: any, index: number) => {
        const rawId = entry.key ? entry.key.replace("COBLOX_LGBOS_v11_", "") : `${index + 1}`;
        let username = `User_${rawId}`;
        try {
          const userRes = await fetch(`https://users.roblox.com/v1/users/${rawId}`);
          if (userRes.ok) {
            const userData = await userRes.json();
            if (userData.name) username = userData.name;
          }
        } catch {}

        return {
          rank: index + 1,
          username: username,
          userId: Number(rawId) || index + 1000,
          score: 50,
          slug: `player-${rawId}`,
          lastUpdated: new Date().toISOString()
        };
      }));
    }

    const data = await response.json();
    const entries = data.entries || [];

    const players = await Promise.all(entries.map(async (entry: any, index: number) => {
      const rawId = entry.path ? entry.path.split("/").pop() : (entry.id || `User_${index + 1}`);
      let username = `Player_${rawId}`;
      
      try {
        const userRes = await fetch(`https://users.roblox.com/v1/users/${rawId}`);
        if (userRes.ok) {
          const userData = await userRes.json();
          if (userData.name) {
            username = userData.name;
          }
        }
      } catch (e) {
        console.warn(`Failed to fetch username for ${rawId}`);
      }

      return {
        rank: index + 1,
        username: username,
        userId: Number(rawId) || index + 1000,
        score: entry.value || 0,
        slug: `player-${rawId}`,
        lastUpdated: new Date().toISOString(),
      };
    }));

    return players;
  } catch (error) {
    console.warn("Failed to fetch top players from Roblox OrderedDataStore API:", error);
    return [];
  }
}

/**
 * Fetch Market Assets (Gamepasses/Products) for pSEO
 * Reads from local JSON registry files generated by ContentOps pipeline
 */
import marketData from "../data/registry/market.json";
import recipesData from "../data/registry/recipes.json";
import spiritsData from "../data/registry/spirits.json";
import badgesData from "../data/registry/badges.json";

function assetSlug(name: string): string {
  return name
    .toLowerCase()
    .replace(/[^\w\s]/g, "")
    .replace(/\s+/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-+|-+$/g, "");
}

export async function getMarketAssets(limit: number = 50): Promise<MarketAsset[]> {
  const items = Array.isArray(marketData) ? marketData : (marketData as any).entries || [];
  return items.slice(0, limit).map((item: any) => ({
    id: item.AssetId || item.Id || item.id || 0,
    name: item.Name || item.name || "Unknown",
    description: item.Description || item.description || "",
    price: item.Price || item.price || 0,
    currency: item.Currency || item.currency || "Robux",
    category: item.Category || item.category || "Product",
    slug: assetSlug(item.Name || item.name || "unknown"),
    imageUrl: item.ImageUrl || item.IconUrl || item.imageUrl || "",
    buyUrl: item.BuyUrl || item.buyUrl || "",
  }));
}

/**
 * Fetch live GamePass/DevProduct pricing from Roblox Open Cloud Economy v2
 * and merge over the static market registry. Returns null on API failure so
 * callers fall back to getMarketAssets().
 */
export async function getLiveMonetization(limit: number = 50): Promise<MarketAsset[] | null> {
  if (!ROBLOX_API_KEY) return null;

  try {
    const [gamePassRes, devProductRes] = await Promise.all([
      fetch(
        `https://apis.roblox.com/game-passes/v1/universes/${ROBLOX_UNIVERSE_ID}/game-passes/creator?page_size=100`,
        {
          headers: { "x-api-key": ROBLOX_API_KEY, Accept: "application/json" },
          next: { revalidate: 300 },
        },
      ),
      fetch(
        `https://apis.roblox.com/developer-products/v2/universes/${ROBLOX_UNIVERSE_ID}/developer-products/creator?page_size=100`,
        {
          headers: { "x-api-key": ROBLOX_API_KEY, Accept: "application/json" },
          next: { revalidate: 300 },
        },
      ),
    ]);

    if (!gamePassRes.ok || !devProductRes.ok) {
      return null;
    }

    const gpData = await gamePassRes.json();
    const dpData = await devProductRes.json();

    const gamePasses: Array<{
      gamePassId?: number;
      name?: string;
      description?: string;
      priceInformation?: { defaultPriceInRobux?: number | null };
    }> = gpData.gamePasses || [];
    const devProducts: Array<{
      productId?: number;
      name?: string;
      description?: string;
      priceInformation?: { defaultPriceInRobux?: number | null };
    }> = dpData.developerProducts || [];

    const live: MarketAsset[] = [
      ...gamePasses.map((gp) => ({
        id: gp.gamePassId || 0,
        name: gp.name || "Unknown",
        description: gp.description || "",
        price: gp.priceInformation?.defaultPriceInRobux ?? 0,
        currency: "Robux",
        category: "Gamepass",
        slug: assetSlug(gp.name || "unknown"),
        imageUrl: `https://tr.rbxcdn.com/180DAY-0/420/420/Image/Png/noFilter`,
        buyUrl: `https://www.roblox.com/game-pass/${gp.gamePassId}`,
      })),
      ...devProducts.map((dp) => ({
        id: dp.productId || 0,
        name: dp.name || "Unknown",
        description: dp.description || "",
        price: dp.priceInformation?.defaultPriceInRobux ?? 0,
        currency: "Robux",
        category: "Developer Product",
        slug: assetSlug(dp.name || "unknown"),
        imageUrl: `https://tr.rbxcdn.com/180DAY-0/420/420/Image/Png/noFilter`,
        buyUrl: "",
      })),
    ];

    return live.filter((a) => a.price > 0).slice(0, limit);
  } catch (error) {
    console.warn("Failed to fetch live monetization:", error);
    return null;
  }
}

export async function getRecipes(limit: number = 50): Promise<Recipe[]> {
  const items = Array.isArray(recipesData) ? recipesData : (recipesData as any).entries || [];
  return items.slice(0, limit).map((item: any) => ({
    id: item.Id || item.id || "",
    name: item.Name || item.name || "Unknown",
    description: item.Description || item.description || "",
    ingredients: item.Ingredients || item.ingredients || [],
    outputType: item.OutputType || item.outputType || "Material",
    slug: (item.Id || item.id || "unknown").toLowerCase().replace(/_/g, "-"),
  }));
}

export async function getSpirits(limit: number = 50): Promise<Spirit[]> {
  const items = Array.isArray(spiritsData) ? spiritsData : (spiritsData as any).entries || [];
  return items.slice(0, limit).map((item: any) => ({
    id: item.Id || item.id || "",
    name: item.Name || item.name || "Unknown",
    description: item.Description || item.description || "",
    rarity: item.Rarity || item.rarity || "Common",
    element: item.Element || item.element || "Neutral",
    dropRate: String(item.DropRate || item.dropRate || "0.1"),
    slug: (item.Id || item.id || "unknown").toLowerCase().replace(/_/g, "-"),
  }));
}

export async function getBadges(limit: number = 50): Promise<Badge[]> {
  const items = Array.isArray(badgesData) ? badgesData : (badgesData as any).entries || [];
  return items.slice(0, limit).map((item: any) => ({
    id: item.Id || item.id || 0,
    name: item.Name || item.name || "Unknown",
    description: item.Description || item.description || "",
    rarityPercent: item.RarityPercent || item.rarityPercent || 0,
    slug: (item.Id || item.id || "unknown").toLowerCase().replace(/_/g, "-"),
  }));
}
