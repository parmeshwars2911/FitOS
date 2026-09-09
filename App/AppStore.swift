import Combine
import Foundation

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var sessions: [WorkoutSession]
    @Published private(set) var generatedWorkout: GeneratedWorkout?
    @Published private(set) var measurements: [BodyMeasurement]
    @Published private(set) var targets: [MuscleTarget]
    @Published private(set) var nutritionEntries: [NutritionEntry]
    @Published private(set) var nutritionTarget: NutritionTarget
    @Published private(set) var healthKitEnabled: Bool
    @Published private(set) var isHealthSyncing = false
    @Published private(set) var recoverySnapshot: RecoverySnapshot?
    @Published private(set) var healthKitError: String?

    let catalog = ExerciseCatalog.all

    private let workoutPersistence: WorkoutPersistence
    private let profilePersistence: ProfilePersistence
    private let nutritionPersistence: NutritionPersistence
    private let healthKitService: HealthKitService
    private let userDefaults: UserDefaults
    private let engine = TrainingStateEngine()
    private let generator = WorkoutGenerator()
    private let bodyTrendEngine = BodyTrendEngine()
    private let nutritionEngine = NutritionEngine()
    private let healthKitEnabledKey = "fitos-healthkit-enabled"

    init(
        persistence: WorkoutPersistence = WorkoutPersistence(),
        profilePersistence: ProfilePersistence = ProfilePersistence(),
        nutritionPersistence: NutritionPersistence = NutritionPersistence(),
        healthKitService: HealthKitService? = nil,
        userDefaults: UserDefaults = .standard
    ) {
        self.workoutPersistence = persistence
        self.profilePersistence = profilePersistence
        self.nutritionPersistence = nutritionPersistence
        self.healthKitService = healthKitService ?? HealthKitService()
        self.userDefaults = userDefaults
        self.sessions = persistence.load()
        let profile = profilePersistence.load(defaultTargets: DefaultTargets.all)
        self.measurements = profile.measurements.sorted { $0.recordedAt > $1.recordedAt }
        self.targets = profile.targets
        let nutrition = nutritionPersistence.load()
        self.nutritionEntries = nutrition.entries.sorted { $0.recordedAt > $1.recordedAt }
        self.nutritionTarget = nutrition.target
        self.healthKitEnabled = userDefaults.bool(forKey: healthKitEnabledKey)
        self.generatedWorkout = nil
    }

    var healthKitAvailable: Bool {
        healthKitService.isAvailable
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
            return BodyMeasurement(kind: kind, value: value, recordedAt: date, source: .manual)
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

    func nutritionSummary(for date: Date) -> DailyNutritionSummary {
        nutritionEngine.summary(entries: nutritionEntries, target: nutritionTarget, on: date)
    }

    func nutritionEntries(for date: Date, calendar: Calendar = .current) -> [NutritionEntry] {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86_400)
        return nutritionEntries
            .filter { $0.recordedAt >= start && $0.recordedAt < end }
            .sorted { $0.recordedAt > $1.recordedAt }
    }

    func addNutritionEntry(_ entry: NutritionEntry) {
        nutritionEntries.append(entry)
        nutritionEntries.sort { $0.recordedAt > $1.recordedAt }
        saveNutrition()
    }

    func deleteNutritionEntry(id: UUID) {
        nutritionEntries.removeAll { $0.id == id }
        saveNutrition()
    }

    func updateNutritionTarget(_ target: NutritionTarget) {
        nutritionTarget = target
        saveNutrition()
    }

    func connectHealthKit() async {
        healthKitError = nil
        guard healthKitAvailable else {
            healthKitError = "Apple Health is not available on this device."
            return
        }

        do {
            try await healthKitService.requestAuthorization()
            healthKitEnabled = true
            userDefaults.set(true, forKey: healthKitEnabledKey)
            await syncHealthKit()
        } catch {
            healthKitError = error.localizedDescription
        }
    }

    func syncHealthKitIfEnabled() async {
        guard healthKitEnabled else { return }
        await syncHealthKit()
    }

    func syncHealthKit() async {
        guard healthKitAvailable, !isHealthSyncing else { return }
        isHealthSyncing = true
        healthKitError = nil
        defer { isHealthSyncing = false }

        do {
            let startDate = Calendar.current.date(byAdding: .day, value: -180, to: Date())
                ?? Date().addingTimeInterval(-180 * 86_400)
            let imported = try await healthKitService.fetchBodyMeasurements(since: startDate)
            mergeHealthMeasurements(imported)
            recoverySnapshot = try await healthKitService.fetchRecoverySnapshot()
        } catch {
            healthKitError = error.localizedDescription
        }
    }

    private func mergeHealthMeasurements(_ imported: [BodyMeasurement]) {
        var knownIDs = Set(measurements.compactMap(\.externalID))
        var didAdd = false

        for measurement in imported {
            guard let externalID = measurement.externalID else { continue }
            guard knownIDs.insert(externalID).inserted else { continue }
            measurements.append(measurement)
            didAdd = true
        }

        if didAdd {
            measurements.sort { $0.recordedAt > $1.recordedAt }
            saveProfile()
        }
    }

    private func saveProfile() {
        profilePersistence.save(measurements: measurements, targets: targets)
    }

    private func saveNutrition() {
        nutritionPersistence.save(entries: nutritionEntries, target: nutritionTarget)
    }
}
