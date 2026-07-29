import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Monetization & Products",
  description: "Informasi tentang GamePass, DevProduct, dan Subscription yang tersedia di COBLOX",
};

const gamePasses = [
  { name: "VIP Sanctum Overlord", price: "499 R$", perks: ["Akses Pet God-Tier", "+50% Aura Multiplier", "Gated VIP Pod Area", "Golden Chat Tag"] },
  { name: "Super Alchemical Luck", price: "399 R$", perks: ["+100% Hatch Luck Boost", "Glow Particle Effect"] },
  { name: "+50 Extra Slots", price: "199 R$", perks: ["+50 Max Inventory Slots"] },
  { name: "Quantum Auto-Hatch", price: "299 R$", perks: ["Continuous Auto Hatching"] },
];

const devProducts = [
  { name: "Gems Small (100)", price: "49 R$", grants: "100 Gems" },
  { name: "Gems Large (1,000)", price: "399 R$", grants: "1,000 Gems" },
  { name: "Coins Small (5,000)", price: "29 R$", grants: "5,000 Coins" },
  { name: "Coins Large (50,000)", price: "249 R$", grants: "50,000 Coins" },
];

export default function MonetizationPage() {
  return (
    <div className="max-w-4xl mx-auto px-4 py-16">
      <Link href="/knowledge-base" className="text-emerald-400 hover:underline text-sm mb-8 inline-block">← Kembali ke Knowledge Base</Link>
      <h1 className="text-4xl font-bold mb-2">Monetization & Products</h1>
      <p className="text-slate-400 mb-8">Informasi tentang GamePass, DevProduct, dan Subscription</p>

      <h2 className="text-2xl font-semibold text-white mb-4">GamePasses</h2>
      <div className="grid gap-4 mb-12">
        {gamePasses.map((gp) => (
          <div key={gp.name} className="p-5 rounded-xl border border-slate-800 bg-slate-900/50">
            <div className="flex justify-between items-start mb-2">
              <h3 className="font-semibold text-white">{gp.name}</h3>
              <span className="text-sm font-bold text-emerald-400">{gp.price}</span>
            </div>
            <ul className="flex flex-wrap gap-2 mt-2">
              {gp.perks.map((p) => (
                <li key={p} className="text-xs bg-slate-800 px-2 py-1 rounded text-slate-300">{p}</li>
              ))}
            </ul>
          </div>
        ))}
      </div>

      <h2 className="text-2xl font-semibold text-white mb-4">Developer Products</h2>
      <div className="grid gap-4 mb-12">
        {devProducts.map((dp) => (
          <div key={dp.name} className="p-5 rounded-xl border border-slate-800 bg-slate-900/50 flex justify-between items-center">
            <div>
              <h3 className="font-semibold text-white">{dp.name}</h3>
              <p className="text-sm text-slate-400">{dp.grants}</p>
            </div>
            <span className="text-sm font-bold text-emerald-400">{dp.price}</span>
          </div>
        ))}
      </div>

      <h2 className="text-1xl font-semibold text-white mb-4">Monthly Alchemist Subscription</h2>
      <div className="p-5 rounded-xl border border-amber-500/30 bg-amber-500/5">
        <p className="text-slate-300"><strong className="text-white">$4.99/bulan</strong> — 500 Gems/hari, +20% EXP Boost, Spirit Fox eksklusif, Golden Name Tag</p>
      </div>
    </div>
  );
}
