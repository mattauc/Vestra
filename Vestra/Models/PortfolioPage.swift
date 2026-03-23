//
//  PortfolioPage.swift
//  Vestra
//
//  Created by Matthew Auciello on 23/3/2026.
//

import Foundation

///// Shared surface for page types (`PropertyPage`, future `ETFPage`, `CryptoPage`, …).
//protocol PageModel: Identifiable, Codable {
//    var id: UUID { get }
//    var title: String { get }
//    var activeInvestment: Bool { get set }
//}

enum PageType {
    case property
//    case etf
}

enum PortfolioPage: Identifiable, Codable, Equatable {
    case property(PropertyPage)
    // case etf(ETFPage)
    // case crypto(CryptoPage)
    var id: UUID {
        switch self {
        case .property(let p): return p.id
        // case .etf(let e): return e.id
        }
    }
}

extension PortfolioPage {
    var title: String {
        switch self {
        case .property(let p): return p.title
        }
    }
    var activeInvestment: Bool {
        switch self {
        case .property(let p): return p.activeInvestment
        }
    }
}


