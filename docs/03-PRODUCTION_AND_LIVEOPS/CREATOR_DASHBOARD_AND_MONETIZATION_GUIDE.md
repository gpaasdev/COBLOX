> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# PANDUAN LENGKAP PENGATURAN ROBLOX CREATOR DASHBOARD & MONETISASI PRODUCTION

**Proyek:** COBLOX: Multiverse Alchemy Sanctum 🧪⚡  
**Versi Dokumen:** 1.0.0 (Production Release Guide)  
**Referensi Utama:** [Roblox Creator Documentation](https://create.roblox.com/docs), [DevForum Game Development Guide](https://devforum.roblox.com/t/the-beginners-guide-to-all-things-game-development/1121665/2), [Roblox Open Cloud API Specs](https://create.roblox.com/docs/open-cloud)

---

## 1. PETA OTOMATISASI: OPEN CLOUD API VS CREATOR DASHBOARD MANUAL

Sebelum melakukan pengaturan, pahami pembagian antara apa yang bisa diotomatisasi melalui skrip **Open Cloud API** dan apa yang wajib dikonfigurasi **manual via Web (Creator Dashboard)**:

| Komponen / Fitur | Metode Eksekusi | Status di COBLOX | Catatan Penjelasan |
| :--- | :---: | :---: | :--- |
| **Codebase & Place Build (`.rbxl`)** | ⚡ **Otomatis** (Open Cloud) | 🟢 Published (v68) | Diunggah via `scripts/deploy_opencloud.py` |
| **Aset Ikon Game & Thumbnail** | ⚡ **Otomatis** (Open Cloud) | 🟢 Uploaded | Diunggah via `tools/upload_experience_assets.py` |
| **Aset Ikon GamePass** | ⚡ **Otomatis** (Open Cloud) | 🟢 Uploaded | Diunggah via `tools/upload_experience_assets.py` |
| **Nama & Deskripsi Game (Metadata)** | 🖐️ **Manual Web** | 🟡 Harus di-Save | Form Web memerlukan klik "Simpan Perubahan" |
| **Izin Tempat & Copying (Permissions)** | 🖐️ **Manual Web** | 🟢 Terverifikasi | Matikan `Place Copying` & `In-game APIs` |
| **Developer Products (Robux)** | 🖐️ **Manual Web** | 🟢 Terintegrasi Kode | Buat ID di Web & masukkan ke `MonetizationService.luau` |
| **Game Passes (Robux)** | 🖐️ **Manual Web** | 🟢 Terintegrasi Kode | Buat ID di Web & masukkan ke `MonetizationService.luau` |
| **Share Links & LaunchData** | 🖐️ **Manual Web** | 🟢 Active | Dikelola via `LaunchDataService.luau` (`https://www.roblox.com/join/qkced`) |
| **Kuesioner Pedoman Usia (Age Rating)** | 🖐️ **Manual Web** | 🟡 Akses via Web | Isi kuesioner kelayakan umur pemain |
| **DataStore & MemoryStore** | ⚡ **Otomatis** (Engine API) | 🟢 Active | Dikelola runtime via ProfileStore v3 |

---

## 2. PANDUAN PENGATURAN MANUALL CREATOR DASHBOARD (STEP-BY-STEP)

Buka halaman pengelola pengalaman Roblox Anda di browser:  
`https://create.roblox.com/dashboard/creations/experiences/10545905192/configure`

---

### A. Menu Konfigurasi -> Pengaturan Dasar (Basic Settings)

1. **Judul Pengalaman (Title):**
   ```text
   COBLOX: Multiverse Alchemy Sanctum 🧪⚡
   ```
2. **Deskripsi Pengalaman (Description):**
   ```text
   🧪 Selamat Datang di COBLOX: Multiverse Alchemy Sanctum!

   ✨ Tambang Kristal Mana, racik ramuan elemen legendaris, ciptakan Spirit Cybernetic, dan bangun Markas Alkimia impianmu!

   🌟 FITUR GAME UTAMA:
   • 🔮 Bejana Racik Alkimia 3x3 (Crafting & Transmutation)
   • ⚡ Fisika Interaktif: Angkat, Seret & Lempar Objek Fisik (0 Lag)
   • 🐾 Pet Spirit Cybernetic Hatching & Sistem Fusion
   • 🏆 50-Tier Seasonal Sanctum Battlepass & Daily Quests
   • 🛡️ Ekspedisi Guild, Shadow Raid & Mode PVP Zero-Trust

   🎁 Bergabunglah dengan Group Resmi kami untuk mendapatkan +10% Boost Aura Energy!
   ⭐ ROBLOX PREMIUM BENEFITS: Pemain Premium mendapatkan +20% Aura Energy Boost & 1.2x Luck Multiplier otomatis!
   👍 Tekan Like & Favorite untuk mendukung event update mingguan!
   ```
3. **Genre & Kategori:** `RPG / Simulator / Fantasy`
4. **Fitur Mesh/Gambar Dinamis (jika ada):** Centang `EditableMesh` & `EditableImage` API.
5. **Klik:** **[Simpan Perubahan]**

---

### B. Menu Konfigurasi -> Tempat -> Izin (Permissions)

Navigasi: `Tempat` -> `COBLOX: Multiverse Alchemy Sanctum` -> `Izin`

1. **Penyalinan Tempat (Place Copying):**
   - ❌ **Hilangkan Centang** `Izinkan pengguna men-download salinan Tempat ini`.
   - *Alasan:* Mencegah pencurian *source code* dan aset 3D game Anda.
2. **Dalam Game (In-Game APIs):**
   - ❌ **Hilangkan Centang** `Mengizinkan tempat disalin sebagai templat...`
   - ❌ **Hilangkan Centang** `Izinkan tempat diperbarui menggunakan Save Place API...`
   - *Alasan:* COBLOX menggunakan `ProfileStore` berbasis DataStore standar. Mengunci API tempat ini mencegah eksekusi skrip jahat yang mencoba menimpa struktur tempat.
3. **Pengaturan Perlengkapan (Gear Settings):**
   - Pilih `Hanya izinkan perlengkapan dari genre pengalaman virtual` atau nonaktifkan semua Gear.
   - *Alasan:* Mencegah pemain membawa item Gear bawaan Roblox yang berpotensi merusak keseimbangan permainan (Exploit/Combat imbalance).
4. **Klik:** **[Simpan Perubahan]**

---

### C. Menu Monetisasi -> Produk Developer & Pas (Monetization)

Untuk mengaktifkan monetisasi di dalam game, buat produk berikut di dashboard Roblox dan catat **Product ID / Pass ID** yang dihasilkan untuk dihubungkan ke kode server.

#### 1. Pas Pengalaman (Game Passes)
Navigasi: `Monetisasi` -> `Pas` -> `Buat Pas`

| Nama GamePass | Harga (Robux) | Aset Gambar (di `docs/ASSETS/`) | Manfaat Gameplay di Kode (`MonetizationService.luau`) |
| :--- | :---: | :--- | :--- |
| **VIP Sanctum Membership** | 499 R$ | `pass_vip.png` | +50% Mana Cap, Tag Chat [VIP], Multiplier Aura x1.5 |
| **Super Luck Elixir** | 299 R$ | `pass_super_luck.png` | +25% Probabilitas Alkimia Rasi Bintang Legendaris |
| **Auto-Hatch Alchemy** | 199 R$ | `pass_auto_hatch.png` | Membuka fitur penetasan Pet otomatis |
| **Extra Inventory (+100)** | 149 R$ | `pass_extra_inventory.png` | Menggandakan kapasitas tas penyimpanan dari 50 ke 150 slot |
| **Free Neon Trail** | 99 R$ | `pass_vip.png` (atau kostum) | Efek jejak cahaya Neon Eksklusif pada karakter |

#### 2. Produk Developer (Developer Products)
Navigasi: `Monetisasi` -> `Produk Developer` -> `Buat Produk`

| Nama Produk | Harga (Robux) | Hadiah / Benefit Langsung di Game |
| :--- | :---: | :--- |
| **Pack 1,000 Coins** | 15 R$ | +1,000 Gold Coins langsung ke dompet |
| **Pack 10,000 Coins** | 99 R$ | +10,000 Gold Coins langsung ke dompet |
| **Pack 100 Gems** | 25 R$ | +100 Premium Gems |
| **Pack 1,000 Gems** | 199 R$ | +1,000 Premium Gems |
| **Medium Aura Energy Boost (1 Jam)** | 49 R$ | Boost Pengisian Mana +100% selama 60 menit |
| **Chrono-Sparks Pack x5** | 79 R$ | Instantly skip waktu racik Alkimia 5 kali |
| **Rebirth Skip Token** | 299 R$ | Langsung naik level Rebirth tanpa reset stats |

---

## 3. MENSHINKRONISASIKAN PRODUCT ID KE CODEBASE

Setelah membuat GamePass & DevProducts di Creator Dashboard, buka file kode berikut di proyek Anda:

`file:///Users/mac/.gemini/antigravity-ide/scratch/COBLOX/src/Server/Services/MonetizationService.luau`

Perbarui tabel konfigurasinya sesuai ID numerik yang diberikan oleh Roblox:

```lua
-- src/Server/Services/MonetizationService.luau
MonetizationService.Products = {
    [1000000001] = { Name = "Coins_1000", Coins = 1000 },
    [1000000002] = { Name = "Coins_10000", Coins = 10000 },
    [1000000003] = { Name = "Gems_100", Gems = 100 },
    [1000000004] = { Name = "Gems_1000", Gems = 1000 },
    [1000000005] = { Name = "AuraBoost_Medium", Duration = 3600 },
    [1000000006] = { Name = "ChronoSparks_Pack", Sparks = 5 },
    [1000000007] = { Name = "RebirthSkip_Token", GrantsRebirth = true },
}

MonetizationService.GamePasses = {
    [2000000001] = { Name = "VIP", Multiplier = 1.5, Perks = {"VIP_ChatTag", "ManaCap_Boost"} },
    [2000000002] = { Name = "SuperLuck", LuckBonus = 0.25 },
    [2000000003] = { Name = "ExtraInventory", AddedSlots = 100 },
    [2000000004] = { Name = "AutoHatch", EnableAutoHatch = true },
    [2000000005] = { Name = "NeonTrail", TrailAssetId = "rbxassetid://1784885776946" },
}
```

---

## 4. SKRIP OTOMATISASI TERSEDIA DI COBLOX

Proyek ini telah dilengkapi dengan skrip pembantu di folder `scripts/` dan `tools/`:

1. **Deploy Build Ke Roblox Cloud:**
   ```bash
   python3 scripts/deploy_opencloud.py
   ```
   *Fungsi:* Mengompilasi kode Luau terbaru dengan `rojo build` dan mempublikasikan versi tempat terbaru langsung ke Roblox Cloud.

2. **Upload Aset Ikon & Banner (Open Cloud Asset API):**
   ```bash
   python3 tools/upload_experience_assets.py
   ```
   *Fungsi:* Membaca gambar beresolusi tinggi di `docs/ASSETS/` (`game_icon.png`, `game_thumbnail.png`, `pass_*.png`) dan mengunggahnya ke server Roblox secara terprogram.

---

## 5. DOKUMEN CHECKLIST RELEASE AKHIR

Sebelum mempublikasikan game ke **PUBLIC** (Dapat Dimainkan Semua Orang):

- [x] **DataStore Readiness:** Test health check `PlayerDataService.luau` berjalan lancar di server live.
- [x] **Zero-Trust Security:** Jarak interaksi fisik ($\le 15$ studs) dan sanitasi Server-Authoritative aktif.
- [x] **Visual Polish:** UI Dark Glassmorphism, filter proksimitas Tycoon (max 2 UI aktif), dan responsivitas Mobile terverifikasi.
- [ ] **Manual Save Check:** Tombol *Simpan Perubahan* pada Metadata dan Permissions di Creator Dashboard sudah diklik.
- [ ] **Ubah Status Akses:** Navigasi ke `Pengaturan Akses` (Access Settings) -> Ubah dari `Private` ke `Public`.

---
*Dokumen ini merupakan pedoman operasional resmi untuk tim pengembangan COBLOX (LGBOS v11.0).*
