//
//  FinancialDataCard.swift
//  Vestra
//
//  Created by Matthew Auciello on 21/6/2026.
//

import SwiftUI

struct FinancialDataCard: View {
    @ObservedObject var manager: PropertyPageManager

    var body: some View {
        HStack {
            StatPill(label: "Equity", value: manager.equity.formattedAUD(), isCard: false)
            Spacer()
            StatPill(label: "Loan", value: manager.currentPage.loanBalance.formattedAUD(), isCard: false) { newValue in
                manager.setLoanBalance(newValue)
            }
            Spacer()
            StatPill(label: "Rent", value: manager.rentalEstimate.formattedAUD(), isCard: false) { newValue in
                if let amount = Double(newValue.filter { $0.isNumber || $0 == "." }) {
                    manager.setRent(amount)
                }
            }
            Spacer()
            StatPill(label: "Yield", value: String(format: "%.1f%%", manager.propertyYield), isCard: false) { newValue in
                if let amount = Double(newValue.filter { $0.isNumber || $0 == "." }) {
                    manager.setYield(amount)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
