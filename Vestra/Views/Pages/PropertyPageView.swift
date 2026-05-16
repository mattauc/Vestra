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
    
    private let cardHeight: CGFloat = 250
    private let cardWidth: CGFloat = 400
    
    var body: some View {
        ZStack {
            Color.theme.background
            
            ScrollView(.vertical) {
                VStack {
                    GroupBox(label: titleDisplay
                        .fixedSize(horizontal: false, vertical: true)) {
                        VStack() {
                            Text("1BR . Purchased Dec 2025")
                                .font(Font.theme.ui(15))
                                .foregroundStyle(Color.theme.onAsset.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            StriatedPlaceholder(color: Color.theme.property, label: "PROPERTY / PHOTO")
                                .frame(height: 80)
                                .padding(.top)
                
                        }
                        
                        
                    }
                    .padding()
                    .groupBoxStyle(.custom(for: .property(PropertyPage())))
                    .frame(width: cardWidth, height: cardHeight)

                    closeButton
                }
            }
            .padding(.top, 120)
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
          }

        .ignoresSafeArea()
        // CONSIDER DOING THIS PRIOR TO DISAPPEAR TO MAKE UPDATING LOOK MORE SEAMLESS
//        .onDisappear() {
//            if pageStore.pages.contains(where: { $0.id == pageId }) {
//                pageStore.updatePage(.property(manager.currentPage))
//            }
//        }
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
                        pageStore.updatePage(.property(manager.currentPage))
                    }
            } else {
                Text(manager.title == "" ? "New Property" : manager.title)
                    .font(.largeTitle.weight(.bold))
                    .font(.largeTitle.weight(.bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
            }
            Spacer()
            Button {
                isEditingTitle = true
            } label: {
                Image(systemName: "pencil")
                    .font(.title2)
                    .foregroundStyle(Color.theme.onAccent)
            }
        }
        .frame(height: 60)

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
