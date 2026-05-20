//
//  PortfolioTabButton.swift
//  Vestra
//
//  Created by Matthew Auciello on 18/5/2026.
//

import SwiftUI

struct PortfolioTabButton: ButtonStyle {
    
    var isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .lineLimit(1)
            .minimumScaleFactor(0.7)  
            .font(Font.theme.display(12).bold())
            .foregroundStyle(isSelected ? Color.white : Color.black)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.black : Color.theme.surface, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
        
    }
}

extension ButtonStyle where Self == PortfolioTabButton {
    static func customTab(for isSelected: Bool) -> PortfolioTabButton {
        .init(isSelected: isSelected)
    }
}

#Preview {
    @Previewable @State var selectedTab: Int = 0
    HStack {
        Button {
            selectedTab = 0
        } label: {
            Text("All -" + "5")
        }
        .buttonStyle(PortfolioTabButton.customTab(for: selectedTab == 0))
        Button {
            selectedTab = 1
        } label: {
            Text("Property")
        }
        .buttonStyle(PortfolioTabButton.customTab(for: selectedTab == 1))
    }
}
