//
//  NetlyInterface.swift
//  Netly
//
//  Created by Matthew Auciello on 2/11/2025.
//

import SwiftUI

struct NetlyInterface: View {
     @StateObject var userManager = UserManager()
    
    
    var body: some View {
        VStack {
            Text("Networth: $" + String(userManager.userNetworth))
            Text("Salary: $" + String(format: "%.2f", userManager.userSalary))
        }
    }
}

struct NetlyInterface_Previews: PreviewProvider {
    static var previews: some View {
        NetlyInterface()
    }
}
