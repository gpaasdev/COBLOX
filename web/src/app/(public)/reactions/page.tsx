import React from "react";
import Link from "next/link";

export const metadata = {
  title: "Chemical & Alchemical Reactions Registry | COBLOX Companion",
  description: "Data-Driven Reaction Registry for COBLOX. Displays input materials, thermal thresholds, pressure requirements, products, and entropy rates.",
};

const REACTIONS_DATA = [
  {
    id: "FerriumFusion",
    name: "Ferrium Alloy Fusion",
    inputs: "5 Iron Ore + 1 Aether Crystal",
    minTemp: "1500 K",
    maxTemp: "2500 K",
    minPressure: "1.0 atm",
    product: "1 Ferrium Alloy",
    energyCost: "100 Aether Energy",
    entropyRate: "0.05",
  },
];

export default function ReactionsRegistryPage() {
  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 p-8">
      <div className="max-w-6xl mx-auto space-y-8">
        <header className="border-b border-slate-800 pb-6 flex items-center justify-between">
          <div>
            <span className="text-amber-400 font-mono text-xs tracking-wider uppercase">
              COBLOX REGISTRY // CHEMICAL REACTIONS
            </span>
            <h1 className="text-3xl font-bold text-white mt-1">Data-Driven Reaction Catalog</h1>
          </div>
          <div className="flex items-center gap-3">
            <Link
              href="/materials"
              className="px-4 py-2 bg-slate-800 text-slate-200 border border-slate-700 rounded-lg hover:bg-slate-700 transition-all font-mono text-sm"
            >
              Materials →
            </Link>
            <Link
              href="/machines"
              className="px-4 py-2 bg-slate-800 text-slate-200 border border-slate-700 rounded-lg hover:bg-slate-700 transition-all font-mono text-sm"
            >
              Machines →
            </Link>
          </div>
        </header>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {REACTIONS_DATA.map((rec) => (
            <div
              key={rec.id}
              className="bg-slate-900/60 border border-slate-800 rounded-xl p-6 hover:border-amber-500/50 transition-all"
            >
              <div className="flex items-center justify-between">
                <span className="text-xs font-mono px-2.5 py-1 bg-amber-500/10 text-amber-400 border border-amber-500/20 rounded">
                  Reaction
                </span>
                <span className="text-xs font-mono text-slate-400">ID: {rec.id}</span>
              </div>
              <h2 className="text-xl font-bold text-white mt-3">{rec.name}</h2>

              <div className="space-y-2 mt-4 pt-4 border-t border-slate-800/80 text-xs font-mono">
                <div className="flex justify-between">
                  <span className="text-slate-400">Input Mass:</span>
                  <span className="text-slate-200">{rec.inputs}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-400">Result Product:</span>
                  <span className="text-emerald-400 font-bold">{rec.product}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-400">Temperature Bounds:</span>
                  <span className="text-amber-400">{rec.minTemp} – {rec.maxTemp}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-400">Min Pressure:</span>
                  <span className="text-slate-300">{rec.minPressure}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-400">Energy Required:</span>
                  <span className="text-blue-400">{rec.energyCost}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-400">Entropy Generation:</span>
                  <span className="text-red-400">{rec.entropyRate}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
