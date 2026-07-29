import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Coven & Multiplayer Guide",
  description: "Panduan guild, trading, co-op combat, dan fitur sosial di COBLOX",
};

export default function CovenGuidePage() {
  return (
    <div className="max-w-3xl mx-auto px-4 py-16">
      <Link href="/knowledge-base" className="text-emerald-400 hover:underline text-sm mb-8 inline-block">← Kembali ke Knowledge Base</Link>
      <h1 className="text-4xl font-bold mb-2">Coven & Multiplayer Guide</h1>
      <p className="text-slate-400 mb-8">Panduan guild, trading, co-op combat, dan fitur sosial</p>

      <div className="prose prose-invert max-w-none space-y-6 text-slate-300">
        <h2 className="text-xl font-semibold text-white">Coven (Klan Alchemist)</h2>
        <p>Coven adalah sistem guild di COBLOX. Buat atau bergabung dengan Coven untuk menikmati fitur eksklusif:</p>
        <ul className="list-disc pl-6 space-y-2">
          <li><strong>Hideout:</strong> Markas rahasia khusus anggota Coven</li>
          <li><strong>Treasury:</strong> Kas bersama untuk upgrade Coven</li>
          <li><strong>Coven Buff:</strong> Multiplier global untuk semua anggota</li>
          <li><strong>Raid:</strong> Co-op boss fight eksklusif</li>
        </ul>

        <h2 className="text-xl font-semibold text-white mt-8">Trading</h2>
        <p>Sistem trading 2-step anti-scam: kedua belah pihak harus mengunci (Lock) dan mengkonfirmasi (Confirm) sebelum transaksi dieksekusi secara atomik. Trade mendukung:</p>
        <ul className="list-disc pl-6 space-y-2">
          <li>Pertukaran Coins dan Gems</li>
          <li>Pertukaran Spirit/Pet</li>
          <li>Daily transfer cap berdasarkan Rebirth level</li>
        </ul>

        <h2 className="text-xl font-semibold text-white mt-8">Leaderboard</h2>
        <p>Bersaing dengan pemain lain di leaderboard global. Peringkat berdasarkan total Gems, Rebirth level, dan pencapaian.</p>
      </div>
    </div>
  );
}
