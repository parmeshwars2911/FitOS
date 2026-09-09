import Combine
import Foundation

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var sessions: [WorkoutSession]
    @Published private(set) var generatedWorkout: GeneratedWorkout?
    @Published private(set) var measurements: [BodyMeasurement]
    @Published private(set) var targets: [MuscleTarget]

    let catalog = ExerciseCatalog.all

    private let workoutPersistence: WorkoutPersistence
    private let profilePersistence: ProfilePersistence
    private let engine = TrainingStateEngine()
    private let generator = WorkoutGenerator()
    private let bodyTrendEngine = BodyTrendEngine()

    init(
        persistence: WorkoutPersistence = WorkoutPersistence(),
        profilePersistence: ProfilePersistence = ProfilePersistence()
    ) {
        self.workoutPersistence = persistence
        self.profilePersistence = profilePersistence
        self.sessions = persistence.load()
        let profile = profilePersistence.load(defaultTargets: DefaultTargets.all)
        self.measurements = profile.measurements.sorted { $0.recordedAt > $1.recordedAt }
        self.targets = profile.targets
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
        workoutPersistence.save(sessions)
        generateWorkout()
    }

    func deleteSessions(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            sessions.remove(at: index)
        }
        workoutPersistence.save(sessions)
        generatedWorkout = nil
    }

    func logMeasurements(_ values: [BodyMetricKind: Double], at date: Date = Date()) {
        let newMeasurements = values.compactMap { kind, value -> BodyMeasurement? in
            guard value.isFinite, value > 0 else { return nil }
            return BodyMeasurement(kind: kind, value: value, recordedAt: date)
        }
        guard !newMeasurements.isEmpty else { return }

        measurements.append(contentsOf: newMeasurements)
        measurements.sort { $0.recordedAt > $1.recordedAt }
        saveProfile()
    }

    func latestMeasurement(for kind: BodyMetricKind) -> BodyMeasurement? {
        measurements
            .filter { $0.kind == kind }
            .max { $0.recordedAt < $1.recordedAt }
    }

    func trend(for kind: BodyMetricKind, windowDays: Double? = nil) -> BodyMetricTrend? {
        bodyTrendEngine.trend(for: kind, measurements: measurements, windowDays: windowDays)
    }

    func updateTarget(for muscle: MuscleGroup, weeklySets: Double? = nil, goalPriority: Double? = nil) {
        guard let index = targets.firstIndex(where: { $0.muscle == muscle }) else { return }
        let current = targets[index]
        targets[index] = MuscleTarget(
            muscle: current.muscle,
            effectiveSetsPer7Days: max(0, weeklySets ?? current.effectiveSetsPer7Days),
            goalPriority: max(0.1, goalPriority ?? current.goalPriority),
            fullRecoveryHours: current.fullRecoveryHours
        )
        generatedWorkout = nil
        saveProfile()
    }

    func resetTargets() {
        targets = DefaultTargets.all
        generatedWorkout = nil
        saveProfile()
    }

    private func saveProfile() {
        profilePersistence.save(measurements: measurements, targets: targets)
    }
}
