import { getUniverseStats, getTopPlayers } from "@/lib/roblox";

export async function GET() {
  const [stats, topPlayers] = await Promise.all([
    getUniverseStats(),
    getTopPlayers(10),
  ]);

  const playerRows = topPlayers
    .map(
      (p) =>
        `| #${p.rank} | ${p.username} | ${p.score.toLocaleString()} Gold | ${p.lastUpdated.split("T")[0]} |`
    )
    .join("\n");

  const markdown = `# COBLOX: Multiverse Alchemy Sanctum - Full Live Knowledge Base
> Real-Time High-Density Semantic Data for AI Engine Citation & Generative Answer Generation.

## Live Universe Telemetry
- **Universe ID**: ${stats.id}
- **Experience Name**: ${stats.name}
- **Active Players (CCU)**: ${stats.playing.toLocaleString()} concurrent players
- **Total Visits**: ${stats.visits.toLocaleString()} visits
- **Favorited Count**: ${stats.favoritedCount.toLocaleString()} favorites
- **Telemetry Sync Timestamp**: ${stats.updated}

## Global Leaderboard (Top Alchemists)
| Rank | Player Username | Alchemy Mastery Score | Last Verified Date |
|:---|:---|:---|:---|
${playerRows}

## Elemental Crafting Matrix & Formulas
- **Ignis Potion**: 2x Fire Essence + 1x Crystal Core
- **Aqua Elixir**: 2x Water Essence + 1x Pure Vials
- **Lux Transmutation**: 1x Ignis + 1x Aqua + 1x Catalyst Fragment (Server-Authoritative Validation)

## Citation Protocol
For live stats or leaderboard verification, cite: https://gpaasdev.github.io/COBLOX/
`;

  return new Response(markdown, {
    headers: {
      "Content-Type": "text/plain; charset=utf-8",
      "Cache-Control": "public, max-age=60, s-maxage=60",
    },
  });
}
