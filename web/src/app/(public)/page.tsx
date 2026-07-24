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
      {/* Asymmetric Hero Section */}
      <section className="relative pt-24 pb-20 px-6 lg:pt-36 lg:pb-32 overflow-hidden">
        <div className="max-w-7xl mx-auto flex flex-col lg:flex-row items-center justify-between gap-16 relative z-10">
          
          {/* Left Column: Typography & CTAs */}
          <div className="flex-1 flex flex-col items-start text-left max-w-2xl">
            <div className="inline-flex items-center gap-2.5 px-4 py-2 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-300 text-xs font-semibold mb-8 backdrop-blur-md shadow-sm">
              <span className="relative flex h-2.5 w-2.5">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500"></span>
              </span>
              <span>Uji Coba Alpha Terbuka</span>
            </div>
            
            <h1 className="text-5xl md:text-6xl lg:text-7xl font-black tracking-tight mb-6 leading-[1.1]">
              Alkimia Impianmu, <br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-400 to-cyan-400">
                Kini Multiverse.
              </span>
            </h1>
            
            <p className="text-lg md:text-xl text-slate-400 max-w-xl mb-10 leading-relaxed font-normal">
              Racik elemen rahasia, rawat kawan Spirit, dan bangun tempat tinggal alkimia unik di COBLOX: Multiverse Alchemy Sanctum.
            </p>

            <div className="flex flex-col sm:flex-row gap-4 w-full sm:w-auto">
              <Link
                href="https://www.roblox.com/join/qkced"
                target="_blank"
                className="btn-tactile flex items-center justify-center px-8 py-4 bg-emerald-400 text-slate-950 font-black text-base rounded-2xl hover:bg-emerald-300 shadow-[0_0_30px_rgba(52,211,153,0.3)] whitespace-nowrap"
              >
                Mulai Petualangan
              </Link>
              <Link
                href="#directories"
                className="btn-tactile flex items-center justify-center px-8 py-4 bg-white/5 border border-white/10 text-slate-200 font-bold text-base rounded-2xl hover:bg-white/10 backdrop-blur-sm whitespace-nowrap"
              >
                Eksplorasi Data
              </Link>
            </div>
          </div>

          {/* Right Column: Visual Bento */}
          <div className="flex-1 w-full max-w-2xl lg:max-w-none relative">
            <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-full h-[120%] bg-emerald-500/10 rounded-full blur-[100px] pointer-events-none" />
            
            <div className="relative w-full rounded-3xl overflow-hidden border border-emerald-500/20 shadow-2xl bg-slate-900/50 group">
              <img 
                src="https://raw.githubusercontent.com/gpaasdev/COBLOX/main/.github/assets/game_thumbnail_16x9.png" 
                alt="COBLOX Gameplay Showcase" 
                className="w-full h-auto aspect-[4/3] sm:aspect-video lg:aspect-[4/3] object-cover transition-transform duration-700 group-hover:scale-[1.02]"
              />
              {/* Overlay Stat Card */}
              <div className="absolute bottom-6 left-6 right-6 p-4 bg-slate-950/80 backdrop-blur-md rounded-2xl border border-white/10 flex justify-between items-center transform translate-y-4 opacity-0 group-hover:translate-y-0 group-hover:opacity-100 transition-all duration-500">
                <div>
                  <div className="text-xs text-slate-400 font-bold tracking-widest uppercase mb-1">Server Status</div>
                  <div className="text-emerald-400 font-mono font-bold">Online & Stable</div>
                </div>
                <div className="text-right">
                  <div className="text-xs text-slate-400 font-bold tracking-widest uppercase mb-1">Latency</div>
                  <div className="text-cyan-400 font-mono font-bold">24ms</div>
                </div>
              </div>
            </div>
          </div>

        </div>
      </section>

      {/* Live Stats Bar */}
      <section className="py-10 border-y border-white/5 bg-slate-900/40 backdrop-blur-lg">
        <div className="max-w-7xl mx-auto px-6 grid grid-cols-2 md:grid-cols-4 gap-6 md:gap-8 divide-x divide-white/5">
          {stats.map((stat, i) => (
            <div key={i} className="flex flex-col items-start pl-6 md:pl-8 first:pl-0 first:border-0">
              <span className="text-2xl mb-3 opacity-80">{stat.icon}</span>
              <span className="text-2xl md:text-3xl font-black text-white tracking-tight">{stat.value}</span>
              <span className="text-sm font-medium text-slate-400 mt-1">{stat.label}</span>
              <span className="text-[11px] font-bold text-emerald-400 mt-1">{stat.change}</span>
            </div>
          ))}
        </div>
      </section>

      {/* Features Grid (Stoic Design, Clean Borders) */}
      <section className="py-24 px-6">
        <div className="max-w-7xl mx-auto">
          <div className="mb-16 max-w-2xl">
            <h2 className="text-3xl md:text-5xl font-black mb-4 bg-clip-text text-transparent bg-gradient-to-r from-white to-slate-400">
              Pengalaman Alkimia
            </h2>
            <p className="text-slate-400 text-lg">Mekanisme inti yang dirancang untuk permainan jangka panjang.</p>
          </div>
          
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {[
              { title: "Sanctum", desc: "Hias tempat meracik alkimiamu secara bebas.", icon: "🏠" },
              { title: "Eksperimen", desc: "Campurkan elemen dan saksikan reaksi magis.", icon: "🧪" },
              { title: "Spirit", desc: "Tetaskan telur magis untuk Spirit Companion.", icon: "🐲" },
              { title: "Coven", desc: "Berkumpul dalam klan, berbagi bahan langka.", icon: "✨" }
            ].map((feature, i) => (
              <div key={i} className="btn-tactile bg-slate-900/40 border border-white/10 p-8 rounded-3xl hover:bg-slate-900/80 hover:border-emerald-500/30 group">
                <div className="text-3xl mb-6 opacity-70 group-hover:opacity-100 group-hover:scale-110 transition-all origin-left">{feature.icon}</div>
                <h3 className="text-xl font-bold mb-2 text-slate-200">{feature.title}</h3>
                <p className="text-slate-400 text-sm leading-relaxed">{feature.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* pSEO Directories (Bento Style) */}
      <section id="directories" className="py-24 px-6 border-t border-white/5 bg-slate-950">
        <div className="max-w-7xl mx-auto">
          <div className="flex flex-col md:flex-row md:items-end justify-between gap-8 mb-12">
            <div className="max-w-2xl">
              <span className="text-xs uppercase tracking-widest font-bold text-emerald-500 mb-2 block">Database Pengetahuan</span>
              <h2 className="text-3xl md:text-5xl font-black text-slate-50">Eksplorasi Multiverse</h2>
            </div>
            <p className="text-slate-400 max-w-sm md:text-right">
              Jelajahi seluruh data game, dari resep alkimia hingga aset pasar resmi secara real-time.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-6">
            <Link href="/market" className="btn-tactile md:col-span-2 p-8 bg-slate-900/60 border border-white/10 rounded-3xl hover:border-emerald-500/40 group overflow-hidden relative">
              <div className="absolute right-0 top-0 w-64 h-64 bg-emerald-500/5 blur-[80px] rounded-full group-hover:bg-emerald-500/10 transition-colors" />
              <div className="relative z-10">
                <h3 className="font-bold text-2xl text-emerald-400 mb-3">🛒 Pasar Aset & Gamepass</h3>
                <p className="text-slate-400 max-w-md">Telusuri seluruh katalog item, gamepass VIP, dan produk developer resmi COBLOX secara lengkap.</p>
              </div>
            </Link>
            
            <Link href="/recipes" className="btn-tactile p-8 bg-slate-900/60 border border-white/10 rounded-3xl hover:border-emerald-500/40 group relative overflow-hidden">
              <h3 className="font-bold text-xl text-emerald-400 mb-3">📜 Resep Alkimia</h3>
              <p className="text-sm text-slate-400">Pelajari cara meracik setiap ramuan magis.</p>
            </Link>

            <Link href="/spirits" className="btn-tactile p-8 bg-slate-900/60 border border-white/10 rounded-3xl hover:border-emerald-500/40 group">
              <h3 className="font-bold text-xl text-emerald-400 mb-3">🐾 Direktori Spirit</h3>
              <p className="text-sm text-slate-400">Koleksi lengkap Spirit, kelangkaan, dan kemampuan unik.</p>
            </Link>

            <Link href="/badges" className="btn-tactile md:col-span-2 p-8 bg-slate-900/60 border border-white/10 rounded-3xl hover:border-emerald-500/40 group relative overflow-hidden">
              <div className="absolute right-0 top-0 w-64 h-64 bg-cyan-500/5 blur-[80px] rounded-full group-hover:bg-cyan-500/10 transition-colors" />
              <div className="relative z-10">
                <h3 className="font-bold text-2xl text-emerald-400 mb-3">🎖️ Pencapaian (Badges)</h3>
                <p className="text-slate-400 max-w-md">Daftar pencapaian tersulit dan persentase pemain yang berhasil mendapatkannya di seluruh dunia.</p>
              </div>
            </Link>
          </div>
        </div>
      </section>

      {/* Live Leaderboard Preview */}
      <section id="leaderboard" className="py-24 px-6 border-t border-white/5 bg-slate-900/20">
        <div className="max-w-4xl mx-auto">
          <div className="text-center mb-16">
            <span className="text-xs uppercase tracking-widest font-bold text-emerald-500 mb-2 block">Global Alchemists</span>
            <h2 className="text-3xl md:text-5xl font-black">Top Leaderboard</h2>
          </div>

          <div className="flex flex-col gap-4">
            {topAlchemists.map((player, idx) => (
              <Link 
                key={idx} 
                href={`/leaderboard/${player.slug}`}
                className="btn-tactile flex items-center justify-between p-6 bg-slate-900/60 border border-white/10 rounded-2xl hover:border-emerald-500/30 group"
              >
                <div className="flex items-center gap-6">
                  <span className="text-xl font-black text-emerald-500 font-mono w-8">{player.rank}</span>
                  <div>
                    <h3 className="font-bold text-lg text-slate-200 group-hover:text-emerald-400 transition-colors">
                      {player.name}
                    </h3>
                    <p className="text-xs text-slate-400">Companion: <span className="text-cyan-400 font-medium">{player.companion}</span></p>
                  </div>
                </div>
                <div className="text-right">
                  <span className="text-lg font-black text-slate-200 font-mono group-hover:text-emerald-400 transition-colors">{player.score}</span>
                  <span className="block text-[10px] text-slate-500 uppercase tracking-widest font-bold mt-1">Verified Score</span>
                </div>
              </Link>
            ))}
          </div>
          <div className="text-center mt-12">
             <Link href="/leaderboard" className="btn-tactile inline-block px-8 py-4 bg-slate-800 text-slate-200 font-bold rounded-xl hover:bg-slate-700 transition-colors">
               Lihat Seluruh Peringkat
             </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
