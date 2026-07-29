import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Security & Anti-Exploit",
  description: "Bagaimana COBLOX melindungi data dan progres Anda dari exploit dan kecurangan",
};

export default function SecurityPage() {
  return (
    <div className="max-w-3xl mx-auto px-4 py-16">
      <Link href="/knowledge-base" className="text-emerald-400 hover:underline text-sm mb-8 inline-block">← Kembali ke Knowledge Base</Link>
      <h1 className="text-4xl font-bold mb-2">Zero-Trust Security FAQ</h1>
      <p className="text-slate-400 mb-8">Bagaimana COBLOX melindungi data dan progres Anda</p>
      <div className="prose prose-invert max-w-none space-y-6 text-slate-300">
        <h2 className="text-xl font-semibold text-white">Apa itu Zero-Trust?</h2>
        <p>COBLOX menggunakan arsitektur Zero-Trust: semua data dari client dianggap tidak aman. Setiap transaksi, crafting, dan konsumsi item divalidasi ulang di server sebelum diproses.</p>
        <h2 className="text-xl font-semibold text-white mt-8">Keamanan Data</h2>
        <p>Data progres Anda disimpan menggunakan ProfileStore dengan session-locking. DataStore hanya bisa diakses melalui Open Cloud API dengan API key terenkripsi.</p>
        <h2 className="text-xl font-semibold text-white mt-8">Anti-Exploit</h2>
        <ul className="list-disc pl-6 space-y-2">
          <li>Rate limiting pada semua remote events</li>
          <li>Server-side cooldown untuk combat dan crafting</li>
          <li>Validasi inventory sebelum transaksi</li>
          <li>Atomic swap untuk trading (2-step confirmation)</li>
        </ul>
      </div>
    </div>
  );
}
