"use client";

import { useEffect, useState, useCallback } from "react";
import {
  Activity,
  Server,
  Users,
  Clock,
  AlertTriangle,
  CheckCircle,
  XCircle,
  RefreshCw,
  Loader2,
} from "lucide-react";

interface ServiceHealth {
  name: string;
  status: "operational" | "degraded" | "down";
  latency: string;
  uptime: string;
}

interface ServerMetric {
  label: string;
  value: string;
  status: "good" | "warning" | "fail";
}

interface MonitoringData {
  services: ServiceHealth[];
  metrics: ServerMetric[];
  apiAvailable: boolean;
  polledAt: string;
}

export default function MonitoringPage() {
  const [data, setData] = useState<MonitoringData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const poll = useCallback(async () => {
    setError(null);
    try {
      const res = await fetch("/api/monitoring");
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const result: MonitoringData = await res.json();
      setData(result);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Poll failed");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    poll();
    const interval = setInterval(poll, 30000);
    return () => clearInterval(interval);
  }, [poll]);

  if (loading) {
    return (
      <div className="flex items-center justify-center py-20">
        <Loader2 className="h-8 w-8 animate-spin text-slate-400" />
      </div>
    );
  }

  const services = data?.services ?? [];
  const metrics = data?.metrics ?? [];
  const apiAvailable = data?.apiAvailable ?? false;

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">System Monitoring</h1>
          <p className="text-slate-500">
            Real-time health status and performance metrics.
            <span className="ml-2 text-xs text-slate-400">Polling every 30s</span>
          </p>
        </div>
        <div className="flex items-center gap-3">
          {!apiAvailable && (
            <span className="flex items-center gap-1.5 rounded-lg bg-amber-50 px-3 py-1.5 text-xs font-medium text-amber-700">
              <AlertTriangle className="h-3 w-3" />
              Live API unavailable
            </span>
          )}
          <button
            onClick={poll}
            className="inline-flex items-center gap-2 rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-medium text-slate-600 transition-colors hover:bg-slate-50"
          >
            <RefreshCw className="h-4 w-4" />
            Refresh Now
          </button>
        </div>
      </div>

      {error && (
        <div className="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          <XCircle className="h-4 w-4 shrink-0" />
          {error}
        </div>
      )}

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        <section className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-center gap-2 mb-4">
            <Server className="h-5 w-5 text-blue-600" />
            <h2 className="text-lg font-semibold text-slate-900">Service Health</h2>
          </div>
          <div className="space-y-3">
            {services.length === 0 ? (
              <p className="py-4 text-center text-sm text-slate-400">No service data available.</p>
            ) : (
              services.map((svc) => (
                <div key={svc.name} className="flex items-center justify-between py-2 border-b border-slate-100 last:border-0">
                  <div className="flex items-center gap-3">
                    {svc.status === "operational" ? (
                      <CheckCircle className="h-4 w-4 shrink-0 text-emerald-500" />
                    ) : svc.status === "degraded" ? (
                      <AlertTriangle className="h-4 w-4 shrink-0 text-amber-500" />
                    ) : (
                      <XCircle className="h-4 w-4 shrink-0 text-red-500" />
                    )}
                    <span className="text-sm font-medium text-slate-700">{svc.name}</span>
                  </div>
                  <div className="flex items-center gap-4 text-xs text-slate-500">
                    {svc.latency !== "--" && <span className="font-mono">{svc.latency}</span>}
                    {svc.uptime !== "--" && <span className="font-mono">{svc.uptime}</span>}
                  </div>
                </div>
              ))
            )}
          </div>
        </section>

        <section className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-center gap-2 mb-4">
            <Activity className="h-5 w-5 text-emerald-600" />
            <h2 className="text-lg font-semibold text-slate-900">Performance KPIs</h2>
          </div>
          <div className="space-y-3">
            {metrics.length === 0 ? (
              <p className="py-4 text-center text-sm text-slate-400">No metric data available.</p>
            ) : (
              metrics.map((m) => (
                <div key={m.label} className="flex items-center justify-between py-2 border-b border-slate-100 last:border-0">
                  <span className="text-sm text-slate-700">{m.label}</span>
                  <div className="flex items-center gap-3">
                    <span className="text-sm font-mono text-slate-600">{m.value}</span>
                    <span className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-semibold ${
                      m.status === "good"
                        ? "bg-emerald-100 text-emerald-700"
                        : m.status === "warning"
                          ? "bg-amber-100 text-amber-700"
                          : "bg-red-100 text-red-700"
                    }`}>
                      {m.status === "good" ? "OK" : m.status === "warning" ? "WARN" : "FAIL"}
                    </span>
                  </div>
                </div>
              ))
            )}
          </div>

          {data?.polledAt && (
            <div className="mt-6 border-t border-slate-100 pt-4">
              <div className="flex items-center gap-2 text-xs text-slate-400">
                <Clock className="h-3 w-3" />
                Last polled: {new Date(data.polledAt).toLocaleTimeString()}
              </div>
            </div>
          )}
        </section>
      </div>

      <div className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <div className="flex items-center gap-2 mb-4">
          <Users className="h-5 w-5 text-indigo-600" />
          <h2 className="text-lg font-semibold text-slate-900">Quick Health Summary</h2>
        </div>
        <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
          <MetricSummaryCard
            label="Operational"
            value={services.filter((s) => s.status === "operational").length}
            total={services.length}
            color="emerald"
          />
          <MetricSummaryCard
            label="Degraded"
            value={services.filter((s) => s.status === "degraded").length}
            total={services.length}
            color="amber"
          />
          <MetricSummaryCard
            label="Down"
            value={services.filter((s) => s.status === "down").length}
            total={services.length}
            color="red"
          />
          <MetricSummaryCard
            label="API Status"
            value={apiAvailable ? "Online" : "Offline"}
            total={0}
            color={apiAvailable ? "emerald" : "red"}
          />
        </div>
      </div>
    </div>
  );
}

function MetricSummaryCard({
  label,
  value,
  total,
  color,
}: {
  label: string;
  value: number | string;
  total: number;
  color: "emerald" | "amber" | "red" | "blue";
}) {
  const colorClasses = {
    emerald: "bg-emerald-50 text-emerald-700 border-emerald-200",
    amber: "bg-amber-50 text-amber-700 border-amber-200",
    red: "bg-red-50 text-red-700 border-red-200",
    blue: "bg-blue-50 text-blue-700 border-blue-200",
  };

  return (
    <div className={`rounded-lg border p-4 ${colorClasses[color]}`}>
      <p className="text-xs font-medium uppercase tracking-wider opacity-70">{label}</p>
      <p className="mt-1 text-2xl font-bold">
        {value}
        {typeof value === "number" && total > 0 && (
          <span className="ml-1 text-sm font-normal opacity-60">/ {total}</span>
        )}
      </p>
    </div>
  );
}
