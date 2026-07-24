import { MetadataRoute } from "next";

export default function robots(): MetadataRoute.Robots {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://gpaasdev.github.io/COBLOX";

  const aiBots = ["GPTBot", "ChatGPT-User", "ClaudeBot", "Google-Extended", "PerplexityBot"];

  return {
    rules: [
      // Standard search engine crawlers
      {
        userAgent: "*",
        allow: "/",
        disallow: ["/api/", "/admin/", "/private/"],
      },
      // Targeted rules for Generative AI Scrapers (AEO/GEO optimization)
      ...aiBots.map((bot) => ({
        userAgent: bot,
        allow: ["/llms.txt", "/llms-full.txt", "/leaderboard/"],
        disallow: ["/api/", "/admin/", "/private/"],
      })),
    ],
    sitemap: `${baseUrl}/sitemap.xml`,
  };
}
