import { MetadataRoute } from "next";
import { getTopPlayers, getMarketAssets, getRecipes, getSpirits, getBadges } from "@/lib/roblox";

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://gpaasdev.github.io/COBLOX";
  
  // Dynamic pSEO items
  const players = await getTopPlayers(50);
  const marketAssets = await getMarketAssets(20);
  const recipes = await getRecipes(20);
  const spirits = await getSpirits(20);
  const badges = await getBadges(20);

  const devResources = [
    { category: "framework", slug: "knit-framework" },
    { category: "data-management", slug: "profilestore" },
    { category: "memory-management", slug: "janitor-memory-manager" },
  ];

  const games = [
    { slug: "coblox-multiverse-sanctum" },
    { slug: "blox-fruits" },
    { slug: "adopt-me" },
    { slug: "pet-simulator-99" },
  ];

  // Core static pages
  const staticPages: MetadataRoute.Sitemap = [
    {
      url: baseUrl,
      lastModified: new Date(),
      changeFrequency: "hourly",
      priority: 1.0,
    },
  ];

  const devResourcePages: MetadataRoute.Sitemap = devResources.map((res) => ({
    url: `${baseUrl}/resources/${res.category}/${res.slug}`,
    lastModified: new Date(),
    changeFrequency: "daily",
    priority: 0.9,
  }));

  const gamePages: MetadataRoute.Sitemap = games.map((game) => ({
    url: `${baseUrl}/roblox/games/${game.slug}`,
    lastModified: new Date(),
    changeFrequency: "hourly",
    priority: 0.95,
  }));

  const playerPages: MetadataRoute.Sitemap = players.map((player) => ({
    url: `${baseUrl}/leaderboard/${player.slug}`,
    lastModified: new Date(player.lastUpdated),
    changeFrequency: "hourly",
    priority: 0.8,
  }));

  const marketPages: MetadataRoute.Sitemap = marketAssets.map((asset) => ({
    url: `${baseUrl}/market/assets/${asset.slug}`,
    lastModified: new Date(),
    changeFrequency: "daily",
    priority: 0.85,
  }));

  const recipePages: MetadataRoute.Sitemap = recipes.map((recipe) => ({
    url: `${baseUrl}/recipes/${recipe.slug}`,
    lastModified: new Date(),
    changeFrequency: "weekly",
    priority: 0.8,
  }));

  const spiritPages: MetadataRoute.Sitemap = spirits.map((spirit) => ({
    url: `${baseUrl}/spirits/${spirit.slug}`,
    lastModified: new Date(),
    changeFrequency: "weekly",
    priority: 0.8,
  }));

  const badgePages: MetadataRoute.Sitemap = badges.map((badge) => ({
    url: `${baseUrl}/badges/${badge.slug}`,
    lastModified: new Date(),
    changeFrequency: "weekly",
    priority: 0.7,
  }));

  return [
    ...staticPages,
    ...devResourcePages,
    ...gamePages,
    ...playerPages,
    ...marketPages,
    ...recipePages,
    ...spiritPages,
    ...badgePages,
  ];
}
