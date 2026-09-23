import ActivityKit
import SwiftUI
import WidgetKit

@main
struct PetWidgetBundle: WidgetBundle {
    var body: some Widget { PetLiveActivity() }
}

struct PetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PetAttributes.self) { context in
            HStack(spacing: 16) {
                IslandCat(attributes: context.attributes, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text("AdaDostu").font(.headline)
                    Text(context.state.message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding(20)
            .activityBackgroundTint(Color(red: 0.08, green: 0.10, blue: 0.12))
            .activitySystemActionForegroundColor(.white)
            .widgetURL(URL(string: "adadostu://pet"))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    IslandCat(attributes: context.attributes, size: 48)
                        .padding(.top, 4)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Küçük bir dost, hemen yanında.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 6)
                }
            } compactLeading: {
                IslandCat(attributes: context.attributes, size: 24)
            } compactTrailing: {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 10))
                    .foregroundStyle((PetColor(rawValue: context.attributes.colorName) ?? .amber).color)
                    .accessibilityHidden(true)
            } minimal: {
                IslandCat(attributes: context.attributes, size: 22)
            }
            .widgetURL(URL(string: "adadostu://pet"))
            .keylineTint((PetColor(rawValue: context.attributes.colorName) ?? .amber).color)
        }
    }
}
