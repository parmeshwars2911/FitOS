import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppStore

    let onComplete: () -> Void

    @State private var step = 0
    @State private var experience: TrainingExperience = .intermediate
    @State private var focusMuscles: [MuscleGroup] = []

    private let totalSteps = 4

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressView(value: Double(step + 1), total: Double(totalSteps))
                    .padding(.horizontal)
                    .padding(.top, 8)

                ScrollView {
                    Group {
                        switch step {
                        case 0: welcomeStep
                        case 1: experienceStep
                        case 2: focusStep
                        default: howItWorksStep
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24)
                }

                HStack(spacing: 12) {
                    if step > 0 {
                        Button("Back") { step -= 1 }
                            .buttonStyle(.bordered)
                    }
                    Button(step == totalSteps - 1 ? "Start using FitOS" : "Continue") {
                        if step == totalSteps - 1 {
                            applyProfile()
                            onComplete()
                        } else {
                            step += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                }
                .padding()
            }
            .navigationTitle("FitOS Setup")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var welcomeStep: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: "bolt.heart.fill")
                .font(.system(size: 54))
            Text("Your plan should adapt to what you actually do.")
                .font(.largeTitle.bold())
            Text("FitOS tracks recent muscle stimulus, recovery and training debt. If you skip triceps today or miss abs for several sessions, the next workout can rebalance around it.")
                .font(.title3)
                .foregroundStyle(.secondary)
            Label("No rigid Monday–Sunday split required", systemImage: "calendar.badge.clock")
            Label("Progressive overload from your real history", systemImage: "chart.line.uptrend.xyaxis")
            Label("You can replace or skip any recommendation", systemImage: "arrow.triangle.2.circlepath")
        }
    }

    private var experienceStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What training volume should we start with?")
                .font(.title.bold())
            Text("This only sets a conservative starting point. You can edit every muscle target later.")
                .foregroundStyle(.secondary)

            ForEach(TrainingExperience.allCases, id: \.rawValue) { option in
                Button {
                    experience = option
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: experience == option ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(experienceTitle(option)).font(.headline)
                            Text(experienceDescription(option))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var focusStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Anything you especially want to bring up?")
                .font(.title.bold())
            Text("Optional. Choose up to three muscles. FitOS will give them extra priority when deciding between equally valid training choices.")
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(MuscleGroup.allCases, id: \.rawValue) { muscle in
                    Button {
                        toggleFocus(muscle)
                    } label: {
                        HStack {
                            Image(systemName: focusMuscles.contains(muscle) ? "checkmark.circle.fill" : "circle")
                            Text(muscle.displayName)
                                .lineLimit(1)
                            Spacer(minLength: 0)
                        }
                        .padding(12)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .disabled(!focusMuscles.contains(muscle) && focusMuscles.count >= 3)
                }
            }

            Text("\(focusMuscles.count) / 3 selected")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var howItWorksStep: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("FitOS starts with evidence, not AI guesses.")
                .font(.title.bold())
            explanationRow(
                icon: "1.circle.fill",
                title: "Log what you actually complete",
                text: "Sets, reps, load and RIR update each muscle's rolling training state."
            )
            explanationRow(
                icon: "2.circle.fill",
                title: "Build Today's Workout",
                text: "FitOS weighs training debt, recovery, available equipment, time and previous performance."
            )
            explanationRow(
                icon: "3.circle.fill",
                title: "Keep correcting the plan",
                text: "Skip or replace exercises freely. The next recommendation uses what happened, not what was scheduled."
            )
            Text("The starting weekly targets are guidance, not a medical prescription. Adjust them from Settings → Training Goals as you learn what you recover from well.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }
    }

    private func explanationRow(icon: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon).font(.title2)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(text).foregroundStyle(.secondary)
            }
        }
    }

    private func toggleFocus(_ muscle: MuscleGroup) {
        if let index = focusMuscles.firstIndex(of: muscle) {
            focusMuscles.remove(at: index)
        } else if focusMuscles.count < 3 {
            focusMuscles.append(muscle)
        }
    }

    private func applyProfile() {
        let personalized = TrainingProfileEngine().personalizedTargets(
            baseTargets: DefaultTargets.all,
            experience: experience,
            focusMuscles: focusMuscles
        )
        for target in personalized {
            store.updateTarget(
                for: target.muscle,
                weeklySets: target.effectiveSetsPer7Days,
                goalPriority: target.goalPriority
            )
        }
    }

    private func experienceTitle(_ option: TrainingExperience) -> String {
        switch option {
        case .beginner: return "Starting out"
        case .intermediate: return "Regular lifter"
        case .experienced: return "Experienced lifter"
        }
    }

    private func experienceDescription(_ option: TrainingExperience) -> String {
        switch option {
        case .beginner: return "Start with lower weekly volume while you build consistency and tolerance."
        case .intermediate: return "Moderate starting volume for someone already training consistently."
        case .experienced: return "Use the full default volume targets and tune them from your data."
        }
    }
}
