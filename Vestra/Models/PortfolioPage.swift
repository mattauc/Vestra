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
        case .property: return Image(systemName: "house.fill")
        case .etf:      return Image(systemName: "chart.bar.fill")
        case .crypto:   return Image(systemName: "bitcoinsign.circle.fill")
        }
    }
    
    var kindColor: Color {
        switch self {
        case .property: return Color.theme.property
        case .etf:      return Color.theme.etf
        case .crypto:   return Color.theme.crypto
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

extension PortfolioPage {
    var kindDetails: String {
        switch self {
        case .property(let p):
            guard let data = p.propertyData else { return "" }
            let type = data.propertyType ?? ""
            let beds = data.bedrooms.map { "\($0)BR" } ?? ""
            let date = data.lastSoldDate?.formattedYearMonth() ?? ""
            return "\(type) · \(beds) · \(date)"
        case .etf:    return ""
        case .crypto: return ""
        }
    }

    var kindValue: String {
        switch self {
        case .property(let p):
            let value = p.propertyData?.estimate?.mid ?? p.propertyData?.lastSoldPrice ?? 0
            return value.formattedAUD()
        case .etf:    return ""
        case .crypto: return ""
        }
    }

    var kindChange: String {
        switch self {
        case .property(let p):
            guard let mid = p.propertyData?.estimate?.mid,
                  let purchased = p.propertyData?.lastSoldPrice,
                  purchased > 0 else { return "" }
            let pct = (mid - purchased) / purchased * 100
            return String(format: "%+.1f%%", pct)
        case .etf:    return ""
        case .crypto: return ""
        }
    }

    var kindChangeIsPositive: Bool {
        switch self {
        case .property(let p):
            guard let mid = p.propertyData?.estimate?.mid,
                  let purchased = p.propertyData?.lastSoldPrice else { return true }
            return mid >= purchased
        default: return true
        }
    }
}

