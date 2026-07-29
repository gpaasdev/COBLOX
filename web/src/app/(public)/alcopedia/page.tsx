import React from "react";
import MATERIALS_DATA from "@/data/registry/materials.json";
import RECIPES_DATA from "@/data/registry/recipes.json";
import MACHINES_DATA from "@/data/registry/machines.json";
import REACTIONS_DATA from "@/data/registry/reactions.json";
import SPIRITS_DATA from "@/data/registry/spirits.json";

function tierColor(tier: string) {
  const colors: Record<string, string> = {
    Common: "text-slate-300 bg-slate-700",
    Uncommon: "text-green-300 bg-green-900",
    Rare: "text-blue-300 bg-blue-900",
    Epic: "text-purple-300 bg-purple-900",
    Legendary: "text-orange-300 bg-orange-900",
    Mythic: "text-red-300 bg-red-900",
  };
  return colors[tier] || "text-slate-300 bg-slate-700";
}

function getTier(value: number): string {
  if (value < 100) return "Common";
  if (value < 500) return "Uncommon";
  if (value < 1000) return "Rare";
  if (value < 1500) return "Epic";
  if (value < 2000) return "Legendary";
  return "Mythic";
}

function getRecipesForMaterial(matName: string) {
  return RECIPES_DATA.filter((r: any) => r.Ingredients.includes(matName));
}

function getRecipesProducing(matName: string) {
  return RECIPES_DATA.filter((r: any) => r.Name.includes(matName) || r.OutputType === "Material");
}

const materialTiers = ["Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"];
const tieredMaterials: Record<string, any[]> = {};
for (const t of materialTiers) tieredMaterials[t] = [];
for (const m of MATERIALS_DATA) {
  const t = getTier(m.Value);
  tieredMaterials[t].push(m);
}

const outputCategories = [...new Set(RECIPES_DATA.map((r: any) => r.OutputType))].sort();

export default function AlcopediaPage() {
  return (
    <div className="max-w-6xl mx-auto px-6 py-16 flex-grow w-full space-y-20">
      {/* Hero */}
      <section className="text-center">
        <h1 className="text-5xl font-black text-emerald-400 mb-4">🜁 Alcopedia</h1>
        <p className="text-xl text-slate-300 max-w-2xl mx-auto">
          Panduan lengkap alkimia Multiverse Sanctum — dari bijih besi hingga singularitas adamantit.
        </p>
      </section>

      {/* 1. Cara Kerja Crafting */}
      <section className="bg-slate-900 border border-white/10 rounded-3xl p-8">
        <h2 className="text-3xl font-bold text-white mb-6">⚗️ Cara Kerja Lab Racik</h2>
        <div className="grid md:grid-cols-2 gap-8">
          <div className="space-y-4">
            <h3 className="text-xl font-semibold text-emerald-400">Grid 3×3</h3>
            <p className="text-slate-300 leading-relaxed">
              Buka menu <strong>Lab Racik</strong> dari samping atau tekan tombol <strong>🌱 ELEMEN</strong>.
              Kamu akan melihat grid 3×3 dan palet material di bawahnya.
            </p>
            <ol className="list-decimal list-inside space-y-2 text-slate-300">
              <li>Pilih material dari palet (klik untuk memilih)</li>
              <li>Klik slot grid untuk menempatkan material</li>
              <li>Klik slot yang terisi untuk mengeluarkannya kembali</li>
              <li>Tekan <strong>⚡ RACIK SEKARANG!</strong> untuk memproses</li>
            </ol>
            <div className="bg-slate-800 rounded-xl p-4 mt-4">
              <p className="text-yellow-300 font-semibold mb-2">💡 Tips Dasar</p>
              <ul className="space-y-1 text-sm text-slate-300">
                <li>Mulai dengan <strong>Quartz</strong> — paling mudah didapat</li>
                <li>3 Quartz → QuartzAltar_Tier1 (struktur markas)</li>
                <li>3 AstralIron → AstralGenerator_Tier2 (pembangkit listrik)</li>
                <li>2 PyroEssence → PyroBuffPotion_Tier2 (buff sementara)</li>
                <li>Water Element + Fire Element → reaksi uap (multiplier 2.5×)</li>
              </ul>
            </div>
          </div>
          <div className="space-y-4">
            <h3 className="text-xl font-semibold text-emerald-400">Reaksi Elemen</h3>
            <p className="text-slate-300 leading-relaxed">
              Saat dua elemen berbeda digabung di grid, reaksi elemental terjadi dan melipatgandakan hasil:
            </p>
            <div className="space-y-2">
              <div className="bg-slate-800 rounded-lg p-3">
                <span className="text-red-400 font-bold">Pyro</span> + <span className="text-blue-400 font-bold">Hydro</span>
                <span className="text-slate-400 ml-2">→ Vaporize (2.5× multiplier)</span>
              </div>
              <div className="bg-slate-800 rounded-lg p-3">
                <span className="text-red-400 font-bold">Pyro</span> + <span className="text-cyan-300 font-bold">Cryo</span>
                <span className="text-slate-400 ml-2">→ Melt (2.0× multiplier)</span>
              </div>
              <div className="bg-slate-800 rounded-lg p-3">
                <span className="text-yellow-400 font-bold">Electro</span> + <span className="text-blue-400 font-bold">Hydro</span>
                <span className="text-slate-400 ml-2">→ Electro-Charged (1.8× multiplier)</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 2. Hierarki Material */}
      <section className="bg-slate-900 border border-white/10 rounded-3xl p-8">
        <h2 className="text-3xl font-bold text-white mb-6">📊 Hierarki Material</h2>
        <p className="text-slate-300 mb-8">
          Material diurutkan berdasarkan <strong>Value</strong> (semakin tinggi, semakin langka dan kuat).
          Material Common adalah bahan baku mentah, Mythic adalah material paling langka.
        </p>
        <div className="grid md:grid-cols-3 lg:grid-cols-6 gap-4">
          {materialTiers.map((tier) => (
            <div key={tier} className="bg-slate-800/50 rounded-xl p-4">
              <h3 className={`font-bold text-sm mb-3 ${tierColor(tier).split(" ")[0]}`}>{tier}</h3>
              <div className="space-y-1">
                {tieredMaterials[tier].slice(0, 5).map((m: any) => (
                  <div key={m.Id} className="text-xs text-slate-400 truncate" title={m.Name}>
                    {m.Name}
                  </div>
                ))}
                {tieredMaterials[tier].length > 5 && (
                  <div className="text-xs text-slate-500">+{tieredMaterials[tier].length - 5} lainnya</div>
                )}
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* 3. Resep berdasarkan Kategori Output */}
      <section className="bg-slate-900 border border-white/10 rounded-3xl p-8">
        <h2 className="text-3xl font-bold text-white mb-6">📜 Resep berdasarkan Kegunaan</h2>
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {outputCategories.map((cat) => {
            const catRecipes = RECIPES_DATA.filter((r: any) => r.OutputType === cat);
            if (catRecipes.length === 0) return null;
            return (
              <div key={cat} className="bg-slate-800/50 rounded-xl p-5">
                <h3 className="font-bold text-emerald-400 mb-3">{cat} ({catRecipes.length})</h3>
                <ul className="space-y-2">
                  {catRecipes.slice(0, 4).map((r: any) => (
                    <li key={r.Id} className="text-xs text-slate-300">
                      <span className="text-white font-medium">{r.Name}</span>
                      <br />
                      <span className="text-slate-500">{r.Ingredients.join(" + ")}</span>
                    </li>
                  ))}
                  {catRecipes.length > 4 && (
                    <li className="text-xs text-slate-500">+{catRecipes.length - 4} lagi</li>
                  )}
                </ul>
              </div>
            );
          })}
        </div>
      </section>

      {/* 4. Reaksi Kimia */}
      <section className="bg-slate-900 border border-white/10 rounded-3xl p-8">
        <h2 className="text-3xl font-bold text-white mb-6">🧪 Reaksi Kimia & Fisika</h2>
        <p className="text-slate-300 mb-6">
          Reaksi kimia terjadi di dalam mesin (Smelter, Refinery, Synthesizer) pada suhu dan tekanan tertentu.
          Setiap reaksi mengubah material input menjadi produk baru dengan yield tertentu.
        </p>
        {REACTIONS_DATA.length === 0 ? (
          <p className="text-slate-500 italic">Belum ada reaksi yang terdokumentasi.</p>
        ) : (
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {REACTIONS_DATA.map((rxn: any) => (
              <div key={rxn.Id} className="bg-slate-800/50 rounded-xl p-5 border border-slate-700">
                <h3 className="font-bold text-white mb-2">{rxn.Name}</h3>
                <div className="text-sm space-y-1 text-slate-300">
                  <p>Input: {Object.entries(rxn.RequiredMaterials).map(([k, v]) => `${v}× ${k}`).join(", ")}</p>
                  <p>Produk: <span className="text-emerald-400">{rxn.Product}</span></p>
                  <p>Suhu: {rxn.MinTemperature}–{rxn.MaxTemperature}K</p>
                  <p>Tekanan min: {rxn.MinPressure} atm</p>
                  <p>Energi: {rxn.EnergyRequired} AE | Entropi: {rxn.EntropyGenerated}</p>
                  {rxn.Catalyst && <p>Katalis: {rxn.Catalyst}</p>}
                </div>
              </div>
            ))}
          </div>
        )}
      </section>

      {/* 5. Mesin */}
      <section className="bg-slate-900 border border-white/10 rounded-3xl p-8">
        <h2 className="text-3xl font-bold text-white mb-6">⚙️ Mesin & Progresi</h2>
        <p className="text-slate-300 mb-6">
          6 tipe mesin, masing-masing dengan 10 tingkat (Mark 1–10). Semakin tinggi mark, semakin besar daya
          dan suhu maksimal yang bisa dicapai.
        </p>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-slate-400 border-b border-slate-700">
                <th className="text-left py-2">Tipe</th>
                <th className="text-right py-2">Daya (Mark 1→10)</th>
                <th className="text-right py-2">Suhu Maks (Mark 1→10)</th>
                <th className="text-left py-2">Fungsi</th>
              </tr>
            </thead>
            <tbody>
              {[
                { id: "Smelter", desc: "Melebur bijih menjadi refined metal", icon: "🔥" },
                { id: "Refinery", desc: "Memurnikan material dengan tekanan tinggi", icon: "💧" },
                { id: "Synthesizer", desc: "Mensintesis material baru dari kombinasi", icon: "⚡" },
                { id: "Reactor", desc: "Reaksi suhu tinggi untuk material langka", icon: "☢️" },
                { id: "Turbine", desc: "Menghasilkan energi dari panas berlebih", icon: "💨" },
                { id: "Cooler", desc: "Pendingin untuk reaksi suhu rendah", icon: "❄️" },
              ].map((type) => {
                const v1 = MACHINES_DATA.find((m: any) => m.Id.startsWith(type.id) && m.Id.endsWith("_v1"));
                const v10 = MACHINES_DATA.find((m: any) => m.Id.startsWith(type.id) && m.Id.endsWith("_v10"));
                return (
                  <tr key={type.id} className="border-b border-slate-800">
                    <td className="py-3 text-white font-medium">{type.icon} {type.id}</td>
                    <td className="py-3 text-right text-slate-300">
                      {v1?.PowerConsumption ?? "?"}W → {v10?.PowerConsumption ?? "?"}W
                    </td>
                    <td className="py-3 text-right text-slate-300">
                      {v1?.MaxTemperature ?? "?"}°C → {v10?.MaxTemperature ?? "?"}°C
                    </td>
                    <td className="py-3 text-slate-400">{type.desc}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </section>

      {/* 6. Spirit & Hatching */}
      <section className="bg-slate-900 border border-white/10 rounded-3xl p-8">
        <h2 className="text-3xl font-bold text-white mb-6">🐉 Spirit & Penetasan</h2>
        <p className="text-slate-300 mb-6">
          Koleksi 40 Spirit dalam 5 tingkat kelangkaan. Semakin langka, semakin kecil drop rate-nya.
          Gunakan <strong>Katalis Elemen</strong> untuk meningkatkan peluang mendapatkan spirit elemen tertentu.
        </p>
        <div className="grid md:grid-cols-5 gap-4 mb-8">
          {[
            { rarity: "Common", count: 11, color: "text-slate-300", bg: "bg-slate-700" },
            { rarity: "Uncommon", count: 10, color: "text-green-300", bg: "bg-green-900" },
            { rarity: "Rare", count: 8, color: "text-blue-300", bg: "bg-blue-900" },
            { rarity: "Epic", count: 7, color: "text-purple-300", bg: "bg-purple-900" },
            { rarity: "Legendary", count: 4, color: "text-orange-300", bg: "bg-orange-900" },
          ].map((r) => (
            <div key={r.rarity} className={`${r.bg} rounded-xl p-4 text-center`}>
              <div className={`text-2xl font-black ${r.color}`}>{r.rarity}</div>
              <div className="text-3xl font-bold text-white mt-1">{r.count}</div>
              <div className="text-xs text-slate-400">spirit</div>
            </div>
          ))}
        </div>
        <div className="bg-slate-800 rounded-xl p-6">
          <h3 className="font-bold text-emerald-400 mb-3">🧪 Katalis Elemen</h3>
          <p className="text-sm text-slate-300 mb-3">
            Gunakan katalis untuk meningkatkan peluang mendapat spirit elemen tertentu:
          </p>
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-3 text-sm">
            {[
              { cat: "Fire Spirit Catalyst", ele: "🔥 Fire", ingredients: "Obsidian_Ore + Gold_Shard + Aether_Vapor" },
              { cat: "Water Spirit Catalyst", ele: "💧 Water", ingredients: "Aether_Crystal + Copper_Refined + Iron_Vapor" },
              { cat: "Earth Spirit Catalyst", ele: "🌍 Earth", ingredients: "Iron_Crystal + Copper_Crystal + Obsidian_Dust" },
              { cat: "Lightning Spirit Catalyst", ele: "⚡ Lightning", ingredients: "Copper_Alloy + Gold_Alloy + Aether_Shard" },
              { cat: "Void Spirit Catalyst", ele: "🌑 Void", ingredients: "Obsidian_Singularity + Aether_Matrix + Adamantite_Essence" },
            ].map((c) => (
              <div key={c.cat} className="bg-slate-700/50 rounded-lg p-3">
                <div className="font-medium text-white">{c.ele}</div>
                <div className="text-xs text-slate-400">{c.cat}</div>
                <div className="text-xs text-slate-500 mt-1">{c.ingredients}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* 7. Markas & Bejana */}
      <section className="bg-slate-900 border border-white/10 rounded-3xl p-8">
        <h2 className="text-3xl font-bold text-white mb-6">🏠 Markas & Bejana Aura</h2>
        <div className="grid md:grid-cols-2 gap-8">
          <div className="space-y-4">
            <h3 className="text-xl font-semibold text-emerald-400">🏰 Markas (Sanctum Grid)</h3>
            <p className="text-slate-300 leading-relaxed">
              Setiap pemain memiliki plot pribadi. Klaim dengan menyentuh <strong>ClaimPad</strong> di plot yang tersedia.
              Setelah diklaim, kamu bisa:
            </p>
            <ul className="list-disc list-inside space-y-1 text-slate-300">
              <li>Memasang struktur (dropper, obelisk, lab racik, dll.)</li>
              <li>Membangun blok dekorasi (batu, marmer, kaca, neon, kristal)</li>
              <li>Menempatkan mesin untuk otomatisasi</li>
              <li>Mengundang teman ke markas</li>
            </ul>
          </div>
          <div className="space-y-4">
            <h3 className="text-xl font-semibold text-emerald-400">⚡ Bejana Aura</h3>
            <p className="text-slate-300 leading-relaxed">
              Bejana Aura adalah vault penyimpan energi yang menghasilkan bunga majemuk 5% per hari
              (maks 30 hari). Cara kerja:
            </p>
            <ol className="list-decimal list-inside space-y-1 text-slate-300">
              <li>Deposit Aura Energy ke bejana</li>
              <li>Bunga 5% dihitung setiap hari</li>
              <li>Maksimal akumulasi 30 hari (150% dari deposit)</li>
              <li>Klaim kapan saja untuk mengambil hasil + deposit</li>
            </ol>
          </div>
        </div>
      </section>

      {/* 8. Mobile Controls */}
      <section className="bg-slate-900 border border-white/10 rounded-3xl p-8">
        <h2 className="text-3xl font-bold text-white mb-6">📱 Kontrol Mobile & PC</h2>
        <div className="grid md:grid-cols-2 gap-8">
          <div className="space-y-4">
            <h3 className="text-xl font-semibold text-emerald-400">🖥️ PC / Keyboard</h3>
            <div className="grid grid-cols-2 gap-2 text-sm">
              {[
                { key: "Klik Kiri", action: "Serang / Konfirmasi" },
                { key: "F", action: "Tangkis (Parry)" },
                { key: "Q", action: "Dash" },
                { key: "X", action: "Ganti Senjata" },
                { key: "R", action: "Pilih Realm" },
                { key: "B", action: "Mode Bangun" },
                { key: "C", action: "Minum Ramuan" },
                { key: "G", action: "Flex Shrine" },
                { key: "E", action: "Interaksi (ProximityPrompt)" },
              ].map((ctrl) => (
                <div key={ctrl.key} className="bg-slate-800 rounded-lg p-2 flex justify-between">
                  <span className="font-mono text-emerald-400">{ctrl.key}</span>
                  <span className="text-slate-300">{ctrl.action}</span>
                </div>
              ))}
            </div>
          </div>
          <div className="space-y-4">
            <h3 className="text-xl font-semibold text-emerald-400">📱 Mobile / Touch</h3>
            <div className="grid grid-cols-2 gap-2 text-sm">
              {[
                { btn: "🗡️ (kanan bawah)", action: "Serang" },
                { btn: "🛡️ (kanan tengah)", action: "Tangkis" },
                { btn: "⚡ (kiri bawah)", action: "Dash" },
                { btn: "🔪 (kiri tengah)", action: "Ganti Senjata" },
                { btn: "🌍 (kiri atas)", action: "Pilih Realm" },
                { btn: "☰ (atas kiri)", action: "Menu Navigasi" },
              ].map((ctrl) => (
                <div key={ctrl.btn} className="bg-slate-800 rounded-lg p-2">
                  <div className="text-emerald-400 text-xs">{ctrl.btn}</div>
                  <div className="text-slate-300 text-xs">{ctrl.action}</div>
                </div>
              ))}
            </div>
            <div className="bg-slate-800 rounded-xl p-4 mt-2">
              <p className="text-yellow-300 text-sm font-semibold mb-1">💡 Tips Mobile</p>
              <p className="text-xs text-slate-300">
                Tombol aksi otomatis muncul di layar saat kamu memulai game di perangkat mobile.
                Posisi tombol sudah diatur agar tidak tumpang tindih.
                Ketuk label realm (bawah tengah) untuk pilih realm tanpa keyboard.
              </p>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
