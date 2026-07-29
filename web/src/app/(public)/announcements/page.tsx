import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Pengumuman",
  description: "Pengumuman resmi COBLOX: Multiverse Alchemy Sanctum",
};

const announcements = [
  {
    date: "29 Juli 2026",
    title: "Phase 1 Hardening Complete — Launch Ready!",
    excerpt: "Kami telah menyelesaikan Phase 1 production hardening. Semua P0 security exploits telah di-fix, 7 badges aktif, 8 aset Fairytale live, dan 0 hardcoded strings. Selanjutnya: Phase 2 konten Fairytale Realm!",
    author: "COBLOX Studio",
  },
  {
    date: "28 Juli 2026",
    title: "Fairytale Realm Assets Uploaded",
    excerpt: "17 Fairytale meshes telah dikirim ke moderasi Roblox. Particle textures dan audio sudah tersedia. Nantikan update berikutnya!",
    author: "COBLOX Studio",
  },
  {
    date: "27 Juli 2026",
    title: "Open Cloud API Integration Complete",
    excerpt: "COBLOX sekarang terintegrasi penuh dengan Roblox Open Cloud API. Asset upload, badge creation, dan place publishing semuanya via API. Pipeline CI/CD aktif!",
    author: "COBLOX Studio",
  },
  {
    date: "24 Juli 2026",
    title: "LGBOS v11.0 — Grand Launch",
    excerpt: "COBLOX: Multiverse Alchemy Sanctum resmi launch dengan arsitektur 57 services, server-authoritative zero-trust SOA, ProfileStore v3 persistence, dan full monetization system.",
    author: "COBLOX Studio",
  },
];

export default function AnnouncementsPage() {
  return (
    <div className="max-w-3xl mx-auto px-4 py-16">
      <h1 className="text-4xl font-bold mb-4">Pengumuman</h1>
      <p className="text-slate-400 mb-8">
        Pengumuman dan berita resmi COBLOX Studio
      </p>

      <div className="space-y-6">
        {announcements.map((item, i) => (
          <div key={i} className="border border-slate-800 rounded-xl p-6 bg-slate-900/50">
            <div className="flex items-center gap-3 text-sm text-slate-500 mb-2">
              <span>{item.date}</span>
              <span>•</span>
              <span>{item.author}</span>
            </div>
            <h2 className="text-lg font-semibold text-white mb-2">{item.title}</h2>
            <p className="text-slate-400 text-sm leading-relaxed">{item.excerpt}</p>
          </div>
        ))}
      </div>

      <div className="mt-12 pt-8 border-t border-slate-800">
        <Link href="/" className="text-emerald-400 hover:underline">← Kembali ke Beranda</Link>
      </div>
    </div>
  );
}
