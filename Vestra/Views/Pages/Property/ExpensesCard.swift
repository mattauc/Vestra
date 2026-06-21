//
//  ExpensesCard.swift
//  Vestra
//
//  Created by Matthew Auciello on 21/6/2026.
//

import SwiftUI

struct ExpensesCard: View {
    @ObservedObject var manager: PropertyPageManager
    @State private var showingExpensesEditor = false

    var body: some View {
        let total = manager.totalExpenses

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Expenses")
                    .font(Font.theme.display(16).bold())
                    .foregroundStyle(Color.black)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)

                    .padding(.leading)
                Spacer()
                Text("\(total.formattedAUD())/mo")
                    .font(Font.theme.mono(13, weight: .heavy))
                    .foregroundStyle(Color.black.opacity(0.5))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Button {
                    showingExpensesEditor = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.body)
                        .foregroundStyle(Color.black.opacity(0.4))

                        .padding(.trailing, 6)
                }
                .popover(isPresented: $showingExpensesEditor) {
                    ExpensesEditorSheet(manager: manager)
                        .presentationDetents([.height(420)])
                }
            }
            .padding(.top)

            GeometryReader { geo in
                let widthFor: (Double) -> CGFloat = { price in
                    total > 0 ? geo.size.width * CGFloat(price / total) : 0
                }
                HStack(spacing: 0) {
                    Color.theme.property.frame(width: widthFor(manager.strataPrice))
                    Color.theme.etf.frame(width: widthFor(manager.councilRatesPrice))
                    Color.theme.crypto.frame(width: widthFor(manager.insurancePrice))
                    Color.yellow.frame(width: widthFor(manager.maintenancePrice))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.theme.depth)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .frame(height: 8)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.7),
                    value: [manager.strataPrice, manager.councilRatesPrice,
                            manager.insurancePrice, manager.maintenancePrice]
                )
            }
            .frame(height: 8)
            .padding(.horizontal)
            .padding(.bottom, 5)

            expensesList
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 1, y: 1)
        )
    }

    var expensesList: some View {
        VStack(spacing: 0) {
            HStack {
                Circle()
                    .fill(Color.theme.property)
                    .frame(width: 12, height: 12)
                Text("Strata")
                    .font(Font.theme.display(15).bold())
                Spacer()
                Text(String(manager.strataPrice.formattedAUD()))
                    .font(Font.theme.display(15, weight: .bold))
            }
            .padding([.bottom, .horizontal])
            Divider()
                .padding(.horizontal)


            HStack {
                Circle()
                    .fill(Color.theme.etf)
                    .frame(width: 12, height: 12)
                Text("Council")
                    .font(Font.theme.display(15).bold())
                Spacer()
                Text(manager.councilRatesPrice.formattedAUD())
                    .font(Font.theme.display(15, weight: .bold))
            }
            .padding()

            Divider()
                .padding(.horizontal)


            HStack {
                Circle()
                    .fill(Color.theme.crypto)
                    .frame(width: 12, height: 12)
                Text("Insurance")
                    .font(Font.theme.display(15).bold())
                Spacer()
                Text(manager.insurancePrice.formattedAUD())
                    .font(Font.theme.display(15, weight: .bold))
            }
            .padding()


            Divider()
                .padding(.horizontal)


            HStack {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 12, height: 12)
                Text("Maintain")
                    .font(Font.theme.display(15).bold())
                Spacer()
                Text(manager.maintenancePrice.formattedAUD())
                    .font(Font.theme.display(15, weight: .bold))
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
