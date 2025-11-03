//
//  DashboardView.swift
//  Vestra
//
//  Created by Matthew Auciello on 2/11/2025.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        if let user = authManager.currentUser {
            VStack {
                Button {
                    authManager.signOut()
                } label: {
                    HStack {
                        Text("SIGN OUT")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.left")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                    .background(.red)
                }
            }
        }
    }
}

#Preview {
    DashboardView()
}
