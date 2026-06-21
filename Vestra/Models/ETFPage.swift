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
    var enrichmentStatus: EnrichmentStatus = .ready

    /// The page layout: an ordered list of rows. Each row is one full block or
    /// up to two half blocks (see `BlockRow` / `BlockLayout`).
    var rows: [BlockRow] = []
}

extension ETFPage {
    static let defaultRows: [BlockRow] = [
        BlockRow(Block(kind: .projection)),
        BlockRow(Block(kind: .basket)),
        BlockRow(Block(kind: .assumptions)),
        BlockRow(Block(kind: .empty)),
    ]
}
