//
//  EmptyBlockCard.swift
//  Vestra
//
//  Created by Matthew Auciello on 20/6/2026.
//

import SwiftUI

/// The "add a block" placeholder shown when a row has no content yet.
///
/// Inert to drag-and-drop on its own — content only enters a row via its `+`
/// (picker), wired separately. `accent` lets each page tint it (etf/property/…).
struct EmptyBlockCard: View {

    var accent: Color = Color.theme.etf
    var blockHeight: CGFloat = 300
    /// Brightens the card while a valid drag is hovering it (half-slot swap).
    var isTargeted: Bool = false

    var body: some View {
        Image(systemName: "plus.circle.fill")
            .font(.system(size: 60))
            .foregroundStyle(accent.opacity(isTargeted ? 1 : 0.6))
            .frame(maxWidth: .infinity, minHeight: blockHeight)
            .background(
                RoundedRectangle(cornerRadius: BlockLayout.cornerRadius)
                    .fill(accent.opacity(isTargeted ? 0.2 : 0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: BlockLayout.cornerRadius)
                    .strokeBorder(
                        accent.opacity(isTargeted ? 1 : 0.6),
                        style: StrokeStyle(lineWidth: 1.5, dash: [5])
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: isTargeted)
    }
}

/// The empty half of a one-half row. Owns the `isTargeted` state so the card can
/// brighten while a drag hovers it; reports the dropped block back via `onDrop`.
struct EmptyHalfSlot: View {
    var accent: Color
    let onDrop: (Block?) -> Bool
    @State private var isTargeted = false

    var body: some View {
        EmptyBlockCard(accent: accent, isTargeted: isTargeted)
            .frame(maxWidth: .infinity)
            .dropDestination(for: Block.self) { dropped, _ in
                onDrop(dropped.first)
            } isTargeted: { isTargeted = $0 }
    }
}

#Preview {
    EmptyBlockCard()
        .padding()
        .background(Color.theme.depth)
}
