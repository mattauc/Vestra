//
//  VestraInterface.swift
//  Vestra
//
//  Created by Matthew Auciello on 2/11/2025.
//

import SwiftUI

struct VestraInterface: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var authManager: AuthManager
    
    
    
    var body: some View {
        Group {
            if authManager.userSession != nil {
                DashboardView()
                    .onAppear { print("DEBUG: showing Dashboard (userSession != nil)") }
            } else {
                LoginView()
            }
        }
    }
}

struct NetlyInterface_Previews: PreviewProvider {
    static var previews: some View {
        let auth = AuthManager()
        return VestraInterface()
            .environmentObject(auth)
            .environmentObject(UserManager(authManager: auth))
    }
}
