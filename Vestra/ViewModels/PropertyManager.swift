//
//  PropertyManager.swift
//  Vestra
//
//  Created by Matthew Auciello on 2/11/2025.
//

import Foundation

final class PropertyManager: ObservableObject {
    
    @Published private(set) var propertyStream: PropertyStream
    
    init() {
        self.propertyStream = PropertyStream()
    }
    
}
