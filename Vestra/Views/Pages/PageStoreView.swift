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
    
    
    var body: some View {
        Group {
            if pageStore.pages.isEmpty {
                emptyPageDisplay
            } else {
                VStack {
                    ZStack {
                        ForEach(pageStore.pages) { page in
                            PageView(page: page, pageIndex: $pageIndex)
                        }
                    }
                    .padding(.vertical, 30)
                    addPageButton
                }
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
        addPageButton
    }
    
    var addPageButton: some View {
        Button {
            pageStore.createPage(type: .property)
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
