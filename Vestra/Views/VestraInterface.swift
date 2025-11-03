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
            } else {
                LoginView()
            }
        }
    }
}

struct NetlyInterface_Previews: PreviewProvider {
    static var previews: some View {
        VestraInterface()
    }
}
