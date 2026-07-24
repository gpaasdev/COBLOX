import { MetadataRoute } from "next";
import { getTopPlayers } from "@/lib/roblox";

const ITEMS_PER_SITEMAP = 1000;
const TOTAL_ITEMS = 5000;

export async function generateSitemaps() {
  const totalSitemaps = Math.ceil(TOTAL_ITEMS / ITEMS_PER_SITEMAP);
  return Array.from({ length: totalSitemaps }).map((_, index) => ({ id: index }));
}

export default async function sitemap({ id }: { id: number }): Promise<MetadataRoute.Sitemap> {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://gpaasdev.github.io/COBLOX";
  
  // Fetch dynamic player data from Roblox Open Cloud
  const players = await getTopPlayers(TOTAL_ITEMS);

  const start = id * ITEMS_PER_SITEMAP;
  const end = start + ITEMS_PER_SITEMAP;
  const chunkedPlayers = players.slice(start, end);

  // Core static pages (only included in sitemap 0)
  const staticPages: MetadataRoute.Sitemap = id === 0 ? [
    {
      url: baseUrl,
      lastModified: new Date(),
      changeFrequency: "hourly",
      priority: 1.0,
    },
  ] : [];

  // Dynamic programmatic leaderboard player profile URLs
  const playerPages: MetadataRoute.Sitemap = chunkedPlayers.map((player) => ({
    url: `${baseUrl}/leaderboard/${player.slug}`,
    lastModified: new Date(player.lastUpdated),
    changeFrequency: "hourly",
    priority: 0.8,
  }));

  return [...staticPages, ...playerPages];
}
