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
    
    var body: some View {
        NavigationStack {
            Button {
                pageStore.createPage(newPage: portfolioType)
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
    let auth = AuthManager()
    PageTypeTab(portfolioImage: Image(systemName: "plus.circle.fill"), portfolioType: .property(PropertyPage()), availableYet: true)
        .environmentObject(PageStore(authManager: auth))
}
