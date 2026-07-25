import React from "react";
import Link from "next/link";
import registryData from "@/data/registry_bundle.json";
import JsonLd from "@/components/JsonLd";

export const metadata = {
  title: "Material Science Registry | COBLOX Companion",
  description: "Official Data-Driven Material Science Registry for COBLOX. Explores density, hardness, conductivity, and thermal properties.",
};

const MATERIALS_DATA = registryData.materials || [];

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
          {MATERIALS_DATA.map((mat) => (
            <div
              key={mat.id}
              className="bg-slate-900/60 border border-slate-800 rounded-xl p-6 hover:border-emerald-500/50 transition-all"
            >
              <div className="flex items-center justify-between">
                <span className="text-xs font-mono px-2.5 py-1 bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 rounded">
                  {mat.category}
                </span>
                <span className="text-xs font-mono text-slate-400">ID: {mat.id}</span>
              </div>
              <h2 className="text-xl font-bold text-white mt-3">{mat.name}</h2>
              
              <div className="grid grid-cols-2 gap-4 mt-4 pt-4 border-t border-slate-800/80 text-xs font-mono">
                <div>
                  <span className="text-slate-400">Density:</span>{" "}
                  <span className="text-slate-200">{mat.density} g/cm³</span>
                </div>
                <div>
                  <span className="text-slate-400">Conductivity:</span>{" "}
                  <span className="text-slate-200">{mat.conductivity * 100}%</span>
                </div>
                <div>
                  <span className="text-slate-400">Hardness:</span>{" "}
                  <span className="text-slate-200">{mat.hardness}</span>
                </div>
                <div>
                  <span className="text-slate-400">Thermal Limit:</span>{" "}
                  <span className="text-emerald-400">{mat.heatResistance}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
