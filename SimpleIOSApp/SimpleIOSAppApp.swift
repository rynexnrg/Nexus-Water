import SwiftUI

@main
struct NexusWaterApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                WaterBackground()
                ContentView()
                if showSplash { WaterSplashView().transition(.opacity) }
            }
            .ignoresSafeArea()
            .task {
                try? await Task.sleep(for: .seconds(1.8))
                withAnimation(.easeOut(duration: 0.45)) { showSplash = false }
            }
        }
    }
}

struct WaterSplashView: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            WaterBackground()
            VStack(spacing: 18) {
                ZStack {
                    Circle().stroke(.cyan.opacity(0.25), lineWidth: 1).frame(width: 118, height: 118).scaleEffect(pulse ? 1.18 : 0.9).opacity(pulse ? 0 : 1)
                    Image(systemName: "drop.fill").font(.system(size: 48)).foregroundStyle(.cyan)
                }
                Text("NEXUS WATER").font(.title2.weight(.bold)).tracking(5)
                Text("Small sips. Clear days.").font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .task { withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) { pulse = true } }
    }
}
