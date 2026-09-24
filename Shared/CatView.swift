import SwiftUI
import CoreText

enum CatFont {
    static let registered: Bool = {
        guard let url = Bundle.main.url(forResource: "AdaCat", withExtension: "ttf") else {
            return false
        }
        // Both bundles carry the font; WidgetKit runs separately from the app.
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        return CTFontCopyPostScriptName(CTFontCreateWithName("AdaCat" as CFString, 24, nil)) as String == "AdaCat"
    }()
}

struct StillCat: View {
    var size: CGFloat
    var body: some View {
        PixelCat()
            .fill(style: FillStyle(antialiased: false))
            .frame(width: size, height: size)
            .accessibilityLabel("Piksel kedi")
    }
}

/// Experimental: each decimal glyph is a cat pose. The system updates timer text;
/// clipping the trailing digit reveals one pose without an app background loop.
/// Device testing is required: WidgetKit can throttle timers or substitute fonts.
struct IslandCat: View {
    var attributes: PetAttributes
    var size: CGFloat = 24
    @Environment(\.isLuminanceReduced) private var dimmed
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if attributes.animated && !dimmed && !reduceMotion && CatFont.registered {
                Text(timerInterval: attributes.startedAt...attributes.endsAt,
                     countsDown: false, showsHours: false)
                    .font(.custom("AdaCat", fixedSize: size))
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
                    // A wide layout avoids shrinking or truncating the timer itself.
                    .frame(width: size * 12, height: size, alignment: .trailing)
                    .frame(width: size, height: size, alignment: .trailing)
                    .clipped()
                    .environment(\.locale, Locale(identifier: "en_US_POSIX"))
                    .environment(\.layoutDirection, .leftToRight)
            } else {
                StillCat(size: size)
            }
        }
        .foregroundStyle((PetColor(rawValue: attributes.colorName) ?? .amber).color)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Piksel kedi")
    }
}
