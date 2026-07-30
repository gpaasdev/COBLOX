"""
Texture Baker — COBLOX Mobile Optimization Pipeline
Batch converts 4K PBR textures to 1K compressed maps for mobile GPU budgets.

Usage:
    python3 scripts/texture_baker.py --input assets/textures/4k --output assets/textures/1k
    python3 scripts/texture_baker.py --input assets/textures/4k --output assets/textures/1k --max-size 1024 --quality 85
"""

import argparse
import os
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("ERROR: Pillow not installed. Run: pip install Pillow")
    sys.exit(1)

SUPPORTED_EXTENSIONS = {".png", ".jpg", ".jpeg", ".tga", ".bmp"}
CHANNEL_LABELS = {"_Color", "_Albedo", "_Normal", "_Roughness", "_Metalness", "_AO", "_Opacity", "_Displacement"}


def bake_texture(input_path: Path, output_path: Path, max_size: int, quality: int) -> tuple[str, str, int]:
    """Resize and recompress a single texture. Returns (input_name, status, original_size_kb)."""
    try:
        img = Image.open(input_path)
        original_size = os.path.getsize(input_path) // 1024

        # Determine target size (square power of 2, max_dim <= max_size)
        w, h = img.size
        scale = min(max_size / w, max_size / h, 1.0)
        if scale < 1.0:
            new_w = int(w * scale)
            new_h = int(h * scale)
            resample = Image.LANCZOS if new_w * new_h > 512 * 512 else Image.BILINEAR
            img = img.resize((new_w, new_h), resample)

        # Determine output format
        output_ext = output_path.suffix.lower()
        if output_ext == ".jpg":
            if img.mode in ("RGBA", "P"):
                img = img.convert("RGB")
            img.save(output_path, "JPEG", quality=quality, optimize=True)
        elif output_ext == ".png":
            img.save(output_path, "PNG", optimize=True)
        else:
            img.save(output_path)

        new_size = os.path.getsize(output_path) // 1024
        return (input_path.name, "OK", original_size, new_size)

    except Exception as e:
        return (input_path.name, f"FAIL: {e}", 0, 0)


def find_textures(input_dir: Path) -> list[Path]:
    """Recursively find all supported texture files."""
    files = []
    for ext in SUPPORTED_EXTENSIONS:
        files.extend(input_dir.rglob(f"*{ext}"))
    return sorted(files)


def bake_batch(
    input_dir: Path,
    output_dir: Path,
    max_size: int = 1024,
    quality: int = 85,
    workers: int = 4,
    dry_run: bool = False,
):
    """Bake all textures from input_dir to output_dir."""
    textures = find_textures(input_dir)
    if not textures:
        print(f"No supported textures found in {input_dir}")
        return

    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Found {len(textures)} textures")
    print(f"Source: {input_dir}")
    print(f"Output: {output_dir}")
    print(f"Max size: {max_size}px")
    print(f"JPEG quality: {quality}")
    print(f"Workers: {workers}")
    print(f"Dry run: {dry_run}")
    print()

    if dry_run:
        print("--- Dry Run Preview ---")
        total_orig = 0
        for tex in textures[:20]:
            size_kb = os.path.getsize(tex) // 1024
            total_orig += size_kb
            channel_type = "unknown"
            for label in CHANNEL_LABELS:
                if label.lower() in tex.stem.lower():
                    channel_type = label
                    break
            print(f"  {tex.name} ({size_kb} KB, {channel_type})")
        if len(textures) > 20:
            print(f"  ... and {len(textures) - 20} more")
        total_mb = total_orig / 1024
        print(f"\nTotal original size: ~{total_mb:.1f} MB")
        print(f"Estimated after baking: ~{total_mb * 0.3:.1f} MB (at {max_size}px)")
        return

    results = []
    with ThreadPoolExecutor(max_workers=workers) as executor:
        futures = {}
        for tex in textures:
            rel_path = tex.relative_to(input_dir)
            out_path = output_dir / rel_path
            out_path.parent.mkdir(parents=True, exist_ok=True)
            fut = executor.submit(bake_texture, tex, out_path, max_size, quality)
            futures[fut] = tex

        for fut in as_completed(futures):
            name, status, orig_kb, new_kb = fut.result()
            results.append((name, status, orig_kb, new_kb))

    # Summary
    ok_count = sum(1 for _, s, _, _ in results if s == "OK")
    fail_count = sum(1 for _, s, _, _ in results if s != "OK")
    total_orig = sum(r[2] for r in results)
    total_new = sum(r[3] for r in results)

    print(f"\nResults: {ok_count} OK, {fail_count} failed")
    print(f"Original size: {total_orig / 1024:.1f} MB")
    print(f"After baking:  {total_new / 1024:.1f} MB")
    print(f"Reduction:     {(1 - total_new / max(1, total_orig)) * 100:.1f}%")

    if fail_count > 0:
        print("\nFailures:")
        for name, status, _, _ in results:
            if status != "OK":
                print(f"  {name}: {status}")


def main():
    parser = argparse.ArgumentParser(
        description="COBLOX Texture Baker — 4K to 1K PBR compression pipeline"
    )
    parser.add_argument("--input", "-i", required=True, help="Input directory (4K textures)")
    parser.add_argument("--output", "-o", required=True, help="Output directory (baked textures)")
    parser.add_argument("--max-size", type=int, default=1024, help="Maximum dimension in pixels (default: 1024)")
    parser.add_argument("--quality", type=int, default=85, help="JPEG compression quality 1-100 (default: 85)")
    parser.add_argument("--workers", type=int, default=4, help="Parallel workers (default: 4)")
    parser.add_argument("--dry-run", action="store_true", help="Preview without baking")
    args = parser.parse_args()

    input_dir = Path(args.input)
    output_dir = Path(args.output)

    if not input_dir.is_dir():
        print(f"ERROR: Input directory not found: {input_dir}")
        sys.exit(1)

    bake_batch(
        input_dir=input_dir,
        output_dir=output_dir,
        max_size=args.max_size,
        quality=args.quality,
        workers=args.workers,
        dry_run=args.dry_run,
    )


if __name__ == "__main__":
    main()
