import Link from "next/link";

export function Footer() {
  return (
    <footer className="border-t border-white/5 bg-slate-950 mt-auto py-12">
      <div className="container mx-auto px-4">
        <div className="flex flex-col md:flex-row items-center justify-between gap-6">
          <div className="text-center md:text-left">
            <p className="text-slate-400">
              © 2026 <strong className="text-white">COBLOX Studio</strong>. Dibuat dengan penuh cinta untuk komunitas Roblox.
            </p>
            <p className="text-slate-500 text-sm mt-2">
              Dukung kami dengan bergabung di Discord & ikuti pembaruan game terbaru!
            </p>
          </div>
          <div className="flex items-center gap-4 text-sm">
            <Link href="/terms" className="text-slate-400 hover:text-emerald-400 transition-colors">
              Syarat & Ketentuan
            </Link>
            <Link href="/privacy" className="text-slate-400 hover:text-emerald-400 transition-colors">
              Kebijakan Privasi
            </Link>
            <Link href="/changelog" className="text-slate-400 hover:text-emerald-400 transition-colors">
              Changelog
            </Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
