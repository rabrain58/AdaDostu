import SwiftUI
import ActivityKit

struct ContentView: View {
    @StateObject private var controller = PetController()
    @Environment(\.scenePhase) private var scenePhase
    @State private var color: PetColor = .amber
    @State private var animated = false
    @State private var previewStart = Date()
    private let ink = Color(red: 0.055, green: 0.07, blue: 0.08)

    private var previewAttributes: PetAttributes {
        controller.current?.attributes ?? PetAttributes(
            startedAt: previewStart, endsAt: previewStart.addingTimeInterval(28800),
            colorName: color.rawValue, animated: animated
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                HStack {
                    Label("ADADOSTU", systemImage: "pawprint.fill")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .tracking(2)
                        .foregroundStyle(color.color)
                    Spacer()
                    Text("0.1.1")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 18)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Küçük bir dost.\nHep yakınında.")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Piksel kedine adada bir yer aç.")
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 26) {
                    Text("ADA ÖNİZLEMESİ")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .tracking(2)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 22) {
                        IslandCat(attributes: previewAttributes, size: 28)
                        Capsule().fill(Color(white: 0.035)).frame(width: 74, height: 22)
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(color.color)
                    }
                    .padding(.horizontal, 18)
                    .frame(height: 52)
                    .background(.black, in: Capsule())
                    .overlay(Capsule().stroke(.white.opacity(0.08), lineWidth: 1))
                    .accessibilityLabel("Dinamik Ada örnek görünümü")
                    VStack(spacing: 5) {
                        Text("Mırmır").font(.title2.bold())
                        Text(controller.running ? "Adada bir dostun var." : "Adasına taşınmaya hazır.")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 28))

                VStack(alignment: .leading, spacing: 16) {
                    Text("Bir renk seç").font(.headline)
                    HStack(spacing: 12) {
                        ForEach(PetColor.allCases) { item in
                            Button {
                                color = item
                            } label: {
                                VStack(spacing: 10) {
                                    StillCat(size: 40).foregroundStyle(item.color)
                                    Text(item.title).font(.subheadline.weight(.medium))
                                    Image(systemName: color == item ? "checkmark.circle.fill" : "circle")
                                        .font(.caption)
                                        .foregroundStyle(color == item ? item.color : .secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(color == item ? item.color.opacity(0.10) : .white.opacity(0.035),
                                            in: RoundedRectangle(cornerRadius: 20))
                                .overlay(RoundedRectangle(cornerRadius: 20)
                                    .stroke(color == item ? item.color.opacity(0.6) : .clear, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(item.title + (color == item ? ", seçili" : ""))
                        }
                    }
                    Toggle(isOn: $animated) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Minik adımlar").font(.subheadline.bold())
                            Text("Deneysel, saniyelik piksel hareketi")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .tint(color.color)
                    .padding(.top, 4)
                }
                .disabled(controller.running || controller.busy)

                Button {
                    Task {
                        if controller.running { await controller.stop() }
                        else { await controller.start(color: color, animated: animated) }
                    }
                } label: {
                    HStack(spacing: 10) {
                        if controller.busy { ProgressView().tint(ink) }
                        else { Image(systemName: controller.running ? "stop.fill" : "pawprint.fill") }
                        Text(controller.running ? "Adadan al" : "Adaya gönder").fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 19)
                    .foregroundStyle(ink)
                    .background(color.color, in: RoundedRectangle(cornerRadius: 20))
                }
                .disabled(controller.busy)

                Text(controller.running
                     ? "Ana ekrana dönüp adaya bak. Görünümü büyütmek için adaya basılı tut. Rengini değiştirmek için önce kediyi adadan al."
                     : "Hareket, iOS'un izin verdiği sıklıkta gösterilir. Ekran kararınca durabilir. Oturum en fazla 8 saat sürer; sonra yeniden başlatabilirsin.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 26)
            .padding(.bottom, 32)
        }
        .background(ink.ignoresSafeArea())
        .task {
            sync()
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--smoke-static") ||
                ProcessInfo.processInfo.arguments.contains("--smoke-animated") {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await controller.stop()
                animated = ProcessInfo.processInfo.arguments.contains("--smoke-animated")
                await controller.start(color: .amber, animated: animated)
            }
            #endif
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { sync() }
        }
        .onOpenURL { _ in sync() }
        .alert("Başlatılamadı", isPresented: Binding(
            get: { controller.errorMessage != nil },
            set: { if !$0 { controller.errorMessage = nil } }
        )) {
            Button("Tamam", role: .cancel) { controller.errorMessage = nil }
        } message: {
            Text(controller.errorMessage ?? "")
        }
    }

    private func sync() {
        controller.refresh()
        if let attributes = controller.current?.attributes {
            color = PetColor(rawValue: attributes.colorName) ?? .amber
            animated = attributes.animated
        }
    }
}
