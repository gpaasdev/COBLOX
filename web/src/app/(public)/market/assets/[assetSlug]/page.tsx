import { getMarketAssets } from "@/lib/roblox";
import { Product, WithContext } from "schema-dts";
import Link from "next/link";
import { ArrowLeft, ShoppingCart, Tag } from "lucide-react";

interface PageProps {
  params: Promise<{
    assetSlug: string;
  }>;
}

// Generate static params for the top 10 assets to save build time, ISR for the rest
export async function generateStaticParams() {
  const assets = await getMarketAssets(10);
  return assets.map((asset) => ({
    assetSlug: asset.slug,
  }));
}

export async function generateMetadata({ params }: PageProps) {
  const { assetSlug } = await params;
  const formattedName = assetSlug.replace(/-/g, " ").toUpperCase();
  return {
    title: `${formattedName} - Market COBLOX`,
    description: `Beli ${formattedName} di Pasar COBLOX dan dapatkan keuntungan eksklusif di dalam Multiverse Alchemy Sanctum.`,
  };
}

export default async function MarketAssetPage({ params }: PageProps) {
  const { assetSlug } = await params;
  const assets = await getMarketAssets(100);
  
  const asset = assets.find((a) => a.slug === assetSlug) || {
    id: 999999,
    name: assetSlug.replace(/-/g, " "),
    description: "Item eksklusif dari COBLOX.",
    price: 100,
    currency: "Robux",
    category: "Gamepass",
    slug: assetSlug,
    imageUrl: "https://raw.githubusercontent.com/gpaasdev/COBLOX/main/.github/assets/game_thumbnail_16x9.png",
    buyUrl: "",
  };

  const buyUrl =
    asset.buyUrl ||
    (asset.category === "Developer Product"
      ? `https://www.roblox.com/games/${process.env.ROBLOX_PLACE_ID || "105075159736246"}`
      : `https://www.roblox.com/game-pass/${asset.id}`);

  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://gpaasdev.github.io/COBLOX";

  const jsonLd: WithContext<Product> = {
    "@context": "https://schema.org",
    "@type": "Product",
    name: asset.name,
    image: asset.imageUrl,
    description: asset.description,
    category: asset.category,
    offers: {
      "@type": "Offer",
      price: asset.price,
      priceCurrency: asset.currency === "Robux" ? "ROBUX" : asset.currency,
      availability: "https://schema.org/InStock",
      url: `${baseUrl}/market/assets/${asset.slug}`,
      seller: {
        "@type": "Organization",
        name: "COBLOX Studio"
      }
    }
  };

  return (
    <div className="flex-grow bg-slate-950 p-8">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <div className="max-w-4xl mx-auto">
        <nav className="flex text-sm text-slate-400 mb-8" aria-label="Breadcrumb">
          <ol className="inline-flex items-center space-x-2 md:space-x-3">
            <li className="inline-flex items-center">
              <Link href="/" className="hover:text-emerald-400">Beranda</Link>
            </li>
            <li>
              <div className="flex items-center">
                <span className="mx-2">/</span>
                <Link href="/market" className="hover:text-emerald-400">Market</Link>
              </div>
            </li>
            <li aria-current="page">
              <div className="flex items-center">
                <span className="mx-2">/</span>
                <span className="text-slate-200">{asset.name}</span>
              </div>
            </li>
          </ol>
        </nav>

        <div className="bg-slate-900/40 border border-white/5 rounded-3xl p-8 backdrop-blur-md flex flex-col md:flex-row gap-8">
          <div className="w-full md:w-1/3">
             <img src={asset.imageUrl} alt={asset.name} className="w-full h-auto rounded-xl shadow-lg border border-white/10" />
          </div>
          <div className="w-full md:w-2/3">
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-semibold mb-4">
              <Tag className="w-3.5 h-3.5" /> {asset.category}
            </div>
            <h1 className="text-4xl font-extrabold text-white mb-2">{asset.name}</h1>
            <p className="text-slate-400 mb-6">{asset.description}</p>
            
            <div className="flex items-center gap-4 mb-8">
               <span className="text-3xl font-black text-amber-400 flex items-center gap-2">
                 <div className="w-6 h-6 bg-amber-400 rounded-sm"></div>
                 {asset.price} {asset.currency}
               </span>
            </div>

            <a
              href={buyUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="px-6 py-3 bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold rounded-xl flex items-center gap-2 justify-center transition-colors shadow-lg"
            >
              <ShoppingCart className="w-5 h-5" /> {asset.category === "Developer Product" ? "Beli di Dalam Game" : "Beli di Roblox"}
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
