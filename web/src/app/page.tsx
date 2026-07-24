import Image from "next/image";
import Link from "next/link";

export default function Home() {
  return (
    <main className="min-h-screen bg-slate-950 text-slate-50 font-sans selection:bg-emerald-500/30">
      {/* Navigation */}
      <nav className="fixed top-0 w-full z-50 bg-slate-950/80 backdrop-blur-md border-b border-white/10">
        <div className="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-gradient-to-br from-emerald-400 to-cyan-500 rounded-xl flex items-center justify-center font-bold text-slate-900 text-xl shadow-[0_0_15px_rgba(52,211,153,0.5)]">
              C
            </div>
            <span className="font-bold text-xl tracking-wide bg-clip-text text-transparent bg-gradient-to-r from-emerald-400 to-cyan-300">
              COBLOX
            </span>
          </div>
          <div className="hidden md:flex gap-8 text-sm font-medium text-slate-300">
            <Link href="#features" className="hover:text-white transition-colors">Features</Link>
            <Link href="#economy" className="hover:text-white transition-colors">Economy</Link>
            <Link href="#community" className="hover:text-white transition-colors">Community</Link>
          </div>
          <Link
            href="https://www.roblox.com/join/qkced"
            target="_blank"
            className="px-6 py-2.5 bg-white text-slate-950 font-bold rounded-full hover:bg-emerald-400 hover:text-slate-900 transition-all active:scale-95 shadow-[0_0_20px_rgba(255,255,255,0.2)] hover:shadow-[0_0_25px_rgba(52,211,153,0.6)]"
          >
            Play on Roblox
          </Link>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="relative pt-40 pb-20 px-6 overflow-hidden">
        {/* Background Gradients */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-emerald-500/20 rounded-full blur-[120px] pointer-events-none" />
        <div className="absolute top-0 right-0 w-[600px] h-[600px] bg-cyan-500/10 rounded-full blur-[100px] pointer-events-none" />
        
        <div className="max-w-7xl mx-auto text-center relative z-10 flex flex-col items-center">
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/5 border border-white/10 text-emerald-300 text-sm font-medium mb-8 backdrop-blur-sm">
            <span className="relative flex h-2 w-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
              <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
            </span>
            Closed Alpha v11.0 Live Now
          </div>
          
          <h1 className="text-5xl md:text-7xl font-extrabold tracking-tight mb-8 leading-tight">
            Multiverse <br className="hidden md:block" />
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-emerald-400 via-cyan-400 to-blue-500">
              Alchemy Sanctum
            </span>
          </h1>
          
          <p className="text-lg md:text-xl text-slate-400 max-w-2xl mb-12 leading-relaxed">
            Pengalaman Hybrid Pet Tycoon & Social Action Alkimia terdepan di Roblox 2026. Susun Bejana Aura, racik elemen magis, dan tetaskan Spirit Companion legendaris.
          </p>
          
          <div className="relative group w-full max-w-4xl mx-auto rounded-2xl overflow-hidden border border-white/10 shadow-2xl shadow-emerald-500/10">
            {/* Using img for external url to avoid next/image domain config issues */}
            <img 
              src="https://raw.githubusercontent.com/gpaasdev/COBLOX/main/.github/assets/game_thumbnail_16x9.png" 
              alt="COBLOX Gameplay" 
              className="w-full h-auto aspect-video object-cover transition-transform duration-700 group-hover:scale-105"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-slate-950 via-transparent to-transparent opacity-60" />
          </div>
        </div>
      </section>

      {/* Features Grid */}
      <section id="features" className="py-24 px-6 border-t border-white/5 bg-slate-900/50">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold mb-4">Master the Elements</h2>
            <p className="text-slate-400">Arsitektur canggih dan gameplay loop inovatif.</p>
          </div>
          
          <div className="grid md:grid-cols-3 gap-8">
            {[
              {
                title: "Sanctum Grid 3x3",
                desc: "Tata bejana aura, extractor, dan altar kristal secara bebas dalam matriks presisi tinggi.",
                icon: "🔮"
              },
              {
                title: "Spirit Companions",
                desc: "Tetaskan telur magis dengan spring feedback physics. Koleksi kawan Spirit untuk auto-harvest.",
                icon: "🐉"
              },
              {
                title: "Mobile-First Performance",
                desc: "Beban memori dijaga ketat < 2.5 GB RAM. Object Pooling untuk VFX dan Audio 4-Channel.",
                icon: "⚡"
              }
            ].map((feature, i) => (
              <div key={i} className="bg-slate-950 border border-white/5 p-8 rounded-2xl hover:border-emerald-500/30 transition-all hover:-translate-y-1 hover:shadow-[0_10px_30px_rgba(52,211,153,0.1)] group">
                <div className="w-14 h-14 bg-white/5 rounded-xl flex items-center justify-center text-3xl mb-6 group-hover:scale-110 transition-transform">
                  {feature.icon}
                </div>
                <h3 className="text-xl font-bold mb-3 text-slate-200">{feature.title}</h3>
                <p className="text-slate-400 leading-relaxed">{feature.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-white/10 py-12 px-6 text-center text-slate-500 text-sm bg-slate-950">
        <p>© 2026 COBLOX Studio. All rights reserved.</p>
        <div className="flex justify-center gap-6 mt-4">
          <Link href="#" className="hover:text-emerald-400 transition-colors">Twitter</Link>
          <Link href="#" className="hover:text-emerald-400 transition-colors">Discord</Link>
          <Link href="https://github.com/gpaasdev/COBLOX" className="hover:text-emerald-400 transition-colors">GitHub</Link>
        </div>
      </footer>
    </main>
  );
}
