> **[🏠 Master Index](../MASTER_INDEX.md) | [⬅️ Back to Docs](../README.md)**

# 05 — ART DIRECTION & 3D ASSET RULES

## 1. Visual Style & Model Budgets
- **Estetika:** Low-Poly bersih dan cerah dengan efek gradien halus (*Quantum Indigo*, *Aura Gold*, *Spark Cyan*).
- **Anggaran Poligon:** Maksimal 2.500 segitiga (triangles) per MeshPart (Pet, Monster, atau Mesin Sanctum).
- **Tekstur:** Tekstur gradien warna $512\times 512$ shared yang efisien memori.

## 2. Lighting & Post-Processing FX Engine
- **VFXEngine.luau:** Mengontrol `ColorCorrectionEffect`, `BlurEffect`, dan `BloomEffect` secara tersentralisasi.
- **Screen Shake:** Goyangan kamera yang halus saat reaksi sintesis atau dampak ledakan alkimia terjadi.
- **Pet Particle Aura System:** Setiap pet aktif dilengkapi *ParticleEmitter* jejak aura dan pancaran cahaya (*LightEmission 0.8*).
- **Sanctum Evolution Visuals:** Tema material dan warna pulau berubah otomatis seiring Rebirth (*Slate Cave* $\to$ *Cobblestone Island* $\to$ *ForceField Cosmic Temple*).
- **Hologram Placement Preview:** Hologram berwarna Hijau untuk lokasi valid dan Merah untuk posisi tidak valid/tabrakan.
