//
//  PropertyPageView.swift
//  Vestra
//
//  Created by Matthew Auciello on 22/3/2026.
//

import SwiftUI

struct PropertyPageView: View {
    
    @EnvironmentObject private var pageStore: PageStore
    
    let pageId: UUID
    @Binding var pageIndex: Int
    
    var body: some View {
        VStack {
            Text("PAGE" + " \(pageStore.pages.count)")
            closeButton
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

#Preview {
    @Previewable @State var pageIndex = 0
    let auth = AuthManager()
    auth.currentUser = UserProfile.MOCK_USER
    
    return PropertyPageView(pageId: UUID(), pageIndex: $pageIndex)
        .environmentObject(PageStore(authManager: auth))
}
