import React from "react";
import Link from "next/link";
import { liveDiscoveriesCache } from "@/app/api/webhook/roblox/route";

export const metadata = {
  title: "Global Codex & Discovery Archive | COBLOX Companion",
  description: "Official COBLOX Sci-Fantasy Operating System outside Roblox. Track First Discoveries, Material Science, and Faction Archives.",
};

export default function LorePage() {
  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 p-8">
      <div className="max-w-6xl mx-auto space-y-12">
        {/* Header */}
        <header className="border-b border-slate-800 pb-6">
          <div className="flex items-center justify-between">
            <div>
              <span className="text-emerald-400 font-mono text-sm tracking-wider uppercase">
                COBLOX OS // GLOBAL CODEX
              </span>
              <h1 className="text-4xl font-extrabold tracking-tight mt-1 text-white">
                Discovery Archive & Scientific Telemetry
              </h1>
            </div>
            <Link
              href="/market"
              className="px-4 py-2 bg-emerald-500/10 text-emerald-400 border border-emerald-500/30 rounded-lg hover:bg-emerald-500/20 transition-all font-mono text-sm"
            >
              [LIVE MARKET DASHBOARD]
            </Link>
          </div>
        </header>

        {/* First Discoveries Hall of Fame */}
        <section className="space-y-4">
          <h2 className="text-2xl font-bold text-slate-200 flex items-center gap-2">
            <span className="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-pulse"></span>
            Historic First Discoveries
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {liveDiscoveriesCache.map((discovery, idx) => (
              <div key={idx} className="bg-slate-900/60 border border-slate-800 rounded-xl p-6 hover:border-emerald-500/50 transition-all">
                <span className="text-xs font-mono text-slate-400">DISCOVERY #{String(liveDiscoveriesCache.length - idx).padStart(3, '0')}</span>
                <h3 className="text-xl font-bold text-emerald-400 mt-1">{discovery.id}</h3>
                <p className="text-sm text-slate-300 mt-2">
                  [{discovery.type}] A groundbreaking new discovery registered in the COBLOX archive.
                </p>
                <div className="mt-4 pt-4 border-t border-slate-800/80 text-xs font-mono text-slate-400 space-y-1">
                  <div>Discoverer: <span className="text-white font-bold">{discovery.playerName}</span></div>
                  <div>Timestamp: <span className="text-slate-300">{new Date(discovery.timestamp).toLocaleString()}</span></div>
                </div>
              </div>
            ))}
          </div>
        </section>

        {/* Faction Philosophies & World Timeline */}
        <section className="grid grid-cols-1 md:grid-cols-2 gap-8">
          <div className="bg-slate-900/40 border border-slate-800 rounded-xl p-6 space-y-4">
            <h2 className="text-xl font-bold text-white">Faction Archives</h2>
            <div className="space-y-3">
              <div className="p-4 bg-emerald-950/20 border border-emerald-500/20 rounded-lg">
                <h3 className="font-bold text-emerald-400">Preservationists (Biomancy)</h3>
                <p className="text-xs text-slate-300 mt-1">Focuses on ecological stability, plant mutation, and zero-loss reactor cooling.</p>
              </div>
              <div className="p-4 bg-blue-950/20 border border-blue-500/20 rounded-lg">
                <h3 className="font-bold text-blue-400">Industrialists (Factory & Automation)</h3>
                <p className="text-xs text-slate-300 mt-1">Focuses on high-volume production, conveyor automation, and heavy mining turbines.</p>
              </div>
              <div className="p-4 bg-purple-950/20 border border-purple-500/20 rounded-lg">
                <h3 className="font-bold text-purple-400">Void Walkers (Forbidden Rift Research)</h3>
                <p className="text-xs text-slate-300 mt-1">Focuses on high-risk Void corruption, dimensional teleportation, and volatile alchemy.</p>
              </div>
            </div>
          </div>

          <div className="bg-slate-900/40 border border-slate-800 rounded-xl p-6 space-y-4">
            <h2 className="text-xl font-bold text-white">World Timeline & Historic Events</h2>
            <div className="relative pl-6 border-l border-slate-800 space-y-6 text-sm">
              <div className="relative">
                <span className="absolute -left-[31px] top-1.5 w-3 h-3 rounded-full bg-emerald-500"></span>
                <span className="text-xs font-mono text-slate-400">EPOC 01 // JULY 2026</span>
                <h3 className="font-bold text-slate-100">The Great Aether Awakening</h3>
                <p className="text-xs text-slate-400 mt-0.5">First Sanctum Reactors online globally.</p>
              </div>
              <div className="relative">
                <span className="absolute -left-[31px] top-1.5 w-3 h-3 rounded-full bg-blue-500"></span>
                <span className="text-xs font-mono text-slate-400">EPOC 02 // COMING SOON</span>
                <h3 className="font-bold text-slate-100">Void Gate Breach</h3>
                <p className="text-xs text-slate-400 mt-0.5">Server-wide Industrialist vs Void Walker conflict.</p>
              </div>
            </div>
          </div>
        </section>
      </div>
    </div>
  );
}
