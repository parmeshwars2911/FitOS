import SwiftUI

struct MeasurementEntryView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var recordedAt = Date()
    @State private var values: [BodyMetricKind: String] = [:]

    var body: some View {
        NavigationStack {
            Form {
                Section("When") {
                    DatePicker("Recorded", selection: $recordedAt, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Measurements") {
                    ForEach(BodyMetricKind.allCases, id: \.self) { kind in
                        HStack {
                            Label(kind.displayName, systemImage: kind.iconName)
                            Spacer()
                            TextField(kind.unit, text: binding(for: kind))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: 110)
                            Text(kind.unit)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section {
                    Text("Log only what you measured today. FitOS keeps each metric independently, so you do not need to measure everything every time.")
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
