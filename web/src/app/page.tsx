import Image from "next/image";
import Link from "next/link";
import { getUniverseStats } from "@/lib/roblox";

export default async function Home() {
  const universeData = await getUniverseStats().catch(() => null);

  const stats = [
    {
      label: "Active Alchemists",
      value: universeData?.playing ? universeData.playing.toLocaleString() : "1,420+",
      change: "+12.4% live",
      icon: "⚡",
    },
    {
      label: "Total Visits",
      value: universeData?.visits ? universeData.visits.toLocaleString() : "2.8M+",
      change: "Milestone",
      icon: "🌐",
    },
    {
      label: "Alchemical Fusion Rating",
      value: "98.4%",
      change: "Super Positive",
      icon: "⭐",
    },
    {
      label: "Sanctum Grid Engine",
      value: "v11.0 LGBOS",
      change: "Zero-Trust SOA",
      icon: "🛡️",
    },
  ];

  const topAlchemists = [
    { rank: "01", name: "IgnisMaster99", score: "9,850,400 Aura", companion: "Celestial Phoenix", slug: "ignismaster99" },
    { rank: "02", name: "AuraSynthesizer", score: "8,420,100 Aura", companion: "Void Dragon", slug: "aurasynthesizer" },
    { rank: "03", name: "QuantumAlchemist", score: "7,110,950 Aura", companion: "Starlight Golem", slug: "quantumalchemist" },
  ];

  return (
    <main className="min-h-screen bg-slate-950 text-slate-50 font-sans selection:bg-emerald-500/30">
      {/* Navigation Bar */}
      <nav className="fixed top-0 w-full z-50 bg-slate-950/85 backdrop-blur-xl border-b border-white/10 shadow-2xl">
        <div className="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-gradient-to-br from-emerald-400 via-teal-500 to-cyan-500 rounded-xl flex items-center justify-center font-black text-slate-950 text-xl shadow-[0_0_20px_rgba(52,211,153,0.5)]">
              C
            </div>
            <div className="flex flex-col">
              <span className="font-extrabold text-xl tracking-wider bg-clip-text text-transparent bg-gradient-to-r from-emerald-400 via-cyan-300 to-blue-400">
                COBLOX
              </span>
              <span className="text-[10px] uppercase font-bold tracking-widest text-emerald-400/80 -mt-1">
                Multiverse Sanctum
              </span>
            </div>
          </div>

          <div className="hidden md:flex items-center gap-8 text-sm font-medium text-slate-300">
            <Link href="#stats" className="hover:text-emerald-400 transition-colors">Stats</Link>
            <Link href="#features" className="hover:text-emerald-400 transition-colors">Features</Link>
            <Link href="#leaderboard" className="hover:text-emerald-400 transition-colors">Leaderboard</Link>
            <Link href="#economy" className="hover:text-emerald-400 transition-colors">Economy</Link>
          </div>

          <div className="flex items-center gap-4">
            <Link
              href="/api/auth/signin"
              className="px-4 py-2 text-xs font-semibold text-slate-300 bg-white/5 border border-white/10 rounded-lg hover:bg-white/10 hover:text-white transition-all"
            >
              🔐 Admin Login
            </Link>
            <Link
              href="https://www.roblox.com/join/qkced"
              target="_blank"
              className="px-5 py-2.5 bg-gradient-to-r from-emerald-400 via-teal-400 to-cyan-400 text-slate-950 font-extrabold text-sm rounded-full hover:brightness-110 active:scale-95 transition-all shadow-[0_0_25px_rgba(52,211,153,0.4)]"
            >
              Play on Roblox 🚀
            </Link>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="relative pt-36 pb-20 px-6 overflow-hidden">
        {/* Glowing Orbs Background */}
        <div className="absolute top-1/3 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[700px] bg-emerald-500/15 rounded-full blur-[140px] pointer-events-none" />
        <div className="absolute top-10 right-10 w-[500px] h-[500px] bg-cyan-500/15 rounded-full blur-[120px] pointer-events-none" />
        
        <div className="max-w-7xl mx-auto text-center relative z-10 flex flex-col items-center">
          <div className="inline-flex items-center gap-2.5 px-4 py-2 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-300 text-xs font-semibold mb-8 backdrop-blur-md shadow-lg">
            <span className="relative flex h-2.5 w-2.5">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500"></span>
            </span>
            <span>Multiverse Alchemy Sanctum v11.0 Live</span>
          </div>
          
          <h1 className="text-5xl md:text-7xl lg:text-8xl font-black tracking-tight mb-8 leading-none">
            Master The <br className="hidden sm:block" />
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-400 via-teal-300 to-cyan-400">
              Alchemical Elements
            </span>
          </h1>
          
          <p className="text-lg md:text-xl text-slate-300 max-w-3xl mb-12 leading-relaxed font-normal">
            Pengalaman Hybrid Pet Tycoon & Social Action Alkimia terdepan di Roblox. Susun Bejana Aura 3x3, racik elemen magis, dan tetaskan Spirit Companion legendaris.
          </p>

          <div className="flex flex-wrap justify-center gap-4 mb-16">
            <Link
              href="https://www.roblox.com/join/qkced"
              target="_blank"
              className="px-8 py-4 bg-emerald-400 text-slate-950 font-black text-base rounded-2xl hover:bg-emerald-300 transition-all shadow-[0_0_30px_rgba(52,211,153,0.5)] active:scale-95"
            >
              Enter Sanctum Now
            </Link>
            <Link
              href="#leaderboard"
              className="px-8 py-4 bg-white/5 border border-white/10 text-slate-200 font-bold text-base rounded-2xl hover:bg-white/10 transition-all backdrop-blur-sm"
            >
              View Global Leaderboard
            </Link>
          </div>
          
          {/* Key Art Showcase */}
          <div className="relative group w-full max-w-5xl mx-auto rounded-3xl overflow-hidden border border-white/15 shadow-2xl shadow-emerald-500/20 bg-slate-900/80">
            <img 
              src="https://raw.githubusercontent.com/gpaasdev/COBLOX/main/.github/assets/game_thumbnail_16x9.png" 
              alt="COBLOX Gameplay Showcase" 
              className="w-full h-auto aspect-video object-cover transition-transform duration-700 group-hover:scale-105"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-slate-950 via-slate-950/20 to-transparent opacity-80" />
            <div className="absolute bottom-6 left-6 right-6 flex items-center justify-between text-left">
              <div>
                <span className="text-xs uppercase font-bold text-emerald-400 tracking-wider">Engine Status</span>
                <h3 className="text-lg font-bold text-white">Server-Authoritative Zero-Trust Matrix</h3>
              </div>
              <span className="px-3 py-1 bg-emerald-500/20 border border-emerald-500/40 text-emerald-300 text-xs font-mono rounded-lg">
                &lt; 2.5 GB RAM Target
              </span>
            </div>
          </div>
        </div>
      </section>

      {/* Live Stats Bar */}
      <section id="stats" className="py-12 border-y border-white/10 bg-slate-900/60 backdrop-blur-lg">
        <div className="max-w-7xl mx-auto px-6 grid grid-cols-2 md:grid-cols-4 gap-8">
          {stats.map((stat, i) => (
            <div key={i} className="flex flex-col items-center text-center p-4">
              <span className="text-3xl mb-2">{stat.icon}</span>
              <span className="text-3xl md:text-4xl font-black text-white tracking-tight">{stat.value}</span>
              <span className="text-xs font-medium text-slate-400 mt-1">{stat.label}</span>
              <span className="text-[11px] font-bold text-emerald-400 mt-0.5">{stat.change}</span>
            </div>
          ))}
        </div>
      </section>

      {/* Features Grid */}
      <section id="features" className="py-24 px-6 relative">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-5xl font-black mb-4 bg-clip-text text-transparent bg-gradient-to-r from-white via-slate-200 to-slate-400">
              Architectural Excellence
            </h2>
            <p className="text-slate-400 max-w-xl mx-auto text-base">
              Dipertajam dengan arsitektur SOA Luau (--!strict), ProfileStore v3 session locking, dan komputasi presisi tinggi.
            </p>
          </div>
          
          <div className="grid md:grid-cols-3 gap-8">
            {[
              {
                title: "Sanctum Grid 3x3",
                desc: "Tata bejana aura, extractor, dan altar kristal secara bebas dalam matriks spatial berkoordinat presisi.",
                icon: "🔮",
                badge: "Core Gameplay"
              },
              {
                title: "Spirit Companions",
                desc: "Tetaskan Spirit Companion dengan spring feedback physics & particle pooling (< 20 active particles/emitter).",
                icon: "🐉",
                badge: "Spring Physics"
              },
              {
                title: "Zero-Trust Security",
                desc: "Validasi server-authoritative penuh untuk interaksi jarak (<= 15 studs) dan anti-duplikasi transaksi.",
                icon: "🛡️",
                badge: "Anti-Cheat"
              }
            ].map((feature, i) => (
              <div key={i} className="bg-slate-900/60 border border-white/10 p-8 rounded-3xl hover:border-emerald-500/40 transition-all hover:-translate-y-1.5 shadow-xl hover:shadow-[0_10px_35px_rgba(52,211,153,0.15)] group relative overflow-hidden">
                <div className="flex items-center justify-between mb-6">
                  <div className="w-14 h-14 bg-white/5 rounded-2xl flex items-center justify-center text-3xl group-hover:scale-110 transition-transform border border-white/10">
                    {feature.icon}
                  </div>
                  <span className="text-[11px] font-bold text-emerald-400 bg-emerald-500/10 px-3 py-1 rounded-full border border-emerald-500/20">
                    {feature.badge}
                  </span>
                </div>
                <h3 className="text-xl font-extrabold mb-3 text-slate-100">{feature.title}</h3>
                <p className="text-slate-400 text-sm leading-relaxed">{feature.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Live Leaderboard Preview */}
      <section id="leaderboard" className="py-24 px-6 border-t border-white/10 bg-slate-900/40">
        <div className="max-w-5xl mx-auto">
          <div className="text-center mb-16">
            <span className="text-xs uppercase tracking-widest font-bold text-emerald-400">Global Alchemists</span>
            <h2 className="text-3xl md:text-5xl font-black mt-2 mb-4">Top Leaderboard</h2>
            <p className="text-slate-400">Peringkat alkimis terunggul di seluruh Multiverse Sanctum.</p>
          </div>

          <div className="space-y-4">
            {topAlchemists.map((player, idx) => (
              <Link 
                key={idx} 
                href={`/leaderboard/${player.slug}`}
                className="flex items-center justify-between p-6 bg-slate-900 border border-white/10 rounded-2xl hover:border-emerald-500/40 hover:bg-slate-850 transition-all group shadow-md"
              >
                <div className="flex items-center gap-6">
                  <span className="text-2xl font-black text-emerald-400 font-mono w-8">{player.rank}</span>
                  <div>
                    <h3 className="font-extrabold text-lg text-white group-hover:text-emerald-300 transition-colors">
                      {player.name}
                    </h3>
                    <p className="text-xs text-slate-400">Companion: <span className="text-cyan-300 font-semibold">{player.companion}</span></p>
                  </div>
                </div>
                <div className="text-right">
                  <span className="text-base font-black text-emerald-400 font-mono">{player.score}</span>
                  <span className="block text-[10px] text-slate-500 uppercase tracking-widest font-bold">Verified JSON-LD</span>
                </div>
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* Footer & Admin Link */}
      <footer className="border-t border-white/10 py-16 px-6 text-center text-slate-400 text-sm bg-slate-950">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row items-center justify-between gap-8">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 bg-emerald-400 rounded-lg flex items-center justify-center font-black text-slate-950">C</div>
            <span className="font-extrabold text-white text-lg tracking-wider">COBLOX Studio</span>
          </div>

          <p className="text-xs text-slate-500">© 2026 COBLOX Studio. All rights reserved. Deployed on Vercel.</p>

          <div className="flex items-center gap-6 text-xs font-semibold">
            <Link href="/api/auth/signin" className="hover:text-emerald-400 transition-colors">
              🔐 Admin Sign-In
            </Link>
            <Link href="/admin" className="hover:text-emerald-400 transition-colors">
              📊 Admin Portal
            </Link>
            <Link href="https://github.com/gpaasdev/COBLOX" target="_blank" className="hover:text-emerald-400 transition-colors">
              GitHub Repo
            </Link>
          </div>
        </div>
      </footer>
    </main>
  );
}
