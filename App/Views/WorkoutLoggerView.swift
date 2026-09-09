import SwiftUI

struct WorkoutLoggerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppStore

    @State private var drafts: [ExerciseDraft]
    @State private var showingExercisePicker = false

    init(plan: GeneratedWorkout?, catalog: [ExerciseDefinition]) {
        let initialDrafts: [ExerciseDraft]
        if let plan, !plan.exercises.isEmpty {
            initialDrafts = plan.exercises.map {
                ExerciseDraft(
                    exercise: $0.exercise,
                    setCount: $0.sets,
                    defaultReps: $0.repRange.lowerBound
                )
            }
        } else {
            initialDrafts = []
        }
        _drafts = State(initialValue: initialDrafts)
    }

    var body: some View {
        NavigationStack {
            List {
                if drafts.isEmpty {
                    ContentUnavailableView(
                        "No exercises yet",
                        systemImage: "dumbbell",
                        description: Text("Add an exercise and log what you actually perform.")
                    )
                }

                ForEach($drafts) { $draft in
                    Section {
                        ExerciseDraftEditor(draft: $draft)
                    } header: {
                        Text(draft.exercise.name)
                    }
                }
                .onDelete { offsets in
                    drafts.remove(atOffsets: offsets)
                }

                Button {
                    showingExercisePicker = true
                } label: {
                    Label("Add Exercise", systemImage: "plus.circle.fill")
                }
            }
            .navigationTitle("Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Finish") { finishWorkout() }
                        .disabled(drafts.isEmpty)
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView(catalog: store.catalog) { exercise in
                    drafts.append(ExerciseDraft(exercise: exercise))
                    showingExercisePicker = false
                }
            }
        }
    }

    private func finishWorkout() {
        let exercises = drafts.compactMap { draft -> CompletedExercise? in
            let sets = draft.sets
                .filter { $0.reps > 0 }
                .map { CompletedSet(reps: $0.reps, loadKg: max(0, $0.loadKg), rir: max(0, $0.rir)) }
            guard !sets.isEmpty else { return nil }
            return CompletedExercise(exercise: draft.exercise, sets: sets)
        }

        guard !exercises.isEmpty else { return }
        store.complete(WorkoutSession(completedAt: Date(), exercises: exercises))
        dismiss()
    }
}

private struct ExerciseDraftEditor: View {
    @Binding var draft: ExerciseDraft

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("SET")
                Spacer()
                Text("KG")
                    .frame(width: 72)
                Text("REPS")
                    .frame(width: 58)
                Text("RIR")
                    .frame(width: 52)
            }
            .font(.caption2.bold())
            .foregroundStyle(.secondary)

            ForEach($draft.sets) { $set in
                HStack {
                    Text("\(draft.sets.firstIndex(where: { $0.id == set.id }).map { $0 + 1 } ?? 1)")
                        .font(.caption.monospacedDigit())
                    Spacer()
                    TextField("0", value: $set.loadKg, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 72)
                    TextField("10", value: $set.reps, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 58)
                    TextField("2", value: $set.rir, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 52)
                }
            }

            HStack {
                Button {
                    draft.sets.append(SetDraft())
                } label: {
                    Label("Add set", systemImage: "plus")
                }
                .buttonStyle(.borderless)

                Spacer()

                if draft.sets.count > 1 {
                    Button(role: .destructive) {
                        draft.sets.removeLast()
                    } label: {
                        Label("Remove", systemImage: "minus")
                    }
                    .buttonStyle(.borderless)
                }
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

private struct ExercisePickerView: View {
    let catalog: [ExerciseDefinition]
    let onSelect: (ExerciseDefinition) -> Void

    var body: some View {
        NavigationStack {
            List(catalog) { exercise in
                Button {
                    onSelect(exercise)
                } label: {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(exercise.name)
                        Text(exercise.muscles.map { $0.muscle.displayName }.joined(separator: " · "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Exercises")
        }
    }
}
