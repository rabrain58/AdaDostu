import ActivityKit
import SwiftUI

@MainActor
final class PetController: ObservableObject {
    @Published private(set) var current: Activity<PetAttributes>?
    @Published private(set) var busy = false
    @Published var errorMessage: String?
    private var observation: Task<Void, Never>?

    var running: Bool { current != nil }
    var available: Bool { ActivityAuthorizationInfo().areActivitiesEnabled }

    func refresh() {
        let found = Activity<PetAttributes>.activities.first {
            ($0.activityState == .active || $0.activityState == .stale)
        }
        let changed = current?.id != found?.id
        current = found
        if changed {
            observation?.cancel()
            if let found {
                observation = Task { [weak self] in
                    for await state in found.activityStateUpdates {
                        guard !Task.isCancelled else { return }
                        if state == .ended || state == .dismissed {
                            self?.refresh()
                            return
                        }
                    }
                }
            }
        }
    }

    func start(color: PetColor, animated: Bool) async {
        guard !busy else { return }
        refresh()
        guard current == nil else { return }
        let plugins = Bundle.main.builtInPlugInsURL.flatMap {
            try? FileManager.default.contentsOfDirectory(at: $0, includingPropertiesForKeys: nil)
        } ?? []
        guard plugins.contains(where: { $0.pathExtension == "appex" }) else {
            errorMessage = "Dinamik Ada bileşeni kurulumda eksik. Sideloadly'de uzantıları kaldırma seçeneğini kapatıp yeniden yükle."
            return
        }
        guard available else {
            errorMessage = "Canlı Etkinlikler kapalı. Ayarlar > Uygulamalar > AdaDostu bölümünden izin verip yeniden dene."
            return
        }
        busy = true
        defer { busy = false }
        let now = Date()
        let end = now.addingTimeInterval(8 * 60 * 60)
        let attributes = PetAttributes(startedAt: now, endsAt: end,
                                       colorName: color.rawValue, animated: animated)
        do {
            _ = try Activity.request(
                attributes: attributes,
                content: ActivityContent(
                    state: PetAttributes.ContentState(message: "Küçük bir dost, hemen yanında."),
                    staleDate: end
                ),
                pushType: nil
            )
            refresh()
        } catch {
            errorMessage = "Kedi başlatılamadı: \(error.localizedDescription)"
        }
    }

    func stop() async {
        guard !busy else { return }
        busy = true
        defer { busy = false }
        for activity in Activity<PetAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        refresh()
    }

    deinit { observation?.cancel() }
}
