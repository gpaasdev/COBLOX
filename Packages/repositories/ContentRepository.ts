import { MarketAsset, Recipe, Spirit, Badge, LeaderboardPlayer } from "./types";
import latestRegistry from "../../registry/latest.json";
import fs from "fs";
import path from "path";

const ROBLOX_UNIVERSE_ID = process.env.ROBLOX_UNIVERSE_ID || "10545905192";
const ROBLOX_OPEN_CLOUD_API_KEY = process.env.ROBLOX_OPEN_CLOUD_API_KEY || process.env.ROBLOX_OPENCLOUD_API_KEY;

function loadLatestSnapshotLocal() {
  try {
    const snapshotFile = latestRegistry.snapshot_file;
    const snapshotPath = path.join(process.cwd(), "registry", "snapshots", snapshotFile);
    if (fs.existsSync(snapshotPath)) {
      const data = fs.readFileSync(snapshotPath, "utf-8");
      return JSON.parse(data);
    }
  } catch (err) {
    console.warn("Failed to load local registry snapshot, falling back...", err);
  }
  return null;
}

export class ContentRepository {
  static async getMarketAssets(limit: number = 50): Promise<MarketAsset[]> {
    const snapshot = loadLatestSnapshotLocal();
    const items = snapshot?.market || [
      {
        Id: "MKT_VIP_PASS",
        Name: "Sanctum VIP Pass",
        Description: "Gain exclusive access to the upper Sanctum floors.",
        Price: 500,
        Currency: "Robux",
        Category: "Gamepass",
        ImageUrl: "rbxassetid://105075159736246"
      }
    ];

    return items.slice(0, limit).map((m: any, idx: number) => ({
      id: 500000 + idx,
      name: m.Name,
      description: m.Description,
      price: m.Price,
      currency: m.Currency,
      category: m.Category,
      slug: m.Id.toLowerCase().replace(/_/g, "-"),
      imageUrl: m.ImageUrl
    }));
  }

  static async getRecipes(limit: number = 50): Promise<Recipe[]> {
    const snapshot = loadLatestSnapshotLocal();
    const recipes = snapshot?.recipes || [];

    return recipes.slice(0, limit).map((r: any) => ({
      id: r.Id,
      name: r.Name,
      description: r.Description || "Synthesis recipe for transmutation.",
      ingredients: r.Ingredients || [],
      outputType: r.OutputType || "Material",
      slug: r.Id.toLowerCase().replace(/_/g, "-")
    }));
  }

  static async getSpirits(limit: number = 50): Promise<Spirit[]> {
    const snapshot = loadLatestSnapshotLocal();
    const spirits = snapshot?.spirits || [];

    return spirits.slice(0, limit).map((s: any) => ({
      id: s.Id,
      name: s.Name,
      description: s.Description,
      rarity: s.Rarity,
      element: s.Element,
      dropRate: s.DropRate,
      slug: s.Id.toLowerCase().replace(/_/g, "-")
    }));
  }

  static async getBadges(limit: number = 50): Promise<Badge[]> {
    const snapshot = loadLatestSnapshotLocal();
    const badges = snapshot?.badges || [];

    return badges.slice(0, limit).map((b: any, idx: number) => ({
      id: b.Id,
      name: b.Name,
      description: b.Description,
      rarityPercent: b.RarityPercent,
      slug: b.Id.toLowerCase().replace(/_/g, "-")
    }));
  }
}
