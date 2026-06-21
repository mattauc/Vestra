//
//  PropertyDetailCard.swift
//  Vestra
//
//  Created by Matthew Auciello on 21/6/2026.
//

import SwiftUI

struct PropertyDetailCard: View {
    @ObservedObject var manager: PropertyPageManager
    @State private var pageTitle: String = ""
    @State private var isEditingTitle = false

    var body: some View {
        GroupBox(label: titleDisplay
            .fixedSize(horizontal: false, vertical: true)) {
            VStack() {
                Text(manager.propertyDetails)
                    .font(Font.theme.ui(15))
                    .foregroundStyle(Color.theme.onAsset.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 20)

                estimateDisplay
                HStack {
                    StatPill(label: "Purchase", value: manager.lastSoldPrice.formattedAUD(), isCard: true)
                    Spacer()
                    StatPill(label: "Gain", value: manager.propertyGain.formattedAUD(), isCard: true)
                    Spacer()
                    StatPill(label: "Held", value: manager.yearsHeld, isCard: true)
                }

            }
        }
        .frame(maxWidth: .infinity)
        .groupBoxStyle(.custom(for: .property(PropertyPage())))
    }

    var titleDisplay: some View {
        HStack {
            if isEditingTitle {
                TextField("New Property", text: $pageTitle)
                    .font(.largeTitle.weight(.black))
                    .textFieldStyle(.plain)
                    .onChange(of: pageTitle) { _, newValue in
                        manager.title = newValue
                    }
                    .onSubmit {
                        isEditingTitle = false
                        Task {
                            await manager.sendPropertyAddress(address: manager.title)
                        }
                    }
            } else {
                Text(manager.title == "" ? "New Property" : manager.title)
                    .font(.largeTitle.weight(.bold))
                    .font(.largeTitle.weight(.bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
            }
            Spacer()
            Button {
                isEditingTitle = true
            } label: {
                Image(systemName: "pencil")
                    .font(.title2)
                    .foregroundStyle(Color.theme.onAccent)
            }
        }
        .frame(height: 50)
    }

    var estimateDisplay: some View {
        let low = manager.estimateLowPirce
        let high = manager.estimateHighPrice
        let mid = manager.estimateMidPrice
        let confidence = manager.estimateConfidence
        let ratio = high > low ? CGFloat((mid - low) / (high - low)) : 0.5

        return VStack(alignment: .leading, spacing: 4) {
            Text("ESTIMATE")
                .font(Font.theme.mono(15, weight: .heavy))
                .foregroundStyle(Color.theme.onAsset.opacity(0.7))
                .tracking(1.2)

            Text(mid.formattedAUD())
                .font(.largeTitle.bold())
                .foregroundStyle(Color.white)
                .padding(.bottom, 8)

            // Horizontal range line with yellow circle at the mid position
            GeometryReader { geo in
                let lineWidth = geo.size.width
                let circleX = max(0, min(ratio * lineWidth - 7, lineWidth - 14))
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.25))
                        .frame(height: 3)
                        .frame(maxWidth: .infinity)
                        .offset(y: 5)
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 14, height: 14)
                        .offset(x: circleX)
                        .shadow(color: .yellow.opacity(0.9), radius: 7, x: 0, y: 0)
                }
            }
            .frame(height: 14)
            HStack {
                VStack {
                    Text("LOW")
                        .font(Font.theme.mono(12, weight: .heavy))
                        .foregroundStyle(Color.theme.onAsset.opacity(0.7))
                        .tracking(1.2)
                    Text(low.formattedAUD())
                        .font(Font.theme.mono(20))
                        .foregroundStyle(Color.white)
                }
                Spacer()
                VStack {
                    Text("CONFIDENCE")
                        .font(Font.theme.mono(12, weight: .heavy))
                        .foregroundStyle(Color.theme.onAsset.opacity(0.7))
                        .tracking(1.2)
                    Text(confidence)
                        .font(Font.theme.mono(20))
                        .foregroundStyle(Color.white)
                        .tracking(1.2)
                }
                Spacer()
                VStack {
                    Text("HIGH")
                        .font(Font.theme.mono(12, weight: .heavy))
                        .foregroundStyle(Color.theme.onAsset.opacity(0.7))
                        .tracking(1.2)
                    Text(high.formattedAUD())
                        .font(Font.theme.mono(20))
                        .foregroundStyle(Color.white)
                }
            }
        }
        .padding(.bottom, 8)
    }
}
