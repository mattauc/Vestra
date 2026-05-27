//
//  CustomGroupBox.swift
//  Vestra
//

import SwiftUI

struct CustomGroupBox: GroupBoxStyle {
    let page: PortfolioPage

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .font(Font.theme.display(15, weight: .semibold))
                .foregroundStyle(Color.theme.onAsset)
            configuration.content
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(accentColor)
                Circle()
                    .fill(Color.black.opacity(0.12))
                    .frame(width: 170)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .offset(x: 50, y: -50)
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
        )
    }

    private var accentColor: Color {
        switch page {
        case .property: return Color.theme.property
        case .etf:      return Color.theme.etf
        case .crypto:   return Color.theme.crypto
        }
    }
    
}

extension GroupBoxStyle where Self == CustomGroupBox {
    static func custom(for page: PortfolioPage) -> CustomGroupBox {
        .init(page: page)
    }
}

#Preview {
    VStack(spacing: 16) {
        GroupBox("Property") { Text("Coburg townhouse") }
            .groupBoxStyle(.custom(for: .property(PropertyPage())))
        GroupBox("ETF") { Text("VAS · Aus shares") }
            .groupBoxStyle(.custom(for: .etf(ETFPage())))
        GroupBox("Crypto") { Text("Bitcoin") }
            .groupBoxStyle(.custom(for: .crypto(CryptoPage())))
    }
    .padding()
}
