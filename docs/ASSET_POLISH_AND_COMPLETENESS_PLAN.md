> **[🏠 Master Index](MASTER_INDEX.md) | [⬅️ Back to Docs](README.md)**

# ✨ COBLOX Asset Polish & Completeness Implementation Plan

Dokumen ini menyusun rencana aksi **peningkatan kualitas visual (Polish)**, pengantian seluruh *placeholder* aset dengan aset produksi beresolusi tinggi, serta otomatisasi pengunggahan via **Roblox Open Cloud Assets API**.

---

## 🎨 1. Hasil Generasi Aset Visual Produksi Baru

Aset-aset berikut telah dibuat dan disiapkan untuk menggantikan *placeholder* `rbxassetid://PROCESSING`:

### A. Icon Material Alkimia (Pyro Crystal)
![Pyro Crystal Icon](/Users/mac/.gemini/antigravity-ide/brain/e0db8d2f-2409-4caf-bf21-38e10d33914c/coblox_pyro_crystal_icon_1785399800506.png)
*Item Material Alchemic Pyro Crystal dengan bezel logam futuristik dan efek pendar partikel.*

---

### B. Spirit Companion (Celestial Spirit Fox)
![Celestial Spirit Fox](/Users/mac/.gemini/antigravity-ide/brain/e0db8d2f-2409-4caf-bf21-38e10d33914c/coblox_spirit_fox_companion_1785399868653.png)
*Spirit Companion Fairytale dengan ekor bioluminescent cyan-purple dan aura magis 3D.*

### C. Material Alkimia (Aether Crystal)
![Aether Crystal Icon](/Users/mac/.gemini/antigravity-ide/brain/e0db8d2f-2409-4caf-bf21-38e10d33914c/coblox_aether_crystal_icon_1785401127587.png)
*Item Material Aether Crystal dengan bingkai perunggu alkimia dan prasasti sirkuit bercahaya violet-cyan.*

---

### D. Spirit Companion (Fairy Dragon)
![Fairy Dragon](/Users/mac/.gemini/antigravity-ide/brain/e0db8d2f-2409-4caf-bf21-38e10d33914c/coblox_fairy_dragon_companion_1785401143264.png)
*Spirit Companion Mythic Fairy Dragon dengan sayap bioluminescent emerald-cyan dan aksen zirah roda gigi.*

---

## 🏛️ 2. Pemetaan Penggantian Placeholder Aset (`src/Assets/`)

| Kategori Aset | Nama Aset | Status Sebelumnya | Aset Produksi / Action Plan |
| :--- | :--- | :--- | :--- |
| **Material Icon** | `PyroCrystalIcon` | `rbxassetid://PROCESSING` | Unggah `coblox_pyro_crystal_icon` via Open Cloud Assets API $\rightarrow$ perbarui `AssetManifestFairytale.luau` |
| **Material Icon** | `AetherCrystalMesh` | `rbxassetid://PROCESSING` | Unggah `coblox_aether_crystal_icon` via Open Cloud Assets API $\rightarrow$ perbarui `AssetManifestFairytale.luau` |
| **Spirit Companion** | `SpiritFoxMesh` | `rbxassetid://PROCESSING` | Unggah `coblox_spirit_fox_companion` via Open Cloud Assets API $\rightarrow$ perbarui `AssetManifestFairytale.luau` |
| **Spirit Companion** | `FairyDragon` | `rbxassetid://PROCESSING` | Unggah `coblox_fairy_dragon_companion` via Open Cloud Assets API $\rightarrow$ perbarui `AssetManifestFairytale.luau` |
| **Environment** | `SkyboxTwilight` | `rbxassetid://PROCESSING` | Integrasi PBR Skybox Texture Atlas dari Synty Asset Store |
| **Particles** | `TransmutationBurst` | `rbxassetid://124374758528939` | Ditinjau & diverifikasi ($\le 20$ particles/emitter) |

---

## 🛠️ 3. Rencana Otomatisasi Pengunggahan Aset via Open Cloud API

AI Agent akan menggunakan skrip `scripts/agent_cloud_ops.py` untuk mengunggah berkas gambar hasil generasi langsung ke Roblox Creator Cloud:

```bash
# Contoh Perintah Otomatisasi AI Agent
python3 scripts/agent_cloud_ops.py --upload-asset \
  --file brain/e0db8d2f-2409-4caf-bf21-38e10d33914c/coblox_pyro_crystal_icon_1785399800506.png \
  --type Decal \
  --name "PyroCrystalIcon_v1"
```

Setelah diunggah, `AssetID` yang dikembalikan Roblox Open Cloud akan **otomatis diinjeksikan oleh AI Agent ke dalam `src/Assets/AssetManifestFairytale.luau`**.

---

## 🎯 4. Target Kelengkapan Visibilitas Web Portal (`hycoblox.vercel.app`)

1. **Marketplace Item Cards:** Mengganti ikon kotak abu-abu di katalog Web Portal dengan gambar aset beresolusi tinggi di atas.
2. **Spirit Compendium Page:** Menampilkan galeri visual Spirit Companions 3D dengan kartu informasi statistik retensi.
