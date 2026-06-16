//
//  ETFBasketCard.swift
//  Vestra
//
//  Created by Matthew Auciello on 4/6/2026.
//
//  The basket of ETFs that make up this page. Each holding carries its own
//  expected return (an ETF's historical CAGR differs from the next), and the
//  header shows the allocation-weighted "blended" return that feeds the
//  projection. UI-only for now — holdings are local @State placeholders. When
//  the backend lands, `holdings` moves to ETFPage / ETFPageManager and the
//  per-ETF data (return, MER, category) comes from the catalog API.
//

import SwiftUI

/// One ETF in the basket. UI-only placeholder for now; move to Models when
/// persistence is wired.
struct BasketHolding: Identifiable {
    let id = UUID()
    let ticker: String
    let annualReturn: Double   // 0.110 == 11.0%/yr
    var allocation: Double     // 0...1 weight within the basket
}

struct ETFBasketCard: View {
    @ObservedObject var manager: ETFPageManager

    // Placeholder holdings — replace with the page's real basket once the
    // catalog API + persistence exist.
    @State private var holdings: [BasketHolding] = [
        BasketHolding(ticker: "IVV", annualReturn: 0.110, allocation: 0.33),
        BasketHolding(ticker: "VGS", annualReturn: 0.102, allocation: 0.33),
        BasketHolding(ticker: "VAS", annualReturn: 0.088, allocation: 0.33),
    ]

    /// The shared scale the per-holding return bars are drawn against.
    private let returnScale: Double = 0.15

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            VStack(spacing: 0) {
                ForEach(Array(holdings.enumerated()), id: \.element.id) { index, holding in
                    holdingRow(holding)
                    if index < holdings.count - 1 {
                        Divider().padding(.horizontal)
                    }
                }
            }

            addETFButton
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background(RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 1, y: 1)
        )
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Your basket")
                .font(Font.theme.display(20).bold())
                .foregroundStyle(Color.theme.primaryText)
            Spacer()
            Text(String(format: "%.1f%% blended · %d ETFs", blendedReturn * 100, holdings.count))
                .font(Font.theme.mono(13))
                .foregroundStyle(Color.theme.etf)
        }
        .padding(.horizontal)
        .padding(.top, 18)
        .padding(.bottom, 6)
    }

    /// Allocation-weighted average return across the basket.
    private var blendedReturn: Double {
        let totalAllocation = holdings.reduce(0) { $0 + $1.allocation }
        guard totalAllocation > 0 else { return 0 }
        return holdings.reduce(0) { $0 + $1.annualReturn * $1.allocation } / totalAllocation
    }

    // MARK: - Holding row

    private func holdingRow(_ holding: BasketHolding) -> some View {
        HStack(spacing: 12) {
            icon

            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(holding.ticker)
                        .font(Font.theme.display(17).bold())
                        .foregroundStyle(Color.theme.primaryText)
                    Text(String(format: "%.1f%%/yr", holding.annualReturn * 100))
                        .font(Font.theme.mono(12))
                        .foregroundStyle(Color.theme.secondaryText)
                }
                returnBar(holding.annualReturn)
                    .frame(height: 4)
            }

            Spacer()

            Text("\(Int((holding.allocation * 100).rounded()))%")
                .font(Font.theme.display(17).bold())
                .foregroundStyle(Color.theme.primaryText)

            Button {
                remove(holding)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.theme.secondaryText)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove \(holding.ticker)")
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    /// Rounded ETF glyph shared by every row.
    private var icon: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.theme.etf)
            .frame(width: 40, height: 40)
            .overlay(
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.theme.onAsset)
            )
    }

    /// Thin bar showing this ETF's return against the shared `returnScale`.
    private func returnBar(_ value: Double) -> some View {
        GeometryReader { geo in
            let fraction = min(1, max(0, value / returnScale))
            ZStack(alignment: .leading) {
                Capsule().fill(Color.theme.etf.opacity(0.15))
                Capsule()
                    .fill(Color.theme.etf)
                    .frame(width: geo.size.width * fraction)
            }
        }
    }

    // MARK: - Add button

    var addETFButton: some View {
        HStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundStyle(Color.theme.etf)
            Text("Add ETFs")
                .font(.title2.bold())
                .foregroundStyle(Color.theme.etf)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.theme.etf.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    Color.theme.etf,
                    style: StrokeStyle(lineWidth: 1.5, dash: [5])
                )
        )
        .padding()
    }

    // MARK: - Actions

    private func remove(_ holding: BasketHolding) {
        withAnimation(.easeInOut(duration: 0.2)) {
            holdings.removeAll { $0.id == holding.id }
        }
    }
}

#Preview {
    let auth = AuthManager()
    auth.currentUser = UserProfile.MOCK_USER
    let store = PageStore(authManager: auth)
    let page = ETFPage()
    store.addPage(.etf(page))
    let manager = ETFPageManager(pageId: page.id, pageStore: store)
    return ETFBasketCard(manager: manager)
        .padding()
        .background(Color.theme.depth)
}
