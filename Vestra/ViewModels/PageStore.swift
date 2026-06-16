//
//  PageStore.swift
//  Vestra
//
//  Created by Matthew Auciello on 2/11/2025.
//

import Combine
import FirebaseFirestore
import Foundation

/// Central store for all portfolio pages. Property only for now; add ETF/Crypto arrays or a unified type later.
@MainActor
final class PageStore: ObservableObject {

    @Published private(set) var pages: [PortfolioPage] = []

    private let authManager: AuthManager
    private var cancellables = Set<AnyCancellable>()
    private var reloadTask: Task<Void, Never>?
    private var pagesListener: ListenerRegistration?

    deinit {
        pagesListener?.remove()
    }

    init(authManager: AuthManager) {
        self.authManager = authManager

        // `@Published` emits its current value immediately on subscription, so this
        // also covers the initial load — no separate launch Task needed.
        authManager.$userSession
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { await self?.scheduleReload() }
            }
            .store(in: &cancellables)
    }

    /// Serializes reload requests so listener attach/detach can't race with itself.
    private func scheduleReload() {
        let previous = reloadTask
        reloadTask = Task { [weak self] in
            await previous?.value
            await self?.reloadForCurrentUser()
        }
    }

    /// Property pages that count toward the dashboard (`activeInvestment` until you add `includedInDashboard`).
    var propertyPagesForDashboard: [PortfolioPage] {
        pages.filter(\.activeInvestment)
    }

    /// Current authenticated user's UID — needed by callers that send requests
    /// to the backend with the user's identity.
    var currentUid: String? {
        authManager.userSession?.uid
    }
    
    @discardableResult
    func createPage(newPage: PortfolioPage) -> PortfolioPage {
        addPage(newPage)
        return newPage
    }
    
    func addPage(_ page: PortfolioPage) {
        // Optimistic local append so the UI shows the new page immediately.
        // The Task captures `page` by value, so it's immune to subsequent
        // listener mutations of `self.pages`.
        pages.append(page)
        Task { await write(page) }
    }

    func updatePage(_ page: PortfolioPage) {
        guard let i = pages.firstIndex(where: { $0.id == page.id }) else { return }
        pages[i] = page
        Task { await write(page) }
    }

    func deletePage(id: UUID) {
        pages.removeAll { $0.id == id }
        Task { await deleteFromFirestore(id: id) }
    }

    private func reloadForCurrentUser() async {
        guard authManager.userSession != nil else {
            pagesListener?.remove()
            pagesListener = nil
            pages = []
            return
        }
        attachPagesListener()
    }

    private var pagesCollection: CollectionReference? {
        guard let uid = authManager.userSession?.uid else { return nil }
        return Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("pages")
    }

    /// Attaches a real-time listener to the user's `pages` collection.
    /// Fires immediately with current data, then again whenever any doc changes —
    /// including writes made by the backend worker.
    private func attachPagesListener() {
        pagesListener?.remove()
        pagesListener = nil

        guard let coll = pagesCollection else {
            pages = []
            return
        }

        pagesListener = coll.addSnapshotListener { [weak self] snapshot, error in
            Task { @MainActor in
                guard let self else { return }
                if let error {
                    print("DEBUG: PageStore listener error — \(error.localizedDescription)")
                    return
                }
                guard let snapshot else { return }

                let decoded = snapshot.documents.compactMap { doc -> PortfolioPage? in
                    try? doc.data(as: PortfolioPage.self)
                }
                self.pages = decoded.sorted {
                    $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
            }
        }
    }

    /// Writes a single page to Firestore. The caller passes in the page by value,
    /// so this is safe even if `self.pages` is mutated concurrently by the listener.
    private func write(_ page: PortfolioPage) async {
        guard let coll = pagesCollection else { return }
        do {
            let data = try Firestore.Encoder().encode(page)
            try await coll.document(page.id.uuidString).setData(data)
        } catch {
            print("DEBUG: PageStore write failed — \(error.localizedDescription)")
        }
    }

    /// Deletes a single page from Firestore by id.
    private func deleteFromFirestore(id: UUID) async {
        guard let coll = pagesCollection else { return }
        do {
            try await coll.document(id.uuidString).delete()
        } catch {
            print("DEBUG: PageStore delete failed — \(error.localizedDescription)")
        }
    }
}
