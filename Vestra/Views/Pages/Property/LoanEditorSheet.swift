//
//  LoanEditorSheet.swift
//  Vestra
//
//  Created by Matthew Auciello on 24/5/2026.
//

import SwiftUI

struct LoanEditorSheet: View {
    @ObservedObject var manager: PropertyPageManager
    @Environment(\.dismiss) private var dismiss

    @State private var rateText = ""
    @State private var termText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Loan Details")
                    .font(Font.theme.display(20).bold())
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .font(Font.theme.display(15))
            }
            .padding(.top)

            VStack(alignment: .leading, spacing: 6) {
                Text("INTEREST RATE (%)")
                    .font(Font.theme.mono(12, weight: .heavy))
                    .foregroundStyle(Color.black.opacity(0.5))
                    .tracking(1.2)
                TextField("e.g. 5.50", text: $rateText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("LOAN TERM (YEARS)")
                    .font(Font.theme.mono(12, weight: .heavy))
                    .foregroundStyle(Color.black.opacity(0.5))
                    .tracking(1.2)
                TextField("e.g. 30", text: $termText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
            }

            if manager.monthlyRepayment > 0 {
                Divider()
                HStack {
                    Text("MONTHLY REPAYMENT")
                        .font(Font.theme.mono(12, weight: .heavy))
                        .foregroundStyle(Color.black.opacity(0.5))
                        .tracking(1.2)
                    Spacer()
                    Text(manager.monthlyRepayment.formattedAUD())
                        .font(Font.theme.display(20).bold())
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            rateText = String(format: "%.2f", manager.interestRate)
            termText = String(manager.loanTerm)
        }
        .onDisappear {
            commit()
            manager.persistCurrentPage()
        }
    }

    private func commit() {
        if let rate = Double(rateText) { manager.setInterestRateLocally(rate) }
        if let term = Int(termText) { manager.setLoanTermLocally(term) }
    }
}
