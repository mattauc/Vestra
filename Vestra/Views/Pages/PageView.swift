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
    @Binding var path: NavigationPath
    
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
                
                .offset(x: xOffset)
                .rotationEffect(.degrees(degrees))
                .animation(.snappy, value: xOffset)
                .onTapGesture {
                    path = NavigationPath([page])
                }
                .simultaneousGesture(
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
        case .etf(let e):
            ETFPageView(pageId: e.id, pageIndex: $pageIndex)
        case .crypto:
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
    @Previewable @State var path = NavigationPath()
    let auth = AuthManager()
    return PageView(page: .property(PropertyPage()), pageIndex: $pageIndex, path: $path)
        .environmentObject(PageStore(authManager: auth))
}
