import Foundation

extension AppStore {
    var betaReport: BetaReport {
        let info = Bundle.main.infoDictionary ?? [:]
        let version = info["CFBundleShortVersionString"] as? String ?? "unknown"
        let build = info["CFBundleVersion"] as? String ?? "unknown"

        return BetaReportEngine().makeReport(
            completedWorkoutCount: sessions.count,
            adherenceRecords: planAdherenceRecords,
            feedbackRecords: workoutFeedbackRecords,
            appVersion: version,
            buildNumber: build
        )
    }

    var betaReportExportJSON: String {
        BetaReportEngine().encodeJSON(betaReport) ?? "{}"
    }
}
