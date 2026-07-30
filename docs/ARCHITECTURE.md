> **[🏠 Master Index](MASTER_INDEX.md) | [⬅️ Back to Docs](README.md)**

# 🏗️ COBLOX Architecture Specification

## 1. Core Architecture Overview
COBLOX menggunakan arsitektur **Server-Authoritative Zero-Trust Service-Oriented Architecture (SOA)** pada Roblox Engine.
- **Rojo Sync:** Menghubungkan direktori lokal `src/` ke Roblox Studio (`default.project.json`).
- **Data Persistence:** Menggunakan **ProfileStore v3** dengan *Session Locking* untuk mencegah duping/data loss.
- **Remote Events:** Semua masukan client wajib divalidasi tipe data (`typeof()`), nilai min/max (`math.clamp()`), dan jarak fisik ($\le 15$ studs).

## 2. Service & Controller Lifecycle
Setiap modul di `src/Server/Services/` dan `src/Client/Controllers/` mengikuti standar siklus hidup:
```luau
function Service.Init(self: any, Registry: any)
    -- Inisialisasi awal & pendaftaran event
end

function Service.Start(self: any, Registry: any)
    -- Aktivasi logika game pasca-booting
end
```

## 3. Registries & Data Isolation
Seluruh data konfigurasi disimpan secara terpisah di `Content/Data/` dan dikonversi menjadi *ModuleScripts* di `src/Shared/Config/Generated*Registry.luau`.
- **Aturan Akses:** Dilarang mengiterasi registry langsung via `pairs()`. Selalu gunakan `Registry.GetAll()` yang mengembalikan tabel data murni.

## 4. Open Cloud API & Web Integration
Web Portal (`web/`) berinteraksi dengan Roblox Engine melalui REST API & OAuth 2.0:
- **Header `x-api-key`:** Membutuhkan *Secret API Key murni* dari [Roblox Creator Dashboard](https://create.roblox.com/credentials) dengan IP CIDR `0.0.0.0/0` untuk mengakses DataStore dan MessagingService.
- **MessagingService `Config_Update`:** Dashboard admin mem-push perubahan konfigurasi game secara *real-time* ke Roblox Server.
- **OAuth 2.0 Authorization Code Flow:** Digunakan untuk autentikasi user/pemain di `hycoblox.vercel.app`.

