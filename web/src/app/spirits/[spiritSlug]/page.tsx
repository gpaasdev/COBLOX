import { getSpirits } from "@/lib/roblox";
import { Article, WithContext } from "schema-dts";
import Link from "next/link";
import { Sparkles, Activity } from "lucide-react";

interface PageProps {
  params: Promise<{
    spiritSlug: string;
  }>;
}

export async function generateStaticParams() {
  const spirits = await getSpirits(10);
  return spirits.map((spirit) => ({
    spiritSlug: spirit.slug,
  }));
}

export async function generateMetadata({ params }: PageProps) {
  const { spiritSlug } = await params;
  const formattedName = spiritSlug.replace(/-/g, " ").toUpperCase();
  return {
    title: `Spirit Companion: ${formattedName} | COBLOX`,
    description: `Statistik, elemen, dan kelangkaan Spirit Companion ${formattedName} di COBLOX: Multiverse Alchemy Sanctum.`,
  };
}

export default async function SpiritPage({ params }: PageProps) {
  const { spiritSlug } = await params;
  const spirits = await getSpirits(100);
  
  const spirit = spirits.find((s) => s.slug === spiritSlug) || {
    id: "SPR-999",
    name: spiritSlug.replace(/-/g, " "),
    description: "Spirit rahasia dari dimensi lain.",
    rarity: "Unknown",
    element: "Unknown",
    dropRate: "0.01%",
    slug: spiritSlug,
  };

  const jsonLd: WithContext<Article> = {
    "@context": "https://schema.org",
    "@type": "Article",
    headline: `Mengenal Spirit ${spirit.name}`,
    description: spirit.description,
    author: {
      "@type": "Organization",
      name: "COBLOX Studio"
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
            <li><Link href="/" className="hover:text-emerald-400">Beranda</Link></li>
            <li><span className="mx-2">/</span><Link href="/spirits" className="hover:text-emerald-400">Spirits</Link></li>
            <li aria-current="page"><span className="mx-2">/</span><span className="text-slate-200">{spirit.name}</span></li>
          </ol>
        </nav>

        <div className="bg-slate-900/40 border border-white/5 rounded-3xl p-8 backdrop-blur-md">
          <div className="flex items-center gap-4 mb-6">
            <div className="w-16 h-16 bg-cyan-500/10 border border-cyan-500/20 rounded-2xl flex items-center justify-center text-cyan-400">
              <Sparkles className="w-8 h-8" />
            </div>
            <div>
              <h1 className="text-4xl font-extrabold text-white">{spirit.name}</h1>
              <p className="text-slate-400 mt-1">{spirit.description}</p>
            </div>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-8">
            <div className="bg-slate-800/50 rounded-xl p-6 border border-white/5 text-center">
               <div className="text-slate-400 text-sm font-semibold uppercase tracking-wider mb-2">Rarity</div>
               <div className="text-2xl font-black text-purple-400">{spirit.rarity}</div>
            </div>
            <div className="bg-slate-800/50 rounded-xl p-6 border border-white/5 text-center">
               <div className="text-slate-400 text-sm font-semibold uppercase tracking-wider mb-2">Element</div>
               <div className="text-2xl font-black text-amber-400">{spirit.element}</div>
            </div>
            <div className="bg-slate-800/50 rounded-xl p-6 border border-white/5 text-center">
               <div className="text-slate-400 text-sm font-semibold uppercase tracking-wider mb-2 flex items-center justify-center gap-2">
                 <Activity className="w-4 h-4" /> Drop Rate
               </div>
               <div className="text-2xl font-black text-emerald-400">{spirit.dropRate}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
