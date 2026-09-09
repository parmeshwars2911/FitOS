import SwiftUI

struct NutritionEntryView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var mealType: MealType = .other
    @State private var recordedAt = Date()
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Meal") {
                    TextField("Meal or food name", text: $name)
                    Picker("Type", selection: $mealType) {
                        ForEach(MealType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.iconName)
                                .tag(type)
                        }
                    }
                    DatePicker("Time", selection: $recordedAt)
                }

                Section("Nutrition") {
                    numericField("Calories", unit: "kcal", text: $calories)
                    numericField("Protein", unit: "g", text: $protein)
                    numericField("Carbs", unit: "g", text: $carbs)
                    numericField("Fat", unit: "g", text: $fat)
                }

                Section {
                    Text("You can log only the values you know. Later, AI/photo/voice logging will create the same structured entry automatically.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Log nutrition")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
        }
    }

    private func numericField(_ title: String, unit: String, text: Binding<String>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0", text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 100)
            Text(unit)
                .foregroundStyle(.secondary)
        }
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (number(calories) > 0 || number(protein) > 0 || number(carbs) > 0 || number(fat) > 0)
    }

    private func number(_ text: String) -> Double {
        Double(text.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private func save() {
        let entry = NutritionEntry(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            mealType: mealType,
            calories: number(calories),
            proteinGrams: number(protein),
            carbsGrams: number(carbs),
            fatGrams: number(fat),
            recordedAt: recordedAt
        )
        store.addNutritionEntry(entry)
        dismiss()
    }
}
