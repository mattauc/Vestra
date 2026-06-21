//
//  BlockGridView.swift
//  Vestra
//
//  Created by Matthew Auciello on 21/6/2026.
//

import SwiftUI

/// The shared block grid. It renders a page's `rows` and owns ALL the
/// drag-to-reorder, half-row left↔right swap, and empty-slot behaviour.
///
/// Each page injects only two things:
/// - `manager`  — any `BlockPageManaging` view model (its rows + mutations)
/// - `card`     — how to draw a real block (its kind → its card view)
///
/// `.empty` / `.emptyHalf` slots are handled here; `card` is only asked for
/// real blocks.
struct BlockGridView<Manager: BlockPageManaging, Card: View>: View {
    @ObservedObject var manager: Manager
    var accent: Color
    @ViewBuilder var card: (Block) -> Card

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: BlockLayout.spacing) {
                ForEach(manager.rows) { row in
                    rowView(row)
                }
            }
            .padding(.top)
            .padding(.bottom, 5)
        }
    }

    // MARK: - Rows

    /// Three row shapes:
    /// - full add placeholder (a `.empty` block) — inert, not draggable/droppable
    /// - half row (half blocks + `.emptyHalf` slots) — slots swap left↔right within the row
    /// - full row (one full block) — draggable, reorders among other rows
    @ViewBuilder
    private func rowView(_ row: BlockRow) -> some View {
        if isFullEmptyRow(row) {
            EmptyBlockCard(accent: accent)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, BlockLayout.horizontalPadding)
        } else if isHalfRow(row) {
            halfRow(row)
        } else {
            fullRow(row)
        }
    }

    /// A single full-width block. Draggable; drop another full block here to reorder.
    @ViewBuilder
    private func fullRow(_ row: BlockRow) -> some View {
        let block = row.blocks[0]
        card(block)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.dragPreview, RoundedRectangle(cornerRadius: BlockLayout.cornerRadius))
            .draggable(block) {
                card(block)
                    .frame(width: 320)
                    .contentShape(.dragPreview, RoundedRectangle(cornerRadius: BlockLayout.cornerRadius))
            }
            .padding(.horizontal, BlockLayout.horizontalPadding)
            .dropDestination(for: Block.self) { dropped, _ in
                moveRow(of: dropped.first, toRowOf: row.id)
            }
    }

    /// Two half slots side by side. A real half is draggable; each slot accepts a
    /// drop that swaps with the dragged half — but only if it came from this row.
    @ViewBuilder
    private func halfRow(_ row: BlockRow) -> some View {
        HStack(spacing: BlockLayout.spacing) {
            ForEach(Array(row.blocks.enumerated()), id: \.element.id) { index, block in
                halfSlot(block, at: index, in: row)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, BlockLayout.horizontalPadding)
    }

    @ViewBuilder
    private func halfSlot(_ block: Block, at index: Int, in row: BlockRow) -> some View {
        if isEmptyHalf(block) {
            EmptyHalfSlot(accent: accent) { dropped in
                handleHalfDrop(dropped, row: row, targetIndex: index)
            }
        } else {
            card(block)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.dragPreview, RoundedRectangle(cornerRadius: BlockLayout.cornerRadius))
                .draggable(block) {
                    card(block)
                        .frame(width: 160)
                        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: BlockLayout.cornerRadius))
                }
                .dropDestination(for: Block.self) { dropped, _ in
                    handleHalfDrop(dropped.first, row: row, targetIndex: index)
                }
        }
    }

    /// A drop onto a half slot. If the dragged block is already in this row, swap
    /// the two halves (left↔right). Otherwise it came from a different row, so
    /// reorder whole rows — this is what lets a full row and a half row move past
    /// each other in either direction.
    private func handleHalfDrop(_ dragged: Block?, row: BlockRow, targetIndex: Int) -> Bool {
        guard let dragged else { return false }
        if row.blocks.contains(dragged) {
            return swapWithinRow(dragged, row: row, targetIndex: targetIndex)
        } else {
            return moveRow(of: dragged, toRowOf: row.id)
        }
    }

    // MARK: - Helpers

    private func isFullEmptyRow(_ row: BlockRow) -> Bool {
        row.blocks.contains { if case .empty = $0.kind { return true }; return false }
    }

    private func isHalfRow(_ row: BlockRow) -> Bool {
        row.blocks.first?.kind.width == .half
    }

    private func isEmptyHalf(_ block: Block) -> Bool {
        if case .emptyHalf = block.kind { return true }
        return false
    }

    /// Move the dragged block's row to sit at the target row's position.
    private func moveRow(of dragged: Block?, toRowOf targetID: UUID) -> Bool {
        guard let dragged,
              let from = manager.rows.firstIndex(where: { $0.blocks.contains(dragged) }),
              let to = manager.rows.firstIndex(where: { $0.id == targetID }) else { return false }
        withAnimation {
            manager.moveRows(from: IndexSet(integer: from), to: to > from ? to + 1 : to)
        }
        return true
    }

    /// Swap two slots inside one row — only if the dragged block belongs to this row.
    private func swapWithinRow(_ dragged: Block?, row: BlockRow, targetIndex: Int) -> Bool {
        guard let dragged,
              let rowIndex = manager.rows.firstIndex(where: { $0.id == row.id }),
              let fromIndex = manager.rows[rowIndex].blocks.firstIndex(of: dragged),
              fromIndex != targetIndex else { return false }
        withAnimation {
            manager.swapBlocks(inRow: rowIndex, from: fromIndex, to: targetIndex)
        }
        return true
    }
}
