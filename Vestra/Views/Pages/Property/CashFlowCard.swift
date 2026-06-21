//
//  CashFlowCard.swift
//  Vestra
//
//  Created by Matthew Auciello on 28/5/2026.
//

import SwiftUI
import Charts

struct CashFlowCard: View {
    @ObservedObject var manager: PropertyPageManager

    var body: some View {
        let net = manager.monthlyCashFlow
        let isNegative = manager.isNegativelyGeared
        let accent = isNegative ? Color.theme.negative : Color.theme.positive

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Cash flow")
                    .font(Font.theme.display(17).bold())
                    .foregroundStyle(Color.black)
                    .fixedSize(horizontal: true, vertical: false)
                Spacer()
                Text("\(signed(net))/mo")
                    .font(Font.theme.mono(13, weight: .heavy))
                    .foregroundStyle(accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }

            HStack(spacing: 6) {
                Circle()
                    .fill(accent)
                    .frame(width: 7, height: 7)
                Text(isNegative ? "NEGATIVELY GEARED" : "POSITIVELY GEARED")
                    .font(Font.theme.mono(11, weight: .heavy))
                    .foregroundStyle(accent)
                    .tracking(1.2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(signed(net))
                    .font(Font.theme.display(40).bold())
                    .foregroundStyle(accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("/mo")
                    .font(Font.theme.mono(13, weight: .heavy))
                    .foregroundStyle(accent.opacity(0.6))
            }

            Text("= \(signed(manager.annualCashFlow))/YR")
                .font(Font.theme.mono(12, weight: .heavy))
                .foregroundStyle(Color.black.opacity(0.4))
                .tracking(1.0)

            GeometryReader { geo in
                HStack(spacing: 0) {
                    Color.theme.positive
                        .frame(width: geo.size.width * CGFloat(manager.rentCoverage))
                    Color.theme.graphite
                }
                .clipShape(Capsule())
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: manager.rentCoverage)
            }
            .frame(height: 8)

            VStack(spacing: 8) {
                cashFlowRow(dot: Color.theme.positive, label: "Rent",
                            amount: signed(manager.monthlyRent, showsPlus: true),
                            amountColor: Color.theme.positive)
                cashFlowRow(dot: Color.black, label: "Loan",
                            amount: signed(-manager.monthlyRepayment),
                            amountColor: Color.black)
                cashFlowRow(dot: Color.black, label: "Costs",
                            amount: signed(-manager.totalExpenses),
                            amountColor: Color.black)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(accent.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(accent.opacity(0.55), lineWidth: 1.5)
        )
    }

    private func signed(_ value: Double, showsPlus: Bool = false) -> String {
        let magnitude = abs(value).formattedAUD()
        if value < 0 { return "-\(magnitude)" }
        return showsPlus ? "+\(magnitude)" : magnitude
    }

    @ViewBuilder
    private func cashFlowRow(dot: Color, label: String, amount: String, amountColor: Color) -> some View {
        HStack {
            Circle()
                .fill(dot)
                .frame(width: 8, height: 8)
            Text(label)
                .font(Font.theme.ui(15))
                .foregroundStyle(Color.black.opacity(0.8))
            Spacer()
            Text(amount)
                .font(Font.theme.mono(14, weight: .heavy))
                .foregroundStyle(amountColor)
        }
    }
}
