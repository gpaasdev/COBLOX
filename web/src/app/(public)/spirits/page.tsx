import React from "react";
import Link from "next/link";
import SPIRITS_DATA from "@/data/registry/spirits.json";
import { Metadata } from "next";

export const metadata: Metadata = {
  title: "Direktori Spirit | COBLOX",
  description: "Koleksi lengkap Spirit Companion, kelangkaan, dan kemampuan unik di COBLOX.",
};

export default function SpiritsPage() {
  return (
    <div className="max-w-7xl mx-auto px-6 py-16 flex-grow w-full">
      <div className="mb-12">
        <h1 className="text-4xl font-black text-emerald-400 mb-4">Direktori Spirit</h1>
        <p className="text-slate-300">Daftar lengkap kawan Spirit magis yang dapat ditemukan atau ditetaskan.</p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        {SPIRITS_DATA.map((spirit: any) => {
          let assetIcon = null;
          if (spirit.Id === "SPIRIT_FOX" || spirit.Name?.includes("Fox")) {
            assetIcon = "/assets/coblox_spirit_fox_companion.png";
          } else if (spirit.Id === "FAIRY_DRAGON" || spirit.Name?.includes("Dragon")) {
            assetIcon = "/assets/coblox_fairy_dragon_companion.png";
          }

          return (
            <div
              key={spirit.Id}
              className="p-6 bg-slate-900/60 backdrop-blur-md border border-emerald-500/20 rounded-2xl hover:border-emerald-400/60 hover:shadow-[0_0_25px_rgba(16,185,129,0.25)] transition-all group text-center flex flex-col justify-between"
            >
              <div>
                <div className="w-24 h-24 mx-auto mb-4 relative flex items-center justify-center bg-slate-950/80 rounded-xl border border-white/10 overflow-hidden group-hover:scale-105 transition-transform">
                  {assetIcon ? (
                    <img src={assetIcon} alt={spirit.Name} className="w-full h-full object-cover" />
                  ) : (
                    <div className="text-5xl">🐲</div>
                  )}
                </div>
                <h2 className="text-xl font-bold text-white group-hover:text-emerald-400 mb-2">{spirit.Name}</h2>
                <div className="flex justify-center gap-2 mb-4">
                  <span className="text-xs font-semibold px-2.5 py-1 rounded-full bg-emerald-950/80 text-emerald-300 border border-emerald-500/30">{spirit.Rarity}</span>
                  <span className="text-xs font-semibold px-2.5 py-1 rounded-full bg-cyan-950/80 text-cyan-300 border border-cyan-500/30">{spirit.Element}</span>
                </div>
                <p className="text-sm text-slate-400 line-clamp-3 leading-relaxed">{spirit.Description}</p>
              </div>
              <div className="mt-4 pt-4 border-t border-slate-800/80 text-xs font-mono text-emerald-400 font-semibold">
                Drop Rate: {spirit.DropRate}
              </div>
            </div>
          );
        })}
        {SPIRITS_DATA.length === 0 && (
          <div className="col-span-full py-12 text-center text-slate-500">
            Belum ada Spirit di dalam database registry.
          </div>
        )}
      </div>
    </div>
  );
}
