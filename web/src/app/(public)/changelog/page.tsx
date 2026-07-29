import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Changelog & Pembaruan",
  description: "Catatan perubahan dan pembaruan COBLOX: Multiverse Alchemy Sanctum",
};

const changelogEntries = [
  {
    version: "v195",
    date: "29 Juli 2026",
    type: "patch",
    title: "Launch Readiness & Hardening",
    changes: [
      "Domain Expansion Controller — visual screen vignette & FOV effects live",
      "Potion Vault Controller — 6-slot vault display UI with live sync",
      "0 hardcoded strings remaining — full localization coverage",
      "15 services now show ServiceStatus in boot log",
      "Fixed TradeController execution pipeline",
      "Hotbar slot placeholders with 'Empty' label",
    ],
  },
  {
    version: "v194",
    date: "29 Juli 2026",
    type: "patch",
    title: "Localization Completion",
    changes: [
      "14 new localization keys across 2 languages",
      "Synthesis title & cooldown messages localized",
      "Coven hideout & invite buttons localized",
      "All 7 UIController notifications localized",
      "Fixed AdReward button stuck on error",
    ],
  },
  {
    version: "v190-v193",
    date: "29 Juli 2026",
    type: "patch",
    title: "Economy Security & Badge Creation",
    changes: [
      "P0 exploit fixes: RecipeService & ConsumableMutationService now validate inventory",
      "TradeService: full Lock/Confirm/Execute remote pipeline",
      "CombatService: server-side attack cooldown + weapon validation",
      "OfflineEarningsService: pro-rata calculation (no longer fixed 2h)",
      "5 badges created via Open Cloud API (free quota)",
      "8 Fairytale assets uploaded: 4 particles + 4 audio",
      "17 Fairytale meshes submitted for moderation",
    ],
  },
  {
    version: "v185-v189",
    date: "28 Juli 2026",
    type: "patch",
    title: "Discovery Fix & Cross-Realm Polish",
    changes: [
      "DiscoveryService nil-call crash fixed",
      "WeaponConfig type error fixed",
      "Leaderboard UI + data service enabled",
      "Crafting economy enabled (Alchemy/Reaction/Resource/Discovery)",
      "Teleport cross-realm MAIA\u2194FAIRYTALE via [R] key",
    ],
  },
  {
    version: "v174-v185",
    date: "28 Juli 2026",
    type: "feature",
    title: "Fairytale Realm & Combat Expansion",
    changes: [
      "Fairytale realm assembly with portal, hub, and biomes",
      "5-tier weapon progression (Fist \u2192 Void Greatsword)",
      "9 mob spawn zones with 5 unique enemy types",
      "8 mineable Mana Crystal nodes",
      "Weapon shop UI with stat displays",
      "Cooldown and validation on all combat remotes",
    ],
  },
  {
    version: "v169-v174",
    date: "27 Juli 2026",
    type: "feature",
    title: "Production Hardening Phase 1",
    changes: [
      "All service nil-safety guards (NetChannels, remotes, attributes)",
      "Localization merged (COVEN_, CODEX_, TRADE_, FTUE_ keys)",
      "Stub\u2192Production: SocialSimulation, Political, MacroEconomy services",
      "Realm icons, portal fixes, wallet auto-creation",
    ],
  },
  {
    version: "v11.0",
    date: "24 Juli 2026",
    type: "major",
    title: "LGBOS v11.0 Launch",
    changes: [
      "57 services architecture with tiered boot sequence",
      "Zero-Trust SOA pattern across all systems",
      "ProfileStore v3 session-locked persistence",
      "Multi-currency economy with quantum vault",
      "3x3 grid crafting with elemental reactions",
      "Monetization: 5 GamePasses + 6 DevProducts",
      "Pet system with hatching, fusion, and awakening",
    ],
  },
];

export default function ChangelogPage() {
  return (
    <div className="max-w-3xl mx-auto px-4 py-16">
      <h1 className="text-4xl font-bold mb-4">Changelog</h1>
      <p className="text-slate-400 mb-8">
        Catatan perubahan dan pembaruan COBLOX: Multiverse Alchemy Sanctum
      </p>

      <div className="space-y-8">
        {changelogEntries.map((entry) => (
          <div
            key={entry.version}
            className="border border-slate-800 rounded-xl p-6 bg-slate-900/50"
          >
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-3">
                <span
                  className={`px-2.5 py-0.5 rounded-full text-xs font-bold ${
                    entry.type === "major"
                      ? "bg-emerald-500/20 text-emerald-300"
                      : entry.type === "feature"
                      ? "bg-cyan-500/20 text-cyan-300"
                      : "bg-slate-600/30 text-slate-300"
                  }`}
                >
                  {entry.version}
                </span>
                <span className="text-slate-500 text-sm">{entry.date}</span>
              </div>
              <span
                className={`px-2 py-0.5 rounded text-xs uppercase ${
                  entry.type === "major"
                    ? "bg-emerald-500/10 text-emerald-400"
                    : entry.type === "feature"
                    ? "bg-cyan-500/10 text-cyan-400"
                    : "bg-slate-600/20 text-slate-400"
                }`}
              >
                {entry.type}
              </span>
            </div>
            <h2 className="text-lg font-semibold text-white mb-3">{entry.title}</h2>
            <ul className="space-y-1.5">
              {entry.changes.map((change, i) => (
                <li key={i} className="flex items-start gap-2 text-slate-300 text-sm">
                  <span className="text-emerald-500 mt-1 shrink-0">▸</span>
                  <span>{change}</span>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </div>

      <div className="mt-12 pt-8 border-t border-slate-800 text-center">
        <Link href="/" className="text-emerald-400 hover:underline">
          ← Kembali ke Beranda
        </Link>
      </div>
    </div>
  );
}
