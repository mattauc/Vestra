//
//  SalesChartCard.swift
//  Vestra
//
//  Created by Matthew Auciello on 28/5/2026.
//

import SwiftUI
import Charts

struct SalesChartCard: View {
    @ObservedObject var manager: PropertyPageManager
    var soldPrices: [Double] { manager.soldHistory.compactMap(\.price) }

    var body: some View {
        VStack {
            CAGRPills
            chart
        }
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

    private var chart: some View {
        Chart {
            ForEach(pricePoints) { element in
                AreaMark(
                      x: .value("Date", element.label),
                      y: .value("Price", element.price)
                  )
                  .foregroundStyle(
                      LinearGradient(
                          colors: [accent.opacity(0.3), accent.opacity(0)],
                          startPoint: .top,
                          endPoint: .bottom
                      )
                  )
                  .interpolationMethod(.catmullRom)
                LineMark(
                    x: .value("Date", element.label),
                    y: .value("Price", element.price)
                )
                .foregroundStyle(accent)
                .interpolationMethod(.catmullRom)
                PointMark(
                    x: .value("Date", element.label),
                    y: .value("Price", element.price)
                )
                .foregroundStyle(element.isEstimate ? Color.yellow : accent)
                .annotation(position: .overlay, alignment: .center, spacing: 0) {
                    if element.isEstimate {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 8, height: 8)
                            .shadow(color: Color.yellow.opacity(0.9), radius: 7)
                    }
                }
            }
        }
        .padding()
        .chartYScale(domain: .automatic(includesZero: false))
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let price = value.as(Double.self) {
                        Text(price.formattedAUD())
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel()
            }
        }
    }
    
    var CAGRPills: some View {
        HStack {
            gainPill(percent: manager.firstYearPerformance, suffix: "1YR")
            gainPill(percent: manager.thirdYearPerformance, suffix: "3YR")
            gainPill(percent: manager.firstYearPerformance, suffix: "5YR")
        }
        .padding([.top, .horizontal])
    }
    
    private func gainPill(percent: Double, suffix: String) -> some View {
        let isUp = percent >= 0
        return HStack(spacing: 4) {
            Image(systemName: isUp ? "arrow.up" : "arrow.down")
                .font(.system(size: 10, weight: .heavy))
            Text(String(format: "%.1f %%", abs(percent)))
                .font(Font.theme.mono(12, weight: .heavy))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text("·")
                .foregroundStyle(.black.opacity(0.5))
            Text(suffix)
                .font(Font.theme.mono(12, weight: .heavy))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(.yellow.opacity(0.15)))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.yellow.opacity(0.55), lineWidth: 1.5)
        )
    }
    
    

    private struct PricePoint: Identifiable {
        let id: String
        let label: String
        let price: Double
        let isEstimate: Bool
    }

    
    private var pricePoints: [PricePoint] {
        let sales = Array(manager.soldHistory.reversed())
        var points = sales.enumerated().map { i, entry in
            PricePoint(
                id: "sale-\(i)",
                label: entry.date?.formattedYearMonth() ?? "",
                price: entry.price ?? 0,
                isEstimate: false
            )
        }
        if manager.estimateMidPrice > 0 {
            points.append(PricePoint(
                id: "estimate",
                label: "Now",
                price: manager.estimateMidPrice,
                isEstimate: true
            ))
        }
        return points
    }

    private var accent: Color {
        manager.isEstimatePositive ? Color.theme.positive : Color.theme.negative
    }
    
    
}

#Preview {
    let auth = AuthManager()
    auth.currentUser = UserProfile.MOCK_USER
    let store = PageStore(authManager: auth)

    let mockSales: [SalesHistoryEntry] = [
        SalesHistoryEntry(date: "1999-09-09T00:00:00.000Z", price: 270000, description: "PRIVATE TREATY"),
        SalesHistoryEntry(date: "2012-07-23T00:00:00.000Z", price: 442000, description: "PRIVATE TREATY"),
        SalesHistoryEntry(date: "2025-11-11T00:00:00.000Z", price: 755000, description: "AUCTION - SOLD PRIOR"),
    ]

    var page = PropertyPage()
    page.propertyData = PropertyData(
        address: nil, bedrooms: nil, bathrooms: nil, propertyType: nil,
        landArea: nil, lastSoldPrice: nil, lastSoldDate: nil,
        estimate: nil, rentalEstimate: nil,
        salesHistory: mockSales, suburbPerformance: nil, coverImage: nil
    )
    store.addPage(.property(page))
    let manager = PropertyPageManager(pageId: page.id, pageStore: store)

    return SalesChartCard(manager: manager)
        .padding()
}
