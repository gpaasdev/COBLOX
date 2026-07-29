"use client";

import { useEffect, useState, useCallback } from "react";
import { Save, RefreshCw, Loader2, XCircle, CheckCircle } from "lucide-react";

interface ConfigEntry {
  id: string;
  key: string;
  value: string;
  type: string;
  group: string;
  description: string;
  updatedAt: string;
}

type GroupedEntries = Record<string, ConfigEntry[]>;

const TYPE_GROUPS = ["Tuning", "FeatureFlags", "StringConfig", "BoolConfig"];

const GROUP_PREFIXES = ["Combat_", "Economy_", "Pet_", "LiveOps_", "General"];

function detectGroup(key: string): string {
  for (const prefix of GROUP_PREFIXES) {
    if (key.startsWith(prefix)) return prefix.replace("_", "");
  }
  return "General";
}

function detectType(value: string): string {
  if (value === "true" || value === "false") return "BoolConfig";
  if (!isNaN(Number(value)) && value.trim() !== "") return "Tuning";
  if (value.length > 100) return "StringConfig";
  return "StringConfig";
}

export default function ConfigPage() {
  const [entries, setEntries] = useState<ConfigEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [editingKey, setEditingKey] = useState<string | null>(null);
  const [editValue, setEditValue] = useState("");
  const [saving, setSaving] = useState<string | null>(null);
  const [savedKey, setSavedKey] = useState<string | null>(null);
  const [filter, setFilter] = useState<string>("all");

  const fetchConfig = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch("/api/config");
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      setEntries(data.entries ?? []);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load config");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchConfig();
  }, [fetchConfig]);

  const startEditing = (entry: ConfigEntry) => {
    setEditingKey(entry.key);
    setEditValue(entry.value);
  };

  const cancelEditing = () => {
    setEditingKey(null);
    setEditValue("");
  };

  const saveEntry = async (entry: ConfigEntry) => {
    setSaving(entry.key);
    try {
      const res = await fetch("/api/config", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          key: entry.key,
          value: editValue,
          type: entry.type,
          group: entry.group,
        }),
      });
      if (!res.ok) {
        const errData = await res.json();
        throw new Error(errData.error ?? "Save failed");
      }
      setEditingKey(null);
      setSavedKey(entry.key);
      setTimeout(() => setSavedKey(null), 2000);
      await fetchConfig();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to save");
    } finally {
      setSaving(null);
    }
  };

  const deleteEntry = async (key: string) => {
    if (!confirm(`Delete config entry "${key}"?`)) return;
    try {
      const res = await fetch(`/api/config?key=${encodeURIComponent(key)}`, {
        method: "DELETE",
      });
      if (!res.ok) throw new Error("Delete failed");
      await fetchConfig();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to delete");
    }
  };

  const grouped: GroupedEntries = {};
  for (const entry of entries) {
    const g = entry.group || detectGroup(entry.key);
    if (!grouped[g]) grouped[g] = [];
    grouped[g].push(entry);
  }

  const filteredGroups = filter === "all"
    ? Object.entries(grouped)
    : Object.entries(grouped).filter(([g]) => g === filter);

  if (loading) {
    return (
      <div className="flex items-center justify-center py-20">
        <Loader2 className="h-8 w-8 animate-spin text-slate-400" />
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Setup & Configuration</h1>
          <p className="text-slate-500">Manage game config entries synced via MessagingService.</p>
        </div>
        <button
          onClick={fetchConfig}
          className="inline-flex items-center gap-2 rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-medium text-slate-600 transition-colors hover:bg-slate-50"
        >
          <RefreshCw className="h-4 w-4" />
          Refresh
        </button>
      </div>

      {error && (
        <div className="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          <XCircle className="h-4 w-4 shrink-0" />
          {error}
          <button onClick={() => setError(null)} className="ml-auto text-red-500 hover:text-red-700">Dismiss</button>
        </div>
      )}

      <div className="flex flex-wrap gap-2">
        <button
          onClick={() => setFilter("all")}
          className={`rounded-lg px-3 py-1.5 text-sm font-medium transition-colors ${
            filter === "all" ? "bg-slate-900 text-white" : "bg-slate-100 text-slate-600 hover:bg-slate-200"
          }`}
        >
          All Groups
        </button>
        {Object.keys(grouped).map((g) => (
          <button
            key={g}
            onClick={() => setFilter(g)}
            className={`rounded-lg px-3 py-1.5 text-sm font-medium transition-colors ${
              filter === g ? "bg-slate-900 text-white" : "bg-slate-100 text-slate-600 hover:bg-slate-200"
            }`}
          >
            {g}
          </button>
        ))}
      </div>

      {filteredGroups.length === 0 ? (
        <div className="rounded-xl border border-slate-200 bg-white p-8 text-center text-sm text-slate-400">
          No config entries found. Add entries via the API or seed the database.
        </div>
      ) : (
        filteredGroups.map(([group, groupEntries]) => (
          <section key={group} className="rounded-xl border border-slate-200 bg-white shadow-sm">
            <div className="border-b border-slate-100 px-6 py-4">
              <h2 className="text-lg font-semibold text-slate-900">{group}</h2>
            </div>
            <div className="divide-y divide-slate-100">
              {groupEntries.map((entry) => (
                <div key={entry.key} className="px-6 py-4">
                  <div className="flex items-start justify-between gap-4">
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center gap-2">
                        <span className="font-mono text-sm font-medium text-slate-800">{entry.key}</span>
                        <span className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ${
                          entry.type === "Tuning" ? "bg-blue-100 text-blue-700" :
                          entry.type === "FeatureFlags" ? "bg-purple-100 text-purple-700" :
                          entry.type === "BoolConfig" ? "bg-emerald-100 text-emerald-700" :
                          "bg-slate-100 text-slate-700"
                        }`}>
                          {entry.type}
                        </span>
                      </div>
                      {entry.description && (
                        <p className="mt-0.5 text-xs text-slate-400">{entry.description}</p>
                      )}
                    </div>
                    {savedKey === entry.key && (
                      <span className="flex items-center gap-1 text-xs font-medium text-emerald-600">
                        <CheckCircle className="h-3 w-3" />
                        Saved
                      </span>
                    )}
                  </div>

                  <div className="mt-3 flex items-center gap-3">
                    {editingKey === entry.key ? (
                      <>
                        {entry.type === "BoolConfig" ? (
                          <select
                            value={editValue}
                            onChange={(e) => setEditValue(e.target.value)}
                            className="w-full max-w-xs rounded-lg border border-blue-300 bg-blue-50 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
                          >
                            <option value="true">true</option>
                            <option value="false">false</option>
                          </select>
                        ) : entry.type === "Tuning" ? (
                          <input
                            type="number"
                            value={editValue}
                            onChange={(e) => setEditValue(e.target.value)}
                            className="w-full max-w-xs rounded-lg border border-blue-300 bg-blue-50 px-3 py-2 font-mono text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
                            step="any"
                          />
                        ) : (
                          <input
                            type="text"
                            value={editValue}
                            onChange={(e) => setEditValue(e.target.value)}
                            className="w-full max-w-md rounded-lg border border-blue-300 bg-blue-50 px-3 py-2 font-mono text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
                          />
                        )}
                        <div className="flex items-center gap-2">
                          <button
                            onClick={() => saveEntry(entry)}
                            disabled={saving === entry.key}
                            className="inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-3 py-2 text-sm font-medium text-white transition-colors hover:bg-blue-700 disabled:opacity-50"
                          >
                            {saving === entry.key ? (
                              <Loader2 className="h-3 w-3 animate-spin" />
                            ) : (
                              <Save className="h-3 w-3" />
                            )}
                            Save
                          </button>
                          <button
                            onClick={cancelEditing}
                            className="rounded-lg px-3 py-2 text-sm font-medium text-slate-500 transition-colors hover:bg-slate-100"
                          >
                            Cancel
                          </button>
                        </div>
                      </>
                    ) : (
                      <>
                        <code className="flex-1 rounded bg-slate-50 px-3 py-2 font-mono text-sm text-slate-700">
                          {entry.value}
                        </code>
                        <div className="flex items-center gap-2">
                          <button
                            onClick={() => startEditing(entry)}
                            className="rounded-lg px-3 py-2 text-sm font-medium text-blue-600 transition-colors hover:bg-blue-50"
                          >
                            Edit
                          </button>
                          <button
                            onClick={() => deleteEntry(entry.key)}
                            className="rounded-lg px-3 py-2 text-sm font-medium text-red-500 transition-colors hover:bg-red-50"
                          >
                            Delete
                          </button>
                        </div>
                      </>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </section>
        ))
      )}
    </div>
  );
}
