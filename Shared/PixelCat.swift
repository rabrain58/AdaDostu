import SwiftUI

/// Asset-free geometry: usable by the app and WidgetKit's archived renderer.
struct PixelCat: Shape {
    private static let rows = [
        "000000000000000000000000",
        "000000000000000000000000",
        "000000000000000000000000",
        "000000000000000000000000",
        "000000000000110000110000",
        "000000000000110000110000",
        "001110000000111101110000",
        "001110000000111111111000",
        "001100000000111111111000",
        "001100000000111110111000",
        "001111100000111111111100",
        "001111111111111111111100",
        "001111111111111111111100",
        "000011111111111111111000",
        "000011111111111111111000",
        "000000111111111111000000",
        "000000111111111111000000",
        "000000111111111111000000",
        "000000011000000011000000",
        "000000011000000011000000",
        "000000011110000011110000",
        "000000000000000000000000",
        "000000000000000000000000",
        "000000000000000000000000"
    ]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let pixel = min(rect.width, rect.height) / 24
        let origin = CGPoint(x: rect.midX - 12 * pixel, y: rect.midY - 12 * pixel)
        for (y, row) in Self.rows.enumerated() {
            for (x, bit) in row.enumerated() where bit == "1" {
                path.addRect(CGRect(x: origin.x + CGFloat(x) * pixel,
                                    y: origin.y + CGFloat(y) * pixel,
                                    width: pixel, height: pixel))
            }
        }
        return path
    }
}
