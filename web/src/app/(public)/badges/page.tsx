import React from "react";
import Link from "next/link";
import BADGES_DATA from "@/data/registry/badges.json";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "Pencapaian (Badges) | COBLOX",
  description: "Daftar pencapaian tersulit dan persentase pemain yang berhasil mendapatkannya di COBLOX.",
};

export default function BadgesPage() {
  return (
    <div className="max-w-7xl mx-auto px-6 py-16 flex-grow w-full">
      <div className="mb-12">
        <h1 className="text-4xl font-black text-emerald-400 mb-4">Pencapaian (Badges)</h1>
        <p className="text-slate-300">Daftar pencapaian yang bisa didapatkan pemain di dalam Multiverse Sanctum.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {BADGES_DATA.map((badge: any) => {
          let assetIcon = null;
          if (badge.Id === "TRANSMUTATION_MASTER" || badge.Name?.includes("Transmute") || badge.Name?.includes("Master")) {
            assetIcon = "/assets/coblox_transmutation_badge_icon.png";
          }

          return (
            <div
              key={badge.Id}
              className="p-6 bg-slate-900/60 backdrop-blur-md border border-slate-800 rounded-2xl hover:border-emerald-500/50 hover:shadow-[0_0_20px_rgba(16,185,129,0.2)] transition-all group flex items-center gap-4"
            >
              <div className="w-16 h-16 bg-slate-950/80 rounded-xl flex-shrink-0 flex items-center justify-center border border-white/10 overflow-hidden shadow-inner group-hover:scale-105 transition-transform">
                {assetIcon ? (
                  <img src={assetIcon} alt={badge.Name} className="w-full h-full object-cover" />
                ) : (
                  <span className="text-3xl">🎖️</span>
                )}
              </div>
              <div className="flex-grow">
                <h2 className="text-lg font-bold text-white group-hover:text-emerald-400 mb-1">{badge.Name}</h2>
                <p className="text-xs text-slate-400 line-clamp-1 mb-2">{badge.Description}</p>
                <div className="w-full bg-slate-800/80 rounded-full h-1.5 mb-1 overflow-hidden">
                  <div className="bg-emerald-400 h-1.5 rounded-full shadow-[0_0_8px_rgba(52,211,153,0.8)]" style={{ width: `${Math.max(1, badge.RarityPercent)}%` }}></div>
                </div>
                <span className="text-[10px] font-mono text-emerald-400 font-semibold">{badge.RarityPercent.toFixed(1)}% Rarity</span>
              </div>
            </div>
          );
        })}
        {BADGES_DATA.length === 0 && (
          <div className="col-span-full py-12 text-center text-slate-500">
            Belum ada badge yang ditemukan di database registry.
          </div>
        )}
      </div>
    </div>
  );
}
