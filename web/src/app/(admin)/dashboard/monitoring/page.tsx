"use client";
import { Activity, Server, Clock, AlertTriangle, CheckCircle, XCircle } from "lucide-react";

const services = [
  { name: "Roblox Open Cloud API", status: "operational", latency: "45ms", uptime: "99.97%" },
  { name: "ProfileStore (DataStore)", status: "operational", latency: "120ms", uptime: "99.99%" },
  { name: "MessagingService", status: "operational", latency: "88ms", uptime: "99.95%" },
  { name: "Place Publishing (CI/CD)", status: "operational", latency: "12s", uptime: "100%" },
  { name: "Asset Upload Pipeline", status: "operational", latency: "3.2s", uptime: "100%" },
  { name: "Fairytale Realm (Place 2)", status: "operational", latency: "—", uptime: "99.9%" },
  { name: "Web Portal (hycoblox.vercel.app)", status: "operational", latency: "230ms", uptime: "99.8%" },
  { name: "OAuth2 Token Exchange", status: "operational", latency: "350ms", uptime: "configuring" },
  { name: "Asset Moderation Queue", status: "degraded", latency: "17 meshes pending", uptime: "awaiting approval" },
];

const serverMetrics = [
  { label: "Server Frame Rate", value: "60 FPS", status: "good" },
  { label: "Client Frame Rate (PC)", value: "60 FPS", status: "good" },
  { label: "Client Frame Rate (Mobile)", value: "30-60 FPS", status: "good" },
  { label: "Memory Usage (Server)", value: "<1.2 GB", status: "good" },
  { label: "Active BillboardGuis", value: "≤20 (culled)", status: "good" },
  { label: "Hardcoded Strings", value: "0", status: "good" },
  { label: "Configured Badge Ratio", value: "7/15 (46.7%)", status: "warning" },
  { label: "Configured Product IDs", value: "18/24 (75%)", status: "warning" },
];

export default function MonitoringPage() {
  return (
    <div className="flex flex-col gap-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-slate-900">System Monitoring</h1>
        <p className="text-slate-500">Real-time health status and performance metrics.</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <section className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-center gap-2 mb-4">
            <Server className="h-5 w-5 text-blue-600" />
            <h2 className="text-lg font-semibold text-slate-900">Service Health</h2>
          </div>
          <div className="space-y-3">
            {services.map((svc) => (
              <div key={svc.name} className="flex items-center justify-between py-2 border-b border-slate-100 last:border-0">
                <div className="flex items-center gap-3">
                  {svc.status === "operational" ? (
                    <CheckCircle className="h-4 w-4 text-emerald-500 shrink-0" />
                  ) : svc.status === "degraded" ? (
                    <AlertTriangle className="h-4 w-4 text-amber-500 shrink-0" />
                  ) : (
                    <XCircle className="h-4 w-4 text-red-500 shrink-0" />
                  )}
                  <span className="text-sm font-medium text-slate-700">{svc.name}</span>
                </div>
                <div className="flex items-center gap-4 text-xs text-slate-500">
                  <span className="font-mono">{svc.latency}</span>
                  <span className="font-mono">{svc.uptime}</span>
                </div>
              </div>
            ))}
          </div>
        </section>

        <section className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-center gap-2 mb-4">
            <Activity className="h-5 w-5 text-emerald-600" />
            <h2 className="text-lg font-semibold text-slate-900">Performance KPIs</h2>
          </div>
          <div className="space-y-3">
            {serverMetrics.map((m) => (
              <div key={m.label} className="flex items-center justify-between py-2 border-b border-slate-100 last:border-0">
                <span className="text-sm text-slate-700">{m.label}</span>
                <div className="flex items-center gap-3">
                  <span className="text-sm font-mono text-slate-600">{m.value}</span>
                  <span className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-semibold ${
                    m.status === "good" ? "bg-emerald-100 text-emerald-700" :
                    m.status === "warning" ? "bg-amber-100 text-amber-700" :
                    "bg-red-100 text-red-700"
                  }`}>
                    {m.status === "good" ? "OK" : m.status === "warning" ? "WARN" : "FAIL"}
                  </span>
                </div>
              </div>
            ))}
          </div>

          <div className="mt-6 pt-4 border-t border-slate-100">
            <h3 className="text-sm font-semibold text-slate-700 mb-2">Asset Pipeline</h3>
            <div className="flex items-center justify-between text-sm">
              <span className="text-slate-500">Meshes awaiting moderation</span>
              <span className="font-mono text-amber-600 font-semibold">17 pending</span>
            </div>
            <p className="text-xs text-slate-400 mt-1">
              Poll with: <code className="bg-slate-100 px-1.5 py-0.5 rounded text-xs">python3 scripts/poll_fairytale_uploads.py --watch</code>
            </p>
          </div>
        </section>
      </div>
    </div>
  );
}
