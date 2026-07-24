import { getBadges } from "@/lib/roblox";
import { WebPageElement, WithContext } from "schema-dts";
import Link from "next/link";
import { Trophy, Users } from "lucide-react";

interface PageProps {
  params: Promise<{
    badgeSlug: string;
  }>;
}

export async function generateStaticParams() {
  const badges = await getBadges(10);
  return badges.map((badge) => ({
    badgeSlug: badge.slug,
  }));
}

export async function generateMetadata({ params }: PageProps) {
  const { badgeSlug } = await params;
  const formattedName = badgeSlug.replace(/-/g, " ").toUpperCase();
  return {
    title: `Badge Pencapaian: ${formattedName} | COBLOX`,
    description: `Pelajari cara mendapatkan pencapaian ${formattedName} di COBLOX: Multiverse Alchemy Sanctum.`,
  };
}

export default async function BadgePage({ params }: PageProps) {
  const { badgeSlug } = await params;
  const badges = await getBadges(100);
  
  const badge = badges.find((b) => b.slug === badgeSlug) || {
    id: 999999,
    name: badgeSlug.replace(/-/g, " "),
    description: "Pencapaian misterius.",
    rarityPercent: 0.1,
    slug: badgeSlug,
  };

  const jsonLd: WithContext<WebPageElement> = {
    "@context": "https://schema.org",
    "@type": "WebPageElement",
    name: `Badge: ${badge.name}`,
    description: badge.description,
    about: {
      "@type": "Thing",
      name: badge.name,
      description: badge.description
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
            <li><span className="mx-2">/</span><Link href="/badges" className="hover:text-emerald-400">Badges</Link></li>
            <li aria-current="page"><span className="mx-2">/</span><span className="text-slate-200">{badge.name}</span></li>
          </ol>
        </nav>

        <div className="bg-slate-900/40 border border-white/5 rounded-3xl p-8 backdrop-blur-md">
          <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
            <div className="flex items-center gap-4">
              <div className="w-16 h-16 bg-amber-500/10 border border-amber-500/20 rounded-2xl flex items-center justify-center text-amber-400">
                <Trophy className="w-8 h-8" />
              </div>
              <div>
                <h1 className="text-4xl font-extrabold text-white">{badge.name}</h1>
                <p className="text-slate-400 mt-1">{badge.description}</p>
              </div>
            </div>
            
            <div className="bg-slate-800/50 px-6 py-4 rounded-2xl border border-white/5 text-center min-w-[150px]">
              <div className="flex items-center justify-center gap-2 text-slate-400 text-xs font-bold uppercase tracking-wider mb-2">
                <Users className="w-4 h-4" /> Kelangkaan
              </div>
              <div className="text-3xl font-black text-emerald-400">
                {badge.rarityPercent}%
              </div>
              <div className="text-[10px] text-slate-500 mt-1">Pemain Mendapatkan Ini</div>
            </div>
          </div>
          
          <hr className="my-8 border-white/10" />
          
          <div className="text-center text-slate-400">
            <a 
              href={`https://www.roblox.com/badges/${badge.id}`} 
              target="_blank"
              rel="noopener noreferrer"
              className="inline-block px-6 py-3 bg-white/5 hover:bg-white/10 border border-white/10 rounded-xl font-semibold transition-all"
            >
              Lihat Badge di Roblox
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
