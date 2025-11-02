//
//  UserProfile.swift
//  Netly
//
//  Created by Matthew Auciello on 2/11/2025.
//

import Foundation

struct UserProfile: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    
    var networth: Int = 1000000
    var salary: Double = 200000.00
    
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}

extension UserProfile {
    static var MOCK_USER = UserProfile(id: NSUUID().uuidString, fullname: "Ashwin Gur", email: "ashwinguzzling@gmail.com")
}
