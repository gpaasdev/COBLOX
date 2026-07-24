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
        description: "Hybrid Pet Tycoon & Social Action Alkimia di Roblox.",
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
      description: "Hybrid Pet Tycoon & Social Action Alkimia di Roblox.",
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

/**
 * Fetch Market Assets (Gamepasses/Products) for pSEO
 */
export async function getMarketAssets(limit: number = 50): Promise<MarketAsset[]> {
  // In a real implementation, this would fetch from Roblox Catalog API or Open Cloud
  // For now, we mock the pSEO data structure
  return Array.from({ length: limit }).map((_, idx) => ({
    id: 500000 + idx,
    name: idx === 0 ? "Celestial Phoenix VIP" : `Exclusive Asset ${idx + 1}`,
    description: `Dapatkan keuntungan eksklusif di COBLOX dengan ${idx === 0 ? "Celestial Phoenix VIP" : `Exclusive Asset ${idx + 1}`}.`,
    price: (idx + 1) * 100,
    currency: "Robux",
    category: idx % 2 === 0 ? "Gamepass" : "Developer Product",
    slug: idx === 0 ? "celestial-phoenix-vip" : `exclusive-asset-${idx + 1}`,
    imageUrl: "https://raw.githubusercontent.com/gpaasdev/COBLOX/main/.github/assets/game_thumbnail_16x9.png",
  }));
}

/**
 * Fetch Recipes for pSEO
 */
export async function getRecipes(limit: number = 50): Promise<Recipe[]> {
  return Array.from({ length: limit }).map((_, idx) => ({
    id: `REC-${idx + 1}`,
    name: idx === 0 ? "Ramuan Aura Murni" : `Resep Rahasia ${idx + 1}`,
    description: `Cara membuat ${idx === 0 ? "Ramuan Aura Murni" : `Resep Rahasia ${idx + 1}`} menggunakan kombinasi elemen langka.`,
    ingredients: ["2x Kristal Air", "1x Api Abadi", "50 Gold"],
    outputType: "Potion",
    slug: idx === 0 ? "ramuan-aura-murni" : `resep-rahasia-${idx + 1}`,
  }));
}

/**
 * Fetch Spirits/Pets for pSEO
 */
export async function getSpirits(limit: number = 50): Promise<Spirit[]> {
  return Array.from({ length: limit }).map((_, idx) => ({
    id: `SPR-${idx + 1}`,
    name: idx === 0 ? "Void Dragon" : `Spirit Mistis ${idx + 1}`,
    description: `Kawan magis legendaris yang akan membantumu mengekstrak aura lebih cepat.`,
    rarity: idx % 5 === 0 ? "Mythical" : "Rare",
    element: idx % 2 === 0 ? "Dark" : "Light",
    dropRate: idx % 5 === 0 ? "0.1%" : "5.0%",
    slug: idx === 0 ? "void-dragon" : `spirit-mistis-${idx + 1}`,
  }));
}

/**
 * Fetch Badges for pSEO
 */
export async function getBadges(limit: number = 50): Promise<Badge[]> {
  return Array.from({ length: limit }).map((_, idx) => ({
    id: 212450000 + idx,
    name: idx === 0 ? "Alchemist Tertinggi" : `Pencapaian Rahasia ${idx + 1}`,
    description: `Diberikan kepada pemain yang berhasil menyelesaikan tantangan alkimia tingkat akhir.`,
    rarityPercent: idx === 0 ? 0.05 : 10 + idx,
    slug: idx === 0 ? "alchemist-tertinggi" : `pencapaian-rahasia-${idx + 1}`,
  }));
}
