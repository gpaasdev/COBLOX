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

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {MATERIALS_DATA.map((mat: any) => {
            let assetIcon = null;
            if (mat.Id === "PYRO_CRYSTAL" || mat.Name?.includes("Pyro")) {
              assetIcon = "/assets/coblox_pyro_crystal_icon.png";
            } else if (mat.Id === "AETHER_CRYSTAL" || mat.Name?.includes("Aether")) {
              assetIcon = "/assets/coblox_aether_crystal_icon.png";
            }

            return (
              <div
                key={mat.Id}
                className="bg-slate-900/60 backdrop-blur-md border border-slate-800 rounded-xl p-6 hover:border-emerald-500/50 hover:shadow-[0_0_20px_rgba(16,185,129,0.15)] transition-all flex flex-col justify-between"
              >
                <div>
                  <div className="flex items-center justify-between mb-4">
                    <span className="text-xs font-mono px-2.5 py-1 bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 rounded">
                      MATERIAL
                    </span>
                    <span className="text-xs font-mono text-slate-400">ID: {mat.Id}</span>
                  </div>

                  {assetIcon && (
                    <div className="w-20 h-20 mx-auto mb-4 relative flex items-center justify-center bg-slate-950/80 rounded-xl border border-white/10 overflow-hidden">
                      <img src={assetIcon} alt={mat.Name} className="w-full h-full object-cover" />
                    </div>
                  )}

                  <h2 className="text-xl font-bold text-white mb-2">{mat.Name}</h2>
                </div>
                
                <div className="grid grid-cols-3 gap-2 mt-4 pt-4 border-t border-slate-800/80 text-xs font-mono text-center">
                  <div className="bg-slate-950/50 p-2 rounded border border-white/5">
                    <span className="text-slate-400 block text-[10px]">Density</span>
                    <span className="text-slate-200 font-bold">{mat.Density}</span>
                  </div>
                  <div className="bg-slate-950/50 p-2 rounded border border-white/5">
                    <span className="text-slate-400 block text-[10px]">Conduct.</span>
                    <span className="text-cyan-300 font-bold">{mat.Conductivity * 100}%</span>
                  </div>
                  <div className="bg-slate-950/50 p-2 rounded border border-white/5">
                    <span className="text-slate-400 block text-[10px]">Value</span>
                    <span className="text-emerald-400 font-bold">{mat.Value}</span>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
