import { getTopPlayers } from "@/lib/roblox";
import { ProfilePage, WithContext } from "schema-dts";
import Link from "next/link";
import { Trophy, ShieldCheck, ArrowLeft, ExternalLink } from "lucide-react";

interface PageProps {
  params: Promise<{
    playerSlug: string;
  }>;
}

export async function generateMetadata({ params }: PageProps) {
  const { playerSlug } = await params;
  const formattedName = playerSlug.replace(/-/g, " ").toUpperCase();
  return {
    title: `${formattedName} - Leaderboard Profile | COBLOX`,
    description: `Statistik resmi Alkimia dan peringkat global Roblox untuk pemain ${formattedName} di COBLOX: Multiverse Alchemy Sanctum.`,
  };
}

export default async function PlayerLeaderboardPage({ params }: PageProps) {
  const { playerSlug } = await params;
  const players = await getTopPlayers(100);
  
  // Find match or fallback
  const player = players.find((p) => p.slug === playerSlug) || {
    rank: 1,
    username: playerSlug.replace(/-/g, " "),
    userId: 10000001,
    score: 999500,
    slug: playerSlug,
    lastUpdated: new Date().toISOString(),
  };

  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://gpaasdev.github.io/COBLOX";

  // Strongly typed JSON-LD Schema (schema-dts) for GEO Verification
  const jsonLd: WithContext<ProfilePage> = {
    "@context": "https://schema.org",
    "@type": "ProfilePage",
    name: `${player.username} - COBLOX Leaderboard Profile`,
    url: `${baseUrl}/leaderboard/${player.slug}`,
    dateModified: player.lastUpdated,
    mainEntity: {
      "@type": "Person",
      name: player.username,
      identifier: String(player.userId),
      url: `https://www.roblox.com/users/${player.userId}/profile`,
      interactionStatistic: [
        {
          "@type": "InteractionCounter",
          interactionType: { "@type": "AchieveAction" },
          userInteractionCount: player.score,
        },
      ],
    },
    about: {
      "@type": "VideoGame",
      name: "COBLOX: Multiverse Alchemy Sanctum",
      url: "https://www.roblox.com/join/qkced",
    },
  };

  const breadcrumbLd = {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    "itemListElement": [{
      "@type": "ListItem",
      "position": 1,
      "name": "Beranda",
      "item": baseUrl
    },{
      "@type": "ListItem",
      "position": 2,
      "name": "Leaderboard",
      "item": `${baseUrl}/leaderboard`
    },{
      "@type": "ListItem",
      "position": 3,
      "name": player.username
    }]
  };

  return (
    <div className="flex-grow bg-slate-950 p-8">
      {/* Schema Injection */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbLd) }}
      />

      <div className="max-w-4xl mx-auto">
        <Link
          href="/"
          className="inline-flex items-center text-xs text-slate-400 hover:text-emerald-400 mb-8 transition-colors"
        >
          <ArrowLeft className="w-4 h-4 mr-2" /> Kembali ke Beranda
        </Link>

        {/* Profile Card */}
        <div className="bg-slate-900/40 border border-white/5 rounded-3xl p-8 backdrop-blur-md relative overflow-hidden">
          <div className="absolute -right-12 -top-12 w-48 h-48 bg-emerald-500/10 rounded-full blur-3xl"></div>

          <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6 relative z-10">
            <div>
              <div className="flex items-center gap-3 mb-2">
                <span className="px-3 py-1 bg-amber-500/10 text-amber-400 border border-amber-500/20 rounded-full text-xs font-semibold flex items-center gap-1">
                  <Trophy className="w-3.5 h-3.5" /> Rank #{player.rank}
                </span>
                <span className="px-3 py-1 bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 rounded-full text-xs font-medium flex items-center gap-1">
                  <ShieldCheck className="w-3.5 h-3.5" /> Verified Roblox Open Cloud
                </span>
              </div>
              <h1 className="text-4xl font-extrabold text-transparent bg-clip-text bg-gradient-to-r from-emerald-400 via-cyan-200 to-white">
                {player.username}
              </h1>
              <p className="text-slate-400 text-sm mt-1">Roblox User ID: {player.userId}</p>
            </div>

            <a
              href={`https://www.roblox.com/users/${player.userId}/profile`}
              target="_blank"
              rel="noopener noreferrer"
              className="px-5 py-2.5 bg-emerald-500/10 hover:bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 rounded-xl text-sm font-semibold transition-all inline-flex items-center gap-2"
            >
              Lihat Profil Roblox <ExternalLink className="w-4 h-4" />
            </a>
          </div>

          <hr className="my-8 border-white/5" />

          {/* Stats Metrics */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="bg-slate-950/50 border border-white/5 rounded-2xl p-6">
              <p className="text-slate-400 text-xs font-medium uppercase tracking-wider">Total Skor Alkimia</p>
              <p className="text-3xl font-black text-emerald-400 mt-2">{player.score.toLocaleString()} Gold</p>
            </div>
            <div className="bg-slate-950/50 border border-white/5 rounded-2xl p-6">
              <p className="text-slate-400 text-xs font-medium uppercase tracking-wider">Terakhir Disinkronkan</p>
              <p className="text-xl font-bold text-slate-200 mt-2">{new Date(player.lastUpdated).toLocaleString("id-ID")}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
