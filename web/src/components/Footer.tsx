import Link from "next/link";

export function Footer() {
  return (
    <footer className="border-t border-white/5 bg-slate-950 mt-auto py-12">
      <div className="container mx-auto px-4">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="text-center md:text-left">
            <p className="text-slate-400">
              © 2026 <strong className="text-white">COBLOX Studio</strong>
            </p>
            <p className="text-slate-500 text-sm mt-2">
              Hybrid Pet Tycoon & Social Action Alkimia di Roblox.
            </p>
          </div>
          <div className="text-center">
            <h3 className="text-sm font-semibold text-slate-300 mb-3">Links</h3>
            <div className="flex flex-col gap-2">
              <Link href="/terms" className="text-sm text-slate-400 hover:text-emerald-400 transition-colors">Syarat & Ketentuan</Link>
              <Link href="/privacy" className="text-sm text-slate-400 hover:text-emerald-400 transition-colors">Kebijakan Privasi</Link>
              <Link href="/changelog" className="text-sm text-slate-400 hover:text-emerald-400 transition-colors">Changelog</Link>
              <Link href="/contact" className="text-sm text-slate-400 hover:text-emerald-400 transition-colors">Kontak</Link>
            </div>
          </div>
          <div className="text-center md:text-right">
            <h3 className="text-sm font-semibold text-slate-300 mb-3">Kontak</h3>
            <div className="flex flex-col gap-2 text-sm text-slate-400">
              <a href="mailto:muhzadit@gmail.com" className="hover:text-emerald-400 transition-colors">Business: muhzadit@gmail.com</a>
              <a href="mailto:officialgpaas@gmail.com" className="hover:text-emerald-400 transition-colors">Support: officialgpaas@gmail.com</a>
              <a href="https://hycoblox.vercel.app" target="_blank" rel="noopener noreferrer" className="hover:text-emerald-400 transition-colors">hycoblox.vercel.app</a>
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
}
