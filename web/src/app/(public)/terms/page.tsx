import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Syarat & Ketentuan",
  description: "Syarat dan Ketentuan Layanan (Terms of Service) COBLOX: Multiverse Alchemy Sanctum",
};

export default function TermsPage() {
  return (
    <div className="max-w-3xl mx-auto px-4 py-16">
      <h1 className="text-4xl font-bold mb-8">Syarat & Ketentuan</h1>
      <p className="text-slate-400 text-sm mb-8">Terakhir diperbarui: 29 Juli 2026</p>

      <div className="prose prose-invert prose-emerald max-w-none space-y-6 text-slate-300">
        <h2 className="text-xl font-semibold text-white mt-8">1. Penerimaan Ketentuan</h2>
        <p>Dengan mengakses dan menggunakan game COBLOX: Multiverse Alchemy Sanctum ("Game") serta situs web terkait, Anda menyetujui untuk terikat oleh Syarat dan Ketentuan ini. Jika Anda tidak setuju, jangan gunakan layanan kami.</p>

        <h2 className="text-xl font-semibold text-white mt-8">2. Deskripsi Layanan</h2>
        <p>COBLOX adalah pengalaman Hybrid Pet Tycoon & Social Action Alkimia di platform Roblox. Game ini mencakup sistem crafting elemen, pet companion, trading antar pemain, dan fitur sosial lainnya yang dioperasikan sepenuhnya di server Roblox.</p>

        <h2 className="text-xl font-semibold text-white mt-8">3. Kepemilikan Akun</h2>
        <p>Akun Roblox Anda adalah tanggung jawab Anda. COBLOX Studio tidak bertanggung jawab atas akses tidak sah ke akun Anda. Semua pembelian dalam game bersifat final dan tidak dapat dikembalikan kecuali diwajibkan oleh hukum yang berlaku.</p>

        <h2 className="text-xl font-semibold text-white mt-8">4. Kebijakan Pembelian & Pengembalian Dana</h2>
        <p>Pembelian GamePass, Developer Product, dan Subscription dilakukan melalui platform Roblox. Semua transaksi diproses oleh Roblox Corporation. Kebijakan pengembalian dana tunduk pada ketentuan Roblox. Hubungi dukungan Roblox untuk masalah pembayaran.</p>

        <h2 className="text-xl font-semibold text-white mt-8">5. Perilaku Pengguna</h2>
        <p>Anda setuju untuk tidak:</p>
        <ul className="list-disc pl-6 space-y-2">
          <li>Menggunakan exploit, cheat, atau bug dalam game</li>
          <li>Melakukan farming atau transaksi ilegal</li>
          <li>Melecehkan pemain lain atau menggunakan bahasa yang tidak pantas</li>
          <li>Menciptakan akun alternatif untuk menghindari sanksi</li>
        </ul>

        <h2 className="text-xl font-semibold text-white mt-8">6. Hak Kekayaan Intelektual</h2>
        <p>Seluruh aset, desain, kode, dan konten dalam COBLOX adalah milik COBLOX Studio. Anda tidak diperbolehkan menyalin, memodifikasi, atau mendistribusikan konten game tanpa izin tertulis.</p>

        <h2 className="text-xl font-semibold text-white mt-8">7. Modifikasi Ketentuan</h2>
        <p>Kami berhak mengubah Syarat dan Ketentuan ini kapan saja. Perubahan akan diumumkan melalui server Discord dan halaman pengumuman resmi.</p>

        <h2 className="text-xl font-semibold text-white mt-8">8. Kontak</h2>
        <p>Untuk pertanyaan lebih lanjut, hubungi kami di:
          <br />Email: <a href="mailto:officialgpaas@gmail.com" className="text-emerald-400 hover:underline">officialgpaas@gmail.com</a>
          <br />Discord: <a href="https://discord.gg/coblox" className="text-emerald-400 hover:underline">COBLOX Community</a>
        </p>
      </div>

      <div className="mt-12 pt-8 border-t border-slate-800">
        <Link href="/" className="text-emerald-400 hover:underline">← Kembali ke Beranda</Link>
      </div>
    </div>
  );
}
