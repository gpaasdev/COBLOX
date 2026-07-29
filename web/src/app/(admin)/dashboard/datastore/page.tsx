"use client";

import { useState } from "react";
import { Database, Search, Loader2, AlertCircle } from "lucide-react";

export default function DatastorePage() {
  const [datastoreName, setDatastoreName] = useState("COBLOX_DataStore_LGBOS_v11");
  const [entryKey, setEntryKey] = useState("");
  const [data, setData] = useState<unknown>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchEntry = async () => {
    if (!datastoreName.trim() || !entryKey.trim()) return;

    setLoading(true);
    setError(null);
    setData(null);

    try {
      const params = new URLSearchParams({
        datastoreName: datastoreName.trim(),
        key: entryKey.trim(),
      });
      const res = await fetch(`/api/datastore?${params}`);

      if (!res.ok) {
        const errData = await res.json().catch(() => ({}));
        throw new Error(errData.error ?? `HTTP ${res.status}: ${res.statusText}`);
      }

      const result = await res.json();
      setData(result.data);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to fetch DataStore entry");
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    fetchEntry();
  };

  return (
    <div className="flex flex-col gap-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-slate-900">DataStore Viewer</h1>
        <p className="text-slate-500">Read entries from Roblox Open Cloud DataStore.</p>
      </div>

      <form onSubmit={handleSubmit} className="flex flex-col gap-4 rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <div className="grid gap-4 sm:grid-cols-2">
          <div className="flex flex-col gap-1.5">
            <label htmlFor="datastoreName" className="text-sm font-medium text-slate-700">
              DataStore Name
            </label>
            <input
              id="datastoreName"
              type="text"
              value={datastoreName}
              onChange={(e) => setDatastoreName(e.target.value)}
              placeholder="e.g. COBLOX_DataStore_LGBOS_v11"
              className="rounded-lg border border-slate-200 px-3 py-2 font-mono text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
            />
          </div>
          <div className="flex flex-col gap-1.5">
            <label htmlFor="entryKey" className="text-sm font-medium text-slate-700">
              Entry Key
            </label>
            <input
              id="entryKey"
              type="text"
              value={entryKey}
              onChange={(e) => setEntryKey(e.target.value)}
              placeholder="e.g. COBLOX_LGBOS_v11_123456789"
              className="rounded-lg border border-slate-200 px-3 py-2 font-mono text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
            />
          </div>
        </div>

        <div className="flex items-center justify-between">
          <p className="text-xs text-slate-400">
            Reads from Roblox Open Cloud DataStore API (read-only).
          </p>
          <button
            type="submit"
            disabled={loading || !datastoreName.trim() || !entryKey.trim()}
            className="inline-flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white transition-colors hover:bg-blue-700 disabled:opacity-50"
          >
            {loading ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              <Search className="h-4 w-4" />
            )}
            {loading ? "Fetching..." : "Fetch Entry"}
          </button>
        </div>
      </form>

      {error && (
        <div className="flex items-start gap-3 rounded-xl border border-red-200 bg-red-50 p-4">
          <AlertCircle className="mt-0.5 h-5 w-5 shrink-0 text-red-500" />
          <div>
            <p className="text-sm font-medium text-red-800">Error</p>
            <p className="mt-0.5 text-sm text-red-600">{error}</p>
          </div>
        </div>
      )}

      {data !== null && (
        <div className="rounded-xl border border-slate-200 bg-white shadow-sm">
          <div className="flex items-center gap-2 border-b border-slate-100 px-6 py-4">
            <Database className="h-4 w-4 text-blue-600" />
            <h2 className="text-sm font-semibold text-slate-700">
              {datastoreName} / {entryKey}
            </h2>
          </div>
          <pre className="overflow-auto p-6 text-sm">
            <code className="font-mono text-slate-700">
              {JSON.stringify(data, null, 2)}
            </code>
          </pre>
        </div>
      )}
    </div>
  );
}
