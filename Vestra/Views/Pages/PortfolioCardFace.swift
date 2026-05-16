//
//  PortfolioCardFace.swift
//  Vestra
//
//  Created by Matthew Auciello on 15/5/2026.
//

import SwiftUI

struct PortfolioCardFace: View {
    let page: PortfolioPage
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)

            VStack(alignment: .leading, spacing: 0) {
              // Header
              HStack(alignment: .top) {
                  VStack(alignment: .leading, spacing: 4) {
                      Text(pageTypeName.uppercased())
                          .font(Font.theme.mono(11, weight: .medium))
                          .foregroundStyle(Color.theme.onAsset.opacity(0.7))
                          .tracking(1.4)
                      Text(title)
                          .font(Font.theme.display(28, weight: .bold))
                          .foregroundStyle(Color.theme.onAsset)
                  }
                  Spacer()
                  Image(systemName: pageIcon)
                      .font(.system(size: 28, weight: .medium))
                      .foregroundStyle(Color.theme.onAsset.opacity(0.9))
                      .padding(14)
                      .background(Color.theme.onAsset.opacity(0.15), in: Circle())
              }
              .padding(.horizontal, 24)
              .padding(.top, 36)
                cardBody
              Spacer()

              // Stats row
              HStack {
                  StatPill(label: "Value", value: "$0")
                  Spacer()
                  StatPill(label: "Return", value: "0%")
                  Spacer()
                  StatPill(label: "Active", value: isActive ? "Yes" : "No")
              }
              .padding(.horizontal, 24)
              .padding(.bottom, 36)
            }
        }
    }
    
    @ViewBuilder
    var cardBody: some View {
        switch page {
        case .property:
            VStack() {
                Text("1BR . Purchased Dec 2025")
                    .font(Font.theme.ui(15))
                    .foregroundStyle(Color.theme.onAsset.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                StriatedPlaceholder(color: Color.theme.property, label: "PROPERTY / PHOTO")
                    .frame(height: 100)
                    .padding()
            }
        case .etf:
            EmptyView()
        case .crypto:
            EmptyView()
        }
    }
    
    private var title: String {
        switch page {
        case .property(let p): return p.title.isEmpty ? "New Property" : p.title
        case .etf(let e):      return e.title.isEmpty ? "New ETF" : e.title
        case .crypto(let c):   return c.title.isEmpty ? "New Crypto" : c.title
        }
    }

    private var isActive: Bool {
        switch page {
        case .property(let p): return p.activeInvestment
        case .etf(let e):      return e.activeInvestment
        case .crypto(let c):   return c.activeInvestment
        }
    }

    private var gradientColors: [Color] {
        switch page {
        case .property: return [Color(hex: "#0F3838"), Color(hex: "#1E5A5A")]  // tealDark → teal
        case .etf:      return [Color(hex: "#943D1E"), Color(hex: "#D85A2C")]  // dark clay → clay
        case .crypto:   return [Color(hex: "#3D3268"), Color(hex: "#6B5BB8")]  // dark lilac → lilac
        }
    }

    private var pageIcon: String {
        switch page {
        case .property: return "house.fill"
        case .etf:      return "chart.line.uptrend.xyaxis"
        case .crypto:   return "bitcoinsign.circle.fill"
        }
    }

    private var pageTypeName: String {
        switch page {
        case .property: return "Property"
        case .etf:      return "ETF"
        case .crypto:   return "Crypto"
        }
    }
}

struct StatPill: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(Font.theme.display(17, weight: .semibold))
                .foregroundStyle(Color.theme.onAsset)
            Text(label.uppercased())
                .font(Font.theme.mono(9, weight: .medium))
                .foregroundStyle(Color.theme.onAsset.opacity(0.6))
                .tracking(1.2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.theme.onAsset.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
    }
}


#Preview {
    PortfolioCardFace(page: .property(PropertyPage()))
        .frame(width: 360, height: 500)
        .clipShape(RoundedRectangle(cornerRadius: 24))
}
