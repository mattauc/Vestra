//
//  ExpensesEditorSheet.swift
//  Vestra
//
//  Created by Matthew Auciello on 25/5/2026.
//

import SwiftUI

struct ExpensesEditorSheet: View {
    @ObservedObject var manager: PropertyPageManager
    @Environment(\.dismiss) private var dismiss

    @State private var strataText = ""
    @State private var councilText = ""
    @State private var insuranceText = ""
    @State private var maintenanceText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Expenses")
                    .font(Font.theme.display(20).bold())
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .font(Font.theme.display(15))
            }
            .padding(.top)

            field(label: "STRATA", color: Color.theme.property, text: $strataText)
            field(label: "COUNCIL RATES", color: Color.theme.etf, text: $councilText)
            field(label: "INSURANCE", color: Color.theme.crypto, text: $insuranceText)
            field(label: "MAINTENANCE", color: Color.yellow, text: $maintenanceText)

            if manager.totalExpenses > 0 {
                Divider()
                HStack {
                    Text("TOTAL / YEAR")
                        .font(Font.theme.mono(12, weight: .heavy))
                        .foregroundStyle(Color.black.opacity(0.5))
                        .tracking(1.2)
                    Spacer()
                    Text(manager.totalExpenses.formattedAUD())
                        .font(Font.theme.display(20).bold())
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            strataText      = String(format: "%.0f", manager.strataPrice)
            councilText     = String(format: "%.0f", manager.councilRatesPrice)
            insuranceText   = String(format: "%.0f", manager.insurancePrice)
            maintenanceText = String(format: "%.0f", manager.maintenancePrice)
        }
        .onDisappear {
            commit()
            manager.persistCurrentPage()
        }
    }

    @ViewBuilder
    private func field(label: String, color: Color, text: Binding<String>) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(Font.theme.mono(12, weight: .heavy))
                    .foregroundStyle(Color.black.opacity(0.5))
                    .tracking(1.2)
                TextField("e.g. 1200", text: text)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }

    private func commit() {
        manager.setExpensesLocally(
            strata:       Double(strataText)      ?? manager.strataPrice,
            councilRates: Double(councilText)     ?? manager.councilRatesPrice,
            insurance:    Double(insuranceText)   ?? manager.insurancePrice,
            maintenance:  Double(maintenanceText) ?? manager.maintenancePrice
        )
    }
}
