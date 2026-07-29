import type { Metadata } from "next";
import Link from "next/link";
import { BookOpen, FlaskConical, Sparkles, Shield, Users, ShoppingCart, Bug, Gamepad2 } from "lucide-react";

export const metadata: Metadata = {
  title: "Knowledge Base",
  description: "Panduan, tutorial, dan referensi COBLOX: Multiverse Alchemy Sanctum",
};

const articles = [
  {
    icon: FlaskConical,
    title: "Crafting & Alchemy Guide",
    desc: "Panduan lengkap sistem crafting 3x3, elemental reactions, dan transmutation.",
    href: "/knowledge-base/crafting-guide",
    category: "gameplay",
  },
  {
    icon: Sparkles,
    title: "Spirit Companion System",
    desc: "Cara menetaskan, meng-evolusi, dan membangkitkan Spirit Companion.",
    href: "/knowledge-base/spirit-guide",
    category: "gameplay",
  },
  {
    icon: Shield,
    title: "Zero-Trust Security FAQ",
    desc: "Bagaimana COBLOX melindungi data dan progres Anda dari exploit.",
    href: "/knowledge-base/security",
    category: "technical",
  },
  {
    icon: Users,
    title: "Coven & Multiplayer Guide",
    desc: "Panduan guild, trading, co-op combat, dan fitur sosial lainnya.",
    href: "/knowledge-base/coven-guide",
    category: "social",
  },
  {
    icon: ShoppingCart,
    title: "Monetization & Products",
    desc: "Informasi tentang GamePass, DevProduct, dan Subscription yang tersedia.",
    href: "/knowledge-base/monetization",
    category: "account",
  },
  {
    icon: Bug,
    title: "Bug Reporting & Support",
    desc: "Cara melaporkan bug, memberikan saran, dan menghubungi tim support.",
    href: "/knowledge-base/support",
    category: "support",
  },
];

export default function KnowledgeBasePage() {
  return (
    <div className="max-w-4xl mx-auto px-4 py-16">
      <h1 className="text-4xl font-bold mb-2">Knowledge Base</h1>
      <p className="text-slate-400 mb-10">Panduan, tutorial, dan referensi untuk pemain COBLOX</p>

      <div className="grid md:grid-cols-2 gap-4">
        {articles.map((article) => {
          const Icon = article.icon;
          return (
            <Link
              key={article.href}
              href={article.href}
              className="flex items-start gap-4 p-5 rounded-xl border border-slate-800 bg-slate-900/50 hover:bg-slate-900 hover:border-emerald-500/30 transition-all group"
            >
              <div className="p-2.5 rounded-lg bg-emerald-500/10 text-emerald-400 shrink-0">
                <Icon className="w-5 h-5" />
              </div>
              <div>
                <h2 className="font-semibold text-white group-hover:text-emerald-400 transition-colors">
                  {article.title}
                </h2>
                <p className="text-sm text-slate-400 mt-1">{article.desc}</p>
              </div>
            </Link>
          );
        })}
      </div>

      <div className="mt-12 text-center">
        <Link
          href="https://discord.gg/coblox"
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center gap-2 text-emerald-400 hover:underline"
        >
          <Gamepad2 className="w-4 h-4" /> Bergabung dengan Discord untuk bantuan lebih lanjut
        </Link>
      </div>
    </div>
  );
}
