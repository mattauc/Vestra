//
//  NetlyApp.swift
//  Netly
//
//  Created by Matthew Auciello on 2/11/2025.
//

import SwiftUI

@main
struct NetlyApp: App {
    @StateObject var userManager = UserManager()
    
    var body: some Scene {
        WindowGroup {
            NetlyInterface()
                .environmentObject(userManager)
        }
    }
}
