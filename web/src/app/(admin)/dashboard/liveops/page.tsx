"use client";

import { useState } from "react";
import { Send, CheckCircle2, Activity, Server, Users, ShieldAlert, ShieldCheck } from "lucide-react";
import { sendLiveOpsMessage } from "@/app/actions/opencloud";
import liveopsData from "@/data/liveops.json";

export default function LiveOpsPage() {
  const [topic, setTopic] = useState("System_Alerts");
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);

  const handleBroadcast = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!message) return;

    setLoading(true);
    setSuccess(false);

    const result = await sendLiveOpsMessage(topic, message);
    
    setLoading(false);
    if (result.success) {
      setSuccess(true);
      setMessage("");
      setTimeout(() => setSuccess(false), 3000);
    }
  };

  return (
    <div className="flex flex-col gap-6 max-w-5xl">
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-slate-900">LiveOps Intelligence</h1>
        <p className="text-slate-500">Monitor production telemetry and dispatch real-time events.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="md:col-span-2 flex flex-col gap-6">
          {/* Telemetry Overview */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
              <div className="flex items-center gap-2 text-slate-500 mb-2">
                <Users className="w-4 h-4" />
                <span className="text-xs font-semibold uppercase tracking-wider">Est. CCU</span>
              </div>
              <div className="text-3xl font-bold text-slate-900">{liveopsData.estimated_ccu}</div>
            </div>
            
            <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
              <div className="flex items-center gap-2 text-slate-500 mb-2">
                <Activity className="w-4 h-4" />
                <span className="text-xs font-semibold uppercase tracking-wider">Visits</span>
              </div>
              <div className="text-3xl font-bold text-slate-900">{liveopsData.total_visits}</div>
            </div>

            <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
              <div className="flex items-center gap-2 text-slate-500 mb-2">
                <Server className="w-4 h-4" />
                <span className="text-xs font-semibold uppercase tracking-wider">DS Entries</span>
              </div>
              <div className="text-3xl font-bold text-slate-900">{liveopsData.entries_sampled}</div>
            </div>

            <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
              <div className="flex items-center gap-2 text-slate-500 mb-2">
                <ShieldAlert className="w-4 h-4" />
                <span className="text-xs font-semibold uppercase tracking-wider">Anomalies</span>
              </div>
              <div className="text-3xl font-bold text-red-600">{liveopsData.anomalies_detected?.length || 0}</div>
            </div>
          </div>

          {/* Dispatcher Form */}
          <div className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
            <h2 className="text-lg font-bold text-slate-900 mb-4">Dispatcher</h2>
            <form onSubmit={handleBroadcast} className="flex flex-col gap-5">
              <div className="flex flex-col gap-1.5">
                <label htmlFor="topic" className="text-sm font-medium text-slate-700">Messaging Topic</label>
                <select
                  id="topic"
                  value={topic}
                  onChange={(e) => setTopic(e.target.value)}
                  className="rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
                >
                  <option value="System_Alerts">System Alerts (In-Game Banner)</option>
                  <option value="Live_Event">Live Event Triggers</option>
                  <option value="Maintenance">Maintenance Warnings</option>
                </select>
              </div>

              <div className="flex flex-col gap-1.5">
                <label htmlFor="message" className="text-sm font-medium text-slate-700">Message Content</label>
                <textarea
                  id="message"
                  rows={4}
                  required
                  value={message}
                  onChange={(e) => setMessage(e.target.value)}
                  placeholder="Enter broadcast message..."
                  className="resize-none rounded-lg border border-slate-200 p-3 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
              </div>

              <div className="mt-2 flex items-center justify-between">
                {success ? (
                  <div className="flex items-center gap-2 text-sm font-medium text-green-600">
                    <CheckCircle2 className="h-4 w-4" />
                    Broadcast successful!
                  </div>
                ) : (
                  <div /> // Spacer
                )}
                
                <button
                  type="submit"
                  disabled={loading || !message}
                  className="inline-flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white transition-colors hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50"
                >
                  <Send className="h-4 w-4" />
                  {loading ? "Dispatching..." : "Send Broadcast"}
                </button>
              </div>
            </form>
          </div>
        </div>

        {/* Right Sidebar - Confidence Matrix */}
        <div className="flex flex-col gap-4">
          <div className="rounded-xl border border-slate-200 bg-slate-50 p-5 shadow-sm h-full">
            <h2 className="text-lg font-bold text-slate-900 mb-4 flex items-center gap-2">
              <ShieldCheck className="w-5 h-5 text-emerald-600" />
              Confidence Matrix
            </h2>
            <div className="flex flex-col gap-3">
              {Object.entries(liveopsData.confidence || {}).map(([domain, status]) => (
                <div key={domain} className="flex items-center justify-between py-2 border-b border-slate-200/60 last:border-0">
                  <span className="text-sm font-medium text-slate-700">{domain}</span>
                  <span className={`text-xs font-bold px-2 py-1 rounded-md ${
                    status === 'HIGH' || status === 'VERIFIED' ? 'bg-emerald-100 text-emerald-700' :
                    status === 'LOW' ? 'bg-amber-100 text-amber-700' :
                    'bg-slate-200 text-slate-600'
                  }`}>
                    {String(status)}
                  </span>
                </div>
              ))}
            </div>
            {liveopsData.anomalies_detected && liveopsData.anomalies_detected.length > 0 && (
              <div className="mt-6">
                <h3 className="text-sm font-bold text-red-700 mb-2">Detected Anomalies</h3>
                <ul className="text-xs text-red-600 space-y-1 list-disc list-inside">
                  {liveopsData.anomalies_detected.map((a: string, i: number) => <li key={i}>{a}</li>)}
                </ul>
              </div>
            )}
            <div className="mt-6 text-xs text-slate-400 font-mono text-center">
              Auto-synced via GitHub Actions
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
