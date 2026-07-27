#!/usr/bin/env python3
"""
COBLOX Autonomous 3D Asset Pipeline
Dipanggil oleh AI Agent untuk menghasilkan mesh 3D, mengoptimasi, dan upload ke Roblox.

Usage:
    python scripts/asset_pipeline_3d.py --prompt "a low poly sci-fi cauldron" --output src/Assets/Models/
    python scripts/asset_pipeline_3d.py --image src/Assets/ref/sword.png --output src/Assets/Models/
    python scripts/asset_pipeline_3d.py --mode triposr --prompt "alchemy vase" --output src/Assets/Models/
    python scripts/asset_pipeline_3d.py --mode tripo_api --prompt "fire pet egg" --output src/Assets/Models/ --upload

Modes:
    triposr   - VAST-AI-Research/TripoSR (lokal, cepat <1 detik, butuh GPU/CPU)
    trellis   - microsoft/TRELLIS (lokal, kualitas tinggi, butuh GPU)
    tripo_api - Tripo3D cloud API (tidak perlu GPU lokal)
    comfyui   - ComfyUI + 3D Pack API (butuh ComfyUI jalan di localhost:8188)

Env vars yang dibutuhkan (di .env):
    TRIPO3D_API_KEY     - API key Tripo3D cloud (mode tripo_api)
    ROBLOX_OPENCLOUD_API_KEY - Untuk upload ke Roblox (--upload flag)
    ROBLOX_UNIVERSE_ID  - Universe ID COBLOX
"""

import argparse
import json
import os
import subprocess
import sys
import time
from pathlib import Path

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass  # dotenv opsional, env var bisa diset manual

# ─── Config ───────────────────────────────────────────────────────────────────

ROBLOX_OPEN_CLOUD_BASE = "https://apis.roblox.com/assets/v1"
MAX_TRIANGLE_COUNT = 10_000  # Roblox Layered Clothing limit
BLENDER_EXEC = os.environ.get("BLENDER_EXEC", "blender")
TRIPOSR_PATH = os.environ.get("TRIPOSR_PATH", "../TripoSR")
TRELLIS_PATH = os.environ.get("TRELLIS_PATH", "../TRELLIS")


# ─── Step 1: Generate 3D mesh ─────────────────────────────────────────────────

def generate_triposr(prompt: str | None, image_path: str | None, output_dir: Path) -> Path:
    """Jalankan TripoSR CLI untuk generate .obj dari gambar."""
    if not image_path:
        raise ValueError("TripoSR membutuhkan --image (gambar referensi)")

    output_dir.mkdir(parents=True, exist_ok=True)
    result_path = output_dir / "output.obj"

    cmd = [
        sys.executable,
        str(Path(TRIPOSR_PATH) / "run.py"),
        image_path,
        "--output-dir", str(output_dir),
        "--model-save-format", "obj",
    ]
    print(f"[TripoSR] Menjalankan: {' '.join(cmd)}")
    subprocess.run(cmd, check=True)
    return result_path


def generate_trellis(prompt: str, output_dir: Path) -> Path:
    """Jalankan TRELLIS CLI untuk generate .obj dari teks."""
    output_dir.mkdir(parents=True, exist_ok=True)
    result_path = output_dir / "output.obj"

    cmd = [
        sys.executable,
        str(Path(TRELLIS_PATH) / "sample.py"),
        "--text", prompt,
        "--output_format", "obj",
        "--output_dir", str(output_dir),
    ]
    print(f"[TRELLIS] Menjalankan: {' '.join(cmd)}")
    subprocess.run(cmd, check=True)
    return result_path


def generate_tripo_api(prompt: str, output_dir: Path) -> Path:
    """Panggil Tripo3D REST API untuk generate mesh dari teks/gambar."""
    try:
        import requests
    except ImportError:
        raise RuntimeError("Install requests: pip install requests")

    api_key = os.environ.get("TRIPO3D_API_KEY")
    if not api_key:
        raise RuntimeError("TRIPO3D_API_KEY tidak ditemukan di environment/.env")

    output_dir.mkdir(parents=True, exist_ok=True)
    headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}

    # Buat task generate
    print(f"[Tripo3D API] Membuat task untuk prompt: '{prompt}'")
    resp = requests.post(
        "https://api.tripo3d.ai/v2/openapi/task",
        headers=headers,
        json={"type": "text_to_model", "prompt": prompt},
    )
    resp.raise_for_status()
    task_id = resp.json()["data"]["task_id"]
    print(f"[Tripo3D API] Task ID: {task_id}")

    # Poll sampai selesai
    for attempt in range(60):
        time.sleep(5)
        status_resp = requests.get(
            f"https://api.tripo3d.ai/v2/openapi/task/{task_id}",
            headers=headers,
        )
        status_resp.raise_for_status()
        data = status_resp.json()["data"]
        status = data.get("status")
        print(f"[Tripo3D API] Status ({attempt+1}/60): {status}")

        if status == "success":
            model_url = data["output"]["model"]
            break
        elif status in ("failed", "cancelled"):
            raise RuntimeError(f"Tripo3D task gagal: {data}")
    else:
        raise RuntimeError("Tripo3D task timeout setelah 5 menit")

    # Download file
    output_path = output_dir / "output.glb"
    print(f"[Tripo3D API] Mengunduh model dari {model_url}")
    model_resp = requests.get(model_url, stream=True)
    model_resp.raise_for_status()
    with open(output_path, "wb") as f:
        for chunk in model_resp.iter_content(chunk_size=8192):
            f.write(chunk)

    print(f"[Tripo3D API] ✅ Model tersimpan: {output_path}")
    return output_path


def generate_comfyui(prompt: str, output_dir: Path) -> Path:
    """Kirim request ke ComfyUI + 3D Pack API (localhost:8188)."""
    try:
        import requests
    except ImportError:
        raise RuntimeError("Install requests: pip install requests")

    output_dir.mkdir(parents=True, exist_ok=True)
    comfy_host = os.environ.get("COMFYUI_HOST", "http://localhost:8188")

    # Workflow minimal untuk text-to-3D
    workflow = {
        "1": {
            "class_type": "TripoSR",
            "inputs": {"text": prompt, "output_format": "obj"},
        }
    }

    print(f"[ComfyUI] Mengirim workflow ke {comfy_host}")
    resp = requests.post(f"{comfy_host}/prompt", json={"prompt": workflow})
    resp.raise_for_status()
    prompt_id = resp.json()["prompt_id"]

    # Poll history
    for _ in range(60):
        time.sleep(3)
        history_resp = requests.get(f"{comfy_host}/history/{prompt_id}")
        history = history_resp.json()
        if prompt_id in history and history[prompt_id].get("outputs"):
            outputs = history[prompt_id]["outputs"]
            # Ambil file output pertama
            for node_outputs in outputs.values():
                if "files" in node_outputs:
                    filename = node_outputs["files"][0]["filename"]
                    file_resp = requests.get(f"{comfy_host}/view?filename={filename}")
                    output_path = output_dir / filename
                    output_path.write_bytes(file_resp.content)
                    print(f"[ComfyUI] ✅ Model tersimpan: {output_path}")
                    return output_path
        print(f"[ComfyUI] Menunggu hasil...")
    raise RuntimeError("ComfyUI timeout")


# ─── Step 2: Optimize mesh ────────────────────────────────────────────────────

def optimize_mesh_blender(input_path: Path, output_path: Path, max_tris: int = MAX_TRIANGLE_COUNT) -> Path:
    """
    Jalankan Blender headless untuk decimation/optimize mesh.
    Membutuhkan Blender terinstall dan BLENDER_EXEC di PATH atau env var.
    """
    blender_script = f"""
import bpy
import sys

bpy.ops.wm.read_factory_settings(use_empty=True)
ext = '{input_path.suffix.lower()}'
if ext == '.obj':
    bpy.ops.wm.obj_import(filepath='{input_path}')
elif ext in ('.glb', '.gltf'):
    bpy.ops.import_scene.gltf(filepath='{input_path}')
elif ext == '.fbx':
    bpy.ops.import_scene.fbx(filepath='{input_path}')

for obj in bpy.context.scene.objects:
    if obj.type == 'MESH':
        bpy.context.view_layer.objects.active = obj
        mod = obj.modifiers.new(name='Decimate', type='DECIMATE')
        tri_count = sum(len(p.vertices) - 2 for p in obj.data.polygons)
        if tri_count > {max_tris}:
            mod.ratio = {max_tris} / tri_count
            bpy.ops.object.modifier_apply(modifier='Decimate')
        print(f'[Blender] {{obj.name}}: {{tri_count}} tris -> optimized')

bpy.ops.export_scene.fbx(filepath='{output_path}', use_selection=False)
print('[Blender] Export selesai: {output_path}')
"""
    script_path = input_path.parent / "_blender_optimize.py"
    script_path.write_text(blender_script)

    cmd = [BLENDER_EXEC, "--background", "--python", str(script_path)]
    print(f"[Blender] Mengoptimasi mesh: {input_path} → {output_path}")
    try:
        subprocess.run(cmd, check=True, capture_output=True, text=True)
        print(f"[Blender] ✅ Mesh dioptimasi: {output_path}")
    except FileNotFoundError:
        print(f"[Blender] ⚠️ Blender tidak ditemukan di '{BLENDER_EXEC}'. Melewati optimasi.")
        # Fallback: salin file tanpa optimasi
        import shutil
        shutil.copy(input_path, output_path)
    finally:
        script_path.unlink(missing_ok=True)

    return output_path


# ─── Step 3: Upload ke Roblox Open Cloud ─────────────────────────────────────

def upload_to_roblox(fbx_path: Path, asset_name: str) -> str:
    """Upload .fbx ke Roblox Open Cloud Asset API dan return AssetId."""
    try:
        import requests
    except ImportError:
        raise RuntimeError("Install requests: pip install requests")

    api_key = os.environ.get("ROBLOX_OPENCLOUD_API_KEY")
    universe_id = os.environ.get("ROBLOX_UNIVERSE_ID")

    if not api_key:
        raise RuntimeError("ROBLOX_OPENCLOUD_API_KEY tidak ditemukan di .env")
    if not universe_id:
        raise RuntimeError("ROBLOX_UNIVERSE_ID tidak ditemukan di .env — konfirmasi Universe ID ke Creator Dashboard dulu")

    headers = {"x-api-key": api_key}
    metadata = {
        "assetType": "Model",
        "displayName": asset_name,
        "description": f"Auto-generated asset: {asset_name}",
        "creationContext": {"creator": {"userId": os.environ.get("ROBLOX_CREATOR_USER_ID", "")}},
    }

    print(f"[OpenCloud] Mengupload '{asset_name}' ke Roblox...")
    with open(fbx_path, "rb") as f:
        resp = requests.post(
            f"{ROBLOX_OPEN_CLOUD_BASE}/assets",
            headers=headers,
            data={"request": json.dumps(metadata)},
            files={"fileContent": (fbx_path.name, f, "model/fbx")},
        )
    resp.raise_for_status()

    operation_id = resp.json().get("operationId")
    print(f"[OpenCloud] Operation ID: {operation_id}")

    # Poll operation sampai selesai
    for _ in range(30):
        time.sleep(3)
        op_resp = requests.get(
            f"{ROBLOX_OPEN_CLOUD_BASE}/operations/{operation_id}",
            headers=headers,
        )
        op_resp.raise_for_status()
        op_data = op_resp.json()
        if op_data.get("done"):
            asset_id = op_data["response"]["assetId"]
            print(f"[OpenCloud] ✅ Upload selesai! AssetId: {asset_id}")
            print(f"[OpenCloud] Gunakan: rbxassetid://{asset_id}")
            return str(asset_id)
        print(f"[OpenCloud] Menunggu upload...")

    raise RuntimeError("Upload ke Roblox timeout")


# ─── Main ─────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="COBLOX Autonomous 3D Asset Pipeline")
    parser.add_argument("--mode", choices=["triposr", "trellis", "tripo_api", "comfyui"], default="tripo_api",
                        help="Mode generator 3D (default: tripo_api)")
    parser.add_argument("--prompt", type=str, help="Deskripsi teks untuk model 3D")
    parser.add_argument("--image", type=str, help="Path gambar referensi (untuk triposr)")
    parser.add_argument("--output", type=str, default="src/Assets/Models/", help="Direktori output")
    parser.add_argument("--name", type=str, help="Nama aset (default: diambil dari prompt)")
    parser.add_argument("--upload", action="store_true", help="Upload hasil ke Roblox Open Cloud")
    parser.add_argument("--max-tris", type=int, default=MAX_TRIANGLE_COUNT, help=f"Batas triangle (default: {MAX_TRIANGLE_COUNT})")
    parser.add_argument("--skip-optimize", action="store_true", help="Lewati optimasi Blender")
    args = parser.parse_args()

    if not args.prompt and not args.image:
        parser.error("Wajib salah satu: --prompt atau --image")

    output_dir = Path(args.output)
    asset_name = args.name or (args.prompt[:30].replace(" ", "_") if args.prompt else Path(args.image).stem)

    print("=" * 60)
    print(f"[COBLOX 3D Pipeline] Mode: {args.mode}")
    print(f"[COBLOX 3D Pipeline] Output: {output_dir}")
    print(f"[COBLOX 3D Pipeline] Asset name: {asset_name}")
    print("=" * 60)

    # Step 1: Generate mesh
    if args.mode == "triposr":
        raw_path = generate_triposr(args.prompt, args.image, output_dir / "raw")
    elif args.mode == "trellis":
        raw_path = generate_trellis(args.prompt, output_dir / "raw")
    elif args.mode == "tripo_api":
        raw_path = generate_tripo_api(args.prompt, output_dir / "raw")
    elif args.mode == "comfyui":
        raw_path = generate_comfyui(args.prompt, output_dir / "raw")

    # Step 2: Optimize mesh
    if not args.skip_optimize:
        optimized_path = output_dir / f"{asset_name}_optimized.fbx"
        final_path = optimize_mesh_blender(raw_path, optimized_path, args.max_tris)
    else:
        final_path = raw_path
        print("[Pipeline] Melewati optimasi Blender.")

    print(f"\n✅ Model siap: {final_path}")

    # Step 3: Upload (opsional)
    if args.upload:
        asset_id = upload_to_roblox(final_path, asset_name)
        # Simpan mapping ke file JSON untuk referensi Agent
        mapping_file = output_dir / "asset_id_mapping.json"
        mapping = {}
        if mapping_file.exists():
            mapping = json.loads(mapping_file.read_text())
        mapping[asset_name] = {
            "assetId": asset_id,
            "rbxassetid": f"rbxassetid://{asset_id}",
            "localPath": str(final_path),
            "generatedAt": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        }
        mapping_file.write_text(json.dumps(mapping, indent=2))
        print(f"\n📄 Mapping tersimpan: {mapping_file}")
        print(f"   Tambahkan ke registry COBLOX: rbxassetid://{asset_id}")
    else:
        print("\n💡 Jalankan dengan --upload untuk upload ke Roblox Open Cloud.")

    print("\n[COBLOX 3D Pipeline] Selesai.")


if __name__ == "__main__":
    main()
