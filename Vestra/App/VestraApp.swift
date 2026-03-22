//
//  VestraApp.swift
//  Vestra
//
//  Created by Matthew Auciello on 2/11/2025.
//

import SwiftUI
import Firebase

@MainActor
final class VestraAppModel: ObservableObject {
    let authManager: AuthManager
    let userManager: UserManager
    let pageStore: PageStore
    
    init() {
        let auth = AuthManager()
        self.authManager = auth
        self.userManager = UserManager(authManager: auth)
        self.pageStore = PageStore(authManager: auth)
    }
}

@main
struct VestraApp: App {
    @StateObject private var appModel = VestraAppModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            VestraInterface()
                .environmentObject(appModel.userManager)
                .environmentObject(appModel.authManager)
                .environmentObject(appModel.pageStore)
        }
    }
}
