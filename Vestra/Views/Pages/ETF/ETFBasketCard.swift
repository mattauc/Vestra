//
//  ETFBasketCard.swift
//  Vestra
//
//  Created by Matthew Auciello on 4/6/2026.
//

import SwiftUI

struct ETFBasketCard: View {
    @ObservedObject var manager: ETFPageManager
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Text("Your basket")
                    .font(Font.theme.display(20).bold())
                    .padding()
                Spacer()
                Text("3 ETFs")
                    .foregroundStyle(Color.theme.etf)
                    .font(Font.theme.display(20).bold())
                    .padding()
            }
            addETFButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 1, y: 1)
        )
    }
    
    var addETFButton: some View {
        HStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundStyle(Color.theme.etf)
            Text("Add ETFs")
                .font(.title2.bold())
                .foregroundStyle(Color.theme.etf)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.theme.etf.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    Color.theme.etf,
                    style: StrokeStyle(lineWidth: 1.5, dash: [5])
                )
        )
        .padding()
    }
}

#Preview {
    let auth = AuthManager()
    auth.currentUser = UserProfile.MOCK_USER
    let store = PageStore(authManager: auth)
    let page = ETFPage()
    store.addPage(.etf(page))
    let manager = ETFPageManager(pageId: page.id, pageStore: store)
    return ETFBasketCard(manager: manager)
        .padding()
}
