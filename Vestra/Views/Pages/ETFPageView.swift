//
//  ETFPageView.swift
//  Vestra
//
//  Created by Matthew Auciello on 25/3/2026.
//

import SwiftUI

struct ETFPageView: View {
    
    @EnvironmentObject private var pageStore: PageStore
    
    let pageId: UUID
    @Binding var pageIndex: Int
    
    var body: some View {
        ZStack {
            Color(.red)
            VStack {
                Text("ETF" + " \(pageId)")
                closeButton
            }
        }

    }
    
    var closeButton: some View {
        Button {
            pageStore.deletePage(id: pageId)
            if pageStore.pages.isEmpty {
                    pageIndex = 0
                } else {
                    pageIndex = min(pageIndex, pageStore.pages.count - 1)
                }
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close")
    }
}

//#Preview {
//    ETFPageView()
//}
