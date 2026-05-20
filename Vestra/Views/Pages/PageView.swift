//
//  PageView.swift
//  Vestra
//
//  Created by Matthew Auciello on 23/3/2026.
//

import SwiftUI

struct PageView: View {
    
    @EnvironmentObject var pageStore: PageStore
    
    var page: PortfolioPage
    @Binding var pageIndex: Int
    @Binding var path: NavigationPath
    
    @State private var xOffset: CGFloat = 0
//    @State private var yOffset: CGFloat = 0
    @State private var degrees: Double = 0
    var onSwiped: () -> Void
    
    var body: some View {
        PortfolioCardFace(page: page)
            .frame(width: pageWidth, height: pageHeight)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 2, y: 1)
            .offset(x: xOffset)
            .rotationEffect(.degrees(degrees))
            .animation(.snappy, value: xOffset)
            .onTapGesture { path = NavigationPath([page]) }
            .simultaneousGesture(
                DragGesture()
                    .onChanged(onDragChanged)
                    .onEnded(onDragEnded)
            )
    }
}

private extension PageView {
    func onDragChanged(_ value: _ChangedGesture<DragGesture>.Value) {
        xOffset = value.translation.width
//      yOffset = value.translation.height
//        degrees = Double(value.translation.width / 25)
    }
    
    func onDragEnded(_ value: _ChangedGesture<DragGesture>.Value) {
      let width = value.translation.width

      if abs(width) > abs(screenCutOff) {
          // fly off screen
          withAnimation(.easeInOut(duration: 0.3)) {
              xOffset = width > 0 ? 1000 : -1000
//              degrees = width > 0 ? 20 : -20
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
              onSwiped()  // tell parent to move it to the bottom
              xOffset = 0
              degrees = 0
          }
      } else {
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
        UIScreen.main.bounds.height / 2
    }
    
}

//#Preview {
//    @Previewable @State var pageIndex = 0
//    @Previewable @State var path = NavigationPath()
//    let auth = AuthManager()
//    PageView(page: .property(PropertyPage()), pageIndex: $pageIndex, path: $path, onSwiped: <#() -> Void#>)
//        .environmentObject(PageStore(authManager: auth))
//}
