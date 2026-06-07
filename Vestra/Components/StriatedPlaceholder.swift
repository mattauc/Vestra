//
//  StriatedPlaceholder.swift
//  Vestra
//
//  Recreates the diagonal-stripe image placeholder from the brand studio.
//  Usage: StriatedPlaceholder(color: Color.theme.property, label: "PROPERTY / PHOTO")
//

import SwiftUI

struct StriatedPlaceholder: View {
    var color: Color = Color.theme.property
    var label: String = "PHOTO"
    var cornerRadius: CGFloat = 14
    var stripeWidth: CGFloat = 6

    var body: some View {
        ZStack {
            color

            Canvas { context, size in
                let total = stripeWidth * 2
                let count = Int((size.width + size.height) / total) + 2

                for i in 0...count {
                    let offset = CGFloat(i) * total - size.height

                    // Brighter stripe
                    var p1 = Path()
                    p1.move(to:    CGPoint(x: offset,              y: 0))
                    p1.addLine(to: CGPoint(x: offset + size.height, y: size.height))
                    p1.addLine(to: CGPoint(x: offset + size.height + stripeWidth, y: size.height))
                    p1.addLine(to: CGPoint(x: offset + stripeWidth, y: 0))
                    p1.closeSubpath()
                    context.fill(p1, with: .color(.white.opacity(0.10)))

                    // Dimmer stripe
                    var p2 = Path()
                    p2.move(to:    CGPoint(x: offset + stripeWidth,              y: 0))
                    p2.addLine(to: CGPoint(x: offset + stripeWidth + size.height, y: size.height))
                    p2.addLine(to: CGPoint(x: offset + stripeWidth * 2 + size.height, y: size.height))
                    p2.addLine(to: CGPoint(x: offset + stripeWidth * 2, y: 0))
                    p2.closeSubpath()
                    context.fill(p2, with: .color(.white.opacity(0.04)))
                }
            }

            Text(label.uppercased())
                .font(Font.theme.mono(10, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
                .tracking(1.4)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

#Preview {
    VStack(spacing: 16) {
        StriatedPlaceholder(color: Color.theme.property, label: "PROPERTY / PHOTO")
            .frame(height: 120)
        StriatedPlaceholder(color: Color.theme.etf, label: "ETF / CHART")
            .frame(height: 120)
        StriatedPlaceholder(color: Color.theme.crypto, label: "CRYPTO / CHART")
            .frame(height: 120)
    }
    .padding()
    .background(Color.theme.background)
}
