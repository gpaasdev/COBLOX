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
    <div className="flex flex-col flex-grow">
      {/* Hero Section */}
      <section className="relative pt-36 pb-20 px-6 overflow-hidden">
        <div className="absolute top-1/3 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[700px] bg-emerald-500/15 rounded-full blur-[140px] pointer-events-none" />
        <div className="absolute top-10 right-10 w-[500px] h-[500px] bg-cyan-500/15 rounded-full blur-[120px] pointer-events-none" />
        
        <div className="max-w-7xl mx-auto text-center relative z-10 flex flex-col items-center">
          <div className="inline-flex items-center gap-2.5 px-4 py-2 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-300 text-xs font-semibold mb-8 backdrop-blur-md shadow-lg">
            <span className="relative flex h-2.5 w-2.5">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500"></span>
            </span>
            <span>Uji Coba Alpha Terbuka Dibuka</span>
          </div>
          
          <h1 className="text-5xl md:text-7xl lg:text-8xl font-black tracking-tight mb-8 leading-none">
            Temukan Keajaiban <br className="hidden sm:block" />
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-400 via-teal-300 to-cyan-400">
              Alkimia Impianmu
            </span>
          </h1>
          
          <p className="text-lg md:text-xl text-slate-300 max-w-3xl mb-12 leading-relaxed font-normal">
            Selamat datang di dunia magis COBLOX: Multiverse Alchemy Sanctum! Tempat kamu bisa meracik elemen rahasia, merawat kawan Spirit bernyawa magis, dan membangun tempat tinggal alkemia yang unik.
          </p>

          <div className="flex flex-wrap justify-center gap-4 mb-16">
            <Link
              href="https://www.roblox.com/join/qkced"
              target="_blank"
              className="px-8 py-4 bg-emerald-400 text-slate-950 font-black text-base rounded-2xl hover:bg-emerald-300 transition-all shadow-[0_0_30px_rgba(52,211,153,0.5)] active:scale-95"
            >
              Mulai Petualangan
            </Link>
            <Link
              href="#directories"
              className="px-8 py-4 bg-white/5 border border-white/10 text-slate-200 font-bold text-base rounded-2xl hover:bg-white/10 transition-all backdrop-blur-sm"
            >
              Lihat Resep Magis
            </Link>
          </div>
          
          {/* Key Art Showcase */}
          <div className="relative group w-full max-w-5xl mx-auto rounded-3xl overflow-hidden border border-emerald-500/30 shadow-[0_16px_50px_rgba(6,182,212,0.3)] bg-slate-900/80">
            <img 
              src="https://raw.githubusercontent.com/gpaasdev/COBLOX/main/.github/assets/game_thumbnail_16x9.png" 
              alt="COBLOX Gameplay Showcase" 
              className="w-full h-auto aspect-video object-cover transition-transform duration-700 group-hover:scale-105"
            />
          </div>
        </div>
      </section>

      {/* Live Stats Bar */}
      <section className="py-12 border-y border-white/10 bg-slate-900/60 backdrop-blur-lg">
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

      {/* Features Grid (Updated Copywriting) */}
      <section className="py-24 px-6 relative">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-5xl font-black mb-4 bg-clip-text text-transparent bg-gradient-to-r from-white via-slate-200 to-slate-400">
              Pengalaman Seru Yang Menunggumu
            </h2>
          </div>
          
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {[
              {
                title: "Sanctum Impianmu",
                desc: "Hias dan tata tempat meracik alkimiamu sendiri secara bebas.",
                icon: "🏠",
                border: "border-amber-500/30"
              },
              {
                title: "Eksperimen Bebas",
                desc: "Campurkan elemen misterius dan saksikan reaksi magis memukau.",
                icon: "🧪",
                border: "border-emerald-500/30"
              },
              {
                title: "Teman Setia Spirit",
                desc: "Tetaskan telur magis dan dapatkan Spirit Companion yang setia.",
                icon: "🐲",
                border: "border-cyan-500/30"
              },
              {
                title: "Serunya Bersama",
                desc: "Berkumpul dalam klan (Coven), saling berbagi bahan langka.",
                icon: "✨",
                border: "border-purple-500/30"
              }
            ].map((feature, i) => (
              <div key={i} className={`bg-slate-900/60 border-l-4 ${feature.border} border-y-white/5 border-r-white/5 p-8 rounded-3xl hover:-translate-y-1.5 transition-all shadow-xl group relative overflow-hidden`}>
                <div className="text-4xl mb-4 group-hover:scale-110 transition-transform">{feature.icon}</div>
                <h3 className="text-xl font-extrabold mb-3 text-slate-100">{feature.title}</h3>
                <p className="text-slate-400 text-sm leading-relaxed">{feature.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* pSEO Directories */}
      <section id="directories" className="py-24 px-6 border-t border-white/10 bg-slate-900/40">
        <div className="max-w-5xl mx-auto">
          <div className="text-center mb-16">
            <span className="text-xs uppercase tracking-widest font-bold text-emerald-400">Database Pengetahuan</span>
            <h2 className="text-3xl md:text-5xl font-black mt-2 mb-4">Eksplorasi Multiverse</h2>
            <p className="text-slate-400">Jelajahi seluruh data game, dari resep alkimia hingga aset pasar resmi.</p>
          </div>

          <div className="grid md:grid-cols-2 gap-6">
            <Link href="/market" className="p-8 bg-slate-900 border border-white/10 rounded-2xl hover:border-emerald-500/40 transition-all group">
              <h3 className="font-bold text-xl text-emerald-400 mb-2">🛒 Pasar Aset & Gamepass</h3>
              <p className="text-sm text-slate-400">Telusuri seluruh katalog item, gamepass VIP, dan produk developer resmi.</p>
            </Link>
            <Link href="/recipes" className="p-8 bg-slate-900 border border-white/10 rounded-2xl hover:border-emerald-500/40 transition-all group">
              <h3 className="font-bold text-xl text-emerald-400 mb-2">📜 Resep Alkimia</h3>
              <p className="text-sm text-slate-400">Pelajari cara meracik setiap ramuan magis dan elemen rahasia.</p>
            </Link>
            <Link href="/spirits" className="p-8 bg-slate-900 border border-white/10 rounded-2xl hover:border-emerald-500/40 transition-all group">
              <h3 className="font-bold text-xl text-emerald-400 mb-2">🐾 Direktori Spirit</h3>
              <p className="text-sm text-slate-400">Koleksi lengkap Spirit Companion, kelangkaan (rarity), dan kemampuan unik.</p>
            </Link>
            <Link href="/badges" className="p-8 bg-slate-900 border border-white/10 rounded-2xl hover:border-emerald-500/40 transition-all group">
              <h3 className="font-bold text-xl text-emerald-400 mb-2">🎖️ Pencapaian (Badges)</h3>
              <p className="text-sm text-slate-400">Daftar pencapaian tersulit dan persentase pemain yang berhasil mendapatkannya.</p>
            </Link>
          </div>
        </div>
      </section>

      {/* Live Leaderboard Preview */}
      <section id="leaderboard" className="py-24 px-6 border-t border-white/10 bg-slate-950">
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
                  <span className="block text-[10px] text-slate-500 uppercase tracking-widest font-bold">Verified Score</span>
                </div>
              </Link>
            ))}
          </div>
          <div className="text-center mt-12">
             <Link href="/leaderboard" className="px-6 py-3 bg-white/5 border border-white/10 rounded-xl font-semibold hover:bg-white/10 transition-colors">
               Lihat Seluruh Leaderboard
             </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
