//
//  LoanCard.swift
//  Vestra
//
//  Created by Matthew Auciello on 21/6/2026.
//

import SwiftUI

struct LoanCard: View {
    @ObservedObject var manager: PropertyPageManager
    @State private var showingLoanEditor = false

    var body: some View {
        let purchase = manager.lastSoldPrice
        let loan = manager.currentPage.loanBalance
        let equityRatio: CGFloat = purchase > 0
            ? CGFloat(max(0, min(1, 1 - loan / purchase)))
            : 1.0
        let equityPercent = Int(equityRatio * 100)
        let amountPaid = max(0, purchase - loan)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Loan")
                    .font(Font.theme.display(17).bold())
                    .foregroundStyle(Color.black)
                Spacer()
                HStack(spacing: 4) {
                    Text(String(format: "%.2f%%", manager.interestRate))
                        .font(Font.theme.mono(13, weight: .heavy))
                        .foregroundStyle(Color.black.opacity(0.5))
                    Text("·")
                        .foregroundStyle(Color.black.opacity(0.3))
                    Text("\(manager.monthlyRepayment.formattedAUD())/mo")
                        .font(Font.theme.mono(13, weight: .heavy))
                        .foregroundStyle(Color.black.opacity(0.5))
                }
                Button {
                    showingLoanEditor = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.body)
                        .foregroundStyle(Color.black.opacity(0.4))
                        .padding(.leading, 6)
                }
                .popover(isPresented: $showingLoanEditor) {
                    LoanEditorSheet(manager: manager)
                        .presentationDetents([.height(280)])
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.theme.depth)
                        .frame(height: 12)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(PortfolioPage.property(manager.currentPage).kindColor)
                        .frame(width: geo.size.width * equityRatio, height: 12)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: equityRatio)
                }
            }
            .frame(height: 12)

            HStack {
                Text("\(amountPaid.formattedAUD()) Paid · \(equityPercent)%")
                    .font(Font.theme.mono(13, weight: .heavy))
                    .foregroundStyle(Color.black.opacity(0.5))
                    .tracking(1.2)
                Spacer()
                Text("\(loan.formattedAUD()) left")
                    .font(Font.theme.mono(13, weight: .heavy))
                    .foregroundStyle(Color.black.opacity(0.5))
                    .tracking(1.2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 1, y: 1)
        )
    }
}
