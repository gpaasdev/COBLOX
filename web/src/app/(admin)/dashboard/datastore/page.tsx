"use client";

import { useState, useEffect, useRef } from "react";
import { Search, Edit2, ShieldAlert, ShieldCheck } from "lucide-react";
import { getDatastoreEntries, updatePlayerData, updateUserRestriction } from "@/app/actions/opencloud";

export default function DatastorePage() {
  const [query, setQuery] = useState("");
  const [data, setData] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedPlayer, setSelectedPlayer] = useState<any>(null);
  const [banPlayer, setBanPlayer] = useState<any>(null);
  const [banLoading, setBanLoading] = useState(false);
  
  const dialogRef = useRef<HTMLDialogElement>(null);
  const banDialogRef = useRef<HTMLDialogElement>(null);

  useEffect(() => {
    fetchData();
  }, [query]);

  const fetchData = async () => {
    setLoading(true);
    const result = await getDatastoreEntries(query);
    setData(result);
    setLoading(false);
  };

  const handleEditClick = (player: any) => {
    setSelectedPlayer(player);
    dialogRef.current?.showModal();
  };

  const handleBanClick = (player: any) => {
    setBanPlayer(player);
    banDialogRef.current?.showModal();
  };

  const handleSave = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    const gems = parseInt(formData.get("gems") as string, 10);
    const coins = parseInt(formData.get("coins") as string, 10);
    const auraEnergy = parseInt(formData.get("auraEnergy") as string, 10);
    const chronoSparks = parseInt(formData.get("chronoSparks") as string, 10);
    
    if (selectedPlayer) {
      await updatePlayerData(selectedPlayer.id, { gems, coins, auraEnergy, chronoSparks });
      await fetchData();
    }
    dialogRef.current?.close();
  };

  const handleBanSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!banPlayer) return;
    setBanLoading(true);
    
    const formData = new FormData(e.currentTarget);
    const action = formData.get("actionType") as string;
    const active = action === "ban";
    const duration = parseInt(formData.get("duration") as string, 10) || 3600;
    const displayReason = formData.get("displayReason") as string || "Pelanggaran Aturan Game COBLOX";
    const privateReason = formData.get("privateReason") as string || "Diban dari Dashboard Admin";

    try {
      await updateUserRestriction(banPlayer.id, active, active ? duration : undefined, active ? displayReason : undefined, active ? privateReason : undefined);
      alert(`Berhasil ${active ? "memblokir" : "membuka blokir"} pemain @${banPlayer.username}`);
      await fetchData();
    } catch (err: any) {
      alert(`Gagal memproses pembatasan: ${err.message}`);
    } finally {
      setBanLoading(false);
      banDialogRef.current?.close();
    }
  };

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">DataStore Viewer</h1>
          <p className="text-slate-500">View and modify live player data from Roblox Open Cloud.</p>
        </div>

        <search>
          <form className="relative flex items-center" onSubmit={(e) => e.preventDefault()}>
            <Search className="absolute left-3 h-4 w-4 text-slate-400" />
            <input
              type="search"
              placeholder="Search User ID..."
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              className="w-full rounded-lg border border-slate-200 bg-white py-2 pl-9 pr-4 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500 sm:w-64"
              aria-label="Search players"
            />
          </form>
        </search>
      </div>

      <div className="overflow-hidden rounded-xl border border-slate-200 bg-white shadow-[0_2px_10px_rgb(0,0,0,0.02)]">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-slate-600">
            <thead className="bg-slate-50 text-slate-500">
              <tr>
                <th className="px-6 py-4 font-medium">Player Avatar</th>
                <th className="px-6 py-4 font-medium">Username</th>
                <th className="px-6 py-4 font-medium">Aura / Sparks</th>
                <th className="px-6 py-4 font-medium">Coins / Gems</th>
                <th className="px-6 py-4 font-medium">Status</th>
                <th className="px-6 py-4 font-medium text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {loading ? (
                <tr>
                  <td colSpan={6} className="px-6 py-8 text-center text-slate-400">Loading live data...</td>
                </tr>
              ) : data.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-6 py-8 text-center text-slate-400">No active player profiles found.</td>
                </tr>
              ) : (
                data.map((player) => (
                  <tr key={player.id} className="transition-colors hover:bg-slate-50">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        {player.avatarUrl && (
                          <img
                            src={player.avatarUrl}
                            alt={player.username}
                            className="h-10 w-10 rounded-full border border-slate-200 bg-slate-100"
                          />
                        )}
                        <div>
                          <div className="font-semibold text-slate-900">{player.displayName || player.username}</div>
                          <div className="text-xs text-slate-400">ID: {player.id}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 font-mono text-slate-700">@{player.username}</td>
                    <td className="px-6 py-4">
                      <div className="font-semibold text-amber-600">✨ Aura: {player.auraEnergy?.toLocaleString()}</div>
                      <div className="text-xs text-cyan-600">⚡ Sparks: {player.chronoSparks?.toLocaleString()}</div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="font-semibold text-emerald-600">💰 {player.coins?.toLocaleString()}</div>
                      <div className="text-xs text-purple-600">💎 {player.gems?.toLocaleString()}</div>
                    </td>
                    <td className="px-6 py-4">
                      <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold ${
                        player.status === "Active" ? "bg-green-100 text-green-700" : "bg-red-100 text-red-700"
                      }`}>
                        {player.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <div className="flex items-center justify-end gap-1">
                        <button
                          onClick={() => handleEditClick(player)}
                          className="inline-flex items-center justify-center rounded-md p-2 text-slate-400 transition-colors hover:bg-blue-50 hover:text-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-500"
                          title="Edit Player Data"
                          aria-label={`Edit ${player.username}`}
                        >
                          <Edit2 className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => handleBanClick(player)}
                          className="inline-flex items-center justify-center rounded-md p-2 text-rose-400 transition-colors hover:bg-rose-50 hover:text-rose-600 focus:outline-none focus:ring-2 focus:ring-rose-500"
                          title="Ban / Restrict Player"
                          aria-label={`Ban ${player.username}`}
                        >
                          <ShieldAlert className="h-4 w-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Edit Modal Dialog */}
      <dialog
        ref={dialogRef}
        className="backdrop:bg-slate-900/50 open:animate-in open:fade-in-0 open:zoom-in-95 rounded-xl border border-slate-200 bg-white p-6 shadow-xl w-full max-w-md m-auto"
        onClose={() => setSelectedPlayer(null)}
      >
        <h3 className="text-lg font-semibold text-slate-900">Edit Live Player Data</h3>
        <p className="mt-1 text-sm text-slate-500">Modifying profile for <strong className="text-slate-900">@{selectedPlayer?.username}</strong></p>
        
        <form onSubmit={handleSave} className="mt-6 flex flex-col gap-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-1.5">
              <label htmlFor="auraEnergy" className="text-xs font-semibold text-amber-700">Aura Energy</label>
              <input
                id="auraEnergy"
                name="auraEnergy"
                type="number"
                min="0"
                required
                defaultValue={selectedPlayer?.auraEnergy}
                className="rounded-lg border border-slate-200 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
              />
            </div>
            
            <div className="flex flex-col gap-1.5">
              <label htmlFor="chronoSparks" className="text-xs font-semibold text-cyan-700">Chrono Sparks</label>
              <input
                id="chronoSparks"
                name="chronoSparks"
                type="number"
                min="0"
                required
                defaultValue={selectedPlayer?.chronoSparks}
                className="rounded-lg border border-slate-200 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-1.5">
              <label htmlFor="coins" className="text-xs font-semibold text-emerald-700">Coins Balance</label>
              <input
                id="coins"
                name="coins"
                type="number"
                min="0"
                required
                defaultValue={selectedPlayer?.coins}
                className="rounded-lg border border-slate-200 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
              />
            </div>

            <div className="flex flex-col gap-1.5">
              <label htmlFor="gems" className="text-xs font-semibold text-purple-700">Gems Balance</label>
              <input
                id="gems"
                name="gems"
                type="number"
                min="0"
                required
                defaultValue={selectedPlayer?.gems}
                className="rounded-lg border border-slate-200 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
              />
            </div>
          </div>
          
          <div className="mt-4 flex justify-end gap-3">
            <button
              type="button"
              onClick={() => dialogRef.current?.close()}
              className="rounded-lg px-4 py-2 text-sm font-medium text-slate-600 hover:bg-slate-100 focus:outline-none focus:ring-2 focus:ring-slate-200"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
            >
              Save Changes to Open Cloud
            </button>
          </div>
        </form>
      </dialog>

      {/* Ban / User Restriction Modal Dialog */}
      <dialog
        ref={banDialogRef}
        className="backdrop:bg-slate-900/50 open:animate-in open:fade-in-0 open:zoom-in-95 rounded-xl border border-slate-200 bg-white p-6 shadow-xl w-full max-w-md m-auto"
        onClose={() => setBanPlayer(null)}
      >
        <div className="flex items-center gap-2 text-rose-600 font-bold text-lg">
          <ShieldAlert className="h-5 w-5" />
          <span>User Restriction & Moderation</span>
        </div>
        <p className="mt-1 text-sm text-slate-500">Kelola status larangan akses Roblox Open Cloud untuk <strong className="text-slate-900">@{banPlayer?.username}</strong></p>
        
        <form onSubmit={handleBanSubmit} className="mt-5 flex flex-col gap-4">
          <div className="flex flex-col gap-1.5">
            <label htmlFor="actionType" className="text-xs font-semibold text-slate-700">Tindakan Moderasi</label>
            <select
              id="actionType"
              name="actionType"
              className="rounded-lg border border-slate-200 px-3 py-2 text-sm focus:border-rose-500 focus:outline-none focus:ring-1 focus:ring-rose-500"
            >
              <option value="ban">🔒 Berlakukan Ban (Tutup Akses)</option>
              <option value="unban">🔓 Buka Ban (Pulihkan Akses)</option>
            </select>
          </div>

          <div className="flex flex-col gap-1.5">
            <label htmlFor="duration" className="text-xs font-semibold text-slate-700">Durasi Ban (Detik)</label>
            <input
              id="duration"
              name="duration"
              type="number"
              min="60"
              defaultValue={86400}
              placeholder="3600 = 1 Jam, 86400 = 24 Jam"
              className="rounded-lg border border-slate-200 px-3 py-2 text-sm focus:border-rose-500 focus:outline-none focus:ring-1 focus:ring-rose-500"
            />
          </div>

          <div className="flex flex-col gap-1.5">
            <label htmlFor="displayReason" className="text-xs font-semibold text-slate-700">Alasan Publik (Terlihat oleh Pemain)</label>
            <input
              id="displayReason"
              name="displayReason"
              type="text"
              defaultValue="Pelanggaran Aturan Game & Eksploitasi COBLOX."
              className="rounded-lg border border-slate-200 px-3 py-2 text-sm focus:border-rose-500 focus:outline-none focus:ring-1 focus:ring-rose-500"
            />
          </div>

          <div className="flex flex-col gap-1.5">
            <label htmlFor="privateReason" className="text-xs font-semibold text-slate-700">Catatan Internal Admin (Privat)</label>
            <textarea
              id="privateReason"
              name="privateReason"
              rows={2}
              defaultValue="Eksploitasi duplikasi elemen alkimia terdeteksi oleh sistem."
              className="rounded-lg border border-slate-200 px-3 py-2 text-sm focus:border-rose-500 focus:outline-none focus:ring-1 focus:ring-rose-500"
            />
          </div>

          <div className="mt-4 flex justify-end gap-3">
            <button
              type="button"
              onClick={() => banDialogRef.current?.close()}
              className="rounded-lg px-4 py-2 text-sm font-medium text-slate-600 hover:bg-slate-100 focus:outline-none focus:ring-2 focus:ring-slate-200"
            >
              Batal
            </button>
            <button
              type="submit"
              disabled={banLoading}
              className="rounded-lg bg-rose-600 px-4 py-2 text-sm font-medium text-white hover:bg-rose-700 focus:outline-none focus:ring-2 focus:ring-rose-500 focus:ring-offset-2 disabled:opacity-50"
            >
              {banLoading ? "Memproses..." : "Eksekusi Moderasi"}
            </button>
          </div>
        </form>
      </dialog>
    </div>
  );
}
