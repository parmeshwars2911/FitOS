import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var store: AppStore
    @State private var durationMinutes = 60
    @State private var equipmentPreset: EquipmentPreset = .fullGym
    @State private var showingLogger = false

    private var priorityMuscles: [MuscleState] { Array(store.trainingState.muscles.prefix(6)) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    HealthRecoveryCard()
                    WeeklyReviewCard()
                    trainingStateSection
                    generatorSection
                    generatedWorkoutSection
                }
                .padding()
            }
            .navigationTitle("FitOS")
            .sheet(isPresented: $showingLogger) {
                WorkoutLoggerView(plan: store.generatedWorkout, catalog: store.catalog)
                    .environmentObject(store)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Train what needs attention.").font(.title2.bold())
            Text("FitOS uses what you actually completed—not the workout you intended to do.")
                .font(.subheadline).foregroundStyle(.secondary)
        }
    }

    private var trainingStateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Training state").font(.headline)
            ForEach(priorityMuscles, id: \.muscle) { state in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(state.muscle.displayName).fontWeight(.semibold)
                        Spacer()
                        Text("\(state.effectiveSets, specifier: "%.1f") / \(state.targetSets, specifier: "%.0f") sets")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    ProgressView(value: state.completionRatio)
                    HStack {
                        Text("Debt \(state.deficitSets, specifier: "%.1f")")
                        Spacer()
                        Text("Recovery \(Int(state.recovery * 100))%")
                    }
                    .font(.caption2).foregroundStyle(.secondary)
                }
                .padding(12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private var generatorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's constraints").font(.headline)

            Picker("Duration", selection: $durationMinutes) {
                Text("35 min").tag(35)
                Text("45 min").tag(45)
                Text("60 min").tag(60)
                Text("75 min").tag(75)
            }
            .pickerStyle(.segmented)

            HStack {
                Label("Equipment", systemImage: "dumbbell")
                Spacer()
                Picker("Equipment", selection: $equipmentPreset) {
                    ForEach(EquipmentPreset.allCases) { preset in
                        Text(preset.title).tag(preset)
                    }
                }
                .pickerStyle(.menu)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))

            Button {
                store.generateWorkout(
                    durationMinutes: durationMinutes,
                    availableEquipment: equipmentPreset.equipment
                )
            } label: {
                Label("Build Today's Workout", systemImage: "wand.and.stars")
                    .frame(maxWidth: .infinity).padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    @ViewBuilder
    private var generatedWorkoutSection: some View {
        if let workout = store.generatedWorkout {
            if workout.exercises.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("No session fits these constraints", systemImage: "exclamationmark.triangle")
                        .font(.headline)
                    Text("Try a broader equipment preset or a longer session. FitOS will not recommend unavailable equipment just to fill the workout.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 14))
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recommended session").font(.headline)
                        Spacer()
                        Text("~\(workout.estimatedMinutes) min").font(.subheadline).foregroundStyle(.secondary)
                    }
                    ForEach(workout.exercises, id: \.exercise.id) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.exercise.name).fontWeight(.semibold)
                                Spacer()
                                Text(item.exercise.equipment.capitalized)
                                    .font(.caption2).foregroundStyle(.secondary)
                            }
                            if let load = item.suggestedLoadKg {
                                Text("\(item.sets) sets · \(item.repRange.lowerBound)–\(item.repRange.upperBound) reps · ~\(load, specifier: "%.1f") kg").font(.subheadline)
                            } else {
                                Text("\(item.sets) sets · \(item.repRange.lowerBound)–\(item.repRange.upperBound) reps").font(.subheadline)
                            }
                            if let progressionNote = item.progressionNote {
                                Text(progressionNote).font(.caption).foregroundStyle(.secondary)
                            }
                            Text(item.reason).font(.caption).foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                    }
                    Button { showingLogger = true } label: {
                        Label("Start Workout", systemImage: "play.fill")
                            .frame(maxWidth: .infinity).padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}
