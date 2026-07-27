/**
 * ContentRepository.ts
 * Server-side data layer for COBLOX content.
 * Reads from the web/src/data/registry/ directory which is the authoritative
 * output of tools/content_pipeline.py.
 *
 * Import this file from Next.js server components/routes ONLY (Node.js env).
 * The registry path is resolved relative to the project root at runtime.
 */

import { MarketAsset, Recipe, Spirit, Badge } from "./types";
import fs from "fs";
import path from "path";

// Registry lives at web/src/data/registry/ relative to monorepo root.
// When running inside Next.js (cwd = web/), resolve accordingly.
function getRegistryDir(): string {
  const candidates = [
    path.join(process.cwd(), "src", "data", "registry"),          // next dev/build inside web/
    path.join(process.cwd(), "web", "src", "data", "registry"),   // scripts run from repo root
  ];
  for (const dir of candidates) {
    if (fs.existsSync(dir)) return dir;
  }
  // Fallback: resolve relative to this file's location
  return path.join(__dirname, "..", "..", "web", "src", "data", "registry");
}

function loadRegistry<T>(filename: string): T[] {
  const registryDir = getRegistryDir();
  const filePath = path.join(registryDir, filename);
  try {
    if (!fs.existsSync(filePath)) {
      console.warn(`[ContentRepository] Registry file not found: ${filePath}`);
      return [];
    }
    const raw = fs.readFileSync(filePath, "utf-8");
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed : [];
  } catch (err) {
    console.error(`[ContentRepository] Failed to load ${filename}:`, err);
    return [];
  }
}

export class ContentRepository {
  static async getMarketAssets(limit: number = 50): Promise<MarketAsset[]> {
    const items = loadRegistry<any>("market.json");
    return items.slice(0, limit).map((m, idx) => ({
      id: m.Id ?? idx,
      name: m.Name,
      description: m.Description,
      price: m.Price,
      currency: m.Currency,
      category: m.Category,
      slug: String(m.Id).toLowerCase().replace(/_/g, "-"),
      imageUrl: m.ImageUrl,
    }));
  }

  static async getRecipes(limit: number = 50): Promise<Recipe[]> {
    const items = loadRegistry<any>("recipes.json");
    return items.slice(0, limit).map((r) => ({
      id: r.Id,
      name: r.Name,
      description: r.Description ?? "",
      ingredients: r.Ingredients ?? [],
      outputType: r.OutputType ?? "Material",
      slug: String(r.Id).toLowerCase().replace(/_/g, "-"),
    }));
  }

  static async getSpirits(limit: number = 50): Promise<Spirit[]> {
    const items = loadRegistry<any>("spirits.json");
    return items.slice(0, limit).map((s) => ({
      id: s.Id,
      name: s.Name,
      description: s.Description,
      rarity: s.Rarity,
      element: s.Element,
      dropRate: s.DropRate,
      slug: String(s.Id).toLowerCase().replace(/_/g, "-"),
    }));
  }

  static async getBadges(limit: number = 50): Promise<Badge[]> {
    const items = loadRegistry<any>("badges.json");
    return items.slice(0, limit).map((b) => ({
      id: b.Id,
      name: b.Name,
      description: b.Description,
      rarityPercent: b.RarityPercent,
      slug: String(b.Id).toLowerCase().replace(/_/g, "-"),
    }));
  }
}
