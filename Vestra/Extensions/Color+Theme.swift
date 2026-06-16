//
//  Color+Theme.swift
//  Vestra
//

import SwiftUI

// MARK: - Hex initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Adaptive helper
private func adaptive(light: String, dark: String) -> Color {
    Color(UIColor {
        $0.userInterfaceStyle == .dark
            ? UIColor(Color(hex: dark))
            : UIColor(Color(hex: light))
    })
}

// MARK: - Theme
extension Color {
    static let theme = Theme()

    struct Theme {

        // MARK: Surfaces
        let background       = adaptive(light: "#FBFAF7", dark: "#1A1814")  // ivory
        let surface          = adaptive(light: "#EEEBE2", dark: "#2A2520")  // paper
        let surfaceSecondary = adaptive(light: "#F2EDDE", dark: "#221E19")  // cream
        let depth            = adaptive(light: "#E8E3D2", dark: "#302B24")  // oat — dividers, depth

        // MARK: Text
        let primaryText   = adaptive(light: "#1A1814", dark: "#FBFAF7")  // ink
        let graphite      = adaptive(light: "#3A352C", dark: "#C8C0B4")  // secondary dark
        let secondaryText = adaptive(light: "#6B6660", dark: "#A8A096")  // stone
        let tertiaryText  = adaptive(light: "#A8A096", dark: "#6B6660")  // pebble

        // MARK: Interactive (ink-based — no single brand accent)
        let accent   = adaptive(light: "#1A1814", dark: "#FBFAF7")  // ink / ivory
        let onAccent = adaptive(light: "#FBFAF7", dark: "#1A1814")  // ivory / ink

        // MARK: Asset-coded (never light/dark — always their full chroma)
        let property    = Color(hex: "#1E5A5A")  // teal
        let propertyDark = Color(hex: "#0F3838") // teal dark
        let etf         = Color(hex: "#D85A2C")  // clay
        let crypto      = Color(hex: "#6B5BB8")  // lilac
        let onAsset     = Color(hex: "#FBFAF7")  // ivory — text on asset blocks

        // MARK: Highlight
        let highlight   = Color(hex: "#F4D55C")  // butter
        let onHighlight = Color(hex: "#1A1814")  // ink on butter

        // MARK: Sentiment
        let positive = Color(hex: "#0F8A4C")  // emerald
        let negative = Color(hex: "#B73323")  // rust
    }
}
