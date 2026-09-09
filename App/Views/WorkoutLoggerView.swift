import SwiftUI

struct WorkoutLoggerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppStore

    @State private var drafts: [ExerciseDraft]
    @State private var showingExercisePicker = false
    @State private var replacementDraftID: UUID?
    @State private var restSeconds = 120
    @State private var restEndDate: Date?

    private let plannedExerciseIDs: [String]

    init(plan: GeneratedWorkout?, catalog: [ExerciseDefinition]) {
        let initialDrafts: [ExerciseDraft]
        if let plan, !plan.exercises.isEmpty {
            initialDrafts = plan.exercises.map {
                ExerciseDraft(
                    exercise: $0.exercise,
                    plannedExerciseID: $0.exercise.id,
                    setCount: $0.sets,
                    defaultReps: $0.repRange.lowerBound
                )
            }
            plannedExerciseIDs = plan.exercises.map(\.exercise.id)
        } else {
            initialDrafts = []
            plannedExerciseIDs = []
        }
        _drafts = State(initialValue: initialDrafts)
    }

    var body: some View {
        NavigationStack {
            List {
                restTimerSection

                if drafts.isEmpty {
                    ContentUnavailableView(
                        "No exercises yet",
                        systemImage: "dumbbell",
                        description: Text("Add an exercise and log what you actually perform.")
                    )
                }

                ForEach($drafts) { $draft in
                    Section {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(draft.exercise.name)
                                    .font(.headline)
                                if draft.plannedExerciseID != nil {
                                    Text(draft.exercise.id == draft.plannedExerciseID ? "FitOS recommendation" : "Replacement")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Menu {
                                Button {
                                    replacementDraftID = draft.id
                                    showingExercisePicker = true
                                } label: {
                                    Label("Replace exercise", systemImage: "arrow.triangle.2.circlepath")
                                }

                                Button(role: .destructive) {
                                    drafts.removeAll { $0.id == draft.id }
                                } label: {
                                    Label("Skip exercise", systemImage: "forward.end")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.title3)
                            }
                        }

                        if let previous = store.previousPerformance(for: draft.exercise.id) {
                            Text("Previous · \(previous.completedAt.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                        }

                        ExerciseDraftEditor(
                            draft: $draft,
                            previous: store.previousPerformance(for: draft.exercise.id)?.exercise,
                            onSetCompleted: startRestTimer
                        )
                    }
                }
                .onDelete { offsets in
                    drafts.remove(atOffsets: offsets)
                }

                Button {
                    replacementDraftID = nil
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
            .sheet(isPresented: $showingExercisePicker, onDismiss: {
                replacementDraftID = nil
            }) {
                ExercisePickerView(
                    catalog: store.catalog,
                    title: replacementDraftID == nil ? "Add Exercise" : "Replace Exercise"
                ) { exercise in
                    if let replacementDraftID,
                       let index = drafts.firstIndex(where: { $0.id == replacementDraftID }) {
                        drafts[index].exercise = exercise
                    } else {
                        drafts.append(ExerciseDraft(exercise: exercise))
                    }
                    showingExercisePicker = false
                }
            }
        }
    }

    private var restTimerSection: some View {
        Section("Rest timer") {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Recovery between sets")
                        .font(.subheadline.weight(.semibold))
                    if let restEndDate {
                        TimelineView(.periodic(from: .now, by: 1)) { context in
                            let remaining = max(0, Int(ceil(restEndDate.timeIntervalSince(context.date))))
                            Text(remaining > 0 ? formattedDuration(remaining) : "Ready for the next set")
                                .font(.title3.monospacedDigit().weight(.semibold))
                                .foregroundStyle(remaining > 0 ? Color.primary : Color.green)
                        }
                    } else {
                        Text("Ready")
                            .font(.title3.weight(.semibold))
                    }
                }

                Spacer()

                Picker("Rest duration", selection: $restSeconds) {
                    Text("60s").tag(60)
                    Text("90s").tag(90)
                    Text("2m").tag(120)
                    Text("3m").tag(180)
                }
                .pickerStyle(.menu)
            }

            HStack {
                Button {
                    startRestTimer()
                } label: {
                    Label("Start rest", systemImage: "timer")
                }

                if restEndDate != nil {
                    Spacer()
                    Button("Cancel", role: .cancel) {
                        restEndDate = nil
                    }
                }
            }
        }
    }

    private func startRestTimer() {
        restEndDate = Date().addingTimeInterval(TimeInterval(restSeconds))
    }

    private func formattedDuration(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    private func finishWorkout() {
        var completedExercises: [CompletedExercise] = []
        var outcomes: [WorkoutPlanOutcome] = []

        for draft in drafts {
            let sets = draft.sets
                .filter { $0.reps > 0 }
                .map { CompletedSet(reps: $0.reps, loadKg: max(0, $0.loadKg), rir: max(0, $0.rir)) }
            guard !sets.isEmpty else { continue }

            completedExercises.append(CompletedExercise(exercise: draft.exercise, sets: sets))
            outcomes.append(
                WorkoutPlanOutcome(
                    plannedExerciseID: draft.plannedExerciseID,
                    completedExerciseID: draft.exercise.id
                )
            )
        }

        guard !completedExercises.isEmpty else { return }
        let session = WorkoutSession(completedAt: Date(), exercises: completedExercises)
        store.complete(
            session,
            plannedExerciseIDs: plannedExerciseIDs,
            outcomes: outcomes
        )
        dismiss()
    }
}

private struct ExerciseDraftEditor: View {
    @Binding var draft: ExerciseDraft
    let previous: CompletedExercise?
    let onSetCompleted: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("DONE")
                    .frame(width: 38)
                Text("SET")
                    .frame(width: 28)
                Spacer()
                Text("KG")
                    .frame(width: 68)
                Text("REPS")
                    .frame(width: 54)
                Text("RIR")
                    .frame(width: 48)
            }
            .font(.caption2.bold())
            .foregroundStyle(.secondary)

            ForEach(draft.sets.indices, id: \.self) { index in
                VStack(spacing: 4) {
                    HStack {
                        Button {
                            draft.sets[index].isCompleted.toggle()
                            if draft.sets[index].isCompleted {
                                onSetCompleted()
                            }
                        } label: {
                            Image(systemName: draft.sets[index].isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                        }
                        .buttonStyle(.borderless)
                        .frame(width: 38)

                        Text("\(index + 1)")
                            .font(.caption.monospacedDigit())
                            .frame(width: 28)
                        Spacer()
                        TextField("0", value: $draft.sets[index].loadKg, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 68)
                        TextField("10", value: $draft.sets[index].reps, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 54)
                        TextField("2", value: $draft.sets[index].rir, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 48)
                    }

                    if let oldSet = previousSet(at: index) {
                        HStack {
                            Spacer().frame(width: 74)
                            Text("Last: \(oldSet.loadKg, specifier: "%.1f") kg × \(oldSet.reps) reps\(rirSuffix(oldSet.rir))")
                                .font(.caption2.monospacedDigit())
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
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

    private func previousSet(at index: Int) -> CompletedSet? {
        guard let previous, previous.sets.indices.contains(index) else { return nil }
        return previous.sets[index]
    }

    private func rirSuffix(_ rir: Double?) -> String {
        guard let rir else { return "" }
        return " · RIR \(String(format: "%.1f", rir))"
    }
}

private struct ExercisePickerView: View {
    let catalog: [ExerciseDefinition]
    let title: String
    let onSelect: (ExerciseDefinition) -> Void

    @State private var query = ""

    private var filteredCatalog: [ExerciseDefinition] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return catalog }
        return catalog.filter { exercise in
            exercise.name.localizedCaseInsensitiveContains(trimmed)
                || exercise.equipment.localizedCaseInsensitiveContains(trimmed)
                || exercise.muscles.contains { $0.muscle.displayName.localizedCaseInsensitiveContains(trimmed) }
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredCatalog) { exercise in
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
            .navigationTitle(title)
            .searchable(text: $query, prompt: "Exercise, muscle, equipment")
        }
    }
}
