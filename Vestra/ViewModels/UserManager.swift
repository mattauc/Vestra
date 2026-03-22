//
//  UserManager.swift
//  Vestra
//
//  Created by Matthew Auciello on 2/11/2025.
//

import Combine
import Foundation

extension UserDefaults {
    
}

@MainActor
final class UserManager: ObservableObject {
    
    @Published private(set) var profile: UserProfile?
    
    private var cancellables = Set<AnyCancellable>()
    private let authManager: AuthManager
    
    init(authManager: AuthManager) {
        self.authManager = authManager
        self.profile = authManager.currentUser
        
        authManager.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.profile = user
            }
            .store(in: &cancellables)
    }
    
    func updateSalary() {
        
    }
    
    var userName: String {
        profile?.fullname ?? "Unknown User"
    }
    
    var userNetworth: Int {
        profile?.networth ?? 0
    }
    
    var userSalary: Double {
        profile?.salary ?? 0
    }
    
}
