//
//  Double+Currency.swift
//  Vestra
//
//  Created by Matthew Auciello on 24/5/2026.
//

import Foundation

extension Double {
    func formattedAUD() -> String {
        if abs(self) >= 1_000_000 {
            return "$\(Self.oneDecimal(self / 1_000_000))M"
        } else if abs(self) >= 1_000 {
            return "$\(Self.oneDecimal(self / 1_000))k"
        }
        return String(format: "$%.0f", self)
    }

    /// One decimal place with a trailing ".0" trimmed (so 48.0 → "48", 1.6 → "1.6").
    private static func oneDecimal(_ value: Double) -> String {
        let s = String(format: "%.1f", value)
        return s.hasSuffix(".0") ? String(s.dropLast(2)) : s
    }
}
