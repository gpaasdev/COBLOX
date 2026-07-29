"use client";
import { useState } from "react";
import { Save, RefreshCw, Globe, Bell, Shield, Palette } from "lucide-react";

export default function ConfigPage() {
  const [saved, setSaved] = useState(false);

  const handleSave = () => {
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  };

  return (
    <div className="flex flex-col gap-6 max-w-3xl">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">Setup & Configuration</h1>
          <p className="text-slate-500">Manage game settings, LiveOps, and feature flags.</p>
        </div>
        <button
          onClick={handleSave}
          className="inline-flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 transition-colors"
        >
          <Save className="h-4 w-4" />
          {saved ? "Saved!" : "Save Changes"}
        </button>
      </div>

      <div className="grid gap-6">
        <section className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-center gap-2 mb-4">
            <Globe className="h-5 w-5 text-blue-600" />
            <h2 className="text-lg font-semibold text-slate-900">Game Configuration</h2>
          </div>
          <div className="grid gap-4">
            <ConfigField label="Game Name" value="COBLOX: Multiverse Alchemy Sanctum" />
            <ConfigField label="Universe ID" value="10545905192" />
            <ConfigField label="Main Place ID" value="105075159736246" />
            <ConfigField label="Fairytale Place ID" value="89919608022831" />
            <ConfigField label="Current Version" value="v196" />
          </div>
        </section>

        <section className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-center gap-2 mb-4">
            <Bell className="h-5 w-5 text-amber-600" />
            <h2 className="text-lg font-semibold text-slate-900">LiveOps Settings</h2>
          </div>
          <div className="grid gap-4">
            <ToggleField label="Double XP Weekend" description="2x experience for all players" defaultChecked />
            <ToggleField label="Boosted Drop Rates" description="+50% rare drop chance" defaultChecked={false} />
            <ToggleField label="Maintenance Mode" description="Disable player joins" defaultChecked={false} />
            <ConfigField label="Active Event" value="Phase 1 Hardening Complete" />
          </div>
        </section>

        <section className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-center gap-2 mb-4">
            <Shield className="h-5 w-5 text-purple-600" />
            <h2 className="text-lg font-semibold text-slate-900">Security & Feature Flags</h2>
          </div>
          <div className="grid gap-4">
            <ToggleField label="Server Authoritative Economy" description="All transactions validated server-side" defaultChecked={true} disabled />
            <ToggleField label="ProfileStore Session Locking" description="Data persistence with session-locks" defaultChecked={true} disabled />
            <ToggleField label="Rate Limiting Active" description="Spam protection on all remotes" defaultChecked={true} disabled />
            <ToggleField label="MachineService (BOOT_FLAG)" description="BoundedTick experimental - OFF" defaultChecked={false} />
          </div>
        </section>

        <section className="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-center gap-2 mb-4">
            <Palette className="h-5 w-5 text-emerald-600" />
            <h2 className="text-lg font-semibold text-slate-900">Thumbnail Design Assets</h2>
          </div>
          <p className="text-sm text-slate-500 mb-4">Products requiring thumbnail images. See design system spec.</p>
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="border-b border-slate-200">
                <tr>
                  <th className="pb-2 font-medium text-slate-500">Product</th>
                  <th className="pb-2 font-medium text-slate-500">Type</th>
                  <th className="pb-2 font-medium text-slate-500">Image Status</th>
                  <th className="pb-2 font-medium text-slate-500">Design Spec</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                <ThumbnailRow product="Fairytale Realm Pass" type="GamePass" status="Missing" spec="Fantasy portal arch, twilight sky, 150x150" />
                <ThumbnailRow product="Celestial Wings Bundle" type="GamePass" status="Missing" spec="Aether wings on dark bg, 150x150" />
                <ThumbnailRow product="Coven Guildmaster" type="GamePass" status="Missing" spec="Guild crest, gold accents, 150x150" />
                <ThumbnailRow product="Fairy Dust Pack" type="DevProduct" status="Missing" spec="Sparkling dust particles, 150x150" />
                <ThumbnailRow product="Enchanted Elixir" type="DevProduct" status="Missing" spec="Glowing potion bottle, 150x150" />
                <ThumbnailRow product="Monthly Alchemist" type="Subscription" status="Missing" spec="Monthly badge with fox, 150x150" />
              </tbody>
            </table>
          </div>
        </section>
      </div>
    </div>
  );
}

function ConfigField({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center justify-between py-2 border-b border-slate-100 last:border-0">
      <span className="text-sm font-medium text-slate-700">{label}</span>
      <span className="text-sm text-slate-500 font-mono">{value}</span>
    </div>
  );
}

function ToggleField({ label, description, defaultChecked, disabled }: { label: string; description: string; defaultChecked: boolean; disabled?: boolean }) {
  const [checked, setChecked] = useState(defaultChecked);
  return (
    <div className="flex items-center justify-between py-2 border-b border-slate-100 last:border-0">
      <div>
        <span className="text-sm font-medium text-slate-700">{label}</span>
        <p className="text-xs text-slate-400">{description}</p>
      </div>
      <button
        onClick={() => !disabled && setChecked(!checked)}
        className={`relative h-6 w-11 rounded-full transition-colors ${checked ? 'bg-blue-600' : 'bg-slate-300'} ${disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'}`}
      >
        <span className={`absolute left-0.5 top-0.5 h-5 w-5 rounded-full bg-white shadow-sm transition-transform ${checked ? 'translate-x-5' : ''}`} />
      </button>
    </div>
  );
}

function ThumbnailRow({ product, type, status, spec }: { product: string; type: string; status: string; spec: string }) {
  return (
    <tr>
      <td className="py-2.5 text-sm text-slate-800">{product}</td>
      <td className="py-2.5 text-sm text-slate-500">{type}</td>
      <td className="py-2.5">
        <span className="inline-flex items-center rounded-full bg-amber-100 px-2.5 py-0.5 text-xs font-semibold text-amber-700">
          {status}
        </span>
      </td>
      <td className="py-2.5 text-sm text-slate-500 font-mono text-xs">{spec}</td>
    </tr>
  );
}
