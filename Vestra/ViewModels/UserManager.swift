//
//  UserManager.swift
//  Vestra
//
//  Created by Matthew Auciello on 2/11/2025.
//

import Foundation

extension UserDefaults {
    
}

@MainActor
final class UserManager: ObservableObject {
    
    @Published private(set) var profile: UserProfile
    @Published var propertyVM: PropertyManager
    
    init() {
        self.profile = UserProfile(id: NSUUID().uuidString, fullname: "Ashwin Gur", email: "ashwinguzzling@gmail.com")
        self.propertyVM = PropertyManager()
    }
    
    var userNetworth: Int {
        profile.networth
    }
    
    var userSalary: Double {
        profile.salary
    }
}
