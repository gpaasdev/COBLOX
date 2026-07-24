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

const ROBLOX_API_KEY = process.env.ROBLOX_API_KEY || "";
const ROBLOX_UNIVERSE_ID = process.env.ROBLOX_UNIVERSE_ID || "6891240835"; // Fallback demo universe ID

/**
 * Roblox Open Cloud API Client with Next.js ISR (60s Revalidation)
 */
export async function getUniverseStats(): Promise<UniverseStats> {
  try {
    if (!ROBLOX_API_KEY) {
      // Mock/Fallback data if API Key is not set in environment
      return {
        id: Number(ROBLOX_UNIVERSE_ID),
        name: "COBLOX: Multiverse Alchemy Sanctum",
        description: "Hybrid Pet Tycoon & Social Action Alkimia di Roblox 2026.",
        playing: 8402,
        visits: 1250400,
        favoritedCount: 45200,
        updated: new Date().toISOString(),
      };
    }

    const response = await fetch(
      `https://apis.roblox.com/universes/v1/universes/${ROBLOX_UNIVERSE_ID}`,
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
      id: data.id || Number(ROBLOX_UNIVERSE_ID),
      name: data.name || "COBLOX: Multiverse Alchemy Sanctum",
      description: data.description || "Hybrid Pet Tycoon & Social Action Alkimia.",
      playing: data.playing || 0,
      visits: data.visits || 0,
      favoritedCount: data.favoritedCount || 0,
      updated: data.updated || new Date().toISOString(),
    };
  } catch (error) {
    console.warn("Failed to fetch universe stats from Roblox Open Cloud, using fallback:", error);
    return {
      id: Number(ROBLOX_UNIVERSE_ID),
      name: "COBLOX: Multiverse Alchemy Sanctum",
      description: "Hybrid Pet Tycoon & Social Action Alkimia di Roblox 2026.",
      playing: 8402,
      visits: 1250400,
      favoritedCount: 45200,
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
      // Mock/Fallback Top Players for Programmatic SEO / Sitemap / AEO
      return Array.from({ length: limit }).map((_, idx) => ({
        rank: idx + 1,
        username: `Alchemist_Legend_${idx + 1}`,
        userId: 10000000 + idx,
        score: (100 - idx) * 5000 + 1250,
        slug: `alchemist-legend-${idx + 1}`,
        lastUpdated: new Date().toISOString(),
      }));
    }

    const response = await fetch(
      `https://apis.roblox.com/datastores/v1/universes/${ROBLOX_UNIVERSE_ID}/standard-datastores/datastore/entries?datastoreName=Leaderboard_Global&limit=${limit}`,
      {
        headers: {
          "x-api-key": ROBLOX_API_KEY,
          Accept: "application/json",
        },
        next: { revalidate: 60 },
      }
    );

    if (!response.ok) {
      throw new Error(`DataStore API Error: ${response.statusText}`);
    }

    const data = await response.json();
    const entries = data.keys || [];

    return entries.map((entry: any, index: number) => ({
      rank: index + 1,
      username: entry.key || `Player_${index + 1}`,
      userId: Number(entry.key.replace(/\D/g, "")) || index + 1000,
      score: entry.value || 0,
      slug: (entry.key || `player-${index + 1}`).toLowerCase().replace(/[^a-z0-9]/g, "-"),
      lastUpdated: new Date().toISOString(),
    }));
  } catch (error) {
    console.warn("Failed to fetch top players from Roblox DataStore API, using fallback:", error);
    return Array.from({ length: limit }).map((_, idx) => ({
      rank: idx + 1,
      username: `Alchemist_Legend_${idx + 1}`,
      userId: 10000000 + idx,
      score: (100 - idx) * 5000 + 1250,
      slug: `alchemist-legend-${idx + 1}`,
      lastUpdated: new Date().toISOString(),
    }));
  }
}
