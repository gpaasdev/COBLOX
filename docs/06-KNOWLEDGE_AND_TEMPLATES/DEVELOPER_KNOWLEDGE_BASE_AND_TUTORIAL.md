> **[🏠 Master Index](../MASTER_INDEX.md) | [⬅️ Back to Docs](../README.md)**

# COBLOX LGBOS v11.0 — Developer Knowledge Base & Engineering Manual

**Versi**: LGBOS v11.0 Commercial Live Service  
**Target Pembaca**: Lead Engineers, Game Developers, & System Architects  
**Bahasa**: Bahasa Indonesia  

---

## 1. Arsitektur Utama & Prinsip Desain

COBLOX dibangun menggunakan arsitektur **Domain-Driven Design (DDD)**, **Zero-Trust Server Authority**, dan **Event-Driven Pub/Sub Pattern**.

### Core Engineering Rules:
1. **`--!strict` Typing**: 100% file `.luau` wajib mencantumkan `--!strict` di baris pertama.
2. **Zero-Trust Security**: Seluruh RemoteEvent (Placement, Steal, Combat, Crafting, Trade, Coven, Laundering, Reclaim) diverifikasi di server dengan jarak $\le 15$ studs dan pengecekan RateLimit via `RateLimitService.luau`.
3. **Data Persistence**: Disimpan via `ProfileStore v3` dan diakses melalui `PlayerDataService.luau` & `ProfileStoreAdapter.luau`.
4. **Monetization Guarantee**: `MarketplaceService.ProcessReceipt` hanya mengembalikan `PurchaseGranted` setelah `PlayerDataService.SavePlayerProfile` dipicu secara aman.
5. **Open Cloud Integration**: Proyek terhubung dengan Roblox Open Cloud API untuk build otomatis, live messaging, dan manajemen DataStore dari luar Studio.

### 🧪 Casual Anime & Gen Z Hype Core Services (GDD Synchronized):
- **`CrystalPurificationService.luau`**: Akumulasi energi Bejana Markas, sinyal suar neon, dan aksi **🚚 Setor Aura** di Obelisk Pusat.
- **`ConsumableMutationService.luau` & `MutationController.luau`**: Pengelolaan racikan **⚡ Overclock Mode** (Speed 45 & Screen Shake) dan **Mode Raksasa** (Scale 2.5x & MaxHealth 500).
- **`CleansingQuestService.luau` & `ShadowRaidService.luau`**: Akses **🥷 Begal Aura** dan pelacakan kompas otomatis **🎯 Kena Karma!** balasan **1.5x Retribusi**.
- **`FlexZoneService.luau`**: Interaksi **🔥 Flexing Shrine** di panggung utama (Hujan Koin, Sky Color Override 60s, Server Billboard).

---

## 2. Command Center & Open Cloud CLI Scripts (`scripts/`)

Proyek ini dilengkapi dengan skrip Python untuk automasi pengoperasian game langsung dari IDE:

### 📦 1. Automated Deploy (`scripts/deploy_opencloud.py`)
Melakukan kompilasi `rojo build -o test.rbxl` dan mengunggah langsung file tempat `.rbxl` ke Roblox Open Cloud API.
```bash
python3 scripts/deploy_opencloud.py
```

### 📡 2. LiveOps Messaging (`scripts/liveops_broadcast.py`)
Mengirim pesan pengumuman global (*Global Announcement*) atau mengaktifkan sinyal event ke seluruh server live via Messaging Service API.
```bash
python3 scripts/liveops_broadcast.py --message "Pengumuman LiveOps COBLOX!"
```

### 🔍 3. DataStore Admin (`scripts/datastore_admin.py`)
Menginspeksi data profil pemain di cloud secara langsung dari CLI.
```bash
python3 scripts/datastore_admin.py inspect --user-id 11329819428
```

---

## 3. Workflow Kompilasi & Deployment

1. **Kompilasi Lokal:**
   ```bash
   rojo build -o test.rbxl
   ```
2. **Push ke Cloud:**
   ```bash
   python3 scripts/deploy_opencloud.py
   ```
3. **Live Sync Studio:**
   Buka Roblox Studio > Connect Rojo Plugin (`localhost:3487`).
