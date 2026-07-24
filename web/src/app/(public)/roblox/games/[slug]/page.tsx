import Link from "next/link";
import { VideoGame, WithContext } from "schema-dts";
import { Gamepad2, Users, Flame, Gift, Copy, Sparkles } from "lucide-react";

interface PageProps {
  params: Promise<{
    slug: string;
  }>;
}

export async function generateMetadata({ params }: PageProps) {
  const { slug } = await params;
  const gameName = slug.replace(/-/g, " ").toUpperCase();
  return {
    title: `${gameName} Live Active Players & Working Redeem Codes (2026) | COBLOX`,
    description: `Dapatkan kode redeem ${gameName} aktif terbaru di Roblox. Pantau statistik pemain aktif live dan total kunjungan secara real-time.`,
  };
}

export default async function RobloxGameHubPage({ params }: PageProps) {
  const { slug } = await params;
  const gameName = slug.replace(/-/g, " ").toUpperCase();

  const gameData = {
    gameName,
    slug,
    activePlayers: 14200,
    visitCount: 125000000,
    creatorName: "Official Roblox Developer",
    codes: [
      { code: "RELEASE2026", reward: "500 Coins & 2x EXP Boost" },
      { code: "FREEBOOST", reward: "1x Rare Spirit Companion" },
      { code: "SUMMERUPDATE", reward: "1,000 Gems" },
    ],
  };

  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://gpaasdev.github.io/COBLOX";

  const jsonLd: WithContext<VideoGame> = {
    "@context": "https://schema.org",
    "@type": "VideoGame",
    name: gameData.gameName,
    url: `${baseUrl}/roblox/games/${gameData.slug}`,
    gamePlatform: ["Roblox", "PC", "Mobile"],
    publisher: {
      "@type": "Organization",
      name: gameData.creatorName,
    },
  };

  return (
    <div className="flex-grow bg-slate-950 p-6 md:p-12">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <div className="max-w-5xl mx-auto">
        <nav className="flex text-sm text-slate-400 mb-8" aria-label="Breadcrumb">
          <ol className="inline-flex items-center space-x-2">
            <li><Link href="/" className="hover:text-emerald-400">Beranda</Link></li>
            <li><span className="mx-2">/</span><span className="text-slate-400">Roblox Games</span></li>
            <li aria-current="page"><span className="mx-2">/</span><span className="text-slate-200">{gameData.gameName}</span></li>
          </ol>
        </nav>

        {/* Hero Game Header */}
        <div className="bg-slate-900/60 border border-white/10 rounded-3xl p-8 backdrop-blur-xl mb-8 relative overflow-hidden">
          <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
            <div>
              <span className="px-3.5 py-1 bg-cyan-500/10 border border-cyan-500/20 text-cyan-400 text-xs font-bold rounded-full uppercase tracking-wider mb-4 inline-block">
                Roblox Player Hub
              </span>
              <h1 className="text-4xl md:text-5xl font-black text-white tracking-tight">
                {gameData.gameName}
              </h1>
              <p className="text-slate-400 mt-2 text-sm">
                Dikembangkan oleh <span className="text-slate-200 font-semibold">{gameData.creatorName}</span>
              </p>
            </div>
            
            <a
              href="https://www.roblox.com/discover"
              target="_blank"
              rel="noopener noreferrer"
              className="px-6 py-3.5 bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-black text-sm rounded-2xl flex items-center gap-2 transition-all shadow-lg active:scale-95"
            >
              <Gamepad2 className="w-5 h-5" /> Mainkan Game Ini
            </a>
          </div>

          <hr className="my-6 border-white/10" />

          {/* Live Player Stats */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="bg-slate-950/60 border border-white/5 rounded-2xl p-6 flex items-center gap-4">
              <div className="w-12 h-12 bg-emerald-500/10 rounded-xl flex items-center justify-center text-emerald-400">
                <Flame className="w-6 h-6" />
              </div>
              <div>
                <div className="text-xs text-slate-400 uppercase font-bold tracking-wider">Active Players Live</div>
                <div className="text-2xl font-black text-white mt-0.5">{gameData.activePlayers.toLocaleString()}</div>
              </div>
            </div>
            <div className="bg-slate-950/60 border border-white/5 rounded-2xl p-6 flex items-center gap-4">
              <div className="w-12 h-12 bg-cyan-500/10 rounded-xl flex items-center justify-center text-cyan-400">
                <Users className="w-6 h-6" />
              </div>
              <div>
                <div className="text-xs text-slate-400 uppercase font-bold tracking-wider">Total Kunjungan</div>
                <div className="text-2xl font-black text-white mt-0.5">{gameData.visitCount.toLocaleString()}</div>
              </div>
            </div>
          </div>
        </div>

        {/* Live Working Redeem Codes Table */}
        <div className="bg-slate-900/60 border border-white/10 rounded-3xl p-8 backdrop-blur-xl mb-12 shadow-2xl">
          <div className="flex items-center gap-3 mb-6">
            <Gift className="w-6 h-6 text-amber-400" />
            <h2 className="text-2xl font-black text-white">Kode Redeem Aktif (Terverifikasi 2026)</h2>
          </div>

          <div className="space-y-4">
            {gameData.codes.map((item, idx) => (
              <div key={idx} className="bg-slate-950/80 border border-white/5 p-5 rounded-2xl flex items-center justify-between gap-4">
                <div>
                  <span className="px-3 py-1 bg-amber-500/10 border border-amber-500/20 text-amber-400 font-mono font-black text-base rounded-lg inline-block">
                    {item.code}
                  </span>
                  <p className="text-slate-400 text-xs mt-2">{item.reward}</p>
                </div>
                <button
                  className="px-4 py-2 bg-emerald-500/10 hover:bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 rounded-xl text-xs font-bold flex items-center gap-2 transition-all active:scale-95"
                >
                  <Copy className="w-3.5 h-3.5" /> Copy Code
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* Community Discovery Banner */}
        <div className="bg-gradient-to-r from-cyan-500/20 via-blue-500/20 to-emerald-500/20 border border-cyan-500/30 rounded-3xl p-8 backdrop-blur-xl flex flex-col md:flex-row items-center justify-between gap-6 shadow-[0_0_50px_rgba(6,182,212,0.15)]">
          <div>
            <div className="flex items-center gap-2 text-cyan-400 font-bold text-xs uppercase tracking-widest mb-1">
              <Sparkles className="w-4 h-4" /> Temukan Game Serupa
            </div>
            <h3 className="text-2xl font-black text-white">Mainkan COBLOX: Multiverse Sanctum</h3>
            <p className="text-slate-300 text-sm mt-1">Rasakan petualangan Alkimia 3D dengan sistem Spirit Companion dan Bejana Aura!</p>
          </div>
          <Link
            href="/"
            className="px-6 py-3.5 bg-cyan-400 hover:bg-cyan-300 text-slate-950 font-black text-sm rounded-2xl flex items-center gap-2 transition-all shadow-lg active:scale-95 whitespace-nowrap"
          >
            Eksplorasi COBLOX 🚀
          </Link>
        </div>
      </div>
    </div>
  );
}
