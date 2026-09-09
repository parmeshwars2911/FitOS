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
    @Published private(set) var planAdherenceRecords: [WorkoutPlanAdherence]
    @Published private(set) var healthKitEnabled: Bool
    @Published private(set) var isHealthSyncing = false
    @Published private(set) var recoverySnapshot: RecoverySnapshot?
    @Published private(set) var healthKitError: String?

    let catalog = ExerciseCatalog.all

    private let workoutPersistence: WorkoutPersistence
    private let profilePersistence: ProfilePersistence
    private let nutritionPersistence: NutritionPersistence
    private let planAdherencePersistence: WorkoutPlanAdherencePersistence
    private let healthKitService: HealthKitService
    private let userDefaults: UserDefaults
    private let engine = TrainingStateEngine()
    private let generator = WorkoutGenerator()
    private let bodyTrendEngine = BodyTrendEngine()
    private let nutritionEngine = NutritionEngine()
    private let coachContextEngine = CoachContextEngine()
    private let weeklyReviewEngine = WeeklyReviewEngine()
    private let planAdherenceEngine = WorkoutPlanAdherenceEngine()
    private let strengthProgressionEngine = StrengthProgressionEngine()
    private let healthKitEnabledKey = "fitos-healthkit-enabled"
    private let exercisePreferenceKey = "fitos-exercise-preferences-v1"

    init(
        persistence: WorkoutPersistence = WorkoutPersistence(),
        profilePersistence: ProfilePersistence = ProfilePersistence(),
        nutritionPersistence: NutritionPersistence = NutritionPersistence(),
        planAdherencePersistence: WorkoutPlanAdherencePersistence = WorkoutPlanAdherencePersistence(),
        healthKitService: HealthKitService? = nil,
        userDefaults: UserDefaults = .standard
    ) {
        self.workoutPersistence = persistence
        self.profilePersistence = profilePersistence
        self.nutritionPersistence = nutritionPersistence
        self.planAdherencePersistence = planAdherencePersistence
        self.healthKitService = healthKitService ?? HealthKitService()
        self.userDefaults = userDefaults
        self.sessions = persistence.load()
        let profile = profilePersistence.load(defaultTargets: DefaultTargets.all)
        self.measurements = profile.measurements.sorted { $0.recordedAt > $1.recordedAt }
        self.targets = profile.targets
        let nutrition = nutritionPersistence.load()
        self.nutritionEntries = nutrition.entries.sorted { $0.recordedAt > $1.recordedAt }
        self.nutritionTarget = nutrition.target
        self.planAdherenceRecords = planAdherencePersistence.load().sorted { $0.recordedAt > $1.recordedAt }
        self.healthKitEnabled = userDefaults.bool(forKey: healthKitEnabledKey)
        self.generatedWorkout = nil
    }

    var healthKitAvailable: Bool { healthKitService.isAvailable }

    var trainingState: TrainingState {
        engine.evaluate(sessions: sessions, targets: targets)
    }

    var coachContext: CoachContext {
        coachContextEngine.build(
            trainingState: trainingState,
            sessions: sessions,
            measurements: measurements,
            nutritionEntries: nutritionEntries,
            nutritionTarget: nutritionTarget
        )
    }

    var weeklyReview: WeeklyReview { weeklyReviewEngine.review(context: coachContext) }

    var generatedExerciseAcceptanceRate: Double? {
        let values = planAdherenceRecords.compactMap(\.acceptanceRatio)
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    var exercisePreferences: [String: ExercisePreference] {
        guard let data = userDefaults.data(forKey: exercisePreferenceKey),
              let decoded = try? JSONDecoder().decode([String: ExercisePreference].self, from: data)
        else { return [:] }
        return decoded
    }

    func exercisePreference(for exerciseID: String) -> ExercisePreference {
        exercisePreferences[exerciseID] ?? .neutral
    }

    func setExercisePreference(_ preference: ExercisePreference, for exerciseID: String) {
        var preferences = exercisePreferences
        if preference == .neutral {
            preferences.removeValue(forKey: exerciseID)
        } else {
            preferences[exerciseID] = preference
        }

        if let data = try? JSONEncoder().encode(preferences) {
            userDefaults.set(data, forKey: exercisePreferenceKey)
        }
        generatedWorkout = nil
    }

    func generateWorkout(
        durationMinutes: Int = 60,
        availableEquipment: Set<String> = [],
        readiness: SessionReadiness = .normal
    ) {
        let constraints = WorkoutConstraint(
            durationMinutes: durationMinutes,
            availableEquipment: availableEquipment
        )
        generatedWorkout = generator.generate(
            from: trainingState,
            exerciseLibrary: catalog,
            constraints: constraints,
            exerciseHistory: sessions,
            exercisePreferences: exercisePreferences,
            readiness: readiness
        )
    }

    func invalidateGeneratedWorkout() {
        generatedWorkout = nil
    }

    func complete(_ session: WorkoutSession, plannedExerciseIDs: [String] = [], outcomes: [WorkoutPlanOutcome] = []) {
        sessions.append(session)
        sessions.sort { $0.completedAt > $1.completedAt }
        workoutPersistence.save(sessions)

        if !plannedExerciseIDs.isEmpty {
            let adherence = planAdherenceEngine.evaluate(
                workoutSessionID: session.id,
                plannedExerciseIDs: plannedExerciseIDs,
                outcomes: outcomes,
                recordedAt: session.completedAt
            )
            planAdherenceRecords.append(adherence)
            planAdherenceRecords.sort { $0.recordedAt > $1.recordedAt }
            planAdherencePersistence.save(planAdherenceRecords)
        }

        // Completing a workout changes training state. Do not silently build the next
        // session with hidden default constraints; Today should rebuild using the
        // duration, equipment, readiness and preferences the user can actually see.
        generatedWorkout = nil
    }

    func previousPerformance(for exerciseID: String) -> (completedAt: Date, exercise: CompletedExercise)? {
        for session in sessions.sorted(by: { $0.completedAt > $1.completedAt }) {
            if let exercise = session.exercises.first(where: { $0.exercise.id == exerciseID }) {
                return (session.completedAt, exercise)
            }
        }
        return nil
    }

    func progressionRecommendation(for exerciseID: String, repRange: ClosedRange<Int> = 8...12) -> ProgressionRecommendation? {
        guard let previous = previousPerformance(for: exerciseID)?.exercise else { return nil }
        return strengthProgressionEngine.recommend(previous: previous, repRange: repRange)
    }

    func strengthTrend(for exerciseID: String) -> ExerciseStrengthTrend? {
        strengthProgressionEngine.trend(for: exerciseID, sessions: sessions)
    }

    func recentStrengthTrends(limit: Int = 5) -> [ExerciseStrengthTrend] {
        var seen = Set<String>()
        var trends: [ExerciseStrengthTrend] = []
        for session in sessions.sorted(by: { $0.completedAt > $1.completedAt }) {
            for exercise in session.exercises where seen.insert(exercise.exercise.id).inserted {
                if let trend = strengthTrend(for: exercise.exercise.id) { trends.append(trend) }
            }
            if trends.count >= limit { break }
        }
        return Array(trends.prefix(limit))
    }

    func deleteSessions(at offsets: IndexSet) {
        let deletedIDs = Set(offsets.compactMap { index in sessions.indices.contains(index) ? sessions[index].id : nil })
        for index in offsets.sorted(by: >) where sessions.indices.contains(index) { sessions.remove(at: index) }
        planAdherenceRecords.removeAll { deletedIDs.contains($0.workoutSessionID) }
        workoutPersistence.save(sessions)
        planAdherencePersistence.save(planAdherenceRecords)
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
        measurements.filter { $0.kind == kind }.max { $0.recordedAt < $1.recordedAt }
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
        return nutritionEntries.filter { $0.recordedAt >= start && $0.recordedAt < end }.sorted { $0.recordedAt > $1.recordedAt }
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

    func makeLocalBackupArchive(generatedAt: Date = Date()) -> FitOSBackupArchive {
        FitOSBackupArchive(
            generatedAt: generatedAt,
            sessions: sessions,
            measurements: measurements,
            muscleTargets: targets,
            nutritionEntries: nutritionEntries,
            nutritionTarget: nutritionTarget,
            planAdherenceRecords: planAdherenceRecords,
            exercisePreferences: exercisePreferences,
            workoutFeedbackRecords: workoutFeedbackRecords
        )
    }

    func restoreFromLocalBackup(_ archive: FitOSBackupArchive) throws {
        try archive.validate()
        sessions = archive.sessions.sorted { $0.completedAt > $1.completedAt }
        measurements = archive.measurements.sorted { $0.recordedAt > $1.recordedAt }
        targets = archive.muscleTargets
        nutritionEntries = archive.nutritionEntries.sorted { $0.recordedAt > $1.recordedAt }
        nutritionTarget = archive.nutritionTarget
        planAdherenceRecords = archive.planAdherenceRecords.sorted { $0.recordedAt > $1.recordedAt }
        generatedWorkout = nil

        workoutPersistence.save(sessions)
        saveProfile()
        saveNutrition()
        planAdherencePersistence.save(planAdherenceRecords)
        WorkoutFeedbackPersistence().save(archive.workoutFeedbackRecords)

        if archive.exercisePreferences.isEmpty {
            userDefaults.removeObject(forKey: exercisePreferenceKey)
        } else if let data = try? JSONEncoder().encode(archive.exercisePreferences) {
            userDefaults.set(data, forKey: exercisePreferenceKey)
        }
    }

    func restoreFromCloud(_ snapshot: CloudStateSnapshot) throws {
        try snapshot.validate()
        sessions = snapshot.sessions.sorted { $0.completedAt > $1.completedAt }
        measurements = snapshot.measurements.sorted { $0.recordedAt > $1.recordedAt }
        targets = snapshot.muscleTargets
        nutritionEntries = snapshot.nutritionEntries.sorted { $0.recordedAt > $1.recordedAt }
        nutritionTarget = snapshot.nutritionTarget
        planAdherenceRecords = []
        generatedWorkout = nil
        workoutPersistence.save(sessions)
        saveProfile()
        saveNutrition()
        planAdherencePersistence.save(planAdherenceRecords)
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
        } catch { healthKitError = error.localizedDescription }
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
            let startDate = Calendar.current.date(byAdding: .day, value: -180, to: Date()) ?? Date().addingTimeInterval(-180 * 86_400)
            let imported = try await healthKitService.fetchBodyMeasurements(since: startDate)
            mergeHealthMeasurements(imported)
            recoverySnapshot = try await healthKitService.fetchRecoverySnapshot()
        } catch { healthKitError = error.localizedDescription }
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

    private func saveProfile() { profilePersistence.save(measurements: measurements, targets: targets) }
    private func saveNutrition() { nutritionPersistence.save(entries: nutritionEntries, target: nutritionTarget) }
}
