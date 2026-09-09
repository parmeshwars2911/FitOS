import Charts
import SwiftUI

struct BodyProgressView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showingEntry = false

    private let featuredMetrics: [BodyMetricKind] = [
        .weightKg, .waistCm, .bodyFatPercent, .bicepsCm, .chestCm, .thighCm
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    latestGrid
                    trendSections
                }
                .padding()
            }
            .navigationTitle("Progress")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingEntry = true
                    } label: {
                        Label("Log", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingEntry) {
                MeasurementEntryView()
                    .environmentObject(store)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Measure trends, not noise.")
                .font(.title2.bold())
            Text("FitOS stores each body metric independently and uses repeated observations to make progress easier to judge.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var latestGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(featuredMetrics, id: \.self) { kind in
                metricCard(kind)
            }
        }
    }

    private func metricCard(_ kind: BodyMetricKind) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(kind.displayName, systemImage: kind.iconName)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let latest = store.latestMeasurement(for: kind) {
                Text("\(latest.value, specifier: "%.1f") \(kind.unit)")
                    .font(.title3.bold())

                if let delta = store.trend(for: kind)?.deltaFromPrevious {
                    Text("\(delta >= 0 ? "+" : "")\(delta, specifier: "%.1f") since last")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("First observation")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if kind == .weightKg, let sevenDay = store.trend(for: .weightKg, windowDays: 7), sevenDay.observationCount > 1 {
                    Text("7-day avg \(sevenDay.averageValue, specifier: "%.1f") kg")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("No data")
                    .font(.title3.bold())
                Text("Tap + to log")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 105, alignment: .topLeading)
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private var trendSections: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Recent trends")
                .font(.headline)

            ForEach(featuredMetrics, id: \.self) { kind in
                let observations = recentMeasurements(for: kind)
                if !observations.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(kind.displayName)
                                .fontWeight(.semibold)
                            Spacer()
                            Text(kind.unit)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Chart(observations) { measurement in
                            LineMark(
                                x: .value("Date", measurement.recordedAt),
                                y: .value(kind.displayName, measurement.value)
                            )
                            PointMark(
                                x: .value("Date", measurement.recordedAt),
                                y: .value(kind.displayName, measurement.value)
                            )
                        }
                        .chartXAxis(.hidden)
                        .frame(height: 110)
                    }
                    .padding(12)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    private func recentMeasurements(for kind: BodyMetricKind) -> [BodyMeasurement] {
        Array(
            store.measurements
                .filter { $0.kind == kind }
                .sorted { $0.recordedAt < $1.recordedAt }
                .suffix(12)
        )
    }
}
