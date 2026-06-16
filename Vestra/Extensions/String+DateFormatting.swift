//
//  String+DateFormatting.swift
//  Vestra
//
//  Created by Matthew Auciello on 24/5/2026.
//

import Foundation

extension String {
    func formattedYearMonth() -> String {
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"
        parser.locale = Locale(identifier: "en_AU")
        guard let parsed = parser.date(from: self) else { return String(self.prefix(7)) }
        let output = DateFormatter()
        output.dateFormat = "MMM yyyy"
        output.locale = Locale(identifier: "en_AU")
        return output.string(from: parsed)
    }
}
