//
//  PageView.swift
//  Vestra
//
//  Created by Matthew Auciello on 23/3/2026.
//

import SwiftUI

struct PageView: View {
    
    var page: PortfolioPage
    @Binding var pageIndex: Int
    @State private var xOffset: CGFloat = 0
//    @State private var yOffset: CGFloat = 0
    @State private var degrees: Double = 0
    
    var body: some View {
        ZStack {
            pageView(for: page)
                .frame(width: pageWidth, height: pageHeight)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 10)
                )
                .background(Color.cyan)
                .offset(x: xOffset)
                .rotationEffect(.degrees(degrees))
                .animation(.snappy, value: xOffset)
                .gesture(
                    DragGesture()
                        .onChanged(onDragChanged)
                        .onEnded(onDragEnded)
                )
        }
    }
    
    @ViewBuilder
    private func pageView(for page: PortfolioPage) -> some View {
        switch page {
        case .property(let p):
            PropertyPageView(pageId: p.id, pageIndex: $pageIndex)
        case .etf, .crypto:
            EmptyView() // TODO: ETFPageView / CryptoPageView
        }
    }
}

private extension PageView {
    func onDragChanged(_ value: _ChangedGesture<DragGesture>.Value) {
        xOffset = value.translation.width
//                                        yOffset = value.translation.height
        degrees = Double(value.translation.width / 25)
    }
    
    func onDragEnded(_ value: _ChangedGesture<DragGesture>.Value) {
        let width = value.translation.width
        
        if abs(width) <= abs(screenCutOff) {
            xOffset = 0
            degrees = 0
        }
    }
}

private extension PageView {
    var screenCutOff: CGFloat {
        (UIScreen.main.bounds.width / 2) * 0.8
    }
    
    var pageWidth: CGFloat {
        UIScreen.main.bounds.width - 20
    }
    
    var pageHeight: CGFloat {
        UIScreen.main.bounds.height / 1.45
    }
}

#Preview {
    @Previewable @State var pageIndex = 0
    let auth = AuthManager()
    return PageView(page: .property(PropertyPage()), pageIndex: $pageIndex)
        .environmentObject(PageStore(authManager: auth))
}
