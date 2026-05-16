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
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                          .fill(Color.theme.surface)
                          .frame(height: 120)
                          .overlay(alignment: .leading) {
                                Rectangle()
                                    .fill(accentColor)
                                    .frame(width: 13)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                          .shadow(radius: 4, x: 1, y: 5)
                    HStack {
                        ZStack {
                            Circle()
                                .fill(accentColor)
                                .frame(height: 80)
                            portfolioImage
                                .font(.system(size: 35))
                                .foregroundStyle(Color.black)
                        }
                        .padding(.leading, 25)
                        
                        
                        
                        VStack(alignment: .leading) {
                            Text(portfolioType.kindLabel)
                                .font(Font.theme.display(30, weight: .black))
                                .foregroundStyle(Color.theme.primaryText)
                            Text(portfolioType.kindDescription)
                                  .font(Font.theme.ui(18))
                                  .foregroundStyle(Color.theme.primaryText)
                                  .lineLimit(2)
                                  .minimumScaleFactor(0.6)
                                  .multilineTextAlignment(.leading)
                                  .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.leading, 10)
                        
                            
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.title)
                            .padding(.trailing)
                            .foregroundStyle(Color.black)
                    }
                }
            }
            .disabled(!availableYet)
        }
    }
    
    private var accentColor: Color {
        switch portfolioType {
        case .property: return Color.theme.property
        case .etf:      return Color.theme.etf
        case .crypto:   return Color.theme.crypto
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    @Previewable @State var sheetPresented = true
    let auth = AuthManager()
    PageTypeTab(
        portfolioImage: Image(systemName: "house"),
        portfolioType: .property(PropertyPage()),
        availableYet: true,
        sheetPresented: $sheetPresented,
        path: $path
    )
        .environmentObject(PageStore(authManager: auth))
}
