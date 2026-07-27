import Link from "next/link";
import { SoftwareSourceCode, WithContext } from "schema-dts";
import { Code2, ExternalLink, Copy, Sparkles, Gamepad2, ArrowLeft } from "lucide-react";

interface PageProps {
  params: Promise<{
    category: string;
    slug: string;
  }>;
}

export async function generateMetadata({ params }: PageProps) {
  const { slug } = await params;
  const formattedTitle = slug.replace(/-/g, " ").toUpperCase();
  return {
    title: `Free ${formattedTitle} Script - How to Setup in Roblox Studio | COBLOX Dev Hub`,
    description: `Unduh & gunakan modul open-source ${formattedTitle} secara gratis. Tutorial pemasangan mudah di Roblox Studio beserta contoh kode Luau lengkap.`,
  };
}

export default async function DevResourcePage({ params }: PageProps) {
  const { category, slug } = await params;
  const formattedName = slug.replace(/-/g, " ").toUpperCase();

  // Statically constructed resource from URL params — SEO fallback for dynamically routed pages.
  // Each slug maps to a Luau module snippet shown inline; no database lookup needed.
  const resource = {
    assetName: formattedName,
    category: category.toUpperCase(),
    slug,
    codeContent: `-- ${formattedName} Open Source Module
local Module = {}

function Module.Init()
    print("${formattedName} Initialized successfully!")
end

return Module`,
    rawSourceUrl: "https://github.com/awesome-roblox/awesome-roblox",
    interactionStats: 1420,
  };

  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://gpaasdev.github.io/COBLOX";

  const jsonLd: WithContext<SoftwareSourceCode> = {
    "@context": "https://schema.org",
    "@type": "SoftwareSourceCode",
    name: resource.assetName,
    programmingLanguage: "Luau",
    codeRepository: resource.rawSourceUrl,
    targetProduct: {
      "@type": "SoftwareApplication",
      name: "Roblox Studio",
      operatingSystem: "Windows, macOS",
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
            <li><span className="mx-2">/</span><span className="text-slate-400">Resources</span></li>
            <li><span className="mx-2">/</span><span className="text-slate-400 capitalize">{category}</span></li>
            <li aria-current="page"><span className="mx-2">/</span><span className="text-slate-200">{resource.assetName}</span></li>
          </ol>
        </nav>

        {/* Header Title Section */}
        <div className="bg-slate-900/60 border border-white/10 rounded-3xl p-8 backdrop-blur-xl mb-8 relative overflow-hidden">
          <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
            <div>
              <span className="px-3.5 py-1 bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-bold rounded-full uppercase tracking-wider mb-4 inline-block">
                {resource.category}
              </span>
              <h1 className="text-4xl md:text-5xl font-black text-white tracking-tight">
                Free {resource.assetName} Script
              </h1>
              <p className="text-slate-400 mt-2 text-base max-w-2xl">
                Open-source Luau module & setup guide for Roblox Studio. Fast, zero-memory-leak architecture.
              </p>
            </div>
            <a
              href={resource.rawSourceUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="px-5 py-2.5 bg-white/5 hover:bg-white/10 text-white font-bold rounded-xl border border-white/10 text-sm flex items-center gap-2 transition-all"
            >
              <ExternalLink className="w-4 h-4" /> GitHub Repository
            </a>
          </div>
        </div>

        {/* Code Block Viewer with 1-Click Copy */}
        <div className="bg-slate-900/80 border border-white/10 rounded-3xl overflow-hidden mb-12 shadow-2xl">
          <div className="bg-slate-950 px-6 py-4 border-b border-white/10 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Code2 className="w-5 h-5 text-emerald-400" />
              <span className="font-mono text-xs text-slate-300 font-bold">{resource.slug}.luau</span>
            </div>
            <button
              className="px-3 py-1.5 bg-emerald-500/10 hover:bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 rounded-lg text-xs font-bold flex items-center gap-1.5 transition-all active:scale-95"
            >
              <Copy className="w-3.5 h-3.5" /> Copy Script
            </button>
          </div>
          <pre className="p-6 text-sm font-mono text-emerald-300 overflow-x-auto bg-slate-950/60 leading-relaxed">
            <code>{resource.codeContent}</code>
          </pre>
        </div>

        {/* High-Converting CTA Banner */}
        <div className="bg-gradient-to-r from-emerald-500/20 via-cyan-500/20 to-blue-500/20 border border-emerald-500/30 rounded-3xl p-8 backdrop-blur-xl flex flex-col md:flex-row items-center justify-between gap-6 shadow-[0_0_50px_rgba(16,185,129,0.15)]">
          <div>
            <div className="flex items-center gap-2 text-emerald-400 font-bold text-xs uppercase tracking-widest mb-1">
              <Sparkles className="w-4 h-4" /> Komunitas Roblox Terkemuka
            </div>
            <h3 className="text-2xl font-black text-white">Bergabunglah di COBLOX Sanctum</h3>
            <p className="text-slate-300 text-sm mt-1">Dapatkan skrip eksklusif, bertukar tips alkimia, dan main bersama di Roblox!</p>
          </div>
          <div className="flex items-center gap-4">
            <a
              href="https://www.roblox.com/join/qkced"
              target="_blank"
              rel="noopener noreferrer"
              className="px-6 py-3.5 bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-black text-sm rounded-2xl flex items-center gap-2 transition-all shadow-lg active:scale-95"
            >
              <Gamepad2 className="w-4 h-4" /> Main di Roblox
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
