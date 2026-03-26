//
//  PageTypeTab.swift
//  Vestra
//
//  Created by Matthew Auciello on 25/3/2026.
//

import SwiftUI

struct PageTypeTab: View {
    
    @EnvironmentObject private var pageStore: PageStore
    
    var portfolioImage: Image
    var portfolioType: PortfolioPage
    var availableYet: Bool = false
    @Binding var sheetPresented: Bool
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationStack {
            Button {
                
                let newPage = pageStore.createPage(newPage: portfolioType)
                path = NavigationPath([newPage])
                sheetPresented = false
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                        .frame(height: 160)
                        .shadow(radius: 4, x: 1, y: 5)
                    HStack {
                        portfolioImage
                            .font(.largeTitle)
                            .foregroundStyle(availableYet ? Color.blue : Color.red)
                            .padding(.horizontal)
                        Text(portfolioType.kindLabel)
                            .font(.largeTitle)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.largeTitle)
                            .padding(.horizontal)
                    }
                }
            }
            .disabled(!availableYet)
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    @Previewable @State var sheetPresented = true
    let auth = AuthManager()
    PageTypeTab(
        portfolioImage: Image(systemName: "plus.circle.fill"),
        portfolioType: .property(PropertyPage()),
        availableYet: true,
        sheetPresented: $sheetPresented,
        path: $path
    )
        .environmentObject(PageStore(authManager: auth))
}
