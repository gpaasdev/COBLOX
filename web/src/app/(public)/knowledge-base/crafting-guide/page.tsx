import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Crafting & Alchemy Guide",
  description: "Panduan lengkap sistem crafting 3x3, elemental reactions, dan transmutation di COBLOX",
};

export default function CraftingGuidePage() {
  return (
    <div className="max-w-3xl mx-auto px-4 py-16">
      <Link href="/knowledge-base" className="text-emerald-400 hover:underline text-sm mb-8 inline-block">← Kembali ke Knowledge Base</Link>
      <h1 className="text-4xl font-bold mb-2">Crafting & Alchemy Guide</h1>
      <p className="text-slate-400 mb-8">Panduan lengkap sistem crafting 3x3, elemental reactions, dan transmutation</p>

      <div className="prose prose-invert max-w-none space-y-6 text-slate-300">
        <h2 className="text-xl font-semibold text-white">Alchemy Synthesis Vessel</h2>
        <p>Sistem crafting COBLOX menggunakan grid 3x3 — tempatkan material di slot yang tersedia dan racik untuk menciptakan item baru. Setiap kombinasi material menghasilkan output yang berbeda.</p>
        
        <h2 className="text-xl font-semibold text-white mt-8">Resep Dasar</h2>
        <ul className="list-disc pl-6 space-y-2">
          <li><strong>3× Quartz</strong> → QuartzAltar_Tier1 (Struktur)</li>
          <li><strong>3× AstralIron</strong> → AstralGenerator_Tier2 (Struktur)</li>
          <li><strong>2× PyroEssence</strong> → PyroBuffPotion_Tier2 (Consumable)</li>
        </ul>

        <h2 className="text-xl font-semibold text-white mt-8">Elemental Reactions</h2>
        <p>Menggabungkan elemen berbeda dalam grid akan memicu elemental reaction yang meningkatkan yield:</p>
        <ul className="list-disc pl-6 space-y-2">
          <li><strong>Pyro + Hydro</strong> → Vaporize (2.5x multiplier)</li>
          <li><strong>Pyro + Cryo</strong> → Melt (2.0x multiplier)</li>
          <li><strong>Electro + Hydro</strong> → Electro-Charged (1.8x multiplier)</li>
        </ul>

        <h2 className="text-xl font-semibold text-white mt-8">Tips</h2>
        <ul className="list-disc pl-6 space-y-2">
          <li>Gunakan material berkualitas tinggi untuk hasil lebih baik</li>
          <li>Kombinasikan elemen berbeda untuk reaksi elemental</li>
          <li>Crafting membutuhkan cooldown — atur waktu dengan bijak</li>
        </ul>
      </div>
    </div>
  );
}
