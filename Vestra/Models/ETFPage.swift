//
//  ETFPage.swift
//  Vestra
//
//  Created by Matthew Auciello on 25/3/2026.
//

import Foundation

struct ETFPage: Codable, Equatable, PagePayload, Hashable {
    var id = UUID()
    var title: String = ""
    var activeInvestment: Bool = true
}
