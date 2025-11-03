//
//  VestraApp.swift
//  Vestra
//
//  Created by Matthew Auciello on 2/11/2025.
//

import SwiftUI
import Firebase

@main
struct VestraApp: App {
    @StateObject var userManager = UserManager()
    @StateObject var authManager = AuthManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            VestraInterface()
                .environmentObject(userManager)
                .environmentObject(authManager)
        }
    }
}
