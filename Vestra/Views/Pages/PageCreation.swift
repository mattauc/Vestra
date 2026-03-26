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

                PageTypeTab(
                    portfolioImage: Image(systemName: "plus.circle.fill"),
                    portfolioType: .property(PropertyPage()),
                    availableYet: true,
                    sheetPresented: $sheetPresented,
                    path: $path
                )
                
                PageTypeTab(
                    portfolioImage: Image(systemName: "lock.fill"),
                    portfolioType: .etf(ETFPage()),
                    availableYet: true,
                    sheetPresented: $sheetPresented,
                    path: $path
                )

                PageTypeTab(
                    portfolioImage: Image(systemName: "lock.fill"),
                    portfolioType: .crypto(CryptoPage()),
                    sheetPresented: $sheetPresented,
                    path: $path
                )
            }
            .padding()
            .navigationTitle("Investment stream")
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
