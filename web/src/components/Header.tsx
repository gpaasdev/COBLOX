import Link from "next/link";
import { FlaskConical, Sparkles, BookOpen, Code2, Gamepad2, Database } from "lucide-react";

export function Header() {
  return (
    <header className="sticky top-0 z-50 w-full border-b border-white/5 bg-slate-950/80 backdrop-blur-md">
      <div className="container mx-auto px-4 h-16 flex items-center justify-between">
        <Link
          href="/"
          className="flex items-center gap-2 font-bold text-xl tracking-tight text-white hover:text-emerald-400 transition-colors"
        >
          <FlaskConical className="w-6 h-6 text-emerald-500" />
          <span>COBLOX</span>
        </Link>
        <nav className="hidden md:flex items-center gap-6">
          <Link
            href="/"
            className="text-sm font-medium text-slate-300 hover:text-emerald-400 flex items-center gap-2 transition-colors"
          >
            <Sparkles className="w-4 h-4" /> Beranda
          </Link>
          <Link
            href="/resources/framework/knit-framework"
            className="text-sm font-medium text-slate-300 hover:text-emerald-400 flex items-center gap-2 transition-colors"
          >
            <Code2 className="w-4 h-4" /> Dev Hub
          </Link>
          <Link
            href="/roblox/games/coblox-multiverse-sanctum"
            className="text-sm font-medium text-slate-300 hover:text-emerald-400 flex items-center gap-2 transition-colors"
          >
            <Database className="w-4 h-4" /> Player Hub
          </Link>
          <a
            href="https://gpaasdev.github.io/COBLOX/codex.html"
            target="_blank"
            rel="noopener noreferrer"
            className="text-sm font-medium text-slate-300 hover:text-emerald-400 flex items-center gap-2 transition-colors"
          >
            <BookOpen className="w-4 h-4" /> Panduan
          </a>
          <a
            href="https://www.roblox.com/join/qkced"
            target="_blank"
            rel="noopener noreferrer"
            className="ml-4 px-5 py-2 bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold rounded-full text-sm flex items-center gap-2 transition-all shadow-[0_0_15px_rgba(16,185,129,0.3)] hover:shadow-[0_0_25px_rgba(16,185,129,0.5)]"
          >
            <Gamepad2 className="w-4 h-4" /> MAIN DI ROBLOX
          </a>
        </nav>
      </div>
    </header>
  );
}
