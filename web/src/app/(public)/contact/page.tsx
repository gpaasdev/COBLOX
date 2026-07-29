import type { Metadata } from "next";
import Link from "next/link";
import { Mail, MessageCircle, Shield, Bug } from "lucide-react";

export const metadata: Metadata = {
  title: "Kontak & Dukungan",
  description: "Hubungi COBLOX Studio untuk inquiry bisnis, laporan bug, atau dukungan umum",
};

export default function ContactPage() {
  return (
    <div className="max-w-3xl mx-auto px-4 py-16">
      <h1 className="text-4xl font-bold mb-2">Kontak & Dukungan</h1>
      <p className="text-slate-400 mb-10">Hubungi tim COBLOX Studio untuk berbagai keperluan</p>

      <div className="grid md:grid-cols-2 gap-4 mb-12">
        <div className="p-6 rounded-xl border border-slate-800 bg-slate-900/50">
          <div className="flex items-center gap-3 mb-4">
            <div className="p-2.5 rounded-lg bg-emerald-500/10">
              <Mail className="w-5 h-5 text-emerald-400" />
            </div>
            <h2 className="font-semibold text-white">Business Inquiry</h2>
          </div>
          <p className="text-sm text-slate-400 mb-3">
            Kerjasama, sponsorship, media, dan inquiry bisnis lainnya.
          </p>
          <a
            href="mailto:muhzadit@gmail.com"
            className="text-emerald-400 hover:underline text-sm font-medium"
          >
            muhzadit@gmail.com →
          </a>
        </div>

        <div className="p-6 rounded-xl border border-slate-800 bg-slate-900/50">
          <div className="flex items-center gap-3 mb-4">
            <div className="p-2.5 rounded-lg bg-cyan-500/10">
              <Bug className="w-5 h-5 text-cyan-400" />
            </div>
            <h2 className="font-semibold text-white">Laporan Bug & Dukungan</h2>
          </div>
          <p className="text-sm text-slate-400 mb-3">
            Laporan bug, saran fitur, dan dukungan teknis umum.
          </p>
          <a
            href="mailto:officialgpaas@gmail.com"
            className="text-cyan-400 hover:underline text-sm font-medium"
          >
            officialgpaas@gmail.com →
          </a>
        </div>

        <div className="p-6 rounded-xl border border-slate-800 bg-slate-900/50">
          <div className="flex items-center gap-3 mb-4">
            <div className="p-2.5 rounded-lg bg-purple-500/10">
              <Shield className="w-5 h-5 text-purple-400" />
            </div>
            <h2 className="font-semibold text-white">Privasi & Keamanan</h2>
          </div>
          <p className="text-sm text-slate-400 mb-3">
            Pertanyaan terkait data pribadi dan keamanan akun.
          </p>
          <a
            href="mailto:officialgpaas@gmail.com"
            className="text-purple-400 hover:underline"
          >
            officialgpaas@gmail.com →
          </a>
        </div>

        <div className="p-6 rounded-xl border border-slate-800 bg-slate-900/50">
          <div className="flex items-center gap-3 mb-4">
            <div className="p-2.5 rounded-lg bg-rose-500/10">
              <MessageCircle className="w-5 h-5 text-rose-400" />
            </div>
            <h2 className="font-semibold text-white">Komunitas Discord</h2>
          </div>
          <p className="text-sm text-slate-400 mb-3">
            Gabung server Discord untuk diskusi dan update terbaru.
          </p>
          <a
            href="https://discord.gg/coblox"
            target="_blank"
            rel="noopener noreferrer"
            className="text-rose-400 hover:underline text-sm font-medium"
          >
            discord.gg/coblox →
          </a>
        </div>
      </div>

      <div className="p-6 rounded-xl border border-slate-800 bg-slate-900/50">
        <h2 className="font-semibold text-white mb-2">Founder & Developer</h2>
        <p className="text-sm text-slate-400">
          Untuk inquiry bisnis langsung ke founder/developer:
          <br />
          <a href="mailto:muhzadit@gmail.com" className="text-emerald-400 hover:underline">
            muhzadit@gmail.com
          </a>
        </p>
      </div>

      <div className="mt-12 pt-8 border-t border-slate-800">
        <Link href="/" className="text-emerald-400 hover:underline">← Kembali ke Beranda</Link>
      </div>
    </div>
  );
}
