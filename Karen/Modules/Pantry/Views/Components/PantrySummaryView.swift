//
//  PantrySummaryView.swift
//  Karen
//
//  Created by Dylan Dunn on 6/21/26.
//
import SwiftUI
import KarenShared

struct PantrySummaryView: View  {
    let overview: PantryOverview
    
    var body: some View {
        Section("Inventory Summary") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Total Calories")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        Text("\(totalCalories().formatted())")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                    }
                }
                
                HStack(spacing: 12) {
                    macroStat("Protein", value: overview.proteinGrams)
                    macroStat("Carbs", value: overview.carbsGrams)
                    macroStat("Fat", value: overview.fatGrams)
                }
            }
        }
    }
    
    private func macroStat(_ title: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            Text("\(value, specifier: "%.0f")g")
                .font(.headline)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func totalCalories() -> Int {
        return Int(overview.proteinGrams * 4 + overview.carbsGrams * 4 + overview.fatGrams * 9)
    }
}
