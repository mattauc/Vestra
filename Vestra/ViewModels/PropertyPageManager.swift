//
//  PropertyPageManager.swift
//  Vestra
//
//  Created by Matthew Auciello on 26/3/2026.
//

import Foundation

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
    
    
    
    

    
    
}
