import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Spirit Companion Guide",
  description: "Cara menetaskan, meng-evolusi, dan membangkitkan Spirit Companion di COBLOX",
};

export default function SpiritGuidePage() {
  return (
    <div className="max-w-3xl mx-auto px-4 py-16">
      <Link href="/knowledge-base" className="text-emerald-400 hover:underline text-sm mb-8 inline-block">← Kembali ke Knowledge Base</Link>
      <h1 className="text-4xl font-bold mb-2">Spirit Companion System</h1>
      <p className="text-slate-400 mb-8">Cara menetaskan, meng-evolusi, dan membangkitkan Spirit Companion</p>

      <div className="prose prose-invert max-w-none space-y-6 text-slate-300">
        <h2 className="text-xl font-semibold text-white">Hatching (Penetasan)</h2>
        <p>Kumpulkan telur (Egg) dari berbagai sumber seperti event, pembelian, atau hadiah. Bawa telur ke Genesis Pod untuk menetaskannya. Setiap telur memiliki rarity yang berbeda: Common, Uncommon, Rare, Epic, Legendary, Mythic.</p>

        <h2 className="text-xl font-semibold text-white mt-8">Fusion</h2>
        <p>Gabungkan dua Spirit dengan level dan rarity tertentu untuk menciptakan Spirit yang lebih kuat. Fusion mempertahankan statistik terbaik dari kedua induk dan menambahkan bonus.</p>

        <h2 className="text-xl font-semibold text-white mt-8">Awakening</h2>
        <p>Spirit yang telah mencapai level maksimum dapat di-Awaken untuk membuka potensi baru. Awakening meningkatkan multiplier, membuka ability baru, dan mengubah penampilan Spirit.</p>

        <h2 className="text-xl font-semibold text-white mt-8">Pet Mining</h2>
        <p>Spirit yang sudah aktif dapat secara otomatis menambang resource saat Anda menjelajah. Semakin tinggi level Spirit, semakin besar yield yang dihasilkan.</p>
      </div>
    </div>
  );
}
