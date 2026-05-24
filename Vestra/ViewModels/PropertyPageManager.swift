//
//  PropertyPageManager.swift
//  Vestra
//
//  Created by Matthew Auciello on 26/3/2026.
//

import Foundation
import CoreLocation

@MainActor
final class PropertyPageManager: ObservableObject {
    
    private let pageId: UUID
    private let pageStore: PageStore
    
    @Published private(set) var currentPage: PropertyPage
    
    init(pageId: UUID, pageStore: PageStore) {
        self.pageId = pageId
        self.pageStore = pageStore
        if let portfolio = pageStore.pages.first(where: { $0.id == pageId }),
           case .property(let p) = portfolio {
            self.currentPage = p
        } else {
            // Previews (and some edge cases) may initialize before `PageStore` has loaded pages.
            // Default to an empty page instead of crashing.
            self.currentPage = PropertyPage()
        }
    }
    
    var isActive: Bool {
        return currentPage.activeInvestment
    }
    
    var propertyAdress: String {
        return currentPage.propertyAddress
    }
    
    var propertyType: PropertyType {
        return PropertyType.unit
    }
    
    var title: String {
        get { currentPage.title }
        set {
            var page = currentPage
            page.title = newValue
            currentPage = page
        }
    }
    
    var estimateLowPirce: Double {
        currentPage.propertyData?.estimate?.low ?? 0.0
    }
    
    var estimateMidPrice: Double {
        currentPage.propertyData?.estimate?.mid ?? 0.0
    }
    
    var estimateHighPrice: Double {
        currentPage.propertyData?.estimate?.high ?? 0.0
    }
    
    var estimateConfidence: String {
        currentPage.propertyData?.estimate?.confidence ?? "-"
    }
    
    var lastSoldPrice: Double {
        currentPage.propertyData?.lastSoldPrice ?? 0.0
    }
    
    var rentalEstimate: Double {
        currentPage.propertyData?.rentalEstimate?.weeklyRent ?? 0.0
    }

    var propertyYield: Double {
        currentPage.propertyData?.rentalEstimate?.yieldPercent ?? 0.0
    }

    var equity: Double {
        estimateMidPrice - currentPage.loanBalance
    }

    var interestRate: Double {
        currentPage.interestRate
    }

    func setInterestRate(_ value: Double) {
        currentPage.interestRate = value
        pageStore.updatePage(.property(currentPage))
    }

    var loanTerm: Int {
        currentPage.loanTerm
    }

    func setLoanTerm(_ value: Int) {
        currentPage.loanTerm = value
        pageStore.updatePage(.property(currentPage))
    }

    var monthlyRepayment: Double {
        let r = currentPage.interestRate / 100 / 12
        let n = Double(currentPage.loanTerm * 12)
        guard n > 0 else { return 0 }
        guard r > 0 else { return currentPage.loanBalance / n }
        return currentPage.loanBalance * (r * pow(1 + r, n)) / (pow(1 + r, n) - 1)
    }

    var yearsHeld: String {
        let currentYear = Calendar.current.component(.year, from: Date())
        let date = currentPage.propertyData?.lastSoldDate.flatMap { Self.formatYearMonth($0) } ?? String(currentYear)
        let year = Int(date.split(separator: "-")[0]) ?? 0
        return "\(currentYear - year) yrs"
    }

    func setLoanBalance(_ value: String) {
        let lower = value.lowercased().trimmingCharacters(in: .whitespaces)
        let multiplier: Double = lower.hasSuffix("m") ? 1_000_000 : lower.hasSuffix("k") ? 1_000 : 1
        let numeric = lower.filter { $0.isNumber || $0 == "." }
        guard let amount = Double(numeric) else { return }
        currentPage.loanBalance = amount * multiplier
        pageStore.updatePage(.property(currentPage))
    }

    func setRent(_ value: Double) {
        currentPage.propertyData?.rentalEstimate?.weeklyRent = value
        pageStore.updatePage(.property(currentPage))
    }

    func setYield(_ value: Double) {
        currentPage.propertyData?.rentalEstimate?.yieldPercent = value
        pageStore.updatePage(.property(currentPage))
    }
    
    var propertyDetails: String {
        if currentPage.propertyData == nil { return "" }
        let type = currentPage.propertyData?.propertyType ?? "—"
        let beds = currentPage.propertyData?.bedrooms.map { "\($0)" } ?? "—"
        let baths = currentPage.propertyData?.bathrooms.map { "\($0)" } ?? "—"
        let date = currentPage.propertyData?.lastSoldDate.flatMap { Self.formatYearMonth($0) } ?? "—"
        return "\(type) . \(beds) BR . \(baths) BA . \(date)"
    }

    private static func formatYearMonth(_ raw: String) -> String? {
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"
        parser.locale = Locale(identifier: "en_AU")
        guard let parsed = parser.date(from: raw) else { return String(raw.prefix(7)) }
        let output = DateFormatter()
        output.dateFormat = "MMM yyyy"
        output.locale = Locale(identifier: "en_AU")
        return output.string(from: parsed)
    }
    
    var propertyGain: Double {
        if let propertyEstimate = currentPage.propertyData?.estimate?.mid {
            return propertyEstimate - lastSoldPrice
        }
        return 0.0
    }
    
    func setPropertyType(newType: PropertyType) {
        currentPage.propertyType = newType
        //Perhaps I'll have it google the property
    }
    
    func toggleActiveInvestment() {
        if currentPage.activeInvestment == true {
            currentPage.activeInvestment = false
        } else {
            currentPage.activeInvestment = true
        }
    }
    
    func sendPropertyAddress(address: String) async {
        let geocoder = CLGeocoder()
    
        guard let placemark = try? await geocoder.geocodeAddressString(address).first else {
            print("Geocoding failed")
            return
        }
        
        // Extract structured components from placemark
        let streetNumber = placemark.subThoroughfare ?? ""
        let streetName   = placemark.thoroughfare ?? ""
        let suburb       = placemark.locality ?? ""
        let state        = placemark.administrativeArea ?? ""
        let postcode     = placemark.postalCode ?? ""
        
        print(streetNumber + " " + streetName + " " + suburb + " " + state + " " + postcode)
        
        
        let name = placemark.name ?? ""
        print(name)
        var unit = ""
        if name.contains("/") {
          unit = String(name.split(separator: "/").first ?? "")+"-"
        }


        try? await fetchPropertyData(
            streetNumber: unit+streetNumber,
            streetName: streetName,
            suburb: suburb,
            state: state,
            postcode: postcode
        )
    }
    
    func fetchPropertyData(streetNumber: String, streetName: String, suburb: String, state: String, postcode: String) async throws {
        let data: PropertyData = try await NetworkManager.shared.request(
            PropertyEndpoint.getProperty(
            streetNumber: streetNumber,
            streetName: streetName,
            suburb: suburb,
            state: state,
            postcode: postcode
            )
        )
        
        print(data)
        currentPage.propertyData = data
        currentPage.coverImage = data.coverImage
        currentPage.propertyAddress = data.address ?? currentPage.propertyAddress

        // Persist to Firestore
        pageStore.updatePage(.property(currentPage))
    }
}
