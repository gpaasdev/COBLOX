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
 */
import { ContentRepository } from "../../../packages/repositories/ContentRepository";

export async function getMarketAssets(limit: number = 50): Promise<MarketAsset[]> {
  return ContentRepository.getMarketAssets(limit);
}

export async function getRecipes(limit: number = 50): Promise<Recipe[]> {
  return ContentRepository.getRecipes(limit);
}

export async function getSpirits(limit: number = 50): Promise<Spirit[]> {
  return ContentRepository.getSpirits(limit);
}

export async function getBadges(limit: number = 50): Promise<Badge[]> {
  return ContentRepository.getBadges(limit);
}
