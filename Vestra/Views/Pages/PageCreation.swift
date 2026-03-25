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
    
    var body: some View {
        NavigationStack {
            VStack {
                PageTypeTab(portfolioImage: Image(systemName: "plus.circle.fill"), portfolioType: .property(PropertyPage()), availableYet: true)
                
                PageTypeTab(portfolioImage: Image(systemName: "lock.fill"), portfolioType: .etf(ETFPage()), availableYet: true)
                
                PageTypeTab(portfolioImage: Image(systemName: "lock.fill"), portfolioType: .crypto(CryptoPage()))
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
    let auth = AuthManager()
    PageCreation(sheetPresented: .constant(true))
        .environmentObject(PageStore(authManager: auth))
}
