# Panduan Kontribusi (Contributing Guidelines)

Terima kasih telah tertarik untuk berkontribusi pada pengembangan **COBLOX: Multiverse Alchemy Sanctum**!

---

## 🛠️ Alur Kerja Pengkodian (Workflow)

1. **Fork & Clone:** Fork repositori ini ke akun Anda, lalu lakukan `git clone`.
2. **Buat Cabang Fitur (Feature Branch):**
   ```bash
   git checkout -b feature/nama-fitur-baru
   ```
3. **Patuhi Standard Kualitas (RGS & Luau Compliance):**
   - Gunakan `--!strict` di bagian paling atas setiap file script Luau.
   - Hindari variabel global murni.
   - Pastikan beban memori tetap hemat (target < 2.5 GB RAM).
4. **Jalankan Verifikasi Lokal:**
   ```bash
   # Cek linter Luau
   selene src/

   # Cek kepatuhan arsitektur
   python scripts/validate_rgs_compliance.py
   ```
5. **Kirimkan Pull Request (PR):**
   - Buat PR menuju cabang `main` di repositori utama.
   - Jelaskan secara rinci perubahan yang Anda lakukan dan tes yang telah Anda jalankan.

---

## 🐛 Melaporkan Bug atau Fitur Baru

Gunakan **GitHub Issue Templates** yang telah disediakan:
- `bug_report.md` untuk melaporkan *glitch*, kegagalan *data persistence*, atau masalah performa.
- `feature_request.md` untuk mengusulkan ide resep alkimia baru, Spirit Companion, atau mekanisme gameplay.
