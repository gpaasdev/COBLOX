import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Kebijakan Privasi",
  description: "Kebijakan Privasi COBLOX: Multiverse Alchemy Sanctum",
};

export default function PrivacyPage() {
  return (
    <div className="max-w-3xl mx-auto px-4 py-16">
      <h1 className="text-4xl font-bold mb-8">Kebijakan Privasi</h1>
      <p className="text-slate-400 text-sm mb-8">Terakhir diperbarui: 29 Juli 2026</p>

      <div className="prose prose-invert prose-emerald max-w-none space-y-6 text-slate-300">
        <h2 className="text-xl font-semibold text-white mt-8">1. Informasi yang Kami Kumpulkan</h2>
        <p>COBLOX Studio mengumpulkan data berikut melalui platform Roblox dan layanan pihak ketiga:</p>
        <ul className="list-disc pl-6 space-y-2">
          <li><strong>Data Akun Roblox:</strong> User ID, username, dan data profil publik Roblox</li>
          <li><strong>Data Gameplay:</strong> Progres permainan, inventaris, pencapaian, dan statistik</li>
          <li><strong>Data Teknis:</strong> Tipe perangkat, versi game, dan data performa anonim</li>
          <li><strong>Data Komunikasi:</strong> Jika Anda menghubungi kami melalui email atau Discord</li>
        </ul>

        <h2 className="text-xl font-semibold text-white mt-8">2. Penggunaan Data</h2>
        <p>Data yang dikumpulkan digunakan untuk:</p>
        <ul className="list-disc pl-6 space-y-2">
          <li>Menyimpan progres permainan Anda (via DataStore Roblox)</li>
          <li>Memberikan pengalaman yang dipersonalisasi</li>
          <li>Menganalisis performa game dan memperbaiki bug</li>
          <li>Mencegah kecurangan dan penyalahgunaan</li>
          <li>Mengirim notifikasi pembaruan game</li>
        </ul>

        <h2 className="text-xl font-semibold text-white mt-8">3. Penyimpanan Data</h2>
        <p>Data progres game disimpan di Roblox DataStore. Data situs web disimpan di database serverless (Neon/PostgreSQL) yang dihosting di Vercel. Data Anda tidak akan dijual atau dibagikan kepada pihak ketiga tanpa persetujuan Anda.</p>

        <h2 className="text-xl font-semibold text-white mt-8">4. Cookie & Tracking</h2>
        <p>Situs web kami menggunakan cookie esensial untuk fungsi autentikasi dan keamanan. Kami menggunakan Vercel Analytics untuk mengukur lalu lintas anonim. Tidak ada pelacakan iklan yang digunakan.</p>

        <h2 className="text-xl font-semibold text-white mt-8">5. Hak Anda</h2>
        <p>Anda berhak untuk:</p>
        <ul className="list-disc pl-6 space-y-2">
          <li>Meminta akses ke data pribadi Anda</li>
          <li>Meminta penghapusan data Anda</li>
          <li>Menolak pengumpulan data tertentu</li>
          <li>Membawa data Anda ke layanan lain</li>
        </ul>

        <h2 className="text-xl font-semibold text-white mt-8">6. Keamanan</h2>
        <p>Kami menggunakan enkripsi SSL/TLS untuk semua transmisi data. API keys dan kredensial disimpan dengan aman dan tidak pernah diekspos ke client.</p>

        <h2 className="text-xl font-semibold text-white mt-8">7. Layanan Pihak Ketiga</h2>
        <p>Game kami berjalan di platform Roblox Corporation. Kebijakan privasi Roblox berlaku untuk data yang dikumpulkan oleh platform mereka. Kami juga menggunakan Vercel (hosting) dan Neon (database).</p>

        <h2 className="text-xl font-semibold text-white mt-8">8. Perubahan Kebijakan</h2>
        <p>Kami akan memberitahukan perubahan kebijakan privasi melalui pengumuman di Discord dan halaman ini.</p>

        <h2 className="text-xl font-semibold text-white mt-8">9. Kontak</h2>
        <p>Untuk pertanyaan tentang privasi data Anda:
          <br />Email: <a href="mailto:officialgpaas@gmail.com" className="text-emerald-400 hover:underline">officialgpaas@gmail.com</a>
        </p>
      </div>

      <div className="mt-12 pt-8 border-t border-slate-800">
        <Link href="/" className="text-emerald-400 hover:underline">← Kembali ke Beranda</Link>
      </div>
    </div>
  );
}
