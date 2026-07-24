"use client";

import { Users, Activity, CreditCard, ChevronRight } from "lucide-react";
import Link from "next/link";

export default function AdminDashboard() {
  return (
    <div className="min-h-screen bg-slate-950 text-slate-50 font-sans selection:bg-emerald-500/30 p-8">
      {/* Header */}
      <header className="mb-12 flex justify-between items-end border-b border-white/10 pb-6">
        <div>
          <h1 className="text-3xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-emerald-400 to-cyan-300">
            COBLOX Command Center
          </h1>
          <p className="text-slate-400 mt-2 text-sm">Overview of ecosystem health and analytics</p>
        </div>
        <div className="flex gap-4">
          <span className="px-3 py-1 bg-emerald-500/10 text-emerald-400 rounded-full text-xs font-medium border border-emerald-500/20 flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
            Systems Nominal
          </span>
        </div>
      </header>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
        <StatCard
          title="Active Subscriptions"
          value="1,248"
          trend="+12% this week"
          icon={<CreditCard className="w-5 h-5 text-emerald-400" />}
        />
        <div className="bg-slate-900/50 border border-white/5 rounded-2xl p-6 relative overflow-hidden group hover:border-cyan-500/30 transition-colors">
          <div className="absolute -right-6 -top-6 w-32 h-32 bg-cyan-500/10 rounded-full blur-2xl group-hover:bg-cyan-500/20 transition-all"></div>
          <div className="flex justify-between items-start mb-4 relative z-10">
            <h3 className="text-slate-400 font-medium text-sm">Concurrent Players</h3>
            <div className="p-2 bg-slate-800 rounded-lg">
              <Users className="w-5 h-5 text-cyan-400" />
            </div>
          </div>
          <p className="text-3xl font-bold text-slate-100 relative z-10">8,402</p>
          <p className="text-emerald-400 text-xs mt-2 font-medium relative z-10">+2.4% vs last hour</p>
        </div>
        <StatCard
          title="Webhook Events"
          value="45.2k"
          trend="Nominal volume"
          icon={<Activity className="w-5 h-5 text-purple-400" />}
        />
      </div>

      {/* Main Content Area */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Recent Webhook Logs */}
        <div className="lg:col-span-2 bg-slate-900/40 border border-white/5 rounded-2xl overflow-hidden backdrop-blur-sm">
          <div className="p-6 border-b border-white/5 flex justify-between items-center">
            <h2 className="text-lg font-semibold text-slate-200">Recent Webhook Events</h2>
            <Link href="/admin/webhooks" className="text-xs text-emerald-400 hover:text-emerald-300 flex items-center transition-colors">
              View All <ChevronRight className="w-3 h-3 ml-1" />
            </Link>
          </div>
          <div className="divide-y divide-white/5">
            {[
              { id: "evt_1", type: "Subscription Started", user: "RobloxUser_77", time: "2m ago", status: "Processed" },
              { id: "evt_2", type: "Subscription Renewed", user: "AlchemistMaster", time: "15m ago", status: "Processed" },
              { id: "evt_3", type: "Subscription Cancelled", user: "NoobSlayer99", time: "1h ago", status: "Logged" },
            ].map((log) => (
              <div key={log.id} className="p-4 flex items-center justify-between hover:bg-white/[0.02] transition-colors cursor-pointer group">
                <div className="flex items-center gap-4">
                  <div className={`w-2 h-2 rounded-full ${log.type.includes('Cancel') ? 'bg-rose-500' : 'bg-emerald-500'}`}></div>
                  <div>
                    <p className="text-sm font-medium text-slate-200 group-hover:text-emerald-400 transition-colors">{log.type}</p>
                    <p className="text-xs text-slate-500">{log.user}</p>
                  </div>
                </div>
                <div className="text-right">
                  <p className="text-xs text-slate-400 mb-1">{log.time}</p>
                  <span className="text-[10px] uppercase tracking-wider font-semibold text-slate-500">{log.status}</span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Quick Actions */}
        <div className="bg-slate-900/40 border border-white/5 rounded-2xl p-6 backdrop-blur-sm">
          <h2 className="text-lg font-semibold text-slate-200 mb-6">Quick Actions</h2>
          <div className="flex flex-col gap-3">
            <button className="w-full py-3 px-4 bg-white/5 hover:bg-emerald-500/10 border border-white/5 hover:border-emerald-500/30 rounded-xl text-sm font-medium text-slate-300 hover:text-emerald-400 transition-all flex items-center justify-between group">
              Sync Roblox Analytics
              <ChevronRight className="w-4 h-4 opacity-50 group-hover:opacity-100 group-hover:translate-x-1 transition-all" />
            </button>
            <button className="w-full py-3 px-4 bg-white/5 hover:bg-emerald-500/10 border border-white/5 hover:border-emerald-500/30 rounded-xl text-sm font-medium text-slate-300 hover:text-emerald-400 transition-all flex items-center justify-between group">
              Manage Subscriptions
              <ChevronRight className="w-4 h-4 opacity-50 group-hover:opacity-100 group-hover:translate-x-1 transition-all" />
            </button>
            <button className="w-full py-3 px-4 bg-white/5 hover:bg-cyan-500/10 border border-white/5 hover:border-cyan-500/30 rounded-xl text-sm font-medium text-slate-300 hover:text-cyan-400 transition-all flex items-center justify-between group">
              View Database Metrics
              <ChevronRight className="w-4 h-4 opacity-50 group-hover:opacity-100 group-hover:translate-x-1 transition-all" />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

function StatCard({ title, value, trend, icon }: { title: string; value: string; trend: string; icon: React.ReactNode }) {
  return (
    <div className="bg-slate-900/50 border border-white/5 rounded-2xl p-6 relative overflow-hidden group hover:border-emerald-500/30 transition-colors">
      <div className="absolute -right-6 -top-6 w-32 h-32 bg-emerald-500/5 rounded-full blur-2xl group-hover:bg-emerald-500/10 transition-all"></div>
      <div className="flex justify-between items-start mb-4 relative z-10">
        <h3 className="text-slate-400 font-medium text-sm">{title}</h3>
        <div className="p-2 bg-slate-800 rounded-lg shadow-inner">
          {icon}
        </div>
      </div>
      <p className="text-3xl font-bold text-slate-100 relative z-10">{value}</p>
      <p className="text-emerald-400 text-xs mt-2 font-medium relative z-10">{trend}</p>
    </div>
  );
}
