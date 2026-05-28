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

    var body: some View {
        VStack {
            Chart {
                ForEach(manager.soldHistory.reversed()) { element in
                    LineMark(
                        x: .value("Date", element.date?.formattedYearMonth() ?? ""),
                        y: .value("Price", element.price ?? 0.0)
                    )
                    .foregroundStyle(accent)
                    .interpolationMethod(.catmullRom)
                    PointMark(
                        x: .value("Date", element.date?.formattedYearMonth() ?? ""),
                        y: .value("Price", element.price ?? 0.0)
                    )
                    .foregroundStyle(accent)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(accent.opacity(0.1))
        )
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
