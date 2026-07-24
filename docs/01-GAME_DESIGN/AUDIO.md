> **[🏠 Master Index](../MASTER_INDEX.md) | [⬅️ Back to Docs](../README.md)**

# 06 — AUDIO BIBLE & SPATIAL SOUND

## 1. Sound Categories & Bus Structure
- `Master/BGM`: Musik latar bersemangat dan tidak memicu kelelahan pendengaran.
- `Master/SFX/UI`: Efek suara klik tombol `UIButtonAnimator`, pergantian tab, dan konfirmasi transaksi.
- `Master/SFX/World`: Efek 3D penetasan telur, benturan penambangan pet (*Back Out tween impact*), tebasan pedang, serta tangkisan *Parry*.

## 2. Audio Log & Typewriter Sync
- **Story Audio Logs:** Suara narasi cerita (*Tape 01, Tape 02*) terhubung dengan modul `CodexController.luau`.
- **Spirit Memory Sync:** Efek *typewriter* narasi tersinkronisasi dengan efek suara *Vignette* misterius saat pet mengalami *Awakening*.
- **Batasan Instansiasi 3D:** Maksimal 16 instansi audio 3D bersamaan untuk menghemat penggunaan CPU.
