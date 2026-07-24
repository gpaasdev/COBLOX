import { Users, Coins, AlertCircle, Activity } from "lucide-react";

export default function DashboardOverview() {
  return (
    <div className="flex flex-col gap-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-slate-900">Platform Overview</h1>
        <p className="text-slate-500">Key metrics and LiveOps health status.</p>
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <MetricCard
          title="Active Players"
          value="1,234"
          trend="+12%"
          icon={<Users className="h-5 w-5 text-blue-600" />}
        />
        <MetricCard
          title="Avg. Session Length"
          value="45m"
          trend="+2m"
          icon={<Activity className="h-5 w-5 text-indigo-600" />}
        />
        <MetricCard
          title="Economy Sink Rate"
          value="8.4M"
          trend="-1.2M"
          icon={<Coins className="h-5 w-5 text-amber-600" />}
        />
        <MetricCard
          title="Active Alerts"
          value="3"
          trend="Needs Attention"
          trendColor="text-red-600"
          icon={<AlertCircle className="h-5 w-5 text-red-600" />}
        />
      </div>

      <div className="mt-8 grid grid-cols-1 gap-6 lg:grid-cols-2">
        <div className="rounded-xl border border-slate-200 bg-white p-6 shadow-[0_2px_10px_rgb(0,0,0,0.02)]">
          <h3 className="mb-4 text-lg font-semibold text-slate-900">Recent Activity</h3>
          <div className="space-y-4">
            {[1, 2, 3].map((i) => (
              <div key={i} className="flex items-center justify-between border-b border-slate-100 pb-4 last:border-0 last:pb-0">
                <div>
                  <p className="text-sm font-medium text-slate-800">User Player{i * 123} triggered [Rare Summon]</p>
                  <p className="text-xs text-slate-500">{i * 2} minutes ago</p>
                </div>
                <span className="inline-flex items-center rounded-full bg-slate-100 px-2.5 py-0.5 text-xs font-semibold text-slate-800">
                  Event
                </span>
              </div>
            ))}
          </div>
        </div>

        <div className="rounded-xl border border-slate-200 bg-white p-6 shadow-[0_2px_10px_rgb(0,0,0,0.02)]">
          <h3 className="mb-4 text-lg font-semibold text-slate-900">LiveOps Queue</h3>
          <p className="text-sm text-slate-600">No pending live operations. Server is running smoothly.</p>
        </div>
      </div>
    </div>
  );
}

function MetricCard({
  title,
  value,
  trend,
  trendColor = "text-green-600",
  icon,
}: {
  title: string;
  value: string;
  trend: string;
  trendColor?: string;
  icon: React.ReactNode;
}) {
  return (
    <div className="rounded-xl border border-slate-200 bg-white p-6 shadow-[0_2px_10px_rgb(0,0,0,0.02)] transition-all hover:-translate-y-1 hover:shadow-md">
      <div className="flex items-center justify-between">
        <h3 className="text-sm font-medium text-slate-500">{title}</h3>
        <div className="rounded-md bg-slate-50 p-2">{icon}</div>
      </div>
      <div className="mt-4 flex items-baseline gap-2">
        <p className="text-3xl font-bold text-slate-900">{value}</p>
        <span className={`text-sm font-medium ${trendColor}`}>{trend}</span>
      </div>
    </div>
  );
}
