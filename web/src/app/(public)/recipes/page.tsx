import React from "react";
import Link from "next/link";
import RECIPES_DATA from "@/data/registry/recipes.json";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "Buku Resep Alkimia | COBLOX",
  description: "Pelajari seluruh resep rahasia di COBLOX: Multiverse Alchemy Sanctum.",
};

export default function RecipesPage() {
  return (
    <div className="max-w-7xl mx-auto px-6 py-16 flex-grow w-full">
      <div className="mb-12">
        <h1 className="text-4xl font-black text-emerald-400 mb-4">Buku Resep Alkimia</h1>
        <p className="text-slate-300">Kumpulan seluruh resep rahasia untuk meracik elemen di Multiverse Sanctum.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {RECIPES_DATA.map((recipe: any) => (
          <div
            key={recipe.Id}
            className="p-6 bg-slate-900 border border-white/10 rounded-2xl hover:border-emerald-500/50 transition-colors group"
          >
            <h2 className="text-xl font-bold text-white group-hover:text-emerald-400 mb-2">{recipe.Name}</h2>
            <p className="text-sm text-slate-400 line-clamp-2 mb-4">{recipe.Description}</p>
            <div className="text-xs text-slate-400 mb-3">Ingredients: {recipe.Ingredients.join(", ")}</div>
            <span className="text-xs font-semibold text-emerald-500 bg-emerald-500/10 px-2 py-1 rounded">
              Output: {recipe.OutputType}
            </span>
          </div>
        ))}
        {RECIPES_DATA.length === 0 && (
          <div className="col-span-full py-12 text-center text-slate-500">
            Belum ada resep yang ditemukan di database registry.
          </div>
        )}
      </div>
    </div>
  );
}
