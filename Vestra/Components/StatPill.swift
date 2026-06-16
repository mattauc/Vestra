//
//  StatPill.swift
//  Vestra
//
//  Created by Matthew Auciello on 24/5/2026.
//

import SwiftUI

struct StatPill: View {
    let label: String
    let value: String
    let isCard: Bool
    var onCommit: ((String) -> Void)? = nil

    @State private var isEditing = false
    @State private var editText = ""
    @FocusState private var isFocused: Bool

    private var isEditable: Bool { onCommit != nil }

    private var fillColor: Color {
        if isCard { return Color.theme.onAsset.opacity(0.15) }
        return isEditable ? Color.theme.highlight.opacity(0.15) : Color.white
    }

    var body: some View {
        VStack(spacing: 2) {
            Text(label.uppercased())
                .font(Font.theme.mono(13, weight: .heavy))
                .foregroundStyle(isCard ? Color.theme.onAsset.opacity(0.7) : Color.black.opacity(0.7))
                .tracking(1.2)
                .frame(maxWidth: .infinity, alignment: isCard ? .leading : .center)
                .padding(.horizontal)

            if isEditing {
                TextField("", text: $editText)
                    .font(Font.theme.display(17, weight: .bold))
                    .foregroundStyle(isCard ? Color.white : Color.black)
                    .frame(maxWidth: .infinity, alignment: isCard ? .leading : .center)
                    .padding(.horizontal)
                    .focused($isFocused)
                    .onSubmit {
                        onCommit?(editText)
                        isEditing = false
                    }
                    .transition(.opacity)
            } else {
                Text(value)
                    .font(Font.theme.display(17, weight: .bold))
                    .foregroundStyle(isCard ? Color.white : Color.black)
                    .frame(maxWidth: .infinity, alignment: isCard ? .leading : .center)
                    .padding(.horizontal)
                    .transition(.opacity)
            }
        }
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(fillColor)
                .shadow(color: .black.opacity(isEditable ? 0 : 0.1), radius: 10, x: 1, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isCard ? Color.theme.onAsset.opacity(0.6) : Color.theme.highlight,
                    style: StrokeStyle(lineWidth: 1.5, dash: [5])
                )
                .opacity(isEditable ? 1 : 0)
        )
        .onTapGesture {
            guard onCommit != nil, !isEditing else { return }
            editText = value
            isEditing = true
        }
        .onChange(of: isEditing) { _, editing in
            if editing { isFocused = true }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // Card variant — sits on a colored asset background
        StatPill(label: "Equity", value: "$420,000", isCard: true)
            .padding()
            .background(Color.theme.property)
            .clipShape(RoundedRectangle(cornerRadius: 16))

        // Plain variant — white background
        StatPill(label: "Yield", value: "4.2%", isCard: false)

        // Editable variant — long-press to edit
        StatPill(label: "Loan Balance", value: "$310,000", isCard: false) { newValue in
            print("Committed: \(newValue)")
        }
    }
    .padding()
}
