# COBLOX Incident Playbook

Panduan taktis operasional (On-Call) untuk merespons kegagalan sistem pada fase *Live-Service*.

## Service Level Objectives (SLO) & Error Budget

| Metric | Target | Current | Status |
| :--- | :---: | :---: | :---: |
| Crash-free sessions | ≥ 99.5% | — | Unknown |
| Analytics flush success | ≥ 99% | — | Unknown |
| Webhook delivery | ≥ 95% | — | Unknown |
| Session tracking success | ≥ 99% | — | Unknown |
| RemoteConfig availability| ≥ 99.9%| — | Unknown |
| Average server FPS | ≥ 50 FPS| — | Unknown |

---

## 1. Ekonomi Dieksploitasi Masif (Hyper-Inflation)

* **Trigger:** Laporan pemain via Discord, atau peringatan anomali Gini Coefficient di *Analytics*.
* **Detection:** Mengonfirmasi lonjakan aneh di `economy.transaction` yang melebihi wajar.
* **Immediate Action:** Aktifkan **Kill Switch** Economy/Trading ke mode `READ_ONLY` atau `DISABLED` via `FeatureFlagService`.
* **Kill Switch:** `FeatureFlagService.FLAGS.tradingSystem = "DISABLED"`
* **Rollback:** *Server Shutdown* jika diperlukan, diikuti *Datastore Revert* ke versi sebelum eksploitasi.
* **Verification:** Periksa nilai inflasi dan ekonomi global di *Sandbox*.
* **Communication:** Gunakan `AnnouncementService` untuk mengirim Banner Broadcast: "Trading is temporarily disabled for maintenance."
* **Recovery:** Patch *exploit* di server, nyalakan kembali `tradingSystem = "ENABLED"`.
* **Postmortem:** Ditulis ke Notion: Root cause, waktu terbuang, mitigasi ke depan.

---

## 2. Discord Webhook Rate Limited / Mati

* **Trigger:** Peringatan `WARN: Webhook Delivery Failed` di konsol server.
* **Detection:** Log `HttpService` mengembalikan kode 429 atau 500.
* **Immediate Action:** Jangan panik. Gameplay tidak terdampak berkat struktur *asynchronous queue* pada `FeedbackService`.
* **Kill Switch:** Tidak diperlukan. `pcall` melindungi game.
* **Rollback:** N/A.
* **Verification:** Pastikan jumlah error tidak terus merusak kinerja *Server*.
* **Communication:** N/A. Operasi *backend* murni.
* **Recovery:** Perpanjang `BATCH_FLUSH_INTERVAL` sementara.
* **Postmortem:** Tinjau kuota batasan API Discord.

---

## 3. DataStore Throttle / Gagal Memuat Data

* **Trigger:** Pemain gagal masuk, atau peringatan DataStore 502/429 di konsol.
* **Detection:** Log `ProfileStore` berulang kali mengeluarkan pesan pelepasan kunci gagal.
* **Immediate Action:** Aktifkan **Maintenance Mode** untuk mencegah hilangnya data pemain baru.
* **Kill Switch:** `FeatureFlagService.FLAGS.maintenanceMode = true`.
* **Rollback:** N/A.
* **Verification:** Cek situs status Roblox.
* **Communication:** `AnnouncementService`: "Global Roblox Datastore disruption. Progress may not save. Please wait."
* **Recovery:** Matikan *Maintenance Mode* saat Roblox hijau kembali.
* **Postmortem:** Tinjau batas toleransi *ProfileService*.
