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
    
    @State private var sheetPresented = false
    @State var path = NavigationPath()
    
    
    var body: some View {
        VStack {
            NavigationStack(path: $path) {
                VStack {
                    if pageStore.pages.isEmpty {
                        emptyPageDisplay
                            .padding(.top, 300)
                    } else {
                            ZStack {
                                ForEach(pageStore.pages) { page in
                                    PageView(page: page, pageIndex: $pageIndex, path: $path)
                                }
                            }
                            .padding(.vertical, 30)
                    }
                    addPageButton
                        .padding()
                }
                .navigationDestination(for: PortfolioPage.self) { page in
                    switch page {
                    case .property(let p):
                        PropertyPageView(
                                manager: PropertyPageManager(pageId: p.id, pageStore: pageStore),
                                pageId: p.id,
                                pageIndex: $pageIndex,
                                path: $path
                            )
                    case .etf(let e):
                        ETFPageView(pageId: e.id, pageIndex: $pageIndex, path: $path)
                    case .crypto(_):
                        EmptyView() // or CryptoPageView
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
//            VStack {
//                Capsule()
//                    .frame(width: 300, height: 200)
//            }
        }
    }
    
    var emptyPageDisplay: some View {
        Text("Your Studio.")
            .font(Font.theme.display(50))
    }
    
    private var addPageButton: some View {
        Button { sheetPresented = true } label: {
            Label("Add Portfolio", systemImage: "plus")
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.theme.onAccent)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.theme.accent, in: Capsule())
        }
    }
}

#Preview {
    let auth = AuthManager()
    PageStoreView()
        .environmentObject(PageStore(authManager: auth))
}
