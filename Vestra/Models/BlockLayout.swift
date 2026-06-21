//
//  BlockLayout.swift
//  Vestra
//
//  Single source of truth for block shapes & sizing rules.
//
//  Every page type (Property / ETF / Crypto) lays its blocks out against these
//  rules so the grid stays consistent across the app. View code *reads* from
//  here — it should not invent its own heights, spacings, or corner radii.
//

import SwiftUI

// MARK: - Width

/// How much horizontal space a block occupies in its row.
enum BlockWidth {
    case full   // fills the whole row
    case half   // two halves sit side by side in one row
}

extension BlockKind {
    /// The intrinsic width of each kind of block. This is what decides whether
    /// a block needs a full row or can share a row with another half block.
    var width: BlockWidth {
        switch self {
        // ETF cards — full width
        case .projection, .basket, .assumptions:
            return .full
        // Property cards - full width
        case .loan, .financialData, .details, .salesChart:
            return .full
        // Property cards - half width
        case .cashFlow, .expenses:
            return .half          // already laid out half-width on the property page
        // Content blocks
        case .section:
            return .full          // a header spans the row
        case .note:
            return .half          // notes can pair up; change to .full if you prefer
        // The "add a block" placeholders
        case .empty:
            return .full
        case .emptyHalf:
            return .half
        }
    }
}

// MARK: - Sizing rules

/// Universal dimensions shared by every page's block grid.
enum BlockLayout {
    /// Standard height of a row of cards, so the grid stays even.
    /// (Variable-height cards like the basket should scroll/clip to this.)
    static let rowHeight: CGFloat = 320

    /// Gap between rows, and between two half blocks in a row.
    static let spacing: CGFloat = 7

    /// One corner radius for every block card — replaces the per-card 24/12/16.
    static let cornerRadius: CGFloat = 24

    /// Horizontal inset of the grid from the screen edges.
    static let horizontalPadding: CGFloat = 16
}

// MARK: - Row

/// A horizontal row on a page: **either one full block, or up to two half blocks.**
/// This is the unit that actually gets stored and reordered — it's what lets a
/// side-by-side pair persist (a flat `[Block]` can't express "these share a row").
struct BlockRow: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var blocks: [Block]

    /// True if this row is occupied by a single full-width block.
    var isFull: Bool { blocks.first?.kind.width == .full }

    /// A half-row with one block still has space for a second half.
    var hasRoomForHalf: Bool { !isFull && blocks.count < 2 }

    init(_ blocks: [Block]) { self.blocks = blocks }
    init(_ block: Block)   { self.blocks = [block] }
}
