import Link from "next/link";
import { prisma } from "@/lib/db";
import { Metadata } from "next";

export const revalidate = 3600;

export const metadata: Metadata = {
  title: "Pasar Aset & Gamepass",
  description: "Telusuri seluruh katalog item, gamepass VIP, dan produk developer resmi COBLOX.",
};

export default async function MarketPage() {
  const assets = await prisma.marketAsset.findMany({
    take: 50,
    orderBy: { price: "desc" },
  }).catch(() => []);

  return (
    <div className="max-w-7xl mx-auto px-6 py-16 flex-grow w-full">
      <div className="mb-12">
        <h1 className="text-4xl font-black text-emerald-400 mb-4">Pasar Aset</h1>
        <p className="text-slate-300">Katalog resmi Gamepass, produk, dan item eksklusif dari developer.</p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        {assets.map((asset) => (
          <Link
            key={asset.id}
            href={`/market/assets/${asset.slug}`}
            className="p-6 bg-slate-900 border border-white/10 rounded-2xl hover:border-emerald-500/50 transition-all group flex flex-col h-full"
          >
            {asset.imageUrl && (
              <div className="w-full h-40 bg-slate-800 rounded-lg mb-4 overflow-hidden flex items-center justify-center">
                <img src={asset.imageUrl} alt={asset.name} className="w-full h-full object-cover group-hover:scale-105 transition-transform" />
              </div>
            )}
            <h2 className="text-lg font-bold text-white group-hover:text-emerald-400 mb-2">{asset.name}</h2>
            <p className="text-sm text-slate-400 line-clamp-2 mb-4 flex-grow">{asset.description}</p>
            <div className="flex justify-between items-center mt-auto">
              <span className="text-xs font-semibold text-slate-500 uppercase tracking-widest">{asset.category}</span>
              <span className="text-sm font-black text-emerald-400 bg-emerald-400/10 px-2 py-1 rounded">
                {asset.price > 0 ? `${asset.price} ${asset.currency}` : "FREE"}
              </span>
            </div>
          </Link>
        ))}
        {assets.length === 0 && (
          <div className="col-span-full py-12 text-center text-slate-500">
            Belum ada aset di pasar.
          </div>
        )}
      </div>
    </div>
  );
}
