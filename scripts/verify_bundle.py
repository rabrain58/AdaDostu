"""Run on the actual macOS build before shipping the IPA."""
from pathlib import Path
import plistlib
import sys

app = Path(sys.argv[1])
extension = app / "PlugIns" / "AdaDostuIsland.appex"
a = plistlib.loads((app / "Info.plist").read_bytes())
e = plistlib.loads((extension / "Info.plist").read_bytes())
assert a["NSSupportsLiveActivities"] is True
assert e["NSExtension"]["NSExtensionPointIdentifier"] == "com.apple.widgetkit-extension"
assert e["CFBundleIdentifier"].startswith(a["CFBundleIdentifier"] + ".")
assert a["CFBundleVersion"] == e["CFBundleVersion"]
for bundle, info in [(app, a), (extension, e)]:
    assert "AdaCat.ttf" in info["UIAppFonts"]
    assert (bundle / "AdaCat.ttf").stat().st_size > 1000
    assert (bundle / "cat-0.png").is_file()
    assert (bundle / info["CFBundleExecutable"]).is_file()
print("PASS: actual app/extension bundle identifiers, Live Activity metadata, fonts, sprites and executables.")
