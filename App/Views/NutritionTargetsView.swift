import SwiftUI

struct NutritionTargetsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var calories: Double = 0
    @State private var protein: Double = 0
    @State private var carbs: Double = 0
    @State private var fat: Double = 0

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Set your own daily targets. FitOS does not prescribe a calorie target yet; the coaching layer will be added only after body-weight and nutrition trends can be evaluated together.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Daily targets") {
                    targetStepper("Calories", value: $calories, range: 0...6_000, step: 50, unit: "kcal")
                    targetStepper("Protein", value: $protein, range: 0...400, step: 5, unit: "g")
                    targetStepper("Carbs", value: $carbs, range: 0...800, step: 5, unit: "g")
                    targetStepper("Fat", value: $fat, range: 0...250, step: 5, unit: "g")
                }
            }
            .navigationTitle("Nutrition Targets")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                calories = store.nutritionTarget.calories
                protein = store.nutritionTarget.proteinGrams
                carbs = store.nutritionTarget.carbsGrams
                fat = store.nutritionTarget.fatGrams
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.updateNutritionTarget(
                            NutritionTarget(
                                calories: calories,
                                proteinGrams: protein,
                                carbsGrams: carbs,
                                fatGrams: fat
                            )
                        )
                        dismiss()
                    }
                }
            }
        }
    }

    private func targetStepper(
        _ title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        unit: String
    ) -> some View {
        Stepper(value: value, in: range, step: step) {
            HStack {
                Text(title)
                Spacer()
                Text("\(value.wrappedValue, specifier: "%.0f") \(unit)")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
