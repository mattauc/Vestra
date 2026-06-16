//
//  PropertyPage.swift
//  Vestra
//
//  Created by Matthew Auciello on 2/11/2025.
//

import Foundation

enum PropertyType: String, Codable, Hashable, Equatable {
    case house = "House"
    case unit = "Unit/Apartment"
    case townhouse = "Townhouse"
}

struct PropertyPage: Codable, Equatable, PagePayload, Hashable {
    var id = UUID()
    var title: String = ""
    var activeInvestment: Bool = true
    var enrichmentStatus: EnrichmentStatus = .ready

    var propertyAddress: String = ""
    var propertyType: PropertyType?

    var expenses: Expenses?

    var propertyData: PropertyData?
    var loanBalance: Double = 0
    var interestRate: Double = 0
    var loanTerm: Int = 30
}

struct Expenses: Codable, Equatable, Hashable {
    var strata: Double
    var councilRates: Double
    var insurance: Double
    var maintenance: Double
}


struct PropertyData: Codable, Equatable, Hashable {
    let address: String?
    let bedrooms: Int?
    let bathrooms: Int?
    let propertyType: String?
    let landArea: Double?
    let lastSoldPrice: Double?
    let lastSoldDate: String?
    let estimate: PriceEstimate?
    var rentalEstimate: RentalEstimate?
    let salesHistory: [SalesHistoryEntry]?
    let suburbPerformance: SuburbPerformance?
    let coverImage: String?

    enum CodingKeys: String, CodingKey {
        case address
        case bedrooms
        case bathrooms
        case propertyType = "property_type"
        case landArea = "land_area"
        case lastSoldPrice = "last_sold_price"
        case lastSoldDate = "last_sold_date"
        case estimate
        case rentalEstimate = "rental_estimate"
        case salesHistory = "sales_history"
        case suburbPerformance = "suburb_performance"
        case coverImage = "cover_image"
    }
}

struct PriceEstimate: Codable, Equatable, Hashable {
    let low: Double?
    let mid: Double?
    let high: Double?
    let confidence: String?
}

struct RentalEstimate: Codable, Equatable, Hashable {
    var weeklyRent: Double?
    let low: Double?
    let high: Double?
    var yieldPercent: Double?

    enum CodingKeys: String, CodingKey {
        case weeklyRent = "weekly_rent"
        case low
        case high
        case yieldPercent = "yield_percent"
    }
}

struct SalesHistoryEntry: Codable, Equatable, Hashable, Identifiable {
    let date: String?
    let price: Double?
    let description: String?
    
    var id: String {date ?? ""}
}

struct SuburbPerformance: Codable, Equatable, Hashable {
    let cagr1yPercent: Double?
    let cagr3yPercent: Double?
    let cagr5yPercent: Double?

    enum CodingKeys: String, CodingKey {
        case cagr1yPercent = "cagr_1y_percent"
        case cagr3yPercent = "cagr_3y_percent"
        case cagr5yPercent = "cagr_5y_percent"
    }
}
