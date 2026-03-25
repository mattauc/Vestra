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
    
    
    var body: some View {
        VStack {
            if pageStore.pages.isEmpty {
                emptyPageDisplay
                    .padding(.top, 300)
            } else {
                VStack {
                    ZStack {
                        ForEach(pageStore.pages) { page in
                            PageView(page: page, pageIndex: $pageIndex)
                        }
                    }
                    .padding(.vertical, 30)
                }
            }
            NavigationStack {
                addPageButton
            }
            .sheet(isPresented: $sheetPresented) {
                PageCreation(sheetPresented: $sheetPresented)
                    .presentationDetents([.large, .large])
            }
            
        }
        .onChange(of: pageStore.pages.count) { _, newCount in
            guard newCount > 0 else {
                pageIndex = 0
                return
            }
            pageIndex = min(pageIndex, newCount - 1)
        }
    }
    
    var emptyPageDisplay: some View {
        Text("PLACEHOLDER EMPTY PAGES")
    }
    
    var addPageButton: some View {
        Button {
            sheetPresented = true
//            pageStore.createPage(type: .property)
        } label: {
            HStack {
                Text("ADD PAGE")
                    .fontWeight(.semibold)
                Image(systemName: "plus.circle.fill")
            }
            .foregroundColor(.white)
            .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            .background(.blue)
        }
    }
}

#Preview {
    let auth = AuthManager()
    PageStoreView()
        .environmentObject(PageStore(authManager: auth))
}
