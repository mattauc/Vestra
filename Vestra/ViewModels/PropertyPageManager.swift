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
        currentPage.coverImage = data.coverImage
        currentPage.propertyAddress = data.address ?? currentPage.propertyAddress

        // Persist to Firestore
        pageStore.updatePage(.property(currentPage))
    }
}
