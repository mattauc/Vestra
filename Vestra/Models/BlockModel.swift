//
//  BlockModel.swift
//  Vestra
//
//  Created by Matthew Auciello on 16/6/2026.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct Block: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var kind: BlockKind
}

enum BlockKind: Codable, Equatable, Hashable {
    // content blocks (user-authored)
    case note(text: String)
    case section(title: String)
    
    // bound blocks (render from the asset; carry no data)
    case empty        // full-width "add a row" placeholder
    case emptyHalf    // half-width empty slot — the other half of a one-half row

    case cashFlow
    case loan
    case details
    case financialData
    case expenses
    case salesChart
    
    case projection      // ETF
    case basket          // ETF
    case assumptions
}

extension Block: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}
