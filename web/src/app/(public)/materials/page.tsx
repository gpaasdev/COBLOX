import React from "react";
import Link from "next/link";
import MATERIALS_DATA from "@/data/registry/materials.json";

export const metadata = {
  title: "Materials Registry | COBLOX Companion",
  description: "Data-Driven Material Registry for COBLOX.",
};

export default function MaterialsRegistryPage() {
  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 p-8">
      <div className="max-w-6xl mx-auto space-y-8">
        <header className="border-b border-slate-800 pb-6 flex items-center justify-between">
          <div>
            <span className="text-emerald-400 font-mono text-xs tracking-wider uppercase">
              COBLOX REGISTRY // MATERIAL SCIENCE
            </span>
            <h1 className="text-3xl font-bold text-white mt-1">Data-Driven Material Catalog</h1>
          </div>
          <Link
            href="/lore"
            className="px-4 py-2 bg-slate-800 text-slate-200 border border-slate-700 rounded-lg hover:bg-slate-700 transition-all font-mono text-sm"
          >
            ← Back to Codex
          </Link>
        </header>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {MATERIALS_DATA.map((mat: any) => (
            <div
              key={mat.Id}
              className="bg-slate-900/60 border border-slate-800 rounded-xl p-6 hover:border-emerald-500/50 transition-all"
            >
              <div className="flex items-center justify-between">
                <span className="text-xs font-mono px-2.5 py-1 bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 rounded">
                  MATERIAL
                </span>
                <span className="text-xs font-mono text-slate-400">ID: {mat.Id}</span>
              </div>
              <h2 className="text-xl font-bold text-white mt-3">{mat.Name}</h2>
              
              <div className="grid grid-cols-2 gap-4 mt-4 pt-4 border-t border-slate-800/80 text-xs font-mono">
                <div>
                  <span className="text-slate-400">Density:</span>{" "}
                  <span className="text-slate-200">{mat.Density} g/cm³</span>
                </div>
                <div>
                  <span className="text-slate-400">Conductivity:</span>{" "}
                  <span className="text-slate-200">{mat.Conductivity * 100}%</span>
                </div>
                <div>
                  <span className="text-slate-400">Value:</span>{" "}
                  <span className="text-slate-200">{mat.Value}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
