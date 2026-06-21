//
//  BlockPageManaging.swift
//  Vestra
//
//  Created by Matthew Auciello on 21/6/2026.
//

import Foundation

/// Shared block-grid behaviour for every page view model (ETF / Property / Crypto).
///
/// A conformer only has to expose its `rows` and say how to `persist`. The row
/// operations below are written once here and inherited by all conformers, so
/// `BlockGridView` can drive any page through this single interface.
@MainActor
protocol BlockPageManaging: ObservableObject {
    var rows: [BlockRow] { get set }
    func persist()
}

extension BlockPageManaging {
    /// Reorder whole rows (full-row drag).
    func moveRows(from: IndexSet, to: Int) {
        rows.move(fromOffsets: from, toOffset: to)
        persist()
    }

    /// Swap the two slots within a single half-row (left↔right).
    func swapBlocks(inRow rowIndex: Int, from: Int, to: Int) {
        rows[rowIndex].blocks.swapAt(from, to)
        persist()
    }

    /// Append a single empty "add a block" row, unless one already exists.
    func addRow() {
        let hasEmpty = rows.contains { row in
            row.blocks.contains { $0.kind == .empty }
        }
        guard !hasEmpty else { return }
        rows.append(BlockRow(Block(kind: .empty)))
        persist()
    }
}
