//
//  ETFPageView.swift
//  Vestra
//
//  Created by Matthew Auciello on 25/3/2026.
//

import SwiftUI

struct ETFPageView: View {

    @EnvironmentObject private var pageStore: PageStore
    @StateObject private var manager: ETFPageManager

    let pageId: UUID
    @Binding var pageIndex: Int
    @Binding var path: NavigationPath

    init(pageId: UUID, pageStore: PageStore, pageIndex: Binding<Int>, path: Binding<NavigationPath>) {
        self.pageId = pageId
        _pageIndex = pageIndex
        _path = path
        _manager = StateObject(wrappedValue: ETFPageManager(pageId: pageId, pageStore: pageStore))
    }

    var body: some View {
        ZStack {
            Color.theme.depth
                .ignoresSafeArea()

            BlockGridView(manager: manager, accent: Color.theme.etf) { block in
                blockView(for: block)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.fill")
                    Text("ETF")
                        .font(Font.theme.display(15))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.theme.etf, in: Capsule())
                .foregroundStyle(Color.theme.onAsset)
            }
            ToolbarItem(placement: .topBarTrailing) {
                addEmptyBlockButton
            }
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            ToolbarItem(placement: .topBarTrailing) {
                closeButton
            }
        }
    }

    /// The only page-specific piece: which card each ETF block kind maps to.
    @ViewBuilder
    private func blockView(for block: Block) -> some View {
        switch block.kind {
        case .projection: ETFProjectionCard()
        case .basket: ETFBasketCard(manager: manager)
        case .assumptions: ETFAssumptionsCard()
        default: EmptyView()   // non-ETF / placeholder kinds handled by BlockGridView
        }
    }

    var addEmptyBlockButton: some View {
        Button {
            manager.addRow()
        } label: {
            Image(systemName: "plus")
                .font(.title3)
                .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close")
    }

    var closeButton: some View {
        Button {
            if path.count != 0 {
                self.path.removeLast()
            }
            pageStore.deletePage(id: pageId)
            if pageStore.pages.isEmpty {
                    pageIndex = 0
                } else {
                    pageIndex = min(pageIndex, pageStore.pages.count - 1)
                }
        } label: {
            Image(systemName: "xmark")
                .font(.title3)
                .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close")
    }
}

#Preview {
    @Previewable @State var pageIndex = 0
    @Previewable @State var path = NavigationPath()
    let store: PageStore = {
        let auth = AuthManager()
        auth.currentUser = UserProfile.MOCK_USER
        return PageStore(authManager: auth)
    }()

    ETFPageView(
        pageId: UUID(),
        pageStore: store,
        pageIndex: $pageIndex,
        path: $path
    )
    .environmentObject(store)
}
