import ActivityKit
import Foundation
import SwiftUI

struct PetAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var message: String
    }
    var startedAt: Date
    var endsAt: Date
    var colorName: String
    var animated: Bool
}

enum PetColor: String, CaseIterable, Identifiable {
    case amber, cloud, mint
    var id: String { rawValue }
    var title: String {
        switch self {
        case .amber: return "Bal"
        case .cloud: return "Bulut"
        case .mint: return "Nane"
        }
    }
    var color: Color {
        switch self {
        case .amber: return Color(red: 1, green: 0.73, blue: 0.40)
        case .cloud: return Color(red: 0.90, green: 0.93, blue: 1)
        case .mint: return Color(red: 0.57, green: 0.89, blue: 0.74)
        }
    }
}
