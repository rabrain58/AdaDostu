"""Offline asset/config checks, NOT Swift compilation or device acceptance."""
from pathlib import Path
import json
import sys
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / ".build-tools"))
import yaml
from fontTools.ttLib import TTFont
from PIL import Image, ImageFont

spec = yaml.safe_load((ROOT / "project.yml").read_text(encoding="utf-8"))
app = spec["targets"]["AdaDostu"]
extension = spec["targets"]["AdaDostuIsland"]
a = app["settings"]["base"]["PRODUCT_BUNDLE_IDENTIFIER"]
e = extension["settings"]["base"]["PRODUCT_BUNDLE_IDENTIFIER"]
assert e.startswith(a + ".")
assert app["info"]["properties"]["NSSupportsLiveActivities"] is True
assert app["dependencies"][0] == {"target": "AdaDostuIsland", "embed": True}
assert extension["info"]["properties"]["NSExtension"]["NSExtensionPointIdentifier"] == "com.apple.widgetkit-extension"
font_path = ROOT / "Resources/AdaCat.ttf"
font = TTFont(font_path)
assert font["name"].getDebugName(6) == "AdaCat"
assert font["head"].unitsPerEm == 2400
cmap = font.getBestCmap()
poses = []
for i in range(10):
    name = cmap[ord(str(i))]
    assert font["hmtx"][name][0] == 2400
    assert font["glyf"][name].numberOfContours > 0
    poses.append(bytes(font["glyf"][name].compile(font["glyf"])))
assert len(set(poses)) >= 3, "Need alternating walk poses and blink."
raster = ImageFont.truetype(str(font_path), 24)
assert raster.getlength("0123456789") == 240
assert raster.getmask("0").getbbox() is not None
for i in range(10):
    with Image.open(ROOT / f"Resources/cat-{i}.png") as image:
        assert image.size == (24, 24) and image.mode == "RGBA"
with Image.open(ROOT / "Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png") as icon:
    assert icon.size == (1024, 1024) and icon.mode == "RGB"
workflow = yaml.load((ROOT / ".github/workflows/build-ipa.yml").read_text(), Loader=yaml.BaseLoader)
assert "main" in workflow["on"]["push"]["branches"]
assert "workflow_dispatch" in workflow["on"]
assert workflow["permissions"] == {"contents": "read"}
for path in ROOT.rglob("*.swift"):
    text = path.read_text(encoding="utf-8")
    assert "\ufffd" not in text
    assert "\u00c3" not in text and "\u00c4" not in text, f"Broken UTF-8: {path}"
print("PASS: source configuration, extension embedding, timer-font glyphs/metrics/raster, 10 sprites, icon and workflow triggers.")
print("NOT VERIFIED: Swift build, Sideloadly signing, iOS 27 animation and device lifecycle.")
