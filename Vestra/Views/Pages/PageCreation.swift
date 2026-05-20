//
//  PageCreation.swift
//  Vestra
//
//  Created by Matthew Auciello on 25/3/2026.
//

import SwiftUI

struct PageCreation: View {
    
    @EnvironmentObject private var pageStore: PageStore
    @Binding var sheetPresented: Bool
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Create a page.")
                    .font(Font.theme.display(50).bold())
                          .padding(.bottom, 8)
                Text("PORTFOLIO TYPE")
                    .font(Font.theme.mono(20))
                    .tracking(1.4)
                    .foregroundStyle(Color.theme.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical)
                PageTypeTab(
                    portfolioImage: Image(systemName: "house"),
                    portfolioType: .property(PropertyPage()),
                    availableYet: true,
                    sheetPresented: $sheetPresented,
                    path: $path
                )
                .padding(.bottom, 25)
                
                PageTypeTab(
                    portfolioImage: Image(systemName: "chart.bar.fill"),
                    portfolioType: .etf(ETFPage()),
                    availableYet: true,
                    sheetPresented: $sheetPresented,
                    path: $path
                )
                .padding(.bottom, 25)

                PageTypeTab(
                    portfolioImage: Image(systemName: "bitcoinsign.circle.fill"),
                    portfolioType: .crypto(CryptoPage()),
                    availableYet: true,
                    sheetPresented: $sheetPresented,
                    path: $path
                )
                .padding(.bottom, 25)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .font(Font.theme.display(40))
            .toolbar {
                Button {
                    sheetPresented = false
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    let auth = AuthManager()
    PageCreation(sheetPresented: .constant(true), path: $path)
        .environmentObject(PageStore(authManager: auth))
}
