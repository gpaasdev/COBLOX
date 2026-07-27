export type MarketAsset = {
  id: number;
  name: string;
  description: string;
  price: number;
  currency: string;
  category: string;
  slug: string;
  imageUrl: string;
};

export type Recipe = {
  id: string;
  name: string;
  description: string;
  ingredients: string[];
  outputType: string;
  slug: string;
};

export type Spirit = {
  id: string;
  name: string;
  description: string;
  rarity: string;
  element: string;
  dropRate: string;
  slug: string;
};

export type Badge = {
  id: string;
  name: string;
  description: string;
  rarityPercent: number;
  slug: string;
};

export type LeaderboardPlayer = {
  rank: number;
  userId: string;
  username: string;
  displayName: string;
  score: number;
  avatarUrl: string;
};
