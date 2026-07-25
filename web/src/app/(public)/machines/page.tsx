import React from "react";
import Link from "next/link";
import registryData from "@/data/registry_bundle.json";

export const metadata = {
  title: "Machine & Equipment Registry | COBLOX Companion",
  description: "Data-Driven Machine & Equipment Registry for COBLOX. Displays power consumption, heat generation, max heat thresholds, and efficiency.",
};

const MACHINES_DATA = registryData.machines || [];

export default function MachinesRegistryPage() {
  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 p-8">
      <div className="max-w-6xl mx-auto space-y-8">
        <header className="border-b border-slate-800 pb-6 flex items-center justify-between">
          <div>
            <span className="text-blue-400 font-mono text-xs tracking-wider uppercase">
              COBLOX REGISTRY // INDUSTRIAL EQUIPMENT
            </span>
            <h1 className="text-3xl font-bold text-white mt-1">Data-Driven Machine Catalog</h1>
          </div>
          <div className="flex items-center gap-3">
            <Link
              href="/materials"
              className="px-4 py-2 bg-slate-800 text-slate-200 border border-slate-700 rounded-lg hover:bg-slate-700 transition-all font-mono text-sm"
            >
              Material Catalog →
            </Link>
            <Link
              href="/lore"
              className="px-4 py-2 bg-slate-800 text-slate-200 border border-slate-700 rounded-lg hover:bg-slate-700 transition-all font-mono text-sm"
            >
              Codex →
            </Link>
          </div>
        </header>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {MACHINES_DATA.map((mac) => (
            <div
              key={mac.id}
              className="bg-slate-900/60 border border-slate-800 rounded-xl p-6 hover:border-blue-500/50 transition-all"
            >
              <div className="flex items-center justify-between">
                <span className="text-xs font-mono px-2.5 py-1 bg-blue-500/10 text-blue-400 border border-blue-500/20 rounded">
                  {mac.category}
                </span>
                <span className="text-xs font-mono text-slate-400">ID: {mac.id}</span>
              </div>
              <h2 className="text-xl font-bold text-white mt-3">{mac.name}</h2>

              <div className="space-y-2 mt-4 pt-4 border-t border-slate-800/80 text-xs font-mono">
                <div className="flex justify-between">
                  <span className="text-slate-400">Power draw:</span>
                  <span className="text-slate-200">{mac.powerConsumption}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-400">Thermal Output:</span>
                  <span className="text-amber-400">{mac.heatGeneration}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-400">Max Heat Threshold:</span>
                  <span className="text-red-400">{mac.maxHeat}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-400">Efficiency:</span>
                  <span className="text-emerald-400">{mac.efficiency}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-400">Base Cost:</span>
                  <span className="text-yellow-400">{mac.baseCost} Coins</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
