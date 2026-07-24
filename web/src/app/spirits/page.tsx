import Link from "next/link";
import { prisma } from "@/lib/db";
import { Metadata } from "next";

export const revalidate = 3600;

export const metadata: Metadata = {
  title: "Direktori Spirit",
  description: "Koleksi lengkap Spirit Companion, kelangkaan, dan kemampuan unik di COBLOX.",
};

export default async function SpiritsPage() {
  const spirits = await prisma.spirit.findMany({
    take: 50,
    orderBy: { rarity: "asc" },
  }).catch(() => []);

  return (
    <div className="max-w-7xl mx-auto px-6 py-16 flex-grow w-full">
      <div className="mb-12">
        <h1 className="text-4xl font-black text-emerald-400 mb-4">Direktori Spirit</h1>
        <p className="text-slate-300">Daftar lengkap kawan Spirit magis yang dapat ditemukan atau ditetaskan.</p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        {spirits.map((spirit) => (
          <Link
            key={spirit.id}
            href={`/spirits/${spirit.slug}`}
            className="p-6 bg-slate-900 border border-white/10 rounded-2xl hover:border-emerald-500/50 transition-all group text-center"
          >
            <div className="text-5xl mb-4 group-hover:scale-110 transition-transform">🐲</div>
            <h2 className="text-xl font-bold text-white group-hover:text-emerald-400 mb-2">{spirit.name}</h2>
            <div className="flex justify-center gap-2 mb-4">
              <span className="text-xs font-semibold px-2 py-1 rounded bg-slate-800 text-slate-300 border border-white/5">{spirit.rarity}</span>
              <span className="text-xs font-semibold px-2 py-1 rounded bg-slate-800 text-cyan-300 border border-white/5">{spirit.element}</span>
            </div>
            <p className="text-sm text-slate-400 line-clamp-2">{spirit.description}</p>
          </Link>
        ))}
        {spirits.length === 0 && (
          <div className="col-span-full py-12 text-center text-slate-500">
            Belum ada Spirit di dalam database.
          </div>
        )}
      </div>
    </div>
  );
}
