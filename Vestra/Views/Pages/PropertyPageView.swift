//
//  PropertyPageView.swift
//  Vestra
//
//  Created by Matthew Auciello on 22/3/2026.
//

import SwiftUI

struct PropertyPageView: View {
    
    @EnvironmentObject private var pageStore: PageStore
    @ObservedObject var manager: PropertyPageManager
    
    let pageId: UUID
    @Binding var pageIndex: Int
    @Binding var path: NavigationPath
    @State var pageTitle: String = ""
    @State var isEditingTitle = false
    
    var body: some View {
        ZStack {
            Color(.mint)
            VStack {
                titleDisplay
                
                
                Text("PROPERTY" + " \(pageId)")
                    .padding()
                
                
                closeButton
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
        .onDisappear() {
            if pageStore.pages.contains(where: { $0.id == pageId }) {
                pageStore.updatePage(.property(manager.currentPage))
            }
        }
    }
    
    var titleDisplay: some View {
        HStack {
            if isEditingTitle {
                TextField("New Property", text: $pageTitle)
                    .font(.largeTitle.weight(.black))
                    .textFieldStyle(.plain)
                    .onChange(of: pageTitle) { _, newValue in
                        manager.title = newValue
                    }
                    .onSubmit {
                        isEditingTitle = false
                    }
            } else {
                Text(manager.title == "" ? "New Property" : manager.title)
                    .font(.largeTitle.weight(.bold))
            }
            
            Button {
                isEditingTitle = true
            } label: {
                Image(systemName: "pencil")
                    .font(.title2)
                    .foregroundStyle(.black)
            }
        }
        .padding()
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
    @Previewable @State var path = NavigationPath()
    let auth = AuthManager()
    auth.currentUser = UserProfile.MOCK_USER

    let store = PageStore(authManager: auth)
    let pageId = UUID()
    let manager = PropertyPageManager(pageId: pageId, pageStore: store)

    return PropertyPageView(
        manager: manager,
        pageId: pageId,
        pageIndex: $pageIndex,
        path: $path
    )
    .environmentObject(store)
}
