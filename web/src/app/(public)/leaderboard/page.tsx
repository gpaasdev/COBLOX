import Link from "next/link";
import { prisma } from "@/lib/db";
import { Metadata } from "next";

export const revalidate = 3600;

export const metadata: Metadata = {
  title: "Leaderboard Multiverse",
  description: "Peringkat game teratas dan alkimis terunggul di seluruh Multiverse Sanctum.",
};

export default async function LeaderboardPage() {
  const games = await prisma.robloxGame.findMany({
    take: 50,
    orderBy: { activePlayers: "desc" },
  }).catch(() => []);

  return (
    <div className="max-w-7xl mx-auto px-6 py-16 flex-grow w-full">
      <div className="mb-12">
        <h1 className="text-4xl font-black text-emerald-400 mb-4">Top Leaderboard</h1>
        <p className="text-slate-300">Peringkat Multiverse berdasarkan jumlah pengunjung dan pemain aktif.</p>
      </div>

      <div className="bg-slate-900 border border-white/10 rounded-2xl overflow-hidden shadow-xl">
        <div className="grid grid-cols-12 gap-4 p-4 border-b border-white/5 bg-slate-950/50 text-xs font-bold text-slate-400 uppercase tracking-wider">
          <div className="col-span-1 text-center">Rank</div>
          <div className="col-span-5">Universe</div>
          <div className="col-span-3 text-right">Active Players</div>
          <div className="col-span-3 text-right">Total Visits</div>
        </div>
        
        {games.map((game, idx) => (
          <Link
            key={game.id}
            href={`/roblox/games/${game.slug}`}
            className="grid grid-cols-12 gap-4 p-4 border-b border-white/5 hover:bg-slate-800/50 transition-colors group items-center"
          >
            <div className="col-span-1 text-center font-mono font-black text-emerald-500 text-lg">
              {idx + 1}
            </div>
            <div className="col-span-5">
              <h2 className="font-bold text-white group-hover:text-emerald-400 truncate">{game.gameName}</h2>
              <p className="text-xs text-slate-500 truncate">by {game.creatorName}</p>
            </div>
            <div className="col-span-3 text-right font-mono text-cyan-300">
              {game.activePlayers.toLocaleString()}
            </div>
            <div className="col-span-3 text-right font-mono text-slate-300">
              {game.visitCount.toString()}
            </div>
          </Link>
        ))}

        {games.length === 0 && (
          <div className="p-12 text-center text-slate-500">
            Data leaderboard belum tersedia.
          </div>
        )}
      </div>
    </div>
  );
}
