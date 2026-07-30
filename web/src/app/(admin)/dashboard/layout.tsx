import Link from "next/link";
import { LayoutDashboard, Database, Bell, Settings, Activity, FileText } from "lucide-react";
import { LogoutButton } from "./components/LogoutButton";

const navItems = [
  { href: "/dashboard", label: "Overview", icon: LayoutDashboard },
  { href: "/dashboard/datastore", label: "DataStore Viewer", icon: Database },
  { href: "/dashboard/liveops", label: "LiveOps", icon: Bell },
  { href: "/dashboard/config", label: "Setup & Config", icon: Settings },
  { href: "/dashboard/monitoring", label: "Monitoring", icon: Activity },
  { href: "/dashboard/cms", label: "Content (CMS)", icon: FileText },
];

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="grid h-screen grid-cols-[260px_1fr] bg-slate-50">
      <aside className="flex flex-col border-r border-slate-200 bg-white">
        <div className="flex h-16 items-center border-b border-slate-100 px-6">
          <Link href="/dashboard" className="text-lg font-bold tracking-tight text-blue-600">
            COBLOX Admin
          </Link>
        </div>

        <nav className="flex-1 space-y-1 p-4" aria-label="Main Navigation">
          {navItems.map((item) => {
            const Icon = item.icon;
            return (
              <Link
                key={item.href}
                href={item.href}
                className="flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-100 hover:text-slate-900"
              >
                <Icon className="h-4 w-4" />
                {item.label}
              </Link>
            );
          })}
        </nav>

        <div className="border-t border-slate-100 p-4">
          <LogoutButton />
        </div>
      </aside>

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
