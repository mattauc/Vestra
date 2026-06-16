//
//  BentoVLogo.swift
//  Vestra
//
//  Pixel-accurate SwiftUI translation of the IconBentoV JSX from the brand studio.
//  Scales to any size — use .frame(width:height:) to control it.
//
//  Grid layout (matches brand spec):
//    3 columns (equal) × 3 rows (2fr / 1.4fr / 1.4fr)
//
//    [ teal  ][ ——— ][ ink  ]   ← arms of the V
//    [ clay  ][butter][lilac ]   ← mid
//    [ ——— ][ ink  ][ ——— ]   ← point of the V
//

import SwiftUI

struct BentoVLogo: View {
    var size: CGFloat = 120

    // — proportional geometry, matches JSX exactly —
    private var gap:          CGFloat { size * 0.04  }
    private var inset:        CGFloat { size * 0.14  }
    private var blockRadius:  CGFloat { size * 0.06  }
    private var cornerRadius: CGFloat { size * 0.225 }

    // Row heights derived from the 2fr / 1.4fr / 1.4fr spec
    private var availableHeight: CGFloat { (size - 2 * inset) - 2 * gap }
    private var row1H: CGFloat { availableHeight * (2.0 / 4.8) }
    private var row2H: CGFloat { availableHeight * (1.4 / 4.8) }
    private var row3H: CGFloat { availableHeight * (1.4 / 4.8) }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.theme.surfaceSecondary)
            .overlay {
                VStack(spacing: gap) {
                    // Row 1 — arms of the V
                    HStack(spacing: gap) {
                        block(Color.theme.property)    // teal  — left arm
                        Color.clear                    // gap
                        block(Color.theme.primaryText) // ink   — right arm
                    }
                    .frame(height: row1H)

                    // Row 2 — mid sweep
                    HStack(spacing: gap) {
                        block(Color.theme.etf)         // clay
                        block(Color.theme.highlight)   // butter
                        block(Color.theme.crypto)      // lilac
                    }
                    .frame(height: row2H)

                    // Row 3 — point of the V
                    HStack(spacing: gap) {
                        Color.clear
                        block(Color.theme.primaryText) // ink
                        Color.clear
                    }
                    .frame(height: row3H)
                }
                .padding(inset)
            }
            .frame(width: size, height: size)
    }

    private func block(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: blockRadius)
            .fill(color)
    }
}

#Preview {
    HStack(spacing: 24) {
        BentoVLogo(size: 220)
        VStack(spacing: 16) {
            BentoVLogo(size: 80)
            BentoVLogo(size: 52)
            BentoVLogo(size: 36)
        }
    }
    .padding(40)
    .background(Color.theme.background)
}
