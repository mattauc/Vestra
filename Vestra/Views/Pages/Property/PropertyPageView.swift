//
//  PropertyPageView.swift
//  Vestra
//
//  Created by Matthew Auciello on 22/3/2026.
//

import SwiftUI
import Kingfisher
import Charts

struct PropertyPageView: View {
    
    @EnvironmentObject private var pageStore: PageStore
    @StateObject private var manager: PropertyPageManager

    let pageId: UUID
    @Binding var pageIndex: Int
    @Binding var path: NavigationPath

    private let cardHeight: CGFloat = 320

    init(pageId: UUID, pageStore: PageStore, pageIndex: Binding<Int>, path: Binding<NavigationPath>) {
        self.pageId = pageId
        _pageIndex = pageIndex
        _path = path
        _manager = StateObject(wrappedValue: PropertyPageManager(pageId: pageId, pageStore: pageStore))
    }
    
    var body: some View {
        ZStack {
            Color.theme.depth
                .ignoresSafeArea()
            
            BlockGridView(manager: manager, accent: Color.theme.property) { block in
                blockView(for: block)
            }
//            ScrollView(.vertical, showsIndicators: false) {
//                LazyVStack(alignment: .leading, spacing: 7, pinnedViews: [.sectionHeaders]) {
//                    PropertyDetailCard(manager: manager)
//                    FinancialDataCard(manager: manager)
//                        .padding([.horizontal])
//                        .padding(.bottom, 5)
//                    SalesChartCard(manager: manager)
//                        .padding([.horizontal])
//                        .padding(.bottom, 5)
//                    LoanCard(manager: manager)
//                        .padding(.bottom, 5)
//                    HStack(alignment: .top) {
//                        ExpensesCard(manager: manager)
//                            .padding(.leading)
//                            .padding(.trailing, 5)
//                        CashFlowCard(manager: manager)
//                            .padding(.trailing)
//                    }
//                    .fixedSize(horizontal: false, vertical: true)
//                    Spacer()
//                }
//            }

        }
        .toolbar {
              ToolbarItem(placement: .principal) {
                  HStack(spacing: 6) {
                      Image(systemName: "house.fill")
                      Text("Property")
                          .font(Font.theme.display(15))
                  }
                  .padding(.horizontal, 12)
                  .padding(.vertical, 6)
                  .background(Color.theme.property, in: Capsule())
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
    
    @ViewBuilder
    private func blockView(for block: Block) -> some View {
        switch block.kind {
        case .details: PropertyDetailCard(manager: manager)
        case .financialData: FinancialDataCard(manager: manager)
        case .salesChart: SalesChartCard(manager: manager)
        case .loan: LoanCard(manager: manager)
        case .expenses: ExpensesCard(manager: manager)
        case .cashFlow: CashFlowCard(manager: manager)
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
    let auth = AuthManager()
    auth.currentUser = UserProfile.MOCK_USER

    let store = PageStore(authManager: auth)
    let pageId = UUID()

    return PropertyPageView(
        pageId: pageId,
        pageStore: store,
        pageIndex: $pageIndex,
        path: $path
    )
    .environmentObject(store)
}
