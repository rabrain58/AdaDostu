"""Original pixel artwork and timer font. No downloaded character assets."""
from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / ".build-tools"))
from fontTools.fontBuilder import FontBuilder
from fontTools.pens.ttGlyphPen import TTGlyphPen
from PIL import Image, ImageDraw

def pose(index):
    grid = [[0] * 24 for _ in range(24)]
    def rect(x, y, w, h, value=1):
        for row in range(y, y + h):
            for col in range(x, x + w):
                grid[row][col] = value
    # A side-facing kitten: raised tail, block ears, little paws.
    rect(6, 11, 12, 7)
    rect(12, 7, 9, 8)
    rect(12, 4, 2, 4)
    rect(13, 6, 3, 2)
    rect(18, 4, 2, 4)
    rect(17, 6, 3, 2)
    rect(20, 10, 2, 3)
    rect(4, 10, 3, 5)
    tail = index % 4
    rect(2, 7 + (tail % 2), 2, 6)
    rect(2, 6 + (tail % 2), 3, 2)
    rect(17, 9, 1, 1, 0)
    if index == 8:
        rect(17, 9, 2, 1, 0)
    if index % 2 == 0:
        rect(7, 18, 2, 3)
        rect(8, 20, 3, 1)
        rect(16, 18, 2, 3)
        rect(17, 20, 3, 1)
    else:
        rect(9, 18, 2, 2)
        rect(10, 19, 3, 1)
        rect(14, 18, 2, 3)
        rect(13, 20, 3, 1)
    return grid

def glyph(grid):
    pen = TTGlyphPen(None)
    for y, row in enumerate(grid):
        for x, bit in enumerate(row):
            if bit:
                left, bottom = x * 100, (23 - y) * 100
                pen.moveTo((left, bottom))
                pen.lineTo((left, bottom + 100))
                pen.lineTo((left + 100, bottom + 100))
                pen.lineTo((left + 100, bottom))
                pen.closePath()
    return pen.glyph()

def generate():
    resources = ROOT / "Resources"
    resources.mkdir(exist_ok=True)
    names = [".notdef", "space", "colon"] + [f"pose{i}" for i in range(10)]
    font = FontBuilder(2400, isTTF=True)
    font.setupGlyphOrder(names)
    font.setupCharacterMap({32: "space", 58: "colon", **{48 + i: f"pose{i}" for i in range(10)}})
    empty = [[0] * 24 for _ in range(24)]
    glyphs = {name: glyph(empty) for name in names[:3]}
    glyphs.update({f"pose{i}": glyph(pose(i)) for i in range(10)})
    font.setupGlyf(glyphs)
    font.setupHorizontalMetrics({name: (2400, 200 if name.startswith("pose") else 0) for name in names})
    font.setupHorizontalHeader(ascent=2400, descent=0, lineGap=0)
    font.setupNameTable({
        "familyName": "AdaCat", "styleName": "Regular", "uniqueFontIdentifier": "AdaCat-1",
        "fullName": "AdaCat", "psName": "AdaCat", "version": "Version 1.0",
        "copyright": "Original AdaDostu pixel artwork"
    })
    font.setupOS2(sTypoAscender=2400, sTypoDescender=0, sTypoLineGap=0,
                  usWinAscent=2400, usWinDescent=0, fsType=0, fsSelection=64)
    font.setupPost()
    font.setupMaxp()
    font.save(resources / "AdaCat.ttf")
    frames = []
    for i in range(10):
        frame = Image.new("RGBA", (24, 24))
        for y, row in enumerate(pose(i)):
            for x, bit in enumerate(row):
                if bit:
                    frame.putpixel((x, y), (255, 255, 255, 255))
        frame.save(resources / f"cat-{i}.png")
        frames.append(frame)
    catalog = resources / "Assets.xcassets"
    icon = catalog / "AppIcon.appiconset"
    icon.mkdir(parents=True, exist_ok=True)
    (catalog / "Contents.json").write_text(json.dumps({"info": {"author": "xcode", "version": 1}}))
    canvas = Image.new("RGB", (1024, 1024), "#10161B")
    draw = ImageDraw.Draw(canvas)
    draw.rounded_rectangle((130, 315, 894, 710), radius=180, fill="#050708")
    cat = frames[0].resize((624, 624), Image.Resampling.NEAREST)
    tint = Image.new("RGB", cat.size, "#FFBA66")
    canvas.paste(tint, (200, 160), cat.getchannel("A"))
    canvas.save(icon / "AppIcon.png")
    (icon / "Contents.json").write_text(json.dumps({
        "images": [{"filename": "AppIcon.png", "idiom": "universal", "platform": "ios", "size": "1024x1024"}],
        "info": {"author": "xcode", "version": 1}
    }, indent=2))
    # Design inspection only, not evidence of a running iPhone application.
    board = Image.new("RGB", (960, 280), "#10161B")
    d = ImageDraw.Draw(board)
    for i in range(4):
        f = frames[i].resize((192, 192), Image.Resampling.NEAREST)
        board.paste(Image.new("RGB", f.size, "#FFBA66"), (24 + i * 240, 36), f.getchannel("A"))
    (ROOT / "design").mkdir(exist_ok=True)
    board.save(ROOT / "design" / "cat-frames.png")
    print("Generated font, 10 sprite frames and app icon.")

if __name__ == "__main__":
    generate()
