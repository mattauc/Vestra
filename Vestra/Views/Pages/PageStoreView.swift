//
//  PageStoreView.swift
//  Vestra
//
//  Created by Matthew Auciello on 22/3/2026.
//

import SwiftUI

struct PageStoreView: View {
    
    @EnvironmentObject private var pageStore: PageStore
    
    @State var pageIndex: Int = 0
    @State private var xOffset: CGFloat = 0
//    @State private var yOffset: CGFloat = 0
    @State private var degrees: Double = 0
    @State private var selectedTab: Int = 0
    @State private var scrollOffset = 0.0
    
    @State private var sheetPresented = false
    @State var path = NavigationPath()
    @State private var cardOrder: [UUID] = []
    @State private var cardScrollPosition: UUID?
    

    private let cardSpacerHeight: CGFloat = UIScreen.main.bounds.height / 2
    
    
    var body: some View {
        VStack {
            NavigationStack(path: $path) {
                topBar
                VStack {
                    if pageStore.pages.isEmpty {
                        Spacer()
                    } else {
                        // Cards — on top at rest, behind when scrolling
                        VStack(spacing: 8) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 0) {
                                    ForEach(orderedPages) { page in
                                        PageView(page: page, pageIndex: $pageIndex, path: $path, onSwiped: {
                                            sendToBottom(page)
                                        })
                                        .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                                    }
                                }
                                .scrollTargetLayout()
                                .onAppear {
                                    selectedTab = 0
                                    cardOrder = filteredPages.map { $0.id }
                                }
                            }
                            .scrollPosition(id: $cardScrollPosition)
                            .scrollTargetBehavior(.viewAligned)

                            // Dot indicators
                            HStack(spacing: 6) {
                                ForEach(orderedPages) { page in
                                    Circle()
                                        .fill(cardScrollPosition == page.id ? Color.theme.primaryText : Color.theme.tertiaryText)
                                        .frame(width: 7, height: 7)
                                }
                            }
                        }
                        
                        // ScrollView — grouped by asset type
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                                ForEach(["Property", "ETF", "Crypto"], id: \.self) { section in
                                    if let pages = groupedPages[section], !pages.isEmpty {
                                        
                                        Section {
                                            ForEach(pages) { page in
                                                PageColumns(page: page)
                                                    .padding(.top, 10)
                                            }
                                        } header: {
                                            HStack {
                                                groupedPages[section]?.first?.kindImage
                                                      .font(.title2.bold())
                                                      .foregroundStyle(Color.white)
                                                      .frame(width: 35, height: 35)
                                                      .padding(5)
                                                  Text(section)
                                                      .font(.title3.bold())
                                                      .foregroundStyle(Color.white)
                                                      .lineLimit(1)
                                                      .frame(maxWidth: .infinity, alignment: .leading)
                                                  Spacer()
                                              }
                                            .background(groupedPages[section]?.first?.kindColor)
                                        }
                                    }
                                }
                            }
                        }
                        .scrollBounceBehavior(.basedOnSize)
                        .background(Color.clear)
                        .scrollContentBackground(.hidden)

                        
                    }
                }
                .navigationDestination(for: PortfolioPage.self) { page in
                    switch page {
                    case .property(let p):
                        PropertyPageView(
                                pageId: p.id,
                                pageStore: pageStore,
                                pageIndex: $pageIndex,
                                path: $path
                            )
                    case .etf(let e):
                        ETFPageView(pageId: e.id, pageIndex: $pageIndex, path: $path)
                    case .crypto(let c):
                        CryptoPageView(pageId: c.id, pageIndex: $pageIndex, path: $path)
                    }
                }
            }
            .toolbar(path.isEmpty ? .visible : .hidden, for: .tabBar)
            .onChange(of: pageStore.pages.count) { _, newCount in
                guard newCount > 0 else {
                    pageIndex = 0
                    return
                }
                pageIndex = min(pageIndex, newCount - 1)
            }
            .sheet(isPresented: $sheetPresented) {
                PageCreation(sheetPresented: $sheetPresented, path: $path)
                    .presentationDetents([.large, .large])
            }
        }
    }
      
    var orderedPages: [PortfolioPage] {
        cardOrder.compactMap { id in
            filteredPages.first(where: { $0.id == id })
        }
    }

    var groupedPages: [String: [PortfolioPage]] {
        Dictionary(grouping: orderedPages, by: \.kindLabel)
    }
    
    func sendToBottom(_ page: PortfolioPage) {
        cardOrder.removeAll(where: { $0 == page.id })
        cardOrder.insert(page.id, at: 0)  // insert at bottom (ZStack renders last on top)
    }


    
    var emptyPageDisplay: some View {
        Text("Your Studio.")
            .font(Font.theme.display(50))
    }
    
    var addPageButton: some View {
        Button {
            sheetPresented = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(Color.theme.onAccent)
                .frame(width: 52, height: 52)
                .background(Color.theme.accent, in: Circle())
        }
    }
    
    var filteredPages: [PortfolioPage] {
          switch selectedTab {
          case 0: return pageStore.pages
          case 1: return pageStore.pages.filter { $0.isProperty }
          case 2: return pageStore.pages.filter { $0.isETF }
          case 3: return pageStore.pages.filter { $0.isCrypto }
          default: return pageStore.pages
          }
      }

    
    var topBar: some View {
        HStack() {
            VStack(alignment: .leading) {
//                Text(String(pageStore.pages.count) + " PAGES")
//                    .font(Font.theme.ui(15))
//                    .foregroundStyle(Color.black.opacity(0.7))
                Text("Your Studio.")
                    .font(Font.theme.display(40))
                filterButtons
            }
            Spacer()
            addPageButton
                .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.horizontal, .top])
        .padding(.bottom, 5)
    }
    
    var filterButtons: some View {
        HStack {
            Button {
                selectedTab = 0
            } label: {
                Text("All - " + String(pageStore.pages.count))
            }
            .buttonStyle(PortfolioTabButton.customTab(for: selectedTab == 0))
            Button {
                selectedTab = 1
            } label: {
                Text("Property")
            }
            .buttonStyle(PortfolioTabButton.customTab(for: selectedTab == 1))
            Button {
                selectedTab = 2
            } label: {
                Text("ETFs")
            }
            .buttonStyle(PortfolioTabButton.customTab(for: selectedTab == 2))
            Button {
                selectedTab = 3
            } label: {
                Text("Crypto")
            }
            .buttonStyle(PortfolioTabButton.customTab(for: selectedTab == 3))
        }
    }

}

#Preview {
    let auth = AuthManager()
    PageStoreView()
        .environmentObject(PageStore(authManager: auth))
}
