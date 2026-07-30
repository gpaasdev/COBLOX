import os
from PIL import Image, ImageDraw, ImageFont

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS_DIR = os.path.join(BASE_DIR, "src", "Assets")
TARGETS = [
    ("Materials", 112, (50, 100, 255)),
    ("Spirits", 55, (100, 255, 100)),
    ("Recipes", 45, (255, 150, 50)),
    ("Badges", 15, (255, 50, 50))
]

def generate_placeholders():
    print("Generating 2D Asset Placeholders...")
    for folder, count, color in TARGETS:
        target_dir = os.path.join(ASSETS_DIR, "Textures", "UI", folder)
        os.makedirs(target_dir, exist_ok=True)
        for i in range(1, count + 1):
            img = Image.new('RGB', (256, 256), color=color)
            d = ImageDraw.Draw(img)
            d.text((10,120), f"{folder[:-1]} {i}", fill=(255,255,255))
            img.save(os.path.join(target_dir, f"icon_{i}.png"))
        print(f"✅ Generated {count} icons for {folder}")
        
if __name__ == "__main__":
    generate_placeholders()
