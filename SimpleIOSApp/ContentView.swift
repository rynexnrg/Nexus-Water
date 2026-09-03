import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var model = WaterViewModel()
    @State private var showingSettings = false

    var body: some View {
        ZStack {
            WaterBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) { Text("NEXUS WATER").font(.caption.bold()).tracking(2).foregroundStyle(.cyan); Text("Good morning").font(.largeTitle.bold()) }
                        Spacer()
                        Button { showingSettings = true } label: { Image(systemName: "slider.horizontal.3").font(.title3).padding(12).background(.white.opacity(0.09), in: Circle()) }
                    }
                    MotivationCard(message: model.motivation)
                    HydrationCard(model: model)
                    HStack(spacing: 12) { QuickAddButton(amount: 250, model: model); QuickAddButton(amount: 350, model: model); QuickAddButton(amount: 500, model: model) }
                    StreakCard(model: model)
                    Text("Today’s rhythm").font(.title3.bold())
                    TimelineView(model: model)
                }.padding(.horizontal, 18).padding(.top, 14).padding(.bottom, 30)
            }.scrollIndicators(.hidden)
            if model.showCelebration { CelebrationOverlay() }
        }
        .sheet(isPresented: $showingSettings) { SettingsView(model: model) }
        .preferredColorScheme(.dark)
    }
}

struct MotivationCard: View { let message: String; var body: some View { HStack(spacing: 14) { Image(systemName: "sparkles").font(.title2).foregroundStyle(.cyan); Text(message).font(.headline).fixedSize(horizontal: false, vertical: true); Spacer() }.padding(18).background(.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 22)).overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.12))) } }

struct HydrationCard: View {
    @ObservedObject var model: WaterViewModel
    var body: some View {
        VStack(spacing: 20) {
            HStack { Text("DAILY HYDRATION").font(.caption.bold()).tracking(1.5).foregroundStyle(.secondary); Spacer(); Text("\(model.target / 1000, specifier: "%.1f") L goal").font(.caption).foregroundStyle(.secondary) }
            ZStack {
                Circle().stroke(.white.opacity(0.08), lineWidth: 18)
                Circle().trim(from: 0, to: model.progress).stroke(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing), style: StrokeStyle(lineWidth: 18, lineCap: .round)).rotationEffect(.degrees(-90)).animation(.easeOut, value: model.progress)
                VStack(spacing: 3) { Image(systemName: "drop.fill").foregroundStyle(.cyan); Text("\(model.consumed / 1000, specifier: "%.1f") L").font(.system(size: 38, weight: .bold, design: .rounded)); Text("\(Int(model.progress * 100))% complete").font(.caption).foregroundStyle(.secondary) }
            }.frame(height: 220)
            Text(model.progress >= 1 ? "Goal reached. Your cloud is glowing." : "A few calm sips can change your whole afternoon.").font(.subheadline).foregroundStyle(.secondary)
        }.padding(20).background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 26)).overlay(RoundedRectangle(cornerRadius: 26).stroke(.cyan.opacity(0.18)))
    }
}

struct QuickAddButton: View {
    let amount: Int
    @ObservedObject var model: WaterViewModel

    var body: some View {
        Button { model.add(amount) } label: {
            VStack(spacing: 7) {
                Image(systemName: "plus").font(.caption.bold())
                Text("\(amount) ml").font(.caption.bold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 15))
        }
    }
}

struct StreakCard: View {
    @ObservedObject var model: WaterViewModel

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: model.isFrozen ? "cloud.fill" : "cloud.sun.fill")
                .font(.system(size: 35))
                .foregroundStyle(model.isFrozen ? .gray : .cyan)
                .symbolEffect(.pulse, value: model.streak)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(model.streak) day Cloud Streak").font(.headline)
                Text(model.isFrozen ? "Frozen cloud · Joker available" : "Your consistency is building momentum")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if model.isFrozen {
                Button("Use Joker") { model.useJoker() }.font(.caption.bold()).buttonStyle(.borderedProminent)
            } else {
                Text("☁️").font(.title2)
            }
        }
        .padding(17)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
    }
}

struct TimelineView: View {
    @ObservedObject var model: WaterViewModel

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<6, id: \.self) { index in
                VStack(spacing: 8) {
                    Circle().fill(index < model.glassesToday ? .cyan : .white.opacity(0.12)).frame(width: 14, height: 14)
                    Text("\(index + 1)").font(.caption2).foregroundStyle(.secondary)
                }
                if index < 5 {
                    Rectangle().fill(index < model.glassesToday - 1 ? .cyan.opacity(0.65) : .white.opacity(0.1)).frame(height: 2).frame(maxWidth: .infinity)
                }
            }
        }
        .padding(18)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
    }
}

struct SettingsView: View {
    @ObservedObject var model: WaterViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily goal") {
                    Stepper("\(model.target / 1000, specifier: "%.1f") liters", value: $model.target, in: 1500...6000, step: 250)
                }
                Section {
                    Text("Your hydration data stays on this device. It can be synced later when a connected Apple Watch or internet connection is available.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Nexus Water")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }
}

final class WaterViewModel: ObservableObject {
    @Published var consumed: Int { didSet { save() } }; @Published var target: Int { didSet { save() } }; @Published var streak: Int { didSet { save() } }; @Published var isFrozen = false; @Published var glassesToday = 0; @Published var showCelebration = false
    private let defaults = UserDefaults.standard; private let dateKey = "nexus.water.date"
    private let messages = ["A fresh sip for your focus.", "Halfway there. Let the day flow.", "Small sips, clear momentum.", "Your body says thank you."]
    var progress: Double { min(Double(consumed) / Double(target), 1) }; var motivation: String { messages[min(glassesToday, messages.count - 1)] }
    init() { consumed = defaults.integer(forKey: "nexus.water.consumed"); target = defaults.object(forKey: "nexus.water.target") as? Int ?? 3000; streak = defaults.integer(forKey: "nexus.water.streak"); let today = Calendar.current.dateStamp; if defaults.string(forKey: dateKey) != today { consumed = 0; glassesToday = 0; defaults.set(today, forKey: dateKey) }; if let completed = defaults.string(forKey: "nexus.water.completedDate"), completed != today { isFrozen = completed != Calendar.current.previousDateStamp } }
    func add(_ amount: Int) { consumed += amount; glassesToday += 1; if progress >= 1 { completeToday() } }
    func useJoker() { let month = Calendar.current.monthStamp; guard isFrozen, defaults.string(forKey: "nexus.water.jokerMonth") != month else { return }; isFrozen = false; defaults.set(month, forKey: "nexus.water.jokerMonth") }
    private func save() { defaults.set(consumed, forKey: "nexus.water.consumed"); defaults.set(target, forKey: "nexus.water.target"); defaults.set(streak, forKey: "nexus.water.streak") }
    private func completeToday() { let stamp = Calendar.current.dateStamp; guard defaults.string(forKey: "nexus.water.completedDate") != stamp else { return }; streak = max(streak + 1, 1); isFrozen = false; defaults.set(stamp, forKey: "nexus.water.completedDate"); showCelebration = true; UIImpactFeedbackGenerator(style: .medium).impactOccurred(); DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { self.showCelebration = false } }
}

extension Calendar { var dateStamp: String { formatted(Date(), date: .numeric, time: .omitted) } }
extension Calendar { var previousDateStamp: String { formatted(date(byAdding: .day, value: -1, to: Date()) ?? Date(), date: .numeric, time: .omitted) }; var monthStamp: String { formatted(Date(), date: .numeric, time: .omitted).prefix(7).description } }
struct WaterBackground: View { var body: some View { LinearGradient(colors: [Color(red: 0.02, green: 0.10, blue: 0.18), Color(red: 0.01, green: 0.03, blue: 0.08)], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea() } }
struct CelebrationOverlay: View { var body: some View { VStack(spacing: 10) { Image(systemName: "cloud.sun.fill").font(.system(size: 52)).foregroundStyle(.cyan).symbolEffect(.bounce); Text("Cloud Streak extended").font(.headline); Text("100% hydrated today").font(.caption).foregroundStyle(.secondary) }.padding(25).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24)).overlay(RoundedRectangle(cornerRadius: 24).stroke(.cyan.opacity(0.35))).transition(.scale.combined(with: .opacity)) } }
