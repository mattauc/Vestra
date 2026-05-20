//
//  PortfolioPage.swift
//  Vestra
//
//  Created by Matthew Auciello on 23/3/2026.
//

import Foundation
import SwiftUI

enum PageType {
    case property
    case etf
    case crypto
}

enum PortfolioPage: Identifiable, Codable, Equatable, Hashable {
    case property(PropertyPage)
    case etf(ETFPage)
    case crypto(CryptoPage)
    var id: UUID {
        switch self {
            case .property(let p): return p.id
            case .etf(let e): return e.id
            case .crypto(let c): return c.id
        }
    }
}

extension PortfolioPage {
    var title: String {
        switch self {
            case .property(let p): return p.title
            case .etf(let e): return e.title
            case .crypto(let c): return c.title
        }
    }
    var activeInvestment: Bool {
        switch self {
            case .property(let p): return p.activeInvestment
            case .etf(let e): return e.activeInvestment
            case .crypto(let c): return c.activeInvestment
            
        }
    }
}

extension PortfolioPage {
    var kindLabel: String {
        switch self {
        case .property: return "Property"
        case .etf: return "ETF"
        case .crypto: return "Crypto"
        }
    }
    
    var kindDescription: String {
        switch self {
        case .property: return "Track properties, loans & equity"
        case .etf:      return "Monitor index funds & returns"
        case .crypto:   return "Follow your digital assets"
        }
    }
    
    var kindImage: Image {
        switch self {
        case .property: return Image(systemName: "house")
        case .etf:      return Image(systemName: "chart.bar.fill")
        case .crypto:   return Image(systemName: "bitcoinsign.circle.fill")
        }
    }
}

protocol PagePayload {
    var id: UUID { get }
    var title: String { get }
    var activeInvestment: Bool { get }
}

extension PortfolioPage {
      var isProperty: Bool { if case .property = self { return true }; return false }
      var isETF: Bool { if case .etf = self { return true }; return false }
      var isCrypto: Bool { if case .crypto = self { return true }; return false }
  }

