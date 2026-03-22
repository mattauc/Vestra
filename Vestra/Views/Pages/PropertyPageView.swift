//
//  PropertyPageView.swift
//  Vestra
//
//  Created by Matthew Auciello on 22/3/2026.
//

import SwiftUI

struct PropertyPageView: View {
    
    let pageID: UUID
    @EnvironmentObject private var pageStore: PageStore
    
    var body: some View {
        Text("PAGE")
//        Form{
//            TextField("Title", text: )
//        }
    }
}

#Preview {
    let auth = AuthManager()
    auth.currentUser = UserProfile.MOCK_USER
    
    return PropertyPageView(pageID: UUID())
        .environmentObject(PageStore(authManager: auth))
}
