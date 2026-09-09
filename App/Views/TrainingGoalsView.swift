import SwiftUI

struct TrainingGoalsView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("These are rolling 7-day effective-set targets. Changing a target immediately changes FitOS training debt and the next generated workout.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Muscle targets") {
                    ForEach(store.targets, id: \.muscle) { target in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(target.muscle.displayName)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(target.effectiveSetsPer7Days, specifier: "%.0f") sets / 7d")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Stepper(
                                "Weekly sets",
                                value: weeklySetsBinding(for: target.muscle),
                                in: 0...30,
                                step: 1
                            )
                            .labelsHidden()

                            Toggle(
                                "Priority muscle",
                                isOn: priorityBinding(for: target.muscle)
                            )
                            .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section {
                    Button("Reset default targets", role: .destructive) {
                        store.resetTargets()
                    }
                }
            }
            .navigationTitle("Training Goals")
        }
    }

    private func weeklySetsBinding(for muscle: MuscleGroup) -> Binding<Double> {
        Binding(
            get: {
                store.targets.first(where: { $0.muscle == muscle })?.effectiveSetsPer7Days ?? 0
            },
            set: { value in
                store.updateTarget(for: muscle, weeklySets: value)
            }
        )
    }

    private func priorityBinding(for muscle: MuscleGroup) -> Binding<Bool> {
        Binding(
            get: {
                (store.targets.first(where: { $0.muscle == muscle })?.goalPriority ?? 1) >= 1.2
            },
            set: { enabled in
                store.updateTarget(for: muscle, goalPriority: enabled ? 1.3 : 1.0)
            }
        )
    }
}
