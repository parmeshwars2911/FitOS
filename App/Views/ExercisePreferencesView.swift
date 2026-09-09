import SwiftUI

struct ExercisePreferencesView: View {
    @EnvironmentObject private var store: AppStore
    @State private var searchText = ""
    @State private var preferences: [String: ExercisePreference] = [:]

    private var filteredExercises: [ExerciseDefinition] {
        let sorted = store.catalog.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return sorted }
        return sorted.filter { exercise in
            exercise.name.localizedCaseInsensitiveContains(searchText) ||
            exercise.equipment.localizedCaseInsensitiveContains(searchText) ||
            exercise.muscles.contains { $0.muscle.displayName.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        List {
            Section {
                Text("Preferred exercises get a small ranking boost when they fit today's training need. Avoided exercises are excluded from generated workouts, but you can still log them manually.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            ForEach(filteredExercises) { exercise in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .fontWeight(.medium)
                        Text("\(exercise.equipment.capitalized) · \(primaryMuscles(exercise))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Menu {
                        preferenceButton(.prefer, exercise: exercise)
                        preferenceButton(.neutral, exercise: exercise)
                        preferenceButton(.avoid, exercise: exercise)
                    } label: {
                        Label(label(for: preference(for: exercise)), systemImage: icon(for: preference(for: exercise)))
                            .font(.caption)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .navigationTitle("Exercise preferences")
        .searchable(text: $searchText, prompt: "Exercise, muscle or equipment")
        .onAppear {
            preferences = store.exercisePreferences
        }
    }

    private func preference(for exercise: ExerciseDefinition) -> ExercisePreference {
        preferences[exercise.id] ?? .neutral
    }

    private func preferenceButton(_ preference: ExercisePreference, exercise: ExerciseDefinition) -> some View {
        Button {
            apply(preference, to: exercise)
        } label: {
            Label(label(for: preference), systemImage: icon(for: preference))
        }
    }

    private func apply(_ preference: ExercisePreference, to exercise: ExerciseDefinition) {
        if preference == .neutral {
            preferences.removeValue(forKey: exercise.id)
        } else {
            preferences[exercise.id] = preference
        }
        store.setExercisePreference(preference, for: exercise.id)
    }

    private func primaryMuscles(_ exercise: ExerciseDefinition) -> String {
        exercise.muscles
            .filter { $0.factor >= 0.75 }
            .map { $0.muscle.displayName }
            .joined(separator: ", ")
    }

    private func label(for preference: ExercisePreference) -> String {
        switch preference {
        case .neutral: return "Neutral"
        case .prefer: return "Prefer"
        case .avoid: return "Avoid"
        }
    }

    private func icon(for preference: ExercisePreference) -> String {
        switch preference {
        case .neutral: return "minus.circle"
        case .prefer: return "star.fill"
        case .avoid: return "nosign"
        }
    }
}
