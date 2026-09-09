import SwiftUI

struct NutritionView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedDate = Date()
    @State private var showingEntry = false
    @State private var showingTargets = false

    private var summary: DailyNutritionSummary {
        store.nutritionSummary(for: selectedDate)
    }

    private var entries: [NutritionEntry] {
        store.nutritionEntries(for: selectedDate)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    dayPicker
                    summarySection
                    mealSection
                }
                .padding()
            }
            .navigationTitle("Nutrition")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        showingTargets = true
                    } label: {
                        Image(systemName: "target")
                    }
                    Button {
                        showingEntry = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingEntry) {
                NutritionEntryView()
                    .environmentObject(store)
            }
            .sheet(isPresented: $showingTargets) {
                NutritionTargetsView()
                    .environmentObject(store)
            }
        }
    }

    private var dayPicker: some View {
        DatePicker("Day", selection: $selectedDate, displayedComponents: .date)
            .datePickerStyle(.compact)
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Daily summary")
                    .font(.headline)
                Spacer()
                Text("\(summary.entryCount) entries")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            nutrientRow("Calories", actual: summary.calories, target: summary.target.calories, unit: "kcal")
            nutrientRow("Protein", actual: summary.proteinGrams, target: summary.target.proteinGrams, unit: "g")
            nutrientRow("Carbs", actual: summary.carbsGrams, target: summary.target.carbsGrams, unit: "g")
            nutrientRow("Fat", actual: summary.fatGrams, target: summary.target.fatGrams, unit: "g")

            if summary.target.calories == 0 && summary.target.proteinGrams == 0 {
                Button("Set daily targets") {
                    showingTargets = true
                }
                .font(.subheadline.bold())
            }
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func nutrientRow(_ title: String, actual: Double, target: Double, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                    .fontWeight(.semibold)
                Spacer()
                if target > 0 {
                    Text("\(actual, specifier: "%.0f") / \(target, specifier: "%.0f") \(unit)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(actual, specifier: "%.0f") \(unit)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            if target > 0 {
                ProgressView(value: min(1.25, actual / target), total: 1.25)
            }
        }
    }

    private var mealSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Logged meals")
                .font(.headline)

            if entries.isEmpty {
                ContentUnavailableView(
                    "No meals logged",
                    systemImage: "fork.knife",
                    description: Text("Use + to quickly log calories and macros.")
                )
                .frame(maxWidth: .infinity)
            } else {
                ForEach(entries) { entry in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: entry.mealType.iconName)
                            .frame(width: 24)
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.name)
                                .fontWeight(.semibold)
                            Text(entry.mealType.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("P \(entry.proteinGrams, specifier: "%.0f") · C \(entry.carbsGrams, specifier: "%.0f") · F \(entry.fatGrams, specifier: "%.0f") g")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 8) {
                            Text("\(entry.calories, specifier: "%.0f") kcal")
                                .font(.subheadline.bold())
                            Button(role: .destructive) {
                                store.deleteNutritionEntry(id: entry.id)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .padding(12)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }
}
