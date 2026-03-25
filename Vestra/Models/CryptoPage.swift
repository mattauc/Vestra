//
//  CryptoPage.swift
//  Vestra
//
//  Created by Matthew Auciello on 25/3/2026.
//

import Foundation

struct CryptoPage: Codable, Equatable, PagePayload {
    var id = UUID()
    var title: String = ""
    var activeInvestment: Bool = true
}
