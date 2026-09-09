import SwiftUI

struct MeasurementEntryView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var recordedAt = Date()
    @State private var values: [BodyMetricKind: String] = [:]
    @State private var guidedKind: BodyMetricKind = .waistCm
    @State private var showingGuide = false

    var body: some View {
        NavigationStack {
            Form {
                Section("When") {
                    DatePicker("Recorded", selection: $recordedAt, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Measurements") {
                    ForEach(BodyMetricKind.allCases, id: \.self) { kind in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Label(kind.displayName, systemImage: kind.iconName)
                                Spacer()
                                TextField(kind.unit, text: binding(for: kind))
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: 95)
                                Text(kind.unit)
                                    .foregroundStyle(.secondary)
                            }

                            Button {
                                guidedKind = kind
                                showingGuide = true
                            } label: {
                                Label("Measurement guide", systemImage: "ruler")
                                    .font(.caption)
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(.vertical, 2)
                    }
                }

                Section("Measurement quality") {
                    Text("For tape measurements, use the guide and repeat the placement. FitOS saves one robust result from the repeated readings, then the Progress screen smooths observations across days.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Log body data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.logMeasurements(parsedValues, at: recordedAt)
                        dismiss()
                    }
                    .disabled(parsedValues.isEmpty)
                }
            }
            .sheet(isPresented: $showingGuide) {
                MeasurementGuideView(kind: guidedKind) { result in
                    values[guidedKind] = String(format: "%.1f", result)
                    showingGuide = false
                }
            }
        }
    }

    private func binding(for kind: BodyMetricKind) -> Binding<String> {
        Binding(
            get: { values[kind] ?? "" },
            set: { values[kind] = $0 }
        )
    }

    private var parsedValues: [BodyMetricKind: Double] {
        var result: [BodyMetricKind: Double] = [:]
        for (kind, text) in values {
            let normalized = text.replacingOccurrences(of: ",", with: ".")
            if let value = Double(normalized), value > 0, value.isFinite {
                result[kind] = value
            }
        }
        return result
    }
}

private struct MeasurementGuideView: View {
    @Environment(\.dismiss) private var dismiss

    let kind: BodyMetricKind
    let onUse: (Double) -> Void

    @State private var readings: [String]

    private let repeatEngine = RepeatMeasurementEngine()

    init(kind: BodyMetricKind, onUse: @escaping (Double) -> Void) {
        self.kind = kind
        self.onUse = onUse
        let count = RepeatMeasurementEngine().recommendedRepeatCount(for: kind)
        _readings = State(initialValue: Array(repeating: "", count: count))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(protocolDefinition.summary)
                        .font(.subheadline)
                    ForEach(Array(protocolDefinition.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(index + 1)")
                                .font(.caption.bold())
                                .frame(width: 20, height: 20)
                                .background(.quaternary, in: Circle())
                            Text(step)
                                .font(.callout)
                        }
                    }
                } header: {
                    Text("Protocol")
                }

                Section("Readings") {
                    ForEach(readings.indices, id: \.self) { index in
                        HStack {
                            Text("Reading \(index + 1)")
                            Spacer()
                            TextField(kind.unit, text: $readings[index])
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: 100)
                            Text(kind.unit)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let result = aggregate {
                        LabeledContent("FitOS result") {
                            Text("\(result, specifier: "%.1f") \(kind.unit)")
                                .fontWeight(.semibold)
                        }
                        Text(aggregationExplanation)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(kind.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Use Result") {
                        guard let aggregate else { return }
                        onUse(aggregate)
                    }
                    .disabled(aggregate == nil)
                }
            }
        }
    }

    private var protocolDefinition: BodyMeasurementProtocol {
        MeasurementProtocols.protocolFor(kind)
    }

    private var parsedReadings: [Double] {
        readings.compactMap { text in
            let normalized = text.replacingOccurrences(of: ",", with: ".")
            guard let value = Double(normalized), value.isFinite, value > 0 else { return nil }
            return value
        }
    }

    private var aggregate: Double? {
        let values = parsedReadings
        guard values.count == readings.count else { return nil }
        return repeatEngine.aggregate(kind: kind, readings: values)
    }

    private var aggregationExplanation: String {
        switch kind {
        case .weightKg, .heightCm:
            return "FitOS uses the mean of these repeated readings."
        case .bodyFatPercent, .waistCm, .chestCm, .bicepsCm, .thighCm:
            return "FitOS uses the median so one awkward placement has less influence."
        }
    }
}
