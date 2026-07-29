import type { Metadata } from "next";
import Link from "next/link";
import { Mail, MessageCircle, Bug, FileText } from "lucide-react";

export const metadata: Metadata = {
  title: "Bug Reporting & Support",
  description: "Cara melaporkan bug, memberikan saran, dan menghubungi tim support COBLOX",
};

export default function SupportPage() {
  return (
    <div className="max-w-3xl mx-auto px-4 py-16">
      <Link href="/knowledge-base" className="text-emerald-400 hover:underline text-sm mb-8 inline-block">← Kembali ke Knowledge Base</Link>
      <h1 className="text-4xl font-bold mb-2">Bug Reporting & Support</h1>
      <p className="text-slate-400 mb-8">Cara melaporkan bug dan menghubungi tim support</p>

      <div className="grid gap-4 mb-8">
        <div className="p-5 rounded-xl border border-slate-800 bg-slate-900/50 flex items-start gap-4">
          <Bug className="w-5 h-5 text-rose-400 mt-1 shrink-0" />
          <div>
            <h2 className="font-semibold text-white mb-1">Laporkan Bug</h2>
            <p className="text-sm text-slate-400">Kirim email ke <a href="mailto:officialgpaas@gmail.com" className="text-emerald-400 hover:underline">officialgpaas@gmail.com</a> dengan detail: langkah reproduksi, screenshot/video, dan info perangkat.</p>
          </div>
        </div>
        <div className="p-5 rounded-xl border border-slate-800 bg-slate-900/50 flex items-start gap-4">
          <MessageCircle className="w-5 h-5 text-cyan-400 mt-1 shrink-0" />
          <div>
            <h2 className="font-semibold text-white mb-1">Discord Community</h2>
            <p className="text-sm text-slate-400">Gabung server Discord untuk diskusi, laporan bug cepat, dan update terbaru. <a href="https://discord.gg/yqh4C6uVY" target="_blank" rel="noopener noreferrer" className="text-emerald-400 hover:underline">discord.gg/yqh4C6uVY</a></p>
          </div>
        </div>
        <div className="p-5 rounded-xl border border-slate-800 bg-slate-900/50 flex items-start gap-4">
          <Mail className="w-5 h-5 text-emerald-400 mt-1 shrink-0" />
          <div>
            <h2 className="font-semibold text-white mb-1">Business Inquiry</h2>
            <p className="text-sm text-slate-400">Untuk kerjasama, sponsorship, dan inquiry bisnis: <a href="mailto:muhzadit@gmail.com" className="text-emerald-400 hover:underline">muhzadit@gmail.com</a></p>
          </div>
        </div>
        <div className="p-5 rounded-xl border border-slate-800 bg-slate-900/50 flex items-start gap-4">
          <FileText className="w-5 h-5 text-purple-400 mt-1 shrink-0" />
          <div>
            <h2 className="font-semibold text-white mb-1">Privacy & Data</h2>
            <p className="text-sm text-slate-400">Lihat <Link href="/privacy" className="text-emerald-400 hover:underline">Kebijakan Privasi</Link> dan <Link href="/terms" className="text-emerald-400 hover:underline">Syarat & Ketentuan</Link> untuk informasi lebih lanjut.</p>
          </div>
        </div>
      </div>
    </div>
  );
}
