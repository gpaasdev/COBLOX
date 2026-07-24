> **[🏠 Master Index](../../MASTER_INDEX.md) | [⬅️ Back to Docs](../../README.md)**

# Modular Asset Workflow & Technical Guidelines

Dokumen panduan standar industri untuk **Kitbashing Modular Asset Workflow**, **PBR Texture Atlasing**, dan ekspor aset dari **Blender ke Roblox Studio** (Target: Stabil 60 FPS di Mobile Low-End).

---

## 1. Hierarchy ReplicatedStorage (Standard Industry Level)

Gunakan struktur folder terorganisir di bawah `ReplicatedStorage.Shared.Assets`:

```
ReplicatedStorage/
└── Shared/
    └── Assets/
        ├── ModularKits/
        │   ├── Building/
        │   │   ├── Walls/
        │   │   │   ├── Wall_Plain_High [Model]
        │   │   │   └── Wall_Plain_Low  [Model]
        │   │   └── Roofs/
        │   └── Environment/
        │       ├── Trees/
        │       │   ├── Oak_Tree_High   [Model]
        │       │   └── Oak_Tree_Low    [Model]
        │       └── Rocks/
        └── Atlases/
            ├── Textures/
            │   ├── Env_Atlas_Albedo.png
            │   ├── Env_Atlas_Normal.png
            │   └── Env_Atlas_Roughness.png
            └── Materials/
                └── M_EnvAtlas [SurfaceAppearance]
```

---

## 2. Blender Export Checklist

| Parameter | Pengaturan Blender | Keterangan & Standard Roblox |
| :--- | :--- | :--- |
| **File Format** | `.FBX` (Binary FBX 7.4) | Mempertahankan hierarchy, UV Map, dan Custom Pivot Point secara konsisten. |
| **Transforms** | Apply All Transforms (`Ctrl + A`) | Set Location `0,0,0`, Rotation `0,0,0`, Scale `1.0, 1.0, 1.0`. |
| **Unit Scale** | Metric, Scale `0.28` | $1\text{ Unit Blender} = 1\text{ Stud Roblox}$. |
| **Pivot Point (Origin)** | Snap Bottom-Center `(0, 0, 0)` | Krusial untuk kalkulasi Snap Raycast Placement System & Grid Alignment. |
| **Triangle Count (Tris)** | - Small Prop: $< 300$ tris<br>- Medium Building: $< 1,500$ tris<br>- High-Poly LOD0: Max $3,000$ tris | Mencegah bottleneck alokasi memori geometri GPU mobile. |
| **Texture Atlasing** | 1 Single Atlas Sheet ($2048 \times 2048$) | Menggabungkan multiple mesh ke 1 Material/SurfaceAppearance untuk meminimalkan **Draw Calls**. |
