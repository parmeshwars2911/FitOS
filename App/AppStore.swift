import Combine
import Foundation

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var sessions: [WorkoutSession]
    @Published private(set) var generatedWorkout: GeneratedWorkout?

    let catalog = ExerciseCatalog.all

    private let persistence: WorkoutPersistence
    private let engine = TrainingStateEngine()
    private let generator = WorkoutGenerator()
    private let targets = DefaultTargets.all

    init(persistence: WorkoutPersistence = WorkoutPersistence()) {
        self.persistence = persistence
        self.sessions = persistence.load()
        self.generatedWorkout = nil
    }

    var trainingState: TrainingState {
        engine.evaluate(sessions: sessions, targets: targets)
    }

    func generateWorkout(durationMinutes: Int = 60) {
        let constraints = WorkoutConstraint(durationMinutes: durationMinutes)
        generatedWorkout = generator.generate(
            from: trainingState,
            exerciseLibrary: catalog,
            constraints: constraints
        )
    }

    func complete(_ session: WorkoutSession) {
        sessions.append(session)
        sessions.sort { $0.completedAt > $1.completedAt }
        persistence.save(sessions)
        generateWorkout()
    }

    func deleteSessions(at offsets: IndexSet) {
        sessions.remove(atOffsets: offsets)
        persistence.save(sessions)
        generatedWorkout = nil
    }
}
