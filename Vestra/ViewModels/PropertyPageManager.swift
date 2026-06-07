//
//  PropertyPageManager.swift
//  Vestra
//
//  Created by Matthew Auciello on 26/3/2026.
//

import Foundation
import Combine
import CoreLocation

@MainActor
final class PropertyPageManager: ObservableObject {

    private let pageId: UUID
    private let pageStore: PageStore
    private var cancellables = Set<AnyCancellable>()

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

        // Keep currentPage in sync whenever PageStore.pages changes — including
        // updates pushed by the backend worker via the Firestore snapshot listener.
        pageStore.$pages
            .sink { [weak self] pages in
                guard let self else { return }
                if let portfolio = pages.first(where: { $0.id == self.pageId }),
                   case .property(let updated) = portfolio {
                    self.currentPage = updated
                }
            }
            .store(in: &cancellables)
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
    
    var coverImage: String {
        currentPage.propertyData?.coverImage ?? ""
    }

    var equity: Double {
        estimateMidPrice - currentPage.loanBalance
    }

    var interestRate: Double {
        currentPage.interestRate
    }
    
    var strataPrice: Double {
        currentPage.expenses?.strata ?? 0.0
    }

    var councilRatesPrice: Double {
        currentPage.expenses?.councilRates ?? 0.0
    }
    
    var firstYearPerformance: Double {
        currentPage.propertyData?.suburbPerformance?.cagr1yPercent ?? 0.0
    }
    
    var thirdYearPerformance: Double {
        currentPage.propertyData?.suburbPerformance?.cagr3yPercent ?? 0.0
    }
    
    var fithYearPerformance: Double {
        currentPage.propertyData?.suburbPerformance?.cagr5yPercent ?? 0.0
    }

    var insurancePrice: Double {
        currentPage.expenses?.insurance ?? 0.0
    }

    var maintenancePrice: Double {
        currentPage.expenses?.maintenance ?? 0.0
    }

    var totalExpenses: Double {
        strataPrice + councilRatesPrice + insurancePrice + maintenancePrice
    }
    
    var soldHistory: [SalesHistoryEntry] {
        currentPage.propertyData?.salesHistory ?? []
    }

    func setExpensesLocally(strata: Double, councilRates: Double, insurance: Double, maintenance: Double) {
        currentPage.expenses = Expenses(strata: strata, councilRates: councilRates, insurance: insurance, maintenance: maintenance)
    }

    func persistCurrentPage() {
        pageStore.updatePage(.property(currentPage))
    }

    func setInterestRateLocally(_ value: Double) {
        currentPage.interestRate = value
    }

    var loanTerm: Int {
        currentPage.loanTerm
    }

    func setLoanTermLocally(_ value: Int) {
        currentPage.loanTerm = value
    }
    
    var isEstimatePositive: Bool {
        currentPage.propertyData?.estimate?.mid ?? 0.0 > currentPage.propertyData?.salesHistory?.first?.price ?? 0.0
    }

    var monthlyRepayment: Double {
        let r = currentPage.interestRate / 100 / 12
        let n = Double(currentPage.loanTerm * 12)
        guard n > 0 else { return 0 }
        guard r > 0 else { return currentPage.loanBalance / n }
        return currentPage.loanBalance * (r * pow(1 + r, n)) / (pow(1 + r, n) - 1)
    }

    // MARK: - Cash flow

    /// Rent is stored weekly; convert to a monthly figure to match repayment/expenses.
    var monthlyRent: Double {
        rentalEstimate * 52 / 12
    }

    var monthlyOutgoings: Double {
        monthlyRepayment + totalExpenses
    }

    var monthlyCashFlow: Double {
        monthlyRent - monthlyOutgoings
    }

    var annualCashFlow: Double {
        monthlyCashFlow * 12
    }

    var isNegativelyGeared: Bool {
        monthlyCashFlow < 0
    }

    /// Share of monthly outgoings covered by rent (0...1) — drives the coverage bar.
    var rentCoverage: Double {
        guard monthlyOutgoings > 0 else { return monthlyRent > 0 ? 1 : 0 }
        return min(1, max(0, monthlyRent / monthlyOutgoings))
    }

    var yearsHeld: String {
        let currentYear = Calendar.current.component(.year, from: Date())
        let date = currentPage.propertyData?.lastSoldDate?.formattedYearMonth() ?? String(currentYear)
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
        let date = currentPage.propertyData?.lastSoldDate?.formattedYearMonth() ?? "—"
        return "\(type) . \(beds) BR . \(baths) BA . \(date)"
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


        await requestEnrichment(
            streetNumber: unit+streetNumber,
            streetName: streetName,
            suburb: suburb,
            state: state,
            postcode: postcode
        )
    }
    
    /// Ask the backend to enrich this property. Fire-and-forget — the worker
    /// writes the result directly to Firestore, and the snapshot listener
    /// delivers it to `currentPage` via the `pageStore.$pages` sink in init.
    func requestEnrichment(streetNumber: String, streetName: String, suburb: String, state: String, postcode: String) async {
        guard let uid = pageStore.currentUid else {
            print("requestEnrichment: no authenticated user")
            return
        }

        // 1. Mark the page as enriching + persist so the UI shows a pending state
        //    immediately, before the network request even starts.
        currentPage.enrichmentStatus = .enriching
        pageStore.updatePage(.property(currentPage))

        // 2. Fire-and-forget the enrich request. We never read the response body —
        //    the worker writes enriched data straight to Firestore.
        do {
            try await NetworkManager.shared.request(
                PropertyEndpoint.enrichProperty(
                    uid: uid,
                    pageId: pageId.uuidString,
                    address: .init(
                        streetNumber: streetNumber,
                        streetName: streetName,
                        suburb: suburb,
                        state: state,
                        postcode: postcode
                    )
                )
            )
        } catch {
            // If the HTTP request itself fails (network down, backend unreachable),
            // flip the page to failed so the UI can show a retry option.
            print("requestEnrichment failed: \(error)")
            currentPage.enrichmentStatus = .failed
            pageStore.updatePage(.property(currentPage))
        }
    }
}
