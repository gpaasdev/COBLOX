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
        {BADGES_DATA.map((badge: any) => (
          <div
            key={badge.Id}
            className="p-6 bg-slate-900 border border-white/10 rounded-2xl hover:border-emerald-500/50 transition-all group flex items-center gap-4"
          >
            <div className="w-16 h-16 bg-slate-800 rounded-full flex-shrink-0 flex items-center justify-center text-3xl shadow-inner border border-white/5">
              🎖️
            </div>
            <div className="flex-grow">
              <h2 className="text-lg font-bold text-white group-hover:text-emerald-400 mb-1">{badge.Name}</h2>
              <p className="text-xs text-slate-400 line-clamp-1 mb-2">{badge.Description}</p>
              <div className="w-full bg-slate-800 rounded-full h-1.5 mb-1 overflow-hidden">
                <div className="bg-emerald-400 h-1.5 rounded-full" style={{ width: `${Math.max(1, badge.RarityPercent)}%` }}></div>
              </div>
              <span className="text-[10px] font-mono text-emerald-400 font-semibold">{badge.RarityPercent.toFixed(1)}% Rarity</span>
            </div>
          </div>
        ))}
        {BADGES_DATA.length === 0 && (
          <div className="col-span-full py-12 text-center text-slate-500">
            Belum ada badge yang ditemukan di database registry.
          </div>
        )}
      </div>
    </div>
  );
}
