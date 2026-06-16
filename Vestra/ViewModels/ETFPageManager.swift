//
//  ETFPageManager.swift
//  Vestra
//
//  Created by Matthew Auciello on 3/6/2026.
//

import Foundation
import Combine

@MainActor
final class ETFPageManager: ObservableObject {

    private let pageId: UUID
    private let pageStore: PageStore
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var currentPage: ETFPage

    init(pageId: UUID, pageStore: PageStore) {
        self.pageId = pageId
        self.pageStore = pageStore
        if let portfolio = pageStore.pages.first(where: { $0.id == pageId }),
           case .etf(let e) = portfolio {
            self.currentPage = e
        } else {
            // Previews (and some edge cases) may initialize before `PageStore` has loaded pages.
            // Default to an empty page instead of crashing.
            self.currentPage = ETFPage()
        }

        // Keep currentPage in sync whenever PageStore.pages changes — including
        // updates pushed by the backend worker via the Firestore snapshot listener.
        pageStore.$pages
            .sink { [weak self] pages in
                guard let self else { return }
                if let portfolio = pages.first(where: { $0.id == self.pageId }),
                   case .etf(let updated) = portfolio {
                    self.currentPage = updated
                }
            }
            .store(in: &cancellables)
    }
}
