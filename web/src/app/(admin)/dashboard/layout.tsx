import Link from "next/link";
import { LogOut, LayoutDashboard, Database, Bell } from "lucide-react";
import { LogoutButton } from "./components/LogoutButton";

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="grid h-screen grid-cols-[260px_1fr] bg-slate-50">
      {/* Sidebar Navigation */}
      <aside className="flex flex-col border-r border-slate-200 bg-white">
        <div className="flex h-16 items-center border-b border-slate-100 px-6">
          <Link href="/dashboard" className="text-lg font-bold tracking-tight text-blue-600">
            COBLOX Admin
          </Link>
        </div>

        <nav className="flex-1 space-y-1 p-4" aria-label="Main Navigation">
          <Link
            href="/dashboard"
            className="flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-100 hover:text-slate-900"
          >
            <LayoutDashboard className="h-4 w-4" />
            Overview
          </Link>
          <Link
            href="/dashboard/datastore"
            className="flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-100 hover:text-slate-900"
          >
            <Database className="h-4 w-4" />
            DataStore Viewer
          </Link>
          <Link
            href="/dashboard/liveops"
            className="flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-100 hover:text-slate-900"
          >
            <Bell className="h-4 w-4" />
            LiveOps
          </Link>
        </nav>

        <div className="border-t border-slate-100 p-4">
          <LogoutButton />
        </div>
      </aside>

      {/* Main Content Area */}
      <main className="flex h-full flex-col overflow-y-auto">
        <header className="flex h-16 shrink-0 items-center border-b border-slate-200 bg-white px-8">
          <h2 className="text-sm font-medium text-slate-500">Live Server Status: <span className="text-green-600">Healthy</span></h2>
        </header>
        <div className="flex-1 p-8">
          {children}
        </div>
      </main>
    </div>
  );
}
