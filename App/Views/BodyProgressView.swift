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
            Text("Weight is smoothed with a rolling mean. Tape and body-fat measurements use a rolling median so one unusual reading does not become a coaching signal.")
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
        VStack(alignment: .leading, spacing: 7) {
            Label(kind.displayName, systemImage: kind.iconName)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let trend = store.trend(for: kind) {
                Text("\(trend.smoothedValue, specifier: "%.1f") \(kind.unit)")
                    .font(.title3.bold())

                Text("Trend · \(confidenceLabel(trend.confidence)) confidence")
                    .font(.caption2.bold())

                if trend.observationCount > 1 {
                    Text("Latest raw \(trend.latestValue, specifier: "%.1f") \(kind.unit)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if let delta = trend.smoothedDelta {
                    Text("\(delta >= 0 ? "+" : "")\(delta, specifier: "%.1f") vs prior signal")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("More observations needed")
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
        .frame(maxWidth: .infinity, minHeight: 122, alignment: .topLeading)
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private var trendSections: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Recent trends")
                .font(.headline)

            ForEach(featuredMetrics, id: \.self) { kind in
                let points = trendPoints(for: kind)
                if !points.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(kind.displayName)
                                .fontWeight(.semibold)
                            Spacer()
                            if let trend = store.trend(for: kind) {
                                Text("\(confidenceLabel(trend.confidence)) confidence")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Chart(points) { point in
                            PointMark(
                                x: .value("Date", point.recordedAt),
                                y: .value("Raw", point.rawValue)
                            )
                            LineMark(
                                x: .value("Date", point.recordedAt),
                                y: .value("Trend", point.smoothedValue)
                            )
                        }
                        .chartXAxis(.hidden)
                        .frame(height: 120)

                        Text("Points show raw readings; the line is the signal FitOS uses for trend decisions.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    private func trendPoints(for kind: BodyMetricKind) -> [BodyTrendPoint] {
        BodyTrendEngine().smoothedSeries(
            for: kind,
            measurements: store.measurements,
            maxPoints: 12
        )
    }

    private func confidenceLabel(_ confidence: BodyTrendConfidence) -> String {
        switch confidence {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}
