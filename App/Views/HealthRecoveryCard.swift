import SwiftUI

struct HealthRecoveryCard: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        if store.healthKitAvailable {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Apple Health", systemImage: "heart.fill")
                        .font(.headline)
                    Spacer()
                    if store.isHealthSyncing {
                        ProgressView()
                            .controlSize(.small)
                    }
                }

                if store.healthKitEnabled {
                    if let snapshot = store.recoverySnapshot {
                        HStack(spacing: 10) {
                            signal("Sleep", value: formatted(snapshot.recentSleepHours, decimals: 1, unit: "h"))
                            signal("Resting HR", value: formatted(snapshot.restingHeartRateBPM, decimals: 0, unit: "bpm"))
                            signal("HRV", value: formatted(snapshot.heartRateVariabilityMS, decimals: 0, unit: "ms"))
                        }
                    } else {
                        Text("Connected. Sync to bring recent recovery and body measurements into FitOS.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        Task { await store.syncHealthKit() }
                    } label: {
                        Label("Sync Apple Health", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)
                    .disabled(store.isHealthSyncing)
                } else {
                    Text("Import body weight, body fat, waist, sleep, resting heart rate and HRV. FitOS requests read-only access and keeps manual logging available.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button {
                        Task { await store.connectHealthKit() }
                    } label: {
                        Label("Connect Apple Health", systemImage: "heart.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                }

                if let error = store.healthKitError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .padding(14)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private func signal(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(9)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
    }

    private func formatted(_ value: Double?, decimals: Int, unit: String) -> String {
        guard let value else { return "—" }
        return String(format: "%.*f %@", decimals, value, unit)
    }
}
