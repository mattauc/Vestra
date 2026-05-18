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
                topBar
                VStack {
                    if pageStore.pages.isEmpty {

                    } else {
                            ZStack {
                                ForEach(pageStore.pages) { page in
                                    PageView(page: page, pageIndex: $pageIndex, path: $path)
                                }
                            }
                    }
                    Spacer()
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
        }
    }
    
    var emptyPageDisplay: some View {
        Text("Your Studio.")
            .font(Font.theme.display(50))
    }
    
    var addPageButton: some View {
        Button { sheetPresented = true } label: {
            Image(systemName: "plus")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(Color.theme.onAccent)
                .frame(width: 52, height: 52)
                .background(Color.theme.accent, in: Circle())
        }
    }
    
    var topBar: some View {
        HStack() {
            VStack(alignment: .leading) {
                Text(String(pageStore.pages.count) + " PAGES")
                    .font(Font.theme.ui(15))
                    .foregroundStyle(Color.black.opacity(0.7))
                Text("Your Studio.")
                    .font(Font.theme.display(40))
            }
            Spacer()
            addPageButton
                .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    
//    var filterButtons: some View {
//        HStack {
//            Button {
//                
//            }
//            Button {
//                
//            }
//            Button {
//                
//            }
//            Button {
//                
//            }
//            Button {
//                
//            }
//        }
//    }
}

#Preview {
    let auth = AuthManager()
    PageStoreView()
        .environmentObject(PageStore(authManager: auth))
}
